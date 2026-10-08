"""Check ladle-to-bowl contact throughout exported Orc cooking motion."""
from pathlib import Path
import sys,json,math,bpy
from mathutils import Vector
O=Path(__file__).resolve().parents[1]/'assets/uat01/roka-hearth-v1';FBX='--fbx'in sys.argv
bpy.ops.wm.read_factory_settings(use_empty=True);s=bpy.context.scene;s.render.fps=30
if FBX:bpy.ops.import_scene.fbx(filepath=str(O/'Roka_Hearth.fbx'),anim_offset=0)
else:bpy.ops.import_scene.gltf(filepath=str(O/'Roka_Hearth.glb'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE');assert len(rig.data.bones)==16
def points(o):
 e=o.evaluated_get(bpy.context.evaluated_depsgraph_get());m=e.to_mesh();ps=[e.matrix_world@v.co for v in m.vertices];e.to_mesh_clear();return ps
def center(o):
 p=points(o);return Vector(tuple((min(v[i]for v in p)+max(v[i]for v in p))*.5 for i in range(3)))
cup=bpy.data.objects['LadleCup'];stew=bpy.data.objects['Stew'];records=[]
s.frame_set(0);bpy.context.view_layer.update();start={b.name:b.matrix.copy()for b in rig.pose.bones}
for frame in range(0,181,15):
 s.frame_set(frame);bpy.context.view_layer.update();c=center(cup);food=center(stew);radius=((c.x-food.x)**2+(c.y-food.y)**2)**.5;top=max(p.z for p in points(stew));assert abs(radius-.25)<.00003
 assert radius+.16<.58;assert abs(c.z-top-.03)<.00003
 for name in ['Root','LeftHand','LeftFoot','RightFoot']:
  assert max(abs(rig.pose.bones[name].matrix[i][j]-start[name][i][j])for i in range(4)for j in range(4))<1e-5
 records.append({'frame':frame,'radius':radius,'ladleAboveStew':c.z-top})
assert max(abs(b.matrix[i][j]-start[b.name][i][j])for b in rig.pose.bones for i in range(4)for j in range(4))<1e-5
controls={b.custom_shape for b in rig.pose.bones if b.custom_shape}
meshes=[o for o in bpy.data.objects if o.type=='MESH' and o not in controls];tri=0
for o in meshes:
 o.data.calc_loop_triangles();tri+=len(o.data.loop_triangles)
 if any(m.type=='ARMATURE'for m in o.modifiers):
  for v in o.data.vertices:assert abs(sum(g.weight for g in v.groups)-1)<1e-5
report={'status':'PASS','format':'FBX'if FBX else'GLB','bones':16,'meshObjects':len(meshes),'triangles':tri,'contactSamples':records,'fixedSupportAndFeet':True,'loopSeam':True,'platformImported':False}
(O/('fbx-roundtrip-report.json'if FBX else'roundtrip-report.json')).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print('ROKA_ROUNDTRIP',json.dumps(report))
