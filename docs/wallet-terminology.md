# Wallet Terminology Review

Reviewed October 2, 2026, against the released 1.1.5 catalogs. This review is
limited to the term "wallet" and its surrounding wording, not certification of
every translation in the app.

## Changes

German uses `Wallet` instead of `Geldbörse`, including plurals and compounds such
as `Wallets`, `Wallet-Adresse`, and `Wallet-Aktivität`. Dutch uses `wallet`
instead of `portemonnee`, including `wallets`, `walletadres`, and
`walletactiviteit`. Each catalog has 25 changed messages. The generated Dart
localizations must be regenerated with `flutter gen-l10n`.

This follows the German tester's feedback and usage in German and Dutch Bitcoin
products. It is a terminology preference for this product, not a claim that a
local word also used for a physical wallet is always wrong.

Only translated display text is changed. English, brand names, message keys,
placeholders, protocol strings, routes, authentication, subscriptions, alerts,
monitoring logic, and Bitcoin data handling are unchanged.

## All 18 Languages

Preserve the local term when it is also established cryptocurrency terminology.
The source links below are evidence of usage, not endorsements of those products.

| Language | Wallet label after review | Decision and reference |
| --- | --- | --- |
| English | Wallet | Unchanged source language |
| Arabic | المحفظة | Keep; [Bitcoin.org](https://bitcoin.org/ar/) uses the same noun |
| German | Wallet | Change; [BitBox](https://bitbox.swiss/de/app/) uses Wallet |
| Spanish | Cartera | Keep; [Bitcoin.com](https://www.bitcoin.com/es/wallet/bitcoin/) uses cartera for its app |
| French | Portefeuille | Keep; [Bitcoin.com support](https://support.bitcoin.com/fr/collections/2050805-portefeuille) uses portefeuille |
| Hebrew | ארנק | Keep; [Bitcoin.org](https://bitcoin.org/he/secure-your-wallet) uses the same noun |
| Hindi | वॉलेट | Keep the loanword; [Bitcoin.com](https://www.bitcoin.com/hi/) uses it |
| Indonesian | Dompet | Keep; [Bitcoin.com](https://www.bitcoin.com/id/get-started/wallet-security/wallets-custody/what-is-a-bitcoin-wallet/) uses dompet Bitcoin; English wallet is also used locally |
| Italian | Portafoglio | Keep; [Bitcoin.org](https://bitcoin.org/it/wallets/desktop/) uses portafoglio |
| Japanese | ウォレット | Keep the loanword; [Bitcoin.org](https://bitcoin.org/ja/how-it-works) uses it |
| Korean | 지갑 | Keep; [Bitcoin.org](https://bitcoin.org/ko/) uses the same noun |
| Dutch | Wallet | Change; [Bitvavo](https://learn.bitvavo.com/nl/article/cryptocurrency-wallet-adres/395) uses wallet |
| Polish | Portfel | Keep; [Bitcoin.org](https://bitcoin.org/pl/slownik) defines portfel Bitcoin |
| Portuguese | Carteira | Keep; [Bitcoin.org](https://bitcoin.org/pt_BR/) uses carteira |
| Russian | Кошелёк | Keep; [Bitcoin.com Wallet](https://wallet.bitcoin.com/ru/) uses the same noun |
| Turkish | Cüzdan | Keep; [Bitcoin.org](https://bitcoin.org/tr/nasil-calisir) uses the same noun |
| Ukrainian | Гаманець | Keep; [Bitcoin.org](https://bitcoin.org/uk/getting-started) uses the same noun |
| Chinese (Simplified) | 钱包 | Keep; [Bitcoin.com](https://www.bitcoin.com/zh/wallet/bitcoin/) uses the same noun |

Native speaker feedback remains valuable for regional preferences and sentence
quality. Do not globally replace these local terms with English.

## Regression Checks

`test/wallet_terminology_test.dart` covers all 25 affected generated getters in
each changed language, checks catalog/runtime agreement, rejects the previous
German and Dutch terms, and preserves brand and protocol tokens. Existing catalog
completeness and layout tests apply to all 18 languages. Watch-only import UI
tests cover English, German, and Dutch at phone and tablet widths.

Local validation on October 2, 2026 with Flutter 3.41.6:

* Normal regression run with wallet import enabled: 757 passed; nine expected
  skips require isolated mock-server settings.
* Separate PIN, QR import, and extended screen run with `test.invalid` endpoints:
  870 passed, none skipped. This covers the nine normal-run skips and includes
  all 648 screen/language/width combinations. Counts overlap between the runs.
* Focused terminology, language preference, and import navigation run: 58 passed.
* Small-phone captures of login, balance, and wallet settings in German and Dutch:
  six passed and screenshots visually inspected.
* Static analysis of changed Dart files: no issues. `git diff --check`: clean.
* The 250 other tracked files under `lib/` are byte-identical to the release
  baseline. Catalog keys, metadata, and placeholders are unchanged.

The initial combined run used mock-server settings for every test, which conflicts
with the existing test that explicitly requires an absent Supabase URL. It passed
in the normal configuration; the suites above were rerun separately without
changing that test or application behavior. No native device acceptance or new
store build was performed during this text correction.

## Release Baseline

The corrections are based on final Android 1.1.5 source commit
`68d743ea5b2082488f1bf91dcee45d952a33ab71`, tag
`v1.1.5-public-source-20260929-android`, build `1790736554`.
The iOS 1.1.5 checkpoint is commit
`b7f61db0f1bdbbe0194e0e340d5bb76d4ec15300`, tag
`v1.1.5-public-source-20260929`, build `20260929234538` (4538).
Their Dart/localization source is identical. These existing tags are not moved.

Shipping this correction requires a new mobile build and device acceptance;
editing these catalogs does not update already installed apps or deploy a backend.
