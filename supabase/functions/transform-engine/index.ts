// ============================================================================
// Supabase Edge Function: transform-engine
// Hybrid AI router for the Estetix AI transform pipeline.
//
//   Gemini 1.5 Flash  -> analyzes the image (summary + missing items)
//   FLUX.1 [dev]      -> free render (Replicate)
//   gpt-image-1       -> premium render (OpenAI images/edits — the current
//                        DALL·E-class image-editing model)
//   DeepSeek-V3       -> e-commerce products (name, price, search URL) + DIY steps
//   Affiliate router  -> appends ?subid=estetix_app to every product URL
//   deduct_token RPC  -> 3 tokens (premium) / 1 token (free) after success
//
// Required secrets (set before deploy):
//   supabase secrets set GEMINI_API_KEY=... REPLICATE_API_TOKEN=... \
//     OPENAI_API_KEY=... DEEPSEEK_API_KEY=...
//
// Deploy: supabase functions deploy transform-engine --no-verify-jwt=false
// The request must carry the user's JWT; the Flutter client sends it
// automatically through supabase.functions.invoke().
// ============================================================================

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const AFFILIATE_SUBID = 'estetix_app';
const ALLOWED_MODULES = new Set<string>(['space', 'wardrobe', 'kitchen']);

type ModuleType = 'space' | 'wardrobe' | 'kitchen';

interface TransformRequestBody {
  image_url?: string;
  image_base64?: string;
  module_type?: string;
  is_premium?: boolean;
  style?: string;
}

interface GeminiAnalysis {
  summary: string;
  missing_items: string[];
}

interface ProductRow {
  name: string;
  price_estimate: string;
  search_url: string;
}

interface DeepSeekResult {
  products: ProductRow[];
  diy_steps: string[];
}

const STYLE_HINTS: Record<string, string> = {
  budget: 'low-budget, zero-cost approach using repurposed or affordable items',
  luxury: 'luxurious, high-end approach with premium materials',
  rainy: 'rainy-weather-ready approach: moody, practical and weatherproof',
  cozy: 'cozy, warm and inviting approach',
};

const ANALYSIS_PROMPTS: Record<ModuleType, string> = {
  space:
    'You are an interior design analyst. Analyze the room in the image and list what is missing or could be improved (furniture, decor, lighting, layout). Reply with ONLY JSON: {"summary": string, "missing_items": string[]}',
  wardrobe:
    'You are a fashion stylist. Analyze the outfit in the image and list missing or improvable items (garments, accessories, colors). Reply with ONLY JSON: {"summary": string, "missing_items": string[]}',
  kitchen:
    'You are a nutrition and kitchen analyst. Analyze the image and identify the dish or kitchen setup; list missing ingredients or tools. Reply with ONLY JSON: {"summary": string, "missing_items": string[]}',
};

const MODULE_ACTIONS: Record<ModuleType, string> = {
  space: 'redesign this interior space',
  wardrobe: 'restyle this outfit',
  kitchen: 'improve this meal or kitchen setup',
};

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization') ?? '';
    if (!authHeader) {
      return json({ error: 'Missing Authorization header' }, 401);
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      {
        global: { headers: { Authorization: authHeader } },
        auth: { persistSession: false },
      },
    );

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();
    if (authError || !user) {
      return json({ error: 'Unauthorized' }, 401);
    }

    const body = (await req.json()) as TransformRequestBody;
    const moduleType = body.module_type as ModuleType;
    if (!moduleType || !ALLOWED_MODULES.has(moduleType)) {
      return json({ error: 'invalid module_type' }, 400);
    }
    if (typeof body.is_premium !== 'boolean') {
      return json({ error: 'invalid is_premium' }, 400);
    }

    // 0) Atomic balance pre-check — fail fast before any paid AI call.
    const amount = body.is_premium ? 3 : 1;
    const { error: precheckError } = await supabase.rpc('precheck_transform', {
      user_id: user.id,
      amount,
    });
    if (precheckError) {
      return json({ error: precheckError.message }, 402);
    }

    // 1) Resolve the input image (URL download or inline base64).
    const { mime, base64 } = await resolveImage(body);

    // 2) Gemini 1.5 Flash: analyze the scene / outfit / dish.
    const analysis = await analyzeWithGemini(base64, mime, moduleType);
    const prompt = buildRenderPrompt(moduleType, body.style ?? '', analysis);

    // 3) Render: FLUX.1 [dev] (free) or gpt-image-1 edits (premium).
    const renderBytes = body.is_premium
      ? await renderWithOpenAI(base64, mime, prompt)
      : await renderWithReplicate(base64, mime, prompt);

    // 4) Persist the render into Supabase Storage (public bucket).
    const renderUrl = await uploadRender(supabase, user.id, renderBytes);

    // 5) DeepSeek-V3: products + DIY steps.
    const shopping = await searchProductsWithDeepSeek(moduleType, analysis);
    const products = shopping.products.map((p) => ({
      name: p.name,
      price_estimate: p.price_estimate,
      search_url: appendSubid(p.search_url, AFFILIATE_SUBID),
    }));

    // 6) Token deduction (authoritative; atomic).
    const { error: deductError } = await supabase.rpc('deduct_token', {
      user_id: user.id,
      amount,
    });
    if (deductError) {
      return json({ error: deductError.message }, 402);
    }

    return json({
      render_image_url: renderUrl,
      analysis_summary: analysis.summary,
      products,
      diy_steps: shopping.diy_steps,
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Internal error';
    return json({ error: message }, 500);
  }
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'Content-Type': 'application/json', ...corsHeaders },
  });
}

