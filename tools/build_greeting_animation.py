"""Original neutral greeting on the authored custom hero rig, with a verified raised hand."""
from pathlib import Path
import bpy,math,json
from mathutils import Vector,Quaternion
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/cosmetic-kit'
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'assets/uat01/hero-kit/knight_01.blend'))
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE');mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH')
rig.animation_data_clear();scene=bpy.context.scene;scene.render.fps=30;scene.frame_start=1;scene.frame_end=61
axis=Vector((0,-1,0))
for frame in range(1,62):
    t=(frame-1)/60;envelope=min(1,t/.2,(1-t)/.2);envelope=max(0,envelope);envelope=envelope*envelope*(3-2*envelope)
    for bone in rig.pose.bones:
        bone.rotation_mode='QUATERNION';bone.rotation_quaternion=Quaternion();bone.location=(0,0,0);bone.scale=(1,1,1)
    for name,angle in [('RightUpperArm',2.25*envelope),('RightLowerArm',(.15+.22*math.sin(t*math.tau*3))*envelope),('Head',.06*math.sin(t*math.tau)*envelope)]:
        p=rig.pose.bones[name];localAxis=p.bone.matrix_local.to_3x3().inverted()@axis;p.rotation_quaternion=Quaternion(localAxis,angle)
    for p in rig.pose.bones:
        for field in ('rotation_quaternion','location','scale'):p.keyframe_insert(data_path=field,frame=frame,group=p.name)
rig.animation_data.action.name='FriendlyGreeting';scene.frame_set(26);bpy.context.view_layer.update()
hand=rig.pose.bones['RightHand'].matrix.translation;shoulder=rig.pose.bones['RightUpperArm'].matrix.translation
assert hand.z>shoulder.z+.6,(tuple(hand),tuple(shoulder))
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);mesh.select_set(True);bpy.context.view_layer.objects.active=rig
bpy.ops.export_scene.fbx(filepath=str(OUT/'friendly_greeting_Animation.fbx'),use_selection=True,object_types={'MESH','ARMATURE'},add_leaf_bones=False,bake_anim=True,bake_anim_use_all_actions=False,bake_anim_use_nla_strips=False,bake_anim_step=1,bake_anim_simplify_factor=0,axis_forward='-Z',axis_up='Y')
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'FriendlyGreeting.blend'))
(OUT/'greeting-report.json').write_text(json.dumps(dict(frames=61,fps=30,duration=2,handAboveShoulder=float(hand.z-shoulder.z),animationAssetId=None,customNpcRig=True),indent=2)+'\n')
print('GREETING_RAISED_HAND_PASS',hand.z-shoulder.z)
