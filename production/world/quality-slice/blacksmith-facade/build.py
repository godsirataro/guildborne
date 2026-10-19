"""Original Blacksmith-only decorative facade; no shared kit/runtime edits."""
from pathlib import Path
import importlib.util,json,hashlib,math,re
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/blacksmith-facade'
HELPER=ROOT/'production/world/quality-slice/ironveil-ore-yard/build.py'
spec=importlib.util.spec_from_file_location('original_primitives',HELPER);g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
box,beam=g.box,g.beam
def actor_bound():
    source=ROOT/'src/server/Services/CityCharacterKit.luau'
    section=source.read_text().split('{id="smith_borin"',1)[1].split('{id="cartographer_nyra"',1)[0]
    bones={n:(list(map(float,p.split(','))),None if parent=='nil' else parent.strip('"')) for n,p,parent in re.findall(r'\{name="([^"]+)",pos=V\(([^)]+)\),parent=(nil|"[^"]+")\}',section)}
    length=lambda v:math.sqrt(sum(x*x for x in v))
    def chain(n):
        p,parent=bones[n]
        return 0 if parent is None else chain(parent)+length([p[i]-bones[parent][0][i] for i in range(3)])
    records=[]
    for n,size,pos,bone in re.findall(r'\{name="([^"]+)",size=V\(([^)]+)\),pos=V\(([^)]+)\),rotation=.*?bone="([^"]+)"\}',section):
        size=list(map(float,size.split(',')));pos=list(map(float,pos.split(',')))
        bound=chain(bone)+length([pos[i]-bones[bone][0][i] for i in range(3)])+length(size)/2
        records.append(dict(name=n,bone=bone,chain=chain(bone),relativeRadius=bound))
    maximum=max(x['relativeRadius'] for x in records);assert len(records)>30
    paths=['src/server/Services/CityCharacterKit.luau','src/server/Services/FriendlyCityNpcs.luau','src/shared/Presentation/BorinPresentation.luau','src/shared/Presentation/BorinWorkMotion.luau']
    return dict(status='CONSERVATIVE_SOURCE_BOUND_NOT_STUDIO_MEASUREMENT',method='Ancestor segment-length sum + part/bone offset norm + half part diagonal; allows arbitrary joint rotation. Root fallbackY1 is above current grassY0.3.',parts=records,rootMaximumY=1,actorMaximumWorldY=1+maximum,workstationMaximumWorldY=1+2.04+(2.4-.4/2-1.716),skinMinimumY=9.5,margin=9.5-(1+maximum),sourceHashes={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in paths},limitations=['Current native Borin only; future rig or root-motion changes invalidate this bound.','Workstation maximum uses root-welded contactY: STRIKE_HAND.Y + HammerHead bottom minus bind RightHand boneY.','No change to old broad XZ validator: this wave has separately approved 3D wall-skin/footing exceptions.'])
