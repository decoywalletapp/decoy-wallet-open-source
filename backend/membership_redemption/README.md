# Membership redemption integration

This module adds the authenticated external-browser redemption flow without
changing the existing Stripe or BTCPay purchase endpoints.

Required server configuration:

- `MEMBERSHIP_CODE_PEPPER`: secret HMAC pepper for stored code hashes.
- `REDEMPTION_SESSION_PEPPER`: separate secret HMAC pepper for session tokens.
- `PUBLIC_REDEEM_URL`: public `/redeem-membership` URL.
- `STRIPE_PROMO_100_COUPON_ID`: an internal 100%-off Stripe coupon used only
  by the schedule adapter.

The route module and Stripe adapter are dependency-injected so they can be
registered by the existing payment service. The adapter refuses to modify an
account that already has a Stripe subscription schedule; those redemptions are
flagged for review instead of risking replacement of an existing billing plan.
It must not be deployed until staging tests pass for monthly, annual,
cancel-at-period-end, and already-scheduled accounts.

Mission-critical alert services must use `has_active_decoy_wallet_access`
instead of checking only `is_active/current_period_end`. That RPC recognizes
both paid access and `promotional_access_until`, while retaining the existing
teardown grace behavior.
