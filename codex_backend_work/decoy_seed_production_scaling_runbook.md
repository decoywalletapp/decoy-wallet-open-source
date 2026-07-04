# Decoy Seed Production Scaling Runbook

## Current posture

New Android Decoy Seed records now store a watch-only public key and use QuickNode/BTC Blockbook UTXO monitoring once per watcher run. This covers the generated account path instead of relying only on the first 30 stored receive addresses.

The live App Store build had existing decoy seed records that are address-only. Those records remain protected by the legacy scanner until users regenerate a Decoy Seed from an updated build that stores a watch key.

QuickNode is intentionally configured with a bounded per-run budget. That prevents a bad deploy or sudden provider problem from burning the monthly credits immediately.

The watcher now supports deterministic sharding. A scheduler can call `/run` with:

```json
{
  "shard_index": 0,
  "shard_count": 4
}
```

Each Decoy Seed is assigned to exactly one shard from its `decoy_id`. That means future backend scaling does not require users with stored watch keys to regenerate Decoy Seeds. The same stored `watch_public_key` can be monitored by one shard today and a different shard layout later.

## Operating thresholds

- 0-25 armed watch-key seed users: one 60-second watcher is acceptable if `WATCHER_HEALTH_OK` is steady.
- 25 armed watch-key seed users: capacity warning threshold. Confirm QuickNode usage and prepare shards before public promotion.
- 35 armed watch-key seed users: urgent threshold for the single-watcher layout. Do not continue growth without sharding or a higher per-run budget.
- 40 armed watch-key seed users: single-watcher budget ceiling with `BLOCKBOOK_MAX_REQUESTS_PER_RUN=40`.
- 50-100 armed watch-key seed users: run 2-4 shards every 60 seconds, with each shard below its request budget.
- 100-500 armed watch-key seed users: run 4-16 shards, review QuickNode usage daily, and keep stale-seed alerts active.
- 500-1,000 armed watch-key seed users: run 16-32 shards or move to an event-driven provider design verified in shadow mode.
- 1,000+ armed watch-key seed users: sharding plus provider redundancy is required. A second chain data provider or self-hosted node/indexer should be in place before marketing claims this capacity.

## Required next production work

1. Keep legacy address-only scanning enabled for current App Store users.
2. Keep QuickNode reserve capped for legacy records.
3. Ship iOS and Android builds that store a public watch key for newly generated decoy seeds.
4. Ask older users to regenerate decoy seeds only after the updated build is live and verified. Do not disable legacy scanning.
5. Deploy the sharded watcher code.
6. Add Cloud Scheduler jobs for `shard_index` 0 through `shard_count - 1` before 40 armed watch-key seeds.
7. Run QuickNode stream/watch-key ingest in shadow mode until a real controlled transaction produces a shadow match.
8. Promote stream/watch-key ingest to active only after shadow verification and a rollback path are confirmed.
9. Before paid public growth, confirm the current QuickNode plan can cover:

```text
monthly watch-key checks ~= armed_watch_key_seed_records * 43,200 scans/month
```

This estimate assumes one UTXO request per armed watch-key Decoy Seed every 60 seconds. Faster polling multiplies the usage.

## Alert interpretation

- `Decoy Watcher Missing Heartbeat`: no healthy watcher heartbeat for 10 minutes.
- `Decoy Watcher Health Failure`: repeated incomplete scan failures in a short window.
- `Decoy QuickNode Reserve Usage Elevated`: reserve provider is being used repeatedly, which may mean paid usage is increasing.
- `Decoy QuickNode Rate Limit`: QuickNode rejected watcher traffic and reserve may be paused.
- `Decoy Watch-Key Capacity`: the number of armed watch-key seeds is near or at the per-run QuickNode budget.
- `Decoy Stale Seed Checks`: at least one armed seed has not been successfully checked inside the stale-check window.

In a sharded setup, health payloads include:

- `watcherShardIndex`
- `watcherShardCount`
- `watcherShardKey`
- `eligibleSeedRecords` for that shard
- `unshardedEligibleSeedRecords` across the full system
- `watchKeyRecords` for that shard
- `unshardedWatchKeyRecords` across the full system

`watchKeyCapacityExhausted`, `watchKeyCapacityWarn`, and `watchKeyCapacityUrgent` are per-shard signals. `watchKeyTotalCapacityWarn` and `watchKeyTotalCapacityUrgent` are planning warnings for the whole system and emit separate `WATCHER_WATCH_KEY_TOTAL_CAPACITY_WARN` / `WATCHER_WATCH_KEY_TOTAL_CAPACITY_URGENT` logs.

## Default guardrails

- `WATCH_KEY_CAPACITY_WARN_THRESHOLD=25`
- `WATCH_KEY_CAPACITY_URGENT_THRESHOLD=35`
- `BLOCKBOOK_MAX_REQUESTS_PER_RUN=40`
- `WATCH_KEY_STALE_AFTER_MS=180000`
- `WATCHER_SHARD_COUNT=1`
- `WATCHER_SHARD_INDEX=0`

The watcher emits `WATCHER_WATCH_KEY_CAPACITY_WARN`, `WATCHER_WATCH_KEY_CAPACITY_URGENT`, `WATCHER_WATCH_KEY_CAPACITY_EXHAUSTED`, `WATCHER_WATCH_KEY_TOTAL_CAPACITY_WARN`, `WATCHER_WATCH_KEY_TOTAL_CAPACITY_URGENT`, and `WATCHER_STALE_SEED_CHECKS` logs when these thresholds are crossed.

## User regeneration policy

Do not make updated watch-key users regenerate for backend scaling changes. Once a Decoy Seed has `watch_public_key` stored, backend upgrades should be handled through watcher code, shard count, scheduler jobs, QuickNode capacity, and provider redundancy.

Legacy address-only users are different. The backend cannot derive a full account watch key from the old fixed address list, and the app does not store seed phrases. Those users need a one-time Decoy Seed regeneration after the updated iOS/Android build is live and verified.
