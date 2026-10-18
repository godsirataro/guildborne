"""Audit captured native wedges, not just the generator's abstract triangles."""
import json,math,collections
from pathlib import Path
import generate as g
HERE=Path(__file__).resolve().parent
before=json.loads((HERE/'before.json').read_text());after=json.loads((HERE/'after.json').read_text());runtime=json.loads((HERE/'runtime.json').read_text())
a=after['parts'];b=before['parts'];new=[p for p in a if p['name'].startswith('Settlement_GroundUnion_')]
canon=lambda parts:collections.Counter(json.dumps(p,sort_keys=True) for p in parts)
assert canon([p for p in b if p['name'] not in g.NAMES])==canon([p for p in a if p not in new]),'Unrelated source geometry changed'
assert runtime['parts']==a and runtime['streaming'].endswith('Atomic')
assert len(a)==645 and len(new)==82 and sum(p['collision'] for p in a)==61 and sum(p['marker'] for p in a)==15
verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
triangles=[]
for p in new:
 assert p['className']=='WedgePart' and p['anchored'] and not any(p[k] for k in ('collision','query','touch','castShadow'))
 assert min(p['size'])>=.02
 r=p['rotation'];s=p['size'];c=p['position'];world=[[c[i]+sum(r[i*3+j]*s[j]*v[j] for j in range(3)) for i in range(3)] for v in verts]
 assert all(abs(v[1]-.045)<1e-9 or abs(v[1]-.015)<1e-9 for v in world)
 assert all(abs(v[0])<=150 and abs(v[2])<=225 for v in world)
 top=[(v[0],v[2]) for v in world if abs(v[1]-.045)<1e-9];assert len(top)==3
 if g.area(top)<0:top.reverse()
 triangles.append(top)
area=sum(g.area(t) for t in triangles)
overlap=sum(abs(g.area(q)) if len(q:=g.clip(t,u))>=3 else 0 for i,t in enumerate(triangles) for u in triangles[i+1:])
data=json.loads((HERE/'ground-union.json').read_text());poly=data['verticesXZ'];expected=[[poly[j] for j in ids] for ids in data['triangles']]
intersection=sum(abs(g.area(q)) if len(q:=g.clip(t,u))>=3 else 0 for t in triangles for u in expected)
assert overlap<1e-6 and abs(area-g.area(poly))<1e-6 and abs(intersection-area)<1e-6
lane=[(-12,-5),(12,-5),(12,216),(-12,216)]
lanearea=sum(abs(g.area(q)) if len(q:=g.clip(t,lane))>=3 else 0 for t in triangles)
assert abs(lanearea-5304)<1e-6
result=dict(evidence='OFFLINE_CAPTURED_NATIVE_GEOMETRY_NOT_STUDIO',parts=len(a),visible=sum(p['transparency']<1 for p in a),colliders=61,markers=15,wedges=len(new),eightOwnerParts=len(a)*8,nativeTopArea=area,nativePairwiseOverlapArea=overlap,nativeIntersectionWithIntendedArea=intersection,centralLaneCoveredArea=lanearea,topY=.045,bottomY=.015,unchangedOtherParts=len(a)-len(new),studioVisualGate='PENDING')
(HERE/'geometry-report.json').write_bytes((json.dumps(result,indent=2)+'\n').encode());print(json.dumps(result))
