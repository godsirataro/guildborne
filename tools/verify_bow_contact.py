"""Check imported rendered geometry against actual posed grip and string endpoints."""
from pathlib import Path
import bpy,json,sys
from mathutils import Vector
O=Path(__file__).resolve().parents[1]/'assets/uat01/bow-contact-v1';fbx='--fbx'in sys.argv;manifest=json.loads((O/'manifest.json').read_text())
bpy.ops.wm.read_factory_settings(use_empty=True);s=bpy.context.scene;s.render.fps=30
if fbx:bpy.ops.import_scene.fbx(filepath=str(O/'Bow_Contact.fbx'),anim_offset=0)
else:bpy.ops.import_scene.gltf(filepath=str(O/'Bow_Contact.glb'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE');assert len(rig.data.bones)==18
def points(o):
 e=o.evaluated_get(bpy.context.evaluated_depsgraph_get());m=e.to_mesh();p=[e.matrix_world@v.co for v in m.vertices];e.to_mesh_clear();return p
def center(o):
 ps=points(o);return Vector([(min(p[i]for p in ps)+max(p[i]for p in ps))/2 for i in range(3)])
def head(name):return rig.matrix_world@rig.pose.bones[name].head
def matrix_error(a,b):return max(abs(a[i][j]-b[i][j])for i in range(4)for j in range(4))
s.frame_set(0);bpy.context.view_layer.update();start={b.name:b.matrix.copy()for b in rig.pose.bones};ready=Vector(manifest['readyNock']);draw=Vector(manifest['drawAnchor']);back=Vector(manifest['backDirection']);records=[];max_error=0
for frame in [0,1,3,5,6,7,8,9,10,12,15,18,19,24,27,30,33,36,39,42,45,48,51,54,56,59,60,66,67,68,78,120,126,127,128,138,153,162,179,180]:
 s.frame_set(frame);bpy.context.view_layer.update();t=(frame/30)%2
 grip=center(bpy.data.objects['Bow_5_Grip']);assert(grip-head('LeftHand')).length<.00003
 for name in ['Root','LeftHand','LeftFoot','RightFoot']:assert matrix_error(rig.pose.bones[name].matrix,start[name])<.00003
 # Drawn string meets the right palm; release detaches intentionally.
 nock=head('RightHand')if t<=.24 else ready
 if t<=.24:
  for sign,objname in [(1,'Bow_8_TipCap'),(-1,'Bow_6_TipCap')]:
   tip=center(bpy.data.objects[objname]);direction=(nock-tip).normalized();length=(nock-tip).length
   vertices=points(bpy.data.objects['StringUpper'if sign==1 else'StringLower'])
   distances=[(v-tip).dot(direction)for v in vertices];error=max(abs(min(distances)),abs(max(distances)-length));max_error=max(max_error,error);assert error<.00005,(frame,sign,error)
  arrow=bpy.data.objects['Arrow'];error=(arrow.matrix_world.translation-nock).length;max_error=max(max_error,error);assert error<.00005,(frame,'nock',error)
 if .24<t<=.60:
  expected=draw-back*((t-.24)*18);error=(bpy.data.objects['Arrow'].matrix_world.translation-expected).length;max_error=max(max_error,error);assert error<.00005,(frame,'flight',error)
 if t>=1.1:
  arrow=bpy.data.objects['Arrow'];error=(arrow.matrix_world.translation-head('RightHand')).length;max_error=max(max_error,error);assert error<.00005,(frame,'pickup grip',error)
 if 1.1<=t<=1.4:
  arrow=bpy.data.objects['Arrow'];direction=(arrow.matrix_world.to_3x3()@Vector((0,0,1))).normalized();axis=Vector(manifest['quiverAxis']);assert direction.dot(-axis)>.99999
  mouth=center(bpy.data.objects['QuiverRim']);offset=arrow.matrix_world.translation-mouth;assert(offset-axis*offset.dot(axis)).length<.00005
 if frame%60==42:
  arrow=bpy.data.objects['Arrow'];axis=Vector(manifest['quiverAxis']);mouth=center(bpy.data.objects['QuiverRim']);clearance=min((p-mouth).dot(axis)for p in points(arrow));assert clearance>.03,(frame,'quiver tip clearance',clearance)
 if frame%60==0:assert all(matrix_error(b.matrix,start[b.name])<.00005 for b in rig.pose.bones)
 records.append({'frame':frame,'handToGrip':(grip-head('LeftHand')).length,'handToReadyNock':(head('RightHand')-ready).length})
controls={b.custom_shape for b in rig.pose.bones if b.custom_shape};meshes=[o for o in bpy.data.objects if o.type=='MESH'and o not in controls];triangles=0
for o in meshes:
 o.data.calc_loop_triangles();triangles+=len(o.data.loop_triangles)
 if any(m.type=='ARMATURE'for m in o.modifiers):
  for v in o.data.vertices:assert abs(sum(g.weight for g in v.groups)-1)<.00001
report={'status':'PASS','format':'FBX'if fbx else'GLB','bones':18,'meshObjects':len(meshes),'triangles':triangles,'sampleCount':len(records),'samples':records,'maxContactError':max_error,'fixedGripRootFeet':True,'loopSeams':True,'platformImported':False,'note':'Checks sampled contact and free flight, not final acting or server damage synchronization.'}
(O/('fbx-roundtrip-report.json'if fbx else'roundtrip-report.json')).write_text(json.dumps(report,indent=2)+'\n');print('BOW_ROUNDTRIP',json.dumps(report))
