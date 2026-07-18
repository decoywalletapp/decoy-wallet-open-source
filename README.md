# Decoy Wallet App

Decoy Wallet is a personal safety app disguised as a Bitcoin-wallet-style
interface. The app is designed to help a user discreetly prepare trusted-contact
alert workflows for dangerous situations.

This repository contains the Flutter mobile app source. Production deployment
scripts, live backend operations, signing material, and service credentials are
not part of this public source tree.

## What is included

- Flutter app UI and app logic
- Android and iOS project shells
- Generated FlutterFlow support code used by the app
- Example configuration files for setting up your own Firebase and Supabase
  projects

## What is not included

- Live production credentials
- App Store or Google Play signing material
- Production Cloud Run, Supabase, Twilio, Stripe, BTCPay, or QuickNode
  deployment scripts
- Production decoy seed watcher source, operational policies, live monitoring
  scripts, or alerting runbooks
- Private operational runbooks
- User data

## Backend scope

This public source tree is intended for mobile app transparency and review. It
does not include the production backend services that operate Decoy Wallet's
alert delivery, payment handling, phone verification, or decoy seed monitoring.

Anyone running an independent deployment must provide and audit their own
backend infrastructure. In particular, decoy seed monitoring requires careful
watch-only Bitcoin address scanning, stale-transaction protection, idempotent
alert delivery, and operational health monitoring. Do not treat this repository
alone as a complete production safety system.

## Local setup

This app needs Firebase and Supabase configuration to run against a real
backend. Copy the example files and provide your own project values:

```sh
cp android/app/google-services.json.example android/app/google-services.json
cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
```

Then pass Supabase and Firebase values at build time:

```sh
flutter run \
  --dart-define=DECOY_SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=DECOY_SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=DECOY_FIREBASE_CONFIGURED=true \
  --dart-define=DECOY_FIREBASE_WEB_API_KEY=your-web-api-key \
  --dart-define=DECOY_FIREBASE_WEB_AUTH_DOMAIN=your-project.firebaseapp.com \
  --dart-define=DECOY_FIREBASE_PROJECT_ID=your-project-id \
  --dart-define=DECOY_FIREBASE_STORAGE_BUCKET=your-project.appspot.com \
  --dart-define=DECOY_FIREBASE_MESSAGING_SENDER_ID=your-sender-id \
  --dart-define=DECOY_FIREBASE_WEB_APP_ID=your-web-app-id \
  --dart-define=DECOY_FIREBASE_FUNCTIONS_BASE_URL=https://your-functions-host \
  --dart-define=DECOY_ALERT_BASE_URL=https://your-alert-service \
  --dart-define=DECOY_DATA_KEY_BASE_URL=https://your-data-key-service \
  --dart-define=DECOY_PAYMENT_BASE_URL=https://your-payment-service \
  --dart-define=DECOY_VERIFY_BASE_URL=https://your-password-reset-verifier \
  --dart-define=DECOY_EMAIL_CONFIRM_URL=https://your-email-confirm-url \
  --dart-define=DECOY_EMAIL_CONFIRM_DEEP_LINK=decoywalletapp://confirm-email \
  --dart-define=DECOY_LEGAL_BASE_URL=https://your-public-legal-site \
  --dart-define=DECOY_SUPPORT_EMAIL=support@example.com \
  --dart-define=DECOY_BILLING_RETURN_URL=https://your-public-site/open \
  --dart-define=DECOY_TUTORIAL_VIDEO_BASE_URL=https://your-video-bucket
```

Public Decoy release builds also inject source provenance values so users can
compare the installed app with a public GitHub tag or commit:

```sh
--dart-define=DECOY_SOURCE_REPOSITORY=https://github.com/decoywalletapp/decoy-wallet-open-source
--dart-define=DECOY_SOURCE_REF=android-v1.0.5+10005
--dart-define=DECOY_SOURCE_COMMIT=<public-git-commit-sha>
--dart-define=DECOY_BUILD_CHANNEL=codemagic
--dart-define=DECOY_BUILD_PLATFORM=android
--dart-define=DECOY_BUILD_VERSION=1.0.5
--dart-define=DECOY_BUILD_NUMBER=10005
--dart-define=DECOY_BUILD_VERIFICATION=store-release
```

See `docs/BUILD_PROVENANCE.md` for the release-tagging and verification model.

For Android release builds, create `android/key.properties` locally with your
own signing key details. Do not commit signing files or service credentials.

The Android manifest uses `example.com` as the placeholder web deep-link host
for email confirmation. Replace that with your own verified domain before
shipping an Android build. Fork operators should also replace bundle IDs, app
names, support contacts, legal URLs, billing return URLs, and deep-link schemes
with values they control.

## Security note

The public app source is only one part of the Decoy system. Backend alert
delivery, payment handling, phone verification, and monitoring infrastructure
must be deployed and audited separately before running a production service.

## Public release status

This repository is Decoy Wallet's sanitized public-source mobile app tree. The
source-code license is MIT, with Decoy Wallet brand materials handled separately
in `TRADEMARKS.md`. See `docs/BUILD_PROVENANCE.md`,
`docs/PUBLIC_GITHUB_LAUNCH_GUARDRAILS.md`,
`docs/FINAL_SANITIZATION_AUDIT.md`, `THIRD_PARTY_NOTICES.md`, and
`docs/THIRD_PARTY_ASSET_REVIEW.md` for the publication and verification model.
Do not make the private development repository public, fork it, or import it
into a public repository.
