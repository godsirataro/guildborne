"""Room-sized camera distances and elevated front views for original furnishings."""
from pathlib import Path
import bpy,math,json
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/city-interior-kit'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'Guildborne_City_Interiors.blend'))
scene=bpy.context.scene
for o in list(scene.objects):bpy.data.objects.remove(o,do_unlink=True)
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.render.resolution_x=900;scene.render.resolution_y=700
scene.world.node_tree.nodes['Background'].inputs[1].default_value=.9
bpy.ops.object.camera_add();cam=bpy.context.object;cam.data.type='ORTHO';scene.camera=cam
for pos,power in [((25,-35,45),45000),((-30,-5,25),30000)]:
    bpy.ops.object.light_add(type='AREA',location=pos);o=bpy.context.object;o.data.energy=power;o.data.size=35;o.rotation_euler=(-o.location).to_track_quat('-Z','Y').to_euler()
models=[]
for a in json.loads((OUT/'kit.json').read_text())['assets']:
    bpy.ops.import_scene.gltf(filepath=str(OUT/(a['id']+'.glb')))
    o=next(o for o in bpy.context.selected_objects if o.type=='MESH');models.append(o)
    world=o.matrix_world.copy();o.parent=None;o.matrix_world=world
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    bpy.ops.object.transform_apply(location=False,rotation=True,scale=True);o.rotation_mode='XYZ'
    center=Vector((0,0,4));cam.location=center+Vector((35,-50,40));cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.ortho_scale=57
    scene.render.filepath=str(OUT/(a['id']+'.png'));bpy.ops.render.render(write_still=True);o.hide_render=True
for i,o in enumerate(models):
    o.hide_render=False;o.rotation_euler=(math.radians(55),0,math.radians(8));o.location=((i%3-1)*62,0,(1-i//3)*57)
    bpy.ops.object.text_add(location=(o.location.x-22,-25,o.location.z-23),rotation=(math.pi/2,0,0))
    text=bpy.context.object;text.data.body=o.name.replace('_',' ').upper();text.data.size=2;text.data.extrude=.01
cam.location=(0,-240,32);cam.rotation_euler=(Vector((0,0,32))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.ortho_scale=190
for lamp in [o for o in scene.objects if o.type=='LIGHT']:
    lamp.location.y=-90;lamp.location.z=100;lamp.data.energy=300000;lamp.data.size=120;lamp.rotation_euler=(Vector((0,0,30))-lamp.location).to_track_quat('-Z','Y').to_euler()
scene.render.resolution_x=1600;scene.render.resolution_y=1100;scene.render.filepath=str(OUT/'preview.png')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_City_Interiors.blend'));bpy.ops.render.render(write_still=True)
print('CITY_INTERIOR_RENDER_PASS')
