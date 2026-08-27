# Watch-Only Import Staging Backend Handoff

This handoff is for the non-production Supabase/backend environment only. Do
not apply these changes to production until the staging mobile build and
staging backend tests pass end to end.

## Mobile Request Contract

The mobile app sends both generated Decoy Seeds and imported watch-only wallet
data through the existing `commit-decoy` endpoint.

```json
{
  "decoyId": "uuid-like-client-id",
  "derivation_path": "m/84'/0'/0' or imported-addresses",
  "addresses": ["bc1..."],
  "xpub": "xpub... or empty string",
  "watch_public_key": "zpub... or newline-separated addresses",
  "watch_public_key_type": "bip84-account-zpub or bitcoin-address-list"
}
```

## Existing Generated Seed Behavior

Generated Decoy Seeds must keep working exactly as they do today:

- `watch_public_key_type`: `bip84-account-zpub`
- `derivation_path`: `m/84'/0'/0'`
- `watch_public_key`: account-level zpub
- `xpub`: account-level xpub
- `addresses`: first 30 derived external BIP84 receive addresses

The backend should continue to store and monitor these as account-level
watch-only wallet records. No private seed, private key, mnemonic, xprv, or
zprv should ever be accepted or stored.

## Imported Zpub/Xpub Behavior

Imported zpub/xpub drafts intentionally normalize to the same
`bip84-account-zpub` contract used by generated Decoy Seeds:

- zpub imports should be stored like generated zpub watches.
- xpub imports are converted app-side to the matching zpub representation for
  native SegWit monitoring.
- outbound movement from any watched derived receive address should trigger the
  same emergency-contact alert path as generated Decoy Seed movement.

## Imported Address-List Behavior

Imported receive-address lists use:

- `watch_public_key_type`: `bitcoin-address-list`
- `derivation_path`: `imported-addresses`
- `watch_public_key`: newline-separated mainnet receive addresses
- `xpub`: empty string
- `addresses`: the same de-duplicated mainnet receive addresses as an array

For this type, the staging backend should:

- store the supplied addresses directly.
- avoid attempting child-address derivation.
- scan every supplied address for outbound movement.
- trigger the existing Decoy Seed emergency-contact alert path when any watched
  address spends.
- preserve existing duplicate/replay suppression so one chain event does not
  create repeated emergency alerts.

## Staging Acceptance Tests

Before enabling this feature in a production mobile build, staging must prove:

- the mobile Settings footer says `Backend: staging`.
- the watch-only import UI is present only when
  `DECOY_ENABLE_WATCH_ONLY_IMPORT=true`.
- a generated Decoy Seed can still be armed and alerted without behavior
  changes.
- a zpub import can be armed and alerts on outbound movement.
- an xpub import can be armed and alerts on outbound movement.
- an address-list import can be armed and alerts on outbound movement from each
  supplied address.
- invalid inputs are rejected app-side before the backend call, including seed
  phrases, xprv/zprv values, WIF private keys, BIP38-like private keys, testnet
  addresses, and malformed text.
- staging tables, logs, and alert queues receive all test data.
- production tables, logs, and alert queues receive no test data.

## Release Gate

Leave `DECOY_ENABLE_WATCH_ONLY_IMPORT` disabled for ordinary production builds
until the staging backend supports both `bip84-account-zpub` and
`bitcoin-address-list` records and the acceptance tests above pass.
