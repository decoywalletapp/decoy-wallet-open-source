// index.mjs - decoy-alert (Cloud Run) - FINAL TANK VERSION
//
// Tank goals:
// - Cloud Run can be "Allow unauthenticated" (so the mobile app can reach it).
// - Application-level auth REQUIRED via Authorization: Bearer <Supabase access token>.
// - Derive userId from token (ignore any userId in request body).
//
// Still does:
// - Inserts alert_logs
// - Enqueues sms_queue
// - Kicks decoy-sms-worker via Cloud Run identity token (includeEmail=true)
//
// Env vars required:
// SUPABASE_URL
// SUPABASE_ANON_KEY
// SUPABASE_SERVICE_ROLE (or SUPABASE_SERVICE_ROLE_KEY)
// SMS_WORKER_RUN_URL   (example: https://decoy-sms-worker-....run.app/run)
// Optional:
// COOLDOWN_SECONDS

import express from "express";
import bodyParser from "body-parser";
import crypto from "crypto";
import { createClient } from "@supabase/supabase-js";

const app = express();
app.disable("x-powered-by");
app.use(bodyParser.json({ limit: "256kb" }));

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const SUPABASE_SERVICE_ROLE =
  process.env.SUPABASE_SERVICE_ROLE || process.env.SUPABASE_SERVICE_ROLE_KEY;

const SMS_WORKER_RUN_URL_RAW = process.env.SMS_WORKER_RUN_URL || "";
const SMS_WORKER_RUN_URL = SMS_WORKER_RUN_URL_RAW.replace(/\/+$/, ""); // no trailing slash

const COOLDOWN_SECONDS_RAW = process.env.COOLDOWN_SECONDS;
let COOLDOWN_SECONDS = Number.parseInt(COOLDOWN_SECONDS_RAW || "", 10);
if (!Number.isFinite(COOLDOWN_SECONDS) || COOLDOWN_SECONDS < 0) COOLDOWN_SECONDS = 0;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE) {
  console.error("[decoy-alert] Missing SUPABASE_URL, SUPABASE_ANON_KEY, or SUPABASE_SERVICE_ROLE");
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE, {
  auth: { persistSession: false },
});

function setCors(res) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS, GET");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

function jsonErr(res, status, msg, extra = {}) {
  setCors(res);
  return res.status(status).json({ ok: false, error: msg, ...extra });
}

function safeString(v, max = 240) {
  const s = (v ?? "").toString();
  return s.length > max ? s.slice(0, max) : s;
}

function newTraceId() {
  return crypto.randomUUID();
}

function normalizeWorkerAudience(urlString) {
  try {
    const u = new URL(urlString);
    return u.origin;
  } catch {
    return "";
  }
}

function normalizeWorkerRunUrl(urlString) {
  try {
    const u = new URL(urlString);
    const path = u.pathname.replace(/\/+$/, "");
    const finalPath = path.endsWith("/run") ? path : `${path}/run`;
    return `${u.origin}${finalPath}`;
  } catch {
    return "";
  }
}

function getBearer(req) {
  const auth = req.get("authorization") || req.get("Authorization") || "";
  const m = auth.match(/^Bearer\s+(.+)$/i);
  return m ? m[1].trim() : "";
}

// Verify Supabase session token and return user id.
// Uses ANON key as apikey for /auth/v1/user.
async function verifySupabaseUserId(jwt) {
  if (!jwt) return null;
  try {
    const resp = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: {
        Authorization: `Bearer ${jwt}`,
        apikey: SUPABASE_ANON_KEY,
      },
    });
    if (!resp.ok) return null;
    const u = await resp.json().catch(() => null);
    return u && u.id ? u.id : null;
  } catch {
    return null;
  }
}

// IMPORTANT: includeEmail=true so downstream services can check payload.email if they want
async function getCloudRunIdentityToken(audience) {
  try {
    if (!audience) return { token: null, status: null, detail: "missing audience" };

    const mdUrl =
      "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity" +
      `?audience=${encodeURIComponent(audience)}&format=full&includeEmail=true`;

    const resp = await fetch(mdUrl, {
      headers: { "Metadata-Flavor": "Google" },
    });

    if (!resp.ok) {
      const text = await resp.text().catch(() => "");
      return {
        token: null,
        status: resp.status,
        detail: safeString(text, 200),
      };
    }

    const token = await resp.text();
    return { token, status: resp.status, detail: null };
  } catch (e) {
    return { token: null, status: null, detail: e?.message || String(e) };
  }
}

