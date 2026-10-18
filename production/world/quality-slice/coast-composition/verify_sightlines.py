"""Independent exported-art/native-ground sight rays; not rendered or Studio proof."""
from pathlib import Path
import hashlib
import json
import math
import numpy as np

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
PACKET = ROOT/'assets/production/world-slice/coast-composition/scenery.mesh.json'
GROUND = ROOT/'production/world/quality-slice/continuous-corridor/ground.json'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    packet = json.loads(PACKET.read_bytes())
    ground = json.loads(GROUND.read_bytes())
    meshes = {m['id']: m for m in packet['meshes']}
    triangles, names = [], []
    for placement in packet['placements']:
        # Center-line targets are inside beacon; exclude only target object.
        if placement['meshId'].startswith('landforms_ruined_beacon'):
            continue
        mesh = meshes[placement['meshId']]
        cf = np.array(placement['cframe'])
        vertices = np.array(mesh['vertices']) * np.array(placement['scale'])
        vertices = vertices @ cf[3:].reshape(3, 3).T + cf[:3]
        faces = vertices[np.array(mesh['triangles']) - 1]
        triangles.extend(faces)
        names.extend([placement['name']] * len(faces))
    # Full solid WedgePart/Part surfaces, not just floor triangles.
    box_vertices = [(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,-.5),(.5,.5,-.5),(.5,.5,.5),(-.5,.5,.5)]
    box_faces = [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]
    wedge_vertices = [(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
    wedge_faces = [(1,2,3,0),(2,5,4,3),(4,5,1,0),(3,4,0),(5,2,1)]
    for index, part in enumerate(ground['parts']):
        wedge = part.get('className') == 'WedgePart'
        vertices = np.array(wedge_vertices if wedge else box_vertices) * part['size']
        vertices = vertices @ np.array(part['rotation']).reshape(3,3).T + part['position']
        for face in wedge_faces if wedge else box_faces:
            for i in range(1,len(face)-1):
                triangles.append(vertices[[face[0],face[i],face[i+1]]])
                names.append('native_ground_'+str(index))
    tri = np.array(triangles)
    origins, edge1, edge2 = tri[:,0], tri[:,1]-tri[:,0], tri[:,2]-tri[:,0]

    def ray(eye, target):
        direction = np.array(target)-eye
        distance = np.linalg.norm(direction)
        direction /= distance
        cross = np.cross(direction, edge2)
        det = np.einsum('ij,ij->i',edge1,cross)
        valid = abs(det)>1e-8
        inverse = np.zeros_like(det)
        inverse[valid] = 1/det[valid]
        delta = eye-origins
        u = inverse*np.einsum('ij,ij->i',delta,cross)
        q = np.cross(delta,edge1)
        v = inverse*(q@direction)
        t = inverse*np.einsum('ij,ij->i',edge2,q)
        hits = np.where(valid & (u>=0) & (v>=0) & (u+v<=1) & (t>.001) & (t<distance-.01))[0]
        if not len(hits):
            return None
        index = hits[np.argmin(t[hits])]
        return dict(object=names[index],distance=float(t[index]))

    def sample(distance):
        for a,b in zip(ground['walkCenterline'],ground['walkCenterline'][1:]):
            length = math.hypot(b[0]-a[0],b[2]-a[2])
            if distance <= length:
                return np.array(a)+(np.array(b)-a)*distance/length, np.array([b[0]-a[0],b[2]-a[2]])/length
            distance -= length
        raise ValueError('Distance outside path')

    results = []
    for distance in (750,800,850,900,950,1000,1050,1100):
        eye,tangent = sample(distance)
        eye[1] += 6
        horizontal = np.array([-565,460])-eye[[0,2]]
        angle = math.degrees(math.acos(np.dot(horizontal,tangent)/np.linalg.norm(horizontal)))
        targets = [dict(target=[-565,y,460],blocker=ray(eye,[-565,y,460])) for y in (35,65,100)]
        results.append(dict(routeDistance=distance,eye=eye.tolist(),angleFromForwardDegrees=angle,targets=targets))
    report = dict(status='OFFLINE_RAY_TEST_NOT_STUDIO',packetSha256=digest(PACKET),groundSha256=digest(GROUND),
                  scriptSha256=digest(Path(__file__)),triangleCount=len(triangles),samples=results,
                  allRaysClear=all(t['blocker'] is None for s in results for t in s['targets']),
                  limitations='Two-sided exact exported geometry rays; target beacon excluded. Clear line of sight does not prove forward camera framing or visual prominence. No unsupplied game geometry included.')
    (HERE/'sightlines.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
