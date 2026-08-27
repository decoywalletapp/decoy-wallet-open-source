import {
  errorResponse,
  jsonResponse,
  optionsResponse,
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
    const { data, error } = await admin
      .from("emergency_contact_consents")
      .select("contact_slot, first_name, last_name, phone_number, status")
      .eq("user_id", user.id)
      .order("contact_slot", { ascending: true });

    if (error) {
      return jsonResponse(500, {
        ok: false,
        error: "Unable to load staging consent statuses",
        details: error.message,
      });
    }

    const rows = data ?? [];
    const body: Record<string, unknown> = {
      ok: true,
      consents: rows,
      staging: true,
    };

    for (let slot = 1; slot <= 5; slot += 1) {
      const row = rows.find((item) => item.contact_slot === slot);
      body[`slot${slot}Status`] = row?.status ?? "";
      body[`slot${slot}First`] = row?.first_name ?? "";
      body[`slot${slot}Last`] = row?.last_name ?? "";
      body[`slot${slot}Phone`] = row?.phone_number ?? "";
    }

    return jsonResponse(200, body);
  } catch (error) {
    return errorResponse(error);
  }
});
