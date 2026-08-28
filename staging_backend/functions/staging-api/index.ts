import {
  cleanString,
  errorResponse,
  jsonResponse,
  optionsResponse,
  readJson,
  requireUser,
  sha256Hex,
  stagingUrl,
} from "../_shared/staging.ts";

function pathAfterFunction(req: Request): string[] {
  const url = new URL(req.url);
  const pieces = url.pathname.split("/").filter(Boolean);
  const marker = pieces.lastIndexOf("staging-api");
  return marker >= 0 ? pieces.slice(marker + 1) : [];
}

async function optionalUser(req: Request) {
  try {
    return await requireUser(req);
  } catch (_) {
    return null;
  }
}

async function handleFirebase(action: string, body: Record<string, unknown>) {
  if (action === "sendVerificationCode") {
    return jsonResponse(200, {
      success: true,
      sid: "staging-verification-noop",
      staging: true,
    });
  }

  if (action === "checkVerificationCode") {
    return jsonResponse(200, {
      success: true,
      status: "approved",
      staging: true,
    });
  }

  if (action === "getPhoneHash") {
    const phone = cleanString(body.cleanPhone ?? body.phone);
    if (!phone) {
      return jsonResponse(400, { success: false, error: "Missing phone" });
    }
    return jsonResponse(200, {
      success: true,
      phoneHash: await sha256Hex(`phone:${phone}`),
      staging: true,
    });
  }

  if (action === "getEmailHash") {
    const email = cleanString(body.email).toLowerCase();
    if (!email) {
      return jsonResponse(400, { success: false, error: "Missing email" });
    }
    return jsonResponse(200, {
      success: true,
      emailHash: await sha256Hex(`email:${email}`),
      staging: true,
    });
  }

  if (action === "sendSupportTicket") {
    return jsonResponse(200, { success: true, staging: true });
  }

  return jsonResponse(404, {
    success: false,
    error: "Unknown staging Firebase helper",
  });
}

function handleDataKey(body: Record<string, unknown>) {
  const dataKeyB64 = cleanString(body.dataKeyB64);
  const wrappedB64 = cleanString(body.wrappedB64);

  if (dataKeyB64) {
    return jsonResponse(200, {
      wrappedB64: dataKeyB64,
      keyId: "staging-identity-wrapper",
      staging: true,
    });
  }

  if (wrappedB64) {
    return jsonResponse(200, {
      dataKeyB64: wrappedB64,
      unwrappedB64: wrappedB64,
      staging: true,
    });
  }

  return jsonResponse(400, {
    ok: false,
    error: "Missing dataKeyB64 or wrappedB64",
  });
}

async function handlePayment(req: Request, action: string) {
  const context = await optionalUser(req);
  if (context) {
    await context.admin.from("user_entitlements").upsert(
      {
        user_id: context.user.id,
        entitlement: "decoy_wallet",
        is_active: true,
        provider: "staging",
        provider_status: "active",
        current_period_end: new Date(
          Date.now() + 365 * 24 * 60 * 60 * 1000,
        ).toISOString(),
        updated_at: new Date().toISOString(),
      },
      { onConflict: "user_id,entitlement" },
    );
  }

  return jsonResponse(200, {
    ok: true,
    url: stagingUrl(`/payment/${action || "complete"}`),
    session_id: "staging-session",
    invoice_id: "staging-invoice",
    staging: true,
  });
}

async function handleAlerts(req: Request, body: Record<string, unknown>) {
  const context = await optionalUser(req);
  if (context) {
    const triggerType = cleanString(body.triggerType) || "STAGING_TEST_ALERT";
    const location = body.location && typeof body.location === "object"
      ? body.location as Record<string, unknown>
      : {};
    const lat = Number(location.lat);
    const lng = Number(location.lng);

    await context.admin.from("alert_logs").insert({
      user_id: context.user.id,
      trigger_type: triggerType,
      success: true,
      lat: Number.isFinite(lat) ? lat : null,
      lng: Number.isFinite(lng) ? lng : null,
      created_at: new Date().toISOString(),
    });
  }

  return jsonResponse(200, {
    ok: true,
    success: true,
    queued: true,
    staging: true,
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return optionsResponse();
  }

  if (req.method !== "POST") {
    return jsonResponse(405, { ok: false, error: "Method not allowed" });
  }

  try {
    const parts = pathAfterFunction(req);
    const group = parts[0] ?? "";
    const action = parts[1] ?? "";
    const body = await readJson(req);

    if (group === "firebase") {
      return await handleFirebase(action, body);
    }

    if (group === "data-key") {
      return handleDataKey(body);
    }

    if (group === "payment") {
      return await handlePayment(req, action);
    }

    if (group === "alerts" && action === "sendEmergencyAlerts") {
      return await handleAlerts(req, body);
    }

    return jsonResponse(404, {
      ok: false,
      error: "Unknown staging helper route",
    });
  } catch (error) {
    return errorResponse(error);
  }
});
