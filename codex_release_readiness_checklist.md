# Decoy Wallet Release Readiness Checklist

Last updated: 2026-05-09

Current known-good mobile checkpoint:

- `1c7873b`
- `chore: tighten release hygiene`

## Verified / Done

- Duress fake BTC dust displays as zero instead of showing tiny leftover value.
- Fake BTC seed persists for 24 hours and does not regenerate just because the fake balance is zero.
- Duress send/confirm flow uses the dust-zero behavior consistently.
- Emergency contact status push notifications work for confirmed, denied, opted out, and START re-opt-in paths.
- Website consent and opt-out links update backend status and trigger app push notifications.
- Twilio STOP and START inbound SMS sync contact state and push notification state.
- Payment backend calls from the app require authenticated user context.
- Abandoned Stripe checkout no longer schedules a Stripe takeover.
- Completed BTC-to-Stripe switch schedules the Stripe takeover date correctly.
- Stripe-to-Bitcoin handoff path tested.
- Alerts continue working during BTC-to-Stripe and Stripe-to-Bitcoin payment handoff timing.
- Expired/unpaid users are blocked from alert delivery.
- PIN trigger database path checks entitlements.
- Seed trigger database path simulated successfully for active paid, paid handoff, and expired states.
- Live Decoy Seed trigger tested successfully with BlueWallet using the intended on-chain restore, receive, and outbound-send flow.
- Blitz Wallet Lightning-to-on-chain test did not trigger; treat as a wallet-behavior compatibility caveat for future research, not a release blocker for the intended on-chain seed flow.
- Bitcoin subscription days stack from the existing paid-through date.
- Account deletion now routes through the payment backend, cancels/handles active Stripe billing first, then deletes Supabase app/account data.
- Account deletion was tested successfully with a disposable account after fixing the read-only `armed_decoy_seeds` view cleanup issue.
- CodeMagic/TestFlight upload now tolerates Apple's confirmed-success-after-500 uploader response.
- Recreating an account with the same email after account deletion resets local access state correctly.
- Push notification permission/token behavior tested successfully in TestFlight after the notification hardening build.
- Deep link return flow polish tested successfully in TestFlight after the payment return/password reset build.
- Password reset keyboard Next behavior tested successfully.
- Auth Router to PIN two-step fade tested successfully; Bitcoin Wallet / PIN text overlap no longer visible.
- Final active-account PIN alert sanity test passed after release-hygiene build.

## Next Release-Readiness Pass

1. Account deletion and data cleanup
   - Supabase account deletion RPC hardened on 2026-05-06.
   - Audit confirmed sensitive app-owned tables are now explicitly deleted or intentionally retained.
   - Intentionally retained: global SMS STOP suppressions, Stripe/BTCPay payment audit records, and a minimal deletion receipt.
   - Completed: app delete-account action now goes through the Stripe payment backend so active/pending Stripe subscriptions are canceled before account data is deleted.
   - Completed: disposable account deletion test passed on 2026-05-07.
   - Completed: same-email account recreation after deletion shows the unpaid/locked state correctly on 2026-05-07.

2. Returning user after entitlement loss
   - Completed: contact/person/address setup state remains available after entitlement loss and restoration.
   - Completed: expired entitlement blocks alert delivery; live seed spend did not send an alert while unpaid on 2026-05-07.
   - Completed: trigger settings intentionally disarm after entitlement loss.
   - Completed: paying again requires the user to intentionally rearm triggers.
   - Completed: after manually re-enabling the trigger switch, alert delivery works again without needing to re-save emergency contacts.
   - Baseline live Seed trigger check passed before continuing entitlement-loss testing.

3. Notification permission edge cases
   - Code hardening added: Control Center now refreshes notification permission/device token before saving push enabled.
   - Code hardening added: app startup refreshes the push device token for users whose backend setting already has push enabled.
   - Completed: basic Control Center save still works.
   - Completed: push allowed in iOS Settings stays enabled without warning.
   - Completed: push denied in iOS Settings shows the expected warning/settings path.
   - Completed: enabling push again from iOS Settings clears the warning after app refresh/save.
   - Completed: emergency PIN alert sanity check still sends after the push hardening build.

