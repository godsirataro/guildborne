"""Offline arrival geometry and bounded sightline checks against 3b5e161.
No runtime rendering/physics acceptance. Does not import the authoring recipe.
"""
from pathlib import Path
import hashlib,json,subprocess,runpy
import numpy as np
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BASELINE='3b5e161'
REPLACED={'terrain_arrival_west__000','terrain_arrival_east__000'}
SIGN='arrival_charter_sign__000'
SUPPORT=[[-110,110,1462,1500],[-62,-18,1500,1520],[-14,14,1500,1526]]

def overlap_area(a,b):
    """Clip two XZ triangles; upward Y normals mean clockwise XZ winding."""
    polygon=[(float(p[0]),float(p[2])) for p in a]
    def side(p,u,v):return (v[0]-u[0])*(p[1]-u[1])-(v[1]-u[1])*(p[0]-u[0])
    edges=[(float(p[0]),float(p[2])) for p in b]
    for u,v in zip(edges,edges[1:]+edges[:1]):
        if not polygon:return 0.
        output=[];previous=polygon[-1];sp=side(previous,u,v)
        for current in polygon:
            sc=side(current,u,v)
            if (sc<=0)!=(sp<=0):
                t=sp/(sp-sc);output.append(tuple(previous[k]+t*(current[k]-previous[k]) for k in range(2)))
            if sc<=0:output.append(current)
            previous=current;sp=sc
        polygon=output
    return abs(sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(polygon,polygon[1:]+polygon[:1])))/2

