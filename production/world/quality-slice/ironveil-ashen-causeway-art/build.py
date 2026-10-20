"""Original endpoint-anchored side trusses; decorative, no navigation changes."""
from pathlib import Path
import importlib.util,json,hashlib
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/ironveil-ashen-causeway-art'
HELPER=ROOT/'production/world/quality-slice/ironveil-ore-yard/build.py'
spec=importlib.util.spec_from_file_location('original_primitives',HELPER)
g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,d):p.write_bytes((json.dumps(d,indent=2)+'\n').encode())
def build():
    g.meshes.clear();g.solids.clear();g.groups.clear()
    # Warm forged iron gives way to cooler charcoal stone toward Ashen.
    g.COLORS[:]=[[.25,.28,.29],[.34,.36,.35],[.48,.39,.25],[.43,.43,.39],
                [.25,.27,.32],[.35,.36,.42],[.52,.48,.36],[.40,.39,.44]]
    contacts=[]
    def contact(a,b,reason):contacts.append(dict(a=a,b=b,reason=reason))
    # Battered plinths are embedded in actual native island blocks, not free-ended piers.
    for label,x in [('ironveil',616),('ashen',904)]:
        color=4 if label=='ironveil' else 6
        v=[]
        for y,hx,hz in [(-3.2,6,7),(1.12,4,5)]:
            v.extend([[x-hx,y,1503-hz],[x+hx,y,1503-hz],[x+hx,y,1503+hz],[x-hx,y,1503+hz]])
        g.solid('abutments',label+'_battered_plinth',v,g.BOXF,color)
        g.box('abutments',label+'_bearing_cap',[x,1.30,1503],[11,.86,14],7 if label=='ironveil' else 8)
        contact(label+'_battered_plinth','native_'+label+'_island','positive-volume embed in source native Island')
        contact(label+'_bearing_cap',label+'_battered_plinth','bearing overlap .25Y')
        contact(label+'_bearing_cap','native_road','cap top1.73 overlaps collider underside1.70 by.03')
    nodes=[616+24*j for j in range(13)]
    for side,z in [('north',1491.5),('south',1520.5)]:
        # Separate colored ends, fully buried inside the wider central post.
        for section,a,b,col in [('iron',615.7,759.9,1),('ashen',760.1,904.3,5)]:
            for name,y,depth in [('lower',.9,.9),('upper',7.3,.8)]:
                n=f'{side}_{section}_{name}'
                g.box('chords',n,[(a+b)/2,y,z],[b-a,depth,.8],col)
                if section=='ashen':contact(n,f'{side}_post_6','separated end embedded in central post')
        for j,x in enumerate(nodes):
            n=f'{side}_post_{j}'
            g.box('webs',n,[x,4.1,z],[.85,7.4,1.0] if j==6 else [.65,6.9,.65],1 if j<6 else 5)
            section='iron' if j<=6 else 'ashen'
            contact(n,f'{side}_{section}_lower','vertical bearing in lower chord')
            contact(n,f'{side}_{section}_upper','vertical bearing in upper chord')
            if j<12:
                a=[x,.9 if j%2==0 else 7.3,z]
                b=[x+24,7.3 if j%2==0 else .9,z]
                d=f'{side}_diagonal_{j}'
                g.beam('webs',d,a,b,.48,.55,2 if j<6 else 5)
                contact(d,n,'diagonal endpoint crosses post')
                contact(d,f'{side}_post_{j+1}','diagonal endpoint crosses next post')
            # Restrained joint plates at every third node, not a field of rivets.
            if j%3==0:
                outside=z+(-.42 if side=='north' else .42)
                for k,y in [('lower',.9),('upper',7.3)]:
                    p=f'{side}_plate_{j}_{k}'
                    g.box('plates',p,[x,y,outside],[1.45,1.12,.26],3 if j<6 else 6)
                    contact(p,f'{side}_{section}_{k}','plate overlaps chord outward face .11Z')
    # Crossgirders stay below walking floor and physically join both side trusses.
    for j in range(0,13,2):
        x=nodes[j];n=f'crossgirder_{j}'
        g.box('bearings',n,[x,1.23,1506],[1.5,1,30],2 if j<6 else 5)
        section='iron' if j<=6 else 'ashen'
        for side in ('north','south'):contact(n,f'{side}_{section}_lower','crossgirder/chord positive-volume overlap')
        contact(n,'native_road','top1.73 embeds .03 in existing deck underside')
        if j in (0,12):contact(n,('ironveil' if j==0 else 'ashen')+'_bearing_cap','endpoint bearing cap crossing')
    placements=[]
    for m in g.meshes:
        old=m['id'];m['id']=old.replace('oreyard_','causeway_')
        for s in g.solids:
            if s['meshId']==old:s['meshId']=m['id']
        m['bounds']={k:[fn(v[i] for v in m['vertices']) for i in range(3)] for k,fn in [('min',min),('max',max)]}
        placements.append(dict(name=m['id'],meshId=m['id'],cframe=[0,0,0,1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    # No boundary touch is counted as walking intrusion; tall geometry is strictly outside.
    lane=[(624,886,1493,1517),(596,624,1493,1519),(886,914,1493,1519)]
    for m in g.meshes:
        for x,y,z in m['vertices']:
            assert not (y>=2.1 and any(a<=x<=b and c<=z<=d for a,b,c,d in lane)),(m['id'],x,y,z)
    OUT.mkdir(parents=True,exist_ok=True)
    packet=dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',meshes=g.meshes,placements=placements,runtimeIds=None,runtimeImported=False,compositionOnly=True)
    write(OUT/'scenery.mesh.json',packet);write(OUT/'solids.json',g.solids)
    metrics=dict(resources=len(g.meshes),placements=len(placements),solids=len(g.solids),triangles=sum(len(m['triangles']) for m in g.meshes),triangleCap=3000,placementCap=60)
    assert metrics['triangles']<=3000 and metrics['placements']<=60
    write(OUT/'metrics.json',metrics)
    write(HERE/'design-bounds.json',dict(status='AUTHOR_DESIGN_REQUIRES_INDEPENDENT_CONTACT_VERIFICATION',walkExclusionsXZ=lane,walkFloorY=2.1,roadUndersideY=1.7,underdeckTopY=1.73,sideTrussZ=[1491.5,1520.5],bayNodesX=nodes,upperChordY=7.3,nativeAnchors={'native_ironveil_island':dict(min=[380,-2,1290],max=[620,2,1510]),'native_ashen_island':dict(min=[890,-2,1290],max=[1110,2,1510])},nativeRoad='production/world/quality-slice/ironveil-ashen/runtime-descriptor.json',declaredContacts=contacts,notes=['No middle piers: long side trusses transfer to embedded endpoint abutments.','Crossgirders and caps intersect actual road underside by .03; no coplanar deck surfaces.','Plinths deliberately intersect native islands as bearing embed. All other visual shore intersections require independent review.','No new physics or gameplay railing; actual bridge structural engineering is not simulated.']))
    sources=['src/server/Services/AdventureMapKit.luau','src/shared/Config/City.luau','production/world/quality-slice/ironveil-ashen/ground.json','assets/production/world-slice/coast-prop-ashen-cut/scenery.mesh.json']
    write(OUT/'provenance.json',dict(status='ORIGINAL_FILE_GENERATED_NOT_NATIVE',origin='Original Guildborne endpoint-anchored iron causeway with Ashen charcoal finish. No downloaded assets, textures, fonts or providers.',recipe=Path(__file__).relative_to(ROOT).as_posix(),recipeSha256=sha(Path(__file__)),helper=HELPER.relative_to(ROOT).as_posix(),helperSha256=sha(HELPER),sourceHashes={p:sha(ROOT/p) for p in sources},packetSha256=sha(OUT/'scenery.mesh.json'),runtimeIds=None,downloads=False))
    print(json.dumps(dict(**metrics,packetSha256=sha(OUT/'scenery.mesh.json'))))
if __name__=='__main__':build()
