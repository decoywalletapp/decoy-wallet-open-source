# Redemption Regression Checklist

Use dedicated test accounts where possible. Successful redemption tests consume a single-use code.

## Core redemption

1. Create and verify a new account, complete onboarding without purchasing, and open **Redeem Code** from subscription options.
2. Confirm the browser page uses the Bebas Neue wordmark, the white gift-card icon, and the **Redemption Code** and **Subscription code** labels without clipping.
3. Enter a valid code without dashes and confirm dashes and capitalization are applied automatically.
4. Redeem an unused code, confirm 365 days are added, return to the app, and verify the app refreshes with access unlocked.
5. Force-close and reopen the app and verify the redeemed access remains active.

## Failure handling

6. Re-enter the redeemed code and confirm it is rejected without adding time.
7. Enter an invalid code and confirm a clear error appears without changing the account expiration.
8. Enter an incomplete code and confirm redemption is blocked or rejected cleanly.
9. Open the redemption page, return without redeeming, and confirm no access or entitlement changes.

## Stacking

10. Redeem two unused promotional codes on one test account and confirm the second adds another 365 days instead of replacing the first year.
11. Make a small Bitcoin subscription purchase after redemption and confirm purchased time begins after promotional access.
12. Redeem a code on an account with Bitcoin-paid access and confirm 365 days are added after the existing expiration.
13. Redeem a code on an active Stripe test subscription and confirm access remains active, Stripe is not canceled, no immediate charge occurs, and paid billing resumes after promotional access.

## Regression checks

14. Sign into an existing paying customer account without redeeming and confirm its original access, expiration, and payment provider remain unchanged.
15. Confirm **Redeem Code** appears in initial subscription options and **Manage Subscription**, while Bitcoin and Stripe payment options still open normally.
16. Confirm existing emergency contacts remain present, send one confirmation-link test, and trigger one known-good address or extended-public-key monitor. Verify the alert includes the recipient address.
17. Repeat the redemption-page opening and return-to-app test on iPhone and Android, including a smaller screen with the keyboard open.

Minimum release gate: tests 1-9 and 14-17, plus either test 11 or 12 for Bitcoin stacking.
