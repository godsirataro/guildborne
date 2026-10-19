"""Original small workshop composition for the two surveyed Borin apron flanks."""
from pathlib import Path
import importlib.util,json,hashlib,math
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/city-smith-apron'
HELPER=ROOT/'production/world/quality-slice/ironveil-ore-yard/build.py'
spec=importlib.util.spec_from_file_location('original_mesh_primitives',HELPER);g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
box,beam,cylinder=g.box,g.beam,g.cylinder
def build():
    # All details stay inside surveyed8x10 flanks. The center remains untouched.
    for x in (350,390):
        for i in range(4):
            for j in range(5):box('pavers',f'paver_{x}_{i}_{j}',[x-2.94+i*1.96,.40,-968+j*1.95],[1.88,.20,1.86],2+(i+j)%2)
    # West: open-sided teal canvas shelter, legible working surface and tools.
    for x in (346.5,353.5):
        for z,y in [(-968.5,8.5),(-959.6,7.5)]:
            box('west_timber',f'post{x}{z}',[x,(y+.5)/2,z],[.42,y-.5,.42],5)
        beam('west_timber',f'rafter{x}',[x,8.5,-968.7],[x,7.5,-959.4],.42,.42,6)
        beam('west_timber',f'brace{x}',[x,5.7,-959.6],[x,7.7,-961.6],.28,.28,5)
    for z,y in [(-968.5,8.5),(-959.6,7.5)]:beam('west_timber',f'header{z}',[346.3,y,z],[353.7,y,z],.42,.4,6)
    # Actual colored triangular cloth solids export to runtime, no texture dependency.
    for i in range(6):
        x0=346.1+i*1.3;x1=x0+1.3
        v=[[x0,8.65,-968.9],[x1,8.65,-968.9],[x1,7.65,-959.1],[x0,7.65,-959.1]]
        v += [[x,y-.12,z] for x,y,z in v]
        g.solid('canvas',f'canvas{i}',v,g.BOXF,13 if i%3 else 14)
        box('canvas',f'valance{i}',[(x0+x1)/2,7.32,-959.13],[1.28,.55,.12],13 if i%3 else 14)
    for x in (347.4,352.6):
        for z in (-967,-964.6):box('workbench',f'leg{x}{z}',[x,1.61,z],[.5,2.5,.5],5)
    for j in range(4):box('workbench',f'plank{j}',[350,2.98,-967.1+j*.8],[6.1,.32,.74],6+j%2)
    for z in (-966.9,-964.8):beam('workbench',f'stretcher{z}',[347.4,1.05,z],[352.6,1.05,z],.35,.35,5)
    beam('workbench','backrack',[347.1,5.1,-968],[352.9,5.1,-968],.30,.35,6)
    for x in (347.2,352.8):box('workbench',f'rackpost{x}',[x,2.95,-968],[.3,4.9,.3],5)
    for i,x in enumerate((348,349.3,350.6,351.9)):
        beam('tools',f'handle{i}',[x,3.6,-967.7],[x,4.9,-967.7],.16,.16,6)
        box('tools',f'hammerhead{i}',[x,4.75,-967.65],[.7,.35,.35],4)
        box('tools',f'hook{i}',[x,5.03,-967.65],[.12,.22,.45],15)
    box('tools','vicebase',[351.4,3.28,-965.6],[1,.3,.7],4)
    for x in (351.05,351.75):box('tools',f'vicejaw{x}',[x,3.63,-965.6],[.18,.5,.65],15)
    beam('tools','vicescrew',[350.65,3.5,-965.6],[352.15,3.5,-965.6],.13,.13,3)
    beam('tools','vicecrank',[352.15,3.15,-965.6],[352.15,3.85,-965.6],.12,.12,3)
    for i in range(3):box('tools',f'ingot{i}',[348.2+i*.65,3.28,-965.4],[.5,.3,1],3)
    # East: stocked outdoor supplies, low enough to frame rather than hide Borin.
    for x in (387,393):box('stock',f'rackleg{x}',[x,2.35,-967.7],[.45,3.9,.45],5)
    for y in (1,2.2,3.4):
        beam('stock',f'stockshelf{y}',[386.6,y,-967.6],[393.4,y,-967.6],.7,.22,6)
        for j in range(5):box('stock',f'billet{y}{j}',[387.3+j*1.3,y+.3,-967.5],[1.05,.38,1.65],3 if y>2 else 6)
    # Small freestanding guild-trade badge; pictogram, not unreadable baked text.
    box('stock','badgepost',[393.3,3.8,-968.3],[.35,6.8,.35],5)
    beam('stock','badgearm',[390.6,6.9,-968.3],[393.5,6.9,-968.3],.3,.3,6)
    for x in (391,392.4):beam('tools',f'badgehanger{x}',[x,6.8,-968.3],[x,6.25,-968.3],.09,.09,15)
    box('stock','badgeboard',[391.7,5.6,-968.3],[2.4,1.35,.22],13)
    beam('tools','badgehammerhandle',[391.3,5.15,-968.12],[391.9,5.95,-968.12],.15,.15,14)
    box('tools','badgehammerhead',[391.95,5.9,-968.1],[.7,.28,.16],12)
    for j,(x,z,r,h) in enumerate([(387.5,-962.8,.85,2.5),(392.2,-962.4,.75,2.15)]):
        cylinder('barrels',f'barrel{j}',[x,.5+h/2,z],r,h,6,12,top=r*.92)
        for y in (.85,.5+h-.35):cylinder('barrels',f'hoop{j}{y}',[x,y,z],r+.045,.13,4,12)
        cylinder('barrels',f'lid{j}',[x,.54+h,z],r*.87,.08,7,12)
    # Original upright wheel: closed convex rim segments, hub and spoke beams.
    cx,cy,cz=390,2.15,-960.6
    for j in range(12):
        a=j*math.tau/12;b=(j+1)*math.tau/12
        beam('wheel',f'rim{j}',[cx+1.5*math.cos(a),cy+1.5*math.sin(a),cz],[cx+1.5*math.cos(b),cy+1.5*math.sin(b),cz],.25,.3,5)
    for j in range(6):
        a=j*math.tau/6;beam('wheel',f'spoke{j}',[cx,cy,cz],[cx+1.4*math.cos(a),cy+1.4*math.sin(a),cz],.15,.16,6)
    box('wheel','hub',[cx,cy,cz],[.5,.5,.6],4)
    box('wheel','wheelchock',[cx,.55,cz],[1,.3,.9],5)
    placements=[]
    for m in g.meshes:
        old=m['id'];m['id']=old.replace('oreyard_','smith_apron_')
        for s in g.solids:
            if s['meshId']==old:s['meshId']=m['id']
        m['bounds']={k:[fn(v[i] for v in m['vertices']) for i in range(3)] for k,fn in [('min',min),('max',max)]}
        placements.append(dict(name=m['id'],meshId=m['id'],cframe=[0,0,0,1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    OUT.mkdir(parents=True,exist_ok=True)
    def write(p,data):p.write_bytes((json.dumps(data,indent=2)+'\n').encode())
    packet=dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',meshes=g.meshes,placements=placements,runtimeIds=None,runtimeImported=False,compositionOnly=True)
    write(OUT/'scenery.mesh.json',packet);write(OUT/'solids.json',g.solids)
    sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    write(OUT/'provenance.json',dict(status='ORIGINAL_FILE_GENERATED_NOT_NATIVE',recipe=Path(__file__).relative_to(ROOT).as_posix(),recipeSha256=sha(Path(__file__)),helper=HELPER.relative_to(ROOT).as_posix(),helperSha256=sha(HELPER),packetSha256=sha(OUT/'scenery.mesh.json'),origin='Original Guildborne workshop geometry; no new third-party asset intake, texture, font or provider.',runtimeIds=None))
    metrics=dict(resources=len(g.meshes),placements=len(placements),triangles=sum(len(m['triangles']) for m in g.meshes),solids=len(g.solids))
    write(OUT/'metrics.json',metrics);print(json.dumps(metrics))
if __name__=='__main__':build()
