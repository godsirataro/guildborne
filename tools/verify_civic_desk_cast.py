"""Verify exported document/tool contacts and stable supporting poses."""
from pathlib import Path
import bpy,sys,json
from mathutils import Vector
R=Path(__file__).resolve().parents[1];FBX='--fbx'in sys.argv
for who in ['elian','nyra','sela']:
 O=R/('assets/uat01/'+who+'-desk-v1');bpy.ops.wm.read_factory_settings(use_empty=True);s=bpy.context.scene;s.render.fps=30
 if FBX:bpy.ops.import_scene.fbx(filepath=str(O/(who.title()+'_Desk.fbx')),anim_offset=0)
 else:bpy.ops.import_scene.gltf(filepath=str(O/(who.title()+'_Desk.glb')))
 rig=next(o for o in bpy.data.objects if o.type=='ARMATURE');assert len(rig.data.bones)==16
 def points(o):
  e=o.evaluated_get(bpy.context.evaluated_depsgraph_get());m=e.to_mesh();ps=[e.matrix_world@v.co for v in m.vertices];e.to_mesh_clear();return ps
 def center(o):
  ps=points(o);return Vector(tuple((min(v[i]for v in ps)+max(v[i]for v in ps))*.5 for i in range(3)))
 paper=bpy.data.objects['Document'];tip=bpy.data.objects['StampFoot'if who=='elian'else'ToolTip'];s.frame_set(0);bpy.context.view_layer.update();start={b.name:b.matrix.copy()for b in rig.pose.bones};records=[]
 frames=[0,30,60,90,120,150,180]if who!='sela'else[0,22,44,52,60,82,104,112,120,142,164,172,180]
 for frame in frames:
  s.frame_set(frame);bpy.context.view_layer.update();surface=max(v.z for v in points(paper));p=center(tip)
  if who=='elian':
   bottom=min(v.z for v in points(tip));assert bottom>=surface-.00002
   if frame==90:assert abs(bottom-surface)<.00002
   if frame in [0,180]:assert bottom-surface>.54
   clearance=bottom-surface
  else:
   assert -.81<p.x<.81 and -1.64<p.y<-.80
   clearance=p.z-surface
   if who=='nyra'or frame%60<=44:assert abs(clearance)<.00002
   else:assert clearance>.08
  for name in ['Root','LeftHand','LeftFoot','RightFoot']:
   assert max(abs(rig.pose.bones[name].matrix[i][j]-start[name][i][j])for i in range(4)for j in range(4))<1e-5
  records.append({'frame':frame,'toolClearance':clearance})
 assert max(abs(b.matrix[i][j]-start[b.name][i][j])for b in rig.pose.bones for i in range(4)for j in range(4))<1e-5
 controls={b.custom_shape for b in rig.pose.bones if b.custom_shape}
 meshes=[o for o in bpy.data.objects if o.type=='MESH' and o not in controls];tri=0
 for o in meshes:
  o.data.calc_loop_triangles();tri+=len(o.data.loop_triangles)
  if any(m.type=='ARMATURE'for m in o.modifiers):
   for v in o.data.vertices:assert abs(sum(g.weight for g in v.groups)-1)<1e-5
 report={'status':'PASS','format':'FBX'if FBX else'GLB','bones':16,'meshObjects':len(meshes),'triangles':tri,'contactSamples':records,'fixedSupportAndFeet':True,'loopSeam':True,'platformImported':False,'notes':'Stamp tests bottom surface; pen/stylus tests authored tip centre against document surface and bounds.'}
 (O/('fbx-roundtrip-report.json'if FBX else'roundtrip-report.json')).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print('DESK_ROUNDTRIP',who,json.dumps(report))
