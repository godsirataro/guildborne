"""Independent convex/SAT support and full walking-prism review; no engine claims."""
from pathlib import Path
import collections,hashlib,itertools,json,math,re,subprocess
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
ASSET=ROOT/'assets/production/world-slice/ironveil-ashen-causeway-art';BASE='ff81a48'
def sub(a,b):return [x-y for x,y in zip(a,b)]
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def sha(b):return hashlib.sha256(b).hexdigest()
def load(p):return json.loads(p.read_bytes())
def axes(vectors):
    result={}
    for v in vectors:
        length=math.sqrt(dot(v,v))
        if length<1e-8:continue
        n=[x/length for x in v]
        if next(x for x in n if abs(x)>1e-8)<0:n=[-x for x in n]
        result[tuple(round(x,7) for x in n)]=n
    return list(result.values())
def record(name,vs,ns,es):return dict(name=name,vertices=vs,normals=axes(ns),edges=axes(es),min=[min(v[k] for v in vs) for k in range(3)],max=[max(v[k] for v in vs) for k in range(3)])
def box(name,lo,hi):
    basis=[[1,0,0],[0,1,0],[0,0,1]]
    return record(name,list(itertools.product(*zip(lo,hi))),basis,basis)
def overlap(a,b):
    # Require positive penetration, so mere touching cannot support disconnected art.
    if any(min(a['max'][k],b['max'][k])-max(a['min'][k],b['min'][k])<=1e-6 for k in range(3)):return False
    for n in axes(a['normals']+b['normals']+[cross(x,y) for x in a['edges'] for y in b['edges']]):
        x=[dot(v,n) for v in a['vertices']];y=[dot(v,n) for v in b['vertices']]
        if min(max(x),max(y))-max(min(x),min(y))<=1e-6:return False
    return True
def verify_splices(solids):
    """Separated chord halves must bury their entire end faces inside post6."""
    byname={s['name']:s for s in solids};results=[]
    for side in ['north','south']:
        post=byname[side+'_post_6']
        for level in ['lower','upper']:
            left=byname[side+'_iron_'+level];right=byname[side+'_ashen_'+level]
            gap=right['min'][0]-left['max'][0]
            assert gap>1e-5,('exposed_chord_splice_no_positive_gap',side,level,gap)
            # Disjoint X ranges exclude positive-area coincident faces between halves.
            assert not overlap(left,right)
            margins=[]
            for chord,x in [(left,left['max'][0]),(right,right['min'][0])]:
                ends=[v for v in chord['vertices'] if abs(v[0]-x)<1e-7]
                assert len(ends)>=3,('missing_end_face',chord['name'])
                assert overlap(chord,post),('end_not_in_post',chord['name'])
                # Convex post support planes, derived from actual faces/vertices.
                # Strict containment of every end vertex also contains the full face.
                margin=min(min(dot(v,n)-min(dot(p,n) for p in post['vertices']),max(dot(p,n) for p in post['vertices'])-dot(v,n)) for v in ends for n in post['normals'])
                assert margin>1e-5,('exposed_chord_end_face',chord['name'],margin)
                margins.append(margin)
            results.append(dict(side=side,level=level,xGap=gap,endFaceMinimumMargins=margins))
    return results
def old_splice_regression():
    """Read hash-pinned historical archive without requiring a local Git object."""
    archive=ASSET/'revision-ac539a3'
    raw=(archive/'scenery.mesh.json').read_bytes()
    assert sha(raw)=='99ceb74508c2e693957a5601960f2a2897fc85b55eabf17d1dbf0eb5ca471c1e'
    meta_raw=(archive/'solids.json').read_bytes()
    assert sha(meta_raw)=='4a8a1b0d753befc64d6e054b1daa65d78c3f9509a131674e2873f1365d600175'
    data=json.loads(raw);meta=json.loads(meta_raw)
    meshes={m['id']:m for m in data['meshes']};solids=[]
    for p in data['placements']:
        m=meshes[p['meshId']];cf=p['cframe'];sc=p['scale']
        world=[[cf[k]+sum(cf[3+3*k+j]*sc[j]*v[j] for j in range(3)) for k in range(3)] for v in m['vertices']]
        for s in [s for s in meta if s['meshId']==m['id']]:
            fs=m['triangles'][s['firstTriangle']-1:s['firstTriangle']-1+s['triangleCount']]
            vs=[world[i-1] for i in sorted({i for f in fs for i in f})];ns=[];es=[]
            for f in fs:
                a,b,c=[world[i-1] for i in f];ns.append(cross(sub(b,a),sub(c,a)))
                es.extend(sub(world[y-1],world[x-1]) for x,y in zip(f,f[1:]+f[:1]))
            solids.append(record(s['name'],vs,ns,es))
    try:verify_splices(solids)
    except AssertionError as error:
        assert 'exposed_chord_splice_no_positive_gap' in str(error)
        return dict(status='EXPECTED_REJECTION',commit='ac539a3',packetSHA256=sha(raw),reason=str(error))
    raise AssertionError('old_splice_packet_was_not_rejected')
