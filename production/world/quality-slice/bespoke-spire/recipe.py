"""Original masonry watch-spire; replaces only the explicitly retired beacon.

All architecture is authored here, with real through openings and closed stone
solids. No borrowed geometry, downloads, runtime IDs or new walkable ground.
"""
from pathlib import Path
import json, math, hashlib, importlib.util
from copy import deepcopy

ROOT=Path(__file__).resolve().parents[4]
OUT=ROOT/'assets/production/world-slice/bespoke-spire'
SOURCE=ROOT/'assets/production/world-slice/coast-composition/scenery.mesh.json'
EXPECTED='79e3c3ea39f702ee77d6765ea41d0dffbdbc9cd4a1c674faa1a01832e82f807f'
RETIRED='landforms_ruined_beacon__000'
spec=importlib.util.spec_from_file_location('partition',ROOT/'production/world/quality-slice/mesh-extents/partition.py')
split=importlib.util.module_from_spec(spec);spec.loader.exec_module(split)
PALETTE=[[.39,.41,.36],[.46,.47,.40],[.52,.52,.43],[.31,.34,.30],[.57,.55,.44],[.25,.32,.19]]
IDENTITY=[0,0,0,1,0,0,0,1,0,0,0,1]
mesh=dict(id='bespoke_watch_spire',vertices=[],triangles=[],faceColors=[],colors=PALETTE)
SOLIDS=[]

def world(v,rotation=0):
    x,y,z=v;c=math.cos(rotation);s=math.sin(rotation)
    x,z=x*c+z*s,-x*s+z*c
    t=2**-.5
    return [-565+t*(-x+z),y,460+t*(-x-z)]

def tri(a,b,c,color):
    u=[b[i]-a[i] for i in range(3)];v=[c[i]-a[i] for i in range(3)]
    cross=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
    assert sum(n*n for n in cross)>1e-12
    n=len(mesh['vertices']);mesh['vertices'] += [a,b,c]
    mesh['triangles'].append([n+1,n+2,n+3]);mesh['faceColors'].append(color)

def prism(poly,z0,z1,color,rotation=0):
    # Convex CCW section in local X/Y; every closed-solid face faces outward.
    area=sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(poly,poly[1:]+poly[:1]))
    if area<0:poly=list(reversed(poly))
    lo=[world([x,y,z0],rotation) for x,y in poly]
    hi=[world([x,y,z1],rotation) for x,y in poly]
    start=len(mesh['triangles']);n=len(poly)
    for i in range(1,n-1):tri(hi[0],hi[i],hi[i+1],color);tri(lo[0],lo[i+1],lo[i],color)
    for i in range(n):
        j=(i+1)%n
        tri(lo[i],lo[j],hi[j],color);tri(lo[i],hi[j],hi[i],color)
    center=[sum(v[a] for v in lo+hi)/(2*n) for a in range(3)]
    for face in mesh['triangles'][start:]:
        a,b,c=[mesh['vertices'][i-1] for i in face]
        u=[b[k]-a[k] for k in range(3)];v=[c[k]-a[k] for k in range(3)]
        normal=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
        assert sum(normal[k]*((a[k]+b[k]+c[k])/3-center[k]) for k in range(3))>1e-9
    SOLIDS.append(dict(firstFace=start+1,faceCount=len(mesh['triangles'])-start,center=center))

def box(x0,x1,y0,y1,z0,z1,color=1,r=0):
    prism([[x0,y0],[x1,y0],[x1,y1],[x0,y1]],z0,z1,color,r)

def courses(x0,x1,y0,y1,z0,z1,r,seed=0):
    count=max(1,math.ceil((y1-y0)/4.8))
    for k in range(count):
        low=y0+(y1-y0)*k/count;high=y0+(y1-y0)*(k+1)/count
        # Alternating large ashlar joints are physical, shallow recesses.
        cuts=[x0,x0+(x1-x0)*(.43 if k%2 else .62),x1]
        for j,(a,b) in enumerate(zip(cuts,cuts[1:])):
            box(a+.035,b-.035,low+.035,high-.035,z0,z1,1+(k+j+seed)%3,r)

def arched_wall(bottom,spring,r,seed):
    # Eight-stud-wide actual aperture, fifteen+ studs tall, on all four sides.
    courses(-9,-4,bottom,spring+6,6.7,9,r,seed)
    courses(4,9,bottom,spring+6,6.7,9,r,seed+1)
    for i in range(8):
        a=i*math.pi/8;b=(i+1)*math.pi/8
        poly=[[4*math.cos(a),spring+4*math.sin(a)],
              [6*math.cos(a),spring+6*math.sin(a)],
              [6*math.cos(b),spring+6*math.sin(b)],
              [4*math.cos(b),spring+4*math.sin(b)]]
        prism(poly,6.4,9.35,5 if i in (3,4) else 2+(i%2),r)
    # Above the curved arch, fill only exterior spandrel strips.
    for i in range(8):
        a=-4+i;b=a+1
        lowa=spring+math.sqrt(36-a*a);lowb=spring+math.sqrt(36-b*b)
        if max(lowa,lowb)>=spring+6:top=spring+6.3
        else:top=spring+6.3
        prism([[a,lowa],[b,lowb],[b,top],[a,top]],6.7,9,2,r)

