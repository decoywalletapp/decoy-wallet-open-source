#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    p = ROOT / path
    if not p.exists():
        print(f'[guardrail] skip missing {path}')
        return None
    return p.read_text()


def write(path, text, original):
    if text == original:
        print(f'[guardrail] unchanged {path}')
        return
    (ROOT / path).write_text(text)
    print(f'[guardrail] patched {path}')


def ensure_import(text, import_line):
    if import_line in text:
        return text
    anchor = "import '/flutter_flow/flutter_flow_util.dart';\n"
    if anchor in text:
        return text.replace(anchor, f'{import_line}\n{anchor}', 1)
    match = re.search(r"^import .+;$", text, flags=re.M)
    if match:
        return text[:match.end()] + f'\n{import_line}' + text[match.end():]
    return text


def patch_main_notification_prompt():
    path = 'lib/main.dart'
    text = read(path)
    if text is None:
        return
    original = text
    text = re.sub(
        r"await FirebaseMessaging\.instance\.requestPermission\([\s\S]*?\);",
        "// Do not show the iOS notification permission prompt at app launch.\n"
        "// The onboarding notification page asks only after the user chooses it.\n"
        "await FirebaseMessaging.instance.getNotificationSettings();",
        text,
        count=1,
    )
    write(path, text, original)


def patch_app_state_fake_btc():
    path = 'lib/app_state.dart'
    text = read(path)
    if text is None:
        return
    original = text

    if '_fakeBtcReseedCooldown' not in text:
        text = text.replace(
            '  FFAppState._internal();\n',
            '  FFAppState._internal();\n\n'
            '  static const Duration _fakeBtcReseedCooldown = Duration(hours: 24);\n',
            1,
        )

    seed_init = """    _fakeBtcBalance =
        await secureStorage.getDouble('ff_fakeBtcBalance') ?? _fakeBtcBalance;
"""
    if "ff_fakeBtcSeededAt" not in text and seed_init in text:
        text = text.replace(
            seed_init,
            seed_init
            + """    _fakeBtcSeededAt = await secureStorage.getInt('ff_fakeBtcSeededAt').then(
      (value) => value != null ? DateTime.fromMillisecondsSinceEpoch(value) : null,
    );
""",
            1,
        )

    fake_block = """  double _fakeBtcBalance = 0.0;
  double get fakeBtcBalance => _isFakeBtcBalanceStale() ? 0.0 : _fakeBtcBalance;
  set fakeBtcBalance(double value) {
    final wasStale = _isFakeBtcBalanceStale();
    _fakeBtcBalance = value;
    secureStorage.setDouble('ff_fakeBtcBalance', value);
    if (value > 0 && (_fakeBtcSeededAt == null || _fakeSeeded != true || wasStale)) {
      fakeBtcSeededAt = DateTime.now();
    }
  }

  void deleteFakeBtcBalance() {
    secureStorage.delete(key: 'ff_fakeBtcBalance');
    deleteFakeBtcSeededAt();
  }

  DateTime? _fakeBtcSeededAt;
  DateTime? get fakeBtcSeededAt => _fakeBtcSeededAt;
  set fakeBtcSeededAt(DateTime? value) {
    _fakeBtcSeededAt = value;
    if (value == null) {
      secureStorage.delete(key: 'ff_fakeBtcSeededAt');
    } else {
      secureStorage.setInt('ff_fakeBtcSeededAt', value.millisecondsSinceEpoch);
    }
  }

  void deleteFakeBtcSeededAt() {
    secureStorage.delete(key: 'ff_fakeBtcSeededAt');
    _fakeBtcSeededAt = null;
  }

  bool get shouldSeedFakeBtcBalance {
    if (_fakeSeeded != true) return true;
    if (_fakeBtcBalance < 0.0) return true;
    if (_fakeBtcSeededAt == null) return _fakeBtcBalance <= 0.0;
    return DateTime.now().difference(_fakeBtcSeededAt!) >= _fakeBtcReseedCooldown;
  }

  bool _isFakeBtcBalanceStale() {
    if (_fakeBtcBalance < 0.0) return true;
    if (_fakeBtcSeededAt == null) return false;
    return DateTime.now().difference(_fakeBtcSeededAt!) >= _fakeBtcReseedCooldown;
  }

"""
    text = re.sub(
        r"  double _fakeBtcBalance = 0\.0;[\s\S]*?\n  double _fakeUsdValue",
        fake_block + '  double _fakeUsdValue',
        text,
        count=1,
    )
    write(path, text, original)


def patch_fake_btc_seed_conditions():
    pattern = re.compile(
        r"\(FFAppState\(\)\.fakeSeeded\s*==\s*false\)\s*\|\|\s*"
        r"\(FFAppState\(\)\.fakeBtcBalance\s*<=\s*(?:0(?:\.0+)?|0\.05)\)"
    )
    for p in (ROOT / 'lib').rglob('*.dart'):
        text = p.read_text()
        original = text
        text = pattern.sub('(FFAppState().shouldSeedFakeBtcBalance == true)', text)
        if text != original:
            p.write_text(text)
            print(f'[guardrail] patched {p.relative_to(ROOT)}')


