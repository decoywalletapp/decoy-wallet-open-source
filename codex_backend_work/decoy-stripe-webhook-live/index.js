/* index.js
   Cloud Run Express service for:
   1) POST /create-checkout-session (Stripe)
   2) POST /stripe-webhook (Stripe → Supabase entitlements)
   3) POST /create-btcpay-invoice (BTCPay → returns invoice checkoutLink) optional
   4) POST /btcpay-webhook (BTCPay webhooks → Supabase entitlements)
   5) GET  /success and /cancel (Return-to-app pages)
   6) GET  /health
   7) POST /create-billing-portal-session (Stripe customer portal)
   8) POST /finalize-stripe-switch (deterministic provider flip after pending_starts_at)
   9) POST /finalize-btcpay-switch (deterministic provider flip after pending_starts_at)
   10) POST /repair-stripe-entitlement (repair entitlement from Stripe truth)

   Node 18+
*/

const express = require("express");
const Stripe = require("stripe");
const crypto = require("crypto");

const app = express();

/* ---------- env ---------- */
const {
  // Stripe
  STRIPE_SECRET_KEY,
  STRIPE_WEBHOOK_SECRET,

  // Supabase
  SUPABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY,

  // Stripe prices
  STRIPE_PRICE_ID,
  STRIPE_PRICE_ID_MONTHLY,

  // URLs
  PUBLIC_BASE_URL,
  STRIPE_SUCCESS_URL,
  STRIPE_CANCEL_URL,

  // App return
  APP_RETURN_URL,
  APP_DEEPLINK_BASE,

  // BTCPay optional
  BTCPAY_BASE_URL,
  BTCPAY_STORE_ID,
  BTCPAY_API_KEY,
  BTCPAY_WEBHOOK_SECRET,
} = process.env;

/* ---------- required checks ---------- */
if (!STRIPE_SECRET_KEY) throw new Error("Missing STRIPE_SECRET_KEY");
if (!STRIPE_WEBHOOK_SECRET) throw new Error("Missing STRIPE_WEBHOOK_SECRET");
if (!SUPABASE_URL) throw new Error("Missing SUPABASE_URL");
if (!SUPABASE_SERVICE_ROLE_KEY) throw new Error("Missing SUPABASE_SERVICE_ROLE_KEY");

const stripe = new Stripe(STRIPE_SECRET_KEY, { apiVersion: "2023-10-16" });

const BTCPAY_ENABLED = !!(
  BTCPAY_BASE_URL &&
  BTCPAY_STORE_ID &&
  BTCPAY_API_KEY &&
  BTCPAY_WEBHOOK_SECRET
);

if (!BTCPAY_ENABLED) {
  console.log("BTCPay is disabled because one or more BTCPAY env vars are missing");
}

/* ---------- helpers ---------- */
function pickPriceId() {
  return STRIPE_PRICE_ID_MONTHLY || STRIPE_PRICE_ID;
}

function appendQuery(url, params) {
  const u = new URL(url);
  Object.entries(params).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== "") {
      u.searchParams.set(k, String(v));
    }
  });
  return u.toString();
}

function getReturnDeepLink(sessionId) {
  const raw = (APP_RETURN_URL || APP_DEEPLINK_BASE || "").trim();
  if (!raw) return null;

  try {
    return appendQuery(raw, { session_id: sessionId });
  } catch {
    return raw;
  }
}

function addCheckoutSessionPlaceholder(url) {
  if (!url || typeof url !== "string") return url;
  if (url.includes("{CHECKOUT_SESSION_ID}")) return url;
  const separator = url.includes("?") ? "&" : "?";
  return `${url}${separator}session_id={CHECKOUT_SESSION_ID}`;
}

function isUuid(v) {
  return (
    typeof v === "string" &&
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v)
  );
}

function toUnixSecondsOrNull(v) {
  if (v === undefined || v === null || v === "") return null;

  const n =
    typeof v === "number"
      ? v
      : typeof v === "string"
      ? Number(v)
      : NaN;

  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.floor(n);
}

function toIsoFromUnixSeconds(sec) {
  const n = toUnixSecondsOrNull(sec);
  if (!n) return null;
  return new Date(n * 1000).toISOString();
}

function normalizeStripeStatusToActive(status) {
  if (!status) return null;
  const s = String(status).toLowerCase();

  if (s === "active") return true;
  if (s === "trialing") return true;
  if (s === "past_due") return true;
  if (s === "paused") return true;

  if (s === "canceled") return false;
  if (s === "unpaid") return false;
  if (s === "incomplete") return false;
  if (s === "incomplete_expired") return false;

  return null;
}

function addOneMonthIso(fromDate = new Date()) {
  const d = new Date(fromDate);
  d.setUTCMonth(d.getUTCMonth() + 1);
  return d.toISOString();
}

function isValidIsoDateString(s) {
  if (!s || typeof s !== "string") return false;
  const t = Date.parse(s);
  return Number.isFinite(t);
}

function nowMs() {
  return Date.now();
}

function isoToMs(iso) {
  const t = Date.parse(String(iso || ""));
  return Number.isFinite(t) ? t : null;
}

function deepClean(obj) {
  if (obj === null || obj === undefined) return obj;
  if (Array.isArray(obj)) {
    return obj
      .map(deepClean)
      .filter((v) => v !== undefined && v !== null && v !== "");
  }
  if (typeof obj === "object") {
    const out = {};
    for (const [k, v] of Object.entries(obj)) {
      const vv = deepClean(v);
      if (vv === undefined || vv === null || vv === "") continue;
      out[k] = vv;
    }
    return out;
  }
  return obj;
}

/* ---------- Supabase helpers (REST) ---------- */
async function supabaseInsertStripeEvent(event) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/stripe_events`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      Prefer: "resolution=merge-duplicates",
    },
    body: JSON.stringify({
      stripe_event_id: event.id,
      type: event.type,
      livemode: !!event.livemode,
      api_version: event.api_version || null,
      account: event.account || null,
      created: event.created || null,
      request_id: event.request?.id || null,
      idempotency_key: event.request?.idempotency_key || null,
      payload: event,
    }),
  });

  if (res.status === 409) return;

  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`stripe_events insert failed: ${res.status} ${txt}`);
  }
}

async function supabaseUpsertEntitlement(payload) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/user_entitlements`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      Prefer: "resolution=merge-duplicates",
    },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`user_entitlements upsert failed: ${res.status} ${txt}`);
  }
}

async function clearPendingProviderSwitch(userId) {
  await supabaseUpsertEntitlement({
    user_id: String(userId),
    entitlement: "decoy_wallet",
    updated_at: new Date().toISOString(),
    pending_provider: null,
    pending_provider_customer_id: null,
    pending_provider_subscription_id: null,
    pending_starts_at: null,
    switch_initiated_at: null,
    teardown_grace_until: null,
  });
}

async function supabaseGetEntitlementRow(userId, entitlement) {
  const url = new URL(`${SUPABASE_URL}/rest/v1/user_entitlements`);
  url.searchParams.set(
    "select",
    [
      "user_id",
      "entitlement",
      "is_active",
      "provider",
      "provider_customer_id",
      "provider_subscription_id",
      "provider_status",
      "current_period_end",
      "cancel_at_period_end",
      "updated_at",
      "pending_provider",
      "pending_provider_subscription_id",
      "pending_provider_customer_id",
      "pending_starts_at",
      "switch_initiated_at",
      "teardown_grace_until",
      "activation_notified_at",
    ].join(",")
  );
  url.searchParams.set("user_id", `eq.${userId}`);
  url.searchParams.set("entitlement", `eq.${entitlement}`);
  url.searchParams.set("limit", "1");

  const res = await fetch(url.toString(), {
    method: "GET",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
    },
  });

  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`user_entitlements select failed: ${res.status} ${txt}`);
  }

  const rows = await res.json().catch(() => []);
  return Array.isArray(rows) && rows.length ? rows[0] : null;
}

