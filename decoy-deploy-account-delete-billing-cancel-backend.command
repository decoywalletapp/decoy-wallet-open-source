#!/bin/zsh
set -euo pipefail

GCLOUD="/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud"
CLOUDSDK_PYTHON_BIN="/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3.12"
REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app"
SOURCE_DIR="$REPO/codex_backend_work/decoy-stripe-webhook-live"
INDEX_FILE="$SOURCE_DIR/index.js"
PROJECT="decoywallet-a283b"
REGION="us-central1"
SERVICE="decoy-stripe-webhook-live"
HEALTH_URL="https://decoy-stripe-webhook-live-866378207353.us-central1.run.app/health"
EXPECTED_VERSION="account-delete-billing-cancel-v1"
DEPLOY_MARKER="account-delete-billing-cancel-$(date -u +%Y%m%d%H%M%S)"
REVISION_SUFFIX="adbc$(date -u +%H%M%S)"
IMAGE="us-central1-docker.pkg.dev/$PROJECT/cloud-run-source-deploy/$SERVICE:$DEPLOY_MARKER"

echo "Deploying Decoy Wallet account-delete billing cancellation backend..."
echo "This only changes the Stripe/payment Cloud Run service."
echo "It does not touch emergency alerts, Supabase alert triggers, CodeMagic, signing, or UI."

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

if ! grep -q "$EXPECTED_VERSION" "$INDEX_FILE"; then
  echo "Payment backend source does not include the expected account-delete billing fix marker."
  echo "Expected marker: $EXPECTED_VERSION"
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
echo "Image: $IMAGE"

"$GCLOUD" builds submit "$SOURCE_DIR" \
  --project "$PROJECT" \
  --tag "$IMAGE"

"$GCLOUD" run deploy "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --image "$IMAGE" \
  --allow-unauthenticated \
  --revision-suffix "$REVISION_SUFFIX" \
  --update-env-vars "CODEX_DEPLOY_MARKER=$DEPLOY_MARKER"

target_revision="$("$GCLOUD" run services describe "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --format='value(status.latestCreatedRevisionName)' 2>/dev/null || true)"

if [[ -z "$target_revision" ]]; then
  echo "Could not determine the latest created revision."
  echo "Paste this output back into Codex."
  exit 6
fi

echo "Routing traffic to: $target_revision"
"$GCLOUD" run services update-traffic "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --to-revisions "$target_revision=100"

serving_revision="$("$GCLOUD" run services describe "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --format='value(status.traffic[0].revisionName)' 2>/dev/null || true)"

echo "Serving revision after deploy: ${serving_revision:-unknown}"

health_status="$(curl -sS -o /tmp/decoy-payment-delete-account-health.txt -w '%{http_code}' "$HEALTH_URL" || true)"
health_body="$(cat /tmp/decoy-payment-delete-account-health.txt 2>/dev/null || true)"
echo "health_http_status=$health_status"
echo "$health_body"

if [[ "$health_body" != *"$EXPECTED_VERSION"* ]]; then
  echo ""
  echo "Payment backend did not report the account-delete billing fix."
  echo "Do not test account deletion yet. Paste this output back into Codex."
  exit 8
fi

if [[ -n "$previous_revision" && "$previous_revision" != "$serving_revision" ]]; then
  echo "Rollback command if needed:"
  echo "$GCLOUD run services update-traffic $SERVICE --project $PROJECT --region $REGION --to-revisions $previous_revision=100"
fi

echo ""
echo "Done. Account-delete billing cancellation backend is live."
