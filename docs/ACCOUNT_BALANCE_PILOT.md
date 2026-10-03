# Account Balance Pilot

This change makes the simulated Bitcoin balance belong to a signed-in account,
with Supabase persistence and an account-specific secure local cache. It is an
opt-in pilot, not a public release. The source baseline is
`v1.1.6-public-source-20261003` at
`1fc1d7aa3735816858d99c9efe2780eb6aab1ae6`.

## Balance Behavior

- New balances start at a random amount between 1 and 5 BTC.
- Configuration sets the simulated balance, including an explicit zero.
- Simulated sends deduct the gross amount using the existing fee/dust floor.
- Partial balances do not expire, even after 24 hours or many days.
- A positive simulated send that drains the balance to zero starts a 24 hour
  cooldown. The existing fee plus one-satoshi floor also counts as drained.
- The next PIN entry after that cooldown restores the saved custom starting
  amount, or generates 1-5 BTC if no custom amount has been configured.
- Manually configured zero persists until explicitly changed. Configuration
  cancels any prior cooldown. A send at zero does not restart the cooldown.
- Market price updates affect the USD estimate, not the BTC balance or timer.
- No actual Bitcoin transactions or monitoring balances are changed.

The legacy device-wide value is not imported: it has no reliable account owner.

## Isolation and Sync

The feature requires both `DECOY_ACCOUNT_BALANCE_PILOT=true` in a private build
and a server enrollment row for the authenticated user ID. The migration enrolls
nobody. Tester email addresses are deliberately not embedded in public source.

