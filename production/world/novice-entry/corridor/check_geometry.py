"""Corridor source invariants, not a substitute for real pathfinding or visibility tests."""
import json,math
from pathlib import Path
HERE=Path(__file__).resolve().parent
before=json.loads((HERE/'before.json').read_text())['parts'];after=json.loads((HERE/'after.json').read_text())['parts'];runtime=json.loads((HERE/'runtime.json').read_text())
assert runtime['streaming']=='ModelStreamingMode.Atomic' and runtime['parts']==after
assert len(before)==408 and len(after)<=650
def collision(parts):return [{k:v for k,v in p.items() if k!='transparency'} for p in parts if p['collision']]
assert collision(before)==collision(after),'Original collider contract changed'
assert len(collision(after))==61
assert [p for p in before if p['marker']]==[p for p in after if p['marker']]
assert sum(p['marker'] for p in after)==15
old=[p for p in after if not p['name'].startswith('Corridor_')]
assert len(old)==len(before)
visibility_changes=[]
for a,b in zip(before,old):
 assert {k:v for k,v in a.items() if k!='transparency'}=={k:v for k,v in b.items() if k!='transparency'},('Old geometry changed',a['name'])
 if a['transparency']!=b['transparency']:
  assert b['name'] in ('CoastEdge','TrainingCourt','CaravanCourt','CartBed','CartWheel','CartCrates') and b['transparency']==1,b['name']
  visibility_changes.append(b['name'])
def bounds(p):
 r=p['rotation'];h=[s/2 for s in p['size']];e=[sum(abs(r[i*3+j])*h[j] for j in range(3)) for i in range(3)]
 return [(x-d,x+d) for x,d in zip(p['position'],e)]
def overlap(b,x0,x1,z0,z1):return b[0][1]>x0 and b[0][0]<x1 and b[2][1]>z0 and b[2][0]<z1
def distance(b,x,z):return math.hypot(max(b[0][0]-x,0,x-b[0][1]),max(b[2][0]-z,0,z-b[2][1]))
warnings=[(59,71,93,105,.05),(56,74,-44.5,-35.5,.1)]
anchors=[(-65,149),(-79,31),(-87,25),(80,86),(-65,53),(72,-53),(86,-30)]
anchors += [(p['position'][0],p['position'][2]) for p in before if p['marker']]
cart=[bounds(p) for p in before if p['collision'] and p['name'] in ('CartBed','CartWheel','CartCrates')]
exemptions=[]
for p in after:
 b=bounds(p);assert b[0][0]>=-150-1e-5 and b[0][1]<=150+1e-5 and b[2][0]>=-225-1e-5 and b[2][1]<=225+1e-5,('Bounds',p['name'],b)
 if not p['name'].startswith('Corridor_'):continue
 assert p['anchored'] and not p['collision'] and not p['query'] and not p['touch'] and not p['marker']
 for x0,x1,z0,z1,y in warnings:
  assert not overlap(b,x0-6,x1+6,z0-6,z1+6) or b[1][1]<=y-0.005,('Warning coverage',p['name'],b)
 # Decorative replacements entirely inside an unchanged cart collider add no new obstruction.
 contained=any(all(b[i][0]>=c[i][0]-1e-5 and b[i][1]<=c[i][1]+1e-5 for i in range(3)) for c in cart)
 if contained:
  assert 'Cart' in p['name'],p['name'];exemptions.append(p['name']);continue
 if b[1][1]<=.22 or b[1][0]>=7:continue
 assert not overlap(b,-12,12,-200,218),('Main road',p['name'])
 for z in (150,90,25,-40,-105):assert not overlap(b,-82,82,z-9,z+9),('Crosspath',p['name'],z)
 assert distance(b,0,153)>=34,('Courier dodge',p['name'])
 assert distance(b,62.6,94.5)>=24,('Observed training dodge envelope',p['name'])
 for x,z in anchors:assert distance(b,x,z)>=12,('Actor/marker approach',p['name'],x,z)
report={'evidence':'OFFLINE_SOURCE_GEOMETRY_NOT_STUDIO','baselineParts':408,'candidateParts':len(after),'addedParts':len(after)-408,'colliders':61,'unchangedMarkers':15,'originalVisibilityChanges':visibility_changes,'cartContainedDecorations':exemptions,'runtimeParity':True,'streaming':'Atomic','eightOwnerArtParts':len(after)*8,'warningVolumesUnobscured':True,'navigation':'NOT_RUN_ON_THIS_CANDIDATE','performance':'NOT_RUN'}
(HERE/'geometry-check.json').write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps(report))
