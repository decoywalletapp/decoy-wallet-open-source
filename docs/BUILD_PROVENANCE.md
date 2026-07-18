# Build Provenance

This document describes the bridge between Decoy Wallet's public source and
store-distributed app builds.

## What Users Can Verify

The app can display the public repository, release ref, source commit, build
channel, target platform, and verification status compiled into the binary.
Those values are not secrets. They are public provenance markers.

A user should be able to compare the app's Settings > Source Verification values
with a public GitHub release or tag.

## Required Release Pattern

For each production release:

1. Land the actual source change in the public repository before building.
2. Tag the exact source commit used for the store submission.
3. Build from that public tag using the documented Flutter toolchain.
4. Inject provenance values with `--dart-define`.
5. Publish release notes that map each store version to its tag and commit.

The current public verification workflow pins Flutter `3.41.6` with Dart
`3.11.4`.

Example Android build metadata:

```sh
flutter build appbundle \
  --build-name 1.0.5 \
  --build-number 10005 \
  --dart-define=DECOY_SOURCE_REPOSITORY=https://github.com/decoywalletapp/decoy-wallet-open-source \
  --dart-define=DECOY_SOURCE_REF=android-v1.0.5+10005 \
  --dart-define=DECOY_SOURCE_COMMIT=<public-git-commit-sha> \
  --dart-define=DECOY_BUILD_CHANNEL=codemagic \
  --dart-define=DECOY_BUILD_PLATFORM=android \
  --dart-define=DECOY_BUILD_VERSION=1.0.5 \
  --dart-define=DECOY_BUILD_NUMBER=10005 \
  --dart-define=DECOY_BUILD_VERIFICATION=store-release
```

Example iOS build metadata:

```sh
flutter build ipa \
  --build-name 1.0.5 \
  --build-number 10005 \
  --dart-define=DECOY_SOURCE_REPOSITORY=https://github.com/decoywalletapp/decoy-wallet-open-source \
  --dart-define=DECOY_SOURCE_REF=ios-v1.0.5+10005 \
  --dart-define=DECOY_SOURCE_COMMIT=<public-git-commit-sha> \
  --dart-define=DECOY_BUILD_CHANNEL=codemagic \
  --dart-define=DECOY_BUILD_PLATFORM=ios \
  --dart-define=DECOY_BUILD_VERSION=1.0.5 \
  --dart-define=DECOY_BUILD_NUMBER=10005 \
  --dart-define=DECOY_BUILD_VERIFICATION=store-release
```

## Android

Android can support the strongest public verification path. The public workflow
builds a debug APK from public source, uploads the artifact, and creates a
GitHub provenance attestation for non-PR runs. A production Android release
should later add signed release artifacts, Google Play submission provenance,
and Android Code Transparency.

## iOS

iOS can show the same public source tag and commit inside the app, but normal
users cannot independently reproduce Apple's final App Store-signed binary in
the same way Android users can inspect APKs. The practical iOS trust bridge is
public source tags, public build logs, visible in-app commit metadata, release
notes, and independent auditability of the source.

## Boundaries

Build provenance does not require publishing signing keys, app-store
credentials, production backend secrets, deployment scripts, or operational
runbooks. Those stay outside the public repository.
