#!/bin/zsh
set -euo pipefail

if [[ "${CONFIRM_REDEMPTION_STAGING:-}" != "YES" ]]; then
  echo "Refusing to deploy without CONFIRM_REDEMPTION_STAGING=YES"
  exit 2
fi

GCLOUD="${GCLOUD:-/opt/homebrew/bin/gcloud}"
PROJECT="${PROJECT:-decoywallet-a283b}"
REGION="${REGION:-us-central1}"
SERVICE="${SERVICE:-decoy-stripe-webhook-staging}"
SOURCE_DIR="${SOURCE_DIR:-/private/tmp/decoy-redemption-staging-service}"
PROJECT_NUMBER="${PROJECT_NUMBER:-866378207353}"

if [[ "$SERVICE" != *staging* ]]; then
  echo "Refusing to deploy a service without 'staging' in its name: $SERVICE"
  exit 3
fi

required_secrets=(
  decoy-payment-staging-stripe-secret-key
  decoy-payment-staging-stripe-webhook-secret
  decoy-payment-staging-supabase-url
  decoy-payment-staging-supabase-service-role-key
  decoy-payment-staging-stripe-price-id-monthly
  decoy-payment-staging-stripe-price-id-yearly
  decoy-payment-staging-btcpay-base-url
  decoy-payment-staging-btcpay-store-id
  decoy-payment-staging-btcpay-api-key
  decoy-payment-staging-btcpay-webhook-secret
  decoy-redemption-staging-code-pepper
  decoy-redemption-staging-session-pepper
  decoy-redemption-staging-stripe-coupon-id
)

for secret in "${required_secrets[@]}"; do
  "$GCLOUD" secrets describe "$secret" --project "$PROJECT" >/dev/null
done

public_url="https://$SERVICE-$PROJECT_NUMBER.$REGION.run.app"

"$GCLOUD" run deploy "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --source "$SOURCE_DIR" \
  --allow-unauthenticated \
  --set-env-vars "PUBLIC_BASE_URL=$public_url,APP_RETURN_URL=https://decoywalletapp.com/open,APP_DEEPLINK_BASE=decoywalletapp://payment-return,BTCPAY_MONTHLY_AMOUNT_USD=3.94,BTCPAY_YEARLY_AMOUNT_USD=39.42" \
  --set-secrets "STRIPE_SECRET_KEY=decoy-payment-staging-stripe-secret-key:latest,STRIPE_WEBHOOK_SECRET=decoy-payment-staging-stripe-webhook-secret:latest,SUPABASE_URL=decoy-payment-staging-supabase-url:latest,SUPABASE_SERVICE_ROLE_KEY=decoy-payment-staging-supabase-service-role-key:latest,STRIPE_PRICE_ID_MONTHLY=decoy-payment-staging-stripe-price-id-monthly:latest,STRIPE_PRICE_ID_YEARLY=decoy-payment-staging-stripe-price-id-yearly:latest,BTCPAY_BASE_URL=decoy-payment-staging-btcpay-base-url:latest,BTCPAY_STORE_ID=decoy-payment-staging-btcpay-store-id:latest,BTCPAY_API_KEY=decoy-payment-staging-btcpay-api-key:latest,BTCPAY_WEBHOOK_SECRET=decoy-payment-staging-btcpay-webhook-secret:latest,MEMBERSHIP_CODE_PEPPER=decoy-redemption-staging-code-pepper:latest,REDEMPTION_SESSION_PEPPER=decoy-redemption-staging-session-pepper:latest,STRIPE_PROMO_100_COUPON_ID=decoy-redemption-staging-stripe-coupon-id:latest"

service_url="$("$GCLOUD" run services describe "$SERVICE" \
  --project "$PROJECT" --region "$REGION" --format='value(status.url)')"
curl -fsS "$service_url/health"
echo
echo "Staging redemption service deployed: $service_url"
