"""Read-only Blender geometry diagnosis; writes only the JSON audit report."""
import bpy,json,bmesh
from pathlib import Path
root=Path(__file__).resolve().parents[3]
out=root/'assets/production/world-slice'
rows=[]
for asset in ['stable','house','sawmill','arch','bridge']:
 bpy.ops.wm.read_factory_settings(use_empty=True)
 bpy.ops.import_scene.fbx(filepath=str(out/'source'/f'{asset}.fbx'),use_anim=False)
 for obj in bpy.context.scene.objects:
  if obj.type!='MESH':continue
  bm=bmesh.new();bm.from_mesh(obj.data);bm.faces.ensure_lookup_table()
  normals=[f.normal.copy() for f in bm.faces]
  bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.normal_update()
  flipped=sum(a.dot(f.normal)<-.5 for a,f in zip(normals,bm.faces));bm.free()
  rows.append(dict(asset=asset,object=obj.name,determinant=obj.matrix_world.determinant(),faces=len(obj.data.polygons),recalculatedFlipCount=flipped,materials=[m.name for m in obj.data.materials]))
(out/'source-orientation-audit.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8')
print(json.dumps(rows),flush=True)
