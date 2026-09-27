# App Language Support

## Scope and Release Gate

This is an unreleased English/Spanish localization feature, based on the verified
1.1.4 source commit `3b3082f574df83ff92cf3ae2762de9cce2fcb3da`. The test build is
version 1.1.5. TestFlight and signed Android test artifacts do not deploy a backend
or submit a public store release.

Language selection is available on Login, Create Account, and Settings. It updates
the interface immediately and is saved on the device, independent of account,
subscription, PIN, monitoring, and emergency-contact settings. The default follows
the device language, with English as the fallback for unsupported languages.
Translation catalogs ship with the app; selecting a language requires no network
request or external translation service.

The first pass covers in-app authentication, onboarding, PIN screens, settings,
contact forms, subscription controls, monitoring setup, and simulated-wallet UI.
This is not a claim that every language or every externally supplied message is
translated. Further languages require reviewed catalogs and layout/font testing;
right-to-left languages also require a directionality review.

Still English or unchanged by design:

- Counsel-authored legal document bodies, pending approved translations.
- SMS, email, browser checkout/redemption pages, and tutorial media.
- Server-supplied errors, monitor titles/details, and some dynamic status copy.
- Bitcoin seed words, keys, addresses, protocol values, amounts, and user data.
- Existing numeric input/format behavior. Do not translate values sent to APIs.

Spanish copy needs review by a fluent speaker, particularly safety and consent
wording, before public release. Native iPhone and Android tests remain a release
gate. Automated tests are not a guarantee of live alert delivery.

## Implementation

- `lib/l10n/app_en.arb` is the source catalog; `app_es.arb` is Spanish.
- `flutter gen-l10n` generates the localization classes beside the catalogs.
- `AppLanguageController` stores only `app_language` in SharedPreferences.
- `LanguagePickerButton` and `showLanguagePicker` provide the shared selection UI.
- `main.dart` provides the controller and locale to the existing app/router.
- iOS advertises English and Spanish in `CFBundleLocalizations`.
- Login/signup use the existing bundled Roboto font for labels/buttons instead
  of fetching those fonts at runtime. Narrow-screen text may wrap.
- Signup no longer disposes focus nodes owned by its Autocomplete widgets; screen
  teardown tests exposed that pre-existing ownership issue.

Backend clients/actions, alert payload construction, PIN checks, wallet derivation,
payment actions, app-state persistence, and build workflows are unchanged. Only
display labels were localized in those screens. In particular, never translate a
stored status constant, route name, key prefix, or network identifier.

## Tests

Run the ordinary regression suite:

```sh
flutter pub get
flutter gen-l10n
flutter test --no-pub
flutter analyze --no-pub
```

The dedicated PIN widget tests deliberately require test-only endpoints. They
mock all requests and verify the actual PIN page in both languages without
sending messages or touching production:

```sh
flutter test --no-pub test/localized_pin_navigation_test.dart \
  --dart-define=DECOY_SUPABASE_URL=https://test.invalid \
  --dart-define=DECOY_FIREBASE_FUNCTIONS_BASE_URL=https://test.invalid \
  --dart-define=DECOY_ALERT_BASE_URL=https://test.invalid \
  --dart-define=DECOY_DATA_KEY_BASE_URL=https://test.invalid/unwrap
```

These cover normal/incorrect/decoy PIN routing, optional personal information,
missing contacts, unconfirmed contacts, and the confirmed-contact alert payload.
The regular suite also covers preference persistence, form state across language
changes, catalog completeness, xpub/zpub/address behavior, and existing billing
and monitoring regression guards.

`localized_screens_test.dart` checks six entry/settings/wallet pages in both
languages at 320, 402, and 768 logical-pixel widths, including login/signup with
keyboard insets. For optional local screenshot capture, add
`--dart-define=DECOY_CAPTURE_LOCALIZATION=true`. Widget screenshots are not native
device screenshots and do not replace device testing.

## Device Acceptance Before Release

Local verification on 2026-09-27: 120 regression tests passed, plus 16 isolated
PIN tests. The 36 layout combinations are included in those 120 tests. Static
analysis reported no errors and 73 existing warnings/informational diagnostics;
this change does not attempt unrelated cleanup. No native build was distributed.

1. Choose Spanish on Login, Create Account, and Settings. Switch back to English.
   Confirm typed form values remain and no page unexpectedly navigates.
2. Force-close and reopen. Confirm the selected language persists. Check device
   language mode with English, Spanish, and an unsupported language.
3. On dedicated test accounts, confirm ordinary PIN and decoy PIN routing in both
   languages, with optional profile information absent and present.
4. With a consenting test contact, verify an emergency alert arrives with the
   expected recipient/location. Confirm unconfirmed contacts are not alerted.
5. Verify existing monitored keys/addresses and arm states remain unchanged.
   Do not alter real users' monitors for this check.
6. Check subscription access and redemption return flows without changing real
   customer billing. Existing server checkout pages remain in their own language.
7. Inspect small-phone/tablet layouts, keyboard visibility, large text settings,
   long translated labels, legal pages, and all four simulated-wallet subpages.

## Adding a Language

Add a reviewed `app_<language>.arb` catalog with the same keys/placeholders, run
`flutter gen-l10n`, add the language to the controller and picker, and update iOS
bundle localizations. Extend catalog and UI tests for that language. Native names
belong in the picker; do not use country flags to represent languages.