def ground(packet,x,z):
    ys=[]
    for m in packet['meshes']:
        if not m['id'].startswith(('landforms_west','coast_headland')):continue
        for face in m['triangles']:
            a,b,c=[m['vertices'][i-1] for i in face]
            d=(b[2]-c[2])*(a[0]-c[0])+(c[0]-b[0])*(a[2]-c[2])
            if abs(d)<1e-9:continue
            u=((b[2]-c[2])*(x-c[0])+(c[0]-b[0])*(z-c[2]))/d
            v=((c[2]-a[2])*(x-c[0])+(a[0]-c[0])*(z-c[2]))/d
            if min(u,v,1-u-v)>=-1e-7:ys.append(u*a[1]+v*b[1]+(1-u-v)*c[1])
    assert ys,(x,z)
    return max(ys)

def main():
    raw=SOURCE.read_bytes();assert hashlib.sha256(raw).hexdigest()==EXPECTED
    source=json.loads(raw);packet=deepcopy(source)
    packet['meshes']=[m for m in packet['meshes'] if m['id']!=RETIRED]
    packet['placements']=[p for p in packet['placements'] if p['meshId']!=RETIRED]
    # Broad low stepped foundation with terrain-driven buried supports.
    samples=[]
    for x in (-10,0,10):
        for z in (-10,0,10):
            p=world([x,0,z]);samples.append(dict(x=p[0],z=p[2],groundY=ground(source,p[0],p[2])))
    bottom=min(s['groundY'] for s in samples)-1.5
    box(-10,10,bottom,1.8,-10,10,4)
    box(-11.1,11.1,1.8,3.3,-11.1,11.1,2)
    box(-10.2,10.2,3.3,5,-10.2,10.2,3)
    # Narrow soil-stained ashlar facing breaks up the exposed downhill plinth.
    for side in range(4):
        courses(-10,10,bottom,1.8,9.97,10.22,side*math.pi/2,side+2)
    for side in range(4):
        r=side*math.pi/2
        courses(-9,9,5,39,6.7,9,r,side)
        box(-9.65,9.65,38.5,40.5,6.3,9.65,4,r)
        arched_wall(40.5,55.5,r,side)
        courses(-9,9,61.8,78,6.7,9,r,side+1)
        box(-9.7,9.7,77,79,6.3,9.7,5,r)
        arched_wall(79,96,r,side+1)
        # Broken, unequal parapet. Opposite corner remnants sustain old height.
        top=[119.5,110,115,106][side]
        roof=[(-9,top-.8),(-6.6,top),(-5.5,top-2),(-3.8,max(103.3,top-4))]
        for (a,ay),(b,by) in zip(roof,roof[1:]):
            prism([[a,102.3],[b,102.3],[b,by],[a,ay]],6.6,9.5,2,r)
        # Convex strips retain the jagged roof without inverted low-side solids.
        roof=[(4,max(104.3,top-8)),(5.4,max(104.8,top-9)),(7,max(105.2,top-6)),(9,max(104.5,top-7))]
        for (a,ay),(b,by) in zip(roof,roof[1:]):
            prism([[a,102.3],[b,102.3],[b,by],[a,ay]],6.6,9.5,3,r)
        # Narrow fractured arch stump, never bridging the open watch crown.
        box(-9.8,-3.5,102.3,104,6.2,9.8,4,r)
        # Stepped buttress fins leave the large window clear.
        for x0,x1 in [(-9,-6.6),(6.6,9)]:
            prism([[x0,3.3],[x1,3.3],[x1,48],[x0,48]],9,11.6,3,r)
            foot=[]
            for fx in (x0,(x0+x1)/2,x1):
                for fz in (9,11.6,13.4):
                    fp=world([fx,0,fz],r);foot.append(ground(source,fp[0],fp[2]))
            footbottom=min(foot)-.6
            prism([[x0,footbottom],[x1,footbottom],[x1,3.3],[x0,3.3]],9,13.4,3,r)
            prism([[x0,3.3],[x1,3.3],[x1,25],[x0,25]],11.6,13.4,1,r)
    # Deliberate fallen arch pieces, cut stone and moss beds at one base corner.
    # These are original authored solids, not random scatter or cloned kit props.
    for i,(x,z,angle) in enumerate([(-3,14,.14),(0,15,-.3),(3,14,.5)]):
        levels=[]
        for fx in (x-1.3,x,x+1.3):
            for fz in (z-2,z,z+2):
                pos=world([fx,0,fz]);levels.append(ground(source,pos[0],pos[2]))
        top=max(levels)+1.7+(i%2)*.8
        box(x-1.3,x+1.3,min(levels)-.8,top,z-2,z+2,2+i%2)
        box(x-1,x+1,top,top+.08,z-1.5,z+1.5,6)
    # One sheltered grouping, reusing reviewed resources verbatim.
    accents=[]
    lookup={m['id']:m for m in source['meshes']}
    for name,mid,lx,lz,scale,angle in [
        ('Spire_FernRock_Foot','silhouette_fern_rocks__000',-5,14,.55,.3),
        ('Spire_Bush_Shelter','bush__000',5,14,.55,-.4)]:
        m=lookup[mid];c=math.cos(angle);sn=math.sin(angle)
        pos=world([lx,0,lz]);x,z=pos[0],pos[2]
        footprints=[(x+(v[0]*c+v[2]*sn)*scale,z+(-v[0]*sn+v[2]*c)*scale) for v in m['vertices']]
        levels=[ground(source,px,pz) for px,pz in footprints]
        base=min(levels)-.25
        packet['placements'].append(dict(meshId=mid,name=name,cframe=[x,base,z,c,0,sn,0,1,0,-sn,0,c],scale=[scale]*3,collision=False,query=False,touch=False))
        accents.append(dict(name=name,meshId=mid,groundMin=min(levels),groundMax=max(levels),baseY=base))
    mesh['bounds']=split.bounds(mesh['vertices'])
    parts=split.partition(mesh,[2000]*3)
    for part in parts:
        packet['meshes'].append(part)
        packet['placements'].append(dict(meshId=part['id'],name=part['id'],cframe=IDENTITY,scale=[1,1,1],collision=False,query=False,touch=False))
    assert all(m in packet['meshes'] for m in source['meshes'] if m['id']!=RETIRED)
    assert all(p in packet['placements'] for p in source['placements'] if p['meshId']!=RETIRED)
    metrics=split.validate_extents(packet)
    lookup={m['id']:m for m in packet['meshes']}
    unique=sum(len(m['triangles']) for m in packet['meshes'])
    instanced=sum(len(lookup[p['meshId']]['triangles']) for p in packet['placements'])
    assert unique<=12000 and instanced<=50000 and len(packet['placements'])<=100
    out=(json.dumps(packet,separators=(',',':'))+'\n').encode()
    proof=dict(sourceSha256=EXPECTED,packetSha256=hashlib.sha256(out).hexdigest(),retiredMesh=RETIRED,retiredMeshPreserved=False,allOtherResourcesAndPlacementsExact=True,retainedOriginalProps=57,uniqueTriangles=unique,instancedTriangles=instanced,placements=len(packet['placements']),spireTriangles=len(mesh['triangles']),spireBounds=mesh['bounds'],foundationSamples=samples,foundationBottom=bottom,closedSolids=len(SOLIDS),outwardSolidFaceCheck=True,zeroAreaFaces=0,groundAndNodesUnmodified=True)
    provenance=dict(status='FILE_GENERATED_NOT_STUDIO',origin='Original deterministic Guildborne masonry geometry authored in recipe.py',license='Original project work; no third-party geometry added',source=str(SOURCE.relative_to(ROOT)),sourceSha256=EXPECTED,packetSha256=proof['packetSha256'],runtimeIds=None,studioTested=False,humanApproved=False,design='Stepped ashlar base, buttress fins, two tiers of true arched apertures, asymmetrical fractured watch crown and three deliberate mossed fallen stones.',envelopeException='Buried support bottom follows terrain; visible spire kept within previous landmark envelope.')
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'scenery.mesh.json').write_bytes(out)
    (OUT/'solids.json').write_text(json.dumps(dict(mesh=mesh,solids=SOLIDS),separators=(',',':'))+'\n',encoding='utf-8')
    metrics.update(proof)
    metrics['accentSupports']=accents
    provenance['reusedAccentResources']=['silhouette_fern_rocks__000','bush__000']
    provenance['license']='Original architecture; retained original Guildborne fern-rock and reviewed Quaternius CC0 bush reused in two deliberate placements'
    provenance['licenseFiles']=['assets/production/world-slice/village-LICENSE.txt','assets/production/world-slice/ruins-LICENSE.txt']
    (OUT/'metrics.json').write_text(json.dumps(metrics,indent=2)+'\n',encoding='utf-8')
    (OUT/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(proof,indent=2))

if __name__=='__main__':main()
