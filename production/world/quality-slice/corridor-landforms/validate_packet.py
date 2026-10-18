"""Independent triangle-space lane/private checks and locked-input verification."""
from pathlib import Path
import json,math,hashlib,sys,importlib.util
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];OUT=ROOT/'assets/production/world-slice/corridor-landforms'
def cross(a,b,c):return (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
def area(poly):return sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(poly,poly[1:]+poly[:1]))/2
# Sutherland-Hodgman convex clipping; works on degenerate projected vertical faces too.
def clip(poly,window):
 if area(window)<0:window=list(reversed(window))
 for a,b in zip(window,window[1:]+window[:1]):
  if not poly:break
  result=[]
  for p,q in zip(poly,poly[1:]+poly[:1]):
   dp,dq=cross(a,b,p),cross(a,b,q);ip,iq=dp>=-1e-8,dq>=-1e-8
   if ip:result.append(p)
   if ip!=iq:
    t=dp/(dp-dq);result.append((p[0]+t*(q[0]-p[0]),p[1]+t*(q[1]-p[1])))
  poly=result
 return poly
def height(t,p):
 xz=[(v[0],v[2]) for v in t];den=cross(*xz)
 if abs(den)<1e-9:return max(v[1] for v in t)
 u=cross(xz[1],xz[2],p)/den;v=cross(xz[2],xz[0],p)/den
 return u*t[0][1]+v*t[1][1]+(1-u-v)*t[2][1]
def bounds(t):return min(v[0] for v in t),max(v[0] for v in t),min(v[2] for v in t),max(v[2] for v in t)
def intersect(a,b):return a[0]<=b[1]+1e-7 and b[0]<=a[1]+1e-7 and a[2]<=b[3]+1e-7 and b[2]<=a[3]+1e-7
locked=json.loads((HERE/'preserved-inputs.json').read_text())
for p,h in locked['sha256'].items():assert hashlib.sha256((ROOT/p).read_bytes()).hexdigest()==h,p
packet=json.loads((OUT/'scenery.mesh.json').read_text());spec=importlib.util.spec_from_file_location('schema',ROOT/'tools/import_quality_meshes.py');schema=importlib.util.module_from_spec(spec);spec.loader.exec_module(schema);report=schema.validate(packet)
assert report['triangles']<=12000 and report['placements']<=100
meshes={m['id']:m for m in packet['meshes']};assert max(len(m['triangles']) for m in meshes.values())<=2000
old=json.loads((ROOT/'assets/production/world-slice/continuous-corridor/scenery.mesh.json').read_text());oldids={m['id'] for m in old['meshes']}
oldplacements={p['name']:p for p in old['placements'] if p['meshId']!='corridor_original_cliff'}
newplacements={p['name']:p for p in packet['placements']}
assert len(oldplacements)==57
for name,p in oldplacements.items():assert newplacements[name]==p,('Changed retained placement',name)
for m in old['meshes']:
 if m['id']!='corridor_original_cliff':assert meshes[m['id']]==m,('Changed retained mesh',m['id'])
for p in packet['placements']:
 if p['name'] not in oldplacements:
  assert all(p.get(flag) is False for flag in ['collision','query','touch']),('New art physics flags',p['name'])
g=json.loads((ROOT/'production/world/quality-slice/continuous-corridor/ground.json').read_text());floors=[(t['vertices'],bounds(t['vertices']),t['collision']) for t in g['topTriangles']]
violations=[];faces=0;tested=0;max_intrusion=-math.inf
for placement in packet['placements']:
 m=meshes[placement['meshId']];f=placement['cframe'];scale=placement.get('scale',[1,1,1]);vertices=[[f[i]+sum(f[3+i*3+j]*v[j]*scale[j] for j in range(3)) for i in range(3)] for v in m['vertices']]
 for ids in m['triangles']:
  faces+=1;t=[vertices[i-1] for i in ids];bb=bounds(t);poly=[(v[0],v[2]) for v in t]
  u=[t[1][i]-t[0][i] for i in range(3)];v=[t[2][i]-t[0][i] for i in range(3)]
  normal=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
  assert sum(n*n for n in normal)>=1e-12,('Zero area face',placement['name'],ids)
  if intersect(bb,(-180,10000,-72,118)) and clip(poly,[(-179.9999,-71.9999),(10000,-71.9999),(10000,117.9999),(-179.9999,117.9999)]):violations.append([placement['name'],'private',ids])
  for floor,fb,collision in floors:
   if not collision and m['id'] in oldids:continue
   if not intersect(bb,fb):continue
   overlap=clip(poly,[(v[0],v[2]) for v in floor])
   if not overlap:continue
   tested+=1;delta=max(height(t,p)-height(floor,p) for p in overlap);max_intrusion=max(max_intrusion,delta)
   if delta>-.025:violations.append([placement['name'],'road' if collision else 'shoulder',round(delta,6),ids])
assert faces<=50000
result=dict(status='PASS' if not violations else 'FAIL',scope='OFFLINE_TRIANGLE_GEOMETRY_NOT_STUDIO',lockedInputs=len(locked['sha256']),exactRetainedPlacements=57,newArtPhysicsDisabled=True,schema=report,instanceTriangles=faces,intersectionsTested=tested,maxSurfaceDelta=max_intrusion,violations=violations[:40],violationCount=len(violations))
(HERE/'independent-geometry.json').write_bytes((json.dumps(result,indent=2)+'\n').encode());print(json.dumps(result,indent=2));assert not violations