async function supabaseFindUserIdByProviderIds({ providerCustomerId, providerSubscriptionId }) {
  const url = new URL(`${SUPABASE_URL}/rest/v1/user_entitlements`);
  url.searchParams.set("select", "user_id,provider_customer_id,provider_subscription_id");
  url.searchParams.set("entitlement", "eq.decoy_wallet");
  url.searchParams.set("limit", "1");

  if (providerSubscriptionId) {
    url.searchParams.set("provider_subscription_id", `eq.${providerSubscriptionId}`);
  } else if (providerCustomerId) {
    url.searchParams.set("provider_customer_id", `eq.${providerCustomerId}`);
  } else {
    return null;
  }

  const res = await fetch(url.toString(), {
    method: "GET",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
    },
  });

  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`user_entitlements lookup failed: ${res.status} ${txt}`);
  }

  const rows = await res.json().catch(() => []);
  return Array.isArray(rows) && rows.length ? rows[0]?.user_id || null : null;
}

async function supabaseAuthUserExists(userId) {
  const url = new URL(`${SUPABASE_URL}/auth/v1/admin/users/${userId}`);

  const res = await fetch(url.toString(), {
    method: "GET",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
    },
  });

  if (res.status === 404) return false;

  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`auth user lookup failed: ${res.status} ${txt}`);
  }

  return true;
}

function getBearerToken(req) {
  const raw = req.get("authorization") || req.get("Authorization") || "";
  const match = raw.match(/^Bearer\s+(.+)$/i);
  return match ? match[1].trim() : "";
}

async function requireSupabaseUser(req) {
  const token = getBearerToken(req);
  if (!token) {
    const err = new Error("Missing bearer token");
    err.statusCode = 401;
    throw err;
  }

  const res = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    method: "GET",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  });

  if (!res.ok) {
    const err = new Error("Invalid bearer token");
    err.statusCode = 401;
    throw err;
  }

  const user = await res.json().catch(() => null);
  const id = String(user?.id || "");
  if (!isUuid(id)) {
    const err = new Error("Authenticated user id missing or invalid");
    err.statusCode = 401;
    throw err;
  }

  return { id, email: user?.email || null };
}

function requireRequestUserMatches(req, authedUser) {
  const bodyUserId = String(req.body?.user_id || "").trim();
  if (bodyUserId && bodyUserId !== authedUser.id) {
    const err = new Error("Authenticated user does not match requested user");
    err.statusCode = 403;
    throw err;
  }
  return authedUser.id;
}

function responseStatusFromError(err) {
  const status = Number(err?.statusCode || 500);
  return status >= 400 && status < 600 ? status : 500;
}

async function supabaseInsertBtcpayWebhookEvent(invoiceId, eventType) {
  const url = new URL(`${SUPABASE_URL}/rest/v1/btcpay_webhook_events`);
  url.searchParams.set("on_conflict", "invoice_id,event_type");

  const res = await fetch(url.toString(), {
    method: "POST",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      Prefer: "resolution=ignore-duplicates,return=representation",
    },
    body: JSON.stringify({
      invoice_id: String(invoiceId),
      event_type: String(eventType),
    }),
  });

  const body = await res.text().catch(() => "");

  if (!res.ok) {
    throw new Error(`btcpay_webhook_events insert failed: ${res.status} ${body}`);
  }

  let parsed = [];
  try {
    parsed = body ? JSON.parse(body) : [];
  } catch {
    parsed = [];
  }

  return Array.isArray(parsed) && parsed.length > 0;
}

/* ---------- instant push helpers ---------- */
async function supabaseGetUserSettings(userId) {
  const url = new URL(`${SUPABASE_URL}/rest/v1/user_settings`);
  url.searchParams.set("select", "push_enabled");
  url.searchParams.set("user_id", `eq.${userId}`);
  url.searchParams.set("limit", "1");

  const res = await fetch(url.toString(), {
    method: "GET",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
    },
  });

  if (!res.ok) return null;

  const rows = await res.json().catch(() => []);
  return Array.isArray(rows) && rows.length ? rows[0] : null;
}

async function supabaseGetUserDevices(userId) {
  const url = new URL(`${SUPABASE_URL}/rest/v1/user_devices`);
  url.searchParams.set("select", "fcm_token");
  url.searchParams.set("user_id", `eq.${userId}`);
  url.searchParams.set("fcm_token", "not.is.null");

  const res = await fetch(url.toString(), {
    method: "GET",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
    },
  });

  if (!res.ok) return [];

  const rows = await res.json().catch(() => []);
  return Array.isArray(rows) ? rows : [];
}

async function supabaseMarkActivationNotified(userId) {
  const url = new URL(`${SUPABASE_URL}/rest/v1/user_entitlements`);
  url.searchParams.set("user_id", `eq.${userId}`);
  url.searchParams.set("entitlement", "eq.decoy_wallet");

  const res = await fetch(url.toString(), {
    method: "PATCH",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      Prefer: "return=minimal",
    },
    body: JSON.stringify({ activation_notified_at: new Date().toISOString() }),
  });

  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    console.log("failed to set activation_notified_at", res.status, txt);
  }
}

async function sendPushViaSupabase({ fcmToken, title, body, data }) {
  const resp = await fetch(`${SUPABASE_URL}/functions/v1/sendPush`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ fcmToken, title, body, data }),
  });

  if (!resp.ok) {
    const txt = await resp.text().catch(() => "");
    console.log("sendPushViaSupabase failed", resp.status, txt);
  }

  return resp.ok;
}

async function notifyActivationIfNeeded(userId, { provider, invoiceId = null } = {}) {
  try {
    const existing = await supabaseGetEntitlementRow(String(userId), "decoy_wallet");
    if (existing?.activation_notified_at) {
      return { attempted: 0, sent: 0, skipped: "already_notified" };
    }

    const settings = await supabaseGetUserSettings(String(userId));
    if (!settings?.push_enabled) {
      return { attempted: 0, sent: 0, skipped: "push_disabled" };
    }

    const devices = await supabaseGetUserDevices(String(userId));
    if (!devices.length) {
      return { attempted: 0, sent: 0, skipped: "no_devices" };
    }

    let attempted = 0;
    let sent = 0;

    for (const d of devices) {
      const token = d?.fcm_token ? String(d.fcm_token) : null;
      if (!token) continue;

      attempted += 1;
      const ok = await sendPushViaSupabase({
        fcmToken: token,
        title: "DecoyWallet",
        body: "Payment confirmed. Your account access is now active.",
        data: {
          type: "entitlement_activated",
          user_id: String(userId),
          provider: String(provider || ""),
          invoice_id: invoiceId ? String(invoiceId) : "",
        },
      });

      if (ok) sent += 1;
    }

    if (sent > 0) await supabaseMarkActivationNotified(String(userId));

    return { attempted, sent, skipped: null };
  } catch (e) {
    console.log("notifyActivationIfNeeded failed", {
      userId: String(userId),
      provider: provider || null,
      message: e?.message || String(e),
    });
    return { attempted: 0, sent: 0, skipped: "error" };
  }
}

