import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Content-Type": "application/json",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: corsHeaders,
  });
}

function cleanString(v: unknown) {
  return String(v ?? "").trim();
}

function normalizePhone(v: unknown) {
  const s = cleanString(v);
  if (!s || s.toLowerCase() === "null") return "";

  let raw = s.replace(/[^\d+]/g, "");
  if (raw.startsWith("00")) {
    raw = `+${raw.slice(2)}`;
  }

  if (raw.startsWith("+")) {
    const digits = raw.replace(/[^\d]/g, "");
    return /^[1-9]\d{7,14}$/.test(digits) ? `+${digits}` : "";
  }

  const digits = raw.replace(/[^\d]/g, "");
  if (/^[2-9]\d{2}[2-9]\d{6}$/.test(digits)) return `+1${digits}`;
  if (/^1[2-9]\d{2}[2-9]\d{6}$/.test(digits)) return `+${digits}`;

  return "";
}

async function sha256Hex(input: string) {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(input),
  );
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get(
      "SUPABASE_SERVICE_ROLE_KEY",
    )!;

    const authHeader = req.headers.get("Authorization") || "";
    if (!authHeader.startsWith("Bearer ")) {
      return json({ ok: false, error: "Missing bearer token" }, 401);
    }

    const jwt = authHeader.replace("Bearer ", "").trim();

    const authClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: `Bearer ${jwt}`,
        },
      },
    });

    const {
      data: { user },
      error: userError,
    } = await authClient.auth.getUser();

    if (userError || !user) {
      return json({ ok: false, error: "Unauthorized" }, 401);
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const body = await req.json();

    const bodyUserId = cleanString(body.userId);
    const userId = user.id;
    const contactSlot = Number(body.contactSlot);
    const firstName = cleanString(body.firstName);
    const lastName = cleanString(body.lastName);
    const phoneNumber = normalizePhone(body.phoneNumber);

    if (bodyUserId && bodyUserId !== userId) {
      return json({ ok: false, error: "User mismatch" }, 403);
    }

    if (
      !Number.isInteger(contactSlot) || contactSlot < 1 || contactSlot > 5 ||
      !phoneNumber
    ) {
      return json({ ok: false, error: "Missing or invalid fields" }, 400);
    }

    const nowIso = new Date().toISOString();

    const { data: existingRows, error: existingError } = await supabase
      .from("emergency_contact_consents")
      .select("*")
      .eq("user_id", userId);

    if (existingError) {
      return json({ ok: false, error: existingError.message }, 500);
    }

    const existingByPhone = (existingRows ?? []).find((row: any) =>
      normalizePhone(row.phone_number) === phoneNumber
    );

    let consentRow: any = null;

    if (existingByPhone) {
      const { data, error } = await supabase
        .from("emergency_contact_consents")
        .update({
          contact_slot: contactSlot,
          first_name: firstName,
          last_name: lastName,
          phone_number: phoneNumber,
          status: "pending",
          confirmed_at: null,
          denied_at: null,
          opted_out_at: null,
          updated_at: nowIso,
        })
        .eq("user_id", userId)
        .eq("id", existingByPhone.id)
        .select()
        .single();

      if (error) {
        return json({ ok: false, error: error.message }, 500);
      }

      consentRow = data;
    } else {
      const { data, error } = await supabase
        .from("emergency_contact_consents")
        .upsert({
          user_id: userId,
          contact_slot: contactSlot,
          first_name: firstName,
          last_name: lastName,
          phone_number: phoneNumber,
          status: "pending",
          confirmed_at: null,
          denied_at: null,
          opted_out_at: null,
          updated_at: nowIso,
        }, {
          onConflict: "user_id,contact_slot",
        })
        .select()
        .single();

      if (error) {
        return json({ ok: false, error: error.message }, 500);
      }

      consentRow = data;
    }

    const rawToken = crypto.randomUUID();
    const tokenHash = await sha256Hex(rawToken);

    const expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24)
      .toISOString();

    const { data: requestRow, error: requestError } = await supabase
      .from("emergency_contact_consent_requests")
      .insert({
        consent_id: consentRow.id,
        user_id: userId,
        contact_slot: contactSlot,
        phone_number: phoneNumber,
        token_hash: tokenHash,
        status: "pending",
        decision: null,
        expires_at: expiresAt,
      })
      .select()
      .single();

    if (requestError) {
      return json({ ok: false, error: requestError.message }, 500);
    }

    const { error: latestRequestError } = await supabase
      .from("emergency_contact_consents")
      .update({
        latest_request_id: requestRow.id,
        updated_at: nowIso,
      })
      .eq("id", consentRow.id);

    if (latestRequestError) {
      return json({ ok: false, error: latestRequestError.message }, 500);
    }

    const link =
      `https://www.decoywalletapp.com/contact-consent?token=${rawToken}`;

    return json({
      ok: true,
      link,
      consentId: consentRow.id,
      requestId: requestRow.id,
    });
  } catch (err) {
    return json({ ok: false, error: String(err) }, 500);
  }
});
