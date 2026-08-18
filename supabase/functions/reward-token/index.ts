// Reward token grants — service-role Edge Function.
//
// Verifies the caller's JWT, then grants tokens into `profiles.token_balance`:
//   reward_type: 'video' -> +2 tokens (rewarded ad)
//   reward_type: 'rate'  -> +5 tokens (one-time, tracked by profiles.has_rated)
//
// Auto-injected secrets: SUPABASE_URL, SUPABASE_ANON_KEY,
// SUPABASE_SERVICE_ROLE_KEY.

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

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization') ?? '';
    if (!authHeader) {
      return json({ error: 'Missing Authorization header' }, 401);
    }

    const url = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    // Verify the caller's JWT.
    const userClient = createClient(url, anonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });
    const {
      data: { user },
      error: authError,
    } = await userClient.auth.getUser();
    if (authError || !user) {
      return json({ error: 'Unauthorized' }, 401);
    }

    const body = (await req.json()) as { reward_type?: string };
    const rewardType = body.reward_type;

    const admin = createClient(url, serviceRole);
    const { data: profile } = await admin
      .from('profiles')
      .select('token_balance, has_rated')
      .eq('id', user.id)
      .single();

    if (!profile) {
      return json({ error: 'PROFILE_NOT_FOUND' }, 404);
    }

    let amount = 0;
    const updates: Record<string, unknown> = {};

    if (rewardType === 'video') {
      amount = 2;
    } else if (rewardType === 'rate') {
      if (profile.has_rated) {
        return json({ error: 'already_rated', granted: 0 }, 400);
      }
      amount = 5;
      updates.has_rated = true;
    } else {
      return json({ error: 'invalid reward_type' }, 400);
    }

    updates.token_balance = (Number(profile.token_balance ?? 0) || 0) + amount;
    const { error: updateError } = await admin
      .from('profiles')
      .update(updates)
      .eq('id', user.id);
    if (updateError) {
      return json({ error: updateError.message }, 500);
    }

    return json({ granted: amount });
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Internal error';
    return json({ error: message }, 500);
  }
});
