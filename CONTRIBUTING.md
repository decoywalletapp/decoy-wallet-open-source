# Contributing

Thank you for helping review and improve Decoy Wallet.

This repository is intended to publish the mobile app source for transparency
and review. It is not a complete production deployment of the Decoy Wallet
system.

## Before Opening a Change

- Keep changes focused on the mobile app source.
- Do not add production credentials, service URLs, signing material, user data,
  backend deployment scripts, private monitoring code, release artifacts, or
  app-store assets.
- Use example files and documented `--dart-define` values for operator-specific
  configuration.
- Treat legal copy, safety-critical behavior, alert delivery, and payment flows
  as high-risk areas that require careful review.

## Local Checks

Run the available tests before proposing a change:

```sh
flutter test
```

`flutter analyze` currently reports generated-code and dependency warnings in
the sanitized candidate. Fix analyzer findings when they are caused by your
change, and keep unrelated generated-code cleanup separate.

## Security Issues

Do not file public issues for vulnerabilities or suspected data exposure. Follow
the process in `SECURITY.md`.
