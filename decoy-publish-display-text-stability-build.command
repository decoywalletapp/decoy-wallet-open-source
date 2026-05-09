#!/bin/zsh
set -euo pipefail

REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app"
REMOTE_BRANCH="codex/entitlement-safety-hardening-20260506"
APP_ID="68be1d76dd3750a73de074ad"
WORKFLOW_ID="ios_release"

cd "$REPO"

echo "Publishing Decoy Wallet display text stability update..."
echo "Repository: $REPO"
echo "Current branch: $(git branch --show-current)"
echo "Starting commit: $(git rev-parse HEAD)"
echo "This is app-only display/layout hardening."
echo "It does not touch emergency alerts, payments, entitlements, backend code, signing, or CodeMagic config."

git diff --check -- \
  codex_release_readiness_checklist.md \
  lib/main.dart \
  decoy-publish-display-text-stability-build.command

git add \
  codex_release_readiness_checklist.md \
  lib/main.dart \
  decoy-publish-display-text-stability-build.command

if git diff --cached --quiet; then
  echo "No staged display-stability changes found; using existing HEAD."
else
  git commit -m "fix: stabilize app text scaling"
fi

HEAD_SHA="$(git rev-parse HEAD)"
echo "Mobile commit: $HEAD_SHA"

GITHUB_TOKEN_VALUE="${GITHUB_TOKEN:-}"
GITHUB_TOKEN_SOURCE="environment"

if [[ -z "$GITHUB_TOKEN_VALUE" ]]; then
  GITHUB_TOKEN_SOURCE="keychain"
  for service in github-api-token github-token github_pat GITHUB_TOKEN GITHUB_API_TOKEN github-session-token decoy-github-token decoywallet-github-token; do
    GITHUB_TOKEN_VALUE="$(security find-generic-password -s "$service" -w 2>/dev/null || true)"
    if [[ -n "$GITHUB_TOKEN_VALUE" ]]; then
      break
    fi
  done
fi

if [[ -z "$GITHUB_TOKEN_VALUE" ]]; then
  CLIPBOARD_VALUE="$(pbpaste 2>/dev/null || true)"
  case "$CLIPBOARD_VALUE" in
    github_pat_*|ghp_*)
      GITHUB_TOKEN_VALUE="$CLIPBOARD_VALUE"
      GITHUB_TOKEN_SOURCE="clipboard"
      echo "Using GitHub token from clipboard."
      ;;
  esac
fi

if [[ -z "$GITHUB_TOKEN_VALUE" ]]; then
  GITHUB_TOKEN_SOURCE="prompt"
  echo ""
  echo "GitHub command-line pushes use a token, not your normal website password."
  echo "Paste a GitHub token with access to decoywalletapp/mobile-app."
  read -rs "GITHUB_TOKEN_VALUE?GitHub token (hidden): "
  echo ""
fi

case "$GITHUB_TOKEN_VALUE" in
  github_pat_*|ghp_*) ;;
  *)
    echo "That did not look like a GitHub personal access token."
    echo "Expected it to start with github_pat_ or ghp_."
    echo "The local commit is still safe: $HEAD_SHA"
    exit 3
    ;;
esac

if [[ "$GITHUB_TOKEN_SOURCE" == "clipboard" || "$GITHUB_TOKEN_SOURCE" == "prompt" ]]; then
  security add-generic-password \
    -U \
    -s github-api-token \
    -a decoywalletapp \
    -w "$GITHUB_TOKEN_VALUE" >/dev/null 2>&1 || true
fi

AUTH_HEADER="Authorization: Basic $(printf 'x-access-token:%s' "$GITHUB_TOKEN_VALUE" | base64 | tr -d '\n')"

echo "Pushing to GitHub branch: $REMOTE_BRANCH"
git -c http.https://github.com/.extraheader="$AUTH_HEADER" push -u origin "HEAD:refs/heads/$REMOTE_BRANCH"
unset AUTH_HEADER GITHUB_TOKEN_VALUE CLIPBOARD_VALUE

