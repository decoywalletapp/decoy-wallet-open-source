# Decoy Staging Parity Checklist

This document defines the staging lane for testing Decoy app and backend changes
without touching production users.

## Goal

Before a feature reaches production, it should run against staging services that
behave like production for app flows but do not send real emergency SMS, mutate
production users, charge production payments, or alter production monitoring.

## Why staging is not one switch

Decoy depends on several independent systems:

- Flutter app build-time config
- Supabase Auth settings
- Supabase database schema and RLS policies
- Supabase Edge Functions
- Firebase/Google Cloud helper endpoints
- Payment helper endpoints
- Alert delivery endpoints
- CodeMagic environment groups
- App deep links and email redirect allowlists

The repo can enforce app-side routing and compile-time configuration, but some
settings are dashboard-managed and do not exist in Git. Those dashboard values
must be mirrored intentionally.

## Current staging project

- Supabase project ref: `dxsihfandgbrkreeokkm`
- Backend environment flag: `DECOY_BACKEND_ENV=staging`
- Watch-only feature gate: `DECOY_ENABLE_WATCH_ONLY_IMPORT=true`
- Staging helper function root:
  `https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api`

## App-side guardrails

The app validates backend wiring on launch.

For staging builds:

- `DECOY_SUPABASE_URL` must point to the staging Supabase project.
- Firebase compatibility calls must point to `staging-api/firebase`.
- Alert calls must point to `staging-api/alerts`.
- Data-key calls must point to `staging-api/data-key`.
- Payment calls must point to `staging-api/payment`.
- Verify-link calls must point to
  `https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/verify-link`.
- Email confirmation must use the staging verify-link bridge when an HTTPS
  confirmation URL is configured, then redirect back into the app deep link.
- Email confirmation and app deep links must not point at localhost.
- Staging AuthRouter shows the current routing step while loading so auth
  failures do not look like a silent app freeze.

For production builds:

- Production config must not point at the staging Supabase project.
- Production config must not point at any `staging-api` route.

## Dashboard-only parity work

These items cannot be completely fixed by code alone and must be verified in
the corresponding dashboards.

Supabase Auth:

- Staging app/site URL is not `localhost`.
- Staging redirect allowlist includes the staging verify-link function URL when
  that function is used as an email confirmation landing page.
- Staging redirect allowlist includes the Decoy app deep link used by TestFlight
  and Android test builds.
- Email templates use Decoy wording, not the default Supabase branding.
- Sender/from configuration is set for staging if branded email delivery is
  required during tests.

Supabase database:

- Staging schema includes every table, column, index, RPC, and RLS policy needed
  by the current production app flows.
- Staging has test users only.
- Staging does not contain production user records.

Supabase functions:

- Staging functions are deployed to the staging project.
- Function secrets point only at staging/test providers.
- Helper routes keep Supabase gateway JWT verification enabled.
- The staging `verify-link` function is the only no-gateway-JWT exception,
  because it receives browser/email clicks before a user session exists. It must
  only redirect back into the app and must not perform backend writes.
- Staging alert functions record test alert logs but do not send live emergency
  SMS unless explicitly configured for a narrow test.

CodeMagic:

- Staging TestFlight and Android rehearsal workflows use staging environment
  groups.
- Staging builds visibly show `Backend: staging`.
- Production release workflows use production environment groups.
- Production app-store submissions are not made from staging builds.

## Acceptance gate before production

Do not promote a feature to production until these checks pass:

- Fresh signup works in staging.
- Email confirmation returns to the app and exits AuthRouter.
- Login works for an existing staging user.
- Phone verification flow works with staging-safe behavior.
- Subscription/access flow works with staging-safe entitlement behavior.
- Generated Decoy Seed flow still works.
- Imported watch-only xpub/zpub flow works.
- Imported address-list flow works.
- Alert-path dry run records the expected staging alert event.
- No staging function sends production SMS.
- The app settings page shows `Backend: staging`.
- Production users and production backend settings were not changed during test.

## Production cutover rule

When a feature is validated in staging, make a small production patch that
changes only the intended feature code or backend function. Deploy production
backend changes behind a narrow switch whenever possible, then publish mobile
builds only after the production candidate has passed the same smoke tests.
