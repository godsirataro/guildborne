"""Independent source geometry review; no engine, pathfinding or art acceptance.

Does not import the author's generator. Reconstructs native WedgePart vertices,
clips actual source triangles, and compares retained inputs to reviewed Git base.
Writes nothing; caller must retain stdout/stderr and an exit receipt per attempt.
"""
import hashlib, json, math, re, subprocess, sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p): return json.loads(p.read_text())
def transform(v,f): return [f[i]+sum(f[3+i*3+j]*v[j] for j in range(3)) for i in range(3)]
def sub(a,b): return [x-y for x,y in zip(a,b)]
def cross(a,b): return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def area(t): return math.sqrt(sum(x*x for x in cross(sub(t[1],t[0]),sub(t[2],t[0]))))/2
def clip(poly,fn):
    out=[]
    for p,q in zip(poly,poly[1:]+poly[:1]):
        a,b=fn(p),fn(q)
        if a>=-1e-9: out.append(p)
        if (a>0 and b<0) or (a<0 and b>0):
            out.append([p[k]+a/(a-b)*(q[k]-p[k]) for k in range(3)])
    return out
def over(poly,tri):
    signed=lambda a,b,p:(b[0]-a[0])*(p[2]-a[2])-(b[2]-a[2])*(p[0]-a[0])
    if signed(*tri)<0: tri=tri[::-1]
    for a,b in zip(tri,tri[1:]+tri[:1]):
        poly=clip(poly,lambda p:signed(a,b,p))
        if not poly: break
    return poly
def in_tri(p,t): return bool(over([p,p,p],t))
def polyarea(poly): return abs(sum(a[0]*b[2]-a[2]*b[0] for a,b in zip(poly,poly[1:]+poly[:1])))/2
def packet_triangles(path):
    data=read(path); meshes={m['id']:m for m in data['meshes']}
    for p in data['placements']:
        m=meshes[p['meshId']];f=p['cframe'];s=p.get('scale',[1,1,1])
        vs=[transform([v[k]*s[k] for k in range(3)],f) for v in m['vertices']]
        for face in m['triangles']: yield p['name'],[vs[i-1] for i in face]
