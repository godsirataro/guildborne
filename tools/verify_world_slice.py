"""Offline checks of the authored mesh deliverable; not a Studio acceptance test."""
from pathlib import Path
import json,math,hashlib,struct
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/production/world-slice'

def verify_ground(data):
 path=ROOT/'production/world/quality-slice/ground-authoring.json'
 if not path.exists():return
 meta=json.loads(path.read_text(encoding='utf-8'))
 def digest(v):return hashlib.sha256(json.dumps(v,sort_keys=True,separators=(',',':')).encode()).hexdigest()
 lookup={m['id']:m for m in data['meshes']};plookup={p['name']:p for p in data['placements']}
 for mid,value in meta['baselineMeshes'].items():assert digest(lookup[mid])==value,('Changed prior mesh',mid)
 for name,value in meta['baselinePlacements'].items():assert digest(plookup[name])==value,('Moved existing anchor/art',name)
 collision=json.loads((OUT/'collision.json').read_text())
 assert len(collision['colliders'])==413 and digest(collision['colliders'])==meta['baselineCollidersSha256']
 terrain=any(mid.startswith('terrain_') for mid in lookup)
 if terrain:
  assert all(mid.startswith(('terrain_','silhouette_','arrival_')) for mid in set(lookup)-set(meta['baselineMeshes']))
 else:assert set(lookup)-set(meta['baselineMeshes'])==set(meta['originalMeshes'])
 def bounds(p):
  m=lookup[p['meshId']];f=p['cframe'];points=[]
  for x in (m['bounds']['min'][0],m['bounds']['max'][0]):
   for y in (m['bounds']['min'][1],m['bounds']['max'][1]):
    for z in (m['bounds']['min'][2],m['bounds']['max'][2]):
     points.append([f[0]+f[3]*x+f[4]*y+f[5]*z,f[1]+f[6]*x+f[7]*y+f[8]*z,f[2]+f[9]*x+f[10]*y+f[11]*z])
  return [min(v[0] for v in points),max(v[0] for v in points),min(v[2] for v in points),max(v[2] for v in points),min(v[1] for v in points),max(v[1] for v in points)]
 roads={'center':[-12,12,1317,1512],'landing':[-18,18,1496,1530],'westLoop':[-72,-48,1362,1458],'eastLoop':[48,72,1362,1458],'southCross':[-72,72,1438,1462],'northCross':[-72,72,1363,1387],'bossCourt':[-51,51,1302,1358],'wood':[-41,-29,1449,1461],'herbs':[29,41,1449,1461]}
 circles={'boar':[0,1410,53],'captain':[0,1330,42],'scout':[-60,1410,32],'archer':[60,1410,32]}
 def overlaps(a,b):return a[0]<b[1] and a[1]>b[0] and a[2]<b[3] and a[3]>b[2]
 building=[]
 for p in data['placements']:
  if p['meshId'].split('__')[0] in ('stable','house','sawmill'):
   a=bounds(p);building.append([a[0]-2,a[1]+2,a[2]-2,a[3]+2])
 rows=[];props=tris=0
 for p in data['placements']:
  if p['name'] in meta['baselinePlacements'] or p['meshId'].startswith(('terrain_','silhouette_','arrival_')):continue
  a=bounds(p);ground=p['meshId'] in meta['originalMeshes'];m=lookup[p['meshId']]
  assert -110<=a[0]<=a[1]<=110 and 1300<=a[2]<=a[3]<=1500,('Native Island bounds',p['name'],a)
  assert all(not overlaps(a,b) for b in roads.values()),('Road/resource/portal exclusion',p['name'],a)
  gaps={}
  for name,(x,z,radius) in circles.items():
   dx=max(a[0]-x,0,x-a[1]);dz=max(a[2]-z,0,z-a[3]);gaps[name]=math.hypot(dx,dz)-radius
   assert gaps[name]>=0,('Combat envelope',p['name'],name,gaps[name])
  if ground:
   assert abs(a[4]-2.02)<1e-5 and abs(a[5]-2.02)<1e-5,('Ground overlay height',p['name'])
   for face in m['triangles']:
    av,bv,cv=[m['vertices'][i-1] for i in face];u=[bv[i]-av[i] for i in range(3)];v=[cv[i]-av[i] for i in range(3)]
    assert u[2]*v[0]-u[0]*v[2]>0,('Ground must face upward',p['name'])
  else:
   props+=1;assert a[4]==2,('Floating decoration',p['name'])
   assert all(not overlaps(a,b) for b in building),('Building clearance',p['name'])
  tris+=len(m['triangles'])
  rows.append(dict(name=p['name'],meshId=p['meshId'],worldAABB=a,combatEnvelopeMargin=gaps,allRoadPortalResourceExclusionsClear=True,groundSurfaceOnly=ground))
 assert props<=28 and tris<=15000
 report=dict(status='OFFLINE_CLEARANCE_PASS_NOT_CAMERA_OCCLUSION_PROOF',sourceMeshSha256=hashlib.sha256((OUT/'world-slice.mesh.json').read_bytes()).hexdigest(),existingMeshesUnchanged=len(meta['baselineMeshes']),existingPlacementsUnchanged=len(meta['baselinePlacements']),collidersUnchanged=413,addedProps=props,addedInstancedTriangles=tris,exclusionRectangles=roads,combatEnvelopes=circles,placements=rows,studioTested=False)
 (ROOT/'production/world/quality-slice'/('terrain-props-clearance.json' if terrain else 'ground-clearance.json')).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
 print('GROUND_CLEARANCE',props,tris,len(rows))

