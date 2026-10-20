"""Original native junction wedge floor and island-embedded stone quay facing."""
from pathlib import Path
import json,math,hashlib,importlib.util,sqlite3,time
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/greenwood-east-junction'
HELPER=ROOT/'production/world/quality-slice/ironveil-ore-yard/build.py'
spec=importlib.util.spec_from_file_location('primitives',HELPER);g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
def write(p,d):p.write_bytes((json.dumps(d,indent=2)+'\n').encode())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def lease():
    c=sqlite3.connect('C:/Work/MySelf/Guildborne/build/agentic/four-session-v10.sqlite3');c.row_factory=sqlite3.Row
    r=dict(c.execute('select * from jobs where id=?',('world-quality-slice',)).fetchone());c.close()
    assert r['state']=='ACTIVE' and r['token']=='6f8950ee564744588813f19af4095a0f' and r['expires']>time.time(),'Junction lease absent/expired'
def build():
    lease();g.meshes.clear();g.solids.clear();g.groups.clear()
    sections=[(9,1493,1515),(14,1493,1517),(70,1494,1518)]
    parts=[];tops=[];maxerror=0
    add,sub,mul,dot,cross,unit=g.add,g.sub,g.mul,g.dot,g.cross,g.unit
    length=lambda v:math.sqrt(dot(v,v))
    def emit(t):
        nonlocal maxerror
        if cross(sub(t[1],t[0]),sub(t[2],t[0]))[1]<0:t=[t[0],t[2],t[1]]
        tops.append(dict(vertices=t,collision=True,group='Junction'))
        i=max(range(3),key=lambda k:length(sub(t[(k+1)%3],t[(k+2)%3])))
        a,b,c=t[i],t[(i+1)%3],t[(i+2)%3]
        bc=sub(c,b);f=add(b,mul(bc,dot(sub(a,b),bc)/dot(bc,bc)))
        normal=unit(cross(sub(b,a),sub(c,a)))
        for e in (b,c):
            h=length(sub(a,f));l=length(sub(f,e))
            if l<1e-8:continue
            y=unit(sub(a,f));z=unit(sub(f,e));x=cross(y,z)
            center=sub(mul(add(a,e),.5),mul(normal,.2))
            r=[x[0],y[0],z[0],x[1],y[1],z[1],x[2],y[2],z[2]]
            side=1 if dot(x,normal)>0 else -1
            reconstructed=[add(add(add(center,mul(x,side*.2)),mul(y,yy)),mul(z,zz)) for yy,zz in ((-h/2,-l/2),(-h/2,l/2),(h/2,l/2))]
            maxerror=max(maxerror,max(length(sub(v,w)) for v,w in zip(reconstructed,(e,f,a))))
            parts.append(dict(name=f'Junction_{len(parts):03d}',className='WedgePart',position=center,size=[.4,h,l],rotation=r,color=[.58,.51,.36],collision=True,query=True,touch=False,anchored=True,castShadow=False,material='Ground'))
    for (x0,n0,s0),(x1,n1,s1) in zip(sections,sections[1:]):
        a,b,c,d=[x0,2.1,n0],[x0,2.1,s0],[x1,2.1,s1],[x1,2.1,n1]
        emit([a,b,c]);emit([a,c,d])
    assert maxerror<1e-8
    # Stone courses follow the exact ribbon. Each course embeds in the native island
    # along Z1493..1500, rather than terminating as a fictitious pier in water.
    def section(x):
        if x<=14:return 1493,1515+(x-9)*2/5
        return 1493+(x-14)/56,1517+(x-14)/56
    for i,(x0,x1) in enumerate(zip([9,14,28,42,56],[14,28,42,56,70])):
        n0,s0=section(x0);n1,s1=section(x1)
        # Top follows collision underside and embeds .03Y; exposed south face tapers.
        v=[[x0,-1.1,n0],[x1,-1.1,n1],[x1,-1.1,s1-.7],[x0,-1.1,s0-.7],
           [x0,1.73,n0],[x1,1.73,n1],[x1,1.73,s1],[x0,1.73,s0]]
        g.solid('quay',f'embedded_course_{i}',v,g.BOXF,2 if i%2 else 3)
    placements=[]
    for m in g.meshes:
        old=m['id'];m['id']=old.replace('oreyard_','greenwood_junction_')
        for s in g.solids:
            if s['meshId']==old:s['meshId']=m['id']
        m['bounds']={k:[fn(v[i] for v in m['vertices']) for i in range(3)] for k,fn in [('min',min),('max',max)]}
        placements.append(dict(name=m['id'],meshId=m['id'],cframe=[0,0,0,1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    centerline=[[x,2.1,(n+s)/2] for x,n,s in sections]
    crosssections=[dict(x=x,minZ=n,maxZ=s,width=s-n,center=[x,2.1,(n+s)/2],road=[[x,2.1,n],[x,2.1,s]]) for x,n,s in sections]
    ground=dict(evidence='OFFLINE_SOURCE_NOT_STUDIO',parts=parts,topTriangles=tops,walkCenterline=centerline,crosssections=crosssections)
    runtime=dict(id='greenwood_east_junction',region='Greenwood',centerline=centerline,crosssections=crosssections,minimumWidth=22,fullWidth=24,colliderCount=len(parts),parts=[dict(name=p['name'],kind='WedgePart',size=p['size'],cframe=p['position']+p['rotation'],color=p['color'],collision=True) for p in parts])
    packet=dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',meshes=g.meshes,placements=placements,runtimeIds=None,runtimeImported=False,compositionOnly=True)
    metrics=dict(triangles=sum(len(m['triangles']) for m in g.meshes),resources=len(g.meshes),placements=len(placements),solids=len(g.solids),nativeColliders=len(parts),topTriangles=len(tops),maxWedgeReconstructionError=maxerror)
    assert metrics['triangles']<=1500 and metrics['placements']<=20
    lease();OUT.mkdir(parents=True,exist_ok=True)
    for name,data in [('ground.json',ground),('runtime-descriptor.json',runtime)]:write(HERE/name,data)
    for name,data in [('scenery.mesh.json',packet),('solids.json',g.solids),('metrics.json',metrics)]:write(OUT/name,data)
    write(HERE/'design-bounds.json',dict(status='SOURCE_CANDIDATE_REQUIRES_INDEPENDENT_VERIFICATION',crosssections=crosssections,nativeIsland=dict(min=[-110,-2,1300],max=[110,2,1500]),nativeLanding=dict(min=[-14,-2,1500],max=[14,2,1526]),arrivalStreetSouth=dict(min=[-9,1.92,1444.5],max=[9,2.08,1509]),portalPosts=[dict(min=[x-.5,2,1516.25],max=[x+.5,12,1517.75]) for x in [-5,5]],artSupport='Every closed course intersects native Island along its north side and native wedge underside by.03Y. No middle piers or new collider authority in art.',artTopY=1.73,roadBottomY=1.7,roadTopY=2.1,oldRoadSeam=dict(x=70,minZ=1494,maxZ=1518,y=2.1),limitations=['Existing approachX0..9 supports22stud strip only; portal posts prevent honest full24 width there.','Start seam has.02 step from ArrivalStreetSouth2.08 to2.1; surrounding native landingtop2.0.','Native tests required for all top/side seams and five heroes; this does not activate or expand a travel route.']))
    sources=['src/server/Services/AdventureMapKit.luau','src/server/Services/WorldQualityAssets.luau','src/server/Services/RegionalWorld.luau','production/world/quality-slice/greenwood-ironveil/ground.json','assets/production/world-slice/world-slice.mesh.json']
    provenance=dict(status='ORIGINAL_FILE_GENERATED_NOT_NATIVE',origin='Original island-embedded stone quay facing; native wedge floor extends existing junction, no third-party assets/providers.',recipe=Path(__file__).relative_to(ROOT).as_posix(),recipeSha256=sha(Path(__file__)),helperSha256=sha(HELPER),sourceHashes={p:sha(ROOT/p) for p in sources},packetSha256=sha(OUT/'scenery.mesh.json'),groundSha256=sha(HERE/'ground.json'),runtimeDescriptorSha256=sha(HERE/'runtime-descriptor.json'),runtimeIds=None)
    write(OUT/'provenance.json',provenance);write(HERE/'provenance.json',provenance)
    print(json.dumps(dict(**metrics,packetSha256=provenance['packetSha256'],groundSha256=provenance['groundSha256'])))
if __name__=='__main__':build()
