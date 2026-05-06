#!/bin/zsh
set -euo pipefail

GCLOUD="/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud"
CLOUDSDK_PYTHON_BIN="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3.12"
REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app"
SOURCE_DIR="$REPO/codex_backend_work/decoy-stripe-webhook-live"
INDEX_FILE="$SOURCE_DIR/index.js"
EXPECTED_SHA="74ee187339c7d25239cfb607d16d031f12be1db10de078c0b736812ef7fc2ea1"
PROJECT="decoywallet-a283b"
REGION="us-central1"
SERVICE="decoy-stripe-webhook-live"
HEALTH_URL="https://decoy-stripe-webhook-live-866378207353.us-central1.run.app/health"

echo "Deploying payment backend entitlement-safety hardening..."

if [[ ! -x "$GCLOUD" ]]; then
  echo "gcloud was not found at the expected bundled path:"
  echo "$GCLOUD"
  echo "Paste this output back into Codex."
  exit 127
fi

if [[ -x "$CLOUDSDK_PYTHON_BIN" ]]; then
  export CLOUDSDK_PYTHON="$CLOUDSDK_PYTHON_BIN"
else
  echo "Modern Python for gcloud was not found at:"
  echo "$CLOUDSDK_PYTHON_BIN"
  echo "Paste this output back into Codex."
  exit 127
fi

if [[ ! -f "$INDEX_FILE" ]]; then
  echo "Payment backend source was not found:"
  echo "$INDEX_FILE"
  echo "Paste this output back into Codex."
  exit 1
fi

actual_sha="$(shasum -a 256 "$INDEX_FILE" | awk '{print $1}')"
if [[ "$actual_sha" != "$EXPECTED_SHA" ]]; then
  echo "Payment backend source checksum mismatch. Aborting."
  echo "expected: $EXPECTED_SHA"
  echo "actual:   $actual_sha"
  echo "Paste this output back into Codex."
  exit 1
fi

active_account="$("$GCLOUD" auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | head -n 1 || true)"
if [[ -z "$active_account" ]]; then
  echo "No active Google Cloud account is selected."
  echo "Starting Google Cloud login now. Approve it in the browser if one opens."
  "$GCLOUD" auth login --update-adc
  active_account="$("$GCLOUD" auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "$active_account" ]]; then
  echo "Google Cloud login did not finish, so nothing was deployed."
  echo "Paste this output back into Codex."
  exit 4
fi

echo "Using Google Cloud account: $active_account"
"$GCLOUD" config set project "$PROJECT" >/dev/null

previous_revision="$("$GCLOUD" run services describe "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --format='value(status.traffic[0].revisionName)' 2>/dev/null || true)"

echo "Previous serving revision: ${previous_revision:-unknown}"

"$GCLOUD" run deploy "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --source "$SOURCE_DIR" \
  --allow-unauthenticated

new_revision="$("$GCLOUD" run services describe "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --format='value(status.latestReadyRevisionName)' 2>/dev/null || true)"

echo "New ready revision: ${new_revision:-unknown}"

health_status="$(curl -sS -o /tmp/decoy-payment-backend-health.txt -w '%{http_code}' "$HEALTH_URL" || true)"
echo "health_http_status=$health_status"
cat /tmp/decoy-payment-backend-health.txt 2>/dev/null || true
echo

if [[ -n "$previous_revision" ]]; then
  echo "Rollback command if needed:"
  echo "$GCLOUD run services update-traffic $SERVICE --project $PROJECT --region $REGION --to-revisions $previous_revision=100"
fi

echo "Done. Payment backend entitlement-safety hardening deployed."
echo "Now test: BTC-active user taps card switch, abandons checkout, and returns to the app."
