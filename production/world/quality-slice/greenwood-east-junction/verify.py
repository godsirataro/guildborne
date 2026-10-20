"""Independent reconstruction and polygon coverage; print only, no engine claims."""
from pathlib import Path
import collections,hashlib,importlib.util,itertools,json,math,re,subprocess,sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
ASSET=ROOT/'assets/production/world-slice/greenwood-east-junction'
def module(name,path):
    s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
g=module('independent_clip',HERE.parent/'greenwood-ironveil/independent_verify.py')
sat=module('independent_sat',HERE.parent/'ironveil-ashen-causeway-art/verify.py')
def load(p):return json.loads(p.read_bytes())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def top(p):
    x,y,z=[n/2 for n in p['size']];f=p['position']+p['rotation']
    faces=[[g.transform([xx,yy,zz],f) for yy,zz in [(-y,-z),(-y,z),(y,z)]] for xx in [-x,x]]
    return max(faces,key=lambda t:sum(v[1] for v in t))
def rect(x0,x1,z0,z1,y=2.1):return [[x0,y,z0],[x1,y,z0],[x1,y,z1],[x0,y,z1]]
def over(poly,boundary):
    signed=lambda a,b,p:(b[0]-a[0])*(p[2]-a[2])-(b[2]-a[2])*(p[0]-a[0])
    if sum(a[0]*b[2]-a[2]*b[0] for a,b in zip(boundary,boundary[1:]+boundary[:1]))<0:boundary=boundary[::-1]
    for a,b in zip(boundary,boundary[1:]+boundary[:1]):
        poly=g.clip(poly,lambda p:signed(a,b,p))
        if not poly:break
    return poly
def coverage(polys,expected):
    for poly in polys:assert abs(sum(g.polyarea(over(poly,q)) for q in expected)-g.polyarea(poly))<1e-5,('outside_expected',poly)
    assert abs(sum(map(g.polyarea,polys))-sum(map(g.polyarea,expected)))<1e-5
    assert all(g.polyarea(over(a,b))<1e-6 for a,b in itertools.combinations(polys,2)), 'overlapping_floor_faces'
def embedded_descriptor():
    source=(ROOT/'src/shared/Config/WorldQuality.luau').read_text(encoding='utf-8')
    literal=source.split('local junctionGeometry=freezeJunction(',1)[1].split(')\nQuality.GreenwoodEastJunction=',1)[0]
    tokens=re.findall(r'"[^"\\]*(?:\\.[^"\\]*)*"|[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?|true|false|[{}\[\]=,]',literal)
    index=0
    def take(want=None):
        nonlocal index
        t=tokens[index];index+=1
        if want is not None:assert t==want,(t,want)
        return t
    def value():
        t=take()
        if t=='{':
            array=[];mapping={}
            while tokens[index]!='}':
                if tokens[index]=='[':
                    take('[');key=json.loads(take());take(']');take('=');mapping[key]=value()
                else:array.append(value())
                if tokens[index]==',':take(',')
            take('}');assert not (array and mapping)
            return mapping if mapping else array
        if t.startswith('"'):return json.loads(t)
        if t in ['true','false']:return t=='true'
        return float(t)
    result=value();assert index==len(tokens)
    return result
