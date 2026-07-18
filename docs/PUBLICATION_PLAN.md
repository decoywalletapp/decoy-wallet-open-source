# Public Repository Publication Plan

This plan is for publishing the sanitized Decoy Wallet mobile app source without
exposing private git history, production backend operations, secrets, app-store
material, or user data.

## Current Status

- Sanitized candidate worktree: `/Users/mitchellwleblanc/Documents/GitHub/mobile-app-open-source`
- Candidate branch: `codex/open-source-sanitization-20260713`
- Private-history checkpoint: `9abe663 chore: prepare public source candidate`
- Publishing status: local candidate only; not pushed to a public repository

## Publication Blockers

- Final owner/legal approval of the prepared MIT source-code license.
- Confirm `NOTICE`, `TRADEMARKS.md`, and `THIRD_PARTY_NOTICES.md` accurately
  cover bundled assets, fonts, generated code, and brand material.
- Complete `docs/THIRD_PARTY_ASSET_REVIEW.md` by either adding required
  attribution/license text or replacing assets that should not be redistributed.
- Complete owner/legal review of legal and privacy copy.
- Decide whether public brand/social links should stay Decoy-owned or be
  generalized for forks.
- Decide public repository name, owner, visibility, and whether GitHub private
  vulnerability reporting should be enabled before launch.

## Safe Publication Model

Do not make the private development repository public. Publish from a new empty
repository using a sanitized first commit only.

See `docs/PUBLIC_GITHUB_LAUNCH_GUARDRAILS.md` for the required safe launch
model. The preferred path is to export the sanitized public-root branch into a
separate local folder and initialize a brand-new Git repository there before
adding the new public GitHub remote.

High-level process:

1. Finish and commit the sanitized candidate locally.
2. Confirm the public-root branch has exactly one parentless commit.
3. Create a new empty GitHub repository that is not a fork or import of the
   private repository.
4. Export the sanitized snapshot into a separate local folder.
5. Initialize a brand-new Git repository in that export folder.
6. Push only that repository's first commit to the new GitHub repository.
7. Review the public repository contents before announcement.
8. Tag the first public source release only after final manual approval.

## Do Not Publish

Do not publish any of the following:

- Private git history.
- Production backend source, watcher code, deployment scripts, monitoring
  scripts, alerting runbooks, or operational policies.
- Firebase, Supabase, Twilio, Stripe, BTCPay, QuickNode, Cloud Run, Google
  Cloud, GitHub, or app-store credentials.
- App Store or Google Play release artifacts, screenshots, signing files,
  provisioning profiles, or keystores.
- Logs, test user data, phone numbers, addresses, location data, contact names,
  wallet identifiers tied to users, or internal support records.
