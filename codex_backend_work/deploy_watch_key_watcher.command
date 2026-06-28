#!/bin/zsh
set -euo pipefail

GCLOUD="/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud"
NODE="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node"
CLOUDSDK_PYTHON_BIN="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3"
REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android"
PROJECT="decoywallet-a283b"
REGION="us-central1"
SERVICE="decoy-watcher"
SOURCE_DIR="$REPO/codex_backend_work/decoy-watcher-source/src"

echo "Deploying Decoy Seed watcher."
echo "This updates only the decoy-watcher Cloud Run service."
echo "Run this only after backend schema changes needed by this watcher are deployed."
echo ""

if [[ ! -x "$GCLOUD" ]]; then
  echo "gcloud was not found at:"
  echo "$GCLOUD"
  exit 127
fi

if [[ ! -x "$NODE" ]]; then
  echo "Node was not found at:"
  echo "$NODE"
  exit 127
fi

if [[ -x "$CLOUDSDK_PYTHON_BIN" ]]; then
  export CLOUDSDK_PYTHON="$CLOUDSDK_PYTHON_BIN"
fi

if [[ ! -f "$SOURCE_DIR/index.js" ]]; then
  echo "Watcher source was not found:"
  echo "$SOURCE_DIR/index.js"
  exit 1
fi

echo "Checking watcher JavaScript syntax..."
"$NODE" --check "$SOURCE_DIR/index.js"

echo ""
echo "Type deploy-watch-key-watcher to continue."
read -r "CONFIRM?Confirmation: "
if [[ "$CONFIRM" != "deploy-watch-key-watcher" ]]; then
  echo "Confirmation did not match. Nothing changed."
  exit 1
fi

previous_revision="$("$GCLOUD" run services describe "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --format='value(status.traffic[0].revisionName)' 2>/dev/null || true)"

echo "Previous serving revision: ${previous_revision:-unknown}"
echo "Deploying watcher source..."

"$GCLOUD" run deploy "$SERVICE" \
  --source "$SOURCE_DIR" \
  --project "$PROJECT" \
  --region "$REGION" \
  --quiet

target_revision="$("$GCLOUD" run services describe "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --format='value(status.latestCreatedRevisionName)' 2>/dev/null || true)"

if [[ -z "$target_revision" ]]; then
  echo "Could not determine the new revision. Paste this output back into Codex."
  exit 2
fi

echo "Routing traffic to new revision: $target_revision"
"$GCLOUD" run services update-traffic "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --to-revisions "$target_revision=100" \
  --quiet

serving_revision="$("$GCLOUD" run services describe "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --format='value(status.traffic[0].revisionName)' 2>/dev/null || true)"

echo "Serving revision after update: ${serving_revision:-unknown}"

if [[ -n "$previous_revision" && "$previous_revision" != "$serving_revision" ]]; then
  echo ""
  echo "Rollback command if needed:"
  echo "$GCLOUD run services update-traffic $SERVICE --project $PROJECT --region $REGION --to-revisions $previous_revision=100"
fi

echo ""
echo "Done. Next: confirm WATCHER_HEALTH_OK in Cloud Run logs."