def main():
    ground=load(HERE/'ground.json');runtime=load(HERE/'runtime-descriptor.json');road=[]
    assert embedded_descriptor()==runtime,'embedded_runtime_descriptor_drift'
    assert len(ground['parts'])==len(runtime['parts'])==runtime['colliderCount']==8
    for p,q in zip(ground['parts'],runtime['parts']):
        assert p['className']==q['kind']=='WedgePart' and p['collision'] and p['query'] and p['anchored'] and not p['touch']
        assert p['size']==q['size'] and p['position']+p['rotation']==q['cframe'] and p['name']==q['name']
        r=[p['rotation'][i*3:i*3+3] for i in range(3)]
        assert all(abs(sat.dot(r[i],r[j])-(i==j))<1e-8 for i in range(3) for j in range(3)) and sat.dot(r[0],sat.cross(r[1],r[2]))>.999999
        t=top(p);assert all(abs(v[1]-2.1)<1e-8 for v in t);road.append(t)
    expected=[[[9,2.1,1493],[14,2.1,1493],[14,2.1,1517],[9,2.1,1515]],[[14,2.1,1493],[70,2.1,1494],[70,2.1,1518],[14,2.1,1517]]]
    coverage(road,expected)
    oldroad=[top(p) for p in load(HERE.parent/'greenwood-ironveil/ground.json')['parts'] if p['collision']]
    assert all(g.polyarea(over(t,q))<1e-6 for t in road for q in oldroad),'old_road_coplanar_overlap'
    def seam_intervals(tris,x):
        out=[]
        for t in tris:
            zs=[v[2] for v in t if abs(v[0]-x)<1e-7]
            for a,b in zip(t,t[1:]+t[:1]):
                if (a[0]-x)*(b[0]-x)<0:
                    f=(x-a[0])/(b[0]-a[0]);zs.append(a[2]+f*(b[2]-a[2]))
            if len(zs)>1:out.append([min(zs),max(zs)])
        merged=[]
        for a,b in sorted(out):
            if merged and a<=merged[-1][1]+1e-7:merged[-1][1]=max(b,merged[-1][1])
            else:merged.append([a,b])
        return merged
    for x,a,b in [(9,1493,1515),(14,1493,1517),(70,1494,1518)]:
        spans=seam_intervals(road,x);assert len(spans)==1 and abs(spans[0][0]-a)<1e-7 and abs(spans[0][1]-b)<1e-7
    assert seam_intervals(oldroad,70)==[[1494.0,1518.0]] or all(abs(x-y)<1e-6 for x,y in zip(seam_intervals(oldroad,70)[0],[1494,1518]))
    native=(ROOT/'src/server/Services/AdventureMapKit.luau').read_text(encoding='utf-8').split('{id="Greenwood",parts={')[1].split('},markers=')[0]
    city=(ROOT/'src/shared/Config/City.luau').read_text(encoding='utf-8');pivot=re.search(r'Greenwood=\{X=([\d.-]+),Z=([\d.-]+),HalfWidth=',city);assert pivot
    ox,oz=map(float,pivot.groups());parts=[]
    pattern=r'\{name="([^"]+)",size=V\(([^)]+)\),pos=V\(([^)]+)\),color=.*?,collide=(true|false),wedge=(true|false),yaw=([\d.-]+)\}'
    for m in re.finditer(pattern,native):
        sz=[float(v) for v in m[2].split(',')];pos=[float(v) for v in m[3].split(',')];pos[0]+=ox;pos[2]+=oz
        parts.append(dict(name=m[1],size=sz,position=pos,wedge=m[5]=='true',yaw=float(m[6]),collision=m[4]=='true'))
    island=next(p for p in parts if p['name']=='Island');landing=next(p for p in parts if p['name']=='Landing')
    def nativebox(p):return sat.box(p['name'],[p['position'][k]-p['size'][k]/2 for k in range(3)],[p['position'][k]+p['size'][k]/2 for k in range(3)])
    ib,lb=nativebox(island),nativebox(landing);assert ib['max']==[110,2,1500] and lb['max']==[14,2,1526]
    assets=(ROOT/'src/server/Services/WorldQualityAssets.luau').read_text(encoding='utf-8')
    m=re.search(r'\["name"\]="ArrivalStreetSouth",\["kind"\]="Part",\["size"\]=\{([^}]+)\},\["cframe"\]=\{([^}]+)\}',assets);assert m
    size=list(map(float,m[1].split(',')));cf=list(map(float,m[2].split(',')));assert cf[3:]==[1,0,0,0,1,0,0,0,1]
    street=sat.box('ArrivalStreetSouth',[cf[k]-size[k]/2 for k in range(3)],[cf[k]+size[k]/2 for k in range(3)]);assert street['max']==[9,2.08,1509]
    # X0..9 approach union has native support. The south portal posts preclude 24 there.
    approach=rect(0,9,1493,1515);supports=[rect(ib['min'][0],ib['max'][0],ib['min'][2],ib['max'][2]),rect(lb['min'][0],lb['max'][0],lb['min'][2],lb['max'][2])]
    assert abs(sum(g.polyarea(over(approach,p)) for p in supports)-g.polyarea(approach))<1e-6
    regional=(ROOT/'src/server/Services/RegionalWorld.luau').read_text(encoding='utf-8');assert 'V(1,10,1.5),position+V(x,0,0)' in regional and '{-5,5}' in regional
    dest=re.search(r'Greenwood=\{Id="Greenwood",Spawn="[^"]+",X=([\d.-]+),Y=([\d.-]+),Z=([\d.-]+)',city);assert dest
    px,py,pz=map(float,dest.groups());posts=[rect(px+x-.5,px+x+.5,pz+12-.75,pz+12+.75) for x in [-5,5]]
    assert all(g.polyarea(over(approach,p))<1e-7 for p in posts)
    assert any(g.polyarea(over(rect(0,9,1493,1517),p))>0 for p in posts),'24_width_counterexample_missing'
    packet=load(ASSET/'scenery.mesh.json');meta=load(ASSET/'solids.json');solids=[];meshes={m['id']:m for m in packet['meshes']}
    assert packet['schemaVersion']==1 and packet['coordinateSystem']=='RobloxYUp' and packet['runtimeImported'] is False and packet['runtimeIds'] is None
    assert sum(len(m['triangles']) for m in meshes.values())<=1500 and len(packet['placements'])<=20
    for p in packet['placements']:
        assert all(p[k] is False for k in ['collision','query','touch']);assert p['scale']==[1,1,1]
        m=meshes[p['meshId']];world=[g.transform(v,p['cframe']) for v in m['vertices']];covered=[]
        assert m['bounds']=={k:[fn(v[i] for v in m['vertices']) for i in range(3)] for k,fn in [('min',min),('max',max)]}
        assert len(m['triangles'])==len(m['faceColors']) and all(1<=i<=len(m['colors']) for i in m['faceColors'])
        for s in [s for s in meta if s['meshId']==m['id']]:
            ids=range(s['firstTriangle']-1,s['firstTriangle']-1+s['triangleCount']);covered.extend(ids);fs=[m['triangles'][i] for i in ids]
            vs=[world[i-1] for i in sorted({i for f in fs for i in f})];center=[sum(v[k] for v in vs)/len(vs) for k in range(3)];edges=collections.Counter();ns=[];es=[]
            for f in fs:
                assert len(set(f))==3 and all(1<=i<=len(world) for i in f)
                a,b,c=[world[i-1] for i in f];n=sat.cross(sat.sub(b,a),sat.sub(c,a));ln=math.sqrt(sat.dot(n,n));assert ln>1e-8 and sat.dot(n,sat.sub(a,center))>1e-8
                assert all(sat.dot(n,sat.sub(v,a))<=ln*1e-7 for v in vs);ns.append(n)
                for x,y in zip(f,f[1:]+f[:1]):edges[x,y]+=1;es.append(sat.sub(world[y-1],world[x-1]))
            assert all(v==1 and edges[b,a]==1 for (a,b),v in edges.items())
            solids.append(sat.record(s['name'],vs,ns,es))
        assert sorted(covered)==list(range(len(m['triangles'])))
    art_tops=[]
    for s in solids:
        assert sat.overlap(s,ib) and abs(s['max'][1]-1.73)<1e-7 and s['max'][1]<2.1
        vs=[v for v in s['vertices'] if abs(v[1]-s['max'][1])<1e-7];cx=sum(v[0] for v in vs)/len(vs);cz=sum(v[2] for v in vs)/len(vs)
        vs.sort(key=lambda v:math.atan2(v[2]-cz,v[0]-cx));art_tops.append(vs)
        assert sum(g.polyarea(over(vs,t)) for t in road)>1e-5
    coverage(art_tops,expected)
    # Whole actual triangle surfaces, including nonquery terrain/props, above floor.
    hits=[];scanned=0
    for name in ['world-slice.mesh.json','greenwood-ironveil/scenery.mesh.json','coast-prop-ashen-cut/scenery.mesh.json']:
        for label,t in g.packet_triangles(ROOT/'assets/production/world-slice'/name):
            if max(v[0] for v in t)<9 or min(v[0] for v in t)>70 or max(v[2] for v in t)<1493 or min(v[2] for v in t)>1518:continue
            scanned+=1
            above=g.clip(t,lambda v:v[1]-2.10001)
            if len(above)<3:continue
            for q in expected:
                hit=over(above,q)
                # 3D area catches vertical intrusions whose projected area vanishes.
                area=sum(g.area([hit[0],hit[i],hit[i+1]]) for i in range(1,len(hit)-1)) if len(hit)>2 else 0
                if area>1e-6:hits.append([name,label,area])
    assert not hits,('existing_mesh_intrusions',hits[:20])
    for p in parts:
        if p['position'][1]+p['size'][1]/2<=2.10001:continue
        # Nearby native pieces are axis-aligned; reject unknown rotation rather than assume.
        b=nativebox(p)
        if b['max'][0]<9 or b['min'][0]>70 or b['max'][2]<1493 or b['min'][2]>1518:continue
        assert p['yaw']==0 and not p['wedge'];assert all(g.polyarea(over(rect(b['min'][0],b['max'][0],b['min'][2],b['max'][2]),q))<1e-6 for q in expected),('native_obstruction',p['name'])
    preserved=[]
    for p in subprocess.check_output(['git','ls-tree','-r','--name-only','4c52678'],cwd=ROOT,text=True).splitlines():
        if p.endswith(('.mesh.json','/ground.json')):
            assert (ROOT/p).read_bytes()==subprocess.check_output(['git','show','4c52678:'+p],cwd=ROOT),p;preserved.append(p)
    return dict(status='PASS_OFFLINE_NOT_NATIVE',groundSHA256=sha(HERE/'ground.json'),packetSHA256=sha(ASSET/'scenery.mesh.json'),embeddedDescriptorMatchesGround=True,floorWedges=len(road),floorArea=sum(map(g.polyarea,road)),artSolids=len(solids),headroomCandidateTriangles=scanned,meshIntrusions=hits,widths={'x9':22,'x14':24,'x70':24},seamOldRoad=seam_intervals(oldroad,70),arrivalStreetStep=2.1-street['max'][1],nativeLandingStep=2.1-lb['max'][1],artUndersidePenetration=.03,preservedFiles=preserved,limits=['22/24 widths are Z cross-sections, not perpendicular widths along slanted centerline.','Contact/top coverage is offline geometry, not physics or five-hero traversal.'])
if __name__=='__main__':print(json.dumps(main(),indent=2))