The database has new, separate tables. It does not alter existing auth, billing,
monitor, or emergency alert tables. Clients have no direct table privileges.
The RPC checks `auth.uid()`, the expected account ID, and pilot enrollment. It
serializes mutations with a row lock and records operation IDs to make retries
idempotent. Table RLS is enabled with no client access policies. Account deletion
cascades the new rows. See Supabase's [function security guidance](https://supabase.com/docs/guides/database/functions)
and [RLS guidance](https://supabase.com/docs/guides/database/postgres/row-level-security).

Account changes clear the in-memory balance immediately. Async responses for a
previous account are ignored. Local secure storage keys contain the account ID;
the legacy shared keys are not overwritten by pilot mutations. The auth state
observer only informs the balance service of the selected account; it does not
create sessions, refresh tokens, or change the auth router's decisions.

Once enrollment has been verified and cached, edits and simulated sends work
offline. They are persisted locally before success is returned. Sync retries on
app resume, balance-screen entry, wallet entry/refresh, and the next mutation.
The custom starting amount and drain timestamp are synchronized along with the
remaining balance. Online devices read remote changes at those points; this is not live continuous
replication. PIN reentry uses the cached state without waiting for a network
refresh. A first-ever uncached account requires a successful server check before
it can edit an account balance; failed checks never import another user's value.

## Concurrent and Offline Rules

- Sends in the same balance epoch subtract serially. A duplicate operation ID
  is acknowledged without subtracting twice.
- Each configure/reset creates a new epoch. A delayed send from an older epoch
  is acknowledged without draining the newly configured/reset balance.
- Competing initial seed operations retain the first accepted server balance.
- Competing refills of the same drained cycle retain the first accepted refill.
  Pending sends following the other phone's refill are rebased to that same
  cycle. A manual configuration clears this lineage and still rejects old sends.
- Explicit configurations are applied in server receipt order. Do not make
  competing offline configurations on two devices during the pilot. A later
  sync of an older offline configuration can replace the other configuration.
- The server starts the authoritative cooldown when it accepts a send that
  drains a positive balance. Client timestamps cannot shorten this interval.
  An offline drain has a provisional local timestamp, replaced on sync. A new
  refill is not queued while earlier operations are still unacknowledged, so an
  offline drain must first sync before its authoritative 24 hour wait begins.
  A previously acknowledged drain can refill offline after the cooldown; the
  refill and later sends remain durable and sync on reconnection.
- Revoking enrollment stops online writes. A previously authorized offline
  cache cannot know about revocation until it reconnects.

## Rollout Gates

1. Run the local automated tests below. Nothing needs production credentials.
2. Review the additive migration and apply it to an isolated Supabase test
   project first. Verify the real API/JWT behavior there; the local PostgreSQL
   runner uses an auth stub and is not a full hosted-Supabase integration test.
3. Resolve the four authorized tester emails to actual auth user IDs privately.
   Review the IDs, then enroll only those IDs. No passwords are needed.
4. With approval, make a private TestFlight/direct Android build with the pilot
   define. Do not use a store production publishing workflow.
5. Run the device tests together, one at a time. Do not enable general rollout
   until they pass. Keep v1.1.6 available as the reference build.

For rollback, remove the private build flag or return testers to v1.1.6. Keep the
new server tables for diagnosis rather than deleting them. v1.1.6 ignores them
and still uses its old shared device setting; synced pilot balances will not
appear in that old version. Applying the migration is a separate rollout step.

## Local Tests

```sh
flutter test --no-pub
flutter test --no-pub test/localized_pin_navigation_test.dart \
  --dart-define=DECOY_TEST_ACCOUNT_BALANCE=true \
  --dart-define=DECOY_SUPABASE_URL=https://test.invalid \
  --dart-define=DECOY_FIREBASE_FUNCTIONS_BASE_URL=https://test.invalid \
  --dart-define=DECOY_ALERT_BASE_URL=https://test.invalid \
  --dart-define=DECOY_DATA_KEY_BASE_URL=https://test.invalid/unwrap
```

Repeat the PIN command without `DECOY_TEST_ACCOUNT_BALANCE` to check the legacy
path. Run the existing QR tests with their documented watch-only flag separately.
The default suite's missing-configuration test must not be given Supabase config.

The database runner uses PGlite in memory, with no network connection. Install
`@electric-sql/pglite` in a temporary folder, not as an app dependency, and run:

```sh
PGLITE_TEST_MODULE=/absolute/path/to/pglite/dist/index.js \
  node test/backend/account_balance_database_test.mjs
```

## Device Checklist

1. Configure four distinct amounts in the four enrolled accounts on one phone.
   Switch through all four and check that each amount returns correctly.
2. Sign into the same account on the other phone and check its saved amount.
3. Partially spend, return through the decoy PIN, and check the remaining amount.
4. Drain the balance, restart, reenter the PIN, and confirm it stays at zero.
5. Repeat configuration and spending offline, restart offline, reconnect, and
   confirm another device receives the change after refresh/resume.
6. Verify 24 hours from draining, indefinite partial balances, custom/default
   refill amounts, and explicit zero on test fixtures. Do not change
   unrelated production account data to simulate time.
7. Confirm a nonenrolled account follows the existing behavior and cannot call
   the new storage API for another user. Rerun normal and decoy PIN/alert checks.
8. Regression-check login, browser confirmation, password reset, and subscription
   access on the private build. These flows are not modified by this patch.

## Local Verification Results

Verified on October 3, 2026, without connecting to production:

- Default Flutter suite: 711 passing tests, including 17 balance tests. Two
  environment-gated suites were skipped here and run separately below.
- PIN integration with the pilot attached and offline: 144 passing cases across
  all 18 languages, including normal PIN, duress PIN, and alert conditions.
- Legacy PIN and enabled QR integration: 222 passing cases.
- In-memory PostgreSQL migration and access-control checks: 18 passing checks.
- Static analysis: no errors or new warnings in the changed code. The existing
  unused `_safeInit` helper warning in `app_state.dart` remains unchanged.

## Private Build Preparation

On October 3, the additive migration was applied first to the existing staging
project. Transactional checks using hosted `auth.uid()` and database roles
passed for ownership, account isolation, duplicate-operation handling, RLS,
unenrolled-account rejection, and anonymous denial. Test mutations were rolled
back. This does not replace physical-device testing with real login tokens.

The same migration was then applied to the application project and only the
four privately reviewed tester accounts were enrolled. Existing app tables,
authentication configuration, billing, and alert functions were not changed.

This branch labels the TestFlight and signed Android artifact workflows as
account balance pilots. Both enforce this exact pilot branch. Android has no
store publishing step; iOS does not submit to App Store review. The separate
iOS public-release workflow leaves the pilot disabled.

The final local prebuild suite passed 714 tests with the same two separately
tested environment gates. Physical-device verification remains required.

## Drain-Only Refill Update

This follow-up intentionally changes the former daily reseeding rule. It adds
`configured_sats`, `drained_at`, and refill lineage in the additive migration
`20261003220000_account_balance_drain_refill.sql`. Existing amounts, operation
receipts, account IDs, and enrollment are preserved. Nothing in auth, PINs,
alerts, billing, or the stable public release is modified.

Old pilot records do not contain the original configured amount. The migration
and old-cache reader preserve the remaining amount as a conservative custom
target, with no inferred drain timestamp. An existing zero stays zero. Testers
should save their desired custom amount once after installing the updated pilot;
there is no automatic account reset or guessing of a previously spent amount.

The new client calls `account_simulated_balance_v2`, which is unavailable until
this migration is applied. It will not silently write through the old rules on
an unmigrated server. The original endpoint is updated to the same server rules
to prevent older online pilots from overwriting nonzero balances. Older pilot
clients still have their original offline rules and must be upgraded together.

On October 3, this migration was applied to staging and passed hosted,
transactional checks for partial balances, custom refills, explicit zero,
server-authoritative drain timing, replay handling, ownership, enrollment, and
access restrictions. All staging fixtures were rolled back.

The same update was then applied to the application project's existing pilot.
Transactional before/after assertions verified that all four saved balances,
their timestamps and epochs, all eleven operation receipts, and the same four
enrolled accounts were preserved. No account settings were reset. Updated
private builds are required for device testing; there is no public rollout.

The previous pilot passed 15 guided physical-device checks for account isolation,
configuration, partial/full spending, offline persistence, and synchronization.
Those results describe the previous build, not this new refill behavior. The
remaining device checks and targeted refill checks require the updated build.

Local verification of the drain-only update on October 3, 2026:

- 726 general Flutter tests passed, including 29 focused balance cases.
- The two environment-gated groups skipped in that general run were exercised
  separately: 144 pilot PIN cases and 222 legacy PIN/QR cases passed.
- 28 in-memory PostgreSQL checks passed, including upgrade preservation,
  anonymous/other-account denial, custom/default refills, replay handling, and
  simultaneous-refill metadata.
- Static analysis reported only the pre-existing unused `_safeInit` warning in
  `app_state.dart`; no new warnings or errors. `git diff --check` passed.
- The stable `v1.1.6-public-source-20261003` tag still resolves to
  `1fc1d7aa3735816858d99c9efe2780eb6aab1ae6`.
