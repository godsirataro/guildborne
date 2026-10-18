"""Static geometry invariants only; PathfindingService remains a separate Studio gate."""
import json,math
from pathlib import Path
HERE=Path(__file__).resolve().parent
before=json.loads((HERE/'before.json').read_text())['parts']
after=json.loads((HERE/'after.json').read_text())['parts']
runtime=json.loads((HERE/'runtime.json').read_text())
assert runtime['streaming']=='ModelStreamingMode.Atomic'
assert runtime['parts']==after,'Review/runtime geometry drift'
assert len(after)<=650
def colliders(parts):
 return [{k:v for k,v in p.items() if k not in ('transparency','color')} for p in parts if p['collision']]
assert colliders(before)==colliders(after),'Original collision contract changed'
assert len(colliders(after))==61
assert [p for p in before if p['marker']]==[p for p in after if p['marker']]
assert sum(p['marker'] for p in after)==15
assert [p for p in before if p['stage'] not in ('Landscape','CourierCamp')]==[p for p in after if p['stage'] not in ('Landscape','CourierCamp')]
def bounds(p):
 r=p['rotation'];h=[s/2 for s in p['size']]
 ext=[sum(abs(r[i*3+j])*h[j] for j in range(3)) for i in range(3)]
 return [(x-e,x+e) for x,e in zip(p['position'],ext)]
for p in after:
 b=bounds(p)
 assert b[0][0]>=-150-1e-5 and b[0][1]<=150+1e-5 and b[2][0]>=-225-1e-5 and b[2][1]<=225+1e-5,('Owner bounds',p['name'],b)
 assert p['anchored'] and not p['touch']
 if not p['name'].startswith('Entry_'):continue
 assert not p['collision'] and not p['query'] and not p['marker']
 # Low paving and overhead ornaments cannot obscure avatar travel volumes.
 if b[1][1]<=.25 or b[1][0]>=7:continue
 def overlap(x0,x1,z0,z1):return b[0][1]>x0 and b[0][0]<x1 and b[2][1]>z0 and b[2][0]<z1
 assert not overlap(-9.9,9.9,143,218),('Entry main lane',p['name'])
 assert not overlap(-77,10,147,156),('Courier crosspath',p['name'])
 assert not overlap(-75,-55,145,159),('Courier interaction',p['name'])
 dx=max(b[0][0],0,-b[0][1]);dz=max(b[2][0]-153,0,153-b[2][1])
 # Existing gate towers occupy the outer dodge envelope already; retain that envelope.
 if not p['name'].startswith(('Entry_Tower','Entry_Corner')):
  assert math.hypot(dx,dz)>=34,('Dodge area',p['name'])
report={'evidence':'OFFLINE_GEOMETRY_CHECK_NOT_STUDIO','baselineParts':len(before),'candidateParts':len(after),'addedParts':len(after)-len(before),'colliders':61,'markersUnchanged':15,'otherStagesUnchanged':True,'runtimeGeometryMatches':True,'runtimeStreaming':'Atomic','ownerLocalBounds':[[-150,150],[-225,225]],'maxEightOwnerArtParts':len(after)*8,'navigation':'NOT_RUN; native probe supplied','devicePerformance':'NOT_RUN'}
(HERE/'geometry-check.json').write_bytes((json.dumps(report,indent=2)+'\n').encode())
print(json.dumps(report))
