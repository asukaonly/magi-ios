#!/usr/bin/env python3
"""Check localization parity and statically referenced UI keys."""
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
catalogs = []
for language in ['en', 'zh-Hans']:
    content = (root / f'MagiIOS/Resources/{language}.lproj/Localizable.strings').read_text()
    keys = re.findall(r'^"([^"]+)"\s*=', content, re.MULTILINE)
    assert len(keys) == len(set(keys)), f'Duplicate keys in {language}'
    catalogs.append(set(keys))
assert catalogs[0] == catalogs[1], 'Localization keys differ'
referenced = set()
for file in (root / 'MagiIOS').glob('*.swift'):
    content = re.sub(r'\.accessibilityIdentifier\("[^"]*"\)', '', file.read_text())
    referenced.update(re.findall(r'"((?:welcome|connection|tab|conversations|chat|attachment|outgoing|interaction|permission|tasks|notifications|action|error|turn)\.[a-zA-Z.]+)"', content))
assert referenced <= catalogs[0], f'Missing keys: {referenced - catalogs[0]}'
print(f'Validated {len(catalogs[0])} English and Chinese localization keys')
