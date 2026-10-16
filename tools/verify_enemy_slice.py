"""Read-only source intake verification; no import or runtime acceptance claim."""
from pathlib import Path
import argparse
import base64
import copy
import json
import math
import struct

import build_enemy_slice as intake


def require(condition, message):
    if not condition:
        raise ValueError(message)


def integer(value, label, minimum=0):
    require(type(value) is int and value >= minimum, label)
    return value


def item(items, index, label):
    integer(index, label)
    require(index < len(items), label)
    return items[index]


def checked_accessor(doc, index):
    a = item(doc['accessors'], index, 'accessor index')
    view = item(doc['bufferViews'], a['bufferView'], 'bufferView index')
    buffer = item(doc['buffers'], view['buffer'], 'buffer index')
    require(a['componentType'] in intake.TYPES and a['type'] in intake.SIZES, 'accessor format')
    require('sparse' not in a and not a.get('normalized'), 'unsupported encoding')
    count = integer(a['count'], 'accessor count', 1)
    require(count <= 100000, 'accessor budget')
    component_size = struct.calcsize('<' + intake.TYPES[a['componentType']])
    size = component_size * intake.SIZES[a['type']]
    offset = integer(a.get('byteOffset', 0), 'accessor offset')
    start = integer(view.get('byteOffset', 0), 'view offset')
    length = integer(view['byteLength'], 'view length', 1)
    stride = integer(view.get('byteStride', size), 'stride', size)
    require(offset % component_size == 0 and start % component_size == 0 and stride % component_size == 0, 'alignment')
    require(offset + (count - 1) * stride + size <= length, 'accessor view bounds')
    uri = buffer['uri']
    require(uri.startswith('data:application/octet-stream;base64,'), 'external buffer forbidden')
    data = base64.b64decode(uri.split(',', 1)[1], validate=True)
    require(integer(buffer['byteLength'], 'buffer length') == len(data), 'buffer declared length')
    require(start + length <= len(data), 'view buffer bounds')
    values = intake.accessor(doc, index)
    require(all(math.isfinite(n) for row in values for n in row), 'nonfinite accessor')
    return values


def validate_document(doc):
    """Strict bounds/skin checks precede the original intake's metric inspection."""
    require(doc['asset']['version'] == '2.0', 'glTF version')
    values = [checked_accessor(doc, i) for i in range(len(doc['accessors']))]
    def read(index):
        return item(values, index, 'referenced accessor')
    require(len(doc['skins']) == 1, 'one skin required')
    joints = doc['skins'][0]['joints']
    require(len(joints) == 43 and len(set(joints)) == 43, 'joint identity/count')
    for joint in joints:
        item(doc['nodes'], joint, 'skin joint node')
    inverse = doc['skins'][0].get('inverseBindMatrices')
    if inverse is not None:
        require(len(read(inverse)) == len(joints), 'inverse bind count')
        require(doc['accessors'][inverse]['type'] == 'MAT4', 'inverse bind format')
    for mesh in doc['meshes']:
        for primitive in mesh['primitives']:
            attrs = primitive['attributes']
            positions = read(attrs['POSITION'])
            require(doc['accessors'][attrs['POSITION']]['type'] == 'VEC3', 'position format')
            for ref in attrs.values():
                require(len(read(ref)) == len(positions), 'vertex attribute count mismatch')
            for name in ('JOINTS_0', 'WEIGHTS_0'):
                require(doc['accessors'][attrs[name]]['type'] == 'VEC4', 'skin attribute format')
            require(doc['accessors'][attrs['JOINTS_0']]['componentType'] in (5121, 5123), 'joint component format')
            weights, influences = read(attrs['WEIGHTS_0']), read(attrs['JOINTS_0'])
            for row, bones in zip(weights, influences):
                require(all(0 <= w <= 1 for w in row) and abs(sum(row) - 1) < .001, 'invalid skin weights')
                require(all(type(j) is int and 0 <= j < len(joints) for j in bones), 'invalid skin influence')
            index = primitive['indices']
            indices = read(index)
            require(doc['accessors'][index]['type'] == 'SCALAR' and doc['accessors'][index]['componentType'] in (5121, 5123, 5125), 'index format')
            require(len(indices) % 3 == 0, 'triangle index count')
            require(all(type(row[0]) is int and 0 <= row[0] < len(positions) for row in indices), 'triangle vertex bounds')
    names = set()
    for animation in doc['animations']:
        require(animation['name'] not in names, 'duplicate clip name')
        names.add(animation['name'])
        for sampler in animation['samplers']:
            times, outputs = read(sampler['input']), read(sampler['output'])
            require(doc['accessors'][sampler['input']]['type'] == 'SCALAR', 'time format')
            require(times[0][0] >= 0 and all(a[0] < b[0] for a, b in zip(times, times[1:])), 'animation time ordering')
            require(sampler.get('interpolation', 'LINEAR') in ('LINEAR', 'STEP'), 'unsupported interpolation')
            require(len(times) == len(outputs), 'animation output count')
        for channel in animation['channels']:
            sampler = item(animation['samplers'], channel['sampler'], 'channel sampler')
            item(doc['nodes'], channel['target']['node'], 'channel node')
            path = channel['target']['path']
            require(path in ('translation', 'rotation', 'scale'), 'unsupported animation target')
            expected = 'VEC4' if path == 'rotation' else 'VEC3'
            require(doc['accessors'][sampler['output']]['type'] == expected, 'animation channel format')
    return intake.inspect(doc)


