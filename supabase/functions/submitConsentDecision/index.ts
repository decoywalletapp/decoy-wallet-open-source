import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Content-Type": "application/json",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: corsHeaders,
  });
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

function decodeB64(s: string) {
  let normalized = String(s).replace(/-/g, "+").replace(/_/g, "/");
  normalized += "=".repeat((4 - (normalized.length % 4)) % 4);
  return Uint8Array.from(atob(normalized), (c) => c.charCodeAt(0));
}

function encodeB64(arr: Uint8Array) {
  return btoa(String.fromCharCode(...arr));
}

function normalizeWrappedUrl(url: string) {
  return url.endsWith("/") ? url : `${url}/`;
}

function normalizePhoneForTwilio(v: unknown) {
  const s = String(v ?? "").trim();
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

async function unwrapDataKey(wrappedB64: string) {
  const baseUrl = Deno.env.get("WRAPDATAKEY_URL");
  if (!baseUrl) throw new Error("Missing WRAPDATAKEY_URL");

  const internalSecret = Deno.env.get("INTERNAL_SHARED_SECRET");
  if (!internalSecret) throw new Error("Missing INTERNAL_SHARED_SECRET");

  const url = normalizeWrappedUrl(baseUrl.replace(/\/+$/, ""));

  const resp = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-internal-secret": internalSecret,
    },
    body: JSON.stringify({ wrappedB64 }),
  });

  const j = await resp.json();

  if (!resp.ok) {
    throw new Error(j?.error || `unwrap failed: ${resp.status}`);
  }

  const dataKeyB64 =
    j?.dataKeyB64 ||
    j?.rawKeyB64 ||
    j?.raw_datakey ||
    j?.data_key ||
    j?.datakey ||
    j?.key;

  if (!dataKeyB64) {
    throw new Error("unwrap response missing dataKeyB64");
  }

  return dataKeyB64;
}