def patch_duress_pin_alert_flow():
    for p in (ROOT / 'lib').rglob('*.dart'):
        text = p.read_text()
        if 'SendEmergencyAlertsCall.call' not in text:
            continue
        original = text
        text = text.replace(
            'if (FFAppState().decoyPinContactsEnabled == true) {',
            'if (true) {',
        )
        text = text.replace(
            'if (FFAppState().decoyPinContactsEnabled) {',
            'if (true) {',
        )
        if text != original:
            p.write_text(text)
            print(f'[guardrail] patched emergency alert gate in {p.relative_to(ROOT)}')


def patch_emergency_contact_empty_strings():
    for p in (ROOT / 'lib').rglob('*emergency*contact*.dart'):
        text = p.read_text()
        original = text
        text = text.replace("'\"\"'", "''")
        text = text.replace('"\\"\\""', "''")
        if text != original:
            p.write_text(text)
            print(f'[guardrail] patched empty-string display in {p.relative_to(ROOT)}')


def patch_location_to_agreements():
    path = 'lib/permissions/location_authorization/location_authorization_widget.dart'
    text = read(path)
    if text is None:
        return
    original = text
    text = text.replace('CreatePinWidget.routeName', 'AgreementsPageWidget.routeName')
    text = text.replace("'/createPin'", "AgreementsPageWidget.routeName")
    write(path, text, original)


def patch_agreements_completion():
    candidates = list((ROOT / 'lib').rglob('*agreements*_widget.dart'))
    if not candidates:
        print('[guardrail] no agreements widget found')
        return
    for p in candidates:
        text = p.read_text()
        original = text
        text = text.replace('setup_complete', 'agreements_complete')
        text = text.replace('setup_completed_at', 'agreements_completed_at')
        if 'HomePageWidget.routeName' in text and 'CreatePinWidget.routeName' in text:
            text = text.replace('HomePageWidget.routeName', 'CreatePinWidget.routeName')
        if text != original:
            p.write_text(text)
            print(f'[guardrail] patched agreements completion in {p.relative_to(ROOT)}')


def patch_keyboard_and_autofill():
    for p in (ROOT / 'lib').rglob('*.dart'):
        name = p.name
        rel = str(p.relative_to(ROOT))
        if name.endswith('_model.dart'):
            continue
        text = p.read_text()
        original = text

        if 'create_account' in rel or 'create_account' in name:
            text = ensure_import(text, "import 'package:flutter/services.dart';")
            text = text.replace('enableInteractiveSelection: false,', '')
            text = re.sub(
                r"keyboardType: TextInputType\.emailAddress,\n(?!\s*textInputAction)",
                "keyboardType: TextInputType.emailAddress,\n"
                "textInputAction: TextInputAction.next,\n"
                "autofillHints: const [AutofillHints.username, AutofillHints.email],\n",
                text,
            )
            text = re.sub(
                r"obscureText: !_model\.passwordVisibility,\n(?!\s*textInputAction)",
                "obscureText: !_model.passwordVisibility,\n"
                "textInputAction: TextInputAction.next,\n"
                "autofillHints: const [AutofillHints.newPassword],\n",
                text,
                count=1,
            )
            text = re.sub(
                r"obscureText: !_model\.confirmPasswordVisibility,\n(?!\s*textInputAction)",
                "obscureText: !_model.confirmPasswordVisibility,\n"
                "textInputAction: TextInputAction.done,\n"
                "autofillHints: const [AutofillHints.newPassword],\n"
                "onEditingComplete: () {\n"
                "  TextInput.finishAutofillContext();\n"
                "  FocusScope.of(context).unfocus();\n"
                "},\n",
                text,
                count=1,
            )

        if 'phone_number_input' in rel or 'phone_number_input' in name:
            text = ensure_import(text, "import 'package:flutter/services.dart';")
            text = re.sub(
                r"keyboardType: TextInputType\.phone,\n(?!\s*textInputAction)",
                "keyboardType: TextInputType.phone,\n"
                "textInputAction: TextInputAction.done,\n"
                "autofillHints: const [AutofillHints.telephoneNumber, AutofillHints.telephoneNumberNational],\n"
                "onEditingComplete: () {\n"
                "  TextInput.finishAutofillContext();\n"
                "  FocusScope.of(context).unfocus();\n"
                "},\n",
                text,
            )

        if 'personal_contact' in rel or 'personal_information' in rel:
            text = re.sub(
                r"keyboardType: TextInputType\.name,\n(?!\s*textInputAction)",
                "keyboardType: TextInputType.name,\ntextInputAction: TextInputAction.next,\n",
                text,
            )

        if 'home_address' in rel or 'address_contact' in rel:
            text = re.sub(
                r"keyboardType: TextInputType\.streetAddress,\n(?!\s*textInputAction)",
                "keyboardType: TextInputType.streetAddress,\ntextInputAction: TextInputAction.next,\n",
                text,
            )

        if text != original:
            p.write_text(text)
            print(f'[guardrail] patched keyboard/autofill in {p.relative_to(ROOT)}')


def main():
    patch_main_notification_prompt()
    patch_app_state_fake_btc()
    patch_fake_btc_seed_conditions()
    patch_duress_pin_alert_flow()
    patch_emergency_contact_empty_strings()
    patch_location_to_agreements()
    patch_agreements_completion()
    patch_keyboard_and_autofill()
    print('[guardrail] generated fixes complete')


if __name__ == '__main__':
    main()
