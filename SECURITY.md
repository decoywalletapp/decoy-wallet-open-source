# Security Policy

Decoy Wallet includes personal safety, contact, location, authentication, and
wallet-monitoring flows. Please do not report suspected vulnerabilities, exposed
credentials, abuse paths, user data, or backend operational details in public
issues.

## Supported Versions

Security review is welcome for the latest public source tags and public release
artifacts published from this repository. Older tags may remain available for
historical verification, but fixes will be prioritized for the current public
app-store releases.

## Reporting a Vulnerability

Use GitHub private vulnerability reporting if it is enabled on the public
repository. If private reporting is not available, email the maintainer
privately at:

support@decoywalletapp.com

Please include:

- A short description of the issue.
- Steps to reproduce or validate it.
- Whether user data, credentials, backend operations, or alert delivery could be
  affected.
- Any logs or screenshots with personal data removed.

Please do not include proof-of-concept exploit code, sensitive user data,
credentials, backend identifiers, or operational details in public GitHub issues.
The project owner will acknowledge security reports privately before discussing
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

## Coordinated Disclosure

Security researchers are asked to provide reasonable time for investigation and
remediation before public disclosure. Please avoid testing that could interrupt
emergency alert delivery, degrade production services, or access data belonging
to other users.