def verify(manifest_path):
    manifest_path = Path(manifest_path).resolve()
    root = manifest_path.parent
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    require(manifest['schema'] == 1 and manifest['license'] == 'CC0-1.0', 'manifest contract')
    require(manifest['status'] == 'SOURCE_INSPECTED_NOT_IMPORTED', 'source evidence status')
    require(len(manifest['archiveSha256']) == 64 and all(c in '0123456789abcdef' for c in manifest['archiveSha256']), 'archive SHA format')
    for name in ('License.txt', 'Atlas_Monsters.png'):
        require(intake.sha((root / 'source' / name).read_bytes()) == manifest[name]['sha256'], 'support file SHA')
    require(b'CC0' in (root / 'source/License.txt').read_bytes(), 'license text')
    require(len(manifest['assets']) == 2, 'bounded asset pair')
    seen = set()
    for asset in manifest['assets']:
        identity = asset['id']
        require(identity in intake.JOBS and identity not in seen, 'encounter identity')
        seen.add(identity)
        require(asset['sourceName'] == intake.JOBS[identity], 'source family')
        require(asset['runtimeAssetId'] is None and asset['studioImported'] is False, 'unbound runtime evidence')
        require(asset['role'] == ('Boss' if identity == 'forest_captain' else 'Melee'), 'preserved encounter role')
        path = (root / asset['sourceFile']).resolve()
        require(path.is_relative_to(root / 'source'), 'source path escape')
        raw = path.read_bytes()
        require(intake.sha(raw) == asset['sha256'], 'source SHA mismatch')
        measured = validate_document(json.loads(raw))
        for key, value in measured.items():
            require(asset[key] == value, 'source metric mismatch: ' + key)
        require(len(measured['clips']) == 14, 'clip count')
        durations = {c['name']: c['seconds'] for c in measured['clips']}
        for clip, expected in {'Idle': 1, 'Walk': 1, 'Run': 17/30, 'Weapon': 26/30, 'Punch': 26/30, 'HitReact': .6, 'Death': 23/30}.items():
            require(abs(durations[clip] - expected) < 1e-6, 'clip duration: ' + clip)
    return {'status': 'SOURCE_VERIFIED_NOT_IMPORTED', 'assets': sorted(seen)}


