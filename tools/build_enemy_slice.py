"""Bounded, byte-preserving CC0 intake. Never executes archive contents."""
from pathlib import Path
import argparse, base64, hashlib, json, math, struct, zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/production/enemy-slice'
JOBS = {'greenwood_scout': 'Tribal', 'forest_captain': 'Monkroose'}
SIZES = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4, 'MAT4': 16}
TYPES = {5121: 'B', 5123: 'H', 5125: 'I', 5126: 'f'}

def sha(data):
    return hashlib.sha256(data).hexdigest()

def accessor(doc, index):
    a = doc['accessors'][index]
    if 'sparse' in a or a.get('normalized'):
        raise ValueError('Unsupported accessor encoding; do not silently alter weights')
    v = doc['bufferViews'][a['bufferView']]
    uri = doc['buffers'][v['buffer']]['uri']
    assert uri.startswith('data:application/octet-stream;base64,')
    buf = base64.b64decode(uri.split(',', 1)[1], validate=True)
    fmt = '<' + TYPES[a['componentType']] * SIZES[a['type']]
    size = struct.calcsize(fmt)
    stride = v.get('byteStride', size)
    start = v.get('byteOffset', 0) + a.get('byteOffset', 0)
    assert 0 < a['count'] <= 100000 and stride >= size
    assert start + (a['count']-1)*stride + size <= v.get('byteOffset', 0)+v['byteLength'] <= len(buf)
    values = [list(struct.unpack_from(fmt, buf, start+i*stride)) for i in range(a['count'])]
    assert all(math.isfinite(n) for row in values for n in row)
    return values

def inspect(doc):
    assert doc['asset']['version'] == '2.0'
    assert len(doc['skins']) == 1 and len(doc['skins'][0]['joints']) == 43
    primitives = []
    for mesh in doc['meshes']:
        for p in mesh['primitives']:
            assert p.get('mode', 4) == 4
            attrs = {k: accessor(doc, v) for k, v in p['attributes'].items()}
            indices = [v[0] for v in accessor(doc, p['indices'])]
            assert len(indices) % 3 == 0 and max(indices) < len(attrs['POSITION'])
            assert all(abs(sum(w)-1) < .001 for w in attrs['WEIGHTS_0'])
            assert all(0 <= j < 43 for row in attrs['JOINTS_0'] for j in row)
            primitives.append({'vertices': len(attrs['POSITION']), 'triangles': len(indices)//3,
                               'maxInfluences': max(sum(w > 0 for w in row) for row in attrs['WEIGHTS_0'])})
    clips = []
    for animation in doc['animations']:
        times = [accessor(doc, s['input']) for s in animation['samplers']]
        for t in times:
            assert all(t[i][0] < t[i+1][0] for i in range(len(t)-1))
        for s in animation['samplers']:
            assert s.get('interpolation', 'LINEAR') in ('LINEAR', 'STEP')
            accessor(doc, s['output'])
        clips.append({'name': animation['name'], 'seconds': max(t[-1][0] for t in times),
                      'channels': len(animation['channels'])})
    return {'primitives': primitives, 'jointCount': 43, 'clips': clips,
            'vertices': sum(p['vertices'] for p in primitives),
            'triangles': sum(p['triangles'] for p in primitives)}

def build(archive):
    archive = Path(archive).resolve()
    assert archive.is_file()
    archive_hash = sha(archive.read_bytes())
    manifest = {'schema': 1, 'source': 'https://quaternius.com/packs/ultimatemonsters.html',
                'license': 'CC0-1.0', 'archiveSha256': archive_hash,
                'licenseNote': 'Archive license header says Ultimate Platformer Pack; pack-specific author page confirms Ultimate Monsters CC0.',
                'status': 'SOURCE_INSPECTED_NOT_IMPORTED', 'assets': []}
    source = OUT/'source'; source.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as z:
        for local, member in [('License.txt', 'Ultimate Monsters/License.txt'),
                              ('Atlas_Monsters.png', 'Ultimate Monsters/Atlas_Monsters.png')]:
            info=z.getinfo(member); assert info.file_size < 1024*1024
            data=z.read(member); (source/local).write_bytes(data)
            manifest[local] = {'sha256': sha(data), 'archiveMember': member}
        assert b'CC0' in (source/'License.txt').read_bytes()
        for identity, name in JOBS.items():
            member=f'Ultimate Monsters/Big/glTF/{name}.gltf'
            assert z.getinfo(member).file_size < 4*1024*1024
            data=z.read(member); doc=json.loads(data)
            # Original exporter embeds the PNG in a bufferView. Never follow URIs.
            for image in doc.get('images', []):
                assert 'uri' not in image and image.get('mimeType') == 'image/png'
                view = doc['bufferViews'][image['bufferView']]
                uri = doc['buffers'][view['buffer']]['uri']
                assert uri.startswith('data:application/octet-stream;base64,')
                buffer = base64.b64decode(uri.split(',', 1)[1], validate=True)
                start = view.get('byteOffset', 0)
                end = start + view['byteLength']
                assert 0 <= start < end <= len(buffer)
                assert buffer[start:end] == (source/'Atlas_Monsters.png').read_bytes()
            metrics=inspect(doc)
            (source/f'{name}.gltf').write_bytes(data)
            manifest['assets'].append({'id': identity, 'sourceName': name,
                'archiveMember': member, 'sha256': sha(data), 'sourceFile': f'source/{name}.gltf',
                'role': 'Melee' if identity=='greenwood_scout' else 'Boss',
                'runtimeAssetId': None, 'studioImported': False, **metrics})
    (OUT/'intake.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({'status': manifest['status'], 'assets': [{k:a[k] for k in ('id','vertices','triangles','jointCount')} for a in manifest['assets']]}))

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('archive');args=parser.parse_args()
    build(args.archive)
