# Reproducible builds

## Current state

- CI pins Flutter **3.41.6** in `.github/workflows/public-verification.yml`;
  `.fvmrc` and `codemagic.yaml` record the same version.
- `pubspec.lock` is **committed** (generated with Flutter 3.41.6) and CI runs
  `flutter pub get --enforce-lockfile`, so CI fails instead of silently
  resolving a different graph. Lockfiles of the local path packages under
  `dependencies/` stay ignored.
- `intl` is constrained to `^0.20.2` (root and
  `dependencies/cartesian_chart_library_syxakz`). Flutter 3.41.6 resolves
  0.20.2; newer stable (needs `^0.20.3`) also resolves without overrides.
- `flutter_secure_storage` remains on `10.0.0-beta.4`. Stable 10.x/11.x change
  Android defaults (`resetOnError: true`, new ciphers with automatic
  migration, minSdk 23) and merge the iOS/macOS packages. That can wipe or
  migrate existing keychain/keystore data, so upgrade only in a dedicated PR
  with on-device migration testing from a beta.4 install.

## Rules

1. Regenerate `pubspec.lock` only with the pinned Flutter version, and commit
   it together with the `pubspec.yaml` change.
2. Keep `.fvmrc`, CI and `codemagic.yaml` Flutter versions in lockstep.
3. Codemagic still runs plain `flutter pub get`; switching it to
   `--enforce-lockfile` is recommended once maintainers confirm.
