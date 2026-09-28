# Watch-Only QR Input

The QR icon inside Monitor Existing Wallet opens the existing native scanner.
A successful scan replaces the input field with the raw QR text. It does not
convert keys, validate data, create a draft, arm monitoring, or send an alert.
The existing Continue action still performs the existing import validation and
duplicate check. Accepted import formats have not changed.

Cancellation, blank results, permission denial, and scanner errors leave the
current field contents untouched. Camera access is requested before launching
the scanner because the existing iOS scanner does not complete its result on
permission denial. The iOS Podfile enables the permission handler's camera
check. No new dependency is required.

## Automated Checks

```sh
flutter test --no-pub test/watch_only_qr_import_test.dart \
  --dart-define=DECOY_ENABLE_WATCH_ONLY_IMPORT=true \
  --dart-define=DECOY_SUPABASE_URL=https://test.invalid
```

These tests mock the native camera and HTTP calls. They cover exact text fill,
permission/cancellation/error handling, unchanged import validation, disposal,
and layout in all 18 supported languages. They do not test physical QR decoding.

## Device Checks Before Release

- On iOS and Android, scan plain-text xpub, zpub, and receive-address QRs.
- Confirm the complete scanned text appears and nothing is imported until
  Continue is tapped. Use public test wallet data only.
- Cancel a scan and verify existing text is retained.
- Deny camera access, enable it in device settings, then retry.
- Check the torch, back/cancel control, and opening the scanner with the keyboard
  visible on a small screen.
- Animated QR exports and wallet-specific encoded exports are not added by this
  change. The scanner fills text; it does not decode additional wallet formats.
