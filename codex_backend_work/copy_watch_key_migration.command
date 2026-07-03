#!/bin/zsh
set -euo pipefail

REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android"
MIGRATION="$REPO/supabase/migrations/20260625232500_add_decoy_watch_public_key.sql"
UTXO_MIGRATION="$REPO/supabase/migrations/20260703122000_add_decoy_seed_utxo_state.sql"

if ! command -v pbcopy >/dev/null 2>&1; then
  echo "pbcopy is not available on this machine."
  exit 127
fi

for file in "$MIGRATION" "$UTXO_MIGRATION"; do
if [[ ! -f "$file" ]]; then
  echo "Migration file was not found:"
  echo "$file"
  exit 1
fi
done

{
  cat "$MIGRATION"
  echo ""
  cat "$UTXO_MIGRATION"
} | pbcopy
echo "Copied the additive Decoy Seed watch-key + UTXO state migration SQL to the clipboard."
echo "Paste it into the Supabase SQL editor and run it once."
