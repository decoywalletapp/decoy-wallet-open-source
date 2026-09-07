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

function cleanString(value: unknown) {
  return String(value ?? "").trim();
}

function asBoolean(value: unknown) {
  return value === true || cleanString(value).toLowerCase() === "true";
}

function cleanStringArray(value: unknown) {
  if (!Array.isArray(value)) return [];
  return [...new Set(value.map((item) => cleanString(item)).filter(Boolean))];
}

function isMissingRelationError(error: any) {
  const message = cleanString(error?.message).toLowerCase();
  return error?.code === "42P01" || message.includes("relation") ||
    message.includes("does not exist") || message.includes("schema cache");
}

function shorten(value: unknown) {
  const text = cleanString(value);
  if (!text) return "";
  if (text.length <= 24) return text;
  return `${text.slice(0, 12)}...${text.slice(-8)}`;
}

function cleanAddressList(value: unknown) {
  if (!Array.isArray(value)) return [];
  return value.map((item) => cleanString(item)).filter(Boolean);
}

function detectType(row: any) {
  const sourceType = cleanString(row?.source_type).toLowerCase();
  if (["generated-seed", "address-list", "xpub", "zpub"].includes(sourceType)) {
    return sourceType;
  }

  const watchPublicKeyType = cleanString(row?.watch_public_key_type)
    .toLowerCase();
  const watchPublicKey = cleanString(row?.watch_public_key);
  const derivationPath = cleanString(row?.derivation_path).toLowerCase();

  if (
    watchPublicKeyType === "bitcoin-address-list" ||
    derivationPath === "imported-addresses"
  ) {
    return "address-list";
  }

  if (/^zpub/i.test(watchPublicKey)) return "zpub";
  if (/^xpub/i.test(watchPublicKey)) return "xpub";
  if (cleanString(row?.xpub)) return "generated-seed";
  if (cleanString(row?.zpub)) return "zpub";

  return "wallet";
}

function monitorTitle(type: string, isMostRecentGeneratedSeed: boolean) {
  if (isMostRecentGeneratedSeed) return "Most Recent Seed Generated";

  switch (type) {
    case "generated-seed":
      return "Generated Seed Monitor";
    case "address-list":
      return "Receive Address Monitor";
    case "xpub":
      return "XPub Monitor";
    case "zpub":
      return "ZPub Monitor";
    default:
      return "Wallet Activity Monitor";
  }
}

function monitorDetail(row: any, type: string) {
  const addresses = cleanAddressList(row?.addresses);
  const count = addresses.length;
  const addressLabel = count === 1 ? "address" : "addresses";

  if (type === "generated-seed") {
    return `${count} derived receive ${addressLabel}`;
  }

  if (type === "address-list") {
    const preview = shorten(addresses[0]);
    return preview
      ? `${count} receive ${addressLabel} (${preview})`
      : `${count} receive ${addressLabel}`;
  }

  const watchKey = cleanString(row?.watch_public_key || row?.zpub || row?.xpub);
  const preview = shorten(watchKey);
  if (preview) return preview;

  return `${count} receive ${addressLabel}`;
}

function formatMonitors(rows: any[]) {
  const generatedRows = rows
    .filter((row) => detectType(row) === "generated-seed")
    .sort((a, b) =>
      Date.parse(cleanString(b?.created_at)) -
      Date.parse(cleanString(a?.created_at))
    );
  const mostRecentGeneratedSeedId = cleanString(generatedRows[0]?.id);

  return rows
    .map((row) => {
      const type = detectType(row);
      const id = cleanString(row?.id);
      const isMostRecentGeneratedSeed =
        type === "generated-seed" && id === mostRecentGeneratedSeedId;

      return {
        id,
        type,
        title: monitorTitle(type, isMostRecentGeneratedSeed),
        detail: monitorDetail(row, type),
        active: row?.active === true,
        addressCount: cleanAddressList(row?.addresses).length,
        createdAt: cleanString(row?.created_at),
        isMostRecentGeneratedSeed,
      };
    })
    .sort((a, b) => {
      if (a.isMostRecentGeneratedSeed) return -1;
      if (b.isMostRecentGeneratedSeed) return 1;
      return Date.parse(b.createdAt) - Date.parse(a.createdAt);
    });
}

async function bestEffortDeleteFingerprints(supabase: any, monitorId: string) {
  const { error } = await supabase
    .from("decoy_watch_address_fingerprints")
    .delete()
    .eq("decoy_id", monitorId);

  if (error && !isMissingRelationError(error)) {
    console.warn(
      "Failed to delete archived monitor fingerprints:",
      error.message,
    );
  }
}