def main():
 data=json.loads((OUT/'world-slice.mesh.json').read_text());report=json.loads((OUT/'export-report.json').read_text())
 assert data['schemaVersion']==1 and data['previewWorldOrigin']==[0,2,1410]
 ids=set();faces=vertices=0
 for m in data['meshes']:
  assert m['id'] not in ids;ids.add(m['id'])
  assert 0<len(m['triangles'])<=2000 and 3<=len(m['vertices'])<20000
  assert len(m['faceColors'])==len(m['triangles'])
  for p in m['vertices']:assert len(p)==3 and all(math.isfinite(x) and abs(x)<1000 for x in p)
  for c in m['colors']:assert len(c)==3 and all(0<=x<=1 for x in c)
  for f,ci in zip(m['triangles'],m['faceColors']):
   assert len(set(f))==3 and all(type(i)==int and 1<=i<=len(m['vertices']) for i in f)
   assert 1<=ci<=len(m['colors'])
   a,b,c=[m['vertices'][i-1] for i in f];u=[b[i]-a[i] for i in range(3)];v=[c[i]-a[i] for i in range(3)]
   cross=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
   assert sum(x*x for x in cross)>1e-14,(m['id'],f)
  for i in range(3):
   assert m['bounds']['min'][i]==min(v[i] for v in m['vertices'])
   assert m['bounds']['max'][i]==max(v[i] for v in m['vertices'])
  faces+=len(m['triangles']);vertices+=len(m['vertices'])
 names=set()
 for p in data['placements']:
  assert p['meshId'] in ids and p['name'] not in names;names.add(p['name'])
  assert p['scale']==[1,1,1] and len(p['cframe'])==12
  assert all(math.isfinite(x) for x in p['cframe'])
  assert abs(p['cframe'][0])<112 and 1298<=p['cframe'][2]<=1528
 assert len(ids)<=128 and faces<=250000 and vertices<=250000
 for record in json.loads((OUT/'intake.json').read_text()):
  assert record['license']=='CC0-1.0' and record['runtimeId'] is None
  assert hashlib.sha256((ROOT/record['source']).read_bytes()).hexdigest()==record['sourceSha256']
 # GLB export is real mesh geometry and excludes the separate preview-only plinth/lights.
 raw=(OUT/'woodland-threshold.glb').read_bytes();magic,version,total=struct.unpack_from('<4sII',raw)
 assert magic==b'glTF' and version==2 and total==len(raw)
 size,kind=struct.unpack_from('<I4s',raw,12);assert kind==b'JSON'
 gltf=json.loads(raw[20:20+size]);assert gltf['meshes']
 assert not any('PREVIEW_ONLY' in n.get('name','') for n in gltf['nodes'])
 blend=(OUT/'woodland-threshold.blend').read_bytes()
 if blend.startswith(b'\x28\xb5\x2f\xfd'):
  from compression import zstd # Python 3.14; Blender 5.2 saves Zstandard-compressed files.
  blend=zstd.decompress(blend)
 assert blend.startswith(b'BLENDER')
 assert (OUT/'woodland-threshold.png').read_bytes().startswith(b'\x89PNG\r\n\x1a\n')
 for name in ['world-slice.mesh.json','woodland-threshold.blend','woodland-threshold.glb','woodland-threshold.png']:
  assert hashlib.sha256((OUT/name).read_bytes()).hexdigest()==report['files'][name]['sha256']
 assert report['uniqueTriangles']==faces and report['studioTested'] is False
 verify_ground(data)
 if any(m['id'].startswith('terrain_') for m in data['meshes']):
  import runpy
  assert runpy.run_path(str(ROOT/'production/world/quality-slice/check_terrain_composition.py'))['main']()==0
 if any(m['id'].startswith('silhouette_') for m in data['meshes']):
  import runpy
  assert runpy.run_path(str(ROOT/'production/world/quality-slice/check_silhouette.py'))['main']()==0
 # Arrival checker is mandatory: omitting the sign must not bypass surface checks.
 if any(m['id'].startswith(('terrain_arrival_','arrival_')) for m in data['meshes']):
  import runpy
  assert runpy.run_path(str(ROOT/'production/world/quality-slice/check_arrival.py'))['main']()==0
 result=dict(status='OFFLINE_GEOMETRY_PASS',meshes=len(ids),vertices=vertices,triangles=faces,placements=len(names),instancedTriangles=report['instancedTriangles'],studioTested=False)
 print(json.dumps(result,indent=2))
if __name__=='__main__':main()
