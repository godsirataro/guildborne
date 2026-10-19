"""Generate data only. Coordinator embeds it; this never activates a route."""
from pathlib import Path
import json, math
HERE=Path(__file__).resolve().parent
d=json.loads((HERE/'descriptor.json').read_text())
g=json.loads((HERE/'ground.json').read_text())
def box(lo,hi):
    return dict(cframe=[(a+b)/2 for a,b in zip(lo,hi)]+[1,0,0,0,1,0,0,0,1],size=[b-a for a,b in zip(lo,hi)])
volumes=[]
for a,b in zip(g['walkCenterline'],g['walkCenterline'][1:]):
    dx,dz=b[0]-a[0],b[2]-a[2];length=math.hypot(dx,dz);ux,uz=dx/length,dz/length
    volumes.append(dict(cframe=[(a[0]+b[0])/2,(a[1]+b[1])/2+5,(a[2]+b[2])/2,uz,0,ux,0,1,0,-ux,0,uz],size=[28,18,length+24]))
parts=[dict(name=p['name'],size=p['size'],cframe=p['position']+p['rotation'],color=p['color'],collision=p['collision']) for p in g['parts']]
spec=dict(id=d['id'],fromZone=d['fromZone'],toZone=d['toZone'],centerline=g['walkCenterline'],colliderCount=sum(p['collision'] for p in parts),parts=parts,volumes=volumes,entries={k:box(v['min'],v['max']) for k,v in d['entryVolumes'].items()},safeRecovery=d['safeRecovery'])
(HERE/'runtime-descriptor.json').write_text(json.dumps(spec,indent=2)+'\n',encoding='utf-8')
print(json.dumps(dict(parts=len(parts),colliders=spec['colliderCount'],nodes=len(spec['centerline']),volumes=len(volumes))))
