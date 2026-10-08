"""Clean import: grip stability, loop seams, fixed support and blade/head clearance."""
from pathlib import Path
import bpy,json,sys
from mathutils import Vector
O=Path(__file__).resolve().parents[1]/'assets/uat01/sword-contact-v1';fbx='--fbx'in sys.argv
bpy.ops.wm.read_factory_settings(use_empty=True);scene=bpy.context.scene;scene.render.fps=30
if fbx:bpy.ops.import_scene.fbx(filepath=str(O/'Sword_Contact.fbx'),anim_offset=0)
else:bpy.ops.import_scene.gltf(filepath=str(O/'Sword_Contact.glb'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE');assert len(rig.data.bones)==16
def points(obj):
 evaluated=obj.evaluated_get(bpy.context.evaluated_depsgraph_get());mesh=evaluated.to_mesh();result=[evaluated.matrix_world@v.co for v in mesh.vertices];evaluated.to_mesh_clear();return result
def center(obj):
 p=points(obj);return Vector([(min(v[i]for v in p)+max(v[i]for v in p))/2 for i in range(3)])
def error(a,b):return max(abs(a[i][j]-b[i][j])for i in range(4)for j in range(4))
scene.frame_set(0);bpy.context.view_layer.update();start={b.name:b.matrix.copy()for b in rig.pose.bones}
grip=bpy.data.objects['Sword_0_Grip'];blade=bpy.data.objects['Sword_3_Blade'];max_error=0;minimum_head=100;sampled=0;cut_direction=None
for frame in range(181):
 scene.frame_set(frame);bpy.context.view_layer.update()
 hand=rig.matrix_world@rig.pose.bones['RightHand'].head;delta=(center(grip)-hand).length;assert delta<.00003,(frame,delta);max_error=max(max_error,delta)
 for name in ['Root','LeftFoot','RightFoot']:assert error(rig.pose.bones[name].matrix,start[name])<.00003,(frame,name)
 if frame%60==0:assert all(error(b.matrix,start[b.name])<.00005 for b in rig.pose.bones)
 # Segment from palm to blade tip stays outside a conservative head bounding sphere.
 vertices=points(blade);end=max(vertices,key=lambda v:(v-hand).length);segment=end-hand
 head=center(bpy.data.objects['Head']);u=max(0,min(1,(head-hand).dot(segment)/segment.length_squared));clearance=(head-(hand+segment*u)).length
 assert clearance>.68,(frame,clearance);minimum_head=min(minimum_head,clearance)
 if frame==9:
  cut_direction=(center(blade)-hand).normalized();assert cut_direction.dot(Vector((0,-1,0)))>.9999
 sampled+=1
controls={b.custom_shape for b in rig.pose.bones if b.custom_shape};meshes=[o for o in bpy.data.objects if o.type=='MESH'and o not in controls]
triangles=sum(sum(len(p.vertices)-2 for p in o.data.polygons)for o in meshes)
report={'status':'PASS','format':'FBX'if fbx else'GLB','samples':sampled,'bones':16,'meshObjects':len(meshes),'triangles':triangles,'maxGripError':max_error,'minimumHeadCenterDistance':minimum_head,'fixedRootFeet':True,'loopSeams':True,'cutDirection':list(cut_direction),'gameplayBound':False,'scope':'Geometric contact study; segment clearance does not prove all body/cloth collision, combat timing or animation quality.'}
(O/('fbx-roundtrip-report.json'if fbx else'roundtrip-report.json')).write_text(json.dumps(report,indent=2)+'\n');print('SWORD_ROUNDTRIP',json.dumps(report))
