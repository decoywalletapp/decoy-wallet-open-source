#!/bin/zsh
set -euo pipefail

REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android"
PNPM="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/pnpm"
NODE_BIN="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin"
PROJECT_REF="vxmrthyumzrfgtuvjqmr"
TOKEN_FILE="/private/tmp/supabase_token.txt"

echo "Deploying Supabase function: commit-decoy"
echo "This reads the Supabase access token from a temporary local file."
echo "It does not print the token."
echo ""

if [[ ! -f "$TOKEN_FILE" ]]; then
  echo "Token file was not found:"
  echo "$TOKEN_FILE"
  exit 1
fi

if [[ ! -x "$PNPM" ]]; then
  echo "pnpm was not found at:"
  echo "$PNPM"
  exit 127
fi

token="$(tr -d '\r\n' < "$TOKEN_FILE")"
if [[ "$token" != sbp_* ]]; then
  echo "Token file does not look like a Supabase access token."
  exit 1
fi

cd "$REPO"

env \
  HOME=/private/tmp \
  PNPM_HOME=/private/tmp/pnpm \
  npm_config_cache=/private/tmp/npm-cache \
  PATH="$NODE_BIN:$PATH" \
  SUPABASE_ACCESS_TOKEN="$token" \
  "$PNPM" dlx supabase functions deploy commit-decoy \
    --project-ref "$PROJECT_REF" \
    --use-api

echo ""
echo "commit-decoy deploy finished."
