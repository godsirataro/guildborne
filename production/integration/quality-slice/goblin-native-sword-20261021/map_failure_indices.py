"""Derived references only. Preserve all original native receipts unchanged."""
from pathlib import Path
import json
import math

root = Path(__file__).resolve().parent
source = Path('C:/Work/MySelf/Guildborne/assets/production/enemy-slice/goblin-equipment/export/r6-authored')
tolerance = 0.00001
references = []
for kit in ('heavy', 'scout', 'ritual'):
    packet = json.loads((root/f'kit-{kit}-failure-detail.json').read_text())
    assert packet['success'] and packet['resetToIdle']
    for frame in packet['frames']:
        for piece in frame['parts']:
            data = json.loads((source/(piece['name']+'.mesh.json')).read_text())
            def matching_indices(position):
                matches = [i for i, p in enumerate(data['positions']) if math.dist(p, position) < tolerance]
                assert matches, (piece['name'], position)
                return matches
            for label, detail in [('minimum', piece['minimumVertex'])] + [('intrusion', x) for x in piece['examples']]:
                faces = []
                for face in detail['incidentTriangles']:
                    matches = [set(matching_indices(p)) for p in face['sourceLimbLocalVertices']]
                    possible = []
                    for index, triangle in enumerate(data['triangles']):
                        ids = triangle['vertices']
                        if any(all(ids[(j+rotation)%3] in matches[j] for j in range(3)) for rotation in range(3)):
                            possible.append(index)
                    assert possible, (piece['name'], face['nativeFaceId'])
                    faces.append(dict(nativeFaceId=face['nativeFaceId'], possibleSourceTriangleIndices0=possible))
                references.append(dict(kit=kit, frame=frame['label'], age=frame.get('age'), forwardDegrees=frame.get('forwardDegrees'), piece=piece['name'], role=label, nativeVertexId=detail['nativeVertexId'], sourceLimbLocal=detail['sourceLimbLocal'], world=detail['world'], possibleSourceVertexIndices0=matching_indices(detail['sourceLimbLocal']), matchingBodies=detail['matchingBodies'], incidentFaces=faces))
output = dict(scope='DERIVED_COORDINATE_REFERENCE_NOT_NATIVE_ID_EQUIVALENCE', toleranceStuds=tolerance, indexing='ZERO_BASED_SOURCE_JSON', ambiguity='All coordinate matches retained; native IDs are not assumed to equal source indices.', references=references)
(root/'failure-source-index-reference.json').write_text(json.dumps(output, indent=2)+'\n')
print(json.dumps(dict(references=len(references), allMatched=True, toleranceStuds=tolerance)))
