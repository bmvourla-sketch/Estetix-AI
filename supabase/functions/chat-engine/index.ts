// Conversational AI: a chat endpoint that understands the user's need through
// back-and-forth questions instead of a form.
//
//   body: { module: 'fashion'|'outdoor'|'interior'|'diet',
//           messages: [{ role: 'user'|'assistant', content: string }] }
//   -> { reply: string }
//
// Auto-injected secrets: SUPABASE_URL, SUPABASE_ANON_KEY, DEEPSEEK_API_KEY.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

const SYSTEM_PROMPTS: Record<string, string> = {
  fashion:
    "Sen bir moda stilistisin. Kullanıcının 'bugün ne giysem' ihtiyacını sohbetle anlamaya çalış. Tek seferde bir soru sor (etkinlik, hava, tarz, ruh hali vb.). Kısa ve sıcak konuş.",
  outdoor:
    'Sen bir bahçe ve dış mekan tasarımcısısın. Kullanıcının tasarım ihtiyacını sohbetle anlamaya çalış. Tek seferde bir soru sor. Kısa ve sıcak konuş.',
  interior:
    'Sen bir iç mekan tasarımcısısın. Kullanıcının dekorasyon ihtiyacını sohbetle anlamaya çalış. Tek seferde bir soru sor. Kısa ve sıcak konuş.',
  diet:
    'Sen bir diyetisyensin. Kullanıcının beslenme ihtiyacını sohbetle anlamaya çalış (hedef, rahatsızlık, tercihler). Tek seferde bir soru sor. Kısa ve sıcak konuş.',
};

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization') ?? '';
    if (!authHeader) return json({ error: 'Missing Authorization header' }, 401);

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      {
        global: { headers: { Authorization: authHeader } },
        auth: { persistSession: false },
      },
    );
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) return json({ error: 'Unauthorized' }, 401);

    const body = (await req.json()) as {
      module?: string;
      messages?: { role: string; content: string }[];
    };
    const module = body.module ?? 'fashion';
    const messages = body.messages ?? [];

    const apiKey = Deno.env.get('DEEPSEEK_API_KEY') ?? '';
    if (!apiKey) return json({ error: 'DEEPSEEK_API_KEY is not set' }, 500);

    const res = await fetch('https://api.deepseek.com/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: 'deepseek-chat',
        messages: [
          { role: 'system', content: SYSTEM_PROMPTS[module] ?? SYSTEM_PROMPTS.fashion },
          ...messages,
        ],
        temperature: 0.7,
      }),
    });
    if (!res.ok) {
      return json({ error: `DeepSeek failed (${res.status})` }, 500);
    }

    const data = await res.json();
    const reply: string = data?.choices?.[0]?.message?.content ?? '';
    return json({ reply });
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Internal error';
    return json({ error: message }, 500);
  }
});
