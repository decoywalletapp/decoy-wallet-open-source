const STAGING_PROJECT_REF = "dxsihfandgbrkreeokkm";
const STAGING_SUPABASE_HOST = `${STAGING_PROJECT_REF}.supabase.co`;
const DEFAULT_DEEP_LINK = "decoywalletapp://confirm-email";
const STRIPPED_PARAMS = new Set(["redirect_to", "redirectTo"]);

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

  for (const key of STRIPPED_PARAMS) {
    params.delete(key);
  }
  return params;
}

function deepLinkBase(): string {
  return Deno.env.get("DECOY_EMAIL_CONFIRM_DEEP_LINK")?.trim() ??
    DEFAULT_DEEP_LINK;
}

function redirectToApp(requestUrl: string): string {
  const incoming = new URL(requestUrl);
  const deepLink = new URL(deepLinkBase() || DEFAULT_DEEP_LINK);
  const params = mergedAuthParams(incoming);

  params.forEach((value, key) => deepLink.searchParams.set(key, value));
  return deepLink.toString();
}

function bridgeHtml(requestUrl: string): string {
  const serverLocation = redirectToApp(requestUrl);
  const safeLocation = escapeHtml(serverLocation);

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Opening Decoy Wallet</title>
</head>
<body>
  <p>Opening Decoy Wallet...</p>
  <p><a id="open-link" href="${safeLocation}">Tap here if Decoy Wallet does not open automatically.</a></p>
  <script>
    (function () {
      const strippedParams = new Set(${JSON.stringify([...STRIPPED_PARAMS])});
      const fallbackLocation = ${JSON.stringify(serverLocation)};
      const target = new URL(${JSON.stringify(deepLinkBase() || DEFAULT_DEEP_LINK)});

      function copyParams(params) {
        params.forEach(function (value, key) {
          if (!strippedParams.has(key)) {
            target.searchParams.set(key, value);
          }
        });
      }

      try {
        const current = new URL(window.location.href);
        copyParams(current.searchParams);

        const fragment = window.location.hash.startsWith('#')
          ? window.location.hash.slice(1)
          : window.location.hash;
        if (fragment) {
          const cleanFragment = fragment.startsWith('?')
            ? fragment.slice(1)
            : fragment;
          copyParams(new URLSearchParams(cleanFragment));
        }

        const destination = target.toString();
        document.getElementById('open-link').setAttribute('href', destination);
        window.location.replace(destination);
      } catch (_error) {
        document.getElementById('open-link').setAttribute('href', fallbackLocation);
        window.location.replace(fallbackLocation);
      }
    })();
  </script>
</body>
</html>`;
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

    return new Response(bridgeHtml(req.url), {
      status: 200,
      headers: {
        ...corsHeaders,
        "Cache-Control": "no-store",
        "Content-Type": "text/html; charset=utf-8",
      },
    });
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
