# Decoy Wallet Release Readiness Checklist

Last updated: 2026-05-06

Current known-good mobile checkpoint:

- `0ac966d7dceb47f98d435c0fb994cb59512d9604`
- `fix: keep access active during payment handoff`

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
- Bitcoin subscription days stack from the existing paid-through date.

## Next Release-Readiness Pass

1. Account deletion and data cleanup
   - Supabase account deletion RPC hardened on 2026-05-06.
   - Audit confirmed sensitive app-owned tables are now explicitly deleted or intentionally retained.
   - Intentionally retained: global SMS STOP suppressions, Stripe/BTCPay payment audit records, and a minimal deletion receipt.
   - In progress: app delete-account action is being moved through the Stripe payment backend so active/pending Stripe subscriptions are canceled before account data is deleted.
   - Remaining validation: deploy backend, publish mobile build, then test actual deletion with a disposable user only.

2. Returning user after entitlement loss
   - Confirm contact/person/address data remains available.
   - Confirm trigger settings intentionally disarm after entitlement loss.
   - Confirm paying again requires the user to intentionally rearm triggers.
   - Confirm no re-save of emergency contacts is required once triggers are rearmed.

3. Notification permission edge cases
   - User denies push permission during onboarding.
   - User enables push later from settings/control center.
   - User disables push in iOS Settings.
   - User reinstalls app and receives a new device token.

4. Deep links and return routes
   - Payment return website button opens the app.
   - Payment return route lands in the right app state.
   - Push tap for subscription renewal opens the manage subscription flow.
   - Password reset and email confirmation links route correctly.

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

Account deletion and data cleanup.