async function sendTwilioSms(toRaw: string, body: string) {
  const accountSid = Deno.env.get("TWILIO_ACCOUNT_SID") || "";
  const authToken = Deno.env.get("TWILIO_AUTH_TOKEN") || "";
  const from = Deno.env.get("TWILIO_FROM") || "";

  if (!accountSid || !authToken || !from) {
    return {
      ok: false,
      error: "Missing Twilio env vars in submitConsentDecision",
    };
  }

  const to = normalizePhoneForTwilio(toRaw);
  if (!to) {
    return {
      ok: false,
      error: "Invalid destination phone for Twilio",
    };
  }

  const auth = btoa(`${accountSid}:${authToken}`);
  const url = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`;

  const form = new URLSearchParams();
  form.set("To", to);
  form.set("From", from);
  form.set("Body", body);

  const resp = await fetch(url, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${auth}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: form.toString(),
  });

  const text = await resp.text();
  let data: any = null;

  try {
    data = JSON.parse(text);
  } catch {
    data = { raw: text };
  }

  if (!resp.ok) {
    return {
      ok: false,
      error: data?.message || `Twilio send failed: ${resp.status}`,
      status: resp.status,
      code: data?.code || null,
    };
  }

  return {
    ok: true,
    sid: data?.sid || null,
  };
}


type ContactStatus = "confirmed" | "denied" | "opted_out";

type PushPayload = {
  fcmToken: string;
  title: string;
  body: string;
  data: Record<string, string>;
};

function cleanString(v: unknown) {
  return String(v ?? "").trim();
}

function contactDisplayName(row: any, contactSlot: number) {
  const first = cleanString(row?.first_name);
  const last = cleanString(row?.last_name);
  const fullName = [first, last].filter(Boolean).join(" ").trim();

  if (fullName) return fullName;
  return `Emergency contact ${contactSlot}`;
}

function contactStatusPushBody(status: ContactStatus, displayName: string) {
  if (status === "confirmed") {
    return `${displayName} has opted in to receive emergency alerts.`;
  }

  if (status === "denied") {
    return `${displayName} declined emergency alerts.`;
  }

  return `${displayName} has opted out of receiving emergency alert texts.`;
}

async function sendContactStatusPush(args: {
  supabase: any;
  supabaseUrl: string;
  serviceRoleKey: string;
  userId: string;
  contactSlot: number;
  displayName: string;
  status: ContactStatus;
}) {
  const {
    supabase,
    supabaseUrl,
    serviceRoleKey,
    userId,
    contactSlot,
    displayName,
    status,
  } = args;

  try {
    const { data: settings, error: settingsError } = await supabase
      .from("user_settings")
      .select("push_enabled")
      .eq("user_id", userId)
      .maybeSingle();

    if (settingsError) {
      console.log(`contact status push skipped settings error userId=${userId} err=${settingsError.message}`);
      return { attempted: 0, sent: 0, skipped: "settings_query_error" };
    }

    if (!settings?.push_enabled) {
      return { attempted: 0, sent: 0, skipped: "push_disabled" };
    }

    const { data: devices, error: devicesError } = await supabase
      .from("user_devices")
      .select("fcm_token")
      .eq("user_id", userId)
      .not("fcm_token", "is", null);

    if (devicesError) {
      console.log(`contact status push skipped devices error userId=${userId} err=${devicesError.message}`);
      return { attempted: 0, sent: 0, skipped: "device_query_error" };
    }

    if (!devices || devices.length === 0) {
      return { attempted: 0, sent: 0, skipped: "no_devices" };
    }

    const sendPushUrl = `${supabaseUrl}/functions/v1/sendPush`;
    const body = contactStatusPushBody(status, displayName);
    let attempted = 0;
    let sent = 0;

    for (const device of devices) {
      const fcmToken = cleanString((device as any).fcm_token);
      if (!fcmToken) continue;

      attempted++;

      const payload: PushPayload = {
        fcmToken,
        title: "Emergency contact updated",
        body,
        data: {
          type: "emergency_contact_status_changed",
          status,
          user_id: userId,
          contact_slot: String(contactSlot),
        },
      };

      const resp = await fetch(sendPushUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${serviceRoleKey}`,
          apikey: serviceRoleKey,
        },
        body: JSON.stringify(payload),
      });

      if (resp.ok) {
        sent++;
      } else {
        const text = await resp.text().catch(() => "");
        console.log(`contact status sendPush failed userId=${userId} slot=${contactSlot} status=${status} http=${resp.status} body=${text}`);
      }
    }

    return { attempted, sent, skipped: null };
  } catch (err) {
    console.log(`contact status push unexpected userId=${userId} slot=${contactSlot} status=${status} err=${String(err)}`);
    return { attempted: 0, sent: 0, skipped: "unexpected_error" };
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const body = await req.json();
    const token = String(body.token || "").trim();
    const decision = String(body.decision || "").trim();

    if (!token) {
      return json({ ok: false, error: "Missing token" }, 400);
    }

    if (!["yes", "no", "opt_out"].includes(decision)) {
      return json({ ok: false, error: "Invalid decision" }, 400);
    }

    const tokenHash = await sha256Hex(token);

    const { data: requestRow, error: requestError } = await supabase
      .from("emergency_contact_consent_requests")
      .select("*")
      .eq("token_hash", tokenHash)
      .maybeSingle();

    if (requestError) {
      return json({ ok: false, error: requestError.message }, 500);
    }

    if (!requestRow) {
      return json({ ok: false, error: "Invalid link" }, 404);
    }

    const { data: consentForRequest, error: consentForRequestError } =
      await supabase
        .from("emergency_contact_consents")
        .select("contact_slot, first_name, last_name, phone_number")
        .eq("id", requestRow.consent_id)
        .maybeSingle();

    if (consentForRequestError) {
      return json({ ok: false, error: consentForRequestError.message }, 500);
    }

    const currentSlot = Number(
      consentForRequest?.contact_slot ?? requestRow.contact_slot,
    );
    const contactPhone =
      normalizePhoneForTwilio(
        consentForRequest?.phone_number || requestRow.phone_number,
      ) || String(requestRow.phone_number || "");

    const now = new Date();
    const expiresAt = new Date(requestRow.expires_at);

    if (expiresAt.getTime() < now.getTime()) {
      await supabase
        .from("emergency_contact_consent_requests")
        .update({
          status: "expired",
          responded_at: now.toISOString(),
        })
        .eq("id", requestRow.id);

      await supabase
        .from("emergency_contact_consents")
        .update({
          status: "expired",
          updated_at: now.toISOString(),
        })
        .eq("id", requestRow.consent_id);

      return json({ ok: false, error: "Link expired" }, 400);
    }

    if (requestRow.status !== "pending") {
      return json(
        {
          ok: false,
          error: "This link has already been used",
          currentStatus: requestRow.status,
        },
        400,
      );
    }

    let newStatus = "Not sent";
    let consentTableStatus = "pending";
    let confirmedAt: string | null = null;
    let deniedAt: string | null = null;
    let optedOutAt: string | null = null;
    let optOutLink: string | null = null;
    let enrollmentSmsSent = false;
    let enrollmentSmsSid: string | null = null;
    let enrollmentSmsError: string | null = null;

    if (decision === "yes") {
      newStatus = "Confirmed";
      consentTableStatus = "confirmed";
      confirmedAt = now.toISOString();
    } else if (decision === "no") {
      newStatus = "Denied";
      consentTableStatus = "denied";
      deniedAt = now.toISOString();
    } else if (decision === "opt_out") {
      newStatus = "Opted out";
      consentTableStatus = "opted_out";
      optedOutAt = now.toISOString();
    }

    const { error: updateRequestError } = await supabase
      .from("emergency_contact_consent_requests")
      .update({
        status: consentTableStatus,
        decision,
        responded_at: now.toISOString(),
        contact_slot: currentSlot,
        phone_number: contactPhone,
      })
      .eq("id", requestRow.id);

    if (updateRequestError) {
      return json({ ok: false, error: updateRequestError.message }, 500);
    }

    const { error: updateConsentError } = await supabase
      .from("emergency_contact_consents")
      .update({
        status: consentTableStatus,
        latest_request_id: requestRow.id,
        confirmed_at: confirmedAt,
        denied_at: deniedAt,
        opted_out_at: optedOutAt,
        updated_at: now.toISOString(),
      })
      .eq("id", requestRow.consent_id);

    if (updateConsentError) {
      return json({ ok: false, error: updateConsentError.message }, 500);
    }

    if (decision === "yes") {
      // clear any prior SMS suppression so explicit reconfirmation re-enrolls the phone
      const { error: clearSuppressionError } = await supabase
        .from("emergency_contact_sms_suppressions")
        .delete()
        .eq("phone_number", contactPhone);

      if (clearSuppressionError) {
        return json({ ok: false, error: clearSuppressionError.message }, 500);
      }

      // revoke any older active opt out tokens for this phone so only the newest one remains active
      const { error: revokeOldTokensError } = await supabase
        .from("emergency_contact_opt_out_tokens")
        .update({
          status: "revoked",
          revoked_at: now.toISOString(),
          updated_at: now.toISOString(),
        })
        .eq("phone_number", contactPhone)
        .eq("status", "active");

      if (revokeOldTokensError) {
        return json({ ok: false, error: revokeOldTokensError.message }, 500);
      }

      const optOutRawToken = crypto.randomUUID() + crypto.randomUUID();
      const optOutTokenHash = await sha256Hex(optOutRawToken);
      const optOutExpiresAt = null;

      const { error: optOutInsertError } = await supabase
        .from("emergency_contact_opt_out_tokens")
        .insert({
          consent_id: requestRow.consent_id,
          user_id: requestRow.user_id,
          phone_number: contactPhone,
          token_hash: optOutTokenHash,
          status: "active",
          source: "confirmation_sms",
          expires_at: optOutExpiresAt,
        });

      if (optOutInsertError) {
        return json({ ok: false, error: optOutInsertError.message }, 500);
      }

      optOutLink = `https://www.decoywalletapp.com/opt-out?token=${optOutRawToken}`;
      const enrollmentBody =
        `Decoy Wallet: You are enrolled to receive emergency alert text messages for someone who listed you as an emergency contact.\n\n` +
        `Reply STOP to opt out at any time or use this link: ${optOutLink}`;

      const smsResult = await sendTwilioSms(contactPhone, enrollmentBody);

      if (smsResult.ok) {
        enrollmentSmsSent = true;
        enrollmentSmsSid = smsResult.sid || null;
      } else {
        enrollmentSmsSent = false;
        enrollmentSmsError = smsResult.error || "Unknown Twilio error";
        console.error(
          `submitConsentDecision enrollment SMS failed status=${smsResult.status || "unknown"} code=${smsResult.code || "unknown"} error=${smsResult.error || "unknown"}`,
        );
      }
    }

    const userId = requestRow.user_id;
    const slot = currentSlot;

    const { data: contactForPush, error: contactForPushError } = await supabase
      .from("emergency_contact_consents")
      .select("first_name, last_name, phone_number, contact_slot")
      .eq("id", requestRow.consent_id)
      .maybeSingle();

    if (contactForPushError) {
      console.log(`submitConsentDecision contact push name lookup failed consentId=${requestRow.consent_id} err=${contactForPushError.message}`);
    }

    const { data: wallet, error: walletError } = await supabase
      .from("decoy_wallet")
      .select("contacts_ciphertext, contacts_nonce, wrapped_datakey")
      .eq("user_id", userId)
      .maybeSingle();

    if (walletError) {
      return json({ ok: false, error: walletError.message }, 500);
    }

    if (
      wallet?.contacts_ciphertext &&
      wallet?.contacts_nonce &&
      wallet?.wrapped_datakey
    ) {
      const rawKeyB64 = await unwrapDataKey(wallet.wrapped_datakey);
      const keyBytes = decodeB64(rawKeyB64);
      const nonceBytes = decodeB64(wallet.contacts_nonce);
      const cipherBytes = decodeB64(wallet.contacts_ciphertext);

      const cryptoKey = await crypto.subtle.importKey(
        "raw",
        keyBytes,
        { name: "AES-GCM" },
        false,
        ["decrypt", "encrypt"],
      );

      const decrypted = await crypto.subtle.decrypt(
        { name: "AES-GCM", iv: nonceBytes },
        cryptoKey,
        cipherBytes,
      );

      const obj = JSON.parse(new TextDecoder().decode(decrypted));

      if (Array.isArray(obj.contacts)) {
        let idx = -1;

        if (contactPhone) {
          idx = obj.contacts.findIndex((contact: any) => {
            const phone = normalizePhoneForTwilio(
              contact?.phone ?? contact?.phone_number ?? "",
            );
            return phone && phone === contactPhone;
          });
        }

        if (idx < 0) {
          idx = slot - 1;
        }

        if (idx >= 0 && idx < obj.contacts.length && obj.contacts[idx]) {
          obj.contacts[idx].consent_status = newStatus;
        }
      }

      const newNonce = crypto.getRandomValues(new Uint8Array(12));
      const plaintext = new TextEncoder().encode(JSON.stringify(obj));

      const encrypted = await crypto.subtle.encrypt(
        { name: "AES-GCM", iv: newNonce },
        cryptoKey,
        plaintext,
      );

      const { error: walletUpdateError } = await supabase
        .from("decoy_wallet")
        .update({
          contacts_ciphertext: encodeB64(new Uint8Array(encrypted)),
          contacts_nonce: encodeB64(newNonce),
        })
        .eq("user_id", userId);

      if (walletUpdateError) {
        return json({ ok: false, error: walletUpdateError.message }, 500);
      }
    }

    const contactStatusPush = await sendContactStatusPush({
      supabase,
      supabaseUrl: SUPABASE_URL,
      serviceRoleKey: SUPABASE_SERVICE_ROLE_KEY,
      userId,
      contactSlot: slot,
      displayName: contactDisplayName(contactForPush, slot),
      status: consentTableStatus as ContactStatus,
    });

    return json({
      ok: true,
      status: newStatus,
      decision,
      optOutLink,
      enrollmentSmsSent,
      enrollmentSmsSid,
      enrollmentSmsError,
      contactStatusPush,
    });
  } catch (err) {
    return json({ ok: false, error: String(err) }, 500);
  }
});
