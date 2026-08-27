import {
  cleanString,
  errorResponse,
  jsonResponse,
  optionsResponse,
  readJson,
  requireUser,
} from "../_shared/staging.ts";

function isMainnetAddress(value: string): boolean {
  const trimmed = value.trim();
  const lower = trimmed.toLowerCase();
  const isBech32 =
    lower.startsWith("bc1") &&
    trimmed === lower &&
    /^bc1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{11,87}$/.test(lower);
  const isBase58 = /^[13][1-9A-HJ-NP-Za-km-z]{25,34}$/.test(trimmed);
  return isBech32 || isBase58;
}

function normalizeAddress(value: string): string {
  const trimmed = value.trim();
  return trimmed.toLowerCase().startsWith("bc1")
    ? trimmed.toLowerCase()
    : trimmed;
}

function normalizeAddresses(raw: unknown): string[] {
  const values = Array.isArray(raw)
    ? raw
    : typeof raw === "string"
      ? raw.split(/[\s,;]+/)
      : [raw];
  const seen = new Set<string>();
  const addresses: string[] = [];

  for (const item of values) {
    const text = cleanString(item);
    if (!text) continue;
    const parsed = text.replace(/^bitcoin:/i, "").split("?")[0].trim();
    const normalized = normalizeAddress(parsed);
    if (!isMainnetAddress(normalized)) {
      throw new Error("Invalid mainnet receive address");
    }
    if (!seen.has(normalized)) {
      seen.add(normalized);
      addresses.push(normalized);
    }
  }

  return addresses;
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
    const decoyId = cleanString(body.id || body.decoyId);
    const derivationPath = cleanString(body.derivation_path);
    const addresses = normalizeAddresses(body.addresses);

    if (!decoyId) {
      return jsonResponse(400, { ok: false, error: "Missing decoy id" });
    }

    if (!derivationPath) {
      return jsonResponse(400, {
        ok: false,
        error: "Missing derivation path",
      });
    }

    if (addresses.length === 0) {
      return jsonResponse(400, { ok: false, error: "Missing address" });
    }

    const { error } = await admin.from("decoys").upsert(
      {
        id: decoyId,
        user_id: user.id,
        addresses,
        active: true,
        network: "mainnet",
        derivation_path: derivationPath,
        watch_public_key_type: "generated-bip84-account",
        updated_at: new Date().toISOString(),
      },
      { onConflict: "id" },
    );

    if (error) {
      return jsonResponse(500, {
        ok: false,
        error: "Unable to register staging decoy",
        details: error.message,
      });
    }

    return jsonResponse(200, {
      ok: true,
      decoyId,
      addressCount: addresses.length,
      staging: true,
    });
  } catch (error) {
    return errorResponse(error);
  }
});