CODEMAGIC_TOKEN_VALUE="${CODEMAGIC_TOKEN:-}"
CODEMAGIC_TOKEN_SOURCE="environment"

if [[ -z "$CODEMAGIC_TOKEN_VALUE" ]]; then
  CODEMAGIC_TOKEN_SOURCE="keychain"
  for service in codemagic-api-token codemagic-token codemagic_token CODEMAGIC_TOKEN CODEMAGIC_API_TOKEN codemagic-session-token; do
    CODEMAGIC_TOKEN_VALUE="$(security find-generic-password -s "$service" -w 2>/dev/null || true)"
    if [[ -n "$CODEMAGIC_TOKEN_VALUE" ]]; then
      break
    fi
  done
fi

if [[ -z "$CODEMAGIC_TOKEN_VALUE" ]]; then
  CLIPBOARD_VALUE="$(pbpaste 2>/dev/null || true)"
  case "$CLIPBOARD_VALUE" in
    github_pat_*|ghp_*) ;;
    *)
      if [[ -n "$CLIPBOARD_VALUE" ]]; then
        CODEMAGIC_TOKEN_VALUE="$CLIPBOARD_VALUE"
        CODEMAGIC_TOKEN_SOURCE="clipboard"
        echo "Using CodeMagic token from clipboard."
      fi
      ;;
  esac
fi

if [[ -z "$CODEMAGIC_TOKEN_VALUE" ]]; then
  CODEMAGIC_TOKEN_SOURCE="prompt"
  echo ""
  echo "CodeMagic needs an API token to start the TestFlight build."
  read -rs "CODEMAGIC_TOKEN_VALUE?CodeMagic token (hidden): "
  echo ""
fi

if [[ -z "$CODEMAGIC_TOKEN_VALUE" ]]; then
  echo "CodeMagic token was empty."
  echo "The GitHub push succeeded, but the build was not started."
  echo "Paste this output back into Codex."
  exit 2
fi

if [[ "$CODEMAGIC_TOKEN_SOURCE" == "clipboard" || "$CODEMAGIC_TOKEN_SOURCE" == "prompt" ]]; then
  security add-generic-password \
    -U \
    -s codemagic-api-token \
    -a decoywalletapp \
    -w "$CODEMAGIC_TOKEN_VALUE" >/dev/null 2>&1 || true
fi

echo "Starting CodeMagic iOS Release build..."
/usr/bin/python3 - "$CODEMAGIC_TOKEN_VALUE" "$APP_ID" "$WORKFLOW_ID" "$REMOTE_BRANCH" <<'PY'
import json
import sys
import urllib.request
import urllib.error

token, app_id, workflow_id, branch = sys.argv[1:5]
payload = json.dumps({
    "appId": app_id,
    "workflowId": workflow_id,
    "branch": branch,
}).encode("utf-8")

req = urllib.request.Request(
    "https://api.codemagic.io/builds",
    data=payload,
    headers={
        "Content-Type": "application/json",
        "x-auth-token": token,
    },
    method="POST",
)

try:
    with urllib.request.urlopen(req, timeout=30) as resp:
        body = resp.read().decode("utf-8", "replace")
        status = resp.status
except urllib.error.HTTPError as exc:
    body = exc.read().decode("utf-8", "replace")
    status = exc.code

print(f"codemagic_build_start_http_status={status}")
try:
    data = json.loads(body or "{}")
except Exception:
    data = {"raw": body}
print(data)
build_id = data.get("buildId") or data.get("_id") or data.get("id")
if build_id:
    print(f"BUILD_ID={build_id}")
    print(f"BUILD_URL=https://codemagic.io/app/{app_id}/build/{build_id}")
if status < 200 or status >= 300:
    sys.exit(1)
PY

echo "Done. Display text stability TestFlight build started."
echo "Next: install TestFlight, then test with iOS Bold Text and larger Text Size enabled."
