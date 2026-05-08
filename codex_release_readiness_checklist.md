# Decoy Wallet Release Readiness Checklist

Last updated: 2026-05-08

Current known-good mobile checkpoint:

- `9e8c815`
- `fix: polish deep link return flows`

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
   - Remaining: push tap for subscription renewal opens the manage subscription flow.

4a. UI polish notes
   - Current transition baseline before this pass: Auth Router to PIN used a 300ms fade. User rated current transition feel about 6/10 and wants easy revert if the polish feels worse.
   - Code polish added: password reset first field uses keyboard Next to focus the confirm field.
   - Code polish added: Auth Router to PIN keeps fade style but shortens the fade to reduce visible page overlap during app open.
   - Follow-up code polish added: Auth Router to PIN now fades the router content to blank first, then fades in PIN, preserving the fade feel while preventing Bitcoin Wallet / PIN text overlap.

5. Emergency contact stale-state protection
   - Confirmed contacts receive alerts.
   - Denied contacts do not receive alerts.
   - Opted-out contacts do not receive alerts.
   - START re-opt-in contacts receive alerts again only after status is confirmed/active.

6. Account setup readiness gates
   - App should not visually imply emergency protection is armed unless required setup is complete.
   - PIN trigger setup gate should require valid contact/911 preferences.
   - Seed trigger setup gate should require seed arming plus contact readiness.

7. Release hygiene
   - Remove or justify debug/test-only code paths.
   - Check test pages exposed through app routing.
   - Review sensitive backend logging.
   - Confirm App Store/TestFlight build uses the intended workflow.

## Current Next Item

Deep links and return routes polish build.