async function resolveImage(
  body: TransformRequestBody,
): Promise<{ mime: string; base64: string }> {
  if (body.image_base64) {
    const parsed = stripDataUri(body.image_base64);
    return parsed ?? { mime: 'image/jpeg', base64: body.image_base64 };
  }
  if (body.image_url) {
    const res = await fetch(body.image_url);
    if (!res.ok) {
      throw new Error(`Failed to download input image (${res.status})`);
    }
    const mime = res.headers.get('content-type') ?? 'image/jpeg';
    const buffer = new Uint8Array(await res.arrayBuffer());
    return { mime, base64: bytesToBase64(buffer) };
  }
  throw new Error('image_url or image_base64 is required');
}

function stripDataUri(
  value: string,
): { mime: string; base64: string } | null {
  const match = value.match(/^data:([^;,]+);base64,(.+)$/s);
  if (!match) return null;
  return { mime: match[1], base64: match[2] };
}

function bytesToBase64(bytes: Uint8Array): string {
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

function base64ToBytes(base64: string): Uint8Array {
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
}

function stripCodeFences(text: string): string {
  return text
    .replace(/^```(?:json)?\s*/i, '')
    .replace(/\s*```$/i, '')
    .trim();
}

async function analyzeWithGemini(
  imageBase64: string,
  mime: string,
  moduleType: ModuleType,
): Promise<GeminiAnalysis> {
  const apiKey = Deno.env.get('GEMINI_API_KEY') ?? '';
  if (!apiKey) throw new Error('GEMINI_API_KEY is not set');

  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [
        {
          parts: [
            { text: ANALYSIS_PROMPTS[moduleType] },
            { inlineData: { mimeType: mime, data: imageBase64 } },
          ],
        },
      ],
      generationConfig: { temperature: 0.4, responseMimeType: 'application/json' },
    }),
  });
  if (!res.ok) {
    throw new Error(`Gemini request failed (${res.status}): ${await res.text()}`);
  }

  const data = await res.json();
  const raw: string = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? '';
  try {
    const parsed = JSON.parse(stripCodeFences(raw));
    return {
      summary: String(parsed.summary ?? ''),
      missing_items: Array.isArray(parsed.missing_items)
        ? parsed.missing_items.map(String)
        : [],
    };
  } catch {
    return { summary: raw.slice(0, 500), missing_items: [] };
  }
}

function buildRenderPrompt(
  moduleType: ModuleType,
  style: string,
  analysis: GeminiAnalysis,
): string {
  const improvements =
    analysis.missing_items.length > 0
      ? analysis.missing_items.join(', ')
      : analysis.summary;
  const styleHint = STYLE_HINTS[style] ?? 'natural, realistic';
  return (
    `Photorealistic ${MODULE_ACTIONS[moduleType]}. ` +
    `Improvements to apply: ${improvements}. ` +
    `Style: ${styleHint}. Keep the original layout and camera angle.`
  );
}

async function renderWithReplicate(
  imageBase64: string,
  mime: string,
  prompt: string,
): Promise<Uint8Array> {
  const token = Deno.env.get('REPLICATE_API_TOKEN') ?? '';
  if (!token) throw new Error('REPLICATE_API_TOKEN is not set');

  const model = 'black-forest-labs/flux-dev';
  const createRes = await fetch(
    `https://api.replicate.com/v1/models/${model}/predictions`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        Prefer: 'wait',
      },
      body: JSON.stringify({
        input: {
          prompt,
          image: `data:${mime};base64,${imageBase64}`,
          strength: 0.65,
          guidance: 3.5,
          num_outputs: 1,
          output_format: 'png',
        },
      }),
    },
  );
  if (!createRes.ok) {
    throw new Error(
      `Replicate request failed (${createRes.status}): ${await createRes.text()}`,
    );
  }

  let prediction = await createRes.json();
  for (let i = 0; i < 25 && prediction.status !== 'succeeded'; i++) {
    if (prediction.status === 'failed' || prediction.status === 'canceled') {
      throw new Error(`Replicate prediction ${prediction.status}`);
    }
    await new Promise((resolve) => setTimeout(resolve, 2000));
    const pollRes = await fetch(prediction.urls.get, {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!pollRes.ok) {
      throw new Error(`Replicate poll failed (${pollRes.status})`);
    }
    prediction = await pollRes.json();
  }
  if (prediction.status !== 'succeeded') {
    throw new Error('Replicate prediction timed out');
  }

  const output = Array.isArray(prediction.output)
    ? prediction.output[0]
    : prediction.output;
  if (typeof output !== 'string') {
    throw new Error('Replicate returned no image URL');
  }
  const imgRes = await fetch(output);
  if (!imgRes.ok) {
    throw new Error(`Failed to download render (${imgRes.status})`);
  }
  return new Uint8Array(await imgRes.arrayBuffer());
}

