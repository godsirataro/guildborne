"""Read native source literals; never mutate runtime or launch Studio."""
from pathlib import Path
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[4]; HERE=Path(__file__).resolve().parent
SOURCE=ROOT/'src/server/Services/AdventureMapKit.luau'
raw=SOURCE.read_text(); section=raw.split('{id="Ironveil",parts={',1)[1].split('{id="Ashen",parts={',1)[0]
def numbers(v): return [float(x) for x in v.split(',')]
parts=[]
pattern=r'\{name="([^"]+)",size=V\(([^)]+)\),pos=V\(([^)]+)\),color=Color3.fromRGB\(([^)]+)\),collide=(true|false),wedge=(true|false),yaw=([^}]+)\}'
for i,m in enumerate(re.finditer(pattern,section)):
    name,size,pos,color,collide,wedge,yaw=m.groups(); pos=numbers(pos);pos[0]+=500;pos[2]+=1400
    parts.append(dict(name=name,index=i,position=pos,size=numbers(size),color=[v/255 for v in numbers(color)],collision=collide=='true',className='WedgePart' if wedge=='true' else 'Part',yaw=float(yaw)))
assert len(parts)>30
markers=[]
for m in re.finditer(r'\{name="([^"]+)",pos=V\(([^)]+)\),role="([^"]+)"\}',section):
    name,pos,role=m.groups();p=numbers(pos);p[0]+=500;p[2]+=1400;markers.append(dict(name=name,position=p,role=role))
routes=[]
for m in re.finditer(r'\{name="([^"]+)",points=\{(.+?)\}\}',section):
    name,points=m.groups();out=[]
    for point in re.findall(r'V\(([^)]+)\)',points):
        p=numbers(point);p[0]+=500;p[2]+=1400;out.append(p)
    routes.append(dict(name=name,points=out))
sources=['src/server/Services/AdventureMapKit.luau','src/server/Services/RegionalWorld.luau','src/shared/Data/Expansion.luau','src/server/Services/IronveilWorld.luau','src/server/Config/AdventureEnemyProfiles.luau','src/shared/Config/City.luau','production/world/quality-slice/greenwood-ironveil/ground.json','assets/production/world-slice/greenwood-ironveil/scenery.mesh.json']
survey=dict(scope='SOURCE_LITERAL_GEOMETRY_NOT_STUDIO_CAPTURE',baseCommit='ccd40f063b3111d38fde5a18ac70b732b4d102ce',sourceHashes={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in sources},nativeParts=parts,encounterMarkers=markers,nativeRoutes=routes,
    protectedAnchors=[dict(id='stone',position=[460,2,1470],clearRadius=10),dict(id='ore',position=[540,6,1430],clearRadius=10),dict(id='spawn',position=[500,2.5,1515],clearRadius=10),dict(id='returnPortal',position=[500,7,1527],clearRadius=12),dict(id='mineEntrance',position=[500,2.15,1498],clearRadius=10)],
    protectedLane=dict(width=24,points=[[390,2.1,1495],[500,2.1,1495],[500,2,1475],[500,6,1450],[500,6,1420],[500,10,1395],[500,10,1330]],note='Conservative 24-stud visual clearance; actual existing ascent collider is 20 wide. This art package does not widen it.'),
    encounterExclusionRadii=dict(RaiderCamp=30,StoneGuard=24,ShamanCamp=30,QuarryGuardian=32),
    privatePocket=dict(baseY=100,slotHeight=80),
    contextLimits=['Literal public map geometry is complete for Ironveil; dynamic players, heroes, private campaign pockets and activated encounter instances are not captured.','Resource anchors are source-derived; exact generated rock/tree meshes require conservative interaction clearances.','No native docking or actual party acceptance is implied.'])
(HERE/'source-survey.json').write_bytes((json.dumps(survey,indent=2)+'\n').encode())
print('Surveyed native parts',len(parts),'markers',len(markers),'routes',len(routes))
