# Watch Address HMAC Shadow Checkpoint - 2026-09-05

## Status

HMAC/fingerprint watch-address matching is live in production as shadow/compare-only logic.
The existing Decoy Seed / watch-only alert path remains authoritative for real alerts and SMS.

No App Store or Google Play release was made for this backend-only checkpoint.

## Production State

- Supabase production project: `vxmrthyumzrfgtuvjqmr`
- Watcher service: `decoy-watcher`
- Shadow-enabled serving revision: `decoy-watcher-00078-6l9`
- Previous rollback revision: `decoy-watcher-00077-wzh`
- Backend branch checkpoint: `codex/xpub-watch-only-backend-20260831`
- Backend commits:
  - `264770a feat: add watch address fingerprint shadow mode`
  - `f8a6802 test: add watch address fingerprint shadow smoke`

## What Is Live

- `commit-decoy` writes address HMAC fingerprint rows for new/updated watch records.
- The watcher can load `decoy_watch_address_fingerprints`.
- The watcher compares fingerprint matches against the existing plaintext/address-list path in shadow mode.
- Shadow mode logs match/mismatch/unavailable signals.
- Fingerprint matching does not send SMS, suppress SMS, create alerts, or replace the existing alert path.

## Validation Completed

- Pre-deploy tests passed:
  - `commit-decoy-source-guard.test.js`
  - `decoy-watcher-safety.test.js`
- Production migration applied for `decoy_watch_address_fingerprints`.
- Backfill completed for existing armed decoys.
- Production smoke passed with `newTriggers: 0`.
- User tested:
  - Existing monitored receive address alert: passed.
  - Newly imported zpub alert: passed.
  - Generated Decoy Seed alert: passed.
- Follow-up audit after testing showed:
  - SMS queue clean with `0` unprocessed rows.
  - Fingerprint coverage present for armed rows.
  - No HMAC mismatch, unavailable, or watcher health-fail logs observed in checked windows.

## Important Nuance

The real user tests were caught by the normal scheduled watcher path, which is currently the authoritative production path.
The chain-event HMAC shadow comparator has matched controlled smoke transactions, but it has not proven enough real production traffic to replace the scheduled watcher path.

## Do Not Forget

Do not make HMAC authoritative casually.
Emergency alert delivery is the core safety function, and any change to the alert path must preserve a fallback.

Before replacing raw watch-address matching, build and test an explicit cutover step with:

- Feature flag control.
- Immediate rollback to the current authoritative path.
- Side-by-side comparison logs.
- No loss of existing Decoy Seed, receive-address, zpub, or xpub monitoring records.
- No app-store submission unless separately requested and validated.

## Future Work

Recommended next privacy phase:

1. Keep shadow mode running while other product work continues.
2. Periodically audit for:
   - HMAC mismatch logs.
   - HMAC unavailable logs.
   - Watcher health failures.
   - SMS queue backlog.
   - Fingerprint coverage for new watch records.
3. Build "HMAC authoritative with fallback" behind a deploy-time flag.
4. Test receive-address, zpub/xpub, generated-seed, and existing-user paths again.
5. Only after that proves stable, decide whether to reduce or remove raw address storage for new records.

