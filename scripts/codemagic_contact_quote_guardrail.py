#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
EMPTY_QUOTE_DEFAULT = re.compile(r"=\s*'(?:\\*\"\\*\")';")
EMPTY_QUOTE_DEFAULT_DOUBLE = re.compile(r'=\s*"(?:\\*\"\\*\")";')
FAKE_SEED_CONDITION = re.compile(
    r"\(\s*FFAppState\(\)\.fakeSeeded\s*==\s*false\s*\)\s*\|\|\s*"
    r"\(\s*FFAppState\(\)\.fakeBtcBalance\s*<=\s*(?:0(?:\.0+)?|0\.05)\s*\)"
)
FAKE_BTC_APP_STATE_BLOCK = re.compile(
    r"  double _fakeBtcBalance = 0\.0;\n"
    r"(?:(?!  double _fakeUsdValue = 0\.0;).)*"
    r"  double _fakeUsdValue = 0\.0;",
    re.DOTALL,
)
FAKE_BTC_BALANCE_INIT = """    await _safeInitAsync(() async {
      _fakeBtcBalance =
          await secureStorage.getDouble('ff_fakeBtcBalance') ?? _fakeBtcBalance;
    });"""
FAKE_BTC_SEEDED_AT_INIT = """    await _safeInitAsync(() async {
      final stored = await secureStorage.getString('ff_fakeBtcSeededAt');
      _fakeBtcSeededAt =
          stored == null ? _fakeBtcSeededAt : DateTime.tryParse(stored);
    });"""
FAKE_BTC_PERSISTENT_BLOCK = """  double _fakeBtcBalance = 0.0;
  double get fakeBtcBalance => _fakeBtcBalance;
  set fakeBtcBalance(double value) {
    _fakeBtcBalance = value;
    secureStorage.setDouble('ff_fakeBtcBalance', value);
    if (value.isFinite && value >= 0.0) {
      fakeBtcSeededAt = DateTime.now().toUtc();
    }
  }

  void deleteFakeBtcBalance() {
    _fakeBtcBalance = 0.0;
    secureStorage.delete(key: 'ff_fakeBtcBalance');
    fakeBtcSeededAt = null;
  }

  DateTime? _fakeBtcSeededAt;
  DateTime? get fakeBtcSeededAt => _fakeBtcSeededAt;
  set fakeBtcSeededAt(DateTime? value) {
    _fakeBtcSeededAt = value;
    if (value == null) {
      secureStorage.delete(key: 'ff_fakeBtcSeededAt');
    } else {
      secureStorage.setString(
        'ff_fakeBtcSeededAt',
        value.toUtc().toIso8601String(),
      );
    }
  }

  void deleteFakeBtcSeededAt() {
    _fakeBtcSeededAt = null;
    secureStorage.delete(key: 'ff_fakeBtcSeededAt');
  }

  bool get shouldSeedFakeBtcBalance {
    if (!_fakeBtcBalance.isFinite) return true;
    if (_fakeSeeded != true) return true;

    final seededAt = _fakeBtcSeededAt;
    if (seededAt == null) return _fakeBtcBalance <= 0.0;

    return DateTime.now().toUtc().difference(seededAt.toUtc()) >=
        _fakeBtcReseedCooldown;
  }"""


def cleanup_contact_quote_defaults():
    patched = 0
    for path in (ROOT / 'lib').rglob('*.dart'):
        rel = str(path.relative_to(ROOT)).lower()
        if 'contact' not in rel and 'emerg' not in rel:
            continue

        original = path.read_text()
        text = EMPTY_QUOTE_DEFAULT.sub("= '';", original)
        text = EMPTY_QUOTE_DEFAULT_DOUBLE.sub("= '';", text)

        if text != original:
            path.write_text(text)
            patched += 1
            print(f'[guardrail] removed visible empty-string quotes in {path.relative_to(ROOT)}')

    print(f'[guardrail] contact quote cleanup complete; files patched={patched}')


def verify_duress_alert_gate():
    pin_page = ROOT / 'lib' / 'pin_pages' / 'p_i_n_page' / 'p_i_n_page_widget.dart'
    if not pin_page.exists():
        print('[guardrail] warning: PIN page not found for duress alert gate verification')
        return

    text = pin_page.read_text()
    if 'sendEmergencyAlertsCall.call' not in text and 'SendEmergencyAlertsCall.call' not in text:
        print('[guardrail] warning: PIN page has no emergency alert call to verify')
        return

    required_terms = [
        'decoyPinContactsEnabled',
        'hasActiveSubscription',
        'contactsComplete',
    ]
    missing = [term for term in required_terms if term not in text]
    if missing:
        raise SystemExit(
            '[guardrail] unsafe PIN alert gate: missing required condition(s): '
            + ', '.join(missing)
        )

    print('[guardrail] duress alert gate verified: contacts trigger, active subscription, contacts complete')


def ensure_fake_btc_persistence():
    app_state = ROOT / 'lib' / 'app_state.dart'
    if not app_state.exists():
        print('[guardrail] warning: lib/app_state.dart not found for fake BTC persistence patch')
        return

    original = app_state.read_text()
    text = original

    if '_fakeBtcReseedCooldown' not in text:
        text = text.replace(
            '  FFAppState._internal();\n',
            '  FFAppState._internal();\n\n'
            '  static const Duration _fakeBtcReseedCooldown = Duration(hours: 24);\n',
            1,
        )

    if "await secureStorage.getString('ff_fakeBtcSeededAt')" not in text:
        text = text.replace(
            FAKE_BTC_BALANCE_INIT,
            f"{FAKE_BTC_BALANCE_INIT}\n{FAKE_BTC_SEEDED_AT_INIT}",
            1,
        )

    text, count = FAKE_BTC_APP_STATE_BLOCK.subn(
        f"{FAKE_BTC_PERSISTENT_BLOCK}\n\n  double _fakeUsdValue = 0.0;",
        text,
        count=1,
    )
    if count != 1:
        raise SystemExit('[guardrail] unable to patch fake BTC persistence block safely')

    if text != original:
        app_state.write_text(text)
        print('[guardrail] ensured 24-hour fake BTC balance hold window in lib/app_state.dart')
    else:
        print('[guardrail] fake BTC persistence already current')


def patch_fake_btc_seed_conditions():
    app_state = ROOT / 'lib' / 'app_state.dart'
    if not app_state.exists() or 'shouldSeedFakeBtcBalance' not in app_state.read_text():
        raise SystemExit('[guardrail] cannot normalize fake BTC seed conditions; shouldSeedFakeBtcBalance is unavailable')

    patched = 0
    for path in (ROOT / 'lib').rglob('*.dart'):
        original = path.read_text()
        if 'fakeSeeded' not in original and 'fakeBtcBalance' not in original:
            continue

        text = FAKE_SEED_CONDITION.sub('(FFAppState().shouldSeedFakeBtcBalance == true)', original)
        if text != original:
            path.write_text(text)
            patched += 1
            print(f'[guardrail] normalized fake BTC seed condition in {path.relative_to(ROOT)}')

    print(f'[guardrail] fake BTC seed condition cleanup complete; files patched={patched}')


def main():
    cleanup_contact_quote_defaults()
    verify_duress_alert_gate()
    ensure_fake_btc_persistence()
    patch_fake_btc_seed_conditions()


if __name__ == '__main__':
    main()
