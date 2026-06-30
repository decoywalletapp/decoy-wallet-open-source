import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
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

function statusRank(status: unknown) {
  switch (cleanString(status).toLowerCase()) {
    case "confirmed":
      return 5;
    case "pending":
      return 4;
    case "denied":
      return 3;
    case "opted_out":
      return 2;
    case "expired":
      return 1;
    default:
      return 0;
  }
}

function timestampMs(v: unknown) {
  const ms = Date.parse(cleanString(v));
  return Number.isFinite(ms) ? ms : 0;
}

type ConsentRow = {
  id: string;
  user_id: string;
  contact_slot: number;
  first_name: string | null;
  last_name: string | null;
  phone_number: string;
  status: string | null;
  latest_request_id: string | null;
  created_at: string | null;
  updated_at: string | null;
};

type IncomingContact = {
  contact_slot: number;
  first_name: string;
  last_name: string;
  phone_number: string;
  existingRow?: ConsentRow;
};

function preferConsentRow(current: ConsentRow | undefined, next: ConsentRow) {
  if (!current) return next;

  const currentRank = statusRank(current.status);
  const nextRank = statusRank(next.status);
  if (nextRank !== currentRank) {
    return nextRank > currentRank ? next : current;
  }

  const currentTime = timestampMs(current.updated_at ?? current.created_at);
  const nextTime = timestampMs(next.updated_at ?? next.created_at);
  return nextTime > currentTime ? next : current;
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
      global: { headers: { Authorization: `Bearer ${jwt}` } },
    });

    const {
      data: { user },
      error: userError,
    } = await authClient.auth.getUser();

    if (userError || !user) {
      console.error("syncConsentSlots auth failed", userError);
      return json({ ok: false, error: "Unauthorized" }, 401);
    }

    const body = await req.json().catch(() => null);
    const slots = Array.isArray(body?.slots) ? body.slots : null;

    if (!slots) {
      return json({ ok: false, error: "slots array is required" }, 400);
    }

    const serviceClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const { data: existingRows, error: existingError } = await serviceClient
      .from("emergency_contact_consents")
      .select("*")
      .eq("user_id", user.id);

    if (existingError) {
      console.error("syncConsentSlots existingError", existingError);
      return json({ ok: false, error: existingError.message }, 500);
    }

    const existingByPhone = new Map<string, ConsentRow>();
    for (const row of (existingRows ?? []) as ConsentRow[]) {
      const phone = normalizePhone(row.phone_number);
      if (!phone) continue;
      existingByPhone.set(
        phone,
        preferConsentRow(existingByPhone.get(phone), row),
      );
    }

    const seenTargetSlots = new Set<number>();
    const seenPhones = new Set<string>();
    const normalizedIncoming: IncomingContact[] = [];

    for (const rawSlot of slots) {
      const contactSlot = Number(rawSlot?.contact_slot);
      if (!Number.isFinite(contactSlot) || contactSlot < 1 || contactSlot > 5) {
        continue;
      }

      if (seenTargetSlots.has(contactSlot)) {
        return json(
          {
            ok: false,
            error: `Duplicate contact_slot in payload: ${contactSlot}`,
          },
          400,
        );
      }
      seenTargetSlots.add(contactSlot);

      const firstName = cleanString(rawSlot?.first_name);
      const lastName = cleanString(rawSlot?.last_name);
      const phoneNumber = normalizePhone(rawSlot?.phone_number);

      const isEmpty = !firstName && !lastName && !phoneNumber;
      if (isEmpty) continue;

      if (phoneNumber) {
        if (seenPhones.has(phoneNumber)) {
          return json(
            { ok: false, error: "Duplicate phone_number in contacts payload" },
            400,
          );
        }
        seenPhones.add(phoneNumber);
      }

      normalizedIncoming.push({
        contact_slot: contactSlot,
        first_name: firstName,
        last_name: lastName,
        phone_number: phoneNumber,
      });
    }

    const matchedIds = new Set<string>();
    for (const item of normalizedIncoming) {
      const existing = item.phone_number
        ? existingByPhone.get(item.phone_number)
        : undefined;

      if (!existing) continue;

      if (matchedIds.has(existing.id)) {
        return json(
          {
            ok: false,
            error: "Multiple incoming contacts matched the same consent record",
          },
          400,
        );
      }

      item.existingRow = existing;
      matchedIds.add(existing.id);
    }

    const rowsToDeleteBecauseRemoved = ((existingRows ?? []) as ConsentRow[])
      .filter((row) => !matchedIds.has(row.id));

    const nowIso = () => new Date().toISOString();
    const results: Array<Record<string, unknown>> = [];

    if (rowsToDeleteBecauseRemoved.length > 0) {
      const idsToDelete = rowsToDeleteBecauseRemoved.map((row) => row.id);

      const { error: clearLatestRequestError } = await serviceClient
        .from("emergency_contact_consents")
        .update({
          latest_request_id: null,
          updated_at: nowIso(),
        })
        .eq("user_id", user.id)
        .in("id", idsToDelete);

      if (clearLatestRequestError) {
        console.error(
          "syncConsentSlots clearLatestRequestError",
          clearLatestRequestError,
        );
        return json({ ok: false, error: clearLatestRequestError.message }, 500);
      }

      const { error: deleteRequestsError } = await serviceClient
        .from("emergency_contact_consent_requests")
        .delete()
        .eq("user_id", user.id)
        .in("consent_id", idsToDelete);

      if (deleteRequestsError) {
        console.error("syncConsentSlots deleteRequestsError", deleteRequestsError);
        return json({ ok: false, error: deleteRequestsError.message }, 500);
      }

      const { error: deleteConsentsError } = await serviceClient
        .from("emergency_contact_consents")
        .delete()
        .eq("user_id", user.id)
        .in("id", idsToDelete);

      if (deleteConsentsError) {
        console.error("syncConsentSlots deleteConsentsError", deleteConsentsError);
        return json({ ok: false, error: deleteConsentsError.message }, 500);
      }

      for (const row of rowsToDeleteBecauseRemoved) {
        results.push({
          contact_slot: row.contact_slot,
          action: "deleted_removed_contact",
          deleted_status: row.status,
          phone_match_preserved: false,
        });
      }
    }

    const matchedIncoming = normalizedIncoming.filter((item) =>
      Boolean(item.existingRow)
    );

    for (const item of matchedIncoming) {
      const existing = item.existingRow!;
      if (Number(existing.contact_slot) === item.contact_slot) continue;

      const temporarySlot = 1000 + item.contact_slot;
      const { error: tempMoveError } = await serviceClient
        .from("emergency_contact_consents")
        .update({
          contact_slot: temporarySlot,
          updated_at: nowIso(),
        })
        .eq("user_id", user.id)
        .eq("id", existing.id);

      if (tempMoveError) {
        console.error("syncConsentSlots tempMoveError", {
          tempMoveError,
          existing,
          item,
        });
        return json({ ok: false, error: tempMoveError.message }, 500);
      }
    }

    for (const item of normalizedIncoming) {
      const existing = item.existingRow;

      if (!existing) {
        results.push({
          contact_slot: item.contact_slot,
          action: "new_contact_no_consent_row",
        });
        continue;
      }

      const updates = {
        contact_slot: item.contact_slot,
        first_name: item.first_name,
        last_name: item.last_name,
        phone_number: item.phone_number,
        updated_at: nowIso(),
      };

      const { error: updateError } = await serviceClient
        .from("emergency_contact_consents")
        .update(updates)
        .eq("user_id", user.id)
        .eq("id", existing.id);

      if (updateError) {
        console.error("syncConsentSlots updateMatchedContactError", {
          updateError,
          existing,
          item,
          updates,
        });
        return json({ ok: false, error: updateError.message }, 500);
      }

      const { error: updateRequestsError } = await serviceClient
        .from("emergency_contact_consent_requests")
        .update({
          contact_slot: item.contact_slot,
          phone_number: item.phone_number,
        })
        .eq("user_id", user.id)
        .eq("consent_id", existing.id);

      if (updateRequestsError) {
        console.error("syncConsentSlots updateRequestsError", {
          updateRequestsError,
          existing,
          item,
        });
        return json({ ok: false, error: updateRequestsError.message }, 500);
      }

      results.push({
        contact_slot: item.contact_slot,
        previous_contact_slot: existing.contact_slot,
        action:
          Number(existing.contact_slot) === item.contact_slot
            ? "same_contact_kept_status"
            : "moved_contact_kept_status_and_links",
        kept_status: existing.status,
        consent_id: existing.id,
      });
    }

    return json({
      ok: true,
      identityMatching: "phone_number",
      results,
    });
  } catch (err) {
    console.error("syncConsentSlots fatal", err);
    return json({ ok: false, error: String(err) }, 500);
  }
});