async function notifyPaymentConfirmed(userId, { provider, invoiceId = null, body }) {
  try {
    const settings = await supabaseGetUserSettings(String(userId));
    if (!settings?.push_enabled) {
      return { attempted: 0, sent: 0, skipped: "push_disabled" };
    }

    const devices = await supabaseGetUserDevices(String(userId));
    if (!devices.length) {
      return { attempted: 0, sent: 0, skipped: "no_devices" };
    }

    let attempted = 0;
    let sent = 0;

    for (const d of devices) {
      const token = d?.fcm_token ? String(d.fcm_token) : null;
      if (!token) continue;

      attempted += 1;
      const ok = await sendPushViaSupabase({
        fcmToken: token,
        title: "DecoyWallet",
        body,
        data: {
          type: "payment_confirmed",
          user_id: String(userId),
          provider: String(provider || ""),
          invoice_id: invoiceId ? String(invoiceId) : "",
        },
      });

      if (ok) sent += 1;
    }

    return { attempted, sent, skipped: null };
  } catch (e) {
    console.log("notifyPaymentConfirmed failed", {
      userId: String(userId),
      provider: provider || null,
      message: e?.message || String(e),
    });
    return { attempted: 0, sent: 0, skipped: "error" };
  }
}

/* ---------- Stripe helpers ---------- */
function extractUserIdFromStripeEvent(event) {
  const obj = event.data?.object;
  return obj?.metadata?.user_id || obj?.client_reference_id || null;
}

function computeIsActiveFromStripeEvent(event) {
  const obj = event.data?.object;

  if (event.type === "checkout.session.completed") return true;
  if (event.type === "invoice.paid") return true;

  if (event.type === "invoice.payment_failed") return null;

  if (
    (event.type === "customer.subscription.updated" ||
      event.type === "customer.subscription.created") &&
    obj
  ) {
    return normalizeStripeStatusToActive(obj.status);
  }

  if (event.type === "customer.subscription.deleted") return false;

  return null;
}

function extractStripeProviderFields(event) {
  const obj = event.data?.object;

  const out = {
    provider: "stripe",
    provider_customer_id: null,
    provider_subscription_id: null,
    provider_status: null,
    current_period_end: null,
    cancel_at_period_end: null,

    cancel_at: null,
    canceled_at: null,
    ended_at: null,
  };

  if (!obj) return out;

  if (event.type === "checkout.session.completed") {
    out.provider_customer_id = obj.customer || null;
    out.provider_subscription_id = obj.subscription || null;
    return out;
  }

  if (
    event.type === "customer.subscription.updated" ||
    event.type === "customer.subscription.created" ||
    event.type === "customer.subscription.deleted"
  ) {
    out.provider_customer_id = obj.customer || null;
    out.provider_subscription_id = obj.id || null;
    out.provider_status = obj.status || null;

    out.current_period_end = toIsoFromUnixSeconds(obj.current_period_end);

    out.cancel_at_period_end =
      typeof obj.cancel_at_period_end === "boolean" ? obj.cancel_at_period_end : null;

    out.cancel_at = toIsoFromUnixSeconds(obj.cancel_at);
    out.canceled_at = toIsoFromUnixSeconds(obj.canceled_at);
    out.ended_at = toIsoFromUnixSeconds(obj.ended_at);

    return out;
  }

  if (event.type === "invoice.paid" || event.type === "invoice.payment_failed") {
    out.provider_customer_id = obj.customer || null;
    out.provider_subscription_id = obj.subscription || null;
    return out;
  }

  return out;
}

async function stripeFetchSubscriptionPeriodEndIso(subscriptionId) {
  if (!subscriptionId || typeof subscriptionId !== "string") return null;
  try {
    const sub = await stripe.subscriptions.retrieve(subscriptionId);
    return toIsoFromUnixSeconds(sub?.current_period_end);
  } catch (e) {
    console.log("stripeFetchSubscriptionPeriodEndIso failed", {
      subscriptionId,
      message: e?.message || "unknown",
    });
    return null;
  }
}

async function stripeFetchSubscription(subscriptionId) {
  if (!subscriptionId || typeof subscriptionId !== "string") return null;
  try {
    return await stripe.subscriptions.retrieve(subscriptionId);
  } catch (e) {
    console.log("stripeFetchSubscription failed", {
      subscriptionId,
      message: e?.message || "unknown",
    });
    return null;
  }
}

async function stripeFetchCheckoutSession(sessionId) {
  if (!sessionId || typeof sessionId !== "string") return null;
  try {
    return await stripe.checkout.sessions.retrieve(sessionId);
  } catch (e) {
    console.log("stripeFetchCheckoutSession failed", {
      sessionId,
      message: e?.message || "unknown",
    });
    return null;
  }
}

function isBtpayActive(entRow) {
  return (
    entRow &&
    String(entRow.entitlement || "") === "decoy_wallet" &&
    entRow.is_active === true &&
    String(entRow.provider || "") === "btcpay" &&
    isValidIsoDateString(entRow.current_period_end) &&
    isoToMs(entRow.current_period_end) > nowMs()
  );
}

function isPendingStripeSwitch(entRow) {
  if (!entRow) return false;
  if (String(entRow.pending_provider || "") !== "stripe") return false;
  if (!isValidIsoDateString(entRow.pending_starts_at)) return false;
  return true;
}

function switchStartMs(entRow) {
  return isoToMs(entRow?.pending_starts_at || null);
}

function isStripeActive(entRow) {
  return (
    entRow &&
    String(entRow.entitlement || "") === "decoy_wallet" &&
    entRow.is_active === true &&
    String(entRow.provider || "") === "stripe" &&
    isValidIsoDateString(entRow.current_period_end) &&
    isoToMs(entRow.current_period_end) > nowMs()
  );
}

function isPendingBtcpaySwitch(entRow) {
  if (!entRow) return false;
  if (String(entRow.pending_provider || "") !== "btcpay") return false;
  if (!isValidIsoDateString(entRow.pending_starts_at)) return false;
  return true;
}

/* ---------- routes ---------- */

