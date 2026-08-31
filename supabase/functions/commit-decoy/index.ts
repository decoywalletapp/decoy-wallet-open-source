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

    const { data: previouslyActiveDecoys, error: activeError } = await supabase
      .from("decoys")
      .select("id")
      .eq("user_id", user.id)
      .eq("active", true)
      .neq("id", decoyId);

    if (activeError) {
      return json({ ok: false, error: activeError.message }, 500);
    }

    const previouslyActiveIds = (previouslyActiveDecoys || [])
      .map((row) => cleanString(row.id))
      .filter(Boolean);

    async function restorePreviouslyActiveDecoys() {
      if (previouslyActiveIds.length === 0) return;

      const { error: restoreError } = await supabase
        .from("decoys")
        .update({ active: true })
        .eq("user_id", user.id)
        .in("id", previouslyActiveIds);

      if (restoreError) {
        console.error(
          "Failed to restore previous active decoy after commit failure:",
          restoreError.message,
        );
      }
    }

    if (previouslyActiveIds.length > 0) {
      const { error: deactivateError } = await supabase
        .from("decoys")
        .update({ active: false })
        .eq("user_id", user.id)
        .eq("active", true)
        .neq("id", decoyId);

      if (deactivateError) {
        return json({ ok: false, error: deactivateError.message }, 500);
      }
    }

    const basePayload = {
      id: decoyId,
      user_id: user.id,
      addresses,
      derivation_path: derivationPath,
      network: "bitcoin",
      active: true,
    };

    const payloadWithWatchKey = {
      ...basePayload,
      xpub: isWatchPublicKey(xpub) ? xpub : null,
      zpub: isWatchPublicKey(zpub) ? zpub : null,
      watch_public_key: addressListWatch
        ? addresses.join("\n")
        : isWatchPublicKey(watchPublicKey)
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
      ({ data, error } = await supabase
        .from("decoys")
        .upsert(basePayload, { onConflict: "id" })
        .select()
        .single());
    }

    if (error) {
      await restorePreviouslyActiveDecoys();
      return json({ ok: false, error: error.message }, 500);
    }

    return json({
      ok: true,
      decoyId,
      storedWatchPublicKey: !!data?.watch_public_key,
      addressCount: addresses.length,
    });
  } catch (err) {
    return json({ ok: false, error: String(err) }, 500);
  }
});
