# CodeMagic TestFlight Rehearsal

This document describes the first iOS rehearsal build from Decoy Wallet's public
source repository. The goal is to prove that the public source can produce a
signed TestFlight candidate with source provenance visible in the app.

This is not a production App Store release.

## Safety Boundaries

- Run the workflow from `decoywalletapp/decoy-wallet-open-source`.
- Do not connect CodeMagic to the private Decoy development repository for this
  rehearsal.
- Do not commit signing files, provisioning profiles, API keys, Firebase plist
  files, Supabase values, or backend credentials.
- Keep the build manual-only until the rehearsal has passed on a real device.
- Upload to App Store Connect/TestFlight only. Do not submit to App Store
  review from this workflow.

## CodeMagic Setup

Create or open the CodeMagic app connected to the public GitHub repository.
CodeMagic uses `codemagic.yaml` from the repository root. Because this workflow
has no `triggering` section, it is manual-only and must be started from the
CodeMagic UI.

Add an App Store Connect integration in CodeMagic named:

```text
DecoyWallet Codemagic
```

The App Store Connect API key should have App Manager permission. CodeMagic will
use this integration for iOS signing and for uploading the `.ipa` to App Store
Connect.

Create these CodeMagic environment groups:

```text
decoy_public_runtime
decoy_ios_testflight
```

`decoy_public_runtime` should contain the public runtime values used by the app:

```text
DECOY_SUPABASE_URL
DECOY_SUPABASE_ANON_KEY
DECOY_FIREBASE_WEB_API_KEY
DECOY_FIREBASE_WEB_AUTH_DOMAIN
DECOY_FIREBASE_PROJECT_ID
DECOY_FIREBASE_STORAGE_BUCKET
DECOY_FIREBASE_MESSAGING_SENDER_ID
DECOY_FIREBASE_WEB_APP_ID
DECOY_FIREBASE_FUNCTIONS_BASE_URL
DECOY_ALERT_BASE_URL
DECOY_DATA_KEY_BASE_URL
DECOY_PAYMENT_BASE_URL
DECOY_VERIFY_BASE_URL
DECOY_EMAIL_CONFIRM_URL
DECOY_EMAIL_CONFIRM_DEEP_LINK
DECOY_LEGAL_BASE_URL
DECOY_SUPPORT_EMAIL
DECOY_BILLING_RETURN_URL
DECOY_TUTORIAL_VIDEO_BASE_URL
```

`decoy_ios_testflight` should contain the iOS/App Store Connect values:

```text
APP_STORE_APPLE_ID
IOS_FIREBASE_API_KEY
IOS_FIREBASE_SENDER_ID
IOS_FIREBASE_PROJECT_ID
IOS_FIREBASE_STORAGE_BUCKET
IOS_FIREBASE_APP_ID
```

The iOS bundle id is `com.decoywalletapp.app`.

## Running The Rehearsal

1. Open the public-repo app in CodeMagic.
2. Select the `iOS TestFlight Rehearsal` workflow.
3. Select the public source branch or tag you want to test.
4. Start the build manually.
5. Wait for CodeMagic to upload the `.ipa` to App Store Connect.
6. In App Store Connect, make the processed build available to internal
   TestFlight testers.
7. Install the build from TestFlight on a real iPhone.
8. Open Decoy Settings and check Source Verification.

The Settings values should show:

```text
Source: decoywalletapp/decoy-wallet-open-source
Ref: the selected public branch or tag
Commit: the public commit built by CodeMagic
Build: codemagic / ios
Status: testflight-rehearsal
```

The CodeMagic artifacts also include:

```text
build/provenance/ios-testflight-rehearsal.txt
```

Use that file to compare CodeMagic's build metadata with the in-app Settings
metadata.

## Expected First-Failure Areas

If the first rehearsal fails, the likely causes are:

- CodeMagic is connected to the wrong repository.
- The App Store Connect integration name does not match
  `DecoyWallet Codemagic`.
- The Apple signing certificate or provisioning profile is missing in
  CodeMagic/App Store Connect.
- One of the required environment variables is missing.
- App Store Connect rejects the build number because a newer number already
  exists.

Fix those in CodeMagic or App Store Connect. Do not add credentials or generated
release files to the public repository.
