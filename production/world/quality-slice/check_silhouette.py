"""Bounded independent-of-recipe checks against git 9909de1. No Studio proof."""
from pathlib import Path
import hashlib,json,math,subprocess,runpy
import numpy as np
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
OUT=ROOT/'assets/production/world-slice'
CAMERAS=[(105,94,1545),(75,32,1530)]
ANCHORS=[(0,4,1505),(0,4,1495),(0,7,1517),(-35,4,1455),(35,4,1455),
         (-60,4,1410),(60,4,1410),(0,4,1410),(0,8,1330)]
CIRCLES=[(0,1410,53),(0,1330,42),(-60,1410,32),(60,1410,32)]

def baseline(path):return json.loads(subprocess.check_output(['git','show','9909de1:'+path],cwd=ROOT))
def world(p,m):
    v=np.asarray(m['vertices'],dtype=float);f=p['cframe']
    return v@np.asarray(f[3:]).reshape(3,3).T+np.asarray(f[:3])
def aabb(v):return [float(v[:,i].min()) for i in range(3)],[float(v[:,i].max()) for i in range(3)]
def main():
    raw=(OUT/'world-slice.mesh.json').read_bytes();data=json.loads(raw)
    old=baseline('assets/production/world-slice/world-slice.mesh.json')
    collision=json.loads((OUT/'collision.json').read_bytes())
    prior=baseline('assets/production/world-slice/collision.json')
    errors=[]
    def check(value,label):
        if not value:errors.append(label)
    meshes={m['id']:m for m in data['meshes']};placements={p['name']:p for p in data['placements']}
    for m in old['meshes']:
        # The next arrival wave audits these two replacements against 3b5e161.
        if m['id'] not in {'terrain_arrival_west__000','terrain_arrival_east__000','terrain_forest_west__000','terrain_forest_east__000','arch__000','arch__001'}:
            check(meshes.get(m['id'])==m,'Changed mesh '+m['id'])
    for p in old['placements']:check(placements.get(p['name'])==p,'Changed placement '+p['name'])
    check(collision['colliders']==prior['colliders'] and len(collision['colliders'])==413,'Colliders changed')
    check(collision['sourceMeshSha256']==hashlib.sha256(raw).hexdigest(),'Source hash mismatch')
    oldids={m['id'] for m in old['meshes']};oldnames={p['name'] for p in old['placements']}
    expected={'silhouette_rooted_cliff__000','silhouette_fern_rocks__000','silhouette_ruined_waymarker__000'}
    check({i for i in set(meshes)-oldids if not i.startswith('arrival_')}==expected,'Unexpected added resources')
    added=[p for p in data['placements'] if p['name'] not in oldnames and not p['meshId'].startswith('arrival_')]
    check(len(added)==7,'Expected seven placements')
    terrain=runpy.run_path(str(HERE/'check_terrain_composition.py'))
    roads=list(terrain['ROADS'].values())
    buildings=[]
    for p in old['placements']:
        if p['meshId'].split('__')[0] in ('house','stable','sawmill'):
            lo,hi=aabb(world(p,meshes[p['meshId']]))
            buildings.append((lo[0]-2,hi[0]+2,lo[2]-2,hi[2]+2))
    alltri=[];rows=[];total=0
    # Separate main cliff, landing underside and stable-apron underside volumes.
    volumes=[(-118,118,-35,1.90,1292,1508),(-14,14,-15,1.90,1500,1526),(-62,-18,-13,1.8,1500,1520)]
    for p in added:
        check(p['meshId'] in expected,'Unexpected added placement resource')
        check(p['scale']==[1,1,1],'Scaled addition')
        m=meshes[p['meshId']];v=world(p,m);tri=v[np.asarray(m['triangles'])-1]
        lo,hi=aabb(v);total+=len(tri);alltri.extend(tri)
        check(np.isfinite(v).all(),'Nonfinite coordinates')
        normal=np.cross(tri[:,1]-tri[:,0],tri[:,2]-tri[:,0])
        check(bool((np.linalg.norm(normal,axis=1)>1e-8).all()),'Degenerate addition')
        if p['meshId']=='silhouette_rooted_cliff__000':
            # Classify connected components, not individual overlapping face
            # bounds: main-cliff south faces can lie inside an apron envelope.
            parents=list(range(len(v)))
            def find(i):
                while parents[i]!=i:i=parents[i]
                return i
            for face in m['triangles']:
                ids=[j-1 for j in face]
                for j in ids[1:]:parents[find(j)]=find(ids[0])
            components={}
            for j in range(len(v)):components.setdefault(find(j),[]).append(j)
            origins={};cap_radius={}
            for root,ids in components.items():
                points=v[ids]
                matches=[k for k,box in enumerate(volumes) if all(box[0]-1e-4<=x<=box[1]+1e-4 and box[2]-1e-4<=y<=box[3]+1e-4 and box[4]-1e-4<=z<=box[5]+1e-4 for x,y,z in points)]
                check(len(matches)==1,'Ambiguous foundation component')
                origins[root]=[(0,1400),(0,1513),(-40,1510)][matches[0]] if matches else (0,1400)
                cap_radius[root]=.1*min(float(np.ptp(points[:,0])),float(np.ptp(points[:,2])))
            for i,t in enumerate(tri):
                supported=any(all(box[0]-1e-4<=x<=box[1]+1e-4 and box[2]-1e-4<=y<=box[3]+1e-4 and box[4]-1e-4<=z<=box[5]+1e-4 for x,y,z in t) for box in volumes)
                check(supported,'Cliff volume '+str(i))
                # Nonvertical caps must face down; rising outward walls face away
                # from the appropriate foundation center (separate subbases).
                component=find(m['triangles'][i][0]-1)
                center=t.mean(axis=0);cx,cz=origins[component]
                radial=normal[i,0]*(center[0]-cx)+normal[i,2]*(center[2]-cz)
                # Bottom fans alone contain an interior-XZ center vertex;
                # wall rings stay on the perimeter. Never waive wall winding
                # just because an inward normal also points downward.
                cap=any(math.hypot(x-cx,z-cz)<cap_radius[component] for x,y,z in t)
                check(normal[i,1]<0 if cap else radial>0,'Inward cliff face '+str(i))
            check(hi[1]<=1.9001,'Cliff above ground')
        else:
            check(abs(lo[1]-2)<1e-4 and hi[1]<=10,'Unsupported prop height')
            check(lo[0]>=-110 and hi[0]<=110 and lo[2]>=1300 and hi[2]<=1500,'Prop outside island')
            for box in roads+buildings:
                overlap=min(hi[0],box[1])-max(lo[0],box[0])>1e-5 and min(hi[2],box[3])-max(lo[2],box[2])>1e-5
                check(not overlap,'Prop exclusion '+p['name'])
            for x,z,r in CIRCLES:
                distance=math.hypot(max(lo[0]-x,0,x-hi[0]),max(lo[2]-z,0,z-hi[2]))
                check(distance>=r,'Combat envelope '+p['name'])
        rows.append(dict(name=p['name'],worldMin=lo,worldMax=hi,triangles=len(tri)))
    check(total<=6000,'Triangle budget exceeded')
    targets=list(ANCHORS)
    for cx,cz,r in CIRCLES:
        for x in range(math.ceil(cx-r),math.floor(cx+r)+1,5):
            for z in range(math.ceil(cz-r),math.floor(cz+r)+1,5):
                if (x-cx)**2+(z-cz)**2>r*r:continue
                y=6 if -48<=x<=48 and 1305<=z<=1355 else 2+(1380-z)*.16 if -10<=x<=10 and 1355<z<1380 else 2
                targets.append((x,y+.09,z))
    triangles=np.asarray(alltri);a=triangles[:,0];e1=triangles[:,1]-a;e2=triangles[:,2]-a
    visibility=[]
    for eye in CAMERAS:
        s=np.asarray(eye)-a;q=np.cross(s,e1);blocked=[]
        for index,target in enumerate(targets):
            d=np.asarray(target)-eye;h=np.cross(d,e2);det=np.einsum('ij,ij->i',e1,h)
            valid=np.abs(det)>1e-9;inv=np.zeros_like(det);inv[valid]=1/det[valid]
            u=inv*np.einsum('ij,ij->i',s,h);v=inv*(q@d);t=inv*np.einsum('ij,ij->i',e2,q)
            hits=valid&(u>=-1e-8)&(v>=-1e-8)&(u+v<=1+1e-8)&(t>1e-7)&(t<1-1e-7)
            if hits.any():blocked.append(index)
        check(not blocked,'Added geometry occludes samples '+str(eye))
        visibility.append(dict(camera=eye,samples=len(targets),occluded=blocked))
    report=dict(status='OFFLINE_SILHOUETTE_FAIL' if errors else 'OFFLINE_SILHOUETTE_PASS',sourceMeshSha256=hashlib.sha256(raw).hexdigest(),checkerSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),baseline='9909de1',retainedMeshes=27,retainedPlacements=108,retainedColliders=413,addedResources=len(expected),addedPlacements=len(added),addedInstancedTriangles=total,foundationVolumes=volumes,placements=rows,visibility=visibility,errors=errors,studioTested=False,limits='Finite added-geometry sightlines only; no all-camera, dynamic telegraph, runtime collision or human art acceptance.')
    (HERE/'silhouette-clearance.json').write_bytes((json.dumps(report,indent=2)+'\n').encode())
    print(json.dumps(report,indent=2))
    return 1 if errors else 0
if __name__=='__main__':raise SystemExit(main())
