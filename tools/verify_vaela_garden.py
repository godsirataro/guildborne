"""Inspect exported skin and water endpoints, not only authoring coordinates."""
from pathlib import Path
import bpy,json,sys
from mathutils import Vector
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/vaela-garden-v1'
bpy.ops.wm.read_factory_settings(use_empty=True);s=bpy.context.scene;s.render.fps=30
FBX='--fbx' in sys.argv
if FBX:bpy.ops.import_scene.fbx(filepath=str(O/'Vaela_Garden.fbx'),anim_offset=0)
else:bpy.ops.import_scene.gltf(filepath=str(O/'Vaela_Garden.glb'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE');assert len(rig.data.bones)==16
def obj(prefix):return next(o for o in bpy.data.objects if o.name==prefix)
def points(o):
 e=o.evaluated_get(bpy.context.evaluated_depsgraph_get());m=e.to_mesh();v=[e.matrix_world@p.co for p in m.vertices];e.to_mesh_clear();return v
def center(o):
 # glTF duplicates UV seam vertices; use the symmetric mesh bounds, not a biased vertex average.
 ps=points(o);return Vector(tuple((min(p[i]for p in ps)+max(p[i]for p in ps))*.5 for i in range(3)))
rose=obj('SpoutRose');drop=obj('WaterDrop_0');last=obj('WaterDrop_7');soil=obj('Soil');records=[]
for frame in range(60,121,10):
 s.frame_set(frame);bpy.context.view_layer.update();mouth=center(rose);first=center(drop);end=center(last);top=max(p.z for p in points(soil));error=(mouth-first).length
 assert error<.00002,(frame,error)
 assert abs(end.z-top)<.00002
 assert ((end.x)**2+(end.y+1.4)**2)**.5<.42
 assert mouth.z>end.z+.2
 records.append({'frame':frame,'spoutStreamError':error,'soilContactError':abs(end.z-top)})
for frame in [0,59,121,180]:
 s.frame_set(frame);bpy.context.view_layer.update();assert max(drop.matrix_world.to_scale())<.00001
s.frame_set(0);bpy.context.view_layer.update();start={b.name:b.matrix.copy()for b in rig.pose.bones}
for frame in [60,90,120,180]:
 s.frame_set(frame);bpy.context.view_layer.update()
 for name in ['Root','LeftHand','LeftFoot','RightFoot']:
  assert max(abs(rig.pose.bones[name].matrix[i][j]-start[name][i][j])for i in range(4)for j in range(4))<1e-5
 if frame==180:assert max(abs(b.matrix[i][j]-start[b.name][i][j])for b in rig.pose.bones for i in range(4)for j in range(4))<1e-5
for name in ['UpperArm','LowerArm']:
 assert abs(rig.data.bones['Right'+name].length-rig.data.bones['Left'+name].length)<1e-5
controls={b.custom_shape for b in rig.pose.bones if b.custom_shape}
meshes=[o for o in bpy.data.objects if o.type=='MESH' and o not in controls];tri=0
for o in meshes:
 o.data.calc_loop_triangles();tri+=len(o.data.loop_triangles)
 if any(m.type=='ARMATURE'for m in o.modifiers):
  for v in o.data.vertices:assert abs(sum(g.weight for g in v.groups)-1)<1e-5
report={'status':'PASS','bones':16,'meshObjects':len(meshes),'triangles':tri,'pourChecks':records,'inactiveWaterChecks':4,'stationaryFootRootSupportHand':True,'symmetricArmLengths':True,'loopSeam':True,'platformImported':False}
report['format']='FBX' if FBX else 'GLB'
(O/('fbx-roundtrip-report.json' if FBX else 'roundtrip-report.json')).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print('VAELA_ROUNDTRIP',json.dumps(report))
