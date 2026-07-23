# CodeMagic Android Rehearsal

This document tracks the public-source Android rehearsal workflow for Decoy
Wallet. The workflow is intended to prove that the public repository can produce
a signed Android test build with the same runtime configuration needed for
device testing.

## Workflow

CodeMagic workflow:

- `android-debug-rehearsal`

The workflow must run from:

- `decoywalletapp/decoy-wallet-open-source`

It builds:

- `build/app/outputs/flutter-apk/app-debug.apk`

It produces a downloadable CodeMagic artifact:

- `build/app/outputs/flutter-apk/app-debug.apk`

Firebase App Distribution can be re-enabled after the public CodeMagic app has a
service-account variable available to the workflow.

Release APK signing can be re-enabled after the public CodeMagic app has the
Android keystore variables available to the workflow.

## Secure Inputs

The public repository must not contain production backend URLs, Firebase files,
keystores, passwords, or service-account JSON. CodeMagic injects those values at
build time through secure variable groups:

- `decoy_public_runtime`
The workflow generates these private build files only inside the CodeMagic
worker:

- `android/app/google-services.json`

Those generated files must never be committed.

## Provenance

The Android rehearsal injects public-source metadata into the app:

- `DECOY_SOURCE_REPOSITORY`
- `DECOY_SOURCE_REF`
- `DECOY_SOURCE_COMMIT`
- `DECOY_BUILD_CHANNEL`
- `DECOY_BUILD_PLATFORM`
- `DECOY_BUILD_VERSION`
- `DECOY_BUILD_NUMBER`
- `DECOY_BUILD_VERIFICATION`

The app Settings page should show the public commit used for the build. The
build also writes:

- `build/provenance/android-firebase-rehearsal.txt`

## Device Test Goal

For Android device testing, install the CodeMagic debug APK on a real Android
device and verify:

- the app launches and authenticates
- Settings shows the expected public commit
- account PIN and decoy PIN flows work
- decoy seed setup and alert behavior work
- emergency contact and location behavior work
- subscription screens and payment buttons route correctly
