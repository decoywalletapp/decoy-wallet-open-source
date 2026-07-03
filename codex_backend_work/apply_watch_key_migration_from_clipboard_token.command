#!/bin/zsh
set -euo pipefail

REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android"
PNPM="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/pnpm"
NODE_BIN="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin"
PROJECT_REF="vxmrthyumzrfgtuvjqmr"
MIGRATION="$REPO/supabase/migrations/20260625232500_add_decoy_watch_public_key.sql"
UTXO_MIGRATION="$REPO/supabase/migrations/20260703122000_add_decoy_seed_utxo_state.sql"
COMBINED="/private/tmp/decoy_watch_key_utxo_migration.sql"

echo "Applying Decoy Seed watch-key + UTXO state migration."
echo "This reads a Supabase access token from the clipboard for this run only."
echo "It does not print or save the token."
echo ""

if ! command -v pbpaste >/dev/null 2>&1; then
  echo "pbpaste is not available on this machine."
  exit 127
fi

if [[ ! -x "$PNPM" ]]; then
  echo "pnpm was not found at:"
  echo "$PNPM"
  exit 127
fi

for file in "$MIGRATION" "$UTXO_MIGRATION"; do
  if [[ ! -f "$file" ]]; then
    echo "Migration file was not found:"
    echo "$file"
    exit 1
  fi
done

token="$(pbpaste | tr -d '\r\n')"
if [[ "$token" != sbp_* ]]; then
  echo "Clipboard does not look like a Supabase access token."
  echo "Copy a fresh sbp_... token, then run this again."
  exit 1
fi

{
  cat "$MIGRATION"
  echo ""
  cat "$UTXO_MIGRATION"
} > "$COMBINED"

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
    --file "$COMBINED" \
    --workdir "$REPO/supabase"

echo ""
echo "Verifying UTXO state table exists..."
env \
  HOME=/private/tmp \
  PNPM_HOME=/private/tmp/pnpm \
  npm_config_cache=/private/tmp/npm-cache \
  PATH="$NODE_BIN:$PATH" \
  SUPABASE_ACCESS_TOKEN="$token" \
  "$PNPM" dlx supabase db query \
    --linked \
    "select to_regclass('public.decoy_seed_utxo_state') as decoy_seed_utxo_state;" \
    --workdir "$REPO/supabase"

echo ""
echo "Migration finished."
