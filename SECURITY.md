# Security Policy

Decoy Wallet includes personal safety, contact, location, authentication, and
wallet-monitoring flows. Please do not report suspected vulnerabilities, exposed
credentials, abuse paths, user data, or backend operational details in public
issues.

## Reporting a Vulnerability

Use GitHub private vulnerability reporting if it is enabled on the public
repository. If private reporting is not enabled yet, contact the project owner
privately and include:

- A short description of the issue.
- Steps to reproduce or validate it.
- Whether user data, credentials, backend operations, or alert delivery could be
  affected.
- Any logs or screenshots with personal data removed.

The project owner should acknowledge security reports privately before discussing
them in public.

## Scope

This repository contains the mobile app source only. Production backend
services, deployment scripts, live monitoring infrastructure, secrets, app-store
signing material, and private operational runbooks are intentionally out of
scope for this public source tree.

## Sensitive Changes

Contributions must not add real service credentials, production endpoint values,
private backend source, release artifacts, app-store assets, logs, user data, or
operator runbooks. Use documented placeholders and `--dart-define` settings for
operator-specific configuration.
