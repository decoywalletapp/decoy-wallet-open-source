#!/bin/zsh
set -euo pipefail

REPO="/Users/mitchellwleblanc/Documents/GitHub/mobile-app"

echo "Finishing Decoy Wallet Stripe switch session fix..."
"$REPO/decoy-deploy-entitlement-payment-backend.command"
"$REPO/decoy-publish-entitlement-safety-build.command"
echo "Done. Wait for TestFlight, then test the completed Stripe switch again."