async function listForUser(supabase: any, userId: string) {
  const { data: walletRow, error: walletError } = await supabase
    .from("decoy_wallet")
    .select("decoy_seed_armed")
    .eq("user_id", userId)
    .limit(1)
    .maybeSingle();

  if (walletError) throw walletError;

  const { data: rows, error: decoysError } = await supabase
    .from("decoys")
    .select(
      "id, active, created_at, derivation_path, addresses, xpub, zpub, watch_public_key, watch_public_key_type, source_type, archived_at",
    )
    .eq("user_id", userId)
    .is("archived_at", null)
    .order("created_at", { ascending: false });

  if (decoysError) throw decoysError;

  return {
    ok: true,
    masterArmed: walletRow?.decoy_seed_armed === true,
    monitors: formatMonitors(rows || []),
  };
}

async function loadOwnedMonitorIds(
  supabase: any,
  userId: string,
  monitorIds: string[],
) {
  if (!monitorIds.length) return new Set<string>();

  const { data, error } = await supabase
    .from("decoys")
    .select("id")
    .eq("user_id", userId)
    .in("id", monitorIds)
    .is("archived_at", null);

  if (error) throw error;
  return new Set((data || []).map((row: any) => cleanString(row?.id)));
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

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const body = req.method === "GET" ? {} : await req.json();
    const action = cleanString(body.action || "list");

    if (action === "list") {
      return json(await listForUser(supabase, user.id));
    }

    if (action === "bulkSave") {
      const deleteMonitorIds = cleanStringArray(body.deleteMonitorIds);
      const deleted = new Set(deleteMonitorIds);
      const activeMonitorIds = cleanStringArray(body.activeMonitorIds)
        .filter((id) => !deleted.has(id));
      const inactiveMonitorIds = cleanStringArray(body.inactiveMonitorIds)
        .filter((id) => !deleted.has(id));
      const allMonitorIds = cleanStringArray([
        ...deleteMonitorIds,
        ...activeMonitorIds,
        ...inactiveMonitorIds,
      ]);

      const ownedIds = await loadOwnedMonitorIds(supabase, user.id, allMonitorIds);
      const missingIds = allMonitorIds.filter((id) => !ownedIds.has(id));
      if (missingIds.length) {
        return json({ ok: false, error: "Monitor not found" }, 404);
      }

      if (deleteMonitorIds.length) {
        const { error: archiveError } = await supabase
          .from("decoys")
          .update({
            active: false,
            archived_at: new Date().toISOString(),
          })
          .eq("user_id", user.id)
          .in("id", deleteMonitorIds)
          .is("archived_at", null);

        if (archiveError) {
          return json({ ok: false, error: archiveError.message }, 500);
        }

        for (const monitorId of deleteMonitorIds) {
          await bestEffortDeleteFingerprints(supabase, monitorId);
        }
      }

      if (activeMonitorIds.length) {
        const { error: activeError } = await supabase
          .from("decoys")
          .update({ active: true })
          .eq("user_id", user.id)
          .in("id", activeMonitorIds)
          .is("archived_at", null);

        if (activeError) {
          return json({ ok: false, error: activeError.message }, 500);
        }
      }

      if (inactiveMonitorIds.length) {
        const { error: inactiveError } = await supabase
          .from("decoys")
          .update({ active: false })
          .eq("user_id", user.id)
          .in("id", inactiveMonitorIds)
          .is("archived_at", null);

        if (inactiveError) {
          return json({ ok: false, error: inactiveError.message }, 500);
        }
      }

      return json(await listForUser(supabase, user.id));
    }

    const monitorId = cleanString(body.monitorId || body.decoyId || body.id);
    if (!monitorId) {
      return json({ ok: false, error: "Missing monitor id" }, 400);
    }

    const { data: existing, error: existingError } = await supabase
      .from("decoys")
      .select("id")
      .eq("user_id", user.id)
      .eq("id", monitorId)
      .is("archived_at", null)
      .maybeSingle();

    if (existingError) {
      return json({ ok: false, error: existingError.message }, 500);
    }

    if (!existing) {
      return json({ ok: false, error: "Monitor not found" }, 404);
    }

    if (action === "setActive") {
      const { error: updateError } = await supabase
        .from("decoys")
        .update({ active: asBoolean(body.active) })
        .eq("user_id", user.id)
        .eq("id", monitorId)
        .is("archived_at", null);

      if (updateError) {
        return json({ ok: false, error: updateError.message }, 500);
      }

      return json(await listForUser(supabase, user.id));
    }

    if (action === "delete") {
      const { error: archiveError } = await supabase
        .from("decoys")
        .update({
          active: false,
          archived_at: new Date().toISOString(),
        })
        .eq("user_id", user.id)
        .eq("id", monitorId)
        .is("archived_at", null);

      if (archiveError) {
        return json({ ok: false, error: archiveError.message }, 500);
      }

      await bestEffortDeleteFingerprints(supabase, monitorId);
      return json(await listForUser(supabase, user.id));
    }

    return json({ ok: false, error: "Unsupported monitor action" }, 400);
  } catch (err) {
    return json({ ok: false, error: String(err) }, 500);
  }
});
