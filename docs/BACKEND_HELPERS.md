# Backend helpers in this repository

The `backend/` directory holds **published helper scripts and regression tests**
for operators reviewing Decoy's public source. It is not the full production
payment, alert, or seed-monitoring stack.

## Layout

| Path | Purpose |
| --- | --- |
| `backend/membership_redemption/` | Membership code redemption helpers, Stripe promo sync adapters, route registration tests, staging/production smoke scripts |
| `backend/account_deletion/` | Account-deletion foreign-key cleanup regression (PGlite-based) |

Each subdirectory has its own `README.md` with environment variables and
verification steps.

## Safe local checks

No `npm install` is required. Node 18+ with built-ins:

```sh
node --test backend/membership_redemption/*.test.mjs
```

Account deletion tests need PGlite; see `backend/account_deletion/README.md`.

## Do not run from casual review

Scripts ending in `.command`, production canary/smoke modules, and anything that
reads `SUPABASE_SERVICE_ROLE_KEY` or Stripe live secrets mutate or probe live
systems. Run those only in an operator-controlled environment with the matching
credentials.