// Stripe webhook (raw body required)
app.post("/stripe-webhook", express.raw({ type: "application/json" }), async (req, res) => {
  let event;

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      req.headers["stripe-signature"],
      STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    return res.status(400).send(`Webhook error: ${err?.message || "bad signature"}`);
  }

  try {
    await supabaseInsertStripeEvent(event);

    const stripeFields = extractStripeProviderFields(event);

    let userId = extractUserIdFromStripeEvent(event);

    if (
      !userId &&
      (event.type === "customer.subscription.updated" ||
        event.type === "customer.subscription.created" ||
        event.type === "customer.subscription.deleted")
    ) {
      userId = await supabaseFindUserIdByProviderIds({
        providerCustomerId: stripeFields.provider_customer_id,
        providerSubscriptionId: stripeFields.provider_subscription_id,
      });
    }

    if (!userId) {
      return res.status(200).json({ received: true, skipped: "no_user_mapping" });
    }

    if (!isUuid(String(userId))) {
      return res.status(200).json({ received: true, skipped: "user_id_not_uuid" });
    }

    const existing = await supabaseGetEntitlementRow(String(userId), "decoy_wallet");
    const btcpayActive = isBtpayActive(existing);
    const pendingSwitch = isPendingStripeSwitch(existing);
    const startAtMs = switchStartMs(existing);
    const isActive = computeIsActiveFromStripeEvent(event);

    if (btcpayActive && !pendingSwitch) {
      const hasStripeSubscription = !!stripeFields.provider_subscription_id;
      const confirmedStripeSwitch =
        hasStripeSubscription &&
        (event.type === "checkout.session.completed" ||
          ((event.type === "customer.subscription.created" ||
            event.type === "customer.subscription.updated") &&
            isActive === true));

      if (confirmedStripeSwitch) {
        const pendingPayload = {
          user_id: String(userId),
          entitlement: "decoy_wallet",
          updated_at: new Date().toISOString(),
          pending_provider: "stripe",
          pending_starts_at: existing.current_period_end,
          switch_initiated_at: new Date().toISOString(),
          teardown_grace_until: existing.current_period_end,
        };

        if (stripeFields.provider_customer_id) {
          pendingPayload.pending_provider_customer_id = String(stripeFields.provider_customer_id);
        }
        if (stripeFields.provider_subscription_id) {
          pendingPayload.pending_provider_subscription_id = String(
            stripeFields.provider_subscription_id
          );
        }

        await supabaseUpsertEntitlement(pendingPayload);

        return res.status(200).json({
          received: true,
          ok: true,
          mode: "pending_scheduled_after_confirmed_stripe",
          type: event.type,
          pending_starts_at: existing.current_period_end || null,
        });
      }

      return res.status(200).json({
        received: true,
        ignored: true,
        reason: "btcpay_active_no_switch",
        type: event.type,
      });
    }

    if (btcpayActive && pendingSwitch && startAtMs && startAtMs > nowMs()) {
      const pendingPayload = {
        user_id: String(userId),
        entitlement: "decoy_wallet",
        updated_at: new Date().toISOString(),
        pending_provider: "stripe",
      };

      if (stripeFields.provider_customer_id) {
        pendingPayload.pending_provider_customer_id = String(stripeFields.provider_customer_id);
      }
      if (stripeFields.provider_subscription_id) {
        pendingPayload.pending_provider_subscription_id = String(
          stripeFields.provider_subscription_id
        );
      }

      await supabaseUpsertEntitlement(pendingPayload);

      return res.status(200).json({
        received: true,
        ok: true,
        mode: "pending_only",
        type: event.type,
        pending_starts_at: existing?.pending_starts_at || null,
      });
    }

    let currentPeriodEndIso = stripeFields.current_period_end;

    const canFetchFromStripe =
      (event.type === "customer.subscription.updated" ||
        event.type === "customer.subscription.created" ||
        event.type === "customer.subscription.deleted") &&
      !currentPeriodEndIso &&
      stripeFields.provider_subscription_id;

    if (canFetchFromStripe) {
      currentPeriodEndIso = await stripeFetchSubscriptionPeriodEndIso(
        stripeFields.provider_subscription_id
      );
    }

    const payload = {
      user_id: String(userId),
      entitlement: "decoy_wallet",
      updated_at: new Date().toISOString(),

      provider: "stripe",
      provider_customer_id: stripeFields.provider_customer_id,
      provider_subscription_id: stripeFields.provider_subscription_id,
      provider_status: stripeFields.provider_status,
    };

    if (currentPeriodEndIso !== null) {
      payload.current_period_end = currentPeriodEndIso;
    }

    if (typeof stripeFields.cancel_at_period_end === "boolean") {
      payload.cancel_at_period_end = stripeFields.cancel_at_period_end;
    }

    if (isActive !== null) {
      payload.is_active = !!isActive;
    }

    if (pendingSwitch && startAtMs && startAtMs <= nowMs()) {
      payload.pending_provider = null;
      payload.pending_provider_customer_id = null;
      payload.pending_provider_subscription_id = null;
      payload.pending_starts_at = null;
      payload.switch_initiated_at = null;
      payload.teardown_grace_until = null;
    }

    await supabaseUpsertEntitlement(payload);

    if (isActive === true) {
      const push = await notifyActivationIfNeeded(String(userId), { provider: "stripe" });
      console.log("stripe activation push result", {
        userId: String(userId),
        type: event.type,
        push,
      });
    }

    return res.json({ received: true, ok: true, mode: "main_write", type: event.type });
  } catch (err) {
    return res.status(500).send(`Webhook failure: ${err?.message || "server error"}`);
  }
});

