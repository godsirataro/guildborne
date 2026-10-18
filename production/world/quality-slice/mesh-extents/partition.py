"""Lossless resource partition of the immutable, failed landform export."""
from collections import Counter
from copy import deepcopy
from hashlib import sha256
import json
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
SOURCE = ROOT / 'assets/production/world-slice/corridor-landforms/scenery.mesh.json'
OUT = ROOT / 'assets/production/world-slice/corridor-landforms-bounded'
HERE = Path(__file__).resolve().parent
EXPECTED = 'cb3171b25c6bd52a24e8a1baa6af5c82c42b0c41127f255e6cb918fcf57da136'
LIMIT = 2000
FACE_LIMIT = 2000


def bounds(vertices):
    return {key: [fn(v[a] for v in vertices) for a in range(3)]
            for key, fn in [('min', min), ('max', max)]}


def extent(b):
    return [b['max'][a] - b['min'][a] for a in range(3)]


def validate_extents(packet):
    resources = {}
    for mesh in packet['meshes']:
        actual = bounds(mesh['vertices'])
        assert actual == mesh['bounds'], (mesh['id'], 'declared bounds mismatch')
        size = extent(actual)
        assert max(size) <= LIMIT, (mesh['id'], 'resource extents', size)
        assert len(mesh['triangles']) <= FACE_LIMIT
        resources[mesh['id']] = dict(bounds=actual, extents=size, triangles=len(mesh['triangles']))
    placed = []
    for p in packet['placements']:
        size = [resources[p['meshId']]['extents'][a] * abs(p['scale'][a]) for a in range(3)]
        assert max(size) <= LIMIT, (p['name'], 'scaled placement extents', size)
        placed.append(dict(name=p['name'], meshId=p['meshId'], extents=size))
    return dict(resources=resources, placements=placed, limitStuds=LIMIT,
                nativeLimitStuds=2048, minimumMarginStuds=2048-max(max(x['extents']) for x in resources.values()))


def partition(mesh, scale_limits):
    def vertices(indices):
        return [mesh['vertices'][v-1] for i in indices for v in mesh['triangles'][i]]

    def split(indices):
        size = extent(bounds(vertices(indices)))
        if max(size[a] / scale_limits[a] for a in range(3)) <= 1 and len(indices) <= FACE_LIMIT:
            return [indices]
        assert len(indices) > 1, (mesh['id'], 'individual face exceeds spatial limit')
        axis = max(range(3), key=lambda a: size[a] / scale_limits[a])
        ordered = sorted(indices, key=lambda i: (sum(mesh['vertices'][v-1][axis] for v in mesh['triangles'][i])/3, i))
        middle = len(ordered)//2
        return split(ordered[:middle]) + split(ordered[middle:])

    groups = split(list(range(len(mesh['triangles']))))
    if len(groups) == 1:
        return [deepcopy(mesh)]
    result = []
    for n, indices in enumerate(groups):
        part = deepcopy(mesh)
        part.update(id=mesh['id']+f'__bounded_{n:03d}', vertices=[], triangles=[], faceColors=[])
        remap = {}
        for i in indices:
            face = []
            for v in mesh['triangles'][i]:
                if v not in remap:
                    part['vertices'].append(mesh['vertices'][v-1])
                    remap[v] = len(part['vertices'])
                face.append(remap[v])
            part['triangles'].append(face)
            part['faceColors'].append(mesh['faceColors'][i])
        part['bounds'] = bounds(part['vertices'])
        result.append(part)
    return result


