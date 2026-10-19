"""Independent reconstruction from emitted native WedgePart data. Offline only."""
from pathlib import Path
import json,math,hashlib,runpy
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'production/world/quality-slice/greenwood-ironveil'
A=ROOT/'assets/production/world-slice/greenwood-ironveil'
helpers=runpy.run_path(str(HERE/'build_ground.py'));clip=helpers['clip']
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
g=json.loads((HERE/'ground.json').read_text());d=json.loads((HERE/'runtime-descriptor.json').read_text());packet=json.loads((A/'scenery.mesh.json').read_text())
fail=[];native_tops=[];dims=[]
for p in g['parts']:
    size=p['size'];dims.extend(size);r=p['rotation'];c=p['position'];x=[r[0],r[3],r[6]];sgn=1 if x[1]>0 else -1
    face=[]
    for yy,zz in [(-size[1]/2,-size[2]/2),(-size[1]/2,size[2]/2),(size[1]/2,size[2]/2)]:
        v=[c[k]+r[3*k]*sgn*size[0]/2+r[3*k+1]*yy+r[3*k+2]*zz for k in range(3)];face.append(v)
    expected=2.1 if p['collision'] else 1.9
    if max(abs(v[1]-expected) for v in face)>1e-9:fail.append(p['name']+' floor mismatch')
    if p['collision']:native_tops.append(face)
if min(dims)<.05:fail.append('Tiny native dimension')
def area(poly):return abs(sum(a[0]*b[1]-a[1]*b[0] for a,b in zip(poly,poly[1:]+poly[:1])))/2
def footprint(m,p):
    lo=m['bounds']['min'];hi=m['bounds']['max'];cf=p['cframe'];s=p['scale'];out=[]
    for x,z in [(lo[0],lo[2]),(hi[0],lo[2]),(hi[0],hi[2]),(lo[0],hi[2])]:out.append([cf[0]+cf[3]*x*s[0]+cf[5]*z*s[2],cf[2]+cf[9]*x*s[0]+cf[11]*z*s[2]])
    return out
shoulders=[[[v[0],v[2]] for v in t['vertices']] for t in g['topTriangles'] if not t['collision']]
road=[[[v[0],v[2]] for v in t] for t in native_tops]
records=[]
for p in packet['placements']:
    if p['meshId'].startswith('gi_original_'):continue
    m=next(m for m in packet['meshes'] if m['id']==p['meshId']);poly=footprint(m,p);total=area(poly);support=sum(clip(poly,t) for t in shoulders);overlap=sum(clip(poly,t) for t in road)
    ok=abs(total-support)<1e-6 and overlap<1e-7
    if not ok:fail.append(p['name']+' footprint support/road intrusion')
    records.append(dict(name=p['name'],area=total,supportedArea=support,roadOverlap=overlap,passCheck=ok))
source=json.loads((ROOT/'assets/production/world-slice/world-slice.mesh.json').read_text())
for m in packet['meshes']:
    if m['id'].startswith('gi_original_'):continue
    if m!=next(x for x in source['meshes'] if x['id']==m['id']):fail.append(m['id']+' changed reviewed mesh')
structural=[]
for m in packet['meshes']:
    if not m['id'].startswith('gi_original_'):continue
    intrusion=0
    for ids in m['triangles']:
        poly=[m['vertices'][i-1] for i in ids];above=[]
        for a,b in zip(poly,poly[1:]+poly[:1]):
            if a[1]>=2.100001:above.append(a)
            if (a[1]>2.100001)!=(b[1]>2.100001):
                t=(2.100001-a[1])/(b[1]-a[1]);above.append([a[k]+t*(b[k]-a[k]) for k in range(3)])
        if len(above)>=3:intrusion+=sum(clip([[v[0],v[2]] for v in above],t) for t in road)
    if intrusion>1e-6:fail.append(m['id']+' structural road intrusion')
    structural.append(dict(meshId=m['id'],roadIntrusionAboveFloor=intrusion))
solids=json.loads((A/'structural-solids.json').read_text())
for solid in solids:
    m=next(m for m in packet['meshes'] if m['id']==solid['meshId'])
    for tri in m['triangles'][solid['firstTriangle']-1:solid['firstTriangle']-1+solid['triangles']]:
        a,b,c=[m['vertices'][i-1] for i in tri]
        u=[b[k]-a[k] for k in range(3)];v=[c[k]-a[k] for k in range(3)]
        normal=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
        offset=[(a[k]+b[k]+c[k])/3-solid['center'][k] for k in range(3)]
        if sum(normal[k]*offset[k] for k in range(3))<=0:fail.append(solid['name']+' inward face')
report=dict(status='PASS' if not fail else 'FAIL',scope='OFFLINE_NATIVE_GEOMETRY_AND_FULL_PROJECTED_PROP_BOUNDS_NOT_STUDIO',failures=fail,structural=structural,outwardClosedBoxSolids=len(solids),minimumNativeDimension=min(dims),nativeRoadTriangles=len(native_tops),roadArea=sum(area(t) for t in road),props=records,groundSha256=digest(HERE/'ground.json'),runtimeDescriptorSha256=digest(HERE/'runtime-descriptor.json'),packetSha256=digest(A/'scenery.mesh.json'))
(ROOT/'production/world/quality-slice/ironveil-dock/offline-geometry.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report,indent=2));assert not fail,fail
