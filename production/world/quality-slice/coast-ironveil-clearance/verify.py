"""Independent offline geometry review; no Blender/Studio and no author imports."""
import hashlib, json, math, pathlib, subprocess
ROOT = pathlib.Path(__file__).resolve().parents[4]
PACK = 'assets/production/world-slice/coast-prop-composition/scenery.mesh.json'
TARGET = 'coast_headland_banks__bounded_003'
RECTS = [(370,640,1270,1560),(56,410,1475,1535)]
def sub(a,b): return [x-y for x,y in zip(a,b)]
def dot(a,b): return sum(x*y for x,y in zip(a,b))
def cross(a,b): return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def area(poly):
    return sum(math.sqrt(dot(n,n))/2 for n in [cross(sub(poly[i],poly[0]),sub(poly[i+1],poly[0])) for i in range(1,len(poly)-1)]) if len(poly)>2 else 0
def cut(poly,axis,bound,sign):
    result=[]
    for a,b in zip(poly,poly[1:]+poly[:1]):
        da=(a[axis]-bound)*sign; db=(b[axis]-bound)*sign
        if da>=0: result.append(a)
        if (da>=0)!=(db>=0):
            t=da/(da-db);result.append([a[k]+t*(b[k]-a[k]) for k in range(3)])
    return result
def inside(poly,r):
    for ax,b,s in [(0,r[0],1),(0,r[1],-1),(2,r[2],1),(2,r[3],-1)]: poly=cut(poly,ax,b,s)
    return poly
def tris(m): return [[m['vertices'][i-1] for i in f] for f in m['triangles']]
def ray(a,b,t):
    d=sub(b,a);e1=sub(t[1],t[0]);e2=sub(t[2],t[0]);h=cross(d,e2);det=dot(e1,h)
    if abs(det)<1e-10:return None
    s=sub(a,t[0]);u=dot(s,h)/det;q=cross(s,e1);v=dot(d,q)/det;z=dot(e2,q)/det
    return z if u>=-1e-9 and v>=-1e-9 and u+v<=1+1e-9 and 0<=z<=1 else None
def contains(t,p):
    n=cross(sub(t[1],t[0]),sub(t[2],t[0]));ln=math.sqrt(dot(n,n))
    if abs(dot(n,sub(p,t[0])))>ln*1e-6:return False
    return all(dot(cross(sub(b,a),sub(p,a)),n)>=-1e-5*ln for a,b in zip(t,t[1:]+t[:1]))
def triangle_overlap(a,b):
    poly=a[:];n=cross(sub(b[1],b[0]),sub(b[2],b[0]))
    for u,v in zip(b,b[1:]+b[:1]):
        output=[]
        for x,y in zip(poly,poly[1:]+poly[:1]):
            dx=dot(cross(sub(v,u),sub(x,u)),n);dy=dot(cross(sub(v,u),sub(y,u)),n)
            if dx>=0:output.append(x)
            if (dx>=0)!=(dy>=0):
                f=dx/(dx-dy);output.append([x[k]+f*(y[k]-x[k]) for k in range(3)])
        poly=output
    return area(poly)
def transform(v,p):
    c=p['cframe'];v=[v[i]*p['scale'][i] for i in range(3)]
    return [c[i]+sum(c[3+3*i+j]*v[j] for j in range(3)) for i in range(3)]
