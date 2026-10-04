# Account Balance Pilot

This change makes the simulated Bitcoin balance belong to a signed-in account,
with Supabase persistence and an account-specific secure local cache. It is a
private pilot, not a public release. The source baseline is
`v1.1.6-public-source-20261003` at
`1fc1d7aa3735816858d99c9efe2780eb6aab1ae6`.

The tested account-balance reference is TestFlight `20261003231757` (1757),
commit `65729d6d0550b6754941937a3e11132545188b6f`. The separate adoption button
introduced in `20261004012717` (2717) is superseded by the single-Set flow below.
Do not roll back the tested account spending, synchronization, or refill rules.

## Balance Behavior

- New balances start at a random amount between 1 and 5 BTC as soon as the
  account's first successful balance load confirms no saved balance exists.
  The same persisted amount is shown in settings and on the decoy PIN route.
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

The legacy device-wide value is never imported automatically: it has no reliable
account owner. The ordinary Set action below lets an existing user choose
an amount for their signed-in account without discarding the old local value.

## Isolation and Sync

The feature requires both `DECOY_ACCOUNT_BALANCE_PILOT=true` in a private build
and a server enrollment row for the authenticated user ID. Migrations enroll
nobody. Existing pilot enrollments stay active. A new signup from an enabled
client carries a balance preference that allows its first authenticated balance
read to enroll it. Existing accounts remain local until they use Set.
Tester email addresses are deliberately not embedded in public source.

## Single Set Transition

- Updating alone preserves the exact stored local amount, including zero and
  old timestamps. Reads and login do not assign it to an account or reseed it.
  Until Set, PIN entry keeps the original 1.1.6 rule: 24 hours from the last
  seed/configuration permits a new random 1-5 BTC amount, including for partial
  balances and zero. It is not a timer starting at drain. Opening settings alone
  does not reseed. No drain history or refill target is guessed or backfilled.
  Unmigrated accounts retain the shared device value until Set; historical
  per-account ownership cannot be recovered from the 1.1.6 storage format.
- The earlier unreleased draft's freeze of the legacy timer is removed. Balance
  preservation on upgrade does not mean disabling the existing daily reset.
- The page has one amount and the existing Set button, with no extra button or
  dialog. The first normal Set saves the entered amount to the signed-in account
  and enables account storage. The amount may be left unchanged or edited.
- That first save requires an online server response. The RPC checks auth.uid(),
  validates the amount, and locks the account's balance row. It atomically saves
  the amount and enables account storage only when no initialized balance exists.
- A saved account balance always wins over an adoption attempt from another
  device, including partial balances, explicit zero, and active drain timers.
  Retries cannot replace that value. A stale save reports failure and reloads the
  account amount instead of falsely claiming the requested amount was saved.
  Normal later configuration remains explicit through the same Set button.
- The local legacy value is not deleted or overwritten by adoption. Other
  unenrolled accounts keep the old shared-device behavior until they also opt in.
- Already enrolled pilot accounts retain their balances and reset rules. A
  legacy editor cannot overwrite a newly discovered account balance after sync.
- All signup paths add only `decoy_balance_storage: account_v1` metadata when the
  private balance flag is enabled. Email/password validation, redirect URLs,
  confirmation requirements, auth sessions, PIN routing, entitlements, monitoring
  and alerts are unchanged. No existing user's metadata is updated by this patch.
- `account_simulated_balance_v3` recognizes the new-signup preference, enrolls
  that authenticated account and delegates to the unchanged v2 balance rules.
  The normal initial seed remains random 1-5 BTC with no custom refill target.
  The marker is a balance preference, not an authorization or entitlement flag;
  owners can already enable their own balance through the explicit save RPC.
- A new account never displays another account's shared legacy value while its
  first load is pending or offline. It waits for a successful account load.
- A previously offline second device discovers adoption when it next connects;
  it cannot discover a remote mode change while offline for the first time.
- New RPC: adopt_account_simulated_balance(uuid, bigint, uuid), authenticated
  self-service only. Direct table access remains denied. Removing enrollment
  blocks the old RPC until the user explicitly adopts again; it is not an
  account suspension or authorization mechanism.

Migrations: `20261004010000_account_balance_opt_in.sql` (deployed for 2717)
and `20261004030000_account_balance_new_signups.sql` (deployed on October 4
after hosted staging verification). Test only on synthetic staging fixtures
and roll back their changes.
Do not run fixtures on customer accounts.
Private builds remain version 1.1.7 and public production workflows stay disabled
for the feature until a separately approved rollout.

Historical 2717 verification (October 4, 2026 UTC): 98 focused app checks,
795 general Flutter checks, 144 pilot PIN cases, 222 legacy PIN/QR cases, and
36 in-memory PostgreSQL checks passed. The two default-suite environment gates
were run separately. Staging authenticated fixture checks passed and rolled
back. The application migration asserted unchanged balances, enrollments and
operation receipts. Existing timed device tests remain pending and unmodified.

