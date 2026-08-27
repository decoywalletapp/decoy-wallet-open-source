import {
  cleanString,
  errorResponse,
  jsonResponse,
  optionsResponse,
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
    const phoneHash = cleanString(body.phoneHash);

    if (!phoneHash) {
      return jsonResponse(400, { ok: false, error: "Missing phone hash" });
    }

    const { data, error } = await admin
      .from("decoy_wallet")
      .select("user_id")
      .eq("phone_e164_hash", phoneHash)
      .neq("user_id", user.id)
      .limit(1);

    if (error) {
      return jsonResponse(500, {
        ok: false,
        error: "Unable to inspect staging phone hash",
        details: error.message,
      });
    }

    return jsonResponse(200, { ok: true, taken: (data ?? []).length > 0 });
  } catch (error) {
    return errorResponse(error);
  }
});
