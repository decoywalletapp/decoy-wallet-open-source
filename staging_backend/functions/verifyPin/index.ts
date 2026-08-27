import {
  cleanString,
  errorResponse,
  hashPin,
  jsonResponse,
  optionsResponse,
  readJson,
  requireUser,
} from "../_shared/staging.ts";

async function matchesPin(
  pin: string,
  hashValue: unknown,
  saltValue: unknown,
): Promise<boolean> {
  const storedHash = cleanString(hashValue);
  const salt = cleanString(saltValue);
  if (!storedHash || !salt) return false;
  return await hashPin(pin, salt) === storedHash;
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
    const pin = cleanString(body.pin);

    if (!/^\d{4,8}$/.test(pin)) {
      return jsonResponse(200, {
        ok: false,
        isAccount: false,
        isDecoy: false,
        error: "Invalid PIN",
      });
    }

    const { data: wallet, error: lookupError } = await admin
      .from("decoy_wallet")
      .select(
        "account_pin_hash, account_pin_salt, decoy_pin_hash, decoy_pin_salt",
      )
      .eq("user_id", user.id)
      .maybeSingle();

    if (lookupError) {
      return jsonResponse(500, {
        ok: false,
        error: "Unable to inspect staging PIN",
        details: lookupError.message,
      });
    }

    if (
      wallet &&
      await matchesPin(pin, wallet.account_pin_hash, wallet.account_pin_salt)
    ) {
      return jsonResponse(200, {
        ok: true,
        isAccount: true,
        isDecoy: false,
        staging: true,
      });
    }

    if (
      wallet &&
      await matchesPin(pin, wallet.decoy_pin_hash, wallet.decoy_pin_salt)
    ) {
      return jsonResponse(200, {
        ok: true,
        isAccount: false,
        isDecoy: true,
        staging: true,
      });
    }

    return jsonResponse(200, {
      ok: false,
      isAccount: false,
      isDecoy: false,
      error: "Invalid PIN",
    });
  } catch (error) {
    return errorResponse(error);
  }
});
