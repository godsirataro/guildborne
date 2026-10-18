"""Independent packet-level architecture audit; no Studio or Blender execution."""
from pathlib import Path
from collections import Counter
import json, math, hashlib
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
OUT=ROOT/'assets/production/world-slice/bespoke-spire'
RETIRED='landforms_ruined_beacon__000'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def sub(a,b):return [x-y for x,y in zip(a,b)]
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def faces(m):return [[m['vertices'][i-1] for i in f] for f in m['triangles']]
def signature(t):return tuple(tuple(v) for v in t)
def world(x,y,z):
 t=2**-.5
 return [-565+t*(-x+z),y,460+t*(-x-z)]
def hit(origin,direction,tri):
 a,b,c=tri;e1=sub(b,a);e2=sub(c,a);p=cross(direction,e2);d=dot(e1,p)
 if abs(d)<1e-9:return None
 inv=1/d;s=sub(origin,a);u=dot(s,p)*inv
 if u < -1e-8 or u>1+1e-8:return None
 q=cross(s,e1);v=dot(direction,q)*inv
 if v < -1e-8 or u+v>1+1e-8:return None
 distance=dot(e2,q)*inv
 return distance if distance>1e-7 else None
def main():
 sourcepath=ROOT/'assets/production/world-slice/coast-composition/scenery.mesh.json'
 path=OUT/'scenery.mesh.json';source=json.loads(sourcepath.read_text());packet=json.loads(path.read_text())
 old={m['id']:m for m in source['meshes']};new={m['id']:m for m in packet['meshes']}
 assert RETIRED not in new
 assert len(new)==len(packet['meshes'])
 for key,m in old.items():
  if key!=RETIRED:assert new[key]==m,('retained mesh',key)
 previous=[p for p in source['placements'] if p['meshId']!=RETIRED]
 assert all(packet['placements'].count(p)==1 for p in previous)
 assert not any(p['meshId']==RETIRED for p in packet['placements'])
 resources={};allfaces=[];architecture=[]
 for m in packet['meshes']:
  lo=[min(v[i] for v in m['vertices']) for i in range(3)];hi=[max(v[i] for v in m['vertices']) for i in range(3)]
  extent=sub(hi,lo);assert max(extent)<=2000 and len(m['triangles'])<=2000
  assert m['bounds']=={'min':lo,'max':hi}
  resources[m['id']]=extent
  for tri in faces(m):assert dot(cross(sub(tri[1],tri[0]),sub(tri[2],tri[0])),cross(sub(tri[1],tri[0]),sub(tri[2],tri[0])))>1e-12
 for p in packet['placements']:
  assert max(abs(p['scale'][i])*resources[p['meshId']][i] for i in range(3))<=2000
  if p not in previous:assert all(p.get(k) is False for k in ['collision','query','touch'])
  f=p['cframe'];scale=p['scale'];m=new[p['meshId']]
  ff=[[[f[i]+sum(f[3+i*3+j]*v[j]*scale[j] for j in range(3)) for i in range(3)] for v in tri] for tri in faces(m)]
  allfaces+=ff
  if p['meshId'].startswith('bespoke_watch_spire'):architecture+=ff
 unique=sum(len(m['triangles']) for m in new.values());assert unique<=12000 and len(allfaces)<=50000 and len(packet['placements'])<=100
 # Rays cross both opposite facades, in two perpendicular directions.
 probes=[]
 for y in [46,50,57,85,91,98]:
  for axis in ['x','z']:
   a=world(-30,y,0) if axis=='x' else world(0,y,-30)
   b=world(30,y,0) if axis=='x' else world(0,y,30)
   hits=[h for t in architecture if (h:=hit(a,sub(b,a),t)) is not None and h<1]
   assert not hits,('blocked aperture',y,axis,hits)
   probes.append(dict(height=y,axis=axis,hits=len(hits)))
 controls=[]
 for y in [30,70]:
  a=world(0,y,-30);b=world(0,y,30)
  hits=[h for t in architecture if (h:=hit(a,sub(b,a),t)) is not None and h<1]
  assert len(hits)>=4,('solid wall control',y)
  controls.append(dict(height=y,hits=len(hits)))
 sidepath=OUT/'solids.json';side=json.loads(sidepath.read_text());sf=faces(side['mesh'])
 assert Counter(map(signature,sf))==Counter(map(signature,architecture)), 'Sidecar does not match exported geometry'
 coverage=Counter();volumes=[];dots=[]
 for s in side['solids']:
  indices=range(s['firstFace']-1,s['firstFace']-1+s['faceCount']);coverage.update(indices)
  group=[sf[i] for i in indices];verts={tuple(v) for t in group for v in t}
  center=[sum(v[i] for v in verts)/len(verts) for i in range(3)]
  edges=Counter();volume=0
  for a,b,c in group:
   for v,w in [(a,b),(b,c),(c,a)]:edges[(tuple(v),tuple(w))]+=1
   n=cross(sub(b,a),sub(c,a));centroid=[(a[i]+b[i]+c[i])/3 for i in range(3)]
   d=dot(n,sub(centroid,center));assert d>1e-9,('inward or nonconvex solid',s['firstFace'],d)
   dots.append(d);volume+=dot(sub(a,center),cross(sub(b,center),sub(c,center)))/6
  assert all(edges[(b,a)]==n for (a,b),n in edges.items()),('open solid',s['firstFace'])
  assert volume>1e-9;volumes.append(volume)
 assert coverage==Counter(range(len(sf))), 'Missing/overlapping solid ranges'
 terrain=[t for m in source['meshes'] if m['id'].startswith(('landforms_west','coast_headland')) for t in faces(m)]
 grounding=[]
 for x in [-9.9,-5,0,5,9.9]:
  for z in [-9.9,-5,0,5,9.9]:
   p=world(x,-100,z)
   terrain_hits=[v for t in terrain if (v:=hit(p,[0,1,0],t)) is not None]
   base_hits=[v for t in sf[:12] if (v:=hit(p,[0,1,0],t)) is not None]
   assert terrain_hits and len(base_hits)>=2
   ground=max(terrain_hits)-100;low=min(base_hits)-100;high=max(base_hits)-100
   assert low<ground<high,('foundation detached or buried',x,z,low,ground,high)
   grounding.append(dict(x=x,z=z,bottom=low,terrain=ground,top=high))
 supports=[]
 for side_index in range(4):
  r=side_index*math.pi/2
  for x in [-8.8,-7.8,-6.8,6.8,7.8,8.8]:
   for z in [11.8,12.5,13.2]:
    p=world(x*math.cos(r)+z*math.sin(r),-100,-x*math.sin(r)+z*math.cos(r))
    th=[v for t in terrain if (v:=hit(p,[0,1,0],t)) is not None]
    ah=[v for t in architecture if (v:=hit(p,[0,1,0],t)) is not None]
    assert th and ah
    gap=min(ah)-max(th)
    supports.append(dict(kind='outer_buttress',side=side_index,x=x,z=z,gap=gap))
 for solid_index in range(len(side['solids'])-6,len(side['solids']),2):
  s=side['solids'][solid_index];group=sf[s['firstFace']-1:s['firstFace']-1+s['faceCount']]
  verts={tuple(v) for t in group for v in t};cx=sum(v[0] for v in verts)/len(verts);cz=sum(v[2] for v in verts)/len(verts)
  footprint={(cx+.8*(v[0]-cx),cz+.8*(v[2]-cz)) for v in verts}|{(cx,cz)}
  for x,z in footprint:
   p=[x,-100,z];th=[v for t in terrain if (v:=hit(p,[0,1,0],t)) is not None];ah=[v for t in group if (v:=hit(p,[0,1,0],t)) is not None]
   assert th and ah
   supports.append(dict(kind='fallen_stone',solid=solid_index,x=x,z=z,gap=min(ah)-max(th)))
 unsupported=[p for p in supports if p['gap']>0.03]
 result=dict(status='FAIL' if unsupported else 'PASS',scope='OFFLINE_ARCHITECTURE_NOT_STUDIO',packetSha256=digest(path),sourceSha256=digest(sourcepath),sidecarSha256=digest(sidepath),retiredBeaconExplicitlyReplaced=True,exactRetainedCoastMeshes=len(old)-1,exactRetainedCoastPlacements=len(previous),uniqueTriangles=unique,instancedTriangles=len(allfaces),placements=len(packet['placements']),maximumResourceExtent=max(max(v) for v in resources.values()),apertureProbes=probes,solidWallControls=controls,closedSolidReview=dict(status='PASS',solids=len(volumes),independentCentroidNormals=True,edgeClosure=True,sidecarMatchesEveryExportedFace=True,minSignedVolume=min(volumes),minOutwardDot=min(dots)),foundationReview=dict(status='FAIL' if unsupported else 'PASS',primaryFootingSamples=grounding,outerSupports=supports,unsupported=unsupported,scope='25 primary footing plus72 outer buttress and15 fallen-stone terrain rays'),artReview='PENDING_RENDER',humanApproved=False)
 (HERE/'architecture-review.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 print(json.dumps(result,indent=2))
 assert not unsupported, 'Detached architectural supports'
if __name__=='__main__':main()
