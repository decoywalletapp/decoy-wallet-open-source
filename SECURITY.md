# Security Policy

Decoy Wallet includes personal safety, contact, location, authentication, and
wallet-monitoring flows. Do not report suspected vulnerabilities, exposed
credentials, abuse paths, user data, or backend operational details in public
issues.

## Supported Versions

Security review is welcome for the latest public source tags and public release
artifacts published from this repository. Older tags may remain available for
historical verification, but fixes will be prioritized for the current public
app-store releases.

| Stream | Supported |
| ------ | --------- |
| Latest `main` / newest public tag | Yes |
| Older tags | Best effort for verification only |

## Reporting a Vulnerability

Use GitHub private vulnerability reporting (**Security → Report a
vulnerability** on the repository page) if it is enabled. If private reporting
is not available, email the maintainer privately at:

support@decoywalletapp.com

Please include:

- A short description of the issue and affected paths (`file:line` when known).
- Steps to reproduce or validate it.
- Whether user data, credentials, backend operations, alert delivery, or
  mnemonic / seed material could be affected.
- Any logs or screenshots with personal data removed.

Please do **not** include:

- Proof-of-concept exploit code in public GitHub issues.
- Sensitive user data, credentials, backend identifiers, or operational details
  in public channels.
- Live testing against production that could interrupt emergency alert delivery
  or access another user's data.

The project owner will acknowledge security reports privately before discussing
them in public.

## Scope

**In scope for this repository**

- Flutter / Dart mobile app source under `lib/`, `android/`, `ios/`, `web/`
- Committed backend helper scripts under `backend/` (as published)
- CI workflows and build provenance scripts in this tree
- Seed / mnemonic generation and handling in the app
- Client-side auth, storage, and network calls from the app

**Out of scope (operator / production)**

- Production Cloud Run, Supabase service-role, Twilio, Stripe live keys
- App Store / Play signing material
- Live decoy seed monitoring infrastructure and runbooks
- Hosted backend authorization rules (Supabase RLS, Firebase rules) that are not
  in this tree — report impact on those privately if you find a client-side path
  that appears to bypass them

## Wallet-specific disclosure notes

- The decoy mnemonic and its private keys are generated on-device and must
  never leave it. Arming a decoy sends only watch-only public material to the
  backend: the decoy id, the BIP84 derivation path, the account xpub, the watch
  public key (zpub) and its type, the derived receive addresses, the source
  type and whether monitoring is on (see `docs/DECOY_SEED_ENTROPY.md`). An
  imported watch-only wallet sends the xpub/zpub or address list the user
  entered. The xpub reveals every address and balance of that decoy, so it is
  private but not a spending secret. Reports that the mnemonic or private keys
  are transmitted, logged, or persisted are high priority.
- The mnemonic is handed between seed screens in memory only (never in route
  or URL parameters, so a crafted deep link cannot inject or read words). The
  reference is dropped after verification, on a new generation, on sign-out or
  account switch, and when the duress PIN opens decoy mode. Dart cannot
  overwrite strings, so the words stay in process memory until
  garbage-collected. Seed screens request OS capture protection: Android
  `FLAG_SECURE`; on iOS an opaque overlay in the app switcher and while the
  screen is recorded or mirrored. iOS cannot block screenshots; that is a
  known platform limit, not a vulnerability in this app.
- Public Firebase API keys and Supabase anon JWTs in client config are expected;
  they are not privileged secrets. Privilege belongs to server rules and
  service-role keys, which must never appear in this repository.
- Do not test disclosure by sending real funds, triggering real emergency
  alerts, or social-engineering support channels.

## Sensitive Changes

Contributions must not add real service credentials, production endpoint values,
private backend source, release artifacts, app-store assets, logs, user data, or
operator runbooks. Use documented placeholders and `--dart-define` settings for
operator-specific configuration.

## Coordinated Disclosure

Security researchers are asked to provide reasonable time for investigation and
remediation before public disclosure. Please avoid testing that could interrupt
emergency alert delivery, degrade production services, or access data belonging
to other users.
