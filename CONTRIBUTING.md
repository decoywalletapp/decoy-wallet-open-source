# Contributing

Thank you for helping review and improve Decoy Wallet.

This repository is intended to publish the mobile app source for transparency
and review. It is not a complete production deployment of the Decoy Wallet
system.

Please also read [SECURITY.md](SECURITY.md).

## Before Opening a Change

- Keep changes focused on the mobile app source (and the published `backend/`
  helpers when that is the topic).
- Do not add production credentials, service URLs, signing material, user data,
  backend deployment scripts, private monitoring code, release artifacts, or
  app-store assets.
- Use example files and documented `--dart-define` values for operator-specific
  configuration.
- Treat legal copy, safety-critical behavior, alert delivery, payments, and
  seed / mnemonic handling as high-risk areas that require careful review.
- Prefer small, reviewable pull requests. Do not bundle unrelated refactors.
- Do not disable or weaken tests, lints, or CI checks to make a change pass.

## Local Checks

Use the Flutter / Dart toolchain pinned by `.github/workflows/public-verification.yml`
(Flutter `3.41.6`) when verifying release candidates. Other stable toolchains may
work for day-to-day development but can drift on transitive pins such as `intl`.

```sh
flutter pub get
flutter analyze --no-fatal-infos
flutter test
```

`flutter analyze` may still report generated FlutterFlow / dependency findings
in the sanitized tree. Fix analyzer findings caused by your change; keep
unrelated generated-code cleanup in a separate PR.

Backend helper unit tests (Node built-ins only):

```sh
node --test backend/membership_redemption/*.test.mjs
```

Account-deletion tests need an optional PGlite module; see
`backend/account_deletion/README.md`.

## Pull requests

In the pull request description, include the commands you ran and their
results, the risk, and how to revert. Maintainers review high-risk paths
(`lib/custom_code/`, `backend/`, CI, manifests, `pubspec.yaml`) carefully.

## Security Issues

Do not file public issues for vulnerabilities or suspected data exposure. Follow
the process in `SECURITY.md`.
