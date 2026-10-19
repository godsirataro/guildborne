"""Independent reconstruction from emitted native WedgePart data. Offline only."""
from pathlib import Path
import json,math,hashlib,runpy
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
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
    if p['meshId']=='gi_original_retaining_skirt':continue
    m=next(m for m in packet['meshes'] if m['id']==p['meshId']);poly=footprint(m,p);total=area(poly);support=sum(clip(poly,t) for t in shoulders);overlap=sum(clip(poly,t) for t in road)
    ok=abs(total-support)<1e-6 and overlap<1e-7
    if not ok:fail.append(p['name']+' footprint support/road intrusion')
    records.append(dict(name=p['name'],area=total,supportedArea=support,roadOverlap=overlap,passCheck=ok))
source=json.loads((ROOT/'assets/production/world-slice/world-slice.mesh.json').read_text())
for m in packet['meshes']:
    if m['id']=='gi_original_retaining_skirt':continue
    if m!=next(x for x in source['meshes'] if x['id']==m['id']):fail.append(m['id']+' changed reviewed mesh')
report=dict(status='PASS' if not fail else 'FAIL',scope='OFFLINE_NATIVE_GEOMETRY_AND_FULL_PROJECTED_PROP_BOUNDS_NOT_STUDIO',failures=fail,minimumNativeDimension=min(dims),nativeRoadTriangles=len(native_tops),roadArea=sum(area(t) for t in road),props=records,groundSha256=digest(HERE/'ground.json'),runtimeDescriptorSha256=digest(HERE/'runtime-descriptor.json'),packetSha256=digest(A/'scenery.mesh.json'))
(HERE/'independent-geometry.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report,indent=2));assert not fail,fail
