# Watch-Only Decoy Import

This note documents the app-side contract for importing existing wallet data
into Decoy Keys.

## Goal

The existing generated Decoy Seed flow remains supported. The watch-only import
flow adds a second setup path for users who already have wallet activity they
want Decoy to monitor.

The app accepts only watch-only public data:

- A mainnet zpub.
- A mainnet xpub treated as a native SegWit account-level public key.
- One or more mainnet Bitcoin receive addresses.

The app rejects seed phrases, private extended keys, WIF private keys, and
BIP38-style private keys.

## App Flow

`GenerateDecoySeedPhraseWidget` presents two choices:

- `Generate Seed Phrase`: keeps the existing generated Decoy Seed path.
- `Monitor Existing Wallet`: opens the watch-only import path.

The import path prepares local draft values only. It does not call the backend
directly. If validation succeeds, the draft is passed into the existing Decoy
Seed system-values screen, where the user arms monitoring and the app calls the
existing `commit-decoy` endpoint.

## Watch Types

For zpub/xpub imports, the app derives the first 30 native SegWit external
receive addresses and sets:

- `watch_public_key_type`: `bip84-account-zpub`
- `derivation_path`: `m/84'/0'/0'`
- `watch_public_key`: zpub

For address-list imports, the app de-duplicates valid receive addresses and
sets:

- `watch_public_key_type`: `bitcoin-address-list`
- `derivation_path`: `imported-addresses`
- `watch_public_key`: newline-separated receive addresses

## Release Safety Contract

The existing generated Decoy Seed alert path is protected behavior. Do not alter
its arming, monitoring direction, alert routing, duplicate handling, or
emergency-contact delivery while adding this feature unless that change is
explicitly requested and tested as its own release.

The `Monitor Existing Wallet` entry point is intentionally hidden unless
`DECOY_ENABLE_WATCH_ONLY_IMPORT=true` is injected at build time. The import
route itself also checks the same flag and shows an enabled-test-build message
if the screen is opened in a normal build. Keep that flag off for ordinary
production builds until backend support is verified for both generated Decoy
Seeds and imported address-list watches.

The existing generated Decoy Seed path must remain compatible with:

- `watch_public_key_type`: `bip84-account-zpub`
- `derivation_path`: `m/84'/0'/0'`
- `watch_public_key`: zpub

The new imported address-list path requires backend support for:

- `watch_public_key_type`: `bitcoin-address-list`
- `derivation_path`: `imported-addresses`
- `watch_public_key`: newline-separated receive addresses

The mobile app commits both generated and imported watch data through the
existing `commit-decoy` call after the user arms monitoring. The request body is
shaped as:

```json
{
  "decoyId": "user-decoy-id",
  "derivation_path": "m/84'/0'/0' or imported-addresses",
  "addresses": ["bc1..."],
  "xpub": "xpub... or empty string",
  "watch_public_key": "zpub... or newline-separated addresses",
  "watch_public_key_type": "bip84-account-zpub or bitcoin-address-list"
}
```

For generated seeds, zpub imports, and xpub imports, the backend should treat
`bip84-account-zpub` the same way the current generated Decoy Seed flow works.
For address-list imports, the backend should store and watch each address directly
without attempting to derive child addresses.

Before releasing address-list imports, backend services must prove that
`bitcoin-address-list` entries are registered, scanned, and alerted through the
same emergency-contact path as generated Decoy Seed alerts.

At minimum, release validation should verify:

- zpub import registers and alerts on outbound movement.
- xpub import registers as a zpub-compatible native SegWit watcher.
- address-list import registers every supplied address.
- address-list import alerts when any watched address has outbound movement.
- generated Decoy Seed registration and alerting still work unchanged.
- duplicate or replayed chain events do not send duplicate emergency alerts.
- seed phrases and private keys are never accepted, logged, or sent.
- existing users' armed Decoy Seed records are not rewritten by the migration.

Do not treat this feature as production-ready until mobile tests, backend
contract checks, and device testing pass.
