#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';

const paymentServicePath = process.env.PAYMENT_SERVICE_JSON;
if (!paymentServicePath) throw new Error('Missing PAYMENT_SERVICE_JSON');

const service = JSON.parse(fs.readFileSync(paymentServicePath, 'utf8'));
const env = Object.fromEntries(
  (service.spec?.template?.spec?.containers?.[0]?.env ?? [])
    .filter((entry) => typeof entry.value === 'string')
    .map((entry) => [entry.name, entry.value]),
);
const supabaseUrl = String(env.SUPABASE_URL ?? '').replace(/\/+$/, '');
const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;
if (!supabaseUrl || !serviceKey) throw new Error('Missing Supabase configuration');

const headers = {
  apikey: serviceKey,
  authorization: `Bearer ${serviceKey}`,
  'content-type': 'application/json',
};

async function jsonFetch(url, options = {}) {
  const response = await fetch(url, options);
  const text = await response.text();
  let body;
  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    body = { raw: text };
  }
  return { response, body };
}

async function deleteWhere(table, query) {
  await fetch(`${supabaseUrl}/rest/v1/${table}?${query}`, {
    method: 'DELETE',
    headers,
  });
}

async function runCase(kind) {
  const nonce = crypto.randomBytes(12).toString('hex');
  const email = `decoy-db-alert-${kind}-${nonce}@example.invalid`;
  const password = `${crypto.randomBytes(24).toString('base64url')}Aa1!`;
  const txidHmac = crypto.randomBytes(32).toString('hex');
  let userId;
  let alertId;

  try {
    const created = await jsonFetch(`${supabaseUrl}/auth/v1/admin/users`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ email, password, email_confirm: true }),
    });
    if (!created.response.ok || !created.body?.id) {
      throw new Error(`${kind} user creation failed`);
    }
    userId = created.body.id;

    const entitlement = {
      user_id: userId,
      entitlement: 'decoy_wallet',
      is_active: kind === 'paid',
      ...(kind === 'paid'
        ? { current_period_end: new Date(Date.now() + 86400000).toISOString() }
        : {
            promotional_access_until: new Date(
              Date.now() + 86400000,
            ).toISOString(),
          }),
    };
    const ent = await jsonFetch(`${supabaseUrl}/rest/v1/user_entitlements`, {
      method: 'POST',
      headers: { ...headers, prefer: 'return=minimal' },
      body: JSON.stringify(entitlement),
    });
    if (!ent.response.ok) throw new Error(`${kind} entitlement insert failed`);

    const wallet = await jsonFetch(
      `${supabaseUrl}/rest/v1/decoy_wallet?user_id=eq.${userId}`,
      {
        method: 'PATCH',
        headers: { ...headers, prefer: 'return=minimal' },
        body: JSON.stringify({ decoy_seed_armed: true }),
      },
    );
    if (!wallet.response.ok) {
      throw new Error(
        `${kind} wallet update failed (${wallet.response.status} ${wallet.body?.code ?? ''} ${wallet.body?.message ?? ''})`,
      );
    }

    const trigger = await jsonFetch(`${supabaseUrl}/rest/v1/decoy_triggers`, {
      method: 'POST',
      headers: { ...headers, prefer: 'return=minimal' },
      body: JSON.stringify({
        user_id: userId,
        trigger_type: 'SEED_DECOY',
        txid_hmac: txidHmac,
      }),
    });
    if (!trigger.response.ok) throw new Error(`${kind} trigger insert failed`);

    const alerts = await jsonFetch(
      `${supabaseUrl}/rest/v1/alert_logs?user_id=eq.${userId}&txid_hmac=eq.${txidHmac}&select=id`,
      { headers },
    );
    if (!alerts.response.ok || alerts.body?.length !== 1) {
      throw new Error(`${kind} alert count was not one`);
    }
    alertId = alerts.body[0].id;

    const queue = await jsonFetch(
      `${supabaseUrl}/rest/v1/sms_queue?alert_id=eq.${alertId}&select=alert_id`,
      { headers },
    );
    if (!queue.response.ok || queue.body?.length !== 1) {
      throw new Error(`${kind} queue count was not one`);
    }

    return { kind, alertCreated: true, queuedExactlyOnce: true };
  } finally {
    if (alertId) {
      await deleteWhere('sms_queue', `alert_id=eq.${alertId}`);
      await deleteWhere('alert_logs', `id=eq.${alertId}`);
    }
    if (userId) {
      await deleteWhere('decoy_triggers', `user_id=eq.${userId}`);
      await deleteWhere('decoy_wallet', `user_id=eq.${userId}`);
      await deleteWhere(
        'user_entitlements',
        `user_id=eq.${userId}&entitlement=eq.decoy_wallet`,
      );
      const cleanup = await fetch(`${supabaseUrl}/auth/v1/admin/users/${userId}`, {
        method: 'DELETE',
        headers,
      });
      if (!cleanup.ok) throw new Error(`${kind} user cleanup failed`);
    }
  }
}

const paid = await runCase('paid');
const promotional = await runCase('promotional');
process.stdout.write(`${JSON.stringify({ paid, promotional })}\n`);