4. Deep links and return routes
   - Completed: payment return website button opens the app.
   - Completed: payment return route lands in the right app state.
   - Completed: password reset links route correctly.
   - Completed: email confirmation links route correctly.
   - Code polish added: payment return page shows Decoy logo first and only reveals manual Refresh after a 5-second fallback delay.
   - Code polish added: password create/reset copy and client-side floors preserve the intended 10-character minimum.
   - Code hardening added: subscription renewal push taps now navigate directly to Manage Subscription when the app is already unlocked, while preserving the cold-start fallback flag.
   - Completed: push tap for subscription renewal opens the Manage Subscription flow.
   - Completed: renewal push near expiration opens Manage Subscription and displays the expected remaining-days state.

4a. UI polish notes
   - Current transition baseline before this pass: Auth Router to PIN used a 300ms fade. User rated current transition feel about 6/10 and wants easy revert if the polish feels worse.
   - Code polish added: password reset first field uses keyboard Next to focus the confirm field.
   - Code polish added: Auth Router to PIN keeps fade style but shortens the fade to reduce visible page overlap during app open.
   - Completed: Auth Router to PIN now fades the router content to blank first, then fades in PIN, preserving the fade feel while preventing Bitcoin Wallet / PIN text overlap.
   - Code hardening added: app-level display guard prevents iOS Bold Text and enlarged system text size from resizing fixed Decoy Wallet layouts.

5. Emergency contact stale-state protection
   - Confirmed contacts receive alerts.
   - Denied contacts do not receive alerts.
   - Opted-out contacts do not receive alerts.
   - START re-opt-in contacts receive alerts again only after status is confirmed/active.

6. Account setup readiness gates
   - App should not visually imply emergency protection is armed unless required setup is complete.
   - PIN trigger setup should distinguish saved user preference from currently usable confirmed-contact routing.
   - Seed trigger setup should distinguish saved seed-monitor arming from currently usable confirmed-contact routing.
   - Decision: do not ship a destructive gate that flips armed trigger preferences off while contacts are pending confirmation.
   - Desired behavior: users may arm PIN contact alerts and seed monitor before a contact confirms; those preferences should become usable automatically once a contact confirms.
   - Conclusion: no app-code change shipped for this item; current behavior should be preserved unless a future audit finds a concrete break.
   - Completed: audit found no reason to change the current trigger preference behavior.

7. Release hygiene
   - Remove or justify debug/test-only code paths.
   - Check test pages exposed through app routing.
   - Review sensitive backend logging.
   - Confirm App Store/TestFlight build uses the intended workflow.
   - Code hardening added: disabled GoRouter diagnostic logging for release builds.
   - Code hardening added: removed direct production routing/export exposure for `lib/test_subjects` pages.
   - Code hardening added: removed the unused `debugSignUp` custom action export and source file.
   - Review result: no live Stripe/webhook/service-role secrets found committed in app code; Supabase anon client key is expected public client configuration.
- Review result: current `ios_release` CodeMagic workflow includes signing, notification entitlement verification, generated-code guardrails, timestamp build numbers, and App Store Connect upload retry/success detection.
- Completed: release-hygiene TestFlight smoke check passed; app opens, PIN unlock works, Settings opens, and Manage Access opens normally.

8. Legal documents
   - Code polish added: lawyer-provided final Terms of Service and Privacy Policy are centralized in app code so onboarding and Settings use the same legal copy.
   - Code polish added: lawyer-provided bold formatting and centered title/effective-date blocks are preserved from the Word documents.
   - Code polish added: onboarding Agreements Terms and Privacy pages now show the final documents instead of placeholder text.
   - Code polish added: Settings Terms of Use and Privacy Policy pages now show the final documents.
   - Code polish added: Decoy PIN and Decoy Seed acknowledgement final checkboxes now use readiness-focused wording instead of broad delivery-disclaimer wording.
   - Remaining: TestFlight display check for onboarding Terms/Privacy tab switching, scroll behavior, checkbox/Continue behavior, and Settings legal page navigation.

9. Display accessibility stress test
   - Code hardening added: Decoy Wallet now opts out of app-wide iOS Bold Text and Dynamic Type scaling to protect fixed graphic layouts for release.
   - Remaining: TestFlight check with iOS Settings > Display & Brightness > Bold Text enabled and large Text Size enabled.
   - Remaining: spot-check Choose Method, locked home, setup checklist, Emergency Contacts, Control Center, Settings, location permission, and Agreements pages.

## Current Next Item

Display accessibility stress test.