async function kickSmsWorker(traceId) {
  if (!SMS_WORKER_RUN_URL) {
    return { kicked: false, kickStatus: null, kickError: "SMS_WORKER_RUN_URL missing" };
  }

  const runUrl = normalizeWorkerRunUrl(SMS_WORKER_RUN_URL);
  const audience = normalizeWorkerAudience(runUrl);

  if (!runUrl || !audience) {
    return {
      kicked: false,
      kickStatus: null,
      kickError: `invalid SMS_WORKER_RUN_URL (${SMS_WORKER_RUN_URL})`,
    };
  }

  const tokenResp = await getCloudRunIdentityToken(audience);
  if (!tokenResp.token) {
    return {
      kicked: false,
      kickStatus: tokenResp.status,
      kickError: `failed to get identity token (aud=${audience}) ${tokenResp.detail || ""}`.trim(),
    };
  }

  const controller = new AbortController();
  const t = setTimeout(() => controller.abort(), 20000);

  try {
    const resp = await fetch(runUrl, {
      method: "POST",
      headers: { Authorization: `Bearer ${tokenResp.token}` },
      signal: controller.signal,
    });

    if (!resp.ok) {
      const text = await resp.text().catch(() => "");
      return {
        kicked: false,
        kickStatus: resp.status,
        kickError: safeString(text, 400) || `sms-worker returned ${resp.status}`,
      };
    }

    return { kicked: true, kickStatus: resp.status, kickError: null };
  } catch (e) {
    return { kicked: false, kickStatus: null, kickError: e?.message || String(e) };
  } finally {
    clearTimeout(t);
  }
}

app.get("/", (req, res) => {
  setCors(res);
  return res.json({
    ok: true,
    service: "decoy-alert",
    status: "running",
    cooldownSeconds: COOLDOWN_SECONDS,
    smsWorkerUrlSet: !!SMS_WORKER_RUN_URL,
    smsWorkerRunUrlNormalized: SMS_WORKER_RUN_URL ? normalizeWorkerRunUrl(SMS_WORKER_RUN_URL) : null,
    smsWorkerAudience: SMS_WORKER_RUN_URL
      ? normalizeWorkerAudience(normalizeWorkerRunUrl(SMS_WORKER_RUN_URL))
      : null,
    authMode: "supabase_jwt_required",
  });
});

app.options("/sendEmergencyAlerts", (req, res) => {
  setCors(res);
  return res.status(204).send("");
});

