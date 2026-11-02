#!/usr/bin/env python3
"""Copy the committed, authoritative product contract and record its provenance."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source', type=Path, default=root.parent / 'magi')
args = parser.parse_args()
revision = subprocess.check_output(['git', '-C', str(args.source), 'rev-parse', 'HEAD'], text=True).strip()
contract = subprocess.check_output(['git', '-C', str(args.source), 'show', f'{revision}:contracts/api/client-product.json'])
json.loads(contract)
(root / 'Contracts/product-api.json').write_bytes(contract)
(root / 'Contracts/source.json').write_text(json.dumps({
    'repository': 'https://github.com/asukaonly/magi', 'revision': revision,
    'path': 'contracts/api/client-product.json', 'sha256': hashlib.sha256(contract).hexdigest(),
}, indent=2) + '\n')
subprocess.run(['python3', str(root / 'scripts/generate-contract.py')], check=True)
