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


def write_if_changed(path: Path, text: str, original: str) -> None:
    if text != original:
        path.write_text(text)
        note(f"wrote {path}")
    else:
        note(f"no changes needed for {path}")


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

    write_if_changed(path, text, original)


def patch_create_pin_route() -> None:
    path = Path('lib/pin_pages/create_pin/create_pin_widget.dart')
    text = path.read_text()
    original = text

    if 'AgreementsPageWidget' in text:
        note('create pin route: already routed through AgreementsPage')
        return

    old_route = """HomePageWidget
                                                            .routeName"""
    new_route = """AgreementsPageWidget
                                                            .routeName"""

    if old_route in text:
        text = text.replace(old_route, new_route, 1)
    else:
        text, count = re.subn(
            r'HomePageWidget\s*\.routeName',
            "AgreementsPageWidget\n                                                            .routeName",
            text,
            count=1,
        )
        if count != 1:
            fail('create pin route: HomePage route target not found')

    note('create pin route: routed through AgreementsPage')
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
    patch_create_account()
    patch_phone_number_main()
    patch_phone_number_copy()
    patch_create_pin_route()
    patch_emergency_contact_defaults()
    note('all generated field fixes complete')


if __name__ == '__main__':
    main()
