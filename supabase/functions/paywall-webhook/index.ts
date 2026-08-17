// ============================================================================
// Supabase Edge Function: paywall-webhook
// Server-side RevenueCat purchase verification.
//
// The RevenueCat dashboard posts events here with an Authorization header:
//   Authorization: Bearer <your webhook auth key>
// We validate that secret, then use the SERVICE ROLE key to grant credits or
// pro status via the RPCs that were revoked from `authenticated`.
//
// Required secrets:
//   supabase secrets set REVENUECAT_WEBHOOK_AUTH_KEY=<your webhook secret>
//   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<your service_role key>
//
// Events handled:
//   INITIAL_PURCHASE / RENEWAL -> pro subscription (set_pro_status true)
//   NON_RENEWING_PURCHASE      -> credit consumable  (update_user_credits)
//   EXPIRATION                 -> pro lapsed          (set_pro_status false)
//
// IMPORTANT: the Flutter app must set RevenueCat's app-user-id to the Supabase
// user id (Purchases.logIn(userId)) so `event.app_user_id` maps to profiles.id.
// ============================================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const PRO_ENTITLEMENT = 'pro_access';

// RevenueCat product id -> credits granted.
const CREDIT_PRODUCTS: Record<string, number> = {
  credits_3: 3,
  credits_5: 5,
  credits_10: 10,
};

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  // 1) Authenticate the webhook using the shared secret.
  const expected = Deno.env.get('REVENUECAT_WEBHOOK_AUTH_KEY') ?? '';
  const authHeader = req.headers.get('Authorization') ?? '';
  if (!expected || authHeader !== `Bearer ${expected}`) {
    return json({ error: 'Unauthorized' }, 401);
  }

  let body: Record<string, unknown>;
  try {
    body = (await req.json()) as Record<string, unknown>;
  } catch {
    return json({ error: 'Invalid JSON' }, 400);
  }

  const event = (body['event'] ?? {}) as Record<string, unknown>;
  const type = String(event['type'] ?? '');
  const appUserId = String(event['app_user_id'] ?? '');
  const productId = String(event['product_id'] ?? '');
  const entitlementIds = Array.isArray(event['entitlement_ids'])
    ? (event['entitlement_ids'] as unknown[]).map(String)
    : [];

  if (!appUserId) {
    return json({ error: 'missing app_user_id' }, 400);
  }

  // 2) Service-role client (bypasses RLS; the grant-self RPCs are only
  //    executable by service_role now).
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false } },
  );

  switch (type) {
    case 'NON_RENEWING_PURCHASE': {
      const credits = CREDIT_PRODUCTS[productId];
      if (!credits) return json({ received: true, ignored: 'unknown_product' });
      const { error } = await supabase.rpc('update_user_credits', {
        user_id: appUserId,
        delta: credits,
      });
      if (error) return json({ error: error.message }, 500);
      return json({ received: true, credits });
    }

    case 'INITIAL_PURCHASE':
    case 'RENEWAL': {
      const isPro =
        entitlementIds.includes(PRO_ENTITLEMENT) || productId.startsWith('pro_');
      const { error } = await supabase.rpc('set_pro_status', {
        user_id: appUserId,
        is_pro: isPro,
      });
      if (error) return json({ error: error.message }, 500);
      return json({ received: true, isPro });
    }

    case 'EXPIRATION': {
      const { error } = await supabase.rpc('set_pro_status', {
        user_id: appUserId,
        is_pro: false,
      });
      if (error) return json({ error: error.message }, 500);
      return json({ received: true, isPro: false });
    }

    default:
      return json({ received: true, ignored: type });
  }
});
