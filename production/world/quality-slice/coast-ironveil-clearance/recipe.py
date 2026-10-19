"""Subtract reserved city/bridge envelopes from the existing decorative bank only."""
from pathlib import Path
import json, hashlib, subprocess, copy, math
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/coast-ironveil-clearance'
PACK='assets/production/world-slice/coast-prop-composition/scenery.mesh.json'
TARGET='coast_headland_banks__bounded_003'
RECTS=[(370,640,1270,1560),(56,410,1475,1535)]
def sha(b):return hashlib.sha256(b).hexdigest()
def clip(poly,axis,bound,sign):
    result=[]
    for a,b in zip(poly,poly[1:]+poly[:1]):
        da=(a[axis]-bound)*sign;db=(b[axis]-bound)*sign
        if da>=0:result.append(a)
        if (da>=0)!=(db>=0):
            t=da/(da-db);result.append([a[k]+t*(b[k]-a[k]) for k in range(3)])
    return result
def subtract(poly,r):
    rest=poly;outside=[]
    for axis,bound,sign in [(0,r[0],1),(0,r[1],-1),(2,r[2],1),(2,r[3],-1)]:
        piece=clip(rest,axis,bound,-sign)
        if len(piece)>2:outside.append(piece)
        rest=clip(rest,axis,bound,sign)
        if len(rest)<3:break
    return outside
def area(t):
    a=[t[1][k]-t[0][k] for k in range(3)];b=[t[2][k]-t[0][k] for k in range(3)]
    return math.sqrt(sum(x*x for x in [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]))/2
def main():
    raw=subprocess.check_output(['git','show','1e670c0:'+PACK],cwd=ROOT)
    assert sha(raw)=='f31077a0847a4a5db7a5918a411ee9b9ba22cdb0ac18ec686bc18859e10fc4e9'
    OUT.mkdir(parents=True,exist_ok=True)
    baseline=OUT/'before.mesh.json'
    if baseline.exists():assert baseline.read_bytes()==raw
    else:baseline.write_bytes(raw)
    data=json.loads(raw);m=next(m for m in data['meshes'] if m['id']==TARGET);old=copy.deepcopy(m)
    vertices=[];triangles=[];colors=[]
    for face,color in zip(old['triangles'],old['faceColors']):
        pieces=[[old['vertices'][i-1] for i in face]]
        for rect in RECTS:pieces=[piece for p in pieces for piece in subtract(p,rect)]
        for p in pieces:
            for i in range(1,len(p)-1):
                tri=[p[0],p[i],p[i+1]]
                if area(tri)<1e-8:continue
                start=len(vertices)+1;vertices.extend(tri);triangles.append([start,start+1,start+2]);colors.append(color)
    m.update(vertices=vertices,triangles=triangles,faceColors=colors,bounds={'min':[min(v[k] for v in vertices) for k in range(3)],'max':[max(v[k] for v in vertices) for k in range(3)]})
    result=(json.dumps(data,separators=(',',':'))+'\n').encode();(ROOT/PACK).write_bytes(result)
    provpath='assets/production/world-slice/coast-prop-composition/provenance.json'
    provraw=subprocess.check_output(['git','show','1e670c0:'+provpath],cwd=ROOT)
    (OUT/'before.provenance.json').write_bytes(provraw)
    provenance=json.loads(provraw)
    provenance.update(origin='Existing coast composition with one decorative bank clipped against surveyed Ironveil and approach envelopes',source='assets/production/world-slice/coast-ironveil-clearance/before.mesh.json',sourceSha256=sha(raw),sourceProvenance='assets/production/world-slice/coast-ironveil-clearance/before.provenance.json',recipe='production/world/quality-slice/coast-ironveil-clearance/recipe.py',packetSha256=sha(result),modifiedMesh=TARGET)
    (ROOT/provpath).write_bytes((json.dumps(provenance,indent=2)+'\n').encode('utf-8'))
    evidence=dict(status='FILE_GENERATED_NOT_STUDIO_TESTED',base='1e670c0',sourceSha256=sha(raw),packetSha256=sha(result),target=TARGET,subtractXZ=RECTS,oldTriangles=len(old['triangles']),newTriangles=len(triangles),placementsUnchanged=len(data['placements']),otherMeshesUnchanged=19,runtimeAssetIds=None)
    (HERE/'recipe-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(evidence))
if __name__=='__main__':main()
