import {
  addDaysIso,
  cleanString,
  errorResponse,
  hashPin,
  jsonResponse,
  optionsResponse,
  randomBase64,
  readJson,
  requireUser,
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
    const type = cleanString(body.type).toLowerCase();
    const pin = cleanString(body.pin);

    if (type !== "account" && type !== "decoy") {
      return jsonResponse(400, { ok: false, error: "Invalid PIN type" });
    }

    if (!/^\d{4,8}$/.test(pin)) {
      return jsonResponse(400, {
        ok: false,
        error: "PIN must be 4 to 8 digits",
      });
    }

    const salt = randomBase64(16);
    const pinHash = await hashPin(pin, salt);
    const now = new Date().toISOString();
    const patch: Record<string, unknown> = {
      user_id: user.id,
      updated_at: now,
    };

    if (type === "account") {
      patch.account_pin_hash = pinHash;
      patch.account_pin_salt = salt;
      patch.account_pin_algo = "pbkdf2-sha256-100000";
      patch.setup_complete = true;
      patch.setup_completed_at = now;
    } else {
      patch.decoy_pin_hash = pinHash;
      patch.decoy_pin_salt = salt;
      patch.decoy_pin_algo = "pbkdf2-sha256-100000";
      patch.decoy_pin_set_at = now;
      patch.decoy_mode_enabled = true;
    }

    const { data: existing, error: lookupError } = await admin
      .from("decoy_wallet")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();

    if (lookupError) {
      return jsonResponse(500, {
        ok: false,
        error: "Unable to inspect staging wallet row",
        details: lookupError.message,
      });
    }

    const write = existing?.id
      ? admin.from("decoy_wallet").update(patch).eq("id", existing.id)
      : admin.from("decoy_wallet").insert(patch);
    const { error: writeError } = await write;

    if (writeError) {
      return jsonResponse(500, {
        ok: false,
        error: "Unable to store staging PIN",
        details: writeError.message,
      });
    }

    await admin.from("user_settings").upsert(
      {
        user_id: user.id,
        updated_at: now,
      },
      { onConflict: "user_id" },
    );

    await admin.from("user_entitlements").upsert(
      {
        user_id: user.id,
        entitlement: "decoy_wallet",
        is_active: true,
        provider: "staging",
        provider_status: "active",
        current_period_end: addDaysIso(365),
        updated_at: now,
      },
      { onConflict: "user_id,entitlement" },
    );

    return jsonResponse(200, {
      ok: true,
      isAccount: type === "account",
      isDecoy: type === "decoy",
      staging: true,
    });
  } catch (error) {
    return errorResponse(error);
  }
});
