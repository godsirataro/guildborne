"""Independent six-prop proof. Offline geometry only; never executes Blender/Studio."""
from pathlib import Path
import ast,json,math,hashlib,sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
# Import only pure geometry function definitions, avoiding prior validators' writes.
ns={'math':math}
tree=ast.parse((HERE.parent/'bespoke-spire/validate_geometry.py').read_text())
exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef)],type_ignores=[]),'prior_geometry','exec'),ns)
clip,height,bounds,intersect,area=[ns[k] for k in ['clip','height','bounds','intersect','area']]
rayns={}
tree=ast.parse((HERE.parent/'bespoke-spire/verify_architecture.py').read_text())
exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in ['sub','dot','cross','hit']],type_ignores=[]),'prior_ray','exec'),rayns)
hit=rayns['hit']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def world(p,m):
 f=p['cframe'];s=p.get('scale',[1,1,1])
 return [[f[i]+sum(f[3+i*3+j]*v[j]*s[j] for j in range(3)) for i in range(3)] for v in m['vertices']]
def subtract(poly,window):
 if area(window)<0:window=list(reversed(window))
 remaining=poly;outside=[]
 for a,b in zip(window,window[1:]+window[:1]):
  if not remaining:break
  inside=[];out=[]
  for p,q in zip(remaining,remaining[1:]+remaining[:1]):
   dp=ns['cross'](a,b,p);dq=ns['cross'](a,b,q)
   (inside if dp>=0 else out).append(p)
   if (dp>=0)!=(dq>=0):
    t=dp/(dp-dq);r=(p[0]+t*(q[0]-p[0]),p[1]+t*(q[1]-p[1]));inside.append(r);out.append(r)
  if len(out)>=3 and abs(area(out))>1e-9:outside.append(out)
  remaining=inside
 return outside

