import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type CommitPayload = {
  decoyId?: unknown;
  id?: unknown;
  derivation_path?: unknown;
  addresses?: unknown;
  xpub?: unknown;
  zpub?: unknown;
  watch_public_key?: unknown;
  watch_public_key_type?: unknown;
};

function response(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function asCleanString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function rejectPrivateMaterial(value: string): boolean {
  const compact = value.trim();
  const words = compact.split(/\s+/).filter(Boolean);

  return (
    /^(xprv|yprv|zprv|tprv|uprv|vprv)/i.test(compact) ||
    /^[5KL][1-9A-HJ-NP-Za-km-z]{50,51}$/.test(compact) ||
    /^6P[1-9A-HJ-NP-Za-km-z]{56}$/.test(compact) ||
    words.length === 12 ||
    words.length === 18 ||
    words.length === 24
  );
}

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
    const text = asCleanString(item);
    if (!text) continue;

    const parsed = text
      .replace(/^bitcoin:/i, "")
      .split("?")[0]
      .trim();
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

function normalizeWatchAddressList(value: string): string[] {
  const candidates = value
    .split(/[\s,;]+/)
    .map((item) => item.trim())
    .filter(Boolean);
  return normalizeAddresses(candidates);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return response(405, { ok: false, error: "Method not allowed" });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return response(500, {
      ok: false,
      error: "Staging backend is missing required Supabase environment values",
    });
  }

  const authorization = req.headers.get("Authorization") ?? "";
  if (!authorization.startsWith("Bearer ")) {
    return response(401, { ok: false, error: "Missing user authorization" });
  }

  const authClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  });

  const { data: authData, error: authError } = await authClient.auth.getUser();
  const user = authData?.user;
  if (authError || !user) {
    return response(401, { ok: false, error: "Invalid user authorization" });
  }

  let payload: CommitPayload;
  try {
    payload = await req.json();
  } catch (_) {
    return response(400, { ok: false, error: "Invalid JSON body" });
  }

  const decoyId = asCleanString(payload.decoyId || payload.id);
  const derivationPath = asCleanString(payload.derivation_path);
  const watchPublicKeyType = asCleanString(payload.watch_public_key_type);
  const requestedWatchPublicKey = asCleanString(payload.watch_public_key);
  const requestedXpub = asCleanString(payload.xpub);
  const requestedZpub = asCleanString(payload.zpub);

  if (!decoyId) {
    return response(400, { ok: false, error: "Missing decoy id" });
  }

  if (!derivationPath) {
    return response(400, { ok: false, error: "Missing derivation path" });
  }

  if (!watchPublicKeyType) {
    return response(400, {
      ok: false,
      error: "Missing watch public key type",
    });
  }

  if (
    watchPublicKeyType !== "bip84-account-zpub" &&
    watchPublicKeyType !== "bitcoin-address-list"
  ) {
    return response(400, {
      ok: false,
      error: "Unsupported watch public key type",
    });
  }

  for (const candidate of [requestedXpub, requestedZpub]) {
    if (candidate && rejectPrivateMaterial(candidate)) {
      return response(400, {
        ok: false,
        error: "Private seed or key material is not accepted",
      });
    }
  }

  if (
    watchPublicKeyType !== "bitcoin-address-list" &&
    requestedWatchPublicKey &&
    rejectPrivateMaterial(requestedWatchPublicKey)
  ) {
    return response(400, {
      ok: false,
      error: "Private seed or key material is not accepted",
    });
  }

  let addresses: string[];
  try {
    addresses = normalizeAddresses(payload.addresses);
  } catch (error) {
    return response(400, {
      ok: false,
      error: error instanceof Error ? error.message : "Invalid addresses",
    });
  }

  if (addresses.length === 0) {
    return response(400, { ok: false, error: "Missing watch addresses" });
  }

  let xpub = "";
  let zpub = "";
  let watchPublicKey = requestedWatchPublicKey;

  if (watchPublicKeyType === "bip84-account-zpub") {
    xpub = requestedXpub;
    zpub = requestedZpub || requestedWatchPublicKey;
    watchPublicKey = requestedWatchPublicKey || zpub;

    if (!watchPublicKey.startsWith("zpub")) {
      return response(400, {
        ok: false,
        error: "BIP84 account imports must store a zpub watch key",
      });
    }

    if (xpub && !xpub.startsWith("xpub")) {
      return response(400, {
        ok: false,
        error: "Invalid xpub value",
      });
    }
  } else if (watchPublicKeyType === "bitcoin-address-list") {
    if (derivationPath !== "imported-addresses") {
      return response(400, {
        ok: false,
        error: "Address-list imports must use imported-addresses path",
      });
    }

    let watchAddresses: string[];
    try {
      watchAddresses = normalizeWatchAddressList(watchPublicKey);
    } catch (error) {
      return response(400, {
        ok: false,
        error:
          error instanceof Error
            ? error.message
            : "Invalid watch address list",
      });
    }

    const expected = addresses.join("\n");
    const supplied = watchAddresses.join("\n");
    if (expected !== supplied) {
      return response(400, {
        ok: false,
        error: "Watch address list does not match submitted addresses",
      });
    }

    watchPublicKey = expected;
  } else {
    return response(400, {
      ok: false,
      error: "Unsupported watch public key type",
    });
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  const { error: upsertError } = await admin.from("decoys").upsert(
    {
      id: decoyId,
      user_id: user.id,
      addresses,
      active: true,
      network: "mainnet",
      derivation_path: derivationPath,
      xpub: xpub || null,
      zpub: zpub || null,
      watch_public_key: watchPublicKey || null,
      watch_public_key_type: watchPublicKeyType,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "id" },
  );

  if (upsertError) {
    return response(500, {
      ok: false,
      error: "Unable to store decoy watch data",
      details: upsertError.message,
    });
  }

  return response(200, {
    ok: true,
    decoyId,
    addressCount: addresses.length,
    watchPublicKeyType,
    storedWatchPublicKey: Boolean(watchPublicKey),
  });
});
