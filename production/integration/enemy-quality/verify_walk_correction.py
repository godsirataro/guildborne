"""Independent source-preservation and numerical Walk correction review.

Requires existing NumPy. Run after regenerated exports are complete; writes only
the explicitly requested JSON report. This does not establish Studio/grounding acceptance.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

import numpy as np

ROOT = Path(__file__).resolve().parents[3]
BASE = '967dc71'
ASSETS = Path('assets/production/enemy-slice')


def check(condition, message):
    if not condition:
        raise AssertionError(message)


def original(path):
    return subprocess.check_output(['git', 'show', f'{BASE}:{path.as_posix()}'], cwd=ROOT)


def matrix(values):
    result = np.eye(4)
    result[:3, 3] = values[:3]
    result[:3, :3] = np.array(values[3:]).reshape(3, 3)
    return result


def angle(a, b):
    def rotation(values):
        u, _, v = np.linalg.svd(matrix(values)[:3, :3])
        return u @ v
    return float(np.degrees(np.arccos(np.clip((np.trace(rotation(a) @ rotation(b).T) - 1) / 2, -1, 1))))


def deform(data, frames):
    bones = data['bones']
    inverse = np.linalg.inv(np.array([matrix(b['bind']) for b in bones]))
    local = [matrix(b['localBind']) for b in bones]
    vertices = np.column_stack([data['vertices'], np.ones(len(data['vertices']))])
    indices = np.zeros((len(vertices), 4), dtype=int)
    weights = np.zeros((len(vertices), 4))
    for i, row in enumerate(data['weights']):
        for k, (bone, weight) in enumerate(row):
            indices[i, k] = bone - 1
            weights[i, k] = weight
    poses = []
    for frame in frames:
        globals_ = []
        for i, bone in enumerate(bones):
            parent = globals_[bone['parent'] - 1] if bone['parent'] else np.eye(4)
            globals_.append(parent @ local[i] @ matrix(frame[i]))
        skin = np.array(globals_) @ inverse
        result = np.zeros_like(vertices)
        for k in range(4):
            result += np.einsum('nij,nj->ni', skin[indices[:, k]], vertices) * weights[:, k, None]
        poses.append(result[:, :3])
    return np.array(poses)


def verify():
    manifest = json.loads((ROOT / ASSETS / 'intake.json').read_text())
    hashes = {}
    for path in sorted((ROOT / ASSETS / 'source').iterdir()):
        if path.is_file():
            raw = path.read_bytes()
            check(raw == original(path.relative_to(ROOT)), 'Original source changed: ' + path.name)
            hashes[path.name] = hashlib.sha256(raw).hexdigest()
    reports = []
    for asset in manifest['assets']:
        identity = asset['id']
        folder = ASSETS / 'review' / identity
        path = folder / 'weighted-mesh.json'
        old = json.loads(original(path))
        new = json.loads((ROOT / path).read_text())
        check(asset['sha256'] == hashes[Path(asset['sourceFile']).name] == old['sourceSha256'] == new['sourceSha256'], 'Source hash mismatch')
        for field in ('vertices', 'triangles', 'bones', 'weights', 'cornerUV', 'colors', 'faceColors'):
            check(old[field] == new[field], 'Geometry/bind/material changed: ' + field)
        check(old['clips'].keys() == new['clips'].keys(), 'Clip inventory changed')
        for name in old['clips']:
            if name != 'Walk':
                check(old['clips'][name] == new['clips'][name], 'Unrelated clip changed: ' + name)
        before, after = old['clips']['Walk'], new['clips']['Walk']
        check({k:v for k,v in before.items() if k != 'frames'} == {k:v for k,v in after.items() if k != 'frames'}, 'Walk timing changed')
        check(len(before['frames']) == len(after['frames']) == 31, 'Walk frame count')
        check(new['bones'][24]['name'] == 'LowerArm.R', 'Wrong correction bone')
        changed = []
        for f, (old_frame, new_frame) in enumerate(zip(before['frames'], after['frames'])):
            check(len(old_frame) == len(new_frame), 'Frame bone count changed')
            for bone, (a, b) in enumerate(zip(old_frame, new_frame)):
                if a != b:
                    check(25 <= f <= 30 and bone == 24, f'Unowned pose changed: frame {f}, bone {bone+1}')
                    check(a[:3] == b[:3], 'Forearm translation changed')
                    changed.append(f)
        check(changed and 30 in changed, 'Correction absent')
        old_skin, new_skin = deform(old, before['frames']), deform(new, after['frames'])
        feet = {i + 1 for i,b in enumerate(new['bones']) if 'foot' in b['name'].lower() or 'toe' in b['name'].lower()}
        foot_vertices = [i for i,row in enumerate(new['weights']) if any(b in feet and w > 0 for b,w in row)]
        check(foot_vertices, 'No foot-weighted vertices inspected')
        foot_error = float(np.abs(old_skin[:, foot_vertices] - new_skin[:, foot_vertices]).max())
        check(foot_error == 0, 'Foot trajectory changed')
        seam = angle(after['frames'][0][24], after['frames'][-1][24])
        check(seam < .0001, 'Corrected endpoint rotation is not closed')
        vertex_seam = float(np.linalg.norm(new_skin[-1] - new_skin[0], axis=1).max())
        check(vertex_seam < .0001, 'Corrected geometry endpoint is not closed')
        inspection = json.loads((ROOT / folder / 'inspection.json').read_text())
        bounds_error, samples = 0., 0
        for name, diagnostic in inspection['diagnostics'].items():
            frames = new['clips'][name]['frames']
            checks = diagnostic['evaluatedBoundsBlenderAxes']
            posed = deform(new, [frames[s['frame']] for s in checks])
            for vertices, sample in zip(posed, checks):
                lo, hi = sample['min'], sample['max']
                expected = np.array([[lo[0],lo[2],-hi[1]], [hi[0],hi[2],-lo[1]]])
                actual = np.array([vertices.min(axis=0), vertices.max(axis=0)])
                bounds_error = max(bounds_error, float(np.abs(actual - expected).max()))
                samples += 1
        check(bounds_error < .0001, 'Blender evaluated bounds disagree')
        def steps(clip):
            f = clip['frames']
            return {f'{i}->{i+1}': angle(f[i][24], f[i+1][24]) for i in [0,23,24,25,26,27,28,29]}
        old_steps, new_steps = steps(before), steps(after)
        reports.append({'id': identity, 'changedFrames': changed, 'changedBone': 'LowerArm.R',
            'footVertices': len(foot_vertices), 'maxFootTrajectoryErrorStud': foot_error,
            'oldEndpointRotationDegrees': angle(before['frames'][0][24],before['frames'][-1][24]),
            'newEndpointRotationDegrees': seam, 'newMaxVertexEndpointErrorStud': vertex_seam,
            'oldAngularStepsDegrees': old_steps, 'newAngularStepsDegrees': new_steps,
            'maxFinalSixAngularStepDegrees': max(new_steps[f'{i}->{i+1}'] for i in range(24,30)),
            'firstAngularStepDegrees': new_steps['0->1'],
            'boundaryAngularStepMagnitudeDifferenceDegrees': abs(new_steps['29->30']-new_steps['0->1']),
            'motionReviewRecommendation': 'Endpoint position is closed, but final and first angular step magnitudes differ. Review repeated loops for residual speed change; this numerical pass does not assert tangent continuity or visual acceptance.',
            'oldMinGeometryYStud': float(old_skin[:,:,1].min()), 'newMinGeometryYStud': float(new_skin[:,:,1].min()),
            'blenderBoundsSamples': samples, 'maxBlenderBoundsErrorStud': bounds_error,
            'weightedMeshSha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest()})
    return {'status': 'PASS_NUMERICAL_SOURCE_CORRECTION', 'baselineCommit': BASE,
        'sourceHashes': hashes, 'actors': reports, 'studioTested': False,
        'groundingAccepted': False, 'visualLoopAccepted': False}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    report = verify()
    text = json.dumps(report, indent=2) + '\n'
    if args.output:
        destination = args.output.resolve()
        check(destination.parent == Path(__file__).resolve().parent and destination.suffix == '.json', 'Report must stay in owned directory')
        destination.write_text(text, encoding='utf-8')
    print(text)
