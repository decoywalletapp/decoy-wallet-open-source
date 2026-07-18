# Third-Party Asset Review

Audit date: 2026-07-18

This file tracks bundled fonts, images, logos, and generated assets that need
license, trademark, or owner review before a public repository is published.
It is a release-readiness record, not legal advice.

## Removed During Review

- `assets/images/ChatGPT_Image_Feb_9,_2026,_12_38_23_PM.png` was not referenced
  by app code and had unclear publication value, so it was removed from the
  public-source candidate.
- Third-party logo image files for Bitcoin, Stripe, Primal, Rumble, and X were
  removed from the bundled source assets. The app now uses generic UI marks in
  those spots.
- `assets/fonts/MyFlutterApp.ttf` was removed after its only app usages were
  replaced with built-in Material location icons.

## Bundled Fonts

The app bundles these font families under `assets/fonts/`:

- Bebas Neue
- Inter
- Inter Tight
- Outfit
- Roboto

Initial source review:

- Bebas Neue upstream documentation says Bebas Neue version 2.000 is licensed
  under the SIL Open Font License 1.1.
- Inter upstream documentation says Inter is licensed under the SIL Open Font
  License.
- Outfit upstream documentation says Outfit is licensed under the SIL Open Font
  License 1.1.
- Roboto 2 upstream documentation identifies the archived Roboto source
  repository as Apache-2.0 licensed. The exact local binary provenance still
  needs owner confirmation.
- Google Fonts guidance says current font projects submitted to Google Fonts are
  expected to be licensed under SIL Open Font License 1.1, and Google Fonts
  metadata supports explicit license fields.
- The official SIL Open Font License site says OFL 1.1 permits bundling fonts
  in apps and software subject to license conditions.
- `THIRD_PARTY_NOTICES.md` now includes font attribution and references local
  copies of the SIL OFL 1.1 and Apache 2.0 license texts.

Publication action:

- Confirm the exact source package and license text for each bundled font file.
- Keep `THIRD_PARTY_NOTICES.md` aligned with the final bundled font files.
- Confirm whether any Reserved Font Name rules apply to modified or repackaged
  fonts.

Useful upstream references:

- https://openfontlicense.org/
- https://github.com/rsms/inter
- https://github.com/Outfitio/Outfit-Fonts
- https://github.com/dharmatype/bebas-neue
- https://github.com/googlefonts/roboto-2
- https://googlefonts.github.io/gf-guide/metadata.html

## Decoy-Owned Brand Assets

These assets appear to be Decoy-owned brand/app assets and should be confirmed
by the owner before publication:

- `assets/images/DecoyLogo1-WOHiRes.jpg`
- `assets/images/app_launcher_icon.png`
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- `web/icons/*.png`
- `web/favicon.png`

Publication action:

- Decide whether Decoy brand assets are included in the public repository.
- Decide whether the open-source license covers these assets or whether they
  should be excluded from the code license through a trademark/brand notice.

## Third-Party Brand and Logo Assets

The candidate no longer bundles third-party logo image files for Bitcoin,
Stripe, Primal, Rumble, or X.

Social and payment links still refer to third-party platforms and services in
the app UI and should be reviewed for public-facing accuracy.

Publication action:

- Confirm third-party platform and payment references are accurate and do not
  imply sponsorship, endorsement, or affiliation.

## Placeholder Directory Assets

Several `favicon.png` files exist to keep Flutter asset directories present:

- `assets/audios/favicon.png`
- `assets/fonts/favicon.png`
- `assets/jsons/favicon.png`
- `assets/pdfs/favicon.png`
- `assets/rive_animations/favicon.png`
- `assets/videos/favicon.png`
- matching placeholder files under
  `dependencies/cartesian_chart_library_syxakz/assets/`

Publication action:

- Keep these only if the corresponding empty asset directories need to remain in
  the Flutter project structure.
- Otherwise remove the unused asset directories from `pubspec.yaml` and delete
  the placeholder files.
