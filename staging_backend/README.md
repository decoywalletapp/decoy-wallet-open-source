# Watch-only Decoy Import Staging Backend

This folder contains the staging-only backend pieces needed to test watch-only
Decoy imports without touching production infrastructure.

## What this supports

- Existing generated Decoy Seed registrations.
- Imported BIP84 account-level watch keys (`zpub`, or `xpub` normalized by the
  app before submission).
- Imported mainnet receive-address lists.
- The same downstream Decoy Seed alert path used by generated Decoy Seeds.

## What this must not contain

- Supabase service-role keys.
- Supabase anon keys.
- Twilio, Stripe, BTCPay, QuickNode, CodeMagic, Apple, or Google secrets.
- Production environment values.

## Deployment order

1. Apply `supabase_sql/20260827_watch_only_staging_schema.sql` to the staging
   Supabase project.
2. Deploy `functions/commit-decoy` to the staging Supabase project.
3. Create the CodeMagic `decoy_staging_runtime` group with staging-only values.
4. Run the `iOS TestFlight Rehearsal` workflow from the watch-only branch.

The production backend should not be changed until the staging TestFlight path
has been tested end-to-end.
