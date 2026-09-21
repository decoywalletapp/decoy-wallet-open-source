# Account deletion redemption cleanup

## Incident and scope

On 2026-09-21, the app-facing deletion endpoint returned HTTP 409 / PostgreSQL
23503 for accounts with retained promo reservation-session references. Both
1.1.1 and 1.1.2 use that endpoint. The deletion action and screen had not changed.

The baseline function in `fixtures/` was exported from production before the
fix. Tests reproduce the same foreign-key failure using that complete function
and an isolated, reduced schema matching the relevant live foreign keys.

Migration `20260921120000_fix_account_deletion_redemption_cleanup.sql` adds only
18 lines before the existing `auth.users` deletion. It detaches the deleting
account's promo references, removes its redemption/session rows, and leaves
code status and grant timestamps intact. Redeemed codes remain redeemed and
unfinished reserved codes remain unavailable for reuse. Other users are not
targeted. All cleanup remains in the existing database transaction.

No UI, alert delivery, redemption grant calculation, payment route, or Stripe
cancellation logic changes are included. Existing Stripe cancellation still
happens before the database RPC; this patch does not change that behavior.

## Verification

Use Node.js and PGlite 0.5.8 in a disposable test directory, not app dependencies:

```sh
PGLITE_MODULE=/absolute/path/to/@electric-sql/pglite/dist/index.js \
  node --test backend/account_deletion/account_deletion.test.mjs
node --test backend/membership_redemption/*.test.mjs
```

Nine database regression tests and twelve existing redemption/billing tests
passed. Coverage includes baseline reproduction, redeemed/reserved/disabled
codes, accounts without codes, session-only links, unrelated subscriber
preservation, authentication rejection, transaction rollback, unchanged function
permissions, idempotency, and refusal to overwrite an unexpected definition.
These are isolated tests, not a live customer-account deletion or Stripe charge.

## Deployment record

Applied the function-only migration through production Supabase SQL Editor on
2026-09-21, before 12:19:40Z. The live function definition hash was verified:

- Before: `88829989b343866d771feaebb55269a4`
- After: `5505a34bbb85b768049baff91df10166`
- Owner: `postgres`; security definer and `search_path=public, auth` unchanged.
- Existing ACL unchanged. No customer deletion was executed during deployment.
- No mobile build or app-store submission is required for this backend fix.

Final device acceptance: the user should retry deletion of their disposable iOS
test account, confirm return to sign-in, and have the endpoint response checked
for success. This device acceptance is pending as of deployment.

The original function is retained as a rollback artifact. Restoring it would
restore the known deletion bug, so rollback should be an explicit incident
decision rather than an automatic action.
