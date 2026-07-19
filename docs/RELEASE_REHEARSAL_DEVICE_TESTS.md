# Release Rehearsal Device Tests

Use this checklist before treating a public-source CodeMagic build as a release
candidate. The goal is to confirm that a build from the public repository can be
installed on real devices, preserves current-user behavior, and displays the
public source commit compiled into the app.

This checklist is for controlled testing only. Use test accounts, consenting
test contacts, and known test addresses. Do not involve emergency services or
non-consenting contacts.

## Seven-Hour Triage Plan

When testing time is tight, run P0 tests first. P1 tests come next if P0 is
clean. P2 tests are polish and confidence checks.

1. First hour: install the public-source build on one fresh iPhone and one fresh
   Android device, then verify startup, login, source provenance, and core
   settings.
2. Next two hours: run the main safety flows, including PIN, decoy seed, alert
   signaling, contact setup, and location permission states.
3. Next two hours: test upgrade behavior from the current store or internal
   testing app to the public-source rehearsal build on both platforms.
4. Final two hours: repeat the highest-risk flows on a second device or OS
   version, check logs/crashes, and document any release blockers.

## P0 Release Blockers

Do not ship if any P0 item fails.

- The build installs from TestFlight or Google Play internal testing on a real
  device.
- The app opens without crashing after a fresh install.
- The app opens without crashing after replacing the current App Store or Google
  Play/internal-testing build.
- Existing user state survives an upgrade: auth state, required settings,
  contacts, watch-only receive addresses, PIN setup, and stored decoy seed data.
- Settings > Source Verification shows the public repository, selected ref,
  public commit, build channel, platform, version, build number, and rehearsal or
  release status.
- The in-app public commit matches the CodeMagic build commit and the GitHub
  commit.
- A fresh user can complete onboarding and reach the main app.
- An existing user can sign in, lock, unlock, close the app, reopen it, and
  still unlock.
- Correct PIN behavior works.
- Wrong PIN behavior works and does not reveal sensitive screens.
- Any intentional duress PIN or trigger behavior works exactly as designed.
- Decoy seed generation works on a fresh account.
- Stored decoy seed data remains available after app restart.
- Seed reveal/hide/copy or equivalent actions behave as intended.
- Watch-only receive addresses can be added, displayed, persisted, and removed
  according to the current product design.
- Alert signaling succeeds with a controlled test contact.
- Alert signaling does not duplicate the same alert unexpectedly.
- Alert signaling failure shows a recoverable state when network connectivity is
  poor or unavailable.
- Trusted-contact setup, edit, and delete flows work.
- Location permission denied, approximate, precise, and later-changed states do
  not crash the app.
- Location is used only in the intended alert or safety contexts.
- Payment, entitlement, restore purchase, and billing return flows work if the
  tested build includes paid access logic.
- Password reset, email confirmation, and deep-link return flows work.
- Legal, privacy, support, and tutorial links open the intended public
  destinations.
- App logs and visible error messages do not expose seed data, PIN values,
  precise location, contact data, auth tokens, or backend credentials.

## P1 Confidence Tests

- Repeat P0 fresh-install testing on a second iOS version and a second Android
  version when devices are available.
- Test app behavior after force quit, reboot, airplane mode, and network changes.
- Test notification permission accepted and denied states.
- Test background-to-foreground behavior during an alert flow.
- Test biometric unlock if enabled by the product.
- Test account deletion or sign-out if enabled by the product.
- Confirm every external URL uses the intended public domain.
- Confirm any crash reporting, analytics, or performance tooling is configured
  without capturing sensitive payloads.
- Confirm app-store build number and version match the planned release notes.
- Confirm TestFlight or internal testing notes clearly identify the public
  commit under test.

## P2 Polish Checks

- Check main screens for obvious layout regressions on small and large devices.
- Check dark mode or accessibility text scaling if supported.
- Check copy on safety-critical screens for clarity.
- Check that Source Verification text fits on smaller phones.
- Check that release notes explain this is a public-source provenance build when
  appropriate.

## Rehearsal Sign-Off

Record these values for each successful rehearsal:

```text
Platform:
Device:
OS version:
Install path: TestFlight / Google Play internal testing / sideload
App version:
Build number:
Public repository:
Public ref:
Public commit:
CodeMagic build URL:
CodeMagic build ID:
Tester:
Date:
P0 result:
P1 result:
Known follow-ups:
```

For production releases, tag the exact public commit, build from that tag, and
publish the tag and commit in the store release notes.
