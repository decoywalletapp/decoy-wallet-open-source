# iOS Decoy Seed Watch-Key UTXO Handoff

Date: 2026-07-03

This note is for porting the Android/backend Decoy Seed reliability fix into the iOS worktree.

## Problem

The old Decoy Seed monitor registered and watched a fixed list of 30 receive addresses. That does not cover every address a real wallet can use, especially later derived receive addresses and change/spend paths. In the failed live test, the spend input address from the armed decoy seed was not one of the 30 stored backend addresses, so the backend never matched it and no seed alert was created.

## Backend Direction

The watcher now has a candidate account-level path:

- New seeds store a public watch key, normally a BIP84 account `zpub`.
- The backend uses QuickNode/Blockbook `GET /api/v2/utxo/{watch_public_key}` once per armed watch-key seed per scheduled run.
- The backend stores only HMAC fingerprints of UTXO outpoints in `public.decoy_seed_utxo_state`.
- If a previously seen UTXO disappears after arming/baseline, the watcher records a `SEED_DECOY` trigger and kicks the SMS worker.
- Legacy address-only seeds keep the old 30-address fallback, but they do not have full derived-address coverage.

Android/backend files to inspect:

- `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android/codex_backend_work/decoy-watcher-source/src/index.js`
- `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android/supabase/migrations/20260625232500_add_decoy_watch_public_key.sql`
- `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android/supabase/migrations/20260703122000_add_decoy_seed_utxo_state.sql`
- `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android/codex_backend_work/live_decoy_seed_readiness_audit.mjs`

## iOS App Requirements

When iOS creates a decoy seed, it must generate and send watch-only public metadata:

- Generate mnemonic as usual.
- Derive BIP84 account path `m/84'/0'/0'`.
- Export account `xpub`.
- Convert/export BIP84 account `zpub`.
- Continue generating the first 30 receive addresses for display/fallback.
- Send these fields to `commit-decoy`:
  - `xpub`
  - `zpub` if the API model supports it
  - `watch_public_key`: the `zpub`
  - `watch_public_key_type`: `bip84-account-zpub`
- Treat missing `storedWatchPublicKey: true` in the commit response as a blocking save failure. Do not show "seed ready" if the backend did not store the watch key.

Android reference files:

- `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android/lib/custom_code/actions/generate_decoy_draft.dart`
- `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android/lib/backend/api_requests/api_calls.dart`
- `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android/lib/create_decoy_seed/decoy_seed_system_values/decoy_seed_system_values_widget.dart`
- `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android/supabase/functions/commit-decoy/index.ts`

## Existing Live Users

Existing Decoy Seed records without `watch_public_key` cannot be upgraded backend-only. The backend cannot derive a full account watch key from the old 30 public addresses, and the app does not store seed phrases.

Those users need a regenerate/re-register Decoy Seed path after the iOS build ships. Until then, those legacy records are limited to spends from the exact stored addresses.

## Cost/Scale Assumption

The intended first production mode is one watch-key UTXO call per armed watch-key seed every 60 seconds. With Bitcoin methods at roughly 10 API credits per call:

- 1 armed seed: about 432k credits/month.
- 100 armed seeds: about 43.2M credits/month.
- 1,000 armed seeds: about 432M credits/month.

Keep `BLOCKBOOK_MAX_REQUESTS_PER_RUN` high enough for the number of armed watch-key seeds, with alerting before the monthly credit limit is threatened.

## Test Checklist

1. Create a fresh iOS Decoy Seed.
2. Confirm the commit response returns `storedWatchPublicKey: true`.
3. Confirm Supabase `decoys.watch_public_key` is populated for that decoy.
4. Arm Decoy Seed monitoring and ensure confirmed emergency contacts exist.
5. Ensure the watcher initializes UTXO state for the decoy.
6. Spend from a UTXO controlled by that seed.
7. Confirm a `SEED_DECOY` trigger is recorded.
8. Confirm SMS alerts are sent to confirmed contacts.
9. Confirm a legacy address-only seed is reported as needing regeneration/full-coverage upgrade.