// BTCPay webhook (raw body required for signature validation)
app.post("/btcpay-webhook", express.raw({ type: "application/json" }), async (req, res) => {
  const runId = crypto.randomUUID();

  if (!BTCPAY_ENABLED) {
    console.log("btcpay-webhook disabled", { runId });
    return res.status(501).json({ ok: false, error: "BTCPay disabled", runId });
  }

  try {
    console.log("btcpay-webhook hit", {
      runId,
      hasBody: !!req.body,
      bodyIsBuffer: Buffer.isBuffer(req.body),
      contentType: req.get("content-type") || null,
    });

    const sigHeaderName = "BTCPAY-SIG";
    const sigHashAlg = "sha256";

    const headerVal = req.get(sigHeaderName) || "";
    if (!headerVal) {
      console.log("btcpay-webhook missing signature header", { runId });
      return res.status(400).send(`Missing ${sigHeaderName}`);
    }

    const rawBody = req.body;
    if (!rawBody || !Buffer.isBuffer(rawBody)) {
      console.log("btcpay-webhook request body empty or not buffer", {
        runId,
        bodyType: typeof rawBody,
      });
      return res.status(500).send("Request body empty");
    }

    const hmac = crypto.createHmac(sigHashAlg, BTCPAY_WEBHOOK_SECRET);
    const digestStr = `${sigHashAlg}=${hmac.update(rawBody).digest("hex")}`;

    const digest = Buffer.from(digestStr, "utf8");
    const checksum = Buffer.from(headerVal, "utf8");

    if (checksum.length !== digest.length || !crypto.timingSafeEqual(digest, checksum)) {
      console.log("btcpay-webhook invalid signature", {
        runId,
        headerLength: checksum.length,
        digestLength: digest.length,
      });
      return res.status(400).send("Invalid signature");
    }

    const payload = JSON.parse(rawBody.toString("utf8"));

    const eventType = String(payload?.type || "");
    const invoiceId = String(payload?.invoiceId || payload?.invoiceID || "");

    console.log("btcpay-webhook parsed payload", {
      runId,
      eventType,
      invoiceId,
    });

    const isReceived = eventType === "InvoiceReceivedPayment";
    const isProcessing = eventType === "InvoiceIsProcessing";
    const isSettled = eventType === "InvoiceSettled";

    if (!isReceived && !isProcessing && !isSettled) {
      console.log("btcpay-webhook ignored event", {
        runId,
        eventType,
        invoiceId,
      });
      return res.status(200).json({ ok: true, ignored: true, type: eventType, runId });
    }

    if (!invoiceId) {
      console.log("btcpay-webhook missing invoice id", { runId, eventType });
      return res.status(400).send("Missing invoiceId");
    }

    if (invoiceId.startsWith("__test__") && invoiceId.endsWith("__test__")) {
      console.log("btcpay-webhook accepted btcpay test event", {
        runId,
        eventType,
        invoiceId,
      });
      return res.status(200).json({
        ok: true,
        test: true,
        type: eventType,
        invoiceId,
        runId,
      });
    }

    const invoiceUrl = `${BTCPAY_BASE_URL}/api/v1/stores/${BTCPAY_STORE_ID}/invoices/${invoiceId}`;

    console.log("btcpay-webhook fetching invoice from btcpay", {
      runId,
      invoiceUrl,
      storeId: BTCPAY_STORE_ID,
    });

    const invRes = await fetch(invoiceUrl, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        Authorization: `token ${BTCPAY_API_KEY}`,
      },
    });

    const invJson = await invRes.json().catch(() => null);

    if (!invRes.ok) {
      console.log("btcpay-webhook invoice fetch failed", {
        runId,
        status: invRes.status,
        invoiceId,
        btcpayResponse: invJson,
      });
      return res.status(502).json({
        error: "Failed to fetch invoice",
        details: invJson,
        runId,
      });
    }

    const userId =
      invJson?.metadata?.user_id ||
      invJson?.metadata?.userId ||
      invJson?.metadata?.userid ||
      null;

    console.log("btcpay-webhook invoice fetched", {
      runId,
      invoiceId,
      userId,
      invoiceStatus: invJson?.status || null,
      metadataKeys: invJson?.metadata ? Object.keys(invJson.metadata) : [],
    });

    if (!userId) {
      console.log("btcpay-webhook missing user metadata", {
        runId,
        invoiceId,
      });
      return res.status(200).json({
        ok: true,
        type: eventType,
        invoiceId,
        userIdFound: false,
        runId,
      });
    }

    if (!isUuid(String(userId))) {
      console.log("btcpay-webhook user id not uuid", {
        runId,
        invoiceId,
        userId,
      });
      return res.status(200).json({
        ok: true,
        type: eventType,
        invoiceId,
        userIdFound: true,
        skipped: "user_id_not_uuid",
        runId,
      });
    }

    const authUserExists = await supabaseAuthUserExists(String(userId));

    if (!authUserExists) {
      console.log("btcpay-webhook ignored because user not in auth.users", {
        runId,
        invoiceId,
        userId,
      });
      return res.status(200).json({
        ok: true,
        ignored: true,
        reason: "user_not_in_auth_users",
        user_id: String(userId),
        invoiceId,
        type: eventType,
        runId,
      });
    }

    let existing = null;
    try {
      existing = await supabaseGetEntitlementRow(String(userId), "decoy_wallet");
      console.log("btcpay-webhook existing entitlement lookup", {
        runId,
        userId,
        existing,
      });
    } catch (e) {
      console.log("btcpay-webhook entitlement lookup failed", {
        runId,
        userId,
        message: e?.message || String(e),
        stack: e?.stack || null,
      });
      throw e;
    }

    const stripeActive = isStripeActive(existing);
    const activeBtcpay = isBtpayActive(existing);
    const pendingBtcpaySwitch = isPendingBtcpaySwitch(existing);
    const pendingStartMs = pendingBtcpaySwitch ? isoToMs(existing.pending_starts_at) : null;

    console.log("btcpay-webhook state analysis", {
      runId,
      userId,
      invoiceId,
      eventType,
      stripeActive,
      activeBtcpay,
      pendingBtcpaySwitch,
      pendingStartMs,
      nowMs: nowMs(),
    });

    if (stripeActive && pendingBtcpaySwitch && pendingStartMs && pendingStartMs > nowMs()) {
      if (!isSettled) {
        console.log("btcpay-webhook pending btcpay switch waiting for settlement", {
          runId,
          userId: String(userId),
          invoiceId,
          eventType,
          pending_starts_at: existing.pending_starts_at,
        });

        return res.status(200).json({
          ok: true,
          ignored: true,
          reason: "pending_btcpay_waiting_for_settlement",
          type: eventType,
          invoiceId,
          pending_starts_at: existing.pending_starts_at,
          runId,
        });
      }

      const settledEventInserted = await supabaseInsertBtcpayWebhookEvent(
        invoiceId,
        "InvoiceSettled"
      );

      if (!settledEventInserted) {
        console.log("btcpay-webhook duplicate pending settled delivery ignored", {
          runId,
          invoiceId,
          eventType,
        });

        return res.status(200).json({
          ok: true,
          duplicateIgnored: true,
          mode: "pending_stacked",
          type: eventType,
          invoiceId,
          runId,
        });
      }

      const stackedEndMs = isoToMs(existing.teardown_grace_until);
      const stackBaseMs =
        stackedEndMs && stackedEndMs > pendingStartMs ? stackedEndMs : pendingStartMs;
      const stackedPaidThrough = addOneMonthIso(new Date(stackBaseMs));

      const pendingPayload = {
        user_id: String(userId),
        entitlement: "decoy_wallet",
        updated_at: new Date().toISOString(),
        pending_provider: "btcpay",
        pending_provider_customer_id: null,
        pending_provider_subscription_id: invoiceId,
        teardown_grace_until: stackedPaidThrough,
      };

      console.log("btcpay-webhook stacking pending btcpay switch payment", {
        runId,
        pendingPayload,
        extendedFrom: new Date(stackBaseMs).toISOString(),
      });

      await supabaseUpsertEntitlement(pendingPayload);

      const push = await notifyPaymentConfirmed(String(userId), {
        provider: "btcpay",
        invoiceId,
        body: "Bitcoin payment confirmed. Your Bitcoin access time has been added.",
      });

      console.log("btcpay-webhook pending btcpay payment push result", {
        runId,
        userId: String(userId),
        invoiceId,
        push,
      });

      return res.status(200).json({
        ok: true,
        mode: "pending_stacked",
        type: eventType,
        invoiceId,
        pending_starts_at: existing.pending_starts_at,
        pending_paid_through: stackedPaidThrough,
        push,
        runId,
      });
    }

    if (stripeActive && !pendingBtcpaySwitch) {
      console.log("btcpay-webhook ignored because stripe active and no pending btcpay switch", {
        runId,
        userId,
        invoiceId,
      });
      return res.status(200).json({
        ok: true,
        ignored: true,
        reason: "stripe_active_no_pending_btcpay_switch",
        type: eventType,
        invoiceId,
        userIdFound: true,
        runId,
      });
    }

    if ((isReceived || isProcessing) && activeBtcpay) {
      console.log("btcpay-webhook active btcpay renewal waiting for settlement", {
        runId,
        userId,
        invoiceId,
        eventType,
      });
      return res.status(200).json({
        ok: true,
        ignored: true,
        reason: "active_btcpay_renewal_waiting_for_settlement",
        type: eventType,
        invoiceId,
        userIdFound: true,
        runId,
      });
    }

    if (isReceived || isProcessing) {
      const provisionalStatus = isProcessing ? "processing" : "received";

      if (!existing) {
        const provisionalInsert = {
          user_id: String(userId),
          entitlement: "decoy_wallet",
          provider: "btcpay",
          provider_customer_id: null,
          provider_subscription_id: invoiceId,
          provider_status: provisionalStatus,
          is_active: false,
          cancel_at_period_end: false,
          updated_at: new Date().toISOString(),
        };

        console.log("btcpay-webhook provisional insert", {
          runId,
          provisionalInsert,
        });

        await supabaseUpsertEntitlement(provisionalInsert);
      } else {
        const provisionalUpdate = {
          user_id: String(userId),
          entitlement: "decoy_wallet",
          updated_at: new Date().toISOString(),
          provider: "btcpay",
          provider_customer_id: null,
          provider_subscription_id: invoiceId,
          provider_status: provisionalStatus,
          is_active: false,
          cancel_at_period_end: false,
        };

        console.log("btcpay-webhook provisional update", {
          runId,
          provisionalUpdate,
        });

        await supabaseUpsertEntitlement(provisionalUpdate);
      }

      return res.status(200).json({
        ok: true,
        provisional: true,
        type: eventType,
        invoiceId,
        provider_status: provisionalStatus,
        is_active: false,
        runId,
      });
    }

    const settledEventInserted = await supabaseInsertBtcpayWebhookEvent(
      invoiceId,
      "InvoiceSettled"
    );

    if (!settledEventInserted) {
      console.log("btcpay-webhook duplicate settled delivery ignored", {
        runId,
        invoiceId,
        eventType,
      });

      return res.status(200).json({
        ok: true,
        duplicateIgnored: true,
        type: eventType,
        invoiceId,
        runId,
      });
    }

    let baseDate = new Date();
    try {
      const existingEnd = existing?.current_period_end || null;
      if (isValidIsoDateString(existingEnd)) {
        const existingEndDate = new Date(existingEnd);
        if (existingEndDate.getTime() > Date.now()) {
          baseDate = existingEndDate;
        }
      }
    } catch (e) {
      console.log("btcpay-webhook baseDate fallback to now", {
        runId,
        message: e?.message || String(e),
      });
    }

    const providerStatus = "settled";
    const isActive = true;
    const currentPeriodEnd = addOneMonthIso(baseDate);

    const entitlementPayload = {
      user_id: String(userId),
      entitlement: "decoy_wallet",
      is_active: isActive,
      updated_at: new Date().toISOString(),

      provider: "btcpay",
      provider_customer_id: null,
      provider_subscription_id: invoiceId,
      provider_status: providerStatus,

      current_period_end: currentPeriodEnd,
      cancel_at_period_end: false,

      pending_provider: null,
      pending_provider_customer_id: null,
      pending_provider_subscription_id: null,
      pending_starts_at: null,
      switch_initiated_at: null,
      teardown_grace_until: null,
    };

    console.log("btcpay-webhook settled upsert payload", {
      runId,
      entitlementPayload,
      extendedFrom: baseDate.toISOString(),
    });

    await supabaseUpsertEntitlement(entitlementPayload);

    try {
      console.log("btcpay-webhook settled, attempting instant push", {
        runId,
        userId: String(userId),
        invoiceId: String(invoiceId),
      });

      const settings = await supabaseGetUserSettings(String(userId));
      if (settings?.push_enabled) {
        const devices = await supabaseGetUserDevices(String(userId));

        let anyOk = false;
        for (const d of devices) {
          const token = d?.fcm_token ? String(d.fcm_token) : null;
          if (!token) continue;

          const ok = await sendPushViaSupabase({
            fcmToken: token,
            title: "DecoyWallet",
            body: "Payment confirmed. Your Bitcoin plan is now active.",
            data: {
              type: "entitlement_activated",
              user_id: String(userId),
              invoice_id: String(invoiceId),
            },
          });

          if (ok) anyOk = true;
        }

        if (anyOk) {
          await supabaseMarkActivationNotified(String(userId));
          console.log("btcpay-webhook instant push sent and activation_notified_at set", {
            runId,
            userId: String(userId),
          });
        } else {
          console.log("btcpay-webhook instant push attempted but none succeeded", {
            runId,
            userId: String(userId),
          });
        }
      } else {
        console.log("btcpay-webhook push disabled for user", {
          runId,
          userId: String(userId),
        });
      }
    } catch (e) {
      console.log("btcpay-webhook instant activation push failed", {
        runId,
        message: e?.message || String(e),
        stack: e?.stack || null,
      });
    }

    return res.status(200).json({
      ok: true,
      type: eventType,
      invoiceId,
      userIdFound: true,
      provider_status: providerStatus,
      is_active: isActive,
      current_period_end: currentPeriodEnd,
      extended_from: baseDate.toISOString(),
      runId,
    });
  } catch (err) {
    console.log("btcpay-webhook fatal error", {
      message: err?.message || "server error",
      stack: err?.stack || null,
      name: err?.name || null,
    });
    return res.status(500).json({ error: err?.message || "server error" });
  }
});

