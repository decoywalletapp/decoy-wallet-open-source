#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
EMPTY_QUOTE_DEFAULT = re.compile(r"=\s*'(?:\\*\"\\*\")';")
EMPTY_QUOTE_DEFAULT_DOUBLE = re.compile(r'=\s*"(?:\\*\"\\*\")";')


def main():
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


if __name__ == '__main__':
    main()
