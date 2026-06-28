# Android Open Testing Checklist

## Local build artifact

- Upload this App Bundle to Play Console testing:
  `build/app/outputs/bundle/release/app-release.aab`
- Current Android package name:
  `com.decoywalletapp.app`
- Current version:
  `1.0.1 (10001)`
- Upload signing key is local only and must not be committed.
- Local signing config is ignored at:
  `android/key.properties`

## Play Console flow

1. Open Google Play Console.
2. Create the Android app record if it does not already exist.
3. Use package name `com.decoywalletapp.app`.
4. Enable Play App Signing when prompted.
5. Go to Testing > Open testing.
6. Create or resume the open testing release.
7. Upload `build/app/outputs/bundle/release/app-release.aab`.
8. Set testers to unlimited if a public beta join link is desired.
9. Confirm countries/regions are enabled.
10. Submit the open testing change for Google review.
11. Install from the Play testing link and run the full smoke test after Google publishes the change.

## Open testing smoke test

- Fresh install from the Google Play open testing link.
- Existing account login.
- New account creation.
- Email confirmation deep link.
- Phone verification.
- PIN creation and unlock.
- Personal information load/save across devices.
- Emergency contacts load/save and consent status.
- Decoy PIN arm/disarm and alert trigger.
- Decoy seed creation, arm, transaction trigger, and SMS delivery.
- Settings pages: change PIN, change phone, change email, support ticket, delete account.

## Release blockers before public rollout

- Confirm Play Console app listing content rating, privacy policy, data safety, and production access requirements.
- Confirm Firebase/FCM Android app is configured for `com.decoywalletapp.app`.
- Confirm app links are verified for email confirmation/reset flows.
- Confirm the watcher health alert email is receiving failures.
- Confirm at least one full end-to-end alert test from the Play-installed build.
