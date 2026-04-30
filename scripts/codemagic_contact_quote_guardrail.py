#!/usr/bin/env python3
"""Guardrails for generated FlutterFlow code.

This runs during CodeMagic builds after FlutterFlow has pushed generated files.
It keeps a few safety behaviors from being lost without changing the FlutterFlow
page routing/action chains themselves.
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: Path) -> str:
    return path.read_text(encoding='utf-8')


def write_if_changed(path: Path, original: str, updated: str) -> None:
    if updated != original:
        path.write_text(updated, encoding='utf-8')
        print(f'[guardrail] patched {path.relative_to(ROOT)}')


def patch_visible_empty_quotes() -> None:
    """Keep emergency contact empty fields blank instead of showing literal ""."""
    targets = [
        ROOT / 'lib/emergancy_contact_information/emergency_contacts/emergency_contacts_model.dart',
        ROOT / 'lib/emergancy_contact_information/emergency_contacts/emergency_contacts_widget.dart',
    ]

    for path in targets:
        if not path.exists():
            continue
        original = read(path)
        text = original

        text = text.replace("'\"\"'", "''")
        text = text.replace('"\\"\\""', "''")
        text = text.replace("initialText: '\"\"'", "initialText: ''")
        text = text.replace("hintText: '\"\"'", "hintText: ''")
        text = re.sub(
            r"valueOrDefault<String>\((.*?),\s*'\"\"'\)",
            r"valueOrDefault<String>(\1, '')",
            text,
            flags=re.S,
        )

        write_if_changed(path, original, text)


def patch_app_state_fake_btc_window() -> None:
    path = ROOT / 'lib/app_state.dart'
    if not path.exists():
        return

    original = read(path)
    text = original

    fake_init = """    await _safeInitAsync(() async {
      _fakeBtcBalance =
          await secureStorage.getDouble('ff_fakeBtcBalance') ?? _fakeBtcBalance;
    });
"""
    fake_seed_init = """    await _safeInitAsync(() async {
      final fakeBtcSeededAtSeconds =
          await secureStorage.getInt('ff_fakeBtcSeededAt');
      if (fakeBtcSeededAtSeconds != null && fakeBtcSeededAtSeconds > 0) {
        _fakeBtcSeededAt =
            dateTimeFromSecondsSinceEpoch(fakeBtcSeededAtSeconds);
      }
    });
"""
    if "ff_fakeBtcSeededAt" not in text and fake_init in text:
        text = text.replace(fake_init, fake_init + fake_seed_init)

    text = re.sub(
        r"  set fakeBtcBalance\(double value\) \{\n.*?  \}\n\n  void deleteFakeBtcBalance",
        """  set fakeBtcBalance(double value) {
    final startsNewWindow =
        value.isFinite && value > 0.0 && shouldSeedFakeBtcBalance;
    _fakeBtcBalance = value;
    secureStorage.setDouble('ff_fakeBtcBalance', value);
    if (startsNewWindow) {
      fakeBtcSeededAt = DateTime.now().toUtc();
    }
  }

  void deleteFakeBtcBalance""",
        text,
        flags=re.S,
    )

    if "DateTime? _fakeBtcSeededAt;" not in text:
        marker = """  void deleteFakeBtcBalance() {
    secureStorage.delete(key: 'ff_fakeBtcBalance');
  }
"""
        insertion = """  void deleteFakeBtcBalance() {
    secureStorage.delete(key: 'ff_fakeBtcBalance');
  }

  DateTime? _fakeBtcSeededAt;
  DateTime? get fakeBtcSeededAt => _fakeBtcSeededAt;
  set fakeBtcSeededAt(DateTime? value) {
    _fakeBtcSeededAt = value;
    if (value == null) {
      secureStorage.delete(key: 'ff_fakeBtcSeededAt');
    } else {
      secureStorage.setInt(
        'ff_fakeBtcSeededAt',
        value.toUtc().millisecondsSinceEpoch ~/ 1000,
      );
    }
  }

  bool get shouldSeedFakeBtcBalance {
    if (_fakeBtcBalance <= 0.0 || _fakeBtcSeededAt == null) {
      return true;
    }
    return DateTime.now().toUtc().difference(_fakeBtcSeededAt!.toUtc()) >=
        const Duration(hours: 24);
  }
"""
        if marker in text:
            text = text.replace(marker, insertion)

    write_if_changed(path, original, text)


def patch_duress_home_seed_condition() -> None:
    path = ROOT / 'lib/duress_mode/duress_home_page/duress_home_page_widget.dart'
    if not path.exists():
        return
    original = read(path)
    text = original
    text = text.replace('if (!FFAppState().fakeSeeded)', 'if (FFAppState().shouldSeedFakeBtcBalance)')
    text = text.replace('if (FFAppState().fakeSeeded == false)', 'if (FFAppState().shouldSeedFakeBtcBalance)')
    text = text.replace('if (FFAppState().fakeBtcBalance <= 0.0)', 'if (FFAppState().shouldSeedFakeBtcBalance)')
    write_if_changed(path, original, text)


def validate_duress_pin_alert_gate() -> None:
    path = ROOT / 'lib/pin_pages/create_pin/create_pin_widget.dart'
    if not path.exists():
        raise SystemExit('Missing expected duress PIN page file')

    text = read(path)
    if 'SendEmergencyAlertsCall.call' not in text:
        raise SystemExit('Duress PIN page no longer calls SendEmergencyAlerts')
    if 'if (true)' in text:
        raise SystemExit('Dangerous flattened duress alert gate detected')

    required_gate_tokens = [
        'decoyPinContactsEnabled',
        'hasActiveSubscription',
        'contactsComplete',
    ]
    missing = [token for token in required_gate_tokens if token not in text]
    if missing:
        raise SystemExit(
            'Duress alert gate is missing required condition(s): ' + ', '.join(missing)
        )


def main() -> None:
    patch_visible_empty_quotes()
    patch_app_state_fake_btc_window()
    patch_duress_home_seed_condition()
    validate_duress_pin_alert_gate()
    print('[guardrail] contact, fake BTC, and duress gate checks complete')


if __name__ == '__main__':
    main()