app.post("/sendEmergencyAlerts", async (req, res) => {
  setCors(res);
  const traceId = newTraceId();

  try {
    const jwt = getBearer(req);
    const authedUserId = await verifySupabaseUserId(jwt);
    if (!authedUserId) {
      return jsonErr(res, 401, "unauthorized", { traceId });
    }

    const body = req.body || {};
    const triggerType = (body.triggerType || body.triggerId || "").toString().trim();

    // Only allow known triggers (prevents random strings / log spam)
    const ALLOWED_TRIGGERS = new Set(["PIN_DECOY", "SEED_DECOY"]);
    if (!ALLOWED_TRIGGERS.has(triggerType)) {
      return jsonErr(res, 400, "triggerType must be PIN_DECOY or SEED_DECOY", { traceId });
    }

    const lat =
      typeof body.lat === "number"
        ? body.lat
        : body.location && typeof body.location.lat === "number"
          ? body.location.lat
          : null;

    const lng =
      typeof body.lng === "number"
        ? body.lng
        : body.location && typeof body.location.lng === "number"
          ? body.location.lng
          : null;

    console.log("[decoy-alert] incoming", {
      traceId,
      triggerType,
      hasLocation: lat !== null && lng !== null,
      userId: authedUserId,
    });

    // Cooldown by user + triggerType
    if (COOLDOWN_SECONDS > 0) {
      const { data: lastRows, error: lastErr } = await supabase
        .from("alert_logs")
        .select("id, created_at")
        .eq("user_id", authedUserId)
        .eq("trigger_type", triggerType)
        .order("created_at", { ascending: false })
        .limit(1);

      if (lastErr) {
        console.error("[decoy-alert] cooldown check failed", lastErr);
        return jsonErr(res, 500, "Cooldown check failed", { traceId, detail: lastErr.message });
      }

      if (lastRows?.length) {
        const lastAt = new Date(lastRows[0].created_at).getTime();
        const elapsedSec = Math.floor((Date.now() - lastAt) / 1000);
        if (elapsedSec < COOLDOWN_SECONDS) {
          return res.status(200).json({
            ok: true,
            sent: false,
            suppressed: true,
            traceId,
            cooldownSeconds: COOLDOWN_SECONDS,
            remainingSeconds: Math.max(0, COOLDOWN_SECONDS - elapsedSec),
          });
        }
      }
    }

    // Insert alert log
    const insertAlert = {
      user_id: authedUserId,
      trigger_type: triggerType,
      success: true,
      error_message: null,
      lat: typeof lat === "number" ? lat : null,
      lng: typeof lng === "number" ? lng : null,
    };

    let alertId = null;

    const { data: insertedRows, error: alertErr } = await supabase
      .from("alert_logs")
      .insert(insertAlert)
      .select("id, created_at");

    if (alertErr) {
      console.error("[decoy-alert] alert_logs insert failed", alertErr);
      return jsonErr(res, 500, "alert insert failed", { traceId, detail: alertErr.message });
    }

    if (Array.isArray(insertedRows) && insertedRows.length >= 1) {
      alertId = insertedRows[0].id;
    } else {
      console.warn("[decoy-alert] insert alert_logs returned no rows", { traceId });

      const since = new Date(Date.now() - 15_000).toISOString();
      const { data: fallbackRows, error: fbErr } = await supabase
        .from("alert_logs")
        .select("id, created_at")
        .eq("user_id", authedUserId)
        .eq("trigger_type", triggerType)
        .gte("created_at", since)
        .order("created_at", { ascending: false })
        .limit(1);

      if (fbErr) {
        console.error("[decoy-alert] alert id fallback query failed", { traceId, fbErr });
        return jsonErr(res, 500, "alert id lookup failed", { traceId, detail: fbErr.message });
      }

      if (!fallbackRows?.length) {
        console.error("[decoy-alert] alert id lookup returned 0 rows", { traceId });
        return jsonErr(res, 500, "alert id lookup returned 0 rows", { traceId });
      }

      alertId = fallbackRows[0].id;
    }

    // Enqueue SMS
    const { error: qErr } = await supabase.from("sms_queue").insert(
      {
        alert_id: alertId,
        user_id: authedUserId,
        processed: false,
      },
      { returning: "minimal" }
    );

    if (qErr) {
      if (qErr.code === "23505") {
        console.log("[decoy-alert] sms_queue duplicate alert_id, ignoring", alertId);
      } else {
        console.error("[decoy-alert] sms_queue insert failed", qErr);
        return jsonErr(res, 500, "sms enqueue failed", {
          traceId,
          alertId,
          detail: qErr.message,
          code: qErr.code,
        });
      }
    }

    const kick = await kickSmsWorker(traceId);

    console.log("[decoy-alert] kick result", {
      traceId,
      alertId,
      kicked: kick.kicked,
      kickStatus: kick.kickStatus,
      kickError: kick.kickError,
    });

    return res.status(200).json({
      ok: true,
      sent: true,
      alertId,
      traceId,
      enqueued: true,
      kicked: kick.kicked,
      kickStatus: kick.kickStatus,
      kickError: kick.kickError,
      cooldownSeconds: COOLDOWN_SECONDS,
    });
  } catch (err) {
    console.error("[decoy-alert] fatal", { err: err?.stack || String(err) });
    return jsonErr(res, 500, "Server error", { traceId });
  }
});

const PORT = Number.parseInt(process.env.PORT || "8080", 10);
app.listen(PORT, "0.0.0.0", () => {
  console.log(`[decoy-alert] listening on port ${PORT} (cooldown=${COOLDOWN_SECONDS}s)`);
});