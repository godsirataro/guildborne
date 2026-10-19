"""Deterministic flat third-corridor source only; no runtime activation."""
from pathlib import Path
import json,hashlib
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
I=[1,0,0,0,1,0,0,0,1]
def write(n,d):(HERE/n).write_bytes((json.dumps(d,indent=2)+'\n').encode())
def main():
    points=[[x,2.1,1505] for x in [610,650,750,850,900]]
    pads={'Ironveil':[[596,1493],[624,1519]],'Ashen':[[886,1493],[914,1519]]}
    entries={z:dict(min=[lo[0],0,lo[1]],max=[hi[0],15,hi[1]]) for z,(lo,hi) in pads.items()}
    d=dict(id='ironveil_ashen_south',fromZone='Ironveil',toZone='Ashen',status='SOURCE_CANDIDATE_NATIVE_ACCEPTANCE_PENDING',groundContainer='GuildborneWorld/IronveilAshenCorridor',width=24,shoulderWidth=24,centerline=points,entryVolumes=entries,safeRecovery={'Ironveil':[600,7,1500],'Ashen':[900,7,1500]},landingPads=pads,seamNotes=['Native island floors endZ1510; explicit solid pads extend to1519. All walking floor top2.1, roadnorth1493 outside combatZ<1490.','Existing Dataset2 bank requires separately reviewed replacement; this geometry export alone is not visual readiness.','No existing portals, regional floors, two prior corridors, travel eligibility or activation changed.'])
    parts=[];tops=[]
    def rect(name,x0,x1,z0,z1):
        parts.append(dict(name=name,className='Part',position=[(x0+x1)/2,1.9,(z0+z1)/2],size=[x1-x0,.4,z1-z0],rotation=I,color=[.48,.47,.43],material='Ground',collision=True,query=True,touch=False,anchored=True,castShadow=False))
        a,b,c,e=[x0,2.1,z0],[x0,2.1,z1],[x1,2.1,z1],[x1,2.1,z0]
        tops.extend([dict(vertices=[a,b,c],collision=True,group=name),dict(vertices=[a,c,e],collision=True,group=name)])
    rect('Landing_Ironveil',596,624,1493,1519)
    for j,(a,b) in enumerate(zip([624,650,750,850],[650,750,850,886])):rect('Road_'+str(j),a,b,1493,1517)
    rect('Landing_Ashen',886,914,1493,1519)
    def box(lo,hi):return dict(cframe=[(a+b)/2 for a,b in zip(lo,hi)]+I,size=[b-a for a,b in zip(lo,hi)])
    volumes=[box([a[0]-14,-1.9,1493],[b[0]+14,16.1,1517]) for a,b in zip(points,points[1:])]
    spec=dict(id=d['id'],fromZone=d['fromZone'],toZone=d['toZone'],centerline=points,colliderCount=len(parts),parts=[dict(name=p['name'],kind=p['className'],size=p['size'],cframe=p['position']+p['rotation'],color=p['color'],collision=p['collision']) for p in parts],volumes=volumes,entries={z:box(v['min'],v['max']) for z,v in entries.items()},safeRecovery=d['safeRecovery'])
    ground=dict(evidence='OFFLINE_SOURCE_GEOMETRY_NOT_STUDIO',parts=parts,topTriangles=tops,walkCenterline=points,crosssections=[dict(center=p,road=[[p[0],2.1,1493],[p[0],2.1,1517]],shoulder=[[p[0],2.1,1493],[p[0],2.1,1517]],shoulderWidth=24) for p in points])
    for n,data in [('descriptor.json',d),('ground.json',ground),('runtime-descriptor.json',spec)]:write(n,data)
    sources=['src/server/Services/AdventureMapKit.luau','src/server/Services/RegionalWorld.luau','src/shared/Config/City.luau','production/world/quality-slice/greenwood-ironveil/runtime-descriptor.json']
    write('source-survey.json',dict(status='SOURCE_ONLY_NOT_NATIVE',sourceHashes={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in sources},floorY=2,nativeFloorBounds={'Ironveil':[380,620,1290,1510],'Ashen':[890,1110,1290,1510]},combatUpperZExclusive=1490,roadMinimumZ=1493,returnPortals=[[500,7,1527],[1000,7,1527]],bankBlocker='Reviewed separately: Dataset2 bank above lane nearX640..745. No claim of route readiness until replacement verified.',oldIronveilEntry=[390,7.5,1495],newIronveilEntry=[610,7.5,1506],minimumEntryXSeparation=194))
    print(json.dumps(dict(parts=len(parts),colliders=len(parts),nodes=len(points),volumes=len(volumes))))
if __name__=='__main__':main()
