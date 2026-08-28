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
2. Deploy helper functions to the staging Supabase project with gateway JWT
   verification enabled. App requests use either a user session JWT or the
   staging Supabase anon JWT to reach staging helper routes, and the helpers
   still perform their own auth checks where user auth is needed.
3. Deploy `verify-link` to the staging Supabase project without gateway JWT
   verification. Email clients and mobile browsers do not send an Authorization
   header when a user taps a Supabase confirmation email. This function is the
   only staging exception: it performs no backend writes, uses no service-role
   credentials, and only redirects Supabase Auth payloads back into the Decoy app
   deep link.
4. Create the CodeMagic `decoy_staging_runtime` group with staging-only values.
5. Run the `iOS TestFlight Rehearsal` workflow from the watch-only branch.

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
- `verify-link`

`staging-api` provides grouped no-production side effects for:

- `firebase/sendVerificationCode`
- `firebase/checkVerificationCode`
- `firebase/getPhoneHash`
- `firebase/getEmailHash`
- `firebase/sendSupportTicket`
- `data-key`
- `payment/*`
- `alerts/sendEmergencyAlerts`

`verify-link` provides the staging email-confirmation bridge. It receives the
Supabase Auth confirmation payload in the mobile browser and redirects it to
`decoywalletapp://confirm-email` so the app can exchange the link for a real
staging session. It must stay staging-only and must not perform backend writes
or vendor side effects.

The production backend should not be changed until the staging TestFlight path
has been tested end-to-end.
