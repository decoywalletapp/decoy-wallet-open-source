# CodeMagic Android Rehearsal

This document tracks the public-source Android rehearsal workflows for Decoy
Wallet. The debug workflow proves that the public repository can produce an
Android build with the same runtime configuration needed for device testing. The
signed workflow is the production-style rehearsal path for installing over an
existing release-signed Android app or submitting to Google Play testing.

## Workflow

CodeMagic workflows:

- `android-debug-rehearsal`
- `android-signed-release-rehearsal`

The workflow must run from:

- `decoywalletapp/decoy-wallet-open-source`

The debug workflow builds:

- `build/app/outputs/flutter-apk/app-debug.apk`

The signed release workflow builds:

- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

Firebase App Distribution can be re-enabled after the public CodeMagic app has a
service-account variable available to the workflow.

The signed release workflow requires the public CodeMagic app to have Android
keystore variables available in the `decoy_android_release_signing` secure
variable group.

## Secure Inputs

The public repository must not contain production backend URLs, Firebase files,
keystores, passwords, or service-account JSON. CodeMagic injects those values at
build time through secure variable groups:

- `decoy_public_runtime`
- `decoy_android_release_signing`

The signed release workflow expects these private signing variables in
CodeMagic only:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEYSTORE_TYPE` (optional)

The workflow generates these private build files only inside the CodeMagic
worker:

- `android/app/google-services.json`
- `android/app/release-keystore.jks`
- `android/key.properties`

Those generated files must never be committed.

## Provenance

Both Android rehearsal workflows inject public-source metadata into the app:

- `DECOY_SOURCE_REPOSITORY`
- `DECOY_SOURCE_REF`
- `DECOY_SOURCE_COMMIT`
- `DECOY_BUILD_CHANNEL`
- `DECOY_BUILD_PLATFORM`
- `DECOY_BUILD_VERSION`
- `DECOY_BUILD_NUMBER`
- `DECOY_BUILD_VERIFICATION`

The app Settings page should show the public commit used for the build. The
builds also write:

- `build/provenance/android-firebase-rehearsal.txt`
- `build/provenance/android-signed-release-rehearsal.txt`

## Device Test Goal

For Android device testing, install the CodeMagic artifact on a real Android
device and verify:

- the app launches and authenticates
- Settings shows the expected public commit
- account PIN and decoy PIN flows work
- decoy seed setup and alert behavior work
- emergency contact and location behavior work
- subscription screens and payment buttons route correctly

If the device already has a release-signed Decoy app installed, Android will not
replace it with the debug APK because the signing certificates differ. Use the
signed release APK for upgrade-style rehearsal testing, or uninstall the
existing app before installing the debug APK on a disposable test device.
