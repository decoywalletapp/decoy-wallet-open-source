const STAGING_PROJECT_REF = "dxsihfandgbrkreeokkm";
const STAGING_SUPABASE_HOST = `${STAGING_PROJECT_REF}.supabase.co`;
const DEFAULT_DEEP_LINK = "decoywalletapp://confirm-email";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function assertStagingProject() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  if (supabaseUrl && !supabaseUrl.includes(STAGING_SUPABASE_HOST)) {
    throw new Error("verify-link is staging-only");
  }
}

function mergedAuthParams(url: URL): URLSearchParams {
  const params = new URLSearchParams(url.searchParams);
  const fragment = url.hash.startsWith("#") ? url.hash.slice(1) : url.hash;

  if (fragment) {
    const cleanFragment = fragment.startsWith("?")
      ? fragment.slice(1)
      : fragment;
    const fragmentParams = new URLSearchParams(cleanFragment);
    fragmentParams.forEach((value, key) => params.set(key, value));
  }

  params.delete("redirect_to");
  params.delete("redirectTo");
  return params;
}

function redirectToApp(requestUrl: string): string {
  const incoming = new URL(requestUrl);
  const deepLinkBase = Deno.env.get("DECOY_EMAIL_CONFIRM_DEEP_LINK")?.trim() ??
    DEFAULT_DEEP_LINK;
  const deepLink = new URL(deepLinkBase || DEFAULT_DEEP_LINK);
  const params = mergedAuthParams(incoming);

  params.forEach((value, key) => deepLink.searchParams.set(key, value));
  return deepLink.toString();
}

Deno.serve((req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "GET") {
    return new Response("Method not allowed", {
      status: 405,
      headers: corsHeaders,
    });
  }

  try {
    assertStagingProject();
    const location = redirectToApp(req.url);
    const safeLocation = escapeHtml(location);

    return new Response(
      `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta http-equiv="refresh" content="0; url=${safeLocation}">
  <title>Opening Decoy Wallet</title>
</head>
<body>
  <p>Opening Decoy Wallet...</p>
  <p><a href="${safeLocation}">Tap here if Decoy Wallet does not open automatically.</a></p>
  <script>window.location.replace(${JSON.stringify(location)});</script>
</body>
</html>`,
      {
        status: 302,
        headers: {
          ...corsHeaders,
          "Cache-Control": "no-store",
          "Content-Type": "text/html; charset=utf-8",
          Location: location,
        },
      },
    );
  } catch (_) {
    return new Response("Staging email verification link is not configured.", {
      status: 500,
      headers: {
        ...corsHeaders,
        "Cache-Control": "no-store",
        "Content-Type": "text/plain; charset=utf-8",
      },
    });
  }
});
