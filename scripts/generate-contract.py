#!/usr/bin/env python3
"""Generate Codable projections; the bundled JSON Schema validates the full wire boundary."""
import argparse
import hashlib
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--check', action='store_true')
args = parser.parse_args()
raw = (root / 'Contracts/product-api.json').read_bytes()
source = json.loads((root / 'Contracts/source.json').read_text())
assert hashlib.sha256(raw).hexdigest() == source['sha256'], 'Contract provenance mismatch'
spec = json.loads(raw)
schemas = dict(spec['components']['schemas'])
roots = {
    'ServerInfoResponse': ('/api/server/info', 'get', '200'),
    'PairResponse': ('/api/auth/pair', 'post', '200'),
    'PairRequest': ('/api/auth/pair', 'post', None),
    'AccessResponse': ('/api/auth/session', 'post', '200'),
    'CreateSessionResponse': ('/api/messages/session/new', 'post', '201'),
    'UploadResponse': ('/api/messages/session/{session_id}/attachments', 'post', '200'),
    'AskSnapshot': ('/api/control/sessions/{session_id}/ask', 'get', '200'),
    'PermissionsSnapshot': ('/api/control/sessions/{session_id}/permissions', 'get', '200'),
}
for name, (path, method, status) in roots.items():
    operation = spec['paths'][path][method]
    body = operation['requestBody'] if status is None else operation['responses'][status]
    schemas[name] = body['content']['application/json']['schema']


def name(value):
    value = re.sub(r'[^A-Za-z0-9_]', '_', value).lstrip('_')
    return value if not value[0].isdigit() else 'Value_' + value


def swift_type(schema, hint):
    if '$ref' in schema:
        return name(schema['$ref'].rsplit('/', 1)[1])
    variants = schema.get('anyOf', schema.get('oneOf', []))
    if variants:
        actual = [v for v in variants if v.get('type') != 'null']
        if len(actual) == 1:
            return swift_type(actual[0], hint) + ('?' if len(actual) != len(variants) else '')
        return 'JSONValue'
    kind = schema.get('type')
    if kind is None and 'const' in schema:
        kind = 'boolean' if isinstance(schema['const'], bool) else 'integer' if isinstance(schema['const'], int) else 'string'
    if kind == 'string': return 'String'
    if kind == 'integer': return 'Int64'
    if kind == 'number': return 'Double'
    if kind == 'boolean': return 'Bool'
    if kind == 'array': return '[' + swift_type(schema.get('items', {}), hint + '_Item') + ']'
    if kind == 'object' or 'properties' in schema:
        if schema.get('properties'):
            nested = name(hint)
            if nested not in schemas:
                schemas[nested] = schema
            return nested
        extra = schema.get('additionalProperties')
        return '[String: ' + (swift_type(extra, hint + '_Value') if isinstance(extra, dict) else 'JSONValue') + ']'
    return 'JSONValue'

lines = ['// Generated from Contracts/product-api.json. Do not edit.', 'import Foundation', '', 'public enum Wire {']
processed = set()
while pending := [k for k in schemas if k not in processed]:
    for key in sorted(pending):
        processed.add(key)
        schema = schemas[key]
        model = name(key)
        fields = schema.get('properties', {})
        if not fields:
            kind = swift_type(schema, model)
            if kind == model: kind = 'JSONValue'
            lines.append(f'    public typealias {model} = {kind}')
            continue
        required = schema.get('required', [])
        props = []
        for field, child in fields.items():
            kind = swift_type(child, model + '_' + name(field))
            if field not in required and not kind.endswith('?'): kind += '?'
            props.append((field, kind))
        lines.append(f'    public struct {model}: Codable, Sendable, Equatable {{')
        lines += [f'        public var `{field}`: {kind}' for field, kind in props]
        parameters = ', '.join(f'`{field}`: {kind}' + (' = nil' if kind.endswith('?') else '') for field, kind in props)
        lines.append(f'        public init({parameters}) {{')
        lines += [f'            self.`{field}` = `{field}`' for field, _ in props]
        lines += ['        }', '    }']
lines += ['}', '']
outputs = {
    root / 'Packages/MagiCore/Sources/MagiCore/Generated/Wire.swift': '\n'.join(lines).encode(),
    root / 'Packages/MagiCore/Sources/MagiCore/Resources/product-api.json': raw,
}
for path, content in outputs.items():
    if args.check:
        assert path.read_bytes() == content, f'{path.name} is stale'
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)
print(f'Validated {len(processed)} generated wire types' if args.check else f'Generated {len(processed)} wire types')
