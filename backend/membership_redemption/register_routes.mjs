import {
  createOpaqueToken,
  hashSecret,
  isMembershipCodeFormatValid,
  normalizeMembershipCode,
} from './redemption_core.mjs';
import { renderRedemptionPage } from './redemption_page.mjs';

function bearerToken(req) {
  const value = req.headers.authorization ?? '';
  return value.startsWith('Bearer ') ? value.slice(7).trim() : '';
}

export function registerMembershipRedemptionRoutes({
  app,
  supabaseAdmin,
  publicRedeemUrl,
  apiBaseUrl,
  codePepper,
  sessionPepper,
  syncStripePromotion,
}) {
  app.post('/create-redemption-session', async (req, res) => {
    const jwt = bearerToken(req);
    const { data, error } = await supabaseAdmin.auth.getUser(jwt);
    if (error || !data?.user?.id) return res.status(401).json({ error: 'unauthorized' });

    const token = createOpaqueToken();
    const tokenHash = hashSecret(token, sessionPepper);
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();
    const returnTo = req.body?.return_to === 'manage' ? 'manage' : 'home';
    const { error: insertError } = await supabaseAdmin
      .from('promo_redemption_sessions')
      .insert({ token_hash: tokenHash, user_id: data.user.id, return_to: returnTo, expires_at: expiresAt });
    if (insertError) return res.status(500).json({ error: 'session_creation_failed' });

    return res.json({ url: `${publicRedeemUrl}?session=${encodeURIComponent(token)}` });
  });

  app.get('/redeem-membership', (req, res) => {
    const session = String(req.query.session ?? '');
    if (!session) return res.status(400).send('Missing redemption session.');
    res.type('html').send(renderRedemptionPage({ apiBaseUrl, sessionToken: session }));
  });

  app.post('/redeem-membership-code', async (req, res) => {
    const sessionToken = String(req.body?.session ?? '');
    const code = normalizeMembershipCode(req.body?.code);
    if (!sessionToken || !isMembershipCodeFormatValid(code)) {
      return res.status(400).json({ error: 'Invalid membership code.' });
    }

    const sessionHash = hashSecret(sessionToken, sessionPepper);
    const codeHash = hashSecret(code, codePepper);
    const { data: rows, error: redeemError } = await supabaseAdmin.rpc(
      'redeem_membership_code',
      { p_session_hash: sessionHash, p_code_hash: codeHash },
    );
    if (redeemError || !rows?.length) {
      return res.status(409).json({ error: 'This code is invalid or has already been redeemed.' });
    }

    const redemption = rows[0];
    if (redemption.billing_sync_status === 'pending') {
      try {
        await syncStripePromotion({ userId: redemption.user_id, redemption });
        await supabaseAdmin.from('promo_redemptions').update({ billing_sync_status: 'complete', billing_sync_error: null }).eq('id', redemption.redemption_id);
      } catch (error) {
        await supabaseAdmin.from('promo_redemptions').update({ billing_sync_status: 'error', billing_sync_error: String(error?.message ?? error).slice(0, 500) }).eq('id', redemption.redemption_id);
        return res.status(503).json({ error: 'Your code was accepted, but billing protection is still syncing. Please contact Decoy support before your next renewal.' });
      }
    }

    return res.json({
      ok: true,
      access_ends_at: redemption.access_ends_at,
      return_url: 'decoywalletapp://paymentreturn?redemption=success',
    });
  });
}
