"""Blender roundtrip checks for the Borin contact-art slice."""
from pathlib import Path
import bpy,json,sys
from mathutils import Vector
R=Path(__file__).resolve().parents[1];O=R/('assets/uat01/borin-forge-v2' if '--polished' in sys.argv else 'assets/uat01/borin-forge-v1')
bpy.ops.wm.read_factory_settings(use_empty=True);bpy.context.scene.render.fps=30
FBX='--fbx' in sys.argv
if FBX:bpy.ops.import_scene.fbx(filepath=str(O/'Borin_Forge.fbx'),anim_offset=0)
else:bpy.ops.import_scene.gltf(filepath=str(O/'Borin_Forge.glb'))
rigs=[o for o in bpy.data.objects if o.type=='ARMATURE'];assert len(rigs)==1
rig=rigs[0];assert len(rig.data.bones)==16
assert all(name in rig.data.bones for name in ['Root','LowerTorso','UpperTorso','RightHand','LeftHand','RightFoot','LeftFoot'])
controls={b.custom_shape for b in rig.pose.bones if b.custom_shape}
meshes=[o for o in bpy.data.objects if o.type=='MESH' and o not in controls];assert meshes
hammer=next(o for o in meshes if o.name.startswith('Hammer_Head'))
work=next(o for o in meshes if o.name.startswith('HotWorkpiece'))
def limits(o):
 evaluated=o.evaluated_get(bpy.context.evaluated_depsgraph_get());mesh=evaluated.to_mesh()
 z=[(evaluated.matrix_world@v.co).z for v in mesh.vertices];evaluated.to_mesh_clear();return min(z),max(z)
contacts=[]
for frame in [30,90,150]:
 bpy.context.scene.frame_set(frame);bpy.context.view_layer.update();bottom=limits(hammer)[0];top=limits(work)[1]
 contacts.append({'frame':frame,'hammerBottom':bottom,'workpieceTop':top,'error':abs(bottom-top)})
 assert abs(bottom-top)<.002,(frame,bottom,top)
bpy.context.scene.frame_set(0);lift=limits(hammer)[0]-limits(work)[1];assert lift>.79
start={b.name:b.matrix.copy() for b in rig.pose.bones}
for frame in [30,90,150,180]:
 bpy.context.scene.frame_set(frame);bpy.context.view_layer.update()
 for name in ['Root','RightFoot','LeftFoot']:
  assert max(abs(rig.pose.bones[name].matrix[i][j]-start[name][i][j])for i in range(4)for j in range(4))<1e-5
 if frame==180:
  assert max(abs(b.matrix[i][j]-start[b.name][i][j])for b in rig.pose.bones for i in range(4)for j in range(4))<1e-5
triangles=0
for o in meshes:o.data.calc_loop_triangles();triangles+=len(o.data.loop_triangles)
skins=[o for o in meshes if any(m.type=='ARMATURE'for m in o.modifiers)];assert len(skins)>50
for o in skins:
 for v in o.data.vertices:
  assert abs(sum(g.weight for g in v.groups)-1)<1e-5,o.name
assert len(bpy.data.actions)>=1
report={'status':'PASS','meshObjects':len(meshes),'triangles':triangles,'bones':len(rig.data.bones),'skinnedMeshes':len(skins),'actions':len(bpy.data.actions),'contactRoundtrip':contacts,'windupClearance':lift,'stationaryFeetAndRoot':True,'loopSeamPassed':True,'platformImported':False,'excludedBoneControlMeshes':len(controls),'notes':'Export imported into a clean Blender scene at authored30fps. Evaluated skinned hammer surfaces tested; listening and production retarget/performance pending. Importer bone-control shapes excluded from geometry totals.'}
report['format']='FBX' if FBX else 'GLB'
(O/('fbx-roundtrip-report.json' if FBX else 'roundtrip-report.json')).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print('BORIN_ROUNDTRIP_PASS',json.dumps(report))
