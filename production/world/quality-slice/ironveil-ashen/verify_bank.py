"""Independent retained triangle and cap-area proof; no author imports."""
import importlib.util,json,pathlib,hashlib,math,collections
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
s=importlib.util.spec_from_file_location('geom',HERE.parent/'coast-ironveil-clearance/verify.py');g=importlib.util.module_from_spec(s);s.loader.exec_module(g)
TARGET='coast_headland_banks__bounded_003';R=(636,918,1489,1523)
def main():
    source=ROOT/'assets/production/world-slice/coast-prop-composition/scenery.mesh.json';packet=ROOT/'assets/production/world-slice/coast-prop-ashen-cut/scenery.mesh.json';evpath=HERE.parent/'coast-prop-ashen-cut/recipe-evidence.json'
    old=json.loads(source.read_bytes());new=json.loads(packet.read_bytes());ev=json.loads(evpath.read_bytes());om={m['id']:m for m in old['meshes']};nm={m['id']:m for m in new['meshes']}
    assert list(om)==list(nm) and all(om[k]==nm[k] for k in om if k!=TARGET)
    assert {k:v for k,v in old.items() if k!='meshes'}=={k:v for k,v in new.items() if k!='meshes'} and len(new['placements'])==72
    for m in new['meshes']:
        assert len(m['faceColors'])==len(m['triangles'])
        assert all(len(v)==3 and all(math.isfinite(x) for x in v) for v in m['vertices'])
        assert all(len(t)==3 and all(type(i)==int and 1<=i<=len(m['vertices']) for i in t) for t in m['triangles'])
        assert all(type(c)==int and 1<=c<=len(m['colors']) for c in m['faceColors'])
    ot=g.tris(om[TARGET]);nt=g.tris(nm[TARGET]);assigned=collections.defaultdict(list);capfaces=[];mapped=set()
    for rec in ev['faceMap']:
        j=rec['outputFace']-1;assert j not in mapped;mapped.add(j);t=nt[j];assert g.area(t)>1e-8
        if rec.get('sourceFace') is not None:
            i=rec['sourceFace']-1;o=ot[i];assert all(g.contains(o,v) for v in t),('changed_original_plane',j)
            assert nm[TARGET]['colors'][nm[TARGET]['faceColors'][j]-1]==om[TARGET]['colors'][om[TARGET]['faceColors'][i]-1]
            assert g.dot(g.cross(g.sub(t[1],t[0]),g.sub(t[2],t[0])),g.cross(g.sub(o[1],o[0]),g.sub(o[2],o[0])))>0
            assigned[i].append(t)
        else:capfaces.append(j)
    assert mapped==set(range(len(nt)))
    for i,o in enumerate(ot):
        expected=g.area(o)-g.area(g.inside(o,R));actual=sum(g.area(t) for t in assigned[i]);assert abs(expected-actual)<max(1e-5,g.area(o)*1e-8),(i,expected,actual)
        for j,t in enumerate(assigned[i]):
            for u in assigned[i][j+1:]:assert g.triangle_overlap(t,u)<1e-5
    caps=[];seen=set()
    for seg in ev['capSegments']:
        a,b=seg['a'],seg['b'];aa=a[:];bb=b[:];aa[1]=bb[1]=-40;quad=[a,b,bb,aa];pieces=[[a,b,bb],[a,bb,aa]];faces=[n-1 for n in seg['outputFaces']]
        for j in faces:
            assert j in capfaces and j not in seen;seen.add(j);t=nt[j];n=g.cross(g.sub(t[1],t[0]),g.sub(t[2],t[0]))
            assert all(abs(v[seg['axis']]-seg['bound'])<1e-7 for v in t)
            assert n[seg['axis']]*seg['inwardSign']>0
            assert all(sum(g.triangle_overlap(t,p) for p in pieces)>=g.area(t)-1e-5 for _ in [0])
        area=sum(g.area(nt[j]) for j in faces);assert abs(area-g.area(quad))<1e-5
        for k,j in enumerate(faces):
            for other in faces[k+1:]:assert g.triangle_overlap(nt[j],nt[other])<1e-5
        caps.append({'a':a,'b':b,'area':area,'faces':len(faces)})
    assert seen==set(capfaces)
    # Topological coverage: every retained cut edge must have a full cap to Y-40.
    captri=[nt[j] for j in capfaces];boundarychecks=0
    for i,parts in assigned.items():
        for t in parts:
            for a,b in zip(t,t[1:]+t[:1]):
                for ax,bound in [(0,R[0]),(0,R[1]),(2,R[2]),(2,R[3])]:
                    if abs(a[ax]-bound)>1e-6 or abs(b[ax]-bound)>1e-6 or abs(a[2 if ax==0 else 0]-b[2 if ax==0 else 0])<1e-7:continue
                    mid=[(a[k]+b[k])/2 for k in range(3)];other=2 if ax==0 else 0;lo,hi=R[2:] if ax==0 else R[:2]
                    if not lo<mid[other]<hi:continue
                    aa=a[:];bb=b[:];aa[1]=bb[1]=-40;pairs=[[a,b,bb],[a,bb,aa]];expected=sum(g.area(p) for p in pairs)
                    covered=sum(g.triangle_overlap(p,c) for p in pairs for c in captri if all(abs(v[ax]-bound)<1e-6 for v in c))
                    assert abs(expected-covered)<max(1e-5,expected*1e-7),('missing_cap',a,b,expected,covered);boundarychecks+=1
    protected=[(596,914,1493,1519),(370.00001,639.99999,1270.00001,1559.99999),(56.00001,409.99999,1475.00001,1534.99999)]
    hits=[];checked=0
    for p in new['placements']:
        for i,t in enumerate(g.tris(nm[p['meshId']])):
            t=[g.transform(v,p) for v in t];checked+=1
            if max(v[1] for v in t)<2.1-1e-6:continue
            for r in protected:
                clipped=g.inside(t,r);clipped=g.cut(clipped,1,2.1-1e-6,1)
                if g.area(clipped)>1e-6:hits.append([p['name'],i+1,r])
    assert not hits,hits[:12]
    report={'status':'PASS_OFFLINE_BANK_REPLACEMENT','sourceSHA256':hashlib.sha256(source.read_bytes()).hexdigest(),'packetSHA256':hashlib.sha256(packet.read_bytes()).hexdigest(),'verifierSHA256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'oldTargetFaces':len(ot),'newTargetFaces':len(nt),'capFaces':len(capfaces),'caps':caps,'boundaryCoverageChecks':boundarychecks,'placedTrianglesChecked':checked,'protectedAboveFloorHits':hits,'unchangedMeshes':19,'unchangedPlacements':72,'limitations':['Original terrain is globally open; exact cap strip coverage is not global closed-manifold proof.','Nonquery decorations included geometrically, but no native visibility, collision, party or performance acceptance.']}
    out=HERE/'independent-bank.json';assert not out.exists();out.write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps(report))
if __name__=='__main__':main()
