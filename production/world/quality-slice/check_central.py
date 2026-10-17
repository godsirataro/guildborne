"""Independent source geometry gate for central surfaces, baseline 9b79d5c.
No author recipe imported. Existing arrivals/architecture/placements stay exact.
"""
from pathlib import Path
import hashlib,json,subprocess,runpy
import numpy as np
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
REVISED={'terrain_forest_west__000','terrain_forest_east__000'}
# Actual AdventureMapKit footprints plus authored 18-stud center road.
EXCLUDED=[(-9,9,1300,1462),(-69,-51,1365,1455),(51,69,1365,1455),
          (-69,69,1441,1459),(-69,69,1366,1384),(-48,48,1305,1355),
          (-10,10,1355,1380),(-41,-29,1449,1461),(29,41,1449,1461)]

def main():
    source=ROOT/'assets/production/world-slice/world-slice.mesh.json';raw=source.read_bytes();data=json.loads(raw)
    def old(path):return json.loads(subprocess.check_output(['git','show','9b79d5c:'+path],cwd=ROOT))
    prior=old('assets/production/world-slice/world-slice.mesh.json')
    collision=json.loads(source.with_name('collision.json').read_bytes());errors=[]
    def check(ok,label):
        if not ok:errors.append(label)
    meshes={m['id']:m for m in data['meshes']};oldmeshes={m['id']:m for m in prior['meshes']}
    check(set(meshes)==set(oldmeshes) and len(data['meshes'])==37,'Changed resource identity/count')
    check(data['placements']==prior['placements'] and len(data['placements'])==116,'Changed placement records')
    for mid,m in oldmeshes.items():
        if mid not in REVISED:check(meshes.get(mid)==m,'Changed prior mesh '+mid)
    check(collision['colliders']==old('assets/production/world-slice/collision.json')['colliders'] and len(collision['colliders'])==413,'Changed colliders')
    check(collision['sourceMeshSha256']==hashlib.sha256(raw).hexdigest(),'Stale collision source')
    clip=runpy.run_path(str(HERE/'check_terrain_composition.py'))['intersection_area']
    overlap=runpy.run_path(str(HERE/'check_arrival.py'))['overlap_area']
    world=runpy.run_path(str(HERE/'check_silhouette.py'))['world']
    alltri=[];rows=[];area=0.
    for p in data['placements']:
        if p['meshId'] not in REVISED:continue
        m=meshes[p['meshId']];v=world(p,m);tri=v[np.asarray(m['triangles'])-1]
        check(bool(np.isfinite(v).all()) and bool((np.abs(v[:,1]-2.02)<1e-6).all()),'Surface height/nonfinite')
        check(len(tri)<=2000,'Per resource triangle budget')
        check(len(m['colors'])<=320,'Per resource palette budget')
        normals=np.cross(tri[:,1]-tri[:,0],tri[:,2]-tri[:,0])
        check(bool((normals[:,1]>1e-8).all()),'Winding/degenerate triangle')
        for i,t in enumerate(tri):
            a=float(normals[i,1]/2);area+=a
            check(abs(clip(t,[-110,110,1300,1462])-a)<1e-6,'Outside native support '+str(i))
            for box in EXCLUDED:check(clip(t,box)<1e-7,'Road/ramp/resource overlap '+str((p['meshId'],i,box)))
        alltri.extend(tri);rows.append(dict(meshId=p['meshId'],triangles=len(tri),vertices=len(v)))
    # Independent exact rectangle-union integration of supported free area.
    xs=sorted({-110,110,*[v for b in EXCLUDED for v in b[:2]]})
    zs=sorted({1300,1462,*[v for b in EXCLUDED for v in b[2:]]});expected=0.
    for a,b in zip(xs,xs[1:]):
        for c,d in zip(zs,zs[1:]):
            x,z=(a+b)/2,(c+d)/2
            if not any(r[0]<x<r[1] and r[2]<z<r[3] for r in EXCLUDED):expected+=(b-a)*(d-c)
    check(abs(area-expected)<1e-5,'Missing/overlapping coverage')
    st=np.asarray(alltri);low=st[:,:,[0,2]].min(axis=1);high=st[:,:,[0,2]].max(axis=1)
    for i,t in enumerate(st):
        candidates=np.nonzero(np.all(np.minimum(high[i],high[i+1:])-np.maximum(low[i],low[i+1:])>1e-8,axis=1))[0]+i+1
        for j in candidates:check(overlap(t,st[j])<1e-6,'Overlapping triangles '+str((i,int(j))))
    check(len(st)<=4000,'Total surface triangle budget')
    report=dict(status='OFFLINE_CENTRAL_FAIL' if errors else 'OFFLINE_CENTRAL_PASS',baseline='9b79d5c',
        sourceMeshSha256=hashlib.sha256(raw).hexdigest(),checkerSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        preservedMeshes=35,preservedPlacements=116,preservedColliders=413,revisedMeshes=rows,
        surfaceTriangles=len(st),surfaceArea=area,expectedArea=expected,exclusions=EXCLUDED,errors=errors,
        studioTested=False,limits='Flat source surfaces only. No new raised geometry; existing sightlines unchanged geometrically. Runtime appearance, telegraph contrast, physics and human art approval not tested.')
    (HERE/'central-clearance.json').write_bytes((json.dumps(report,indent=2)+'\n').encode())
    print(json.dumps(report,indent=2));return 1 if errors else 0

if __name__=='__main__':raise SystemExit(main())
