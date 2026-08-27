# Watch-only Decoy Import Staging Backend

This folder contains the staging-only backend pieces needed to test watch-only
Decoy imports without touching production infrastructure.

## What this supports

- Existing generated Decoy Seed registrations.
- Imported BIP84 account-level watch keys (`zpub`, or `xpub` normalized by the
  app before submission).
- Imported mainnet receive-address lists.
- The same downstream Decoy Seed alert path used by generated Decoy Seeds.
- Full staging onboarding without production vendors: phone verification,
  account/decoy PIN helpers, emergency-contact consent helpers, subscription
  entitlement stubs, chart data, data-key wrapping, and alert logging.

## What this must not contain

- Supabase service-role keys.
- Supabase anon keys.
- Twilio, Stripe, BTCPay, QuickNode, CodeMagic, Apple, or Google secrets.
- Production environment values.

## Deployment order

1. Apply `supabase_sql/20260827_watch_only_staging_schema.sql` to the staging
   Supabase project.
2. Deploy every folder in `functions/` to the staging Supabase project with JWT
   verification disabled at the Supabase edge-function gateway. The helpers do
   their own auth checks where auth is needed.
3. Create the CodeMagic `decoy_staging_runtime` group with staging-only values.
4. Run the `iOS TestFlight Rehearsal` workflow from the watch-only branch.

## Staging Function Map

Deploy these functions to the staging project:

- `commit-decoy`
- `register-decoy`
- `setPin`
- `verifyPin`
- `check_phone_taken`
- `createConsentRequest`
- `getConsentStatuses`
- `syncConsentSlots`
- `coingecko-proxy`
- `staging-api`

`staging-api` provides grouped no-production side effects for:

- `firebase/sendVerificationCode`
- `firebase/checkVerificationCode`
- `firebase/getPhoneHash`
- `firebase/getEmailHash`
- `firebase/sendSupportTicket`
- `data-key`
- `payment/*`
- `alerts/sendEmergencyAlerts`

The production backend should not be changed until the staging TestFlight path
has been tested end-to-end.
