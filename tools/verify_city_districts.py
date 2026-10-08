"""Reimport both interchange formats and compare geometry to native-export bounds."""
from pathlib import Path
import bpy,json,hashlib
from mathutils import Vector
out=Path(__file__).resolve().parents[1]/'assets/uat01/city-districts'
manifest=json.loads((out/'manifest.json').read_text());report=[]
for city in manifest:
 for ext in ['fbx','glb']:
  bpy.ops.wm.read_factory_settings(use_empty=True);path=out/(city['id']+'.'+ext)
  if ext=='fbx':bpy.ops.import_scene.fbx(filepath=str(path))
  else:bpy.ops.import_scene.gltf(filepath=str(path))
  objects=[o for o in bpy.context.scene.objects if o.type=='MESH'];assert len(objects)==city['parts'],path.name
  points=[];triangles=0
  for obj in objects:
   obj.data.calc_loop_triangles();triangles+=len(obj.data.loop_triangles);points.extend(obj.matrix_world@Vector(v)for v in obj.bound_box)
  bounds=[min(p[i]for p in points)for i in range(3)]+[max(p[i]for p in points)for i in range(3)]
  assert triangles==city['triangles'],path.name
  assert max(abs(a-b)for a,b in zip(bounds,city['bounds']))<.01,(path.name,bounds,city['bounds'])
  report.append(dict(file=path.name,parts=len(objects),triangles=triangles,bounds=bounds,sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
(out/'roundtrip-report.json').write_text(json.dumps(report,indent=2)+'\n');print('CITY_DISTRICT_ROUNDTRIP_PASS',len(report))
