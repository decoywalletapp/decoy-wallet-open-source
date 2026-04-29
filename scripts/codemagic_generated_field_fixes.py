#!/usr/bin/env python3
from pathlib import Path
import re
import sys


def fail(message: str) -> None:
    print(f"[generated-field-fixes] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def note(message: str) -> None:
    print(f"[generated-field-fixes] {message}")


def replace_after(text: str, marker: str, old: str, new: str, label: str) -> str:
    start = text.find(marker)
    if start == -1:
        fail(f"{label}: marker not found")

    found_new = text.find(new, start)
    found_old = text.find(old, start)
    if found_new != -1 and (found_old == -1 or found_new < found_old):
        note(f"{label}: already patched")
        return text

    if found_old == -1:
        fail(f"{label}: old block not found after marker")

    note(f"{label}: patched")
    return text[:found_old] + new + text[found_old + len(old):]


def replace_optional(text: str, old: str, new: str, label: str) -> str:
    if old in text:
        note(f"{label}: patched")
        return text.replace(old, new)
    note(f"{label}: already patched or pattern absent")
    return text


def replace_on_editing_complete_after(text: str, marker: str, body: str, label: str) -> str:
    start = text.find(marker)
    if start == -1:
        fail(f"{label}: marker not found")

    window = text[start:start + 5000]
    if body in window:
        note(f"{label}: already patched")
        return text

    match = re.search(
        r'(?P<indent>[ \t]*)onEditingComplete:\s*\n?[ \t]*onEditingComplete,',
        window,
    )
    if not match:
        fail(f"{label}: onEditingComplete handoff not found after marker")

    indent = match.group('indent')
    new_block = f"{indent}onEditingComplete: () {{\n{indent}  {body}\n{indent}}},"
    absolute_start = start + match.start()
    absolute_end = start + match.end()
    note(f"{label}: patched")
    return text[:absolute_start] + new_block + text[absolute_end:]


def write_if_changed(path: Path, text: str, original: str) -> None:
    if text != original:
        path.write_text(text)
        note(f"wrote {path}")
    else:
        note(f"no changes needed for {path}")


def patch_main_notification_permission() -> None:
    path = Path('lib/main.dart')
    text = path.read_text()
    original = text

    old = """    var settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }

    final allowed =
"""
    new = """    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    // Do not trigger the iOS notification prompt from app startup or auth refresh.
    // The onboarding notifications page asks for permission only after the user continues.
    final allowed =
"""

    if old in text:
        text = text.replace(old, new, 1)
        note('main push permission prompt: delayed until onboarding')
    elif 'Do not trigger the iOS notification prompt from app startup or auth refresh.' in text:
        note('main push permission prompt: already patched')
    else:
        fail('main push permission prompt: requestPermission startup block not found')

    write_if_changed(path, text, original)


def patch_personal_information_keyboard() -> None:
    path = Path('lib/emergancy_contact_information/personal_information/personal_information_widget.dart')
    text = path.read_text()
    original = text

    text = replace_on_editing_complete_after(
        text,
        '_model.lastNameTextController',
        '_model.phoneFocusNode?.requestFocus();',
        'personal info last name Next action',
    )

    write_if_changed(path, text, original)


def patch_home_address_keyboard() -> None:
    path = Path('lib/emergancy_contact_information/home_address_entry_page/home_address_entry_page_widget.dart')
    text = path.read_text()
    original = text

    text = replace_on_editing_complete_after(
        text,
        '_model.streetAddressTextController',
        '_model.cityFocusNode?.requestFocus();',
        'home address street Next action',
    )

    write_if_changed(path, text, original)


def patch_create_account() -> None:
    path = Path('lib/welcom_pages/create_account/create_account_widget.dart')
    text = path.read_text()
    original = text

    old_complete = """                                              onEditingComplete:
                                                  onEditingComplete,"""

    text = replace_after(
        text,
        """_model.emailAddressTextController =
                                                textEditingController;""",
        old_complete,
        """                                              onEditingComplete: () {
                                                _model.passwordCreateAccountFocusNode?.requestFocus();
                                              },""",
        'create account email Next action',
    )

    text = replace_after(
        text,
        """_model.passwordCreateAccountTextController =
                                                textEditingController;""",
        old_complete,
        """                                              onEditingComplete: () {
                                                _model.passwordConfirmFocusNode?.requestFocus();
                                              },""",
        'create account password Next action',
    )

    text = replace_after(
        text,
        """_model.passwordConfirmTextController =
                                                textEditingController;""",
        old_complete,
        """                                              onEditingComplete: () {
                                                TextInput.finishAutofillContext();
                                                FocusScope.of(context).unfocus();
                                              },""",
        'create account confirm password Done action',
    )

    text = replace_after(
        text,
        """_model.emailAddressTextController =
                                                textEditingController;""",
        """                                              autofillHints: [
                                                AutofillHints.email
                                              ],""",
        """                                              autofillHints: [
                                                AutofillHints.username,
                                                AutofillHints.email
                                              ],""",
        'create account email autofill hints',
    )

    text = text.replace('AutofillHints.password', 'AutofillHints.newPassword')
    text = replace_optional(
        text,
        """                                              enableInteractiveSelection: false,
""",
        '',
        'create account interactive selection',
    )
    text = replace_optional(
        text,
        "return ['Option 1'].where",
        "return const <String>[].where",
        'create account placeholder autocomplete options',
    )

    write_if_changed(path, text, original)


def patch_phone_number_main() -> None:
    path = Path('lib/welcom_pages/phone_number_input/phone_number_input_widget.dart')
    text = path.read_text()
    original = text

    if "package:flutter/services.dart" not in text:
        text = text.replace(
            "import 'package:flutter/scheduler.dart';\n",
            "import 'package:flutter/scheduler.dart';\nimport 'package:flutter/services.dart';\n",
        )
        note('phone number main services import: patched')

    text = replace_after(
        text,
        """_model.phoneNumberFieldTextController =
                                                    textEditingController;""",
        """                                                  onEditingComplete:
                                                      onEditingComplete,""",
        """                                                  onEditingComplete: () {
                                                    TextInput.finishAutofillContext();
                                                    FocusScope.of(context).unfocus();
                                                  },""",
        'phone number main Done action',
    )

    text = replace_after(
        text,
        """_model.phoneNumberFieldTextController =
                                                    textEditingController;""",
        """                                                  autofillHints: [
                                                    AutofillHints.telephoneNumber
                                                  ],""",
        """                                                  autofillHints: [
                                                    AutofillHints.telephoneNumber,
                                                    AutofillHints.telephoneNumberNational
                                                  ],""",
        'phone number main autofill hints',
    )
    text = replace_optional(
        text,
        "return ['Option 1'].where",
        "return const <String>[].where",
        'phone number main placeholder autocomplete options',
    )

    write_if_changed(path, text, original)


def patch_phone_number_copy() -> None:
    path = Path('lib/test_subjects/phone_number_input_copy/phone_number_input_copy_widget.dart')
    if not path.exists():
        note('phone number copy: file absent')
        return

    text = path.read_text()
    original = text

    if "package:flutter/services.dart" not in text:
        text = text.replace(
            "import 'package:flutter/scheduler.dart';\n",
            "import 'package:flutter/scheduler.dart';\nimport 'package:flutter/services.dart';\n",
        )
        note('phone number copy services import: patched')

    if 'TextInput.finishAutofillContext();' not in text:
        text = text.replace(
            """                                  focusNode: _model.phoneNumberFieldFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(""",
            """                                  focusNode: _model.phoneNumberFieldFocusNode,
                                  onEditingComplete: () {
                                    TextInput.finishAutofillContext();
                                    FocusScope.of(context).unfocus();
                                  },
                                  onChanged: (_) => EasyDebounce.debounce(""",
        )
        note('phone number copy Done action: patched')
    else:
        note('phone number copy Done action: already patched')

    text = replace_optional(
        text,
        """                                  autofillHints: [AutofillHints.telephoneNumber],""",
        """                                  autofillHints: [
                                    AutofillHints.telephoneNumber,
                                    AutofillHints.telephoneNumberNational
                                  ],""",
        'phone number copy autofill hints',
    )

    write_if_changed(path, text, original)


def patch_location_route_to_agreements() -> None:
    path = Path('lib/welcom_pages/location_authorization/location_authorization_widget.dart')
    text = path.read_text()
    original = text

    if 'CreatePinWidget.routeName' in text:
        text = text.replace('CreatePinWidget.routeName', 'AgreementsPageWidget.routeName')
        note('location authorization route: routed to AgreementsPage before PIN setup')
    elif 'AgreementsPageWidget.routeName' in text:
        note('location authorization route: already routed to AgreementsPage')
    else:
        fail('location authorization route: no CreatePin or Agreements route target found')

    write_if_changed(path, text, original)


def patch_agreements_page_completion() -> None:
    path = Path('lib/welcom_pages/agreements_page/agreements_page_widget.dart')
    if not path.exists():
        note('agreements page completion: file absent')
        return

    text = path.read_text()
    original = text

    text = replace_optional(
        text,
        """          'setup_complete': true,
          'setup_completed_at': supaSerialize<DateTime>(acceptedAt),""",
        """          'agreements_complete': true,
          'agreements_completed_at': supaSerialize<DateTime>(acceptedAt),""",
        'agreements page backend acceptance fields',
    )

    if 'HomePageWidget.routeName' in text:
        text = text.replace('HomePageWidget.routeName', 'CreatePinWidget.routeName', 1)
        note('agreements page route: routed to CreatePin after legal acceptance')
    elif 'CreatePinWidget.routeName' in text:
        note('agreements page route: already routed to CreatePin')
    else:
        fail('agreements page route: no HomePage or CreatePin route target found')

    write_if_changed(path, text, original)


def patch_create_pin_route() -> None:
    # Create PIN is now the final onboarding gate. Leave its existing HomePage route intact.
    note('create pin route: left as final setup gate')


def patch_fake_btc_persistence() -> None:
    path = Path('lib/app_state.dart')
    text = path.read_text()
    original = text

    helper = """
  bool get shouldSeedFakeBtcBalance =>
      _fakeSeeded != true || _isFakeBtcBalanceStale();
"""
    marker = "\n  bool _isFakeBtcBalanceStale() {"
    if 'bool get shouldSeedFakeBtcBalance =>' not in text:
        if marker not in text:
            fail('fake BTC persistence: stale helper marker not found')
        text = text.replace(marker, helper + marker, 1)
        note('fake BTC persistence: added reseed helper')
    else:
        note('fake BTC persistence: reseed helper already present')

    old_stale = """  bool _isFakeBtcBalanceStale() {
    if (_fakeSeeded != true) return false;
    if (!_fakeBtcBalance.isFinite ||
        _fakeBtcBalance <= _fakeBtcReseedThreshold) {
      return true;
    }

    final seededAt = _fakeBtcSeededAt;
    if (seededAt == null) return false;

    return DateTime.now().toUtc().difference(seededAt.toUtc()) >=
        _fakeBtcReseedCooldown;
  }
"""
    new_stale = """  bool _isFakeBtcBalanceStale() {
    if (_fakeSeeded != true) return false;
    if (!_fakeBtcBalance.isFinite || _fakeBtcBalance < 0.0) {
      return true;
    }

    final seededAt = _fakeBtcSeededAt;
    if (seededAt == null) return false;

    return DateTime.now().toUtc().difference(seededAt.toUtc()) >=
        _fakeBtcReseedCooldown;
  }
"""
    if old_stale in text:
        text = text.replace(old_stale, new_stale, 1)
        note('fake BTC persistence: low balance now persists until cooldown')
    elif '_fakeBtcBalance < 0.0' in text:
        note('fake BTC persistence: stale logic already patched')
    else:
        fail('fake BTC persistence: stale logic block not found')

    write_if_changed(path, text, original)


def patch_fake_btc_seed_conditions() -> None:
    pattern = re.compile(
        r'\(FFAppState\(\)\s*\.fakeSeeded\s*==\s*false\)\s*\|\|\s*'
        r'\(FFAppState\(\)\s*\.fakeBtcBalance\s*<=\s*(?:0\.0|0\.05)\)',
        re.MULTILINE,
    )

    patched_any = False
    for path in Path('lib').rglob('*_widget.dart'):
        text = path.read_text()
        original = text
        text, count = pattern.subn('FFAppState().shouldSeedFakeBtcBalance == true', text)
        if count:
            patched_any = True
            note(f'fake BTC reseed condition: patched {path} ({count})')
            write_if_changed(path, text, original)

    if not patched_any:
        note('fake BTC reseed condition: no generated reseed expressions found')


def patch_duress_pin_alert_flow() -> None:
    path = Path('lib/pin_pages/p_i_n_page/p_i_n_page_widget.dart')
    text = path.read_text()
    original = text

    gate_pattern = re.compile(
        r'if\s*\(\s*FFAppState\(\)\s*\.decoyPinContactsEnabled\s*==\s*true\s*\)\s*\{',
        re.MULTILINE,
    )
    text, gate_count = gate_pattern.subn('if (true) {', text, count=1)
    if gate_count:
        note('duress PIN alert: removed local contacts toggle from alert gate')
    elif 'decoyPinContactsEnabled' in text and 'sendEmergencyAlertsCall' in text:
        fail('duress PIN alert: contacts toggle gate still present near alert flow')
    else:
        note('duress PIN alert: local contacts toggle gate already absent')

    alert_pattern = re.compile(
        r'unawaited\(\s*\(\)\s+async\s+\{\s*'
        r'(_model\.alertResult1\s*=\s*await\s*DecoyAlertGroup\s*\.sendEmergencyAlertsCall\s*\.call\([\s\S]*?\);\s*)'
        r'\}\(\),\s*\);',
        re.MULTILINE,
    )
    text, alert_count = alert_pattern.subn(lambda m: m.group(1), text, count=1)
    if alert_count:
        note('duress PIN alert: alert call is awaited before navigation')
    elif re.search(
        r'_model\.alertResult1\s*=\s*await\s*DecoyAlertGroup\s*\.sendEmergencyAlertsCall\s*\.call',
        text,
    ):
        note('duress PIN alert: alert call already awaited')
    else:
        fail('duress PIN alert: sendEmergencyAlerts call not found')

    if re.search(r'unawaited\([\s\S]{0,2500}sendEmergencyAlertsCall', text):
        fail('duress PIN alert: alert call is still fire-and-forget')

    write_if_changed(path, text, original)


def patch_emergency_contact_defaults() -> None:
    path = Path('lib/emergancy_contact_information/emergency_contacts/emergency_contacts_model.dart')
    text = path.read_text()
    original = text

    fields = [
        'contactsJson', 'dataKeyB64', 'ctB64', 'nonceB64', 'wrappedB64',
        'c1First', 'c1Last', 'c1Phone', 'c2First', 'c2Last', 'c2Phone',
        'c3First', 'c3Last', 'c3Phone', 'c4First', 'c4Last', 'c4Phone',
        'c5First', 'c5Last', 'c5Phone',
    ]
    field_group = '|'.join(fields)
    text = re.sub(rf"String ({field_group}) = '\\\"\\\"';", r"String \1 = '';", text)
    text = re.sub(rf"String ({field_group}) = '\"\"';", r"String \1 = '';", text)
    text = re.sub(rf"String ({field_group}) = \"''\";", r"String \1 = '';", text)

    if '\\"\\"' in text or "= '\"\"';" in text:
        fail('emergency contact quote placeholders remain')

    write_if_changed(path, text, original)


def main() -> None:
    patch_main_notification_permission()
    patch_personal_information_keyboard()
    patch_home_address_keyboard()
    patch_create_account()
    patch_phone_number_main()
    patch_phone_number_copy()
    patch_location_route_to_agreements()
    patch_agreements_page_completion()
    patch_create_pin_route()
    patch_fake_btc_persistence()
    patch_fake_btc_seed_conditions()
    patch_duress_pin_alert_flow()
    patch_emergency_contact_defaults()
    note('all generated field fixes complete')


if __name__ == '__main__':
    main()