def main():
    oldraw=subprocess.check_output(['git','show','1e670c0:'+PACK],cwd=ROOT)
    raw=(ROOT/PACK).read_bytes();old=json.loads(oldraw);new=json.loads(raw)
    om={m['id']:m for m in old['meshes']};nm={m['id']:m for m in new['meshes']}
    assert new['placements']==old['placements'] and len(new['placements'])==72
    assert set(om)==set(nm) and len(nm)==20
    assert all(om[k]==nm[k] for k in om if k!=TARGET)
    for m in new['meshes']:
        assert all(len(v)==3 and all(math.isfinite(x) for x in v) for v in m['vertices'])
        assert len(m['faceColors'])==len(m['triangles'])
        assert all(len(f)==3 and all(isinstance(i,int) and 1<=i<=len(m['vertices']) for i in f) for f in m['triangles'])
        assert all(isinstance(i,int) and 1<=i<=len(m['colors']) for i in m['faceColors'])
    assert nm[TARGET]['bounds']=={'min':[min(v[k] for v in nm[TARGET]['vertices']) for k in range(3)],'max':[max(v[k] for v in nm[TARGET]['vertices']) for k in range(3)]}
    assert {k:v for k,v in old.items() if k!='meshes'}=={k:v for k,v in new.items() if k!='meshes'}
    ot=tris(om[TARGET]);nt=tris(nm[TARGET]);assert len(nt)>0
    assigned=[[] for _ in ot]
    for j,t in enumerate(nt):
        assert area(t)>1e-8,('degenerate',j)
        candidates=[i for i,o in enumerate(ot) if all(contains(o,p) for p in t) and nm[TARGET]['colors'][nm[TARGET]['faceColors'][j]-1]==om[TARGET]['colors'][om[TARGET]['faceColors'][i]-1]]
        assert candidates,('not_on_original_same_color_face',j)
        i=candidates[0];assert dot(cross(sub(t[1],t[0]),sub(t[2],t[0])),cross(sub(ot[i][1],ot[i][0]),sub(ot[i][2],ot[i][0])))>0
        assigned[i].append(t)
    overlap=(370,410,1475,1535)
    preserved=[]
    for i,o in enumerate(ot):
        expected=area(o)-sum(area(inside(o,r)) for r in RECTS)+area(inside(o,overlap))
        actual=sum(area(t) for t in assigned[i]);assert abs(expected-actual)<max(1e-5,area(o)*1e-8),(i,expected,actual)
        for j,t in enumerate(assigned[i]):
            for u in assigned[i][j+1:]:assert triangle_overlap(t,u)<1e-5,('duplicated_outside_area',i)
        # Deterministic barycentric probes independently ensure outside coverage.
        count=0
        for a in range(1,20):
            for b in range(1,20-a):
                p=[(a*o[0][k]+b*o[1][k]+(20-a-b)*o[2][k])/20 for k in range(3)]
                if any(r[0]<=p[0]<=r[1] and r[2]<=p[2]<=r[3] for r in RECTS):continue
                assert any(contains(t,p) for t in assigned[i]),('outside_hole',i,p)
                count+=1
        preserved.append({'oldFace1':i+1,'expectedArea':expected,'actualArea':actual,'outsideProbes':count})
    intrusions=[];below_floor_water=[];world=[]
    for p in new['placements']:
        m=nm[p['meshId']]
        for i,t in enumerate(tris(m)):
            t=[transform(v,p) for v in t];world.append(t)
            for r in RECTS:
                if area(inside(t,r))>1e-6:
                    if p['meshId']=='coast_bay_water' and max(v[1] for v in t)<0:below_floor_water.append([p['name'],i+1,r,max(v[1] for v in t)])
                    else:intrusions.append([p['name'],i+1,r])
    assert not intrusions, intrusions[:20]
    cases=[([436,100,1468],[436,0,1468]),([500,100,1495],[500,0,1495]),([500,100,1450],[500,0,1450]),([410,28,1450],[436,8,1468]),([500,48,1535],[436,8,1468])]
    rays=[]
    for a,b in cases:
        hits=[{'face1':i+1,'t':r} for i,t in enumerate(ot) if (r:=ray(a,b,t)) is not None]
        after=[r for t in world if (r:=ray(a,b,t)) is not None]
        assert hits and not after,(a,hits,after)
        rays.append({'from':a,'to':b,'oldHits':hits,'newDatasetHits':after})
    report={'status':'PASS_OFFLINE_GEOMETRY_NATIVE_VISUAL_RETEST_PENDING','oldSHA256':hashlib.sha256(oldraw).hexdigest(),'newSHA256':hashlib.sha256(raw).hexdigest(),'verifierSHA256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'unchangedMeshes':19,'unchangedPlacements':72,'oldTargetTriangles':len(ot),'newTargetTriangles':len(nt),'allDatasetTrianglesChecked':len(world),'protectedRectanglesXZ':RECTS,'intrusions':intrusions,'rays':rays,'perOriginalFacePreservation':preserved,'limitations':['Offline math only; no Studio, collision, visual or device acceptance.','Existing Dataset2 unrelated geometry remains unchanged.']}
    report['unchangedBelowFloorWaterOverlaps']=below_floor_water
    out=pathlib.Path(__file__).with_name('independent-review.json');assert not out.exists(),'Preserve prior reports; rename before rerun.'
    out.write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps({k:v for k,v in report.items() if k not in ['perOriginalFacePreservation','rays']}))
if __name__=='__main__': main()
