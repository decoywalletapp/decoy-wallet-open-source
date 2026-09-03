#!/bin/zsh
set -euo pipefail

REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android"
PNPM="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/pnpm"
NODE_BIN="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin"
PROJECT_REF="vxmrthyumzrfgtuvjqmr"
TOKEN_FILE="/private/tmp/supabase_token.txt"
MIGRATION="$REPO/supabase/migrations/20260903223500_add_watch_address_fingerprint_shadow.sql"

echo "Applying Decoy watch-address fingerprint shadow migration."
echo "This creates only the additive shadow table for HMAC address fingerprints."
echo "It does not modify existing decoy rows, alert rows, or SMS behavior."
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

if [[ ! -f "$MIGRATION" ]]; then
  echo "Migration file was not found:"
  echo "$MIGRATION"
  exit 1
fi

echo "Type apply-watch-address-fingerprint-shadow to continue."
read -r "CONFIRM?Confirmation: "
if [[ "$CONFIRM" != "apply-watch-address-fingerprint-shadow" ]]; then
  echo "Confirmation did not match. Nothing changed."
  exit 1
fi

token="$(tr -d '\r\n' < "$TOKEN_FILE")"
if [[ "$token" != sbp_* ]]; then
  echo "Token file does not look like a Supabase access token."
  exit 1
fi

cd "$REPO"

echo "Linking Supabase project through the CLI..."
env \
  HOME=/private/tmp \
  PNPM_HOME=/private/tmp/pnpm \
  npm_config_cache=/private/tmp/npm-cache \
  PATH="$NODE_BIN:$PATH" \
  SUPABASE_ACCESS_TOKEN="$token" \
  "$PNPM" dlx supabase link \
    --project-ref "$PROJECT_REF" \
    --workdir "$REPO/supabase"

echo ""
echo "Applying additive migration SQL..."
env \
  HOME=/private/tmp \
  PNPM_HOME=/private/tmp/pnpm \
  npm_config_cache=/private/tmp/npm-cache \
  PATH="$NODE_BIN:$PATH" \
  SUPABASE_ACCESS_TOKEN="$token" \
  "$PNPM" dlx supabase db query \
    --linked \
    --file "$MIGRATION" \
    --workdir "$REPO/supabase"

echo ""
echo "Verifying shadow table exists..."
env \
  HOME=/private/tmp \
  PNPM_HOME=/private/tmp/pnpm \
  npm_config_cache=/private/tmp/npm-cache \
  PATH="$NODE_BIN:$PATH" \
  SUPABASE_ACCESS_TOKEN="$token" \
  "$PNPM" dlx supabase db query \
    --linked \
    "select to_regclass('public.decoy_watch_address_fingerprints') as decoy_watch_address_fingerprints;" \
    --workdir "$REPO/supabase"

echo ""
echo "Migration finished."