### Current Compatibility Checkpoint (October 4, 2026)

The single-Set revision and its backend prerequisite are verified. Private
builds are the next step; device verification remains required. No customer or
existing tester data was changed. The stable 1.1.6 tag and tested 1757 reference
remain unchanged.

The new function was deployed first to hosted staging. Transactional synthetic
fixtures verified legacy rejection, explicit Set adoption, new-signup enrollment,
initial seed, partial spending, ownership rejection and access restrictions.
Fixtures were rolled back and their absence was checked. The same function was
then deployed to the application project inside a guarded transaction. Before
and after digests matched for all existing auth users, balances, enrollments
and operation receipts. The four existing balance/enrollment rows remain, and
the separately prepared 1.1.6 upgrade account remains unenrolled with unchanged
signup metadata. Anonymous function execution remains denied. No existing
account was used as a mutation fixture.

- 152 focused balance, signup and settings checks passed, including 32 new
  legacy compatibility cases. These cover both sides of the 24 hour boundary,
  zero, one satoshi, 4.52380952 BTC, 195 BTC, restart, offline operation, partial
  and full spending, and transition to the account rules through ordinary Set.
- 849 general Flutter checks passed. The two environment-gated suites were
  run separately: 144 account-mode PIN cases and 222 legacy PIN/QR cases passed.
- All 44 in-memory PostgreSQL checks passed, including unchanged existing rows
  on migration and the authenticated new-signup wrapper. No hosted database
  connection was used for these checks.
- All six signup checks also passed with the private feature flag enabled.
- The 50 settings checks passed again with screenshot capture. Small-screen
  layout checks cover all 18 languages; English, German and Arabic screenshots
  were inspected. There is one Set button and no adoption dialog or extra button.
- Static analysis found no errors. The 15 warnings are pre-existing unused
  declarations/imports and a duplicate generated import. Diff whitespace checks
  passed. No unrelated warning cleanup was included.
- Direct source comparison verified unchanged 1757 snapshot/spending/refill
  and account mutation logic, and an unchanged 1.1.6 legacy expiration rule.
  The PIN pages, translations, existing balance migrations, browser email/reset
  code, auth router and billing code were not changed from their references.

Build readiness: local regression gates pass, but do not start CodeMagic until
`20261004030000_account_balance_new_signups.sql` has passed isolated hosted
staging verification and been applied to the private build's backend. The client
now calls v3, which must exist before the build is distributed. The prepared
staging fixture is `test/backend/account_balance_new_signup_hosted_test.sql`;
it uses synthetic accounts and rolls back. Do not use real customer accounts.

After that prerequisite, make only a private build and verify a real in-place
upgrade from 1.1.6 without uninstalling or clearing app data. Check the saved
amount before its original expiration, then ordinary Set and account sync, and
a new signup before first PIN entry. Automated time-boundary coverage does not
replace the pending physical-device upgrade and elapsed-time tests. Existing
tester balances, settings and drain timestamps must remain intact.

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

## Initial Balance Before PIN Entry

The next pilot client initializes an empty enrolled account after its first
successful server read, using the existing durable, idempotent seed operation.
It does not wait for the first decoy PIN entry. Existing amounts, configured
zero, partially spent balances, and drained balances are left alone. Settings
and refresh do not trigger a drain refill; that still happens on PIN entry
after the existing cooldown. Concurrent first loads converge on the amount
accepted by the server, rather than replacing another device's balance.

Configure Bitcoin Balance waits for the first balance instead of presenting
an editable placeholder zero. If the initial load fails, it offers the existing
localized Retry control. Already initialized cached balances remain usable
offline, and refresh does not overwrite unsaved input in the amount field.

This is client code only. No migrations, production data changes, account
resets, authentication changes, builds, or deployments were performed for this
follow-up. The private build flag and server enrollment gates are unchanged.
The installed pilot builds do not include this follow-up yet.

Local verification on October 3, 2026:

- 62 focused balance and settings tests passed, including all 18 languages for
  the new retry state on a small phone.
- 759 general Flutter tests passed. The two environment-gated groups were run
  separately: 144 pilot PIN cases and 222 legacy PIN/QR cases passed.
- All 28 in-memory PostgreSQL checks passed, without production connections.
- Static analysis found no new warnings or errors. The existing unused
  `_safeInit` warning in `app_state.dart` remains. `git diff --check` passed.
- The stable public release tag remains unchanged.

Before release, verify the next private build with a newly enrolled test
account that has no saved balance: open Configure Bitcoin Balance before any
decoy PIN entry, note its random 1-5 BTC, then confirm the decoy route and a
second device show the same amount. Preserve existing test accounts and their
saved settings; do not clear account data to simulate a new account.
