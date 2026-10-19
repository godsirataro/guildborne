"""Original additive closed gable caps; preserves existing packets and runtime code."""
from pathlib import Path
import importlib.util,json,hashlib,math
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/blacksmith-roof-closure'
HELPER=ROOT/'production/world/quality-slice/ironveil-ore-yard/build.py'
spec=importlib.util.spec_from_file_location('original_primitives',HELPER)
g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
SLOPE=math.tan(math.radians(20))
UNDER=26+14*SLOPE-.6/math.cos(math.radians(20))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,d):p.write_bytes((json.dumps(d,indent=2)+'\n').encode())
def prism(group,name,x0,x1,yz,color):
    n=len(yz)
    verts=[[x,y,z] for x in (x0,x1) for y,z in yz]
    faces=[tuple(range(n)),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    g.solid(group,name,verts,faces,color)
def build():
    g.meshes.clear();g.solids.clear();g.groups.clear()
    prism('west_cap','west_closed_gable',349.45,350.05,[(20.8,-1028),(20.8,-972),(30.6,-1000)],14)
    # Face-mounted structural trim contacts the cap but remains below roof underside.
    for name,a,b in [('left',[349.36,21.25,-1026],[349.36,29.9,-1000]),
                     ('right',[349.36,29.9,-1000],[349.36,21.25,-974]),
                     ('kingpost',[349.36,21.25,-1000],[349.36,29.9,-1000])]:
        g.beam('west_timber',name,a,b,.24,.32,5)
    g.box('west_timber','tie_beam',[349.36,21.25,-1000],[.24,.34,52],5)
    # Each half is convex. The lower edge penetrates the old east gable by .15Y.
    # Front is recessed .10X behind old front; back extends .15X past old back.
    # Existing front masks lower overlap; exposed surfaces are never coplanar.
    for side in (-1,1):
        z=-1000+side*27
        yz=[(29.45,-1000),(20.7,z),(UNDER-27*SLOPE+.12,z),(UNDER+.12,-1000)]
        prism('east_seam','east_roof_band_'+str(side),389.8,390.35,yz,14)
    placements=[]
    for m in g.meshes:
        old=m['id'];m['id']=old.replace('oreyard_','smith_roof_')
        for s in g.solids:
            if s['meshId']==old:s['meshId']=m['id']
        m['bounds']={k:[fn(v[i] for v in m['vertices']) for i in range(3)] for k,fn in [('min',min),('max',max)]}
        placements.append(dict(name=m['id'],meshId=m['id'],cframe=[0,0,0,1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    OUT.mkdir(parents=True,exist_ok=True)
    packet=dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',meshes=g.meshes,placements=placements,runtimeIds=None,runtimeImported=False,compositionOnly=True)
    write(OUT/'scenery.mesh.json',packet);write(OUT/'solids.json',g.solids)
    metrics=dict(resources=len(g.meshes),placements=len(placements),triangles=sum(len(m['triangles']) for m in g.meshes),solids=len(g.solids),triangleCap=256)
    assert metrics['triangles']<=256
    write(OUT/'metrics.json',metrics)
    write(HERE/'geometry-bounds.json',dict(status='SOURCE_DERIVED_NOT_NATIVE',coordinateSystem='RobloxYUp',roof=dict(underRidgeY=UNDER,slope=SLOPE,verticalThickness=1.2/math.cos(math.radians(20)),xBounds=[346,394],nativeCenterY=26,localHalfWidth=16,halfThickness=.6),west=dict(wallBounds=[[349.5,1,-1028],[350.5,21,-972]],capX=[349.45,350.05],baseY=20.8,apexY=30.6,halfSpan=28,wallVerticalOverlap=.2,trimX=[349.24,349.48]),east=dict(oldGableX=[389.95,390.45],oldApexY=29.6,oldBaseY=20.85,halfSpan=27,newX=[389.8,390.35],oldGableVerticalOverlap=.15,roofVerticalOverlap=.12,frontRecessX=.10,backExtensionX=.15),support='West cap overlaps native wall and both roof OBBs; west trim overlaps cap. East bands overlap old gable and matching roof OBB.',scope='Additive packet only; native door and previous packets unchanged. Closed decorative noncolliding solids, not weather/collision authority.'))
    sources=['src/server/Services/CityKit.luau','src/server/Services/CentralCityWorld.luau','production/world/quality-slice/blacksmith-facade/build.py','assets/production/world-slice/blacksmith-facade/scenery.mesh.json']
    write(OUT/'provenance.json',dict(status='ORIGINAL_FILE_GENERATED_NOT_NATIVE',origin='Original Guildborne closed west gable, timber bracing, and additive east roof seam bands; no external assets/providers.',recipe=Path(__file__).relative_to(ROOT).as_posix(),recipeSha256=sha(Path(__file__)),helper=HELPER.relative_to(ROOT).as_posix(),helperSha256=sha(HELPER),sourceHashes={p:sha(ROOT/p) for p in sources},packetSha256=sha(OUT/'scenery.mesh.json'),runtimeIds=None,downloads=False))
    print(json.dumps(dict(**metrics,packetSha256=sha(OUT/'scenery.mesh.json'))))
if __name__=='__main__':build()
