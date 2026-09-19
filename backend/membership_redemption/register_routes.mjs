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
    const { data: rows, error: reserveError } = await supabaseAdmin.rpc(
      'reserve_membership_code',
      { p_session_hash: sessionHash, p_code_hash: codeHash },
    );
    if (reserveError || !rows?.length) {
      const { data: completedRows } = await supabaseAdmin.rpc(
        'completed_membership_redemption',
        { p_session_hash: sessionHash, p_code_hash: codeHash },
      );
      if (completedRows?.length) {
        return res.json({
          ok: true,
          already_completed: true,
          access_ends_at: completedRows[0].access_ends_at,
          return_url: 'decoywalletapp://paymentreturn?redemption=success',
        });
      }
      return res.status(409).json({ error: 'This code is invalid or has already been redeemed.' });
    }

    const reservation = rows[0];
    let billingSyncComplete = false;
    if (reservation.billing_sync_status === 'pending') {
      try {
        await syncStripePromotion({
          userId: reservation.user_id,
          redemption: {
            redemption_id: reservation.reservation_id,
            access_started_at: reservation.access_started_at,
            access_ends_at: reservation.access_ends_at,
          },
        });
        billingSyncComplete = true;
      } catch (error) {
        return res.status(503).json({
          error: 'Your code is safely reserved, but billing protection could not be completed. No membership time was consumed. Please retry or contact Decoy support.',
        });
      }
    }

    const { data: finalizedRows, error: finalizeError } = await supabaseAdmin.rpc(
      'finalize_membership_code',
      {
        p_session_hash: sessionHash,
        p_code_hash: codeHash,
        p_billing_sync_complete: billingSyncComplete,
      },
    );
    if (finalizeError || !finalizedRows?.length) {
      return res.status(503).json({
        error: 'Your code is safely reserved, but access could not be finalized. Please retry or contact Decoy support.',
      });
    }
    const redemption = finalizedRows[0];

    return res.json({
      ok: true,
      access_ends_at: redemption.access_ends_at,
      return_url: 'decoywalletapp://paymentreturn?redemption=success',
    });
  });
}
