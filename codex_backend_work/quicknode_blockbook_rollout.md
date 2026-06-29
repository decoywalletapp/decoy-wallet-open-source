# QuickNode BTC Blockbook Rollout

Goal: use BTC Blockbook/QuickNode safely for Decoy Seed monitoring without burning through paid quota on legacy address-only records.

## Current Production State

- `decoy-watcher` is serving production traffic.
- BTC Blockbook/QuickNode is configured as bounded reserve for legacy address-only records.
- Current scheduler cadence is once per minute.
- New watch-key seed records can run extra lightweight checks inside each scheduled watcher run. This lowers expected Decoy Seed alert latency without multiplying the legacy address-list scans.
- Existing decoy seed records store watched receive addresses, not an xpub, so the watcher checks each stored address.
- Live tuning is intentionally conservative: QuickNode is idle during healthy public batch scans and is capped when used as reserve.

## Next Build-Out: Public Watch Key Support

The Android app now generates a BIP84 account-level public watch key for new decoy seeds:

- the private seed phrase stays only with the user-facing seed flow
- the app still stores the first 30 receive addresses for compatibility and safety checks
- the app also sends a public watch key (`watch_public_key`, currently a zpub)
- the backend stores that public watch key on `public.decoys`
- the watcher tries Blockbook `/xpub/{watch_public_key}` first for new records
- if the watch-key lookup fails or is unavailable, the watcher falls back to the existing address-list scan

This is backward-compatible. Existing users do not need to regenerate decoy seeds for the current address-list watcher path to keep working. New decoy seeds can use the cheaper/faster watch-key path after the database, function, app, and watcher rollout are complete.

## Provider Chain

1. Blockchain.com `multiaddr` batch lookup for legacy address-only records.
2. QuickNode BTC Blockbook reserve when the public batch lookup fails.
3. Public Esplora-style address history endpoints.

For future watch-key records, QuickNode/stream monitoring is the intended primary path once shadow verification is complete.

## QuickNode Setup

Create a Bitcoin Mainnet endpoint with the BTC Blockbook add-on enabled. The watcher accepts either:

- the plain QuickNode endpoint URL, or
- the endpoint URL already including `/addon/3/api/v2`.

Do not commit the endpoint URL if it contains account-specific tokens.

With the current address-only record shape, estimate:

```text
monthly address checks ~= armed_seed_records * 30 addresses * 43,200 scans/month
```

Five armed seed records is about 6.48M address checks/month before transaction-detail lookups if QuickNode is primary. That is why legacy address-only records should not use QuickNode as primary.

With public watch-key support, the expected request shape for new records becomes closer to:

```text
monthly watch-key checks ~= armed_seed_records * 43,200 scans/month
```

That makes paid provider usage much more realistic for early production, while the old address-list records continue to work through the existing path.

## Safe Rollout Order

Before deploy, run the local preflight:

```bash
./codex_backend_work/preflight_watch_key_rollout.command
```

1. Apply `supabase/migrations/20260625232500_add_decoy_watch_public_key.sql`.
2. Deploy `supabase/functions/commit-decoy/index.ts`.
3. Ship an Android build that sends `xpub`, `watch_public_key`, and `watch_public_key_type` during decoy seed setup.
4. Deploy the watcher source from `codex_backend_work/decoy-watcher-source`.
5. Create a fresh decoy seed on Android.
6. Confirm the `commit-decoy` response includes `storedWatchPublicKey: true`.
7. Run the watcher and confirm health includes `blockbookWatchKeySuccesses`.
8. Trigger a controlled decoy seed spend and confirm the emergency alert sends.

Do not remove the address-list fallback. It is the compatibility path for current live users and the safety net if the provider has a watch-key-specific outage.

The watcher deploy can be run with:

```bash
./codex_backend_work/deploy_watch_key_watcher.command
```

That script requires typing `deploy-watch-key-watcher` before it changes Cloud Run.

Supabase helper scripts:

```bash
./codex_backend_work/copy_watch_key_migration.command
./codex_backend_work/deploy_commit_decoy_from_clipboard_token.command
```

The function deploy helper expects a fresh Supabase access token already copied to the clipboard. It reads the token only for the deploy command and does not print or save it.

## Validate Before Production

From the repo root:

```bash
BLOCKBOOK_BASE_URL="https://your-quicknode-endpoint.example/" \
node codex_backend_work/validate_blockbook_endpoint.mjs
```

Expected result:

- address lookup OK
- tx lookup OK
- nonzero `vin` and `vout` counts for a known-used test address

## Cloud Run Env

The safest local path is to copy the endpoint URL to the Mac clipboard and run:

```bash
BLOCKBOOK_FROM_CLIPBOARD=1 ./codex_backend_work/configure_watcher_blockbook.command
```

The script validates the endpoint first, updates `decoy-watcher`, and prints a rollback command.

Equivalent Cloud Run setting for bounded reserve:

```bash
BLOCKBOOK_BASE_URL="https://your-quicknode-endpoint.example/"
BLOCKBOOK_USAGE_MODE=fallback_only
BLOCKBOOK_MAX_REQUESTS_PER_RUN=40
BLOCKBOOK_ADDRESS_BATCH_ENABLED=true
```

Optional tuning:

```bash
BLOCKBOOK_ADDRESS_PAGE_SIZE=25
BLOCKBOOK_MAX_TXIDS_PER_ADDRESS=25
BLOCKBOOK_ADDRESS_DETAILS=txs
BLOCKBOOK_ADDRESS_CONCURRENCY=2
BLOCKBOOK_TX_CONCURRENCY=2
FETCH_RETRIES=3
FETCH_TIMEOUT_MS=8000
WATCH_KEY_FAST_PASSES=4
WATCH_KEY_FAST_INTERVAL_MS=10000
```

Do not raise Blockbook concurrency casually on the Starter add-on. A live test with 10 address requests at a time produced `429 Too Many Requests` and forced fallback to Blockchain.com. The tuned values above produced consecutive automatic runs with 5/5 Blockbook batch success and zero fallback.

`WATCH_KEY_FAST_PASSES` only adds extra checks for records that have a public watch key. Address-list-only seed records still run on the normal full scan cadence.

## Verification

After deploy:

1. Run the watcher once.
2. Confirm logs show `blockbookProviders` enabled.
3. Confirm logs show `blockbook-watch-key` for newly created decoy seeds.
4. Confirm `WATCHER_HEALTH_OK`.
5. Confirm health payload includes `blockbookBatchSuccesses` and, for new records, `blockbookWatchKeySuccesses`.
6. Trigger a fresh armed decoy seed spend.
7. Confirm the SMS alert is sent.

If QuickNode fails but fallback succeeds, logs should include `WATCHER_PRIMARY_PROVIDER_DEGRADED`.
