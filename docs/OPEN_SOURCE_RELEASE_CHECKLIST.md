# Open Source Release Checklist

This checklist is for preparing a public Decoy Wallet source release without exposing
production secrets, private backend operations, app-store release material, or user data.

## Publish Model

- Do not make the private development repository public.
- Do not fork or import the private development repository into a public
  repository.
- Publish from a sanitized first commit in a new GitHub repository.
- Prefer publishing from a separate export folder initialized as a brand-new Git
  repository. See `docs/PUBLIC_GITHUB_LAUNCH_GUARDRAILS.md`.
- Keep production deployment scripts, live backend source, database migrations, app-store
  artifacts, signing files, and generated release bundles private unless they are
  separately reviewed and sanitized.
- Treat the Android private branch as the app-code baseline for this public candidate.
  Production backend watcher commits may exist privately and still be intentionally
  excluded from this app-source release.

## What Must Stay Private

- Firebase `google-services.json` and `GoogleService-Info.plist`.
- Supabase project URLs, anon keys, service-role keys, SQL migration history, and function
  deployment code that exposes production internals.
- Twilio, Stripe, BTCPay, QuickNode, Cloud Run, Google Cloud, and GitHub tokens or webhook
  secrets.
- Private Codemagic credentials, signing identities, release/deployment helper
  scripts, and any generated CI files containing secrets. Public CI workflow
  configuration is allowed only when all credentials stay in the CI provider.
- Decoy seed watcher source, operational policies, live monitoring scripts, and alerting
  runbooks, unless they go through a separate backend-specific public-source review.
- App-store screenshots, APK/AAB/IPA artifacts, signing keys, provisioning profiles, and
  keystores.
- Any logs, test data, phone numbers, locations, contact names, or user IDs.

## Public Candidate Checks

- `android/app/google-services.json` is absent and only the `.example` file is present.
- `ios/Runner/GoogleService-Info.plist` is absent and only the `.example` file is present.
- Backend URLs and API keys are provided through `--dart-define` values, not hardcoded.
- Operator-owned legal URLs, support email addresses, billing return URLs, and auth
  deep links are provided through documented build settings or placeholder domains.
- The app can be analyzed and built from the sanitized worktree.
- Public CI configuration does not contain signing files, provisioning profiles,
  service credentials, backend secrets, or private repository references.
- A secret scan returns no production credentials or live project identifiers.
- README setup instructions explain that backend services must be supplied by the operator.
- The legal/privacy copy has been reviewed for public-source distribution.
- The source license, trademark notice, and third-party notices are present.
- The public-root branch has exactly one parentless commit.
- The public-root branch tree matches the sanitized candidate branch.
- The public app source does not accidentally reintroduce private `codex_backend_work/`,
  `supabase/`, release artifact, or app-store asset folders.
- The private production watcher has the stale confirmed transaction guard and regression
  coverage before public release messaging claims the current safety behavior.
- `LICENSE` has been replaced with the selected open-source license before publication.
- `TRADEMARKS.md` has been reviewed by the owner.
- `NOTICE`, bundled fonts, images, generated code, and third-party attribution
  requirements have been reviewed.
- `docs/THIRD_PARTY_ASSET_REVIEW.md` has no unresolved asset/license/trademark
  blockers.

## Release Steps

1. Finish the sanitized branch in this worktree.
2. Run secret scans and build checks.
3. Commit the sanitized candidate locally.
4. Review `LICENSE`, `NOTICE`, `TRADEMARKS.md`, and `THIRD_PARTY_NOTICES.md`.
5. Verify the public-root branch has exactly one parentless commit.
6. Create a new empty GitHub repository that is not a fork or import of the
   private repository.
7. Export the sanitized public-root snapshot into a separate local folder.
8. Initialize a brand-new Git repository in the export folder.
9. Push only the export repository's first `main` commit.
10. Confirm GitHub shows exactly one commit before public visibility or
    announcement.
11. Tag the first public source release only after a final manual review.
