# Decoy Seed Entropy

This note documents how new Decoy Seed phrases are generated in the public
mobile app source.

## Current Behavior

New Decoy Seeds are generated from explicit app-controlled entropy in
`lib/custom_code/actions/decoy_seed_entropy.dart`.

The app currently:

- Uses Dart `Random.secure()`.
- Generates 16 bytes of entropy for a 12-word BIP39 mnemonic.
- Uses `nextInt(256)` so each byte can be any value from 0 through 255.
- Converts the entropy to a BIP39 mnemonic with `bip39.entropyToMnemonic()`.

This avoids relying on the `bip39.generateMnemonic()` package default entropy
helper.

## Why 12 Words

The current Decoy Seed display and verification flow is built around 12-word
mnemonics. Moving to 24-word Decoy Seeds should be done as a coordinated UI,
quiz, storage, and release change.

Until that migration is made, new Decoy Seeds use standard 128-bit BIP39
entropy.

## Backend Boundary

The Decoy Seed mnemonic and derived private key material must not be sent to the
backend or stored on the device after setup.

During setup, the mnemonic is passed through the seed display and verification
screens so the user can write it down and confirm it. After the Decoy Seed is
armed, the app commits watch-only public material and clears the draft Decoy
Seed app state.

The backend registration flow receives watch-only public material, including:

- Decoy ID.
- BIP84 account derivation path.
- Watch receive addresses.
- Account xpub/zpub/watch public key material.
- Watch public key type.

Existing Decoy Seeds remain valid. This change only hardens how newly generated
Decoy Seeds are created.

## Tests

`test/decoy_seed_entropy_test.dart` verifies that generated Decoy Seeds:

- Validate as BIP39.
- Use the expected 12-word count.
- Are unique across a sample set.
- Still derive BIP84 native SegWit receive addresses.
- Preserve xpub/zpub/watch public key behavior.
- Avoid `bip39.generateMnemonic()` and `nextInt(255)` in the app-controlled
  seed generation path.