// JSON for normal routes
app.use(express.json());

app.get("/health", (_, res) => res.send("ok"));

/* ---------- REPAIR STRIPE ENTITLEMENT ---------- */
app.post("/repair-stripe-entitlement", async (req, res) => {
  try {
    const authedUser = await requireSupabaseUser(req);
    const user_id = requireRequestUserMatches(req, authedUser);

    if (!isUuid(user_id)) {
      return res.status(400).json({ error: "Missing or invalid user_id (must be UUID)" });
    }

    const row = await supabaseGetEntitlementRow(user_id, "decoy_wallet");
    if (!row) {
      return res.status(404).json({ error: "Entitlement row not found" });
    }

    if (String(row.provider || "") !== "stripe") {
      return res.status(200).json({
        ok: true,
        skipped: true,
        reason: "provider_not_stripe",
      });
    }

    const subId = row.provider_subscription_id || null;
    if (!subId || typeof subId !== "string") {
      return res.status(200).json({
        ok: true,
        skipped: true,
        reason: "missing_provider_subscription_id",
      });
    }

    const sub = await stripeFetchSubscription(subId);
    if (!sub) {
      return res.status(502).json({
        error: "Could not retrieve Stripe subscription from Stripe API",
      });
    }

    const repairedStatus = sub.status || null;
    const repairedPeriodEnd = toIsoFromUnixSeconds(sub.current_period_end);
    const repairedCancelAtPeriodEnd =
      typeof sub.cancel_at_period_end === "boolean" ? sub.cancel_at_period_end : null;

    let repairedIsActive = normalizeStripeStatusToActive(repairedStatus);

    if (
      repairedIsActive === false &&
      repairedPeriodEnd &&
      isoToMs(repairedPeriodEnd) &&
      isoToMs(repairedPeriodEnd) > nowMs()
    ) {
      repairedIsActive = true;
    }

    const updatePayload = {
      user_id,
      entitlement: "decoy_wallet",
      updated_at: new Date().toISOString(),

      provider: "stripe",
      provider_status: repairedStatus,
      provider_customer_id: sub.customer ? String(sub.customer) : row.provider_customer_id || null,
      provider_subscription_id: String(sub.id),

      current_period_end: repairedPeriodEnd,
    };

    if (typeof repairedCancelAtPeriodEnd === "boolean") {
      updatePayload.cancel_at_period_end = repairedCancelAtPeriodEnd;
    }

    if (repairedIsActive !== null) {
      updatePayload.is_active = !!repairedIsActive;
    }

    await supabaseUpsertEntitlement(updatePayload);

    const fresh = await supabaseGetEntitlementRow(user_id, "decoy_wallet");

    return res.status(200).json({
      ok: true,
      repaired: true,
      provider: fresh?.provider || "stripe",
      provider_status: fresh?.provider_status || null,
      is_active: fresh?.is_active ?? null,
      current_period_end: fresh?.current_period_end || null,
      cancel_at_period_end: fresh?.cancel_at_period_end ?? null,
    });
  } catch (err) {
    console.log("repair-stripe-entitlement failed", err?.message || String(err));
    return res.status(responseStatusFromError(err)).json({ error: err?.message || "Server error" });
  }
});