def main():
    inputs=[HERE/'ground.json',HERE/'descriptor.json',HERE/'runtime-descriptor.json',
        ROOT/'assets/production/world-slice/world-slice.mesh.json',
        ROOT/'src/server/Services/AdventureMapKit.luau',ROOT/'src/shared/Config/City.luau',
        ROOT/'src/server/Services/WorldQualitySlice.luau',ROOT/'src/shared/Config/WorldQuality.luau']
    artpath=ROOT/'assets/production/world-slice/greenwood-ironveil/scenery.mesh.json'
    inputs.append(artpath)
    inputs.append(artpath.parent/'structural-solids.json')
    before={str(p.relative_to(ROOT)):digest(p) for p in inputs}
    g,d,s=map(read,inputs[:3]); roads=[]; reconstructed=[]
    for p in g['parts']:
        x,y,z=[n/2 for n in p['size']];f=p['position']+p['rotation']
        # Native triangular broad faces at signed local X, upper -Z corner absent.
        faces=[[transform([xx,yy,zz],f) for yy,zz in [(-y,-z),(-y,z),(y,z)]] for xx in (-x,x)]
        top=max(faces,key=lambda t:sum(v[1] for v in t))
        expected_y=2.1 if p['collision'] else 1.9
        assert max(abs(v[1]-expected_y) for v in top)<1e-8
        assert p['anchored'] and not p['touch'] and p['query']==p['collision']
        reconstructed.append(top)
        if p['collision']: roads.append(top)
    authored=[t['vertices'] for t in g['topTriangles'] if t['collision']]
    assert abs(sum(map(area,roads))-sum(map(area,authored)))<1e-6
    for t in roads:
        for v in t: assert any(in_tri(v,a) for a in authored)
    # No positive-area overlap plus identical total area and containment proves
    # coverage of the authored strip, independent of the finite sample check.
    overlaps=[polyarea(over(a,b)) for i,a in enumerate(roads) for b in roads[i+1:]]
    assert max(overlaps)<1e-7
    # Actual reconstructed floor covers every segment across all 24 studs.
    samples=0
    for a,b in zip(g['crosssections'],g['crosssections'][1:]):
        dx,dz=b['center'][0]-a['center'][0],b['center'][2]-a['center'][2]
        length=math.hypot(dx,dz)
        for q in (a,b):
            edge=sub(q['road'][1],q['road'][0])
            assert abs(abs(edge[0]*dz/length-edge[2]*dx/length)-24)<1e-7
        for j in range(41):
            for k in range(25):
                t=j/40;u=k/24
                p=[sum((1-t if end==0 else t)*(1-u if side==0 else u)*q['road'][side][axis]
                       for end,q in enumerate((a,b)) for side in (0,1)) for axis in range(3)]
                assert any(in_tri(p,r) for r in roads),('unsupported floor',p)
                samples+=1
    assert len(s['parts'])==len(g['parts']) and s['colliderCount']==len(roads)
    for p,q in zip(g['parts'],s['parts']):
        assert q['cframe']==p['position']+p['rotation'] and q['size']==p['size'] and q['collision']==p['collision']
    assert s['centerline']==g['walkCenterline'] and len(s['volumes'])==len(s['centerline'])-1
    for zone,(xmin,xmax,zmin,zmax) in {'Greenwood':(-112,112,1298,1528),'Ironveil':(378,622,1288,1536)}.items():
        entry=d['entryVolumes'][zone];lo,hi=entry['min'],entry['max']
        assert xmin<=lo[0]<=hi[0]<=xmax and zmin<=lo[2]<=hi[2]<=zmax and 0<=lo[1]<hi[1]<=35
        assert lo[0]>14 # disjoint from existing west entry even including its boundary
        endpoint=s['centerline'][0 if zone=='Greenwood' else -1]
        assert all(lo[k]<=endpoint[k]<=hi[k] for k in range(3))
    # Native island support reaches first road edge (Greenwood Z <=1500),
    # and fully supports the Ironveil seam. Recovery anchors lie on those islands.
    assert min(v[2] for v in g['crosssections'][0]['road'])<1500
    for zone,origin,half in [('Greenwood',0,(110,100)),('Ironveil',500,(120,110))]:
        p=d['safeRecovery'][zone]
        assert abs(p[0]-origin)<half[0] and abs(p[2]-1400)<half[1]
    obstructions=[]; tested=0; candidate=0
    def check(name,tri):
        nonlocal tested,candidate
        tested+=1
        if max(v[1] for v in tri)<=2.10001 or min(v[1] for v in tri)>=16.1: return
        if max(v[0] for v in tri)<70 or min(v[0] for v in tri)>392 or max(v[2] for v in tri)<1482 or min(v[2] for v in tri)>1528:return
        candidate+=1
        for road in roads:
            poly=over(tri,road)
            if poly: poly=clip(poly,lambda v:v[1]-2.10001)
            if poly: poly=clip(poly,lambda v:16.1-v[1])
            if poly: obstructions.append(name);break
    for name,tri in packet_triangles(inputs[3]): check('reviewed/'+name,tri)
    for name,tri in packet_triangles(artpath): check('newScenery/'+name,tri)
    art=read(artpath); source={m['id']:m for m in read(inputs[3])['meshes']}
    meshes={m['id']:m for m in art['meshes']}; footprints=[]
    assert sum(len(m['triangles']) for m in meshes.values())<=12000
    for m in meshes.values():
        assert all(max(v[k] for v in m['vertices'])-min(v[k] for v in m['vertices'])<=2048 for k in range(3))
    shoulders=[t for t,p in zip(reconstructed,g['parts']) if not p['collision']]
    for p in art['placements']:
        assert not p['collision'] and not p['query'] and not p['touch']
        m=meshes[p['meshId']]
        if m['id'] not in source:continue
        assert m==source[m['id']]
        lo=m['bounds']['min'];hi=m['bounds']['max']
        corners=[[x,0,z] for x,z in [(lo[0],lo[2]),(hi[0],lo[2]),(hi[0],hi[2]),(lo[0],hi[2])]]
        poly=[transform([v[k]*p['scale'][k] for k in range(3)],p['cframe']) for v in corners]
        size=polyarea(poly);supported=sum(polyarea(over(poly,t)) for t in shoulders)
        intrusion=sum(polyarea(over(poly,t)) for t in roads)
        assert abs(size-supported)<1e-6 and intrusion<1e-7,p['name']
        footprints.append(dict(name=p['name'],footprintArea=size,supportedArea=supported,roadIntrusion=intrusion))
    # Original structures may extend below the walk floor but must stay within
    # the existing 36-stud projected strip. No extra broad land is authorized.
    structures=[]
    for p in art['placements']:
        m=meshes[p['meshId']]
        if m['id'] in source:continue
        vs=[transform([v[k]*p['scale'][k] for k in range(3)],p['cframe']) for v in m['vertices']]
        edges=Counter()
        for face in m['triangles']:
            tri=[vs[i-1] for i in face]
            projected=polyarea(tri)
            if projected>1e-7:
                covered=sum(polyarea(over(tri,t)) for t in reconstructed)
                assert abs(projected-covered)<1e-5,('structure escapes strip',p['name'],projected,covered)
            else: assert all(any(in_tri(v,t) for t in reconstructed) for v in tri),p['name']
            for a,b in zip(face,face[1:]+face[:1]):edges[tuple(sorted((a,b)))]+=1
        assert set(edges.values())=={2},('open structure edges',p['name'])
        structures.append(dict(name=p['name'],triangles=len(m['triangles']),closedEdges=True,withinExistingStrip=True))
    solids=read(inputs[-1]);solid_faces={}
    for solid in solids:
        m=meshes[solid['meshId']];start=solid['firstTriangle']-1
        faces=m['triangles'][start:start+solid['triangles']]
        vertex_ids=set();volume=0
        for face in faces:
            vertex_ids.update(face)
            a,b,c=[m['vertices'][i-1] for i in face]
            normal=cross(sub(b,a),sub(c,a));centroid=[(a[k]+b[k]+c[k])/3 for k in range(3)]
            assert sum(normal[k]*(centroid[k]-solid['center'][k]) for k in range(3))>1e-8,('inward solid face',solid['name'])
            volume+=sum(a[k]*cross(b,c)[k] for k in range(3))/6
        assert volume>0 and len(vertex_ids)==8 and len(faces)==12,solid['name']
        assert vertex_ids==set(range(solid['firstVertex'],solid['firstVertex']+8))
        solid_faces.setdefault(solid['meshId'],[]).extend(range(start,start+len(faces)))
    for mid,indices in solid_faces.items(): assert sorted(indices)==list(range(len(meshes[mid]['triangles'])))
    native=inputs[4].read_text(); city=inputs[5].read_text()
    native_count=0
    for zone in ('Greenwood','Ironveil'):
        anchor=re.search(zone+r'=\{X=([\d.-]+),Z=([\d.-]+),HalfWidth',city)
        ox,oz=map(float,anchor.groups())
        block=native.split('{id="'+zone+'",parts={',1)[1].split('},markers={',1)[0]
        for match in re.finditer(r'name="([^"]+)",size=V\(([^)]+)\),pos=V\(([^)]+)\).*?collide=(true|false),wedge=(true|false),yaw=([\d.-]+)',block):
            name,size,pos,collide,wedge,yaw=match.groups(); native_count+=1
            sx,sy,sz=[float(v)/2 for v in size.split(',')];px,py,pz=map(float,pos.split(','));ang=math.radians(float(yaw))
            # Conservative full native box, including noncolliding visual obstacles.
            vs=[[ox+px+x*math.cos(ang)+z*math.sin(ang),py+y,oz+pz-x*math.sin(ang)+z*math.cos(ang)] for x in (-sx,sx) for y in (-sy,sy) for z in (-sz,sz)]
            for a,b,c,e in [(0,1,3,2),(4,6,7,5),(0,4,5,1),(2,3,7,6),(0,2,6,4),(1,5,7,3)]:
                check('native/'+zone+'/'+name,[vs[a],vs[b],vs[c]]);check('native/'+zone+'/'+name,[vs[a],vs[c],vs[e]])
    assert not obstructions,sorted(set(obstructions))
    # Retention: all tracked west recipe/assets and native/source inputs unchanged.
    retained=[]
    paths=['production/world/quality-slice/continuous-corridor','assets/production/world-slice/world-slice.mesh.json','src/server/Services/AdventureMapKit.luau','src/shared/Config/City.luau','src/server/Services/WorldQualityAssets.luau']
    names=subprocess.check_output(['git','ls-tree','-r','--name-only','9588cb6','--',*paths],cwd=ROOT,text=True).splitlines()
    for name in names:
        expected=subprocess.check_output(['git','show','9588cb6:'+name],cwd=ROOT)
        actual=(ROOT/name).read_bytes()
        assert actual.replace(b'\r\n',b'\n')==expected.replace(b'\r\n',b'\n'),name
        retained.append(name)
    config=inputs[7].read_text();old=subprocess.check_output(['git','show','9588cb6:src/shared/Config/WorldQuality.luau'],cwd=ROOT,text=True)
    extract=lambda t:t.split('-- BEGIN GENERATED CONTINUOUS CORRIDOR')[1].split('-- END GENERATED CONTINUOUS CORRIDOR')[0]
    assert extract(config)==extract(old),'West spec altered'
    runtime=inputs[6].read_text();old_runtime=subprocess.check_output(['git','show','9588cb6:src/server/Services/WorldQualitySlice.luau'],cwd=ROOT,text=True)
    west=lambda t:t.split('function result.buildContinuousCorridor()')[1].split('\n\tend')[0]
    assert west(runtime)==west(old_runtime),'West builder altered'
    south=runtime.split('function result.buildGreenwoodIronveilCorridor()')[1].split('\n\tlocal ok,problem')[0]
    assert 'wall' not in south.lower() and 'town' not in south and 'geometry:Destroy()' in south
    equivalence=read(HERE/'line-ending-equivalence.json')
    for item in equivalence['source']:
        raw=ROOT/item['rawSnapshot'];final=ROOT/item['source']
        assert digest(raw)==item['baselineRawSha256'] and digest(final)==item['finalLfSha256']
        assert raw.read_bytes().replace(b'\r\n',b'\n')==final.read_bytes()
    checked_receipts=[]
    for dirname in ('checks-final01','checks-normalized02'):
        receipt=read(HERE/dirname/'receipts.json');assert receipt['inputsUnchanged']
        snapshots={item['source']:item['rawSnapshot'] for item in equivalence['source']}
        for name,h in receipt['inputHashes'].items():
            actual=ROOT/(snapshots.get(name,name) if dirname=='checks-final01' else name)
            assert digest(actual)==h,('check receipt input mismatch',dirname,name)
        for result in receipt['checks']:
            assert result['exitCode']==0
            for suffix in ('stdout','stderr'):
                assert digest(HERE/dirname/(result['name']+'.'+suffix+'.txt'))==result[suffix+'Sha256']
            checked_receipts.append(dirname+'/'+result['name'])
    render_hashes={}
    for variant in (() if '--skip-render' in sys.argv else ('before','after')):
        folder=artpath.parent/variant;receipt=read(folder/'blender-exit.json');evidence=read(folder/'render-evidence.json')
        assert receipt['exitCode']==0 and receipt['inputsUnchanged']
        for name,h in receipt['inputHashes'].items():assert digest(ROOT/name)==h,name
        for suffix in ('stdout','stderr'): assert digest(folder/('blender-'+suffix+'.txt'))==receipt[suffix+'Sha256']
        for name,h in evidence['hashes'].items():
            assert digest(folder/name)==h
            render_hashes[variant+'/'+name]=h
    assert before=={str(p.relative_to(ROOT)):digest(p) for p in inputs},'Source changed during review'
    print(json.dumps(dict(status='PASS_SOURCE_GEOMETRY_ONLY',inputHashes=before,reconstructedWedges=len(reconstructed),roadWedges=len(roads),floorSamples=samples,roadArea=sum(map(area,roads)),maxRoadPairOverlap=max(overlaps),fullPropFootprints=footprints,originalStructures=structures,closedOutwardStructuralSolids=len(solids),verifiedCheckReceipts=checked_receipts,renderHashes=render_hashes,obstacleTriangles=tested,verticalCandidates=candidate,obstructions=obstructions,nativePieces=native_count,retainedFiles=retained,westSpecAndBuilderUnchanged=True,limitations=['No Roblox engine execution or PathfindingService proof','Visual review separate from source geometry','Conservative native bounding boxes; exact original mesh triangles','Geometry is source candidate; no activation, multiplayer, device or human acceptance']),indent=2))
if __name__=='__main__':main()
