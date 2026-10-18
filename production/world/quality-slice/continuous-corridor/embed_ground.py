"""Embed reviewed corridor native geometry; does not activate it."""
from pathlib import Path
import json,math
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
g=json.loads((HERE/'ground.json').read_text());d=json.loads((HERE/'descriptor.json').read_text())
def box(lo,hi):return dict(cframe=[(a+b)/2 for a,b in zip(lo,hi)]+[1,0,0,0,1,0,0,0,1],size=[b-a for a,b in zip(lo,hi)])
volumes=[]
line=g['walkCenterline']
for a,b in zip(line,line[1:]):
 dx,dz=b[0]-a[0],b[2]-a[2];l=math.hypot(dx,dz);ux,uz=dx/l,dz/l
 volumes.append(dict(cframe=[(a[0]+b[0])/2,(a[1]+b[1])/2+5,(a[2]+b[2])/2,uz,0,ux,0,1,0,-ux,0,uz],size=[28,18+abs(b[1]-a[1]),l+24]))
# Extend the final occupancy box over the existing legal landing/street for35stud entry overlap.
volumes[-1]=box([-14,-2,1493],[14,16,1562])
parts=[dict(name=p['name'],size=p['size'],cframe=p['position']+p['rotation'],color=p['color'],collision=p['collision']) for p in g['parts']]
spec=dict(id=d['id'],fromZone='City',toZone='Greenwood',centerline=line,colliderCount=sum(p['collision'] for p in parts),parts=parts,volumes=volumes,entries={k:box(v['min'],v['max']) for k,v in d['entryVolumes'].items()})
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x) for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(lua(x) for x in v)+'}'
 if isinstance(v,str):return json.dumps(v)
 if isinstance(v,bool):return 'true' if v else 'false'
 return format(v,'.15g')
p=ROOT/'src/shared/Config/WorldQuality.luau';s=p.read_text(encoding='utf8');marker='-- BEGIN GENERATED CONTINUOUS CORRIDOR'
if marker in s:s=s[:s.index(marker)]+s[s.index('-- END GENERATED CONTINUOUS CORRIDOR')+len('-- END GENERATED CONTINUOUS CORRIDOR\n'):]
s=s.replace('return table.freeze(Quality)',marker+'\nQuality.ContinuousCorridor='+lua(spec)+'\n-- END GENERATED CONTINUOUS CORRIDOR\nreturn table.freeze(Quality)');p.write_bytes(s.encode());(HERE/'runtime-descriptor.json').write_bytes((json.dumps(spec,indent=2)+'\n').encode());print(len(parts),'parts',len(volumes),'bounded volumes')
