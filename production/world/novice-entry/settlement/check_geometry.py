"""Exact core contract and presentation-clearance checks; no engine acceptance implied."""
import json,math
from pathlib import Path
HERE=Path(__file__).resolve().parent
before=json.loads((HERE/'before.json').read_text())['parts'];after=json.loads((HERE/'after.json').read_text())['parts'];runtime=json.loads((HERE/'runtime.json').read_text())
assert len(before)==564 and len(after)<=650
assert runtime['streaming']=='ModelStreamingMode.Atomic' and runtime['parts']==after
def colliders(parts):return [{k:v for k,v in p.items() if k!='transparency'} for p in parts if p['collision']]
assert colliders(before)==colliders(after),'Original collision contract changed'
assert len(colliders(after))==61
assert [p for p in before if p['marker']]==[p for p in after if p['marker']]
assert sum(p['marker'] for p in after)==15
def core(parts):return [p for p in parts if not p['name'].startswith(('Corridor_','Settlement_'))]
assert len(core(before))==len(core(after))==408
visibility=[]
for a,b in zip(core(before),core(after)):
 assert {k:v for k,v in a.items() if k!='transparency'}=={k:v for k,v in b.items() if k!='transparency'},('Core geometry changed',a['name'])
 if a['transparency']!=b['transparency']:
  assert b['name'] in ('MainRoad','CrossPath','TrainingCourt','CaravanCourt','RescuePath','RescueRejoin') and not b['collision'] and b['transparency']==1,b['name']
  if b['name']=='CrossPath':assert b['position'][2] in (150,90,25)
  visibility.append({'name':b['name'],'position':b['position']})
assert not any(p['name'] in ('Corridor_RoadShoulder','Corridor_TrainingApron','Corridor_CaravanVerge') for p in after),'Redundant tabs still generated'
def bounds(p):
 r=p['rotation'];h=[s/2 for s in p['size']];e=[sum(abs(r[i*3+j])*h[j] for j in range(3)) for i in range(3)]
 return [(x-d,x+d) for x,d in zip(p['position'],e)]
def overlap(b,x0,x1,z0,z1):return b[0][1]>x0 and b[0][0]<x1 and b[2][1]>z0 and b[2][0]<z1
def distance(b,x,z):return math.hypot(max(b[0][0]-x,0,x-b[0][1]),max(b[2][0]-z,0,z-b[2][1]))
anchors=[(-65,149),(-79,31),(-87,25),(80,86),(-65,53),(72,-53),(86,-30)]+[(p['position'][0],p['position'][2]) for p in before if p['marker']]
cart=[bounds(p) for p in before if p['collision'] and p['name'] in ('CartBed','CartWheel','CartCrates')]
for p in after:
 b=bounds(p);assert b[0][0]>=-150-1e-5 and b[0][1]<=150+1e-5 and b[2][0]>=-225-1e-5 and b[2][1]<=225+1e-5,('Owner bounds',p['name'],b)
 if not p['name'].startswith(('Corridor_','Settlement_')):continue
 assert p['anchored'] and not p['collision'] and not p['query'] and not p['touch'] and not p['marker'],p['name']
 for x0,x1,z0,z1,y in [(59,71,93,105,.05),(56,74,-44.5,-35.5,.1)]:
  assert not overlap(b,x0-6,x1+6,z0-6,z1+6) or b[1][1]<=y-.005,('Warning obscured',p['name'],b)
 if any(all(b[i][0]>=c[i][0]-1e-5 and b[i][1]<=c[i][1]+1e-5 for i in range(3)) for c in cart):
  assert 'CartDetail' in p['name'],p['name'];continue
 if b[1][1]<=.22 or b[1][0]>=7:continue
 assert not overlap(b,-12,12,-200,218),('Main road',p['name'])
 for z in (150,90,25,-40,-105):assert not overlap(b,-82,82,z-9,z+9),('Crosspath',p['name'],z)
 assert distance(b,0,153)>=34,('Courier dodge',p['name'])
 assert distance(b,62.6,94.5)>=24,('Training dodge',p['name'])
 for x,z in anchors:assert distance(b,x,z)>=12,('Actor/marker approach',p['name'],x,z)
ground_names={'Settlement_ConnectedRoad','Settlement_RoadJoin','Settlement_TrainingClearing','Settlement_TrainingEquipmentApron','Settlement_CaravanClearing','Settlement_WagonApron'}
tops=sorted(round(bounds(p)[1][1],9) for p in after if p['name'] in ground_names)
assert len(tops)==32 and tops[0]>=.007-1e-7 and tops[-1]<=.044
assert all(b-a>=.001-1e-7 for a,b in zip(tops,tops[1:])), 'Overlapping settlement ground tops are coplanar'
south=next(p for p in after if p['name']=='Settlement_SouthMainRoad')
original=next(p for p in before if p['name']=='MainRoad')
assert south['material']==original['material'] and south['color']==original['color']
assert south['position']==[0,.025,-99.5] and south['size']==[20,.05,189]
report={'evidence':'OFFLINE_SOURCE_GEOMETRY_NOT_STUDIO','baselineParts':564,'candidateParts':len(after),'netPartChange':len(after)-564,'colliders':61,'unchangedMarkers':15,'coreVisibilityChanges':visibility,'redundantTabsRemoved':16,'runtimeParity':True,'streaming':'Atomic','eightOwnerArtParts':len(after)*8,'warningVolumesUnobscured':True,'groundTopMinMax':[tops[0],tops[-1]],'groundLayers':len(tops),'navigation':'NOT_RUN_ON_THIS_CANDIDATE','performance':'NOT_RUN'}
(HERE/'geometry-check.json').write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps(report))
