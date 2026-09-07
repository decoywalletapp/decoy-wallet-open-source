import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
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

function cleanStringArray(v: unknown) {
  if (!Array.isArray(v)) return [];
  return v.map((item) => cleanString(item)).filter(Boolean);
}

function isWatchPublicKey(v: unknown) {
  return /^(xpub|ypub|zpub|tpub|upub|vpub)/i.test(cleanString(v));
}

function isAddressListWatchType(v: unknown) {
  return cleanString(v) === "bitcoin-address-list";
}

function isMissingColumnError(error: any) {
  const message = cleanString(error?.message).toLowerCase();
  return error?.code === "42703" || message.includes("column") ||
    message.includes("schema cache");
}

function isMissingRelationError(error: any) {
  const message = cleanString(error?.message).toLowerCase();
  return error?.code === "42P01" || message.includes("relation") ||
    message.includes("does not exist") || message.includes("schema cache");
}

const watchAddressFingerprintVersion = "watch-address-v1";

function normalizeWatchAddress(value: unknown) {
  const clean = cleanString(value);
  if (/^(bc1|tb1|bcrt1)/i.test(clean)) return clean.toLowerCase();
  return clean;
}

function hex(bytes: ArrayBuffer) {
  return [...new Uint8Array(bytes)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

async function hmacSha256Hex(secret: string, value: string) {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  return hex(await crypto.subtle.sign("HMAC", key, encoder.encode(value)));
}

async function writeWatchAddressFingerprintShadow(
  supabase: any,
  decoyId: string,
  addresses: string[],
  sourceType: string,
) {
  const hmacKey = cleanString(
    Deno.env.get("WATCH_ADDRESS_HMAC_KEY") ||
      Deno.env.get("DECOY_WATCH_ADDRESS_HMAC_KEY"),
  );

  if (!hmacKey) {
    return { enabled: false, stored: 0, addressCount: 0 };
  }

  const rows = [];
  const seen = new Set<string>();

  for (let i = 0; i < addresses.length; i += 1) {
    const address = normalizeWatchAddress(addresses[i]);
    if (!address || seen.has(address)) continue;
    seen.add(address);

    rows.push({
      decoy_id: decoyId,
      address_hmac: await hmacSha256Hex(
        hmacKey,
        `${watchAddressFingerprintVersion}:${address}`,
      ),
      fingerprint_version: watchAddressFingerprintVersion,
      source_type: sourceType || null,
      address_index: i,
    });
  }

  const { error: deleteError } = await supabase
    .from("decoy_watch_address_fingerprints")
    .delete()
    .eq("decoy_id", decoyId);

  if (deleteError) {
    if (!isMissingRelationError(deleteError)) {
      console.warn(
        "Watch address fingerprint shadow delete failed:",
        deleteError.message,
      );
    }

    return {
      enabled: true,
      stored: 0,
      addressCount: rows.length,
      error: "shadow table unavailable",
    };
  }

  if (rows.length === 0) {
    return { enabled: true, stored: 0, addressCount: 0 };
  }

  const { error: insertError } = await supabase
    .from("decoy_watch_address_fingerprints")
    .insert(rows);

  if (insertError) {
    if (!isMissingRelationError(insertError)) {
      console.warn(
        "Watch address fingerprint shadow insert failed:",
        insertError.message,
      );
    }

    return {
      enabled: true,
      stored: 0,
      addressCount: rows.length,
      error: "shadow write failed",
    };
  }

  return { enabled: true, stored: rows.length, addressCount: rows.length };
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
      global: {
        headers: {
          Authorization: `Bearer ${jwt}`,
        },
      },
    });

    const {
      data: { user },
      error: userError,
    } = await authClient.auth.getUser();

    if (userError || !user) {
      return json({ ok: false, error: "Unauthorized" }, 401);
    }

    const body = await req.json();
    const decoyId = cleanString(body.decoyId || body.id);
    const derivationPath = cleanString(body.derivation_path);
    const addresses = cleanStringArray(body.addresses);
    const xpub = cleanString(body.xpub);
    const zpub = cleanString(body.zpub);
    const watchPublicKey = cleanString(body.watch_public_key || zpub || xpub);
    const watchPublicKeyType = cleanString(body.watch_public_key_type);
    const sourceType = cleanString(body.source_type);
    const addressListWatch = isAddressListWatchType(watchPublicKeyType);

    if (!decoyId || !derivationPath || addresses.length === 0) {
      return json({ ok: false, error: "Missing required decoy fields" }, 400);
    }

    if (watchPublicKey && !addressListWatch && !isWatchPublicKey(watchPublicKey)) {
      return json({ ok: false, error: "Invalid public watch key" }, 400);
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const { data: existing, error: existingError } = await supabase
      .from("decoys")
      .select("id, user_id")
      .eq("id", decoyId)
      .maybeSingle();

    if (existingError) {
      return json({ ok: false, error: existingError.message }, 500);
    }

    if (existing && existing.user_id !== user.id) {
      return json({ ok: false, error: "Decoy belongs to another user" }, 403);
    }

    const basePayload = {
      id: decoyId,
      user_id: user.id,
      addresses,
      derivation_path: derivationPath,
      network: "bitcoin",
      active: true,
    };

    const payloadWithMonitorMetadata = {
      ...basePayload,
      source_type: sourceType || null,
      archived_at: null,
    };

    const payloadWithWatchKey = {
      ...payloadWithMonitorMetadata,
      xpub: isWatchPublicKey(xpub) ? xpub : null,
      zpub: isWatchPublicKey(zpub) ? zpub : null,
      watch_public_key: isWatchPublicKey(watchPublicKey)
          ? watchPublicKey
          : null,
      watch_public_key_type: watchPublicKeyType || null,
    };

    let { data, error } = await supabase
      .from("decoys")
      .upsert(payloadWithWatchKey, { onConflict: "id" })
      .select()
      .single();

    if (error && isMissingColumnError(error)) {
      const payloadWithoutMonitorMetadata = {
        ...basePayload,
        xpub: isWatchPublicKey(xpub) ? xpub : null,
        zpub: isWatchPublicKey(zpub) ? zpub : null,
        watch_public_key: isWatchPublicKey(watchPublicKey)
            ? watchPublicKey
            : null,
        watch_public_key_type: watchPublicKeyType || null,
      };

      ({ data, error } = await supabase
        .from("decoys")
        .upsert(payloadWithoutMonitorMetadata, { onConflict: "id" })
        .select()
        .single());
    }

    if (error && isMissingColumnError(error)) {
      ({ data, error } = await supabase
        .from("decoys")
        .upsert(basePayload, { onConflict: "id" })
        .select()
        .single());
    }

    if (error) {
      return json({ ok: false, error: error.message }, 500);
    }

    const fingerprintShadow = await writeWatchAddressFingerprintShadow(
      supabase,
      decoyId,
      addresses,
      sourceType ||
        watchPublicKeyType ||
        (addressListWatch ? "bitcoin-address-list" : "decoy-seed"),
    );

    return json({
      ok: true,
      decoyId,
      storedWatchPublicKey: !!data?.watch_public_key,
      addressCount: addresses.length,
      watchAddressFingerprintShadow: fingerprintShadow,
    });
  } catch (err) {
    return json({ ok: false, error: String(err) }, 500);
  }
});
