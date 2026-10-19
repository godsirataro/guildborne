"""Independent convex geometry, footprint, retention and support review."""
import collections, hashlib, importlib.util, json, math, pathlib, subprocess
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
ASSET=ROOT/'assets/production/world-slice/city-smith-apron';BASE='6e6f4c376b3f3596141389165db2e8e171e80034'
spec=importlib.util.spec_from_file_location('geom',HERE.parent/'ironveil-ore-yard'/'verify.py');g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def sha(b):return hashlib.sha256(b).hexdigest()
def contact(a,b):
    if any(a['max'][k]<b['min'][k]-1e-5 or b['max'][k]<a['min'][k]-1e-5 for k in range(3)):return False
    axes=a['normals']+b['normals']+[g.cross(x,y) for x in a['edges'] for y in b['edges']]
    for n in axes:
        length=math.sqrt(dot(n,n))
        if length<1e-8:continue
        x=[dot(v,n) for v in a['vertices']];y=[dot(v,n) for v in b['vertices']]
        if max(x)<min(y)-length*1e-5 or max(y)<min(x)-length*1e-5:return False
    return True
def main():
    packetpath=ASSET/'scenery.mesh.json';solidpath=ASSET/'solids.json'
    data=json.loads(packetpath.read_bytes());meta=json.loads(solidpath.read_bytes())
    assert data['schemaVersion']==1 and data['coordinateSystem']=='RobloxYUp' and data['units']=='studs'
    assert data['runtimeImported'] is False and data.get('runtimeIds') is None
    meshes={m['id']:m for m in data['meshes']};assert len(meshes)==len(data['meshes'])
    total=sum(len(m['triangles']) for m in meshes.values());assert 0<total<=4000
    covered={k:[] for k in meshes}
    for s in meta:covered[s['meshId']].extend(range(s['firstTriangle']-1,s['firstTriangle']-1+s['triangleCount']))
    for mid,m in meshes.items():
        assert 0<len(m['triangles'])<=1900
        assert sorted(covered[mid])==list(range(len(m['triangles']))),('uncovered_or_duplicate_faces',mid)
        assert all(len(v)==3 and all(math.isfinite(x) for x in v) for v in m['vertices'])
        assert len(m['faceColors'])==len(m['triangles'])
        assert all(len(c)==3 and all(math.isfinite(x) and 0<=x<=1 for x in c) for c in m['colors'])
        assert all(type(i)==int and 1<=i<=len(m['colors']) for i in m['faceColors'])
        assert all(len(t)==3 and len(set(t))==3 and all(type(i)==int and 1<=i<=len(m['vertices']) for i in t) for t in m['triangles'])
        assert m['bounds']=={'min':[min(v[k] for v in m['vertices']) for k in range(3)],'max':[max(v[k] for v in m['vertices']) for k in range(3)]}
    records=[];names=set();faces_checked=0
    for p in data['placements']:
        assert p['name'] not in names;names.add(p['name'])
        assert all(p.get(k) is False for k in ('collision','query','touch'))
        assert len(p['cframe'])==12 and len(p['scale'])==3 and all(math.isfinite(x) for x in p['cframe']+p['scale']) and min(p['scale'])>0
        basis=[p['cframe'][3+3*k:6+3*k] for k in range(3)]
        assert all(abs(dot(basis[i],basis[j])-(i==j))<1e-6 for i in range(3) for j in range(3))
        assert dot(basis[0],g.cross(basis[1],basis[2]))>0.999999
        m=meshes[p['meshId']];world=[g.transform(v,p) for v in m['vertices']]
        for v in world:assert ((346-1e-6<=v[0]<=354+1e-6) or (386-1e-6<=v[0]<=394+1e-6)) and -969-1e-6<=v[2]<=-959+1e-6,('unsafe_vertex',p['name'],v)
        for s in [s for s in meta if s['meshId']==p['meshId']]:
            faces=m['triangles'][s['firstTriangle']-1:s['firstTriangle']-1+s['triangleCount']]
            ids=sorted({i for t in faces for i in t});vs=[world[i-1] for i in ids]
            center=[sum(v[k] for v in vs)/len(vs) for k in range(3)];edges=collections.Counter();directions=[];normals=[];volume=0
            for f in faces:
                a,b,c=[world[i-1] for i in f];n=g.cross(g.sub(b,a),g.sub(c,a));ln=math.sqrt(dot(n,n));assert ln>1e-9
                assert dot(n,g.sub(a,center))>1e-9,('inward',s['name'])
                assert all(dot(n,g.sub(v,a))<=ln*1e-5 for v in vs),('nonconvex',s['name'])
                volume+=dot(g.sub(a,center),g.cross(g.sub(b,center),g.sub(c,center)))/6
                normals.append(n)
                for x,y in zip(f,f[1:]+f[:1]):edges[(x,y)]+=1;directions.append(g.sub(world[y-1],world[x-1]))
                faces_checked+=1
            assert volume>0 and all(n==1 and edges[(b,a)]==1 for (a,b),n in edges.items()),('open_or_bad_edge',s['name'])
            low=[min(v[k] for v in vs) for k in range(3)];high=[max(v[k] for v in vs) for k in range(3)]
            assert high[0]<=354+1e-6 or low[0]>=386-1e-6,('spans_center_gap',s['name'])
            records.append({'name':p['name']+'/'+s['name'],'vertices':vs,'min':low,'max':high,'normals':normals,'edges':directions})
    roots={i for i,s in enumerate(records) if s['min'][1]<=.3+1e-5 and s['max'][1]>=.3-1e-5};assert roots,'No ground contacts'
    reached=set(roots);links=[]
    while True:
        before=len(reached)
        for j,b in enumerate(records):
            if j in reached:continue
            for i in list(reached):
                if contact(records[i],b):reached.add(j);links.append([records[i]['name'],b['name']]);break
        if len(reached)==before:break
    assert len(reached)==len(records),('unsupported_solids',[s['name'] for i,s in enumerate(records) if i not in reached])
    retained={}
    tracked=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'assets/production/world-slice'],cwd=ROOT).decode().splitlines()
    for name in tracked:
        if not name.endswith('.mesh.json'):continue
        raw=subprocess.check_output(['git','show',BASE+':'+name],cwd=ROOT);now=(ROOT/name).read_bytes();assert raw==now,('existing_dataset_changed',name);retained[name]=sha(raw)
    report={'status':'PASS_OFFLINE_GEOMETRY_VISUAL_NATIVE_PENDING','packetSHA256':sha(packetpath.read_bytes()),'solidsSHA256':sha(solidpath.read_bytes()),'verifierSHA256':sha(pathlib.Path(__file__).read_bytes()),'base':BASE,'uniqueTriangles':total,'meshes':len(meshes),'placements':len(data['placements']),'closedConvexSolids':len(records),'outwardFaces':faces_checked,'groundRoots':[records[i]['name'] for i in sorted(roots)],'contactLinks':links,'supportToleranceStuds':1e-5,'retainedDatasetHashes':retained,'clearCenterWidth':28,'forgeLaneMinimumBuffer':min(396-r['max'][0] for r in records),'limitations':['Convex contact graph proves contact connectivity, not load-bearing physics.','No Studio, device, traversal or visual acceptance.']}
    out=HERE/'independent-review.json';assert not out.exists();out.write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps(report))
if __name__=='__main__':main()
