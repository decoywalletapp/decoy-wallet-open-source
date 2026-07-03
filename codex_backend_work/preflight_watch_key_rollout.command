#!/bin/zsh
set -euo pipefail

REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android"
NODE="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node"
DART="/Users/mitchellwleblanc/dev/flutter/bin/cache/dart-sdk/bin/dart"

WATCHER="$REPO/codex_backend_work/decoy-watcher-source/src/index.js"
MIGRATION="$REPO/supabase/migrations/20260625232500_add_decoy_watch_public_key.sql"
UTXO_MIGRATION="$REPO/supabase/migrations/20260703122000_add_decoy_seed_utxo_state.sql"
COMMIT_DECOY="$REPO/supabase/functions/commit-decoy/index.ts"

echo "Running Decoy Seed watch-key rollout preflight."
echo "This does not deploy anything or touch production."
echo ""

if [[ ! -x "$NODE" ]]; then
  echo "Node was not found at:"
  echo "$NODE"
  exit 127
fi

if [[ ! -x "$DART" ]]; then
  echo "Dart was not found at:"
  echo "$DART"
  exit 127
fi

for file in "$WATCHER" "$MIGRATION" "$UTXO_MIGRATION" "$COMMIT_DECOY"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required rollout file:"
    echo "$file"
    exit 1
  fi
done

echo "Checking watcher JavaScript syntax..."
"$NODE" --check "$WATCHER"

echo "Checking Dart formatting for watch-key Android changes..."
env HOME=/private/tmp DART_SUPPRESS_ANALYTICS=true "$DART" format \
  --output=none \
  --set-exit-if-changed \
  "$REPO/lib/custom_code/actions/generate_decoy_draft.dart" \
  "$REPO/lib/app_state.dart" \
  "$REPO/lib/create_decoy_seed/generate_decoy_seed_phrase/generate_decoy_seed_phrase_widget.dart" \
  "$REPO/lib/backend/api_requests/api_calls.dart" \
  "$REPO/lib/create_decoy_seed/decoy_seed_system_values/decoy_seed_system_values_widget.dart" \
  "$REPO/lib/backend/supabase/database/tables/armed_decoy_seeds.dart" \
  "$REPO/lib/backend/supabase/database/tables/decoys.dart"

echo ""
echo "Preflight OK."
echo "Next safe order: Supabase migrations, commit-decoy function, Android build, watcher deploy."