def build():
    # Original stone facing down to grass. All footing stays inside old foundation.
    for row,(y,h) in enumerate(((.66,.72),(1.41,.78))):
        for j in range(10):box('footing',f'north_course{row}_{j}',[351+j*4,y,-971.5],[3.92,h,.55],1+(j+row)%3)
        for z0,z1 in [(-1028.5,-1008.3),(-991.7,-971.9)]:
            count=5;step=(z1-z0)/count
            for j in range(count):box('footing',f'east_course{row}_{z0}_{j}',[390.55,y,z0+(j+.5)*step],[.6,h,step-.06],1+(j+row)%3)
    # End quoins stay outside the central Borin XZ reserve at every height.
    for x in (350.9,389.1):
        for row in range(12):box('pilasters',f'quoin{x}_{row}',[x,2.55+row*1.5,-971.32],[1.6,1.46,.4],1+row%3)
        box('pilasters',f'capital{x}',[x,20.5,-971.32],[1.8,.65,.4],2)
    # Thin upper wall panels; old wall supports them, central original post stays visible.
    for x in (359.6,380.4):
        box('upper_panels',f'plaster{x}',[x,15.2,-971.43],[17,11.4,.18],14)
        for y in (9.75,20.55):box('upper_timber',f'rail{x}_{y}',[x,y,-971.30],[17.4,.45,.4],5)
    for x in (351.3,367.9,372.1,388.7):box('upper_timber',f'upperpost{x}',[x,15.1,-971.30],[.5,10.8,.4],5)
    for a,b in [([351.6,10.1,-971.3],[356.4,19.9,-971.3]),([383.6,19.9,-971.3],[388.4,10.1,-971.3])]:beam('upper_timber','diagonal'+str(a[0]),a,b,.25,.45,6)
    # Shuttered ventilation panels are decorative; no new wall opening or service ID.
    for x in (360.8,379.2):
        box('vents',f'darkvent{x}',[x,15.1,-971.27],[6.8,5.8,.15],15)
        for dx in (-3.4,0,3.4):box('vents',f'ventstile{x}{dx}',[x+dx,15.1,-971.19],[.24,6,.18],5)
        for y in (12.1,18.1):box('vents',f'ventframe{x}{y}',[x,y,-971.19],[7,.24,.18],6)
        for j in range(9):
            y=12.48+j*.65
            for dx in (-1.7,1.7):box('vents',f'louvre{x}{j}{dx}',[x+dx,y,-971.15],[3.14,.34,.10],6 if j%3 else 7)
    # East door surround: never enters16-stud opening or approach.
    for z in (-1009.15,-990.85):
        for row in range(12):box('doorstone',f'jamb{z}_{row}',[390.45,2.55+row*1.5,z],[.9,1.46,1.5],1+row%3)
    box('doorstone','door_crown',[390.45,21.2,-1000],[.9,.7,20],2)
    # Solid original gable infill stays above the old lintel and inside roof silhouette.
    v=[[389.95,20.85,-1027],[389.95,20.85,-973],[389.95,29.6,-1000],[390.45,20.85,-1027],[390.45,20.85,-973],[390.45,29.6,-1000]]
    g.solid('gable','east_gable',v,[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)],14)
    # Gable-facing beams use local axes then map into the east wall plane.
    for i,(a,b) in enumerate([([0,21.6,-1025],[0,29.1,-1000]),([0,29.1,-1000],[0,21.6,-975]),([0,21.6,-1000],[0,29.2,-1000])]):
        # Existing helper's guide produces X-oriented width for a YZ beam.
        a[0]=390.5;b[0]=390.5;beam('gable_timber',f'gablebeam{i}',a,b,.3,.45,5)
    placements=[]
    for m in g.meshes:
        old=m['id'];m['id']=old.replace('oreyard_','smith_facade_')
        for s in g.solids:
            if s['meshId']==old:s['meshId']=m['id']
        m['bounds']={k:[fn(v[i] for v in m['vertices']) for i in range(3)] for k,fn in [('min',min),('max',max)]}
        placements.append(dict(name=m['id'],meshId=m['id'],cframe=[0,0,0,1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    OUT.mkdir(parents=True,exist_ok=True)
    def write(p,d):p.write_bytes((json.dumps(d,indent=2)+'\n').encode())
    packet=dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',meshes=g.meshes,placements=placements,runtimeIds=None,runtimeImported=False,compositionOnly=True)
    write(OUT/'scenery.mesh.json',packet);write(OUT/'solids.json',g.solids);write(HERE/'actor-bound.json',actor_bound())
    sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    write(OUT/'provenance.json',dict(status='ORIGINAL_FILE_GENERATED_NOT_NATIVE',recipe=Path(__file__).relative_to(ROOT).as_posix(),recipeSha256=sha(Path(__file__)),helper=HELPER.relative_to(ROOT).as_posix(),helperSha256=sha(HELPER),packetSha256=sha(OUT/'scenery.mesh.json'),origin='Original Guildborne thin facade facing and shuttered vents; no new third-party assets/textures/fonts/providers.',runtimeIds=None))
    metrics=dict(resources=len(g.meshes),placements=len(placements),triangles=sum(len(m['triangles']) for m in g.meshes),solids=len(g.solids));assert metrics['triangles']<=3000
    write(OUT/'metrics.json',metrics);print(json.dumps(metrics))
if __name__=='__main__':build()
