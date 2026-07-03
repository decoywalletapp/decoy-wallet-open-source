# Decoy Seed Production Scaling Runbook

## Current posture

New Android Decoy Seed records now store a watch-only public key and use QuickNode/BTC Blockbook UTXO monitoring once per watcher run. This covers the generated account path instead of relying only on the first 30 stored receive addresses.

The live App Store build had existing decoy seed records that are address-only. Those records remain protected by the legacy scanner until users regenerate a Decoy Seed from an updated build that stores a watch key.

QuickNode is intentionally configured with a bounded per-run budget. That prevents a bad deploy or sudden provider problem from burning the monthly credits immediately.

## Operating thresholds

- 0-10 armed watch-key seed users: current 60-second QuickNode UTXO checks are acceptable.
- 10-25 armed watch-key seed users: review watcher health and QuickNode usage daily.
- 25 armed watch-key seed users: capacity warning threshold. Prepare to raise budget or shard the watcher before public promotion.
- 35 armed watch-key seed users: urgent threshold. Do not continue growth without confirming QuickNode credits and watcher capacity.
- 40 armed watch-key seed users: current per-run budget ceiling. Raise `BLOCKBOOK_MAX_REQUESTS_PER_RUN`, add workers/shards, or both.
- 100+ armed watch-key seed users: sharded watcher or event-driven ingest should be live, with a second chain provider or node fallback planned.

## Required next production work

1. Keep legacy address-only scanning enabled for current App Store users.
2. Keep QuickNode reserve capped for legacy records.
3. Ship iOS and Android builds that store a public watch key for newly generated decoy seeds.
4. Ask older users to regenerate decoy seeds only after the updated build is live and verified. Do not disable legacy scanning.
5. Add sharded watcher execution before 40 armed watch-key seeds.
6. Run QuickNode stream/watch-key ingest in shadow mode until a real controlled transaction produces a shadow match.
7. Promote stream/watch-key ingest to active only after shadow verification and a rollback path are confirmed.

## Alert interpretation

- `Decoy Watcher Missing Heartbeat`: no healthy watcher heartbeat for 10 minutes.
- `Decoy Watcher Health Failure`: repeated incomplete scan failures in a short window.
- `Decoy QuickNode Reserve Usage Elevated`: reserve provider is being used repeatedly, which may mean paid usage is increasing.
- `Decoy QuickNode Rate Limit`: QuickNode rejected watcher traffic and reserve may be paused.
- `Decoy Watch-Key Capacity`: the number of armed watch-key seeds is near or at the per-run QuickNode budget.
- `Decoy Stale Seed Checks`: at least one armed seed has not been successfully checked inside the stale-check window.

## Default guardrails

- `WATCH_KEY_CAPACITY_WARN_THRESHOLD=25`
- `WATCH_KEY_CAPACITY_URGENT_THRESHOLD=35`
- `BLOCKBOOK_MAX_REQUESTS_PER_RUN=40`
- `WATCH_KEY_STALE_AFTER_MS=180000`

The watcher emits `WATCHER_WATCH_KEY_CAPACITY_WARN`, `WATCHER_WATCH_KEY_CAPACITY_URGENT`, `WATCHER_WATCH_KEY_CAPACITY_EXHAUSTED`, and `WATCHER_STALE_SEED_CHECKS` logs when these thresholds are crossed.
