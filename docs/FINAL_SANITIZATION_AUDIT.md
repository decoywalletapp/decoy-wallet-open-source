# Final Sanitization Audit

Audit date: 2026-07-18
Scope: `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-open-source`

## Summary

This worktree is prepared as a local public-source candidate for the Decoy
Wallet mobile app. It has not been published publicly.

## Checks Completed

- Verified the active branch is `codex/open-source-sanitization-20260713`.
- Confirmed production backend operations, `codex_backend_work/`, and a root
  `supabase/` migration folder are not tracked in this worktree.
- Confirmed real Firebase platform config files are absent and only example
  files remain:
  - `android/app/google-services.json.example`
  - `ios/Runner/GoogleService-Info.plist.example`
- Confirmed Android signing config is represented by
  `android/key.properties.example` only.
- Confirmed no tracked `build/`, `.dart_tool/`, APK, AAB, IPA, keystore,
  provisioning profile, or generated iOS environment files are present.
- Confirmed standard Gradle wrapper files are tracked so Android builds can use
  the pinned wrapper configuration.
- Removed one unreferenced AI-generated image with unclear publication value.
- Replaced the placeholder source license with a prepared MIT license.
- Added trademark and third-party notice files for Decoy brand materials and
  bundled fonts.
- Added a third-party asset review record for bundled fonts, Decoy brand assets,
  app icons, and third-party brand references.
- Removed avoidable third-party logo image assets for Bitcoin and Stripe.
  Settings social logo assets remain bundled for production UI parity and are
  tracked for manual trademark / redistribution review.
- Removed the unused generated icon font asset after replacing its only app
  usages with built-in Material location icons.
- Scanned for common credential patterns and live service hostnames. Findings
  were limited to documented placeholders in README and example files.
- Converted operator-specific support email, legal URL, billing return URL, and
  auth deep-link values to documented build-time configuration.
- Confirmed `flutter test` passes in the sanitized default configuration.
- Confirmed `git diff --check` reports no whitespace errors.

## Remaining Manual Review

- Approve the prepared MIT source-code license before public publication.
- Review bundled image and font assets for redistribution rights and required
  notices, using `THIRD_PARTY_NOTICES.md` and
  `docs/THIRD_PARTY_ASSET_REVIEW.md` as the tracking records.
- Review Decoy-owned legal copy, support contacts, and public social links.
- Decide whether public fork operators should replace bundle IDs, app names,
  app icons, social links, and deep-link schemes before shipping their own apps.
- Review generated FlutterFlow support code and dependency notices for any
  additional attribution requirements.
- Confirm the private production watcher has the stale confirmed transaction
  guard and regression coverage before public messaging claims current safety
  behavior.

## Verification Notes

`flutter analyze` still reports existing generated-code and dependency warnings
in the candidate. Those warnings were present outside the focused sanitization
changes and should be handled separately if the public release requires a clean
analyzer run.
