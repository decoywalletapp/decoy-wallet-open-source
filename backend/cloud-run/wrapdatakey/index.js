// index.js - wrapdatakey (Cloud Run)
//
// Supports BOTH wrap and unwrap via one handler:
// - If body has { dataKeyB64 }, it WRAPS (encrypts) and returns { wrappedB64 }.
// - If body has { wrappedB64 }, it UNWRAPS (decrypts) and returns { dataKeyB64 }.
//
// Auth rules (TANK - safer classification):
// - Always read Authorization: Bearer <token>
// - Classify token by JWT payload.iss (no network calls for classification)
//   - If iss is Supabase -> verify via Supabase /auth/v1/user (user call)
//   - Else -> verify as Cloud Run ID token (verifyIdToken + allowed SA)
//
// IMPORTANT:
// - No JWT in request body
// - Service-to-service calls use Authorization: Bearer <Cloud Run ID token>
// - Never log raw tokens

const { KeyManagementServiceClient } = require("@google-cloud/kms");
const { OAuth2Client } = require("google-auth-library");

const kms = new KeyManagementServiceClient();
const oauth = new OAuth2Client();

const KMS_KEY = process.env.KMS_KEY;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

function b64UrlToBuf(s) {
  if (!s) return null;
  let norm = String(s).replace(/-/g, "+").replace(/_/g, "/");
  norm += "=".repeat((4 - (norm.length % 4)) % 4);
  return Buffer.from(norm, "base64");
}

function bufToB64Url(buf) {
  return Buffer.from(buf)
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

function getBearerToken(req) {
  const auth =
    (req.headers && (req.headers.authorization || req.headers.Authorization)) || "";
  if (typeof auth !== "string") return "";
  const m = auth.match(/^Bearer\s+(.+)$/i);
  return m ? m[1].trim() : "";
}

// Decode JWT payload safely for classification/debugging (do NOT log full token)
function decodeJwtPayloadNoVerify(token) {
  try {
    const parts = String(token).split(".");
    if (parts.length < 2) return null;
    const payloadB64Url = parts[1];

    let b64 = payloadB64Url.replace(/-/g, "+").replace(/_/g, "/");
    b64 += "=".repeat((4 - (b64.length % 4)) % 4);

    const jsonStr = Buffer.from(b64, "base64").toString("utf8");
    return JSON.parse(jsonStr);
  } catch {
    return null;
  }
}

function classifyBearerToken(token) {
  const payload = decodeJwtPayloadNoVerify(token);
  const iss = payload && payload.iss ? String(payload.iss) : "";

  // Cloud Run / Google ID tokens commonly have iss = https://accounts.google.com
  // Supabase access tokens commonly have iss = https://<project>.supabase.co/auth/v1
  if (iss.includes("accounts.google.com")) return "cloud_run_id_token";
  if (iss.includes(".supabase.co/auth/v1")) return "supabase_jwt";

  // Fallback: if it has typical Supabase fields but iss missing, still treat as unknown
  return "unknown";
}

async function verifySupabaseJWT(jwt) {
  if (!jwt) return null;

  const res = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      Authorization: `Bearer ${jwt}`,
      apikey: SUPABASE_SERVICE_ROLE_KEY,
    },
  });

  if (!res.ok) return null;
  const user = await res.json().catch(() => null);
  return user && user.id ? user.id : null;
}

async function verifyCloudRunIdToken(idToken) {
  const aud = (process.env.CLOUD_RUN_AUDIENCE || "").trim();

  // Debug logs: safe summary only
  console.log("[wrapdatakey] expected audience:", aud || "(not set)");
  const decoded = decodeJwtPayloadNoVerify(idToken);
  if (decoded) {
    console.log("[wrapdatakey] token aud:", decoded.aud || "(missing)");
    console.log("[wrapdatakey] token iss:", decoded.iss || "(missing)");
    console.log("[wrapdatakey] token email:", decoded.email || "(missing)");
  } else {
    console.log("[wrapdatakey] token payload decode failed");
  }

  try {
    const ticket = await oauth.verifyIdToken({
      idToken,
      audience: aud || undefined,
    });
    return ticket.getPayload() || null;
  } catch (e) {
    console.log("[wrapdatakey] verifyIdToken failed:", e?.message || String(e));
    return null;
  }
}

function isAllowedCaller(payload) {
  const allowed = (process.env.ALLOWED_CALLER_SA || "").trim();
  if (!allowed) return false;

  const email = payload && payload.email ? String(payload.email) : "";
  return email === allowed;
}

exports.wrapDataKey = async (req, res) => {
  // CORS
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Headers", "authorization,content-type");
  res.set("Access-Control-Allow-Methods", "POST,OPTIONS");
  if (req.method === "OPTIONS") return res.status(204).send("");

  try {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "method_not_allowed" });
    }

    if (!KMS_KEY || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      return res.status(500).json({ error: "server_misconfigured" });
    }

    const token = getBearerToken(req);
    if (!token) return res.status(401).json({ error: "unauthorized" });

    const tokenType = classifyBearerToken(token);
    console.log("[wrapdatakey] tokenType:", tokenType);

    const body = req.body || {};
    let authedUserId = null;

    // If it's clearly a Supabase JWT, verify as user token
    if (tokenType === "supabase_jwt") {
      authedUserId = await verifySupabaseJWT(token);
      if (!authedUserId) return res.status(401).json({ error: "unauthorized" });
    } else {
      // Otherwise, treat as Cloud Run ID token call
      const callerPayload = await verifyCloudRunIdToken(token);
      if (!callerPayload) return res.status(401).json({ error: "unauthorized" });
      if (!isAllowedCaller(callerPayload)) return res.status(403).json({ error: "forbidden" });
      authedUserId = null; // service call allowed
    }

    // MODE A: WRAP
    if (body.dataKeyB64) {
      const plaintext = b64UrlToBuf(body.dataKeyB64);
      if (!plaintext || plaintext.length === 0) {
        return res.status(400).json({ error: "dataKeyB64 invalid" });
      }

      const [result] = await kms.encrypt({ name: KMS_KEY, plaintext });
      const wrappedB64 = bufToB64Url(result.ciphertext);

      return res.json({ v: 1, user: authedUserId, wrappedB64 });
    }

    // MODE B: UNWRAP
    if (body.wrappedB64) {
      const ciphertext = b64UrlToBuf(body.wrappedB64);
      if (!ciphertext || ciphertext.length === 0) {
        return res.status(400).json({ error: "wrappedB64 invalid" });
      }

      const [result] = await kms.decrypt({ name: KMS_KEY, ciphertext });
      const dataKeyB64 = bufToB64Url(result.plaintext);

      return res.json({ v: 1, user: authedUserId, dataKeyB64 });
    }

    return res.status(400).json({ error: "send dataKeyB64 OR wrappedB64" });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "wrap_or_unwrap_failed" });
  }
};