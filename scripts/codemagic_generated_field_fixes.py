#!/usr/bin/env python3
"""Small build-time fixes for FlutterFlow generated code.

This script is intentionally conservative. It does not rewrite the duress PIN
alert gate and it does not move onboarding/agreement routing. Those flows are
owned by the FlutterFlow action chains.
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


def find_call_spans(text: str, call_name: str):
    spans = []
    needle = f'{call_name}('
    start = 0
    while True:
        idx = text.find(needle, start)
        if idx == -1:
            break
        depth = 0
        pos = idx
        in_string = None
        escape = False
        while pos < len(text):
            ch = text[pos]
            if in_string:
                if escape:
                    escape = False
                elif ch == '\\':
                    escape = True
                elif ch == in_string:
                    in_string = None
            else:
                if ch in ('"', "'"):
                    in_string = ch
                elif ch == '(':
                    depth += 1
                elif ch == ')':
                    depth -= 1
                    if depth == 0:
                        spans.append((idx, pos + 1))
                        start = pos + 1
                        break
            pos += 1
        else:
            break
    return spans


def _format_prop(prop: str, indent: str) -> str:
    return ''.join(f'\n{indent}{line}' for line in prop.splitlines())


def insert_props_before_decoration(block: str, props: list[str]) -> str:
    missing = []
    for prop in props:
        name = prop.split(':', 1)[0].strip()
        if re.search(rf'\b{re.escape(name)}\s*:', block):
            continue
        missing.append(prop)
    if not missing:
        return block

    match = re.search(r'\n(\s*)decoration\s*:', block)
    if match:
        indent = match.group(1)
        insertion = ''.join(_format_prop(prop, indent) for prop in missing)
        return block[:match.start()] + insertion + block[match.start():]

    close = block.rfind(')')
    if close == -1:
        return block
    insertion = ''.join(_format_prop(prop, '        ') for prop in missing)
    return block[:close] + insertion + block[close:]


def field_kind(path: Path, block: str) -> set[str]:
    haystack = f'{path.as_posix()}\n{block}'.lower()
    kinds: set[str] = set()

    if 'email' in haystack:
        kinds.add('email')
    if 'confirm password' in haystack or 'confirmpassword' in haystack:
        kinds.add('confirm_password')
    elif 'password' in haystack:
        kinds.add('password')
    if 'phone' in haystack or 'telephone' in haystack:
        kinds.add('phone')
    if 'first name' in haystack or 'firstname' in haystack:
        kinds.add('first_name')
    if 'last name' in haystack or 'lastname' in haystack:
        kinds.add('last_name')
    if 'street' in haystack or 'address' in haystack:
        kinds.add('street')
    if 'city' in haystack:
        kinds.add('city')
    if 'state' in haystack:
        kinds.add('state')
    if 'zip' in haystack or 'postal' in haystack:
        kinds.add('zip')

    return kinds


def props_for_field(path: Path, block: str) -> list[str]:
    kinds = field_kind(path, block)
    props: list[str] = []
    path_s = path.as_posix().lower()

    if 'email' in kinds:
        props.append('autofillHints: const [AutofillHints.email, AutofillHints.username],')
        props.append('textInputAction: TextInputAction.next,')
    elif 'confirm_password' in kinds:
        props.append('autofillHints: const [AutofillHints.newPassword],')
        props.append('textInputAction: TextInputAction.done,')
    elif 'password' in kinds:
        props.append('autofillHints: const [AutofillHints.newPassword],')
        props.append('textInputAction: TextInputAction.next,')
    elif 'phone' in kinds:
        props.append(
            'autofillHints: const [\n'
            '  AutofillHints.telephoneNumber,\n'
            '  AutofillHints.telephoneNumberNational,\n'
            '],'
        )
        action = 'done' if 'phone_number_input' in path_s else 'next'
        props.append(f'textInputAction: TextInputAction.{action},')
    elif {'first_name', 'last_name', 'street', 'city', 'state', 'zip'} & kinds:
        props.append('textInputAction: TextInputAction.next,')

    return props


def _submit_focus_prop(next_focus_node: str) -> str:
    return (
        'onFieldSubmitted: (_) async {\n'
        f'  FocusScope.of(context).requestFocus(_model.{next_focus_node});\n'
        '},'
    )


def _submit_done_prop() -> str:
    return (
        'onFieldSubmitted: (_) async {\n'
        '  FocusScope.of(context).unfocus();\n'
        '},'
    )


def focus_props_for_field(path: Path, block: str) -> list[str]:
    path_s = path.as_posix().lower()

    if 'create_account_widget.dart' in path_s:
        if any(marker in block for marker in (
            'emailAddressFocusNode',
            'emailAddressTextController',
            'emailAddressKey',
        )):
            return [_submit_focus_prop('passwordCreateAccountFocusNode')]
        if any(marker in block for marker in (
            'passwordCreateAccountFocusNode',
            'passwordCreateAccountTextController',
            'passwordCreateAccountKey',
        )):
            return [_submit_focus_prop('passwordConfirmFocusNode')]
        if any(marker in block for marker in (
            'passwordConfirmFocusNode',
            'passwordConfirmTextController',
            'passwordConfirmKey',
            'confirmPasswordFocusNode',
            'confirmPasswordTextController',
            'confirmPasswordKey',
        )):
            return [_submit_done_prop()]

    if 'personal_information_widget.dart' in path_s:
        if any(marker in block for marker in (
            'lastNameFocusNode',
            'lastNameTextController',
            'lastNameKey',
        )):
            return [_submit_focus_prop('phoneFocusNode')]

    if 'home_address_entry_page_widget.dart' in path_s:
        if any(marker in block for marker in (
            'streetAddressFocusNode',
            'streetAddressTextController',
            'streetAddressKey',
        )):
            return [_submit_focus_prop('cityFocusNode')]

    return []


def patch_text_form_fields(path: Path) -> None:
    original = read(path)
    text = original
    spans = find_call_spans(text, 'TextFormField')
    if not spans:
        return

    pieces = []
    last = 0
    for start, end in spans:
        block = text[start:end]
        updated = insert_props_before_decoration(
            block,
            props_for_field(path, block) + focus_props_for_field(path, block),
        )
        pieces.append(text[last:start])
        pieces.append(updated)
        last = end
    pieces.append(text[last:])
    text = ''.join(pieces)

    write_if_changed(path, original, text)


def _force_phone_autofill_props(field: str) -> str:
    field = re.sub(
        r'autofillHints\s*:\s*\[[^\]]*\]\s*,',
        'autofillHints: const [\n'
        '  AutofillHints.telephoneNumber,\n'
        '  AutofillHints.telephoneNumberNational,\n'
        '],',
        field,
        count=1,
        flags=re.S,
    )
    field = re.sub(
        r'textInputAction\s*:\s*TextInputAction\.\w+\s*,',
        'textInputAction: TextInputAction.done,',
        field,
        count=1,
    )
    return insert_props_before_decoration(
        field,
        [
            'autofillHints: const [\n'
            '  AutofillHints.telephoneNumber,\n'
            '  AutofillHints.telephoneNumberNational,\n'
            '],',
            'textInputAction: TextInputAction.done,',
        ],
    )


def patch_phone_input_native_autofill_widget() -> None:
    path = ROOT / 'lib/welcom_pages/phone_number_input/phone_number_input_widget.dart'
    if not path.exists():
        return

    original = read(path)
    text = original

    spans = find_call_spans(text, 'Autocomplete<String>')
    if spans:
        pieces = []
        last = 0
        changed = False
        for start, end in spans:
            block = text[start:end]
            if 'phoneNumberFieldTextController' not in block:
                pieces.append(text[last:end])
                last = end
                continue

            field_spans = find_call_spans(block, 'TextFormField')
            if not field_spans:
                pieces.append(text[last:end])
                last = end
                continue

            field_start, field_end = field_spans[0]
            field = block[field_start:field_end]
            field = re.sub(
                r'controller\s*:\s*textEditingController\s*,',
                'controller: _model.phoneNumberFieldTextController,',
                field,
                count=1,
                flags=re.S,
            )
            field = re.sub(
                r'focusNode\s*:\s*focusNode\s*,',
                'focusNode: _model.phoneNumberFieldFocusNode,',
                field,
                count=1,
                flags=re.S,
            )
            field = re.sub(
                r'\n\s*onEditingComplete\s*:\s*onEditingComplete\s*,',
                '',
                field,
                count=1,
                flags=re.S,
            )
            field = _force_phone_autofill_props(field)

            pieces.append(text[last:start])
            pieces.append(field)
            last = end
            changed = True

        pieces.append(text[last:])
        if changed:
            text = ''.join(pieces)

    controller_line = '    _model.phoneNumberFieldTextController ??= TextEditingController();'
    focus_line = '    _model.phoneNumberFieldFocusNode ??= FocusNode();'
    if controller_line in text and 'phoneNumberFieldFocusNode ??= FocusNode()' not in text:
        text = text.replace(controller_line, f'{controller_line}\n{focus_line}', 1)

    write_if_changed(path, original, text)


def patch_phone_input_native_autofill_model() -> None:
    path = ROOT / 'lib/welcom_pages/phone_number_input/phone_number_input_model.dart'
    if not path.exists():
        return

    original = read(path)
    text = original
    focus_dispose = '    phoneNumberFieldFocusNode?.dispose();'
    controller_dispose = '    phoneNumberFieldTextController?.dispose();'
    if focus_dispose in text and controller_dispose not in text:
        text = text.replace(focus_dispose, f'{focus_dispose}\n{controller_dispose}', 1)

    write_if_changed(path, original, text)


def patch_phone_input_native_autofill() -> None:
    patch_phone_input_native_autofill_widget()
    patch_phone_input_native_autofill_model()


def patch_keyboard_and_autofill() -> None:
    targets = [
        ROOT / 'lib/welcom_pages/create_account/create_account_widget.dart',
        ROOT / 'lib/welcom_pages/phone_number_input/phone_number_input_widget.dart',
        ROOT / 'lib/emergancy_contact_information/personal_information/personal_information_widget.dart',
        ROOT / 'lib/emergancy_contact_information/home_address_entry_page/home_address_entry_page_widget.dart',
        ROOT / 'lib/emergancy_contact_information/emergency_contacts/emergency_contacts_widget.dart',
    ]
    for path in targets:
        if path.exists():
            patch_text_form_fields(path)


def patch_main_notification_prompt() -> None:
    path = ROOT / 'lib/main.dart'
    if not path.exists():
        return
    original = read(path)
    text = re.sub(
        r'FirebaseMessaging\.instance\.requestPermission\s*\([^;]*\)',
        'FirebaseMessaging.instance.getNotificationSettings()',
        original,
        flags=re.S,
    )
    write_if_changed(path, original, text)


def validate_no_duplicate_textfield_args() -> None:
    for path in (ROOT / 'lib').rglob('*.dart'):
        text = read(path)
        for start, end in find_call_spans(text, 'TextFormField'):
            block = text[start:end]
            for arg in ('autofillHints', 'textInputAction', 'onFieldSubmitted'):
                count = len(re.findall(rf'\b{arg}\s*:', block))
                if count > 1:
                    raise SystemExit(
                        f'Duplicate {arg} in {path.relative_to(ROOT)} near byte {start}'
                    )


def main() -> None:
    patch_main_notification_prompt()
    patch_phone_input_native_autofill()
    patch_keyboard_and_autofill()
    validate_no_duplicate_textfield_args()
    print('[guardrail] safe generated field fixes complete')


if __name__ == '__main__':
    main()
