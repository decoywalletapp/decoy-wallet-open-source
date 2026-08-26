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

## Backend/Staging Requirement

Before releasing address-list imports, staging backend services must prove that
`bitcoin-address-list` entries are registered, scanned, and alerted through the
same emergency-contact path as generated Decoy Seed alerts.

At minimum, staging should verify:

- zpub import registers and alerts on outbound movement.
- xpub import registers as a zpub-compatible native SegWit watcher.
- address-list import registers every supplied address.
- address-list import alerts when any watched address has outbound movement.
- duplicate or replayed chain events do not send duplicate emergency alerts.
- seed phrases and private keys are never accepted, logged, or sent.

Do not treat this feature as production-ready until both mobile and staging
backend tests pass.
