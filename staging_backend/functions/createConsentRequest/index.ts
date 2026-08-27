import {
  cleanString,
  errorResponse,
  jsonResponse,
  normalizeSlot,
  optionsResponse,
  randomBase64,
  readJson,
  requireUser,
  sha256Hex,
  stagingUrl,
} from "../_shared/staging.ts";

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
    const requestedUserId = cleanString(body.userId);
    const contactSlot = normalizeSlot(body.contactSlot);
    const firstName = cleanString(body.firstName);
    const lastName = cleanString(body.lastName);
    const phoneNumber = cleanString(body.phoneNumber);

    if (requestedUserId && requestedUserId !== user.id) {
      return jsonResponse(403, {
        ok: false,
        error: "Cannot create consent for another user",
      });
    }

    if (!contactSlot) {
      return jsonResponse(400, {
        ok: false,
        error: "Invalid contact slot",
      });
    }

    const now = new Date().toISOString();
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      .toISOString();
    const token = randomBase64(24);
    const tokenHash = await sha256Hex(token);

    const { data: existingConsent, error: lookupError } = await admin
      .from("emergency_contact_consents")
      .select("id")
      .eq("user_id", user.id)
      .eq("contact_slot", contactSlot)
      .maybeSingle();

    if (lookupError) {
      return jsonResponse(500, {
        ok: false,
        error: "Unable to inspect staging consent",
        details: lookupError.message,
      });
    }

    const consentPatch = {
      user_id: user.id,
      contact_slot: contactSlot,
      first_name: firstName || null,
      last_name: lastName || null,
      phone_number: phoneNumber || null,
      status: "pending",
      updated_at: now,
    };

    const consentWrite = existingConsent?.id
      ? admin
        .from("emergency_contact_consents")
        .update(consentPatch)
        .eq("id", existingConsent.id)
        .select("id")
        .single()
      : admin
        .from("emergency_contact_consents")
        .insert(consentPatch)
        .select("id")
        .single();

    const { data: consent, error: consentError } = await consentWrite;
    if (consentError || !consent) {
      return jsonResponse(500, {
        ok: false,
        error: "Unable to store staging consent",
        details: consentError?.message,
      });
    }

    const { data: requestRow, error: requestError } = await admin
      .from("emergency_contact_consent_requests")
      .insert({
        consent_id: consent.id,
        user_id: user.id,
        contact_slot: contactSlot,
        phone_number: phoneNumber || null,
        token_hash: tokenHash,
        status: "pending",
        expires_at: expiresAt,
        sent_at: now,
      })
      .select("id")
      .single();

    if (requestError || !requestRow) {
      return jsonResponse(500, {
        ok: false,
        error: "Unable to create staging consent request",
        details: requestError?.message,
      });
    }

    await admin
      .from("emergency_contact_consents")
      .update({
        latest_request_id: requestRow.id,
        updated_at: now,
      })
      .eq("id", consent.id);

    return jsonResponse(200, {
      ok: true,
      link: stagingUrl(`/consent/${requestRow.id}`),
      staging: true,
    });
  } catch (error) {
    return errorResponse(error);
  }
});
