"""Run with Blender --background --python tools/blender_adventure_kit.py.
Exports each prop at a ground pivot, plus an editable library and a preview.
Blender uses (x,-z,y) to convert Roblox Y-up studs to Z-up authoring units.
"""
from pathlib import Path
import bpy
import json
import math
from mathutils import Matrix, Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'assets/uat01/adventure-kit'
data = json.loads((OUT/'kit.json').read_text(encoding='utf-8'))
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
materials = {}
for name, rgb in data['palette'].items():
    m = bpy.data.materials.new(name)
    # Convert sRGB source palette to linear color for consistent rendered colors.
    def linear(c):
        c /= 255
        return c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4
    m.diffuse_color = (*[linear(v) for v in rgb],1)
    m.use_nodes = True
    shader = m.node_tree.nodes.get('Principled BSDF')
    shader.inputs['Base Color'].default_value = m.diffuse_color
    shader.inputs['Roughness'].default_value = .82
    materials[name] = m
conversion = Matrix(((1,0,0),(0,0,-1),(0,1,0)))
records = []
for index, asset in enumerate(data['assets']):
    collection = bpy.data.collections.new(asset['id'])
    bpy.context.scene.collection.children.link(collection)
    objects = []
    for p in asset['parts']:
        bpy.ops.mesh.primitive_cube_add(size=1)
        obj = bpy.context.object
        obj.name = p['name']
        for c in list(obj.users_collection): c.objects.unlink(obj)
        collection.objects.link(obj)
        obj.location = conversion @ Vector(p['position'])
        rx,ry,rz = [math.radians(v) for v in p['rotation']]
        rotation = Matrix.Rotation(rx,3,'X') @ Matrix.Rotation(ry,3,'Y') @ Matrix.Rotation(rz,3,'Z')
        obj.rotation_euler = (conversion @ rotation @ conversion.inverted()).to_euler()
        obj.scale = (p['size'][0],p['size'][2],p['size'][1])
        obj.data.materials.append(materials[p['color']])
        objects.append(obj)
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects: obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = asset['id']
    bpy.context.scene.cursor.location = (0,0,0)
    bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
    bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    obj.data.calc_loop_triangles()
    triangle_count = len(obj.data.loop_triangles)
    assert triangle_count < 600, (asset['id'], triangle_count)
    bpy.ops.export_scene.fbx(filepath=str(OUT/(asset['id']+'.fbx')),use_selection=True,
        object_types={'MESH'},add_leaf_bones=False,bake_anim=False,axis_forward='-Z',axis_up='Y')
    bpy.ops.export_scene.gltf(filepath=str(OUT/(asset['id']+'.glb')),use_selection=True,export_format='GLB')
    records.append(dict(id=asset['id'],triangles=triangle_count,
        bounds=list(obj.dimensions),materials=len(obj.data.materials),
        status='CREATED',robloxMeshAssetId=None,studioNativeVerified=False))
    obj.location = ((index%5-2)*11, -(index//5)*14, 0)

# Non-exported display stage and lighting.
bpy.ops.mesh.primitive_plane_add(size=200, location=(0,0,-.04))
stage=bpy.context.object; stage.name='PreviewStage'
stage.data.materials.append(materials['slate'])
world=bpy.context.scene.world
world.color=(.18,.18,.18)
for name,loc,energy,size in [('Key',(0,-4,30),17000,25),('Fill',(-20,5,15),9000,20)]:
    bpy.ops.object.light_add(type='AREA',location=loc)
    light=bpy.context.object; light.name=name; light.data.energy=energy; light.data.shape='DISK';light.data.size=size
    light.rotation_euler=(Vector((0,-6,0))-light.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(27,-43,34))
cam=bpy.context.object
cam.rotation_euler=(Vector((0,-6,2))-cam.location).to_track_quat('-Z','Y').to_euler()
cam.data.type='ORTHO'; cam.data.ortho_scale=63
scene=bpy.context.scene; scene.camera=cam
scene.render.engine='CYCLES'; scene.cycles.samples=24
scene.render.resolution_x=1600;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
scene.view_settings.view_transform='Standard'
scene.render.image_settings.file_format='PNG';scene.render.filepath=str(OUT/'preview.png')
(OUT/'export-report.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_Adventure_Kit.blend'))
bpy.ops.render.render(write_still=True)
print('GUILDBORNE_KIT_COMPLETE',len(records),sum(r['triangles'] for r in records))
