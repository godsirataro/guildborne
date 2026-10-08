"""Render a one-second walk-cycle review of all twelve custom rigs."""
from pathlib import Path
import bpy,json,math
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1];KIT=ROOT/'assets/uat01/enemy-kit';OUT=ROOT/'build/enemy-motion';OUT.mkdir(parents=True,exist_ok=True)
manifest=json.loads((KIT/'manifest.json').read_text(encoding='utf-8'));bpy.ops.wm.read_factory_settings(use_empty=True);scene=bpy.context.scene
for i,a in enumerate(manifest['assets']):
    before=set(scene.objects);bpy.ops.import_scene.fbx(filepath=str(KIT/(a['id']+'_Walk.fbx')));new=set(scene.objects)-before
    rig=next(o for o in new if o.type=='ARMATURE');mesh=next(o for o in new if o.type=='MESH')
    scene.frame_set(1);scale=(5.7 if a['role']=='Boss' else 4.4)/mesh.dimensions.z;rig.scale=(scale,scale,scale);rig.location=((1.5-i%4)*7,0,(2-i//4)*7.4)
    # Object-level FBX keys can overwrite gallery placement; preserve bone channels only.
    if rig.animation_data and rig.animation_data.action:
        action=rig.animation_data.action
        for layer in action.layers:
            for strip in layer.strips:
                for bag in strip.channelbags:
                    for curve in list(bag.fcurves):
                        if not curve.data_path.startswith('pose.bones['):bag.fcurves.remove(curve)
    bpy.ops.object.text_add(location=(rig.location.x+2.8,.3,rig.location.z-.65),rotation=(math.pi/2,0,math.pi));label=bpy.context.object;label.data.body=a['id'].replace('_',' ').upper();label.data.size=.22
    material=bpy.data.materials.new('Label');material.use_nodes=True;material.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(.9,.8,.6,1);label.data.materials.append(material)
scene.world=bpy.data.worlds.new('MotionStudio');scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.03,.045,.07,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.8
bpy.ops.object.light_add(type='AREA',location=(0,18,22));light=bpy.context.object;light.data.energy=9000;light.data.size=30;light.rotation_euler=(Vector((0,0,9))-light.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(6,45,18));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,9))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=32;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=12;scene.cycles.use_denoising=True;scene.view_settings.view_transform='Standard';scene.render.resolution_x=1200;scene.render.resolution_y=1050;scene.render.resolution_percentage=100;scene.render.image_settings.file_format='PNG'
for index in range(24):
    scene.frame_set(round(1+index*30/24));scene.render.filepath=str(OUT/f'{index:02}.png');bpy.ops.render.render(write_still=True)
print('ENEMY_MOTION_FRAMES',24)