async function renderWithOpenAI(
  imageBase64: string,
  mime: string,
  prompt: string,
): Promise<Uint8Array> {
  const apiKey = Deno.env.get('OPENAI_API_KEY') ?? '';
  if (!apiKey) throw new Error('OPENAI_API_KEY is not set');

  const form = new FormData();
  form.append('model', 'gpt-image-1');
  form.append('prompt', prompt);
  form.append('image', new File([base64ToBytes(imageBase64)], 'input.png', { type: mime }));
  form.append('n', '1');
  form.append('size', '1024x1024');
  form.append('response_format', 'url');

  const res = await fetch('https://api.openai.com/v1/images/edits', {
    method: 'POST',
    headers: { Authorization: `Bearer ${apiKey}` },
    body: form,
  });
  if (!res.ok) {
    throw new Error(
      `OpenAI request failed (${res.status}): ${await res.text()}`,
    );
  }

  const data = await res.json();
  const url: unknown = data?.data?.[0]?.url;
  if (typeof url !== 'string') throw new Error('OpenAI returned no image URL');
  const imgRes = await fetch(url);
  if (!imgRes.ok) {
    throw new Error(`Failed to download render (${imgRes.status})`);
  }
  return new Uint8Array(await imgRes.arrayBuffer());
}

async function searchProductsWithDeepSeek(
  moduleType: ModuleType,
  analysis: GeminiAnalysis,
): Promise<DeepSeekResult> {
  const apiKey = Deno.env.get('DEEPSEEK_API_KEY') ?? '';
  if (!apiKey) throw new Error('DEEPSEEK_API_KEY is not set');

  const userPrompt = [
    `Module: ${moduleType}.`,
    `Analysis: ${analysis.summary}`,
    `Missing items: ${analysis.missing_items.join(', ') || 'none'}.`,
    'Find up to 5 realistic products with estimated prices in Turkish Lira (₺) and working search URLs.',
    'Prefer https://www.trendyol.com/sr?q=<query> or https://www.hepsiburada.com/ara?q=<query> style URLs.',
    'Also write 3-5 practical DIY/recipe steps to apply this transformation.',
    'Respond with ONLY JSON: {"products":[{"name":"...","price_estimate":"₺...","search_url":"https://..."}],"diy_steps":["..."]}',
  ].join('\n');

  const res = await fetch('https://api.deepseek.com/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: 'deepseek-chat',
      messages: [
        {
          role: 'system',
          content:
            'You are an e-commerce shopping and DIY assistant. Return only valid JSON.',
        },
        { role: 'user', content: userPrompt },
      ],
      temperature: 0.3,
      response_format: { type: 'json_object' },
    }),
  });
  if (!res.ok) {
    throw new Error(`DeepSeek request failed (${res.status}): ${await res.text()}`);
  }

  const data = await res.json();
  const raw: string = data?.choices?.[0]?.message?.content ?? '';
  try {
    const parsed = JSON.parse(stripCodeFences(raw));
    const products: ProductRow[] = Array.isArray(parsed.products)
      ? parsed.products.map(
          (p: {
            name?: unknown;
            price_estimate?: unknown;
            search_url?: unknown;
          }) => ({
            name: String(p.name ?? 'Ürün'),
            price_estimate: String(p.price_estimate ?? '—'),
            search_url: String(p.search_url ?? ''),
          }),
        )
      : [];
    const diySteps: string[] = Array.isArray(parsed.diy_steps)
      ? parsed.diy_steps.map(String)
      : [];
    return { products, diy_steps: diySteps };
  } catch {
    return { products: [], diy_steps: [] };
  }
}

async function uploadRender(
  supabase: SupabaseClient,
  userId: string,
  bytes: Uint8Array,
): Promise<string> {
  const path = `public/${userId}/${crypto.randomUUID()}.png`;
  const { error } = await supabase.storage.from('renders').upload(path, bytes, {
    contentType: 'image/png',
    upsert: false,
  });
  if (error) throw new Error(`Render upload failed: ${error.message}`);

  const { data } = supabase.storage.from('renders').getPublicUrl(path);
  return data.publicUrl;
}

function appendSubid(url: string, subid: string): string {
  if (!url) return url;
  const separator = url.includes('?') ? '&' : '?';
  return `${url}${separator}subid=${subid}`;
}
