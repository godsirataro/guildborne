"""Close the cleared coast bank's exposed edges with original quarry rock strata."""
from pathlib import Path
import collections,hashlib,json,math,subprocess
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
ASSETS=ROOT/'assets/production/world-slice/ironveil-quarry-edge'
PACK='assets/production/world-slice/coast-prop-composition/scenery.mesh.json'
TARGET='coast_headland_banks__bounded_003'
RECTS=[(370,640,1270,1560),(56,410,1475,1535)]
BASE='7f392a58f8b550383e5e1278c8c0b9627453960c'
def digest(b):return hashlib.sha256(b).hexdigest()
def cut(poly,axis,bound,sign):
    out=[]
    for a,b in zip(poly,poly[1:]+poly[:1]):
        da=(a[axis]-bound)*sign;db=(b[axis]-bound)*sign
        if da>=0:out.append(a)
        if (da>=0)!=(db>=0):out.append([a[k]+da/(da-db)*(b[k]-a[k]) for k in range(3)])
    return out
def normal(t):
    a=[t[1][k]-t[0][k] for k in range(3)];b=[t[2][k]-t[0][k] for k in range(3)]
    return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def main():
    raw=subprocess.check_output(['git','show',BASE+':'+PACK],cwd=ROOT)
    assert digest(raw)=='0a2dd8468029be8c7e9f829666be1413bd9d450b12a25f45beaec2c230480296'
    ASSETS.mkdir(parents=True,exist_ok=True);(ASSETS/'before.mesh.json').write_bytes(raw)
    data=json.loads(raw);m=next(m for m in data['meshes'] if m['id']==TARGET)
    edges=collections.defaultdict(list)
    for face in m['triangles']:
        v=[m['vertices'][i-1] for i in face]
        for a,b in zip(v,v[1:]+v[:1]):
            key=tuple(sorted(tuple(round(x,6) for x in p) for p in [a,b]));edges[key].append((a,b))
    selected=[];seen=set()
    for es in edges.values():
        if len(es)!=1:continue
        a,b=es[0]
        if max(a[1],b[1])<=0:continue
        for r in RECTS:
            for axis,bound,other,lo,hi,sign in [(0,r[0],2,r[2],r[3],1),(0,r[1],2,r[2],r[3],-1),(2,r[2],0,r[0],r[1],1),(2,r[3],0,r[0],r[1],-1)]:
                if abs(a[axis]-bound)>1e-6 or abs(b[axis]-bound)>1e-6 or abs(b[other]-a[other])<1e-8:continue
                # A triangulation edge may cross the mask corner without a vertex there.
                breaks=[0.,1.]
                for rr in RECTS:
                    for level in ([rr[0],rr[1]] if other==0 else [rr[2],rr[3]]):
                        t=(level-a[other])/(b[other]-a[other])
                        if 0<t<1:breaks.append(t)
                breaks=sorted(set(breaks))
                for t0,t1 in zip(breaks,breaks[1:]):
                    aa=[a[k]+t0*(b[k]-a[k]) for k in range(3)];bb=[a[k]+t1*(b[k]-a[k]) for k in range(3)]
                    mid=[(aa[k]+bb[k])/2 for k in range(3)]
                    if not lo-1e-6<=mid[other]<=hi+1e-6 or max(aa[1],bb[1])<=0:continue
                    inside=lambda p:any(rr[0]<p[0]<rr[1] and rr[2]<p[2]<rr[3] for rr in RECTS)
                    front=mid.copy();back=mid.copy();front[axis]+=sign*.001;back[axis]-=sign*.001
                    if not inside(front) or inside(back):continue
                    key=tuple(sorted(tuple(round(x,6) for x in p) for p in [aa,bb]))
                    if key not in seen:seen.add(key);selected.append((aa,bb,axis,sign))
    oldCount=len(m['triangles']);colorStart=len(m['colors'])
    # Cool quarry stones echo native Ironveil rocks; broad beds avoid noisy stripes.
    palette=[[.28,.32,.33],[.40,.44,.44],[.46,.49,.47],[.37,.42,.43],[.50,.52,.48],[.43,.47,.47]]
    m['colors'].extend(palette)
    for a,b,axis,sign in selected:
        poly=[a,b,[b[0],-14,b[2]],[a[0],-14,a[2]]]
        for band,(low,high) in enumerate(zip([-14,0,12,26,42,60],[0,12,26,42,60,100])):
            piece=cut(cut(poly,1,low,1),1,high,-1)
            for i in range(1,len(piece)-1):
                tri=[piece[0],piece[i],piece[i+1]];n=normal(tri)
                if sum(x*x for x in n)<1e-14:continue
                if n[axis]*sign<0:tri.reverse()
                start=len(m['vertices'])+1;m['vertices'].extend(tri);m['triangles'].append([start,start+1,start+2]);m['faceColors'].append(colorStart+band+1)
    m['bounds']={'min':[min(v[k] for v in m['vertices']) for k in range(3)],'max':[max(v[k] for v in m['vertices']) for k in range(3)]}
    assert sum(len(x['triangles']) for x in data['meshes'])<=12000
    out=(json.dumps(data,separators=(',',':'))+'\n').encode();(ROOT/PACK).write_bytes(out)
    provpath='assets/production/world-slice/coast-prop-composition/provenance.json';provraw=subprocess.check_output(['git','show',BASE+':'+provpath],cwd=ROOT)
    (ASSETS/'before.provenance.json').write_bytes(provraw);prov=json.loads(provraw)
    prov.update(origin='Existing cleared coast with original quarry rock closure faces on the cut boundary',source='assets/production/world-slice/ironveil-quarry-edge/before.mesh.json',sourceSha256=digest(raw),sourceProvenance='assets/production/world-slice/ironveil-quarry-edge/before.provenance.json',recipe='production/world/quality-slice/ironveil-quarry-edge/recipe.py',packetSha256=digest(out))
    (ROOT/provpath).write_bytes((json.dumps(prov,indent=2)+'\n').encode())
    evidence={'status':'FILE_GENERATED_NATIVE_PENDING','base':BASE,'sourceSha256':digest(raw),'packetSha256':digest(out),'boundarySegments':selected,'oldTargetTriangles':oldCount,'newTargetTriangles':len(m['triangles']),'totalUniqueTriangles':sum(len(x['triangles']) for x in data['meshes']),'placements':len(data['placements']),'runtimeAssetIds':None}
    (HERE/'recipe-evidence.json').write_bytes((json.dumps(evidence,indent=2)+'\n').encode());print(json.dumps({k:v for k,v in evidence.items() if k!='boundarySegments'}))
if __name__=='__main__':main()