def signature(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def faces(mesh):
    # Vertex order is retained, proving winding as well as exact coordinates/color.
    return Counter(signature([[mesh['vertices'][v-1] for v in face], mesh['colors'][ci-1]])
                   for face, ci in zip(mesh['triangles'], mesh['faceColors']))


def placed_faces(packet):
    meshes = {m['id']: m for m in packet['meshes']}
    counts = Counter()
    for p in packet['placements']:
        attributes = {k: v for k, v in p.items() if k not in ('name', 'meshId')}
        for face, count in faces(meshes[p['meshId']]).items():
            counts[signature([attributes, face])] += count
    return counts


def main():
    raw = SOURCE.read_bytes()
    assert sha256(raw).hexdigest() == EXPECTED
    original = json.loads(raw)
    try:
        validate_extents(original)
    except AssertionError as exc:
        rejection = str(exc)
    else:
        raise AssertionError('Negative control unexpectedly accepted failed packet')
    packet = deepcopy(original)
    packet['meshes'], packet['placements'] = [], []
    mapping = {}
    for mesh in original['meshes']:
        uses = [p for p in original['placements'] if p['meshId'] == mesh['id']]
        scale_limits = [LIMIT / max([1]+[abs(p['scale'][a]) for p in uses]) for a in range(3)]
        parts = partition(mesh, scale_limits)
        mapping[mesh['id']] = parts
        assert sum((faces(p) for p in parts), Counter()) == faces(mesh)
        assert all(p['colors'] == mesh['colors'] for p in parts)
        packet['meshes'].extend(parts)
    for p in original['placements']:
        parts = mapping[p['meshId']]
        for n, mesh in enumerate(parts):
            new = deepcopy(p)
            new['meshId'] = mesh['id']
            if len(parts) > 1:
                new['name'] = p['name']+f'__bounded_{n:03d}'
            packet['placements'].append(new)
    assert placed_faces(packet) == placed_faces(original)
    assert {k:v for k,v in packet.items() if k not in ('meshes','placements')} == {
        k:v for k,v in original.items() if k not in ('meshes','placements')}
    retained = [p for p in original['placements'] if not p['meshId'].startswith('landforms_')]
    assert len(retained) == 57
    assert all(p in packet['placements'] for p in retained)
    for m in original['meshes']:
        if not m['id'].startswith('landforms_') or m['id'] == 'landforms_coastal_water__000':
            assert m in packet['meshes']
    report = validate_extents(packet)
    spec = importlib.util.spec_from_file_location('local_quality_importer', ROOT/'tools/import_quality_meshes.py')
    importer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(importer)
    importer.validate(packet)
    unique = sum(len(m['triangles']) for m in packet['meshes'])
    instanced = sum(placed_faces(packet).values())
    assert unique <= 12000 and instanced <= 50000 and len(packet['placements']) <= 100
    output = (json.dumps(packet, separators=(',', ':'))+'\n').encode('utf-8')
    report.update(status='OFFLINE_PASS_NOT_STUDIO', sourceSha256=EXPECTED,
                  outputSha256=sha256(output).hexdigest(), negativeControl=rejection,
                  exactResourceFaceCounters=True, exactPlacedFaceCounters=True,
                  metadataPreserved=True, retainedSceneryPlacements=57, waterResourceUnchanged=True,
                  localImporterSchemaPassed=True,
                  uniqueTriangles=unique, instanceTriangles=instanced,
                  meshCount=len(packet['meshes']), placementCount=len(packet['placements']),
                  splitResources={k:[p['id'] for p in v] for k,v in mapping.items() if len(v)>1},
                  runtimeIds=None, studioTested=False, humanApproved=False)
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT/'scenery.mesh.json').write_bytes(output)
    provenance = json.loads((SOURCE.parent/'provenance.json').read_text(encoding='utf-8'))
    provenance.update(source=str(SOURCE.relative_to(ROOT)).replace('\\', '/'), sourceSha256=EXPECTED,
                      derivation='Lossless spatial partition of west/east resources; exact coordinates, winding, colors and transforms retained',
                      packetSha256=report['outputSha256'], meshes=len(packet['meshes']), placements=len(packet['placements']),
                      spatialLimitStuds=LIMIT, maxResourceExtent=max(max(x['extents']) for x in report['resources'].values()))
    (OUT/'provenance.json').write_text(json.dumps(provenance, indent=2)+'\n', encoding='utf-8')
    (HERE/'bounds-proof.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k not in ('resources','placements')}, indent=2))


if __name__ == '__main__':
    main()
