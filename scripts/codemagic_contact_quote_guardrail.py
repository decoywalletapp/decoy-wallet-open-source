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


def patch_duress_alert_gate():
    alert_files = 0
    patched = 0

    for path in (ROOT / 'lib').rglob('*.dart'):
        original = path.read_text()
        if 'sendEmergencyAlertsCall.call' not in original and 'SendEmergencyAlertsCall.call' not in original:
            continue

        alert_files += 1
        text = re.sub(
            r"if\s*\(\s*FFAppState\(\)\.decoyPinContactsEnabled\s*==\s*true\s*\)\s*\{",
            "if (true) {",
            original,
        )
        text = re.sub(
            r"if\s*\(\s*FFAppState\(\)\.decoyPinContactsEnabled\s*\)\s*\{",
            "if (true) {",
            text,
        )

        if text != original:
            path.write_text(text)
            patched += 1
            print(f'[guardrail] removed extra decoyPinContactsEnabled alert gate in {path.relative_to(ROOT)}')

    if alert_files == 0:
        print('[guardrail] warning: no emergency alert call files found')
    elif patched == 0:
        print(f'[guardrail] duress alert gate already clean; alert files checked={alert_files}')


def patch_fake_btc_persistence():
    app_state = ROOT / 'lib' / 'app_state.dart'
    if not app_state.exists():
        print('[guardrail] warning: lib/app_state.dart not found for fake BTC persistence patch')
        return

    original = app_state.read_text()
    text = original.replace(
        'if (_fakeBtcSeededAt == null) return _fakeBtcBalance <= 0.0;',
        'if (_fakeBtcSeededAt == null) return false;',
    )
    text = text.replace(
        'if (value > 0 && (_fakeBtcSeededAt == null || _fakeSeeded != true || wasStale)) {',
        'if (value >= 0 && (_fakeBtcSeededAt == null || _fakeSeeded != true || wasStale)) {',
    )

    if text != original:
        app_state.write_text(text)
        print('[guardrail] hardened fake BTC persistence window in lib/app_state.dart')
    else:
        print('[guardrail] fake BTC persistence already hardened or source not yet patched')


def patch_fake_btc_seed_conditions():
    app_state = ROOT / 'lib' / 'app_state.dart'
    if not app_state.exists() or 'shouldSeedFakeBtcBalance' not in app_state.read_text():
        print('[guardrail] skipping fake BTC seed condition cleanup; shouldSeedFakeBtcBalance is unavailable')
        return

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
    patch_duress_alert_gate()
    patch_fake_btc_persistence()
    patch_fake_btc_seed_conditions()


if __name__ == '__main__':
    main()