def main():
    unit=[(0,0,0),(0,0,1),(1,0,0)]
    assert abs(overlap_area(unit,unit)-.5)<1e-9
    assert overlap_area(unit,[(1,0,0),(0,0,1),(1,0,1)])<1e-9
    assert overlap_area(unit,[(.25,0,0),(.25,0,1),(1.25,0,0)])>.1
    helpers=runpy.run_path(str(HERE/'check_silhouette.py'))
    clip=runpy.run_path(str(HERE/'check_terrain_composition.py'))['intersection_area']
    world=helpers['world'];aabb=helpers['aabb']
    def old(path):return json.loads(subprocess.check_output(['git','show',BASELINE+':'+path],cwd=ROOT))
    raw=(ROOT/'assets/production/world-slice/world-slice.mesh.json').read_bytes()
    data=json.loads(raw);prior=old('assets/production/world-slice/world-slice.mesh.json')
    collision=json.loads((ROOT/'assets/production/world-slice/collision.json').read_bytes())
    errors=[]
    def check(value,label):
        if not value:errors.append(label)
    meshes={m['id']:m for m in data['meshes']};places={p['name']:p for p in data['placements']}
    oldids={m['id'] for m in prior['meshes']};oldnames={p['name'] for p in prior['placements']}
    check(set(meshes)==oldids|{SIGN},'Only one new resource permitted')
    check(len(meshes)==len(data['meshes']),'Duplicate resource IDs')
    check(len(places)==len(data['placements']),'Duplicate placements')
    for m in prior['meshes']:
        if m['id'] not in REPLACED:check(meshes.get(m['id'])==m,'Changed prior mesh '+m['id'])
    for p in prior['placements']:check(places.get(p['name'])==p,'Changed prior placement '+p['name'])
    check(collision['colliders']==old('assets/production/world-slice/collision.json')['colliders'] and len(collision['colliders'])==413,'Changed colliders')
    check(collision['sourceMeshSha256']==hashlib.sha256(raw).hexdigest(),'Stale source hash')
    added=[p for p in data['placements'] if p['name'] not in oldnames]
    check(len(added)==1 and added[0]['meshId']==SIGN,'Expected one new sign placement')
    seen=set();surface_count=0;surface_area=0.;rows=[];signtri=None;surface_triangles=[]
    for p in data['placements']:
        if p['meshId'] not in REPLACED|{SIGN}:continue
        m=meshes[p['meshId']];v=world(p,m);tri=v[np.asarray(m['triangles'])-1]
        lo,hi=aabb(v);normal=np.cross(tri[:,1]-tri[:,0],tri[:,2]-tri[:,0])
        check(bool(np.isfinite(v).all()),'Nonfinite coordinates')
        check(bool((np.linalg.norm(normal,axis=1)>1e-8).all()),'Degenerate faces')
        check(len(tri)<=2000 and p['scale']==[1,1,1],'Per resource budget/scale')
        rows.append(dict(name=p['name'],worldMin=lo,worldMax=hi,triangles=len(tri)))
        if p['meshId'] in REPLACED:
            surface_triangles.extend(tri)
            check(bool((np.abs(v[:,1]-2.02)<1e-6).all()),'Coating height')
            check(bool((normal[:,1]>0).all()),'Coating winding')
            for index,t in enumerate(tri):
                label=p['meshId']+':'+str(index)
                area=float(normal[index,1]/2);covered=sum(clip(t,box) for box in SUPPORT)
                check(abs(area-covered)<1e-6,'Unsupported triangle '+label)
                check(clip(t,[-9,9,1462,1526])<1e-7,'Paved lane overlap '+label)
                key=tuple(sorted(tuple(float(c) for c in point) for point in t))
                check(key not in seen,'Duplicate coating triangle '+label);seen.add(key)
                surface_area+=area;surface_count+=1
        else:
            signtri=tri
            check(len(tri)<=200,'Carved sign triangle budget')
            check(-17<=lo[0]<=hi[0]<=-11 and 1488<=lo[2]<=hi[2]<=1492 and abs(lo[1]-2)<1e-5 and hi[1]<=12,'Sign bounds/support')
            for op in prior['placements']:
                if op['meshId'].split('__')[0] not in ('stable','house','sawmill'):continue
                blo,bhi=aabb(world(op,meshes[op['meshId']]))
                overlap=min(hi[0],bhi[0]+2)>max(lo[0],blo[0]-2) and min(hi[2],bhi[2]+2)>max(lo[2],blo[2]-2)
                check(not overlap,'Building margin '+op['name'])
            check(hi[0]<=-9,'Sign intrudes on road')
    # Exact union area minus the paved lane, with no footprint overlaps in area.
    check(abs(surface_area-(220*38+44*20+28*26-18*64))<1e-4,'Incomplete/overlapping surface coverage')
    check(surface_count<=4000,'Arrival coating triangle budget')
    # Independent pairwise clipping catches partial overlaps, not just identical
    # index/coordinate triples. Bounding boxes cheaply prune unrelated pairs.
    st=np.asarray(surface_triangles);low=st[:,:,[0,2]].min(axis=1);high=st[:,:,[0,2]].max(axis=1)
    for i,t in enumerate(st):
        candidates=np.nonzero(np.all(np.minimum(high[i],high[i+1:])-np.maximum(low[i],low[i+1:])>1e-8,axis=1))[0]+i+1
        for j in candidates:check(overlap_area(t,st[j])<1e-6,'Overlapping coating triangles '+str((i,int(j))))
    targets=list(helpers['ANCHORS'])
    for cx,cz,r in helpers['CIRCLES']:
        import math
        for x in range(math.ceil(cx-r),math.floor(cx+r)+1,5):
            for z in range(math.ceil(cz-r),math.floor(cz+r)+1,5):
                if (x-cx)**2+(z-cz)**2>r*r:continue
                y=6 if -48<=x<=48 and 1305<=z<=1355 else 2+(1380-z)*.16 if -10<=x<=10 and 1355<z<1380 else 2
                targets.append((x,y+.09,z))
    visibility=[]
    if signtri is not None:
        a=signtri[:,0];e1=signtri[:,1]-a;e2=signtri[:,2]-a
        for eye in [(40,12,1510),(105,94,1545)]:
            s=np.asarray(eye)-a;q=np.cross(s,e1);blocked=[]
            for index,target in enumerate(targets):
                d=np.asarray(target)-eye;h=np.cross(d,e2);det=np.einsum('ij,ij->i',e1,h)
                valid=np.abs(det)>1e-9;inv=np.zeros_like(det);inv[valid]=1/det[valid]
                u=inv*np.einsum('ij,ij->i',s,h);v=inv*(q@d);t=inv*np.einsum('ij,ij->i',e2,q)
                if (valid&(u>=-1e-8)&(v>=-1e-8)&(u+v<=1+1e-8)&(t>1e-7)&(t<1-1e-7)).any():blocked.append(index)
            check(not blocked,'Sign occludes sampled route/combat points '+str(eye))
            visibility.append(dict(camera=eye,samples=len(targets),occluded=blocked))
    report=dict(status='OFFLINE_ARRIVAL_FAIL' if errors else 'OFFLINE_ARRIVAL_PASS',baseline=BASELINE,
        sourceMeshSha256=hashlib.sha256(raw).hexdigest(),checkerSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        retainedMeshes=34,retainedPlacements=115,retainedColliders=413,revisedMeshes=sorted(REPLACED),
        addedResources=1,addedPlacements=len(added),surfaceTriangles=surface_count,surfaceArea=surface_area,
        supportFootprints=SUPPORT,placements=rows,visibility=visibility,errors=errors,studioTested=False,
        limits='Source geometry and finite sign sightlines only; no all-camera, dynamic telegraph, runtime collision or human art acceptance.')
    (HERE/'arrival-clearance.json').write_bytes((json.dumps(report,indent=2)+'\n').encode())
    print(json.dumps(report,indent=2));return 1 if errors else 0

if __name__=='__main__':raise SystemExit(main())
