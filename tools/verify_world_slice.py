"""Offline checks of the authored mesh deliverable; not a Studio acceptance test."""
from pathlib import Path
import json,math,hashlib,struct
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/production/world-slice'
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
 result=dict(status='OFFLINE_GEOMETRY_PASS',meshes=len(ids),vertices=vertices,triangles=faces,placements=len(names),instancedTriangles=report['instancedTriangles'],studioTested=False)
 print(json.dumps(result,indent=2))
if __name__=='__main__':main()
