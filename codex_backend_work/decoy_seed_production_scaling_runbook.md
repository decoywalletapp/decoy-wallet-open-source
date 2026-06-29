# Decoy Seed Production Scaling Runbook

## Current posture

The live App Store build has existing decoy seed records that are address-only. Those records remain protected by the legacy scanner. QuickNode is intentionally configured as bounded reserve for those records so it can help when the normal batch source degrades without burning paid requests every minute.

## Operating thresholds

- 0-10 armed decoy seed users: current scanner plus QuickNode reserve is acceptable.
- 10-25 armed decoy seed users: review watcher health and QuickNode reserve alerts daily.
- 25-50 armed decoy seed users: finish and verify watch-key/stream monitoring before marketing scale.
- 50-250 armed decoy seed users: QuickNode stream/watch-key path should be primary for new records; legacy address-only scanner remains fallback.
- 250+ armed decoy seed users: add a second chain provider or node fallback, daily synthetic trigger tests, incident escalation, and a formal status dashboard.

## Required next production work

1. Keep legacy address-only scanning enabled for current App Store users.
2. Keep QuickNode reserve capped for legacy records.
3. Ship iOS and Android builds that store a public watch key for newly generated decoy seeds.
4. Run QuickNode stream/watch-key ingest in shadow mode until a real controlled transaction produces a shadow match.
5. Promote stream/watch-key ingest to active only after shadow verification and a rollback path are confirmed.
6. Ask older users to regenerate decoy seeds only after the updated build is live and verified. Do not disable legacy scanning.

## Alert interpretation

- `Decoy Watcher Missing Heartbeat`: no healthy watcher heartbeat for 10 minutes.
- `Decoy Watcher Health Failure`: repeated incomplete scan failures in a short window.
- `Decoy QuickNode Reserve Usage Elevated`: reserve provider is being used repeatedly, which may mean paid usage is increasing.
- `Decoy QuickNode Rate Limit`: QuickNode rejected watcher traffic and reserve may be paused.
