import {
  cleanString,
  errorResponse,
  jsonResponse,
  normalizeSlot,
  optionsResponse,
  readJson,
  requireUser,
} from "../_shared/staging.ts";

function slotRows(value: unknown): Record<string, unknown>[] {
  return Array.isArray(value)
    ? value.filter((item): item is Record<string, unknown> =>
      item !== null && typeof item === "object" && !Array.isArray(item)
    )
    : [];
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return optionsResponse();
  }

  if (req.method !== "POST") {
    return jsonResponse(405, { ok: false, error: "Method not allowed" });
  }

  try {
    const { user, admin } = await requireUser(req);
    const body = await readJson(req);
    const slots = slotRows(body.slots);
    let synced = 0;

    for (const slot of slots) {
      const contactSlot = normalizeSlot(
        slot.contactSlot ?? slot.contact_slot ?? slot.slot,
      );
      if (!contactSlot) continue;

      const firstName = cleanString(slot.firstName ?? slot.first_name);
      const lastName = cleanString(slot.lastName ?? slot.last_name);
      const phoneNumber = cleanString(slot.phoneNumber ?? slot.phone_number);
      const status = cleanString(slot.status ?? slot.consent_status) ||
        "pending";
      const now = new Date().toISOString();

      const { data: existing, error: lookupError } = await admin
        .from("emergency_contact_consents")
        .select("id")
        .eq("user_id", user.id)
        .eq("contact_slot", contactSlot)
        .maybeSingle();

      if (lookupError) {
        return jsonResponse(500, {
          ok: false,
          error: "Unable to inspect staging consent slot",
          details: lookupError.message,
        });
      }

      const patch = {
        user_id: user.id,
        contact_slot: contactSlot,
        first_name: firstName || null,
        last_name: lastName || null,
        phone_number: phoneNumber || null,
        status,
        updated_at: now,
      };

      const write = existing?.id
        ? admin
          .from("emergency_contact_consents")
          .update(patch)
          .eq("id", existing.id)
        : admin.from("emergency_contact_consents").insert(patch);
      const { error: writeError } = await write;

      if (writeError) {
        return jsonResponse(500, {
          ok: false,
          error: "Unable to sync staging consent slot",
          details: writeError.message,
        });
      }

      synced += 1;
    }

    return jsonResponse(200, { ok: true, synced, staging: true });
  } catch (error) {
    return errorResponse(error);
  }
});
