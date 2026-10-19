"""Independent quarry boundary review. Does not import the author recipe."""
import hashlib, importlib.util, json, math, pathlib, subprocess
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[3]
BASE='432098a5529d8d20f361156c4bf587763bd300d6'
PACK='assets/production/world-slice/coast-prop-composition/scenery.mesh.json'
TARGET='coast_headland_banks__bounded_003'
s=importlib.util.spec_from_file_location('prior_independent',HERE.parent/'coast-ironveil-clearance'/'verify.py')
g=importlib.util.module_from_spec(s);s.loader.exec_module(g)
def sha(b):return hashlib.sha256(b).hexdigest()
def main():
    oldbytes=subprocess.check_output(['git','show',BASE+':'+PACK],cwd=ROOT)
    newbytes=(ROOT/PACK).read_bytes();old=json.loads(oldbytes);new=json.loads(newbytes)
    assert {k:v for k,v in old.items() if k!='meshes'}=={k:v for k,v in new.items() if k!='meshes'}
    assert len(new['placements'])==72 and len(new['meshes'])==20
    om={m['id']:m for m in old['meshes']};nm={m['id']:m for m in new['meshes']}
    assert list(om)==list(nm)
    assert all(om[k]==nm[k] for k in om if k!=TARGET)
    before=om[TARGET];after=nm[TARGET]
    for k in ['vertices','triangles','colors','faceColors']:assert after[k][:len(before[k])]==before[k],('old_prefix_changed',k)
    assert set(after)==set(before)
    for k in set(before)-{'vertices','triangles','colors','faceColors','bounds'}:assert before[k]==after[k]
    total=sum(len(m['triangles']) for m in new['meshes']);assert total<=12000,('budget',total)
    for m in new['meshes']:
        assert len(m['triangles'])==len(m['faceColors'])
        assert all(len(v)==3 and all(math.isfinite(x) for x in v) for v in m['vertices'])
        assert all(len(t)==3 and all(type(i)==int and 1<=i<=len(m['vertices']) for i in t) for t in m['triangles'])
        assert all(type(i)==int and 1<=i<=len(m['colors']) for i in m['faceColors'])
        assert all(len(c)==3 and all(0<=x<=1 for x in c) for c in m['colors'])
    assert after['bounds']=={'min':[min(v[k] for v in after['vertices']) for k in range(3)],'max':[max(v[k] for v in after['vertices']) for k in range(3)]}
    added=g.tris(after)[len(before['triangles']):];assert added,'No closure faces added'
    norms=[]
    for i,t in enumerate(added):
        assert g.area(t)>1e-7,('degenerate',i)
        for r in g.RECTS:
            inset=(r[0]+1e-5,r[1]-1e-5,r[2]+1e-5,r[3]-1e-5)
            assert g.area(g.inside(t,inset))<1e-7,('protected_interior',i,r)
        n=g.cross(g.sub(t[1],t[0]),g.sub(t[2],t[0]));mid=[sum(p[k] for p in t)/3 for k in range(3)]
        # Identify city boundary and inward direction without author metadata.
        choices=[]
        for r in g.RECTS:
            for axis,bound,direction in [(0,r[0],1),(0,r[1],-1),(2,r[2],1),(2,r[3],-1)]:
                other=2 if axis==0 else 0;lo,hi=(r[2:4] if axis==0 else r[:2])
                if lo-1e-5<=mid[other]<=hi+1e-5:
                    choices.append((abs(mid[axis]-bound),axis,direction))
        assert choices,('no_boundary',i)
        distance,axis,direction=min(choices)
        assert distance<=8,('not_bounded_closure',i,distance)
        assert n[axis]*direction>1e-7,('backfacing_reserved_area',i,n,axis,direction)
        norms.append({'addedFace1':i+1,'normal':n,'nearestBoundaryDistance':distance})
    # Independent boundary recovery from preserved triangles, including T-junction
    # subdivisions. Check every positive-height cut edge's full skirt area.
    coverage=[];seen=set();gaps=[]
    for tri in g.tris(before):
        for a,b in zip(tri,tri[1:]+tri[:1]):
            key=tuple(sorted(tuple(round(x,7) for x in v) for v in (a,b)))
            if key in seen or max(a[1],b[1])<=0:continue
            for r in g.RECTS:
                for axis,bound in [(0,r[0]),(0,r[1]),(2,r[2]),(2,r[3])]:
                    if not (abs(a[axis]-bound)<1e-6 and abs(b[axis]-bound)<1e-6):continue
                    other=2 if axis==0 else 0
                    if abs(a[other]-b[other])<1e-7:continue
                    lo,hi=(r[2:4] if axis==0 else r[:2])
                    d=b[other]-a[other]
                    ts=sorted([(lo-a[other])/d,(hi-a[other])/d]);t0=max(0,ts[0]);t1=min(1,ts[1])
                    if t1-t0<1e-8:continue
                    ca=[a[k]+t0*(b[k]-a[k]) for k in range(3)];cb=[a[k]+t1*(b[k]-a[k]) for k in range(3)]
                    mid=[(ca[k]+cb[k])/2 for k in range(3)]
                    if any(q[0]+1e-6<mid[0]<q[1]-1e-6 and q[2]+1e-6<mid[2]<q[3]-1e-6 for q in g.RECTS):continue
                    seen.add(key)
                    aa=[*ca];bb=[*cb];aa[1]=-14;bb[1]=-14
                    expected=[ca,cb,bb,aa];pieces=[[ca,cb,bb],[ca,bb,aa]]
                    expected_area=g.area(expected)
                    onplane=[t for t in added if all(abs(v[axis]-bound)<1e-6 for v in t)]
                    covered=sum(g.triangle_overlap(p,t) for p in pieces for t in onplane)
                    if abs(expected_area-covered)>=max(1e-4,expected_area*1e-7):gaps.append((ca,cb,expected_area,covered))
                    coverage.append({'a':ca,'b':cb,'expectedArea':expected_area,'coveredArea':covered})
    assert coverage,'No above-floor boundary closure checked'
    assert not gaps,('boundary_gaps_or_overlaps',gaps)
    # Regression rays and all placed geometry use actual placement transforms.
    world=[ [g.transform(v,p) for v in t] for p in new['placements'] for t in g.tris(nm[p['meshId']]) ]
    rays=[]
    for a,b in [([436,100,1468],[436,0,1468]),([500,100,1495],[500,0,1495]),([500,100,1450],[500,0,1450]),([410,28,1450],[436,8,1468]),([500,48,1535],[436,8,1468])]:
        hits=[h for t in world if (h:=g.ray(a,b,t)) is not None];assert not hits,(a,hits)
        rays.append({'from':a,'to':b,'hits':hits})
    report={'status':'PASS_OFFLINE_GEOMETRY_NATIVE_AND_VISUAL_PENDING','baselineCommit':BASE,'baselineSHA256':sha(oldbytes),'packetSHA256':sha(newbytes),'verifierSHA256':sha(pathlib.Path(__file__).read_bytes()),'helperSHA256':sha(pathlib.Path(g.__file__).read_bytes()),'unchangedMeshes':19,'unchangedPlacements':72,'oldTargetFaces':len(before['triangles']),'addedFaces':len(added),'uniqueTriangles':total,'instancedTriangles':len(world),'rays':rays,'faceNormals':norms,'limitations':['No native Studio acceptance.','Geometry checks alone do not certify visual polish or watertight full island.']}
    report['boundaryCoverage']=coverage
    path=HERE/'independent-review.json';assert not path.exists(),'Preserve prior review before rerun'
    path.write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps({k:v for k,v in report.items() if k not in ('faceNormals','rays')}))
if __name__=='__main__':main()
