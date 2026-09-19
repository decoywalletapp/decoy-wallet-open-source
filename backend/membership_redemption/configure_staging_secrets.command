#!/bin/zsh
set -euo pipefail

if [[ "${CONFIRM_REDEMPTION_STAGING:-}" != "YES" ]]; then
  echo "Refusing to configure staging without CONFIRM_REDEMPTION_STAGING=YES"
  exit 2
fi

GCLOUD="${GCLOUD:-/opt/homebrew/bin/gcloud}"
NODE="${NODE:-/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node}"
PROJECT="${PROJECT:-decoywallet-a283b}"
SCRIPT_DIR="${0:A:h}"

stripe_key="$($GCLOUD secrets versions access latest \
  --project "$PROJECT" \
  --secret decoy-payment-staging-stripe-secret-key)"
coupon_id="$(STRIPE_SECRET_KEY="$stripe_key" \
  "$NODE" "$SCRIPT_DIR/setup_staging_assets.mjs")"
unset stripe_key

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

if ! "$GCLOUD" secrets describe decoy-redemption-staging-code-pepper \
    --project "$PROJECT" >/dev/null 2>&1; then
  put_secret decoy-redemption-staging-code-pepper "$(openssl rand -hex 32)"
fi
if ! "$GCLOUD" secrets describe decoy-redemption-staging-session-pepper \
    --project "$PROJECT" >/dev/null 2>&1; then
  put_secret decoy-redemption-staging-session-pepper "$(openssl rand -hex 32)"
fi
put_secret decoy-redemption-staging-stripe-coupon-id "$coupon_id"

echo "Staging redemption secrets and Stripe coupon are configured."