def main():
    packet=load(ASSET/'scenery.mesh.json');meta=load(ASSET/'solids.json');design=load(HERE/'design-bounds.json')
    assert packet['schemaVersion']==1 and packet['coordinateSystem']=='RobloxYUp' and packet['units']=='studs'
    assert packet['runtimeIds'] is None and packet['runtimeImported'] is False and packet['compositionOnly'] is True
    meshes={m['id']:m for m in packet['meshes']};assert len(meshes)==len(packet['meshes'])
    total=sum(len(m['triangles']) for m in meshes.values());assert 0<total<=3000 and 0<len(packet['placements'])<=60
    coverage=collections.defaultdict(list)
    for s in meta:coverage[s['meshId']]+=list(range(s['firstTriangle']-1,s['firstTriangle']-1+s['triangleCount']))
    for mid,m in meshes.items():
        assert sorted(coverage[mid])==list(range(len(m['triangles']))) and len(m['triangles'])<=1900
        assert all(len(v)==3 and all(math.isfinite(x) for x in v) for v in m['vertices'])
        assert m['bounds']=={k:[fn(v[j] for v in m['vertices']) for j in range(3)] for k,fn in [('min',min),('max',max)]}
        assert len(m['faceColors'])==len(m['triangles'])
        assert all(len(c)==3 and all(math.isfinite(x) and 0<=x<=1 for x in c) for c in m['colors'])
        assert all(type(i)==int and 1<=i<=len(m['colors']) for i in m['faceColors'])
        assert all(len(f)==3 and len(set(f))==3 and all(type(i)==int and 1<=i<=len(m['vertices']) for i in f) for f in m['triangles'])
    solids=[];names=set()
    for p in packet['placements']:
        assert p['name'] not in names;names.add(p['name'])
        assert all(p[k] is False for k in ['collision','query','touch'])
        cf=p['cframe'];sc=p['scale'];assert len(cf)==12 and len(sc)==3 and all(math.isfinite(x) for x in cf+sc) and min(sc)>0
        r=[cf[3+i*3:6+i*3] for i in range(3)]
        assert all(abs(dot(r[i],r[j])-(i==j))<1e-7 for i in range(3) for j in range(3)) and dot(r[0],cross(r[1],r[2]))>.999999
        m=meshes[p['meshId']];world=[[cf[k]+sum(r[k][j]*sc[j]*v[j] for j in range(3)) for k in range(3)] for v in m['vertices']]
        for s in [s for s in meta if s['meshId']==m['id']]:
            fs=m['triangles'][s['firstTriangle']-1:s['firstTriangle']-1+s['triangleCount']]
            ids=sorted({i for f in fs for i in f});assert ids==list(range(s['firstVertex'],s['firstVertex']+s['vertexCount']))
            vs=[world[i-1] for i in ids];center=[sum(v[k] for v in vs)/len(vs) for k in range(3)];edges=collections.Counter();ns=[];es=[];volume=0
            for f in fs:
                a,b,c=[world[i-1] for i in f];n=cross(sub(b,a),sub(c,a));ln=math.sqrt(dot(n,n));assert ln>1e-8
                assert dot(n,sub(a,center))>1e-8,('winding',s['name'])
                assert all(dot(n,sub(v,a))<=ln*1e-6 for v in vs),('convex',s['name'])
                ns.append(n);volume+=dot(sub(a,center),cross(sub(b,center),sub(c,center)))/6
                for x,y in zip(f,f[1:]+f[:1]):edges[x,y]+=1;es.append(sub(world[y-1],world[x-1]))
            assert volume>0 and all(count==1 and edges[b,a]==1 for (a,b),count in edges.items()),('closure',s['name'])
            solids.append(record(s['name'],vs,ns,es))
    assert len({s['name'] for s in solids})==len(solids)
    splice_checks=verify_splices(solids);old_splice=old_splice_regression()
    # Parse actual unchanged native Island literals and City.RegionWorld pivots.
    source=(ROOT/'src/server/Services/AdventureMapKit.luau').read_text(encoding="utf-8");city=(ROOT/'src/shared/Config/City.luau').read_text(encoding="utf-8")
    region=(ROOT/'src/server/Services/RegionalWorld.luau').read_text(encoding="utf-8");assert 'model:PivotTo(CFrame.new(worldDef.X,0,worldDef.Z))' in region
    islands=[]
    for zone in ['Ironveil','Ashen']:
        match=re.search(r'\{id="'+zone+r'",parts=\{\s*\{name="Island",size=V\(([^)]+)\),pos=V\(([^)]+)\)',source);assert match
        sz=[float(v) for v in match[1].split(',')];pos=[float(v) for v in match[2].split(',')]
        match=re.search(zone+r'=\{X=([\d.-]+),Z=([\d.-]+),HalfWidth=',city);assert match
        pos[0]+=float(match[1]);pos[2]+=float(match[2])
        islands.append(box('native_'+zone.lower()+'_island',[pos[k]-sz[k]/2 for k in range(3)],[pos[k]+sz[k]/2 for k in range(3)]))
    roads=[];prisms=[]
    for p in load(ROOT/'production/world/quality-slice/ironveil-ashen/ground.json')['parts']:
        assert p['rotation']==[1,0,0,0,1,0,0,0,1] and p['collision'] is True
        lo=[p['position'][k]-p['size'][k]/2 for k in range(3)];hi=[p['position'][k]+p['size'][k]/2 for k in range(3)]
        assert abs(hi[1]-2.1)<1e-8 and abs(lo[1]-1.7)<1e-8
        roads.append(box('native_road_'+p['name'],lo,hi));prisms.append(box('headroom_'+p['name'],[lo[0],2.1,lo[2]],[hi[0],1e6,hi[2]]))
    for s in solids:
        assert not any(overlap(s,p) for p in prisms),('walking_prism_intrusion',s['name'])
        if any(overlap(s,r) for r in roads):assert s['max'][1]<2.1-1e-4,('floor_coplanarity',s['name'])
    graph={s['name']:set() for s in solids};contacts=[]
    for a,b in itertools.combinations(solids,2):
        if overlap(a,b):graph[a['name']].add(b['name']);graph[b['name']].add(a['name']);contacts.append([a['name'],b['name']])
    roots=set();native_contacts=[]
    for s in solids:
        for n in islands+roads:
            if overlap(s,n):native_contacts.append([s['name'],n['name']]);roots.add(s['name']) if n in islands else None
    assert roots
    seen=set(roots);pending=list(roots)
    while pending:
        for name in graph[pending.pop()]-seen:seen.add(name);pending.append(name)
    assert seen==set(graph),('not_connected_to_island',set(graph)-seen)
    byname={s['name']:s for s in solids+islands}
    for c in design['declaredContacts']:
        assert any(overlap(byname[c['a']],r) for r in roads) if c['b']=='native_road' else overlap(byname[c['a']],byname[c['b']]),('declared_contact_missing',c)
    # Every prior tracked source, test, ground and mesh file must retain exact base bytes.
    files=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE],cwd=ROOT,text=True).splitlines();preserved=[]
    for p in files:
        if p.startswith(('src/','tests/')) or p.endswith(('.mesh.json','/ground.json')):
            old=subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT);assert (ROOT/p).read_bytes()==old,('base_mutation',p);preserved.append(p)
    return dict(status='PASS_OFFLINE_GEOMETRY_NOT_NATIVE',packetSHA256=sha((ASSET/'scenery.mesh.json').read_bytes()),spliceChecks=splice_checks,oldSpliceRegression=old_splice,triangles=total,placements=len(packet['placements']),closedConvexSolids=len(solids),nativeIslandBounds={s['name']:{k:s[k] for k in ['min','max']} for s in islands},islandRootedSolids=sorted(roots),solidContacts=contacts,nativeContacts=native_contacts,declaredContactsVerified=len(design['declaredContacts']),headroomPrisms=len(prisms),preservedFiles=preserved,limits=['Contact topology is not structural engineering or native physics.','Decorations are noncolliding: visually framed edges are not gameplay barriers.','Shore occlusion/art acceptance requires actual image review.'])
if __name__=='__main__':print(json.dumps(main(),indent=2))
