#!/bin/zsh
set -euo pipefail

if [[ "${CONFIRM_REDEMPTION_PRODUCTION_CANARY:-}" != "YES" ]]; then
  echo "Refusing to configure production canary without confirmation"
  exit 2
fi

GCLOUD="${GCLOUD:-/opt/homebrew/bin/gcloud}"
NODE="${NODE:-/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node}"
PROJECT="${PROJECT:-decoywallet-a283b}"
REGION="${REGION:-us-central1}"
SOURCE_SERVICE="${SOURCE_SERVICE:-decoy-stripe-webhook-live}"
CANARY_SERVICE="${CANARY_SERVICE:-decoy-redemption-canary}"
SOURCE_DIR="${SOURCE_DIR:-/private/tmp/decoy-redemption-production-candidate/payment}"
PROJECT_NUMBER="${PROJECT_NUMBER:-866378207353}"
SCRIPT_DIR="${0:A:h}"
SERVICE_JSON="$(mktemp /private/tmp/decoy-production-service.XXXXXX.json)"
ENV_JSON="$(mktemp /private/tmp/decoy-canary-env.XXXXXX.json)"
trap 'rm -f "$SERVICE_JSON" "$ENV_JSON"' EXIT
chmod 600 "$SERVICE_JSON" "$ENV_JSON"

"$GCLOUD" run services describe "$SOURCE_SERVICE" \
  --project "$PROJECT" --region "$REGION" --format=json > "$SERVICE_JSON"

coupon_id="$(PRODUCTION_SERVICE_JSON="$SERVICE_JSON" \
  "$NODE" "$SCRIPT_DIR/setup_production_assets.mjs")"

put_secret() {
  local name="$1"
  local value="$2"
  if "$GCLOUD" secrets describe "$name" --project "$PROJECT" >/dev/null 2>&1; then
    printf %s "$value" | "$GCLOUD" secrets versions add "$name" \
      --project "$PROJECT" --data-file=- >/dev/null
  else
    printf %s "$value" | "$GCLOUD" secrets create "$name" \
      --project "$PROJECT" --replication-policy=automatic --data-file=- >/dev/null
  fi
}

if ! "$GCLOUD" secrets describe decoy-redemption-production-code-pepper \
    --project "$PROJECT" >/dev/null 2>&1; then
  put_secret decoy-redemption-production-code-pepper "$(openssl rand -hex 32)"
fi
if ! "$GCLOUD" secrets describe decoy-redemption-production-session-pepper \
    --project "$PROJECT" >/dev/null 2>&1; then
  put_secret decoy-redemption-production-session-pepper "$(openssl rand -hex 32)"
fi
put_secret decoy-redemption-production-stripe-coupon-id "$coupon_id"

public_url="https://$CANARY_SERVICE-$PROJECT_NUMBER.$REGION.run.app"
"$NODE" "$SCRIPT_DIR/write_canary_env.mjs" \
  "$SERVICE_JSON" "$ENV_JSON" "$public_url"

"$GCLOUD" run deploy "$CANARY_SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --source "$SOURCE_DIR" \
  --allow-unauthenticated \
  --env-vars-file "$ENV_JSON" \
  --set-secrets "MEMBERSHIP_CODE_PEPPER=decoy-redemption-production-code-pepper:latest,REDEMPTION_SESSION_PEPPER=decoy-redemption-production-session-pepper:latest,STRIPE_PROMO_100_COUPON_ID=decoy-redemption-production-stripe-coupon-id:latest"

service_url="$("$GCLOUD" run services describe "$CANARY_SERVICE" \
  --project "$PROJECT" --region "$REGION" --format='value(status.url)')"
curl -fsS "$service_url/health"
echo
echo "Production redemption canary deployed: $service_url"
