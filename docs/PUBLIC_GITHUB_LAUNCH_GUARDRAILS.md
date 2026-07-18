# Public GitHub Launch Guardrails

This guide is for publishing Decoy Wallet's sanitized app source without
exposing private repository history, credentials, backend operations, or release
materials.

## Core Rule

Do not make the private development repository public.

Do not fork the private development repository into a public repository.

Do not push all branches or tags.

Publish only the sanitized public-root snapshot as the first commit of a brand
new GitHub repository.

## Recommended Repository Model

Create a new GitHub repository that is not connected to the private repository:

- New repository, not a fork.
- Start empty: no generated README, license, or `.gitignore` from GitHub.
- Use a neutral public repo name such as `decoy-wallet-app` or
  `decoy-wallet-mobile`.
- Create it as private first if available, review the pushed contents, then
  switch visibility to public only after final approval.
- Enable security features before launch, including private vulnerability
  reporting and secret-scanning protections where available.

## Safe Local Publication Model

The safest local path is to publish from a separate export folder, not from the
sanitization worktree that still knows about the private repository remote.

1. Verify the public-root branch has one commit:

   ```sh
   git rev-list --count codex/public-source-root-20260718
   ```

   Expected result: `1`

2. Verify the public-root commit has no parent:

   ```sh
   git rev-list --parents -n 1 codex/public-source-root-20260718
   ```

   Expected result: one commit hash only, with no parent hash after it.

3. Verify the public-root branch matches the sanitized candidate:

   ```sh
   git diff --stat codex/open-source-sanitization-20260713 codex/public-source-root-20260718
   ```

   Expected result: no output.

4. Export the sanitized snapshot into a separate local folder.

   ```sh
   git archive codex/public-source-root-20260718 | tar -x -C /path/to/new/public/export/folder
   ```

5. Initialize a new git repository inside that export folder.

   ```sh
   git init
   git add .
   git commit -m "chore: publish sanitized public source"
   ```

6. Add only the new public GitHub repository as the remote.

   ```sh
   git remote add origin git@github.com:OWNER/NEW_PUBLIC_REPO.git
   ```

7. Push only the new repository's `main` branch.

   ```sh
   git branch -M main
   git push -u origin main
   ```

8. On GitHub, confirm the public repository shows exactly one commit before
   switching the repository to public visibility or announcing it.

## Pre-Publication Stop Checks

Stop immediately if any of these are true:

- The target GitHub repository is a fork of the private repository.
- The target GitHub repository was created by importing the private repository.
- The local folder being pushed has remotes pointing to private Decoy
  repositories.
- `git log` in the export folder shows more than one commit before the first
  public push.
- Any branch or tag besides the sanitized public `main` branch is queued for
  push.
- Secret scans find live credentials, production host identifiers, signing
  files, app-store artifacts, logs, user data, or backend deployment code.

## Final Human Approval

Before public visibility, the owner should approve:

- The exact GitHub owner and repository name.
- Public visibility timing.
- The prepared MIT source-code license.
- `NOTICE`, `TRADEMARKS.md`, and `THIRD_PARTY_NOTICES.md`.
- Decoy brand and app icon treatment.
- Public README wording, legal/privacy copy, support contacts, and social links.
