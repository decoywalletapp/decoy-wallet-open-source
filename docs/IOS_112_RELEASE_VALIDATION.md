# iOS 1.1.2 Release Validation

## Incident and Scope

Builds 20260921010845 and 20260921021253 used source commit
6fd555c366ac79b0fdf6f9a55bd7d310586ebe52. The TestFlight workflow enabled
DECOY_ENABLE_WATCH_ONLY_IMPORT, but the App Store workflow omitted it. The
default false value hid Monitor Existing Wallet and disabled its import route.

The replacement enables that flag in the App Store workflow. Automated checks
require identical iOS Dart build settings, explicitly enabled import in all
four mobile workflows, and enabled UI tests before each iOS build. Phone and
iPad widget tests open the real import form. App Store submission stays manual.
No application logic, backend service, or database change is required for this
release-configuration fix.

## Artifact Gate

- Do not resubmit build 20260921021253.
- Record the replacement's full build number, source commit, and Codemagic URL.
- Test the replacement from the corrected iOS App Store Release workflow.
- Submit that exact tested build, not a newly rebuilt equivalent.
- A later source or build-setting change requires a new candidate and testing.
- Automated tests do not establish that live SMS delivery works.

## Device Tests, In Order

Use dedicated accounts, consenting test contacts, and wallets you control. Keep
any emergency-service integration disabled. Never paste private keys or seed
phrases into watch-only import. Record pass/fail separately for each item.

1. **Build identity and missing feature.** Install the replacement through
   TestFlight. Record the full build number and Settings source commit. Open
   Decoy Emergency Setup > Decoy Keys. Confirm both Generate Seed Phrase and
   Monitor Existing Wallet appear. Open Monitor Existing Wallet and confirm
   the zpub/xpub/receive-address input is usable. Stop here if it is missing.
2. **Existing-account preservation.** On a dedicated existing paid account,
   compare access/expiration, confirmed contacts, saved monitors and their
   enabled states before and after upgrade and force-close/reopen. Do not
   delete or replace existing monitors to make this pass.
3. **Watch-only setup.** Add a fresh test zpub and a separate receive-address
   monitor. If xpub import is used, test it separately too. Confirm each saves,
   appears in monitor management, and persists after restart. Invalid public
   data should be rejected without changing existing monitors. Confirm merely
   opening or saving setup does not send an emergency alert.
4. **Live monitor delivery.** With the intended monitor and master control
   enabled, perform a small controlled outgoing transaction from the monitored
   test wallet to another wallet you control. After the usual confirmation
   requirement, verify the consenting contact receives the expected alert,
   including the recipient receive address. Record transaction ID and times
   privately. Validate the receive-address monitor separately from zpub.
   Confirm no duplicate alert for the same event.
5. **Contacts and PIN alert.** Confirm a consent-link text arrives, the link
   works, and confirmed status survives restart. Separately test the emergency
   PIN with a warned, consenting contact and verify the expected alert and
   disguised wallet route. Check ordinary PIN entry does not send that alert.
6. **Access smoke check.** Confirm existing paid and redeemed access persists
   after restart. Repeat Bitcoin/promo stacking checks on dedicated accounts
   per redemption-regression-checklist.md before final release sign-off.
   Do not alter a real customer's billing for a test.
7. **Account lifecycle.** On a disposable test account only, verify account
   deletion completes and the deleted account cannot sign in. Recheck email
   confirmation and onboarding on a fresh account if these have not yet been
   validated on this candidate.
8. **UI preservation.** Check Settings, balance configuration, simulated wallet
   pages, permission-page scrolling, and the centered contact-2 resend button.
   Repeat the import-entry and layout checks on iPad.

Any failed safety-critical or access test blocks submission. The earlier test
results remain useful history but do not substitute for checking the exact
replacement artifact. Store test results privately; do not commit customer
details, wallet keys, phone numbers, or redeemable codes here.