def main():
 source=ROOT/'assets/production/world-slice/bespoke-spire/scenery.mesh.json'
 path=ROOT/'assets/production/world-slice/coast-prop-composition/scenery.mesh.json'
 assert sha(source)=='148ba821817101a0372d851f557d4c7593a594295814f0e20da194924adfb3ae'
 old=json.loads(source.read_text());new=json.loads(path.read_text())
 allowed={'CorridorScenery_'+s for s in ['010','009','007','044','015','013']}
 assert new['meshes']==old['meshes'];meshes={m['id']:m for m in new['meshes']}
 op={p['name']:p for p in old['placements']};np={p['name']:p for p in new['placements']}
 assert len(op)==len(np)==len(new['placements'])==72 and op.keys()==np.keys()
 changed={k for k in op if op[k]!=np[k]};assert changed==allowed,changed
 for k in allowed:
  assert {a:b for a,b in op[k].items() if a not in ['cframe','scale']}=={a:b for a,b in np[k].items() if a not in ['cframe','scale']}
 locked=json.loads((HERE.parent/'corridor-landforms/preserved-inputs.json').read_text())['sha256']
 assert all(sha(ROOT/p)==h for p,h in locked.items())
 groundpath=HERE.parent/'continuous-corridor/ground.json';g=json.loads(groundpath.read_text())
 assert sha(groundpath)=='398a440048136c1e81f39f0ac0f40c72b3ecdfb442777a47c490bf678daa7b35'
 assert len(g['parts'])==444 and len(g['walkCenterline'])==38
 floors=[(t['vertices'],bounds(t['vertices']),t['collision']) for t in g['topTriangles']]
 unique=sum(len(m['triangles']) for m in meshes.values());instanced=sum(len(meshes[p['meshId']]['triangles']) for p in np.values())
 assert unique==11330 and instanced==40006 and len(meshes)==20
 legacy=json.loads((ROOT/'assets/production/world-slice/continuous-corridor/scenery.mesh.json').read_text())
 lp={p['name']:p for p in legacy['placements'] if p['meshId']!='corridor_original_cliff'}
 assert len(lp)==57 and all(np[k]==v for k,v in lp.items() if k not in allowed)
 terrain=list(floors)
 for p in np.values():
  if not p['meshId'].startswith(('landforms_west','landforms_east','coast_headland')):continue
  m=meshes[p['meshId']];vs=world(p,m)
  for ids in m['triangles']:
   t=[vs[i-1] for i in ids]
   if abs(area([(v[0],v[2]) for v in t]))>1e-8:terrain.append((t,bounds(t),False))
 issues=[];supports=[];allfaces=[];road_tests=0
 for k in sorted(allowed):
  p=np[k];m=meshes[p['meshId']];verts=world(p,m);ff=[[verts[i-1] for i in ids] for ids in m['triangles']];allfaces.extend((k,t) for t in ff)
  support_verts=[v for v,local in zip(verts,m['vertices']) if local[1]<1e-7] if k=='CorridorScenery_010' else verts
  bb=bounds(support_verts);rect=[(bb[0],bb[2]),(bb[1],bb[2]),(bb[1],bb[3]),(bb[0],bb[3])]
  # Conservative full mesh rectangle at lowest vertex: includes root/support area
  # and canopy overhang. Piecewise-affine terrain extrema are exact at clip vertices.
  bottom=min(v[1] for v in verts);overlaps=[];uncovered=[rect]
  for floor,fb,_ in terrain:
   if not intersect(bb,fb):continue
   poly=clip(rect,[(v[0],v[2]) for v in floor])
   if len(poly)<3:continue
   uncovered=[r for u in uncovered for r in subtract(u,[(v[0],v[2]) for v in floor])];overlaps.extend(height(floor,q) for q in poly)
  needed=abs(area(rect));coverage=needed-sum(abs(area(u)) for u in uncovered);supported=bool(overlaps) and coverage>=needed-1e-5 and bottom-max([min(overlaps)])<=.03
  result=dict(name=k,method=('Tree basal trunk vertices bounding rectangle, excludes canopy' if k=='CorridorScenery_010' else 'Conservative full mesh bounding rectangle at basal plane')+'; exact terrain triangle clipping and polygon subtraction coverage',bottom=bottom,rectangleArea=needed,coveredArea=coverage,terrainMin=min(overlaps) if overlaps else None,terrainMax=max(overlaps) if overlaps else None,maximumGap=bottom-min(overlaps) if overlaps else None,maximumBurial=max(overlaps)-bottom if overlaps else None,status='PASS' if supported else 'FAIL')
  supports.append(result)
  if not supported:issues.append(['support',k])
  for t in ff:
   bb=bounds(t);poly=[(v[0],v[2]) for v in t]
   if intersect(bb,(-180,10000,-72,118)) and clip(poly,[(-179.9999,-71.9999),(10000,-71.9999),(10000,117.9999),(-179.9999,117.9999)]):issues.append(['private',k])
   for floor,fb,collision in floors:
    if not collision or not intersect(bb,fb):continue
    overlap=clip(poly,[(v[0],v[2]) for v in floor])
    if not overlap:continue
    road_tests+=1;delta=max(height(t,q)-height(floor,q) for q in overlap)
    if delta>-.025:issues.append(['road',k,delta])
 rays=[]
 for name,eye in [('native_road_eye',[-320,11,-250]),('spire_reveal',[-336.382089,11.819104,102.214917])]:
  for x in [-570,-565,-560]:
   for y in [40,65,95]:
    target=[x,y,460];d=[target[i]-eye[i] for i in range(3)]
    hits=[k for k,t in allfaces if (h:=hit(eye,d,t)) is not None and h<1]
    rays.append(dict(camera=name,target=target,changedPropHits=sorted(set(hits))))
    if hits:issues.append(['spire-sightline',name,target,sorted(set(hits))])
 report=dict(status='FAIL' if issues else 'PASS',scope='INDEPENDENT_OFFLINE_GEOMETRY_NOT_STUDIO_OR_HUMAN_ART',packetSha256=sha(path),sourceSha256=sha(source),verifierSha256=sha(Path(__file__)),exactRetainedMeshes=20,exactRetainedPlacements=66,originalPropsRetainedExactly=51,originalPropTransformExceptions=sorted(allowed),uniqueTriangles=unique,instancedTriangles=instanced,placements=72,groundParts=444,navigationNodes=38,protectedInputHashes=len(locked),footprintSupport=supports,roadTriangleIntersections=road_tests,sightlineScope='18 segment rays against changed props only; unchanged geometry baseline preserved, does not certify every screen pixel unobstructed',sightlineRays=rays,issues=issues,studio='PENDING_CONTROLLER',humanApproval=False)
 out=HERE/(sys.argv[1] if len(sys.argv)>1 else 'independent-review.json')
 if out.exists():raise FileExistsError('Preserve previous review; choose a new report filename')
 out.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report,indent=2));return int(bool(issues))
if __name__=='__main__':sys.exit(main())