/* ---------- FINALIZE STRIPE SWITCH (tank mode) ---------- */
app.post("/finalize-stripe-switch", async (req, res) => {
  try {
    const authedUser = await requireSupabaseUser(req);
    const user_id = requireRequestUserMatches(req, authedUser);
    const session_id = req.body?.session_id ? String(req.body.session_id) : null;

    if (!isUuid(user_id)) {
      return res.status(400).json({ error: "Missing or invalid user_id (must be UUID)" });
    }

    const row = await supabaseGetEntitlementRow(user_id, "decoy_wallet");
    if (!row) {
      return res.status(404).json({ error: "Entitlement row not found" });
    }

    if (String(row.pending_provider || "") !== "stripe") {
      if (session_id && isBtpayActive(row)) {
        const sess = await stripeFetchCheckoutSession(session_id);
        if (!sess) {
          return res.status(502).json({
            error: "Could not retrieve Stripe checkout session from Stripe API",
          });
        }

        const sessionUserId =
          sess.client_reference_id || sess.metadata?.user_id || sess.subscription_details?.metadata?.user_id;

        if (String(sessionUserId || "") !== String(user_id)) {
          return res.status(403).json({ error: "Stripe checkout session does not belong to user" });
        }

        if (String(sess.status || "") !== "complete" || !sess.subscription) {
          return res.status(200).json({
            ok: true,
            skipped: true,
            reason: "checkout_not_complete",
          });
        }

        const sub = await stripeFetchSubscription(String(sess.subscription));
        if (!sub) {
          return res
            .status(502)
            .json({ error: "Could not retrieve Stripe subscription from Stripe API" });
        }

        const subStatus = sub.status || null;
        const activeish = normalizeStripeStatusToActive(subStatus);
        if (activeish === false) {
          return res.status(409).json({
            error: "Stripe subscription is not active or trialing",
            stripe_status: subStatus,
          });
        }

        const pendingStartsAt = row.current_period_end;
        await supabaseUpsertEntitlement({
          user_id,
          entitlement: "decoy_wallet",
          updated_at: new Date().toISOString(),
          pending_provider: "stripe",
          pending_provider_customer_id: sub.customer ? String(sub.customer) : sess.customer ? String(sess.customer) : null,
          pending_provider_subscription_id: String(sub.id),
          pending_starts_at: pendingStartsAt,
          switch_initiated_at: new Date().toISOString(),
          teardown_grace_until: pendingStartsAt,
        });

        return res.status(200).json({
          ok: true,
          pending_scheduled: true,
          provider: "btcpay",
          pending_provider: "stripe",
          pending_provider_subscription_id: String(sub.id),
          pending_starts_at: pendingStartsAt,
          stripe_status: subStatus,
        });
      }

      return res.status(409).json({ error: "No pending Stripe switch for this user" });
    }

    if (!isValidIsoDateString(row.pending_starts_at)) {
      return res.status(409).json({ error: "pending_starts_at is missing or invalid" });
    }

    const startMs = isoToMs(row.pending_starts_at);
    if (!startMs) {
      return res.status(409).json({ error: "pending_starts_at could not be parsed" });
    }

    if (nowMs() < startMs) {
      return res.status(409).json({
        error: "Too early to finalize switch",
        pending_starts_at: row.pending_starts_at,
      });
    }

    if (String(row.provider || "") === "stripe" && String(row.provider_subscription_id || "")) {
      return res.status(200).json({
        ok: true,
        already_finalized: true,
        provider: row.provider,
        provider_subscription_id: row.provider_subscription_id,
        current_period_end: row.current_period_end || null,
      });
    }

    let pendingCustomerId = row.pending_provider_customer_id || null;
    let pendingSubId = row.pending_provider_subscription_id || null;

    if ((!pendingCustomerId || !pendingSubId) && session_id) {
      const sess = await stripeFetchCheckoutSession(session_id);
      if (sess) {
        if (!pendingCustomerId && sess.customer) pendingCustomerId = String(sess.customer);
        if (!pendingSubId && sess.subscription) pendingSubId = String(sess.subscription);
      }
    }

    if (!pendingSubId) {
      await clearPendingProviderSwitch(user_id);
      return res.status(200).json({
        ok: true,
        cleared_orphan_pending_switch: true,
        reason: "missing_pending_provider_subscription_id",
        pending_provider_customer_id: pendingCustomerId,
        pending_provider_subscription_id: pendingSubId,
      });
    }

    const sub = await stripeFetchSubscription(pendingSubId);
    if (!sub) {
      return res
        .status(502)
        .json({ error: "Could not retrieve Stripe subscription from Stripe API" });
    }

    const subStatus = sub.status || null;
    const subPeriodEndIso = toIsoFromUnixSeconds(sub.current_period_end);

    const activeish = normalizeStripeStatusToActive(subStatus);
    if (activeish === false) {
      return res.status(409).json({
        error: "Stripe subscription is not active or trialing",
        stripe_status: subStatus,
      });
    }

    const updatePayload = {
      user_id,
      entitlement: "decoy_wallet",
      updated_at: new Date().toISOString(),

      is_active: true,

      provider: "stripe",
      provider_status: subStatus,
      provider_customer_id: pendingCustomerId || (sub.customer ? String(sub.customer) : null),
      provider_subscription_id: String(sub.id),

      current_period_end: subPeriodEndIso,

      pending_provider: null,
      pending_provider_customer_id: null,
      pending_provider_subscription_id: null,
      pending_starts_at: null,
      switch_initiated_at: null,
      teardown_grace_until: null,
    };

    await supabaseUpsertEntitlement(updatePayload);

    return res.status(200).json({
      ok: true,
      finalized: true,
      provider: "stripe",
      provider_customer_id: updatePayload.provider_customer_id,
      provider_subscription_id: updatePayload.provider_subscription_id,
      provider_status: updatePayload.provider_status,
      current_period_end: updatePayload.current_period_end || null,
    });
  } catch (err) {
    console.log("finalize-stripe-switch failed", err?.message || String(err));
    return res.status(responseStatusFromError(err)).json({ error: err?.message || "Server error" });
  }
});

/* ---------- FINALIZE BTCPAY SWITCH (tank mode) ---------- */
app.post("/finalize-btcpay-switch", async (req, res) => {
  try {
    const authedUser = await requireSupabaseUser(req);
    const user_id = requireRequestUserMatches(req, authedUser);

    if (!isUuid(user_id)) {
      return res.status(400).json({ error: "Missing or invalid user_id (must be UUID)" });
    }

    const row = await supabaseGetEntitlementRow(user_id, "decoy_wallet");
    if (!row) {
      return res.status(404).json({ error: "Entitlement row not found" });
    }

    if (String(row.pending_provider || "") !== "btcpay") {
      return res.status(409).json({ error: "No pending BTCPay switch for this user" });
    }

    if (!isValidIsoDateString(row.pending_starts_at)) {
      return res.status(409).json({ error: "pending_starts_at is missing or invalid" });
    }

    const startMs = isoToMs(row.pending_starts_at);
    if (!startMs) {
      return res.status(409).json({ error: "pending_starts_at could not be parsed" });
    }

    if (nowMs() < startMs) {
      return res.status(409).json({
        error: "Too early to finalize switch",
        pending_starts_at: row.pending_starts_at,
      });
    }

    if (String(row.provider || "") === "btcpay" && String(row.provider_subscription_id || "")) {
      const push = await notifyActivationIfNeeded(user_id, {
        provider: "btcpay",
        invoiceId: row.provider_subscription_id,
      });
      console.log("finalize-btcpay-switch already finalized push result", {
        userId: user_id,
        push,
      });

      return res.status(200).json({
        ok: true,
        already_finalized: true,
        provider: row.provider,
        provider_subscription_id: row.provider_subscription_id,
        current_period_end: row.current_period_end || null,
      });
    }

    const pendingInvoiceId = row.pending_provider_subscription_id || null;
    if (!pendingInvoiceId) {
      return res.status(409).json({
        error: "Missing pending_provider_subscription_id for BTCPay switch",
      });
    }

    let btcpayPeriodEnd = addOneMonthIso(new Date(row.pending_starts_at));
    const stackedPaidThroughMs = isoToMs(row.teardown_grace_until);
    const defaultPeriodEndMs = isoToMs(btcpayPeriodEnd);
    if (
      stackedPaidThroughMs &&
      defaultPeriodEndMs &&
      stackedPaidThroughMs > defaultPeriodEndMs
    ) {
      btcpayPeriodEnd = new Date(stackedPaidThroughMs).toISOString();
    }

    const updatePayload = {
      user_id,
      entitlement: "decoy_wallet",
      updated_at: new Date().toISOString(),

      is_active: true,
      provider: "btcpay",
      provider_status: "settled",
      provider_customer_id: null,
      provider_subscription_id: String(pendingInvoiceId),
      current_period_end: btcpayPeriodEnd,
      cancel_at_period_end: false,

      pending_provider: null,
      pending_provider_customer_id: null,
      pending_provider_subscription_id: null,
      pending_starts_at: null,
      switch_initiated_at: null,
      teardown_grace_until: null,
    };

    await supabaseUpsertEntitlement(updatePayload);

    const push = await notifyActivationIfNeeded(user_id, {
      provider: "btcpay",
      invoiceId: pendingInvoiceId,
    });
    console.log("finalize-btcpay-switch activation push result", {
      userId: user_id,
      invoiceId: String(pendingInvoiceId),
      push,
    });

    return res.status(200).json({
      ok: true,
      finalized: true,
      provider: "btcpay",
      provider_subscription_id: updatePayload.provider_subscription_id,
      provider_status: updatePayload.provider_status,
      current_period_end: updatePayload.current_period_end || null,
      push,
    });
  } catch (err) {
    console.log("finalize-btcpay-switch failed", err?.message || String(err));
    return res.status(responseStatusFromError(err)).json({ error: err?.message || "Server error" });
  }
});

