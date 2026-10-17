"""Independent append-only arch identity gate against ba1aaa1, no recipe import."""
from pathlib import Path
import hashlib,json,subprocess,runpy,math
import numpy as np
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
ARCH={'arch__000','arch__001'}

def main():
    path=ROOT/'assets/production/world-slice/world-slice.mesh.json';raw=path.read_bytes();data=json.loads(raw)
    def old(p):return json.loads(subprocess.check_output(['git','show','ba1aaa1:'+p],cwd=ROOT))
    prior=old('assets/production/world-slice/world-slice.mesh.json');meshes={m['id']:m for m in data['meshes']}
    errors=[]
    def check(ok,label):
        if not ok:errors.append(label)
    check(len(data['meshes'])==37 and set(meshes)=={m['id'] for m in prior['meshes']},'Changed resource identities')
    check(data['placements']==prior['placements'] and len(data['placements'])==116,'Changed placement records')
    collision=json.loads(path.with_name('collision.json').read_bytes())
    check(collision['colliders']==old('assets/production/world-slice/collision.json')['colliders'] and len(collision['colliders'])==413,'Changed colliders')
    check(collision['sourceMeshSha256']==hashlib.sha256(raw).hexdigest(),'Collision hash')
    additions=[];original=[];rows=[]
    for m in prior['meshes']:
        n=meshes[m['id']]
        if m['id'] not in ARCH:check(n==m,'Changed accepted resource '+m['id']);continue
        for key in ('vertices','triangles','faceColors','colors'):
            check(n[key][:len(m[key])]==m[key],'Changed original arch '+key)
        check(len(n['triangles'])<=2000,'Arch chunk triangle budget')
        original.extend(np.asarray(m['vertices'])[np.asarray(m['triangles'])-1])
        added=np.asarray(n['vertices'])[np.asarray(n['triangles'][len(m['triangles']):],dtype=int).reshape(-1,3)-1]
        additions.extend(added);rows.append(dict(meshId=m['id'],originalTriangles=len(m['triangles']),addedTriangles=len(added)))
    triangles=np.asarray(additions);check(0<len(triangles)<=400,'Added triangle budget')
    normals=np.cross(triangles[:,1]-triangles[:,0],triangles[:,2]-triangles[:,0])
    check(bool((np.linalg.norm(normals,axis=1)>1e-8).all()),'Degenerate detail')
    # Crown is bounded at the keystone; low reliefs must each stay on ONE pier.
    for i,t in enumerate(triangles):
        check(bool(np.isfinite(t).all()),'Nonfinite geometry')
        check(bool((np.abs(t[:,0])<=10.9404).all()) and bool((np.abs(t[:,2])<=1.73731).all()),'Footprint extension')
        crown=bool(((t[:,0]>=1.39)&(t[:,0]<=4.61)).all()) and bool((t[:,1]>=22.29).all()) and bool((t[:,1]<=28.50001).all())
        pier=(bool((t[:,0]>=7.8).all()) or bool((t[:,0]<=-7.8).all())) and bool((t[:,1]>=3.9).all()) and bool((t[:,1]<=12.1).all())
        check(crown or pier,'Aperture/envelope violation '+str(i))
    # Every sampled relief point below the localized crown shoulders must project onto old
    # masonry. Original front/back projected faces form the same solid silhouette.
    ot=np.asarray(original);a=ot[:,0,:2];u=ot[:,1,:2]-a;v=ot[:,2,:2]-a
    det=u[:,0]*v[:,1]-u[:,1]*v[:,0];valid=np.abs(det)>1e-8
    support_samples=0
    for i,t in enumerate(triangles):
        samples=list(t)+[(t[j]+t[(j+1)%3])/2 for j in range(3)]+[t.mean(axis=0)]
        for p in samples:
            if p[1]>=24-1e-5:continue
            support_samples+=1;d=p[:2]-a
            s=np.zeros_like(det);q=np.zeros_like(det)
            s[valid]=(d[valid,0]*v[valid,1]-d[valid,1]*v[valid,0])/det[valid]
            q[valid]=(u[valid,0]*d[valid,1]-u[valid,1]*d[valid,0])/det[valid]
            check(bool((valid&(s>=-1e-5)&(q>=-1e-5)&(s+q<=1+1e-5)).any()),'Relief outside old masonry projection '+str(i))
    attachments=[]
    def surface_depths(tris,x,y):
        origin=tris[:,0,:2];u=tris[:,1,:2]-origin;v=tris[:,2,:2]-origin
        det=u[:,0]*v[:,1]-u[:,1]*v[:,0];valid=np.abs(det)>1e-8
        d=np.asarray([x,y])-origin;s=np.zeros_like(det);q=np.zeros_like(det)
        s[valid]=(d[valid,0]*v[valid,1]-d[valid,1]*v[valid,0])/det[valid]
        q[valid]=(u[valid,0]*d[valid,1]-u[valid,1]*d[valid,0])/det[valid]
        hit=valid&(s>=-1e-8)&(q>=-1e-8)&(s+q<=1+1e-8)
        depths=tris[:,0,2]+s*(tris[:,1,2]-tris[:,0,2])+q*(tris[:,2,2]-tris[:,0,2])
        return depths[hit]
    for x,y in [(-8.95,8),(8.95,8),(3,23.7)]:
        olddepths=surface_depths(ot,x,y);newdepths=surface_depths(triangles,x,y)
        interval=[float(newdepths.min()),float(newdepths.max())] if len(newdepths) else []
        supported=bool(interval and ((olddepths>interval[0])&(olddepths<interval[1])).any())
        check(supported,'Actual relief attachment depth '+str((x,y)))
        attachments.append(dict(localXY=[x,y],actualNewGeometryDepthInterval=interval,oldSurfaceInsideRelief=supported))
    helper=runpy.run_path(str(HERE/'check_silhouette.py'));targets=list(helper['ANCHORS'])
    for cx,cz,r in helper['CIRCLES']:
        for x in range(math.ceil(cx-r),math.floor(cx+r)+1,5):
            for z in range(math.ceil(cz-r),math.floor(cz+r)+1,5):
                if (x-cx)**2+(z-cz)**2>r*r:continue
                y=6 if -48<=x<=48 and 1305<=z<=1355 else 2+(1380-z)*.16 if -10<=x<=10 and 1355<z<1380 else 2
                targets.append((x,y+.09,z))
    def blocked_samples(triangles,eye):
        a=triangles[:,0];e1=triangles[:,1]-a;e2=triangles[:,2]-a
        s=np.asarray(eye)-a;q=np.cross(s,e1);blocked=set()
        for index,target in enumerate(targets):
            d=np.asarray(target)-eye;h=np.cross(d,e2);det=np.einsum('ij,ij->i',e1,h)
            valid=np.abs(det)>1e-9;inv=np.zeros_like(det);inv[valid]=1/det[valid]
            u=inv*np.einsum('ij,ij->i',s,h);v=inv*(q@d);t=inv*np.einsum('ij,ij->i',e2,q)
            if (valid&(u>=-1e-8)&(v>=-1e-8)&(u+v<=1+1e-8)&(t>1e-7)&(t<1-1e-7)).any():blocked.add(index)
        return blocked
    world=triangles+np.asarray([0,2,1380]);oldworld=np.asarray(original)+np.asarray([0,2,1380]);visibility=[]
    for eye in [(105,94,1545),(40,12,1510),(40,22,1435)]:
        baseline=blocked_samples(oldworld,eye);blocked=blocked_samples(world,eye);new=blocked-baseline
        check(not new,'Newly blocked previously visible samples '+str(eye))
        visibility.append(dict(camera=eye,samples=len(targets),baselineArchOccluded=sorted(baseline),addedGeometryIntersections=sorted(blocked),newlyOccluded=sorted(new)))
    report=dict(status='OFFLINE_GATE_FAIL' if errors else 'OFFLINE_GATE_PASS',baseline='ba1aaa1',sourceMeshSha256=hashlib.sha256(raw).hexdigest(),checkerSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),preservedMeshes=35,preservedPlacements=116,preservedColliders=413,archChunks=rows,addedTriangles=len(triangles),oldMasonryProjectionSamples=support_samples,attachmentSamples=attachments,visibility=visibility,errors=errors,studioTested=False,limits='Source append-only geometry and finite projection/sightline samples. Not exact volume containment, all-camera, runtime appearance/physics or human art acceptance.')
    (HERE/'gate-clearance.json').write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps(report,indent=2));return 1 if errors else 0

if __name__=='__main__':raise SystemExit(main())