def fixture():
    doc = {'asset': {'version': '2.0'}, 'nodes': [{} for _ in range(43)], 'skins': [{'joints': list(range(43))}], 'buffers': [], 'bufferViews': [], 'accessors': [], 'meshes': [], 'animations': []}
    def add(rows, kind, component=5126):
        raw = b''.join(struct.pack('<' + intake.TYPES[component] * len(row), *row) for row in rows)
        index = len(doc['accessors'])
        doc['buffers'].append({'uri': 'data:application/octet-stream;base64,' + base64.b64encode(raw).decode(), 'byteLength': len(raw)})
        doc['bufferViews'].append({'buffer': index, 'byteLength': len(raw)})
        doc['accessors'].append({'bufferView': index, 'componentType': component, 'count': len(rows), 'type': kind})
        return index
    p = add([[0, 0, 0], [1, 0, 0], [0, 1, 0]], 'VEC3')
    j = add([[0, 1, 2, 3]] * 3, 'VEC4', 5123)
    w = add([[1, 0, 0, 0]] * 3, 'VEC4')
    i = add([[0], [1], [2]], 'SCALAR', 5123)
    t = add([[0], [1]], 'SCALAR')
    o = add([[0, 0, 0], [1, 0, 0]], 'VEC3')
    doc['meshes'] = [{'primitives': [{'attributes': {'POSITION': p, 'JOINTS_0': j, 'WEIGHTS_0': w}, 'indices': i}]}]
    doc['animations'] = [{'name': 'Idle', 'samplers': [{'input': t, 'output': o}], 'channels': [{'sampler': 0, 'target': {'node': 0, 'path': 'translation'}}]}]
    return doc


def self_test():
    valid = fixture()
    require(validate_document(valid)['triangles'] == 1, 'valid fixture rejected')
    def set_value(doc, accessor_index, values, component):
        raw = struct.pack('<' + intake.TYPES[component] * len(values), *values)
        doc['buffers'][accessor_index]['uri'] = 'data:application/octet-stream;base64,' + base64.b64encode(raw).decode()
    mutations = [
        ('negative accessor', lambda d: d['meshes'][0]['primitives'][0].update(indices=-1)),
        ('negative offset', lambda d: d['accessors'][0].update(byteOffset=-4)),
        ('negative view', lambda d: d['accessors'][0].update(bufferView=-1)),
        ('overrun', lambda d: d['accessors'][0].update(count=4)),
        ('fractional count', lambda d: d['accessors'][0].update(count=2.5)),
        ('misaligned stride', lambda d: d['bufferViews'][0].update(byteStride=13)),
        ('float indices', lambda d: d['accessors'][3].update(componentType=5126)),
        ('vertex overflow', lambda d: set_value(d, 3, [0, 1, 3], 5123)),
        ('negative weight sums to one', lambda d: set_value(d, 2, [1.5, -.5, 0, 0] * 3, 5126)),
        ('nonfinite weight', lambda d: set_value(d, 2, [math.nan, 0, 0, 0] * 3, 5126)),
        ('attribute count mismatch', lambda d: d['accessors'][2].update(count=2)),
        ('joint overflow', lambda d: set_value(d, 1, [43, 1, 2, 3] * 3, 5123)),
        ('animation count mismatch', lambda d: d['accessors'][5].update(count=1)),
    ]
    for name, mutate in mutations:
        doc = copy.deepcopy(valid)
        mutate(doc)
        try:
            validate_document(doc)
        except (ValueError, AssertionError, KeyError, IndexError, struct.error):
            continue
        raise AssertionError('Malformed source accepted: ' + name)
    return {'selfTest': 'PASS', 'validFixtures': 1, 'rejectedMalformedFixtures': len(mutations)}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, default=intake.OUT / 'intake.json')
    parser.add_argument('--self-test', action='store_true')
    args = parser.parse_args()
    if args.self_test:
        print(json.dumps(self_test()))
    print(json.dumps(verify(args.manifest)))