/* ---------- Stripe checkout ---------- */
app.post("/create-checkout-session", async (req, res) => {
  try {
    const authedUser = await requireSupabaseUser(req);
    const user_id = requireRequestUserMatches(req, authedUser);
    const email = req.body?.email || authedUser.email || undefined;

    const billing_cycle_anchor = toUnixSecondsOrNull(req.body?.billing_cycle_anchor);
    let trial_end = toUnixSecondsOrNull(req.body?.trial_end);
    const proration_behavior =
      typeof req.body?.proration_behavior === "string" ? req.body.proration_behavior : null;

    if (!isUuid(String(user_id || ""))) {
      return res.status(400).json({ error: "Missing or invalid user_id (must be UUID)" });
    }

    const priceId = pickPriceId();
    if (!priceId) {
      return res.status(400).json({ error: "Missing STRIPE_PRICE_ID or STRIPE_PRICE_ID_MONTHLY" });
    }

    const base = PUBLIC_BASE_URL || `${req.protocol}://${req.get("host")}`;
    const existing = await supabaseGetEntitlementRow(user_id, "decoy_wallet");

    if (
      isPendingStripeSwitch(existing) &&
      !existing?.pending_provider_subscription_id
    ) {
      await clearPendingProviderSwitch(user_id);
    }

    if (!trial_end && isBtpayActive(existing)) {
      trial_end = Math.floor(isoToMs(existing.current_period_end) / 1000);
    }

    const subscription_data = { metadata: { user_id: String(user_id) } };

    if (trial_end) {
      subscription_data.trial_end = trial_end;
    } else if (billing_cycle_anchor) {
      subscription_data.billing_cycle_anchor = billing_cycle_anchor;
      if (proration_behavior) {
        subscription_data.proration_behavior = proration_behavior;
      }
    }

    const sessionCreatePayload = deepClean({
      mode: "subscription",
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: addCheckoutSessionPlaceholder(
        STRIPE_SUCCESS_URL || `${base}/success?session_id={CHECKOUT_SESSION_ID}`
      ),
      cancel_url: STRIPE_CANCEL_URL || `${base}/cancel`,
      client_reference_id: String(user_id),
      metadata: { user_id: String(user_id) },
      subscription_data,
      customer_email: email || undefined,
      payment_method_collection: trial_end ? "always" : undefined,
      allow_promotion_codes: true,
    });

    const session = await stripe.checkout.sessions.create(sessionCreatePayload);

    return res.json({ url: session.url, session_id: session.id });
  } catch (err) {
    const msg = err?.message || "Server error";
    console.log("create-checkout-session failed", msg);
    return res.status(responseStatusFromError(err)).json({ error: msg });
  }
});

/* ---------- Stripe customer portal session ---------- */
app.post("/create-billing-portal-session", async (req, res) => {
  try {
    const authedUser = await requireSupabaseUser(req);
    const user_id = requireRequestUserMatches(req, authedUser);
    const { customer_id, return_url } = req.body || {};

    const row = await supabaseGetEntitlementRow(user_id, "decoy_wallet");
    const customerId = row?.provider_customer_id || null;

    if (customer_id && customer_id !== customerId) {
      return res.status(403).json({ error: "Stripe customer does not belong to authenticated user" });
    }

    if (!customerId || typeof customerId !== "string") {
      return res
        .status(400)
        .json({ error: "Missing customer_id (or user_id has no Stripe customer yet)" });
    }

    const base = PUBLIC_BASE_URL || `${req.protocol}://${req.get("host")}`;
    const finalReturnUrl =
      (return_url && String(return_url)) || (APP_RETURN_URL || `${base}/success`);

    const portalSession = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: finalReturnUrl,
    });

    return res.json({ url: portalSession.url });
  } catch (err) {
    return res.status(responseStatusFromError(err)).json({ error: err?.message || "Server error" });
  }
});

/* ---------- BTCPay invoice optional ---------- */
app.post("/create-btcpay-invoice", async (req, res) => {
  if (!BTCPAY_ENABLED) {
    return res.status(501).json({ error: "BTCPay disabled" });
  }

  try {
    const authedUser = await requireSupabaseUser(req);
    const user_id = requireRequestUserMatches(req, authedUser);
    if (!isUuid(String(user_id || ""))) {
      return res.status(400).json({ error: "Missing or invalid user_id (must be UUID)" });
    }

    const amountUSD = 3.94;
    const redirectURL = "https://decoywalletapp.com/open";

    const response = await fetch(
      `${BTCPAY_BASE_URL}/api/v1/stores/${BTCPAY_STORE_ID}/invoices`,
      {
        method: "POST",
        headers: {
          Authorization: `token ${BTCPAY_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          amount: amountUSD,
          currency: "USD",
          metadata: { user_id: String(user_id), entitlement: "decoy_wallet" },
          checkout: { redirectURL },
        }),
      }
    );

    const data = await response.json().catch(() => ({}));
    if (!response.ok) return res.status(500).json(data);

    return res.json({ url: data.checkoutLink });
  } catch (err) {
    return res.status(responseStatusFromError(err)).json({ error: err?.message || "Server error" });
  }
});

/* ---------- Return pages ---------- */
app.get("/success", (req, res) => {
  const deepLink = getReturnDeepLink(req.query.session_id || "");
  res.send(`
    <html>
      <body>
        <h2>Payment complete</h2>
        <a href="${deepLink}">Return to Decoy Wallet</a>
      </body>
    </html>
  `);
});

app.get("/cancel", (_, res) => {
  const deepLink = getReturnDeepLink("");
  res.send(`
    <html>
      <body>
        <h2>Payment canceled</h2>
        <a href="${deepLink}">Return to Decoy Wallet</a>
      </body>
    </html>
  `);
});

/* ---------- start ---------- */
const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`listening on ${port}`));
