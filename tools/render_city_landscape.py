"""Run with Blender --background --python. Exact new native geometry, not Studio evidence."""
import bpy
import json
import math
import sys
from pathlib import Path
from mathutils import Matrix, Vector

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'tools'))
from build_city_landscape import rotation_matrix
OUT = ROOT/'assets/uat01/city-landscape'
data = json.loads((OUT/'landscape.json').read_text(encoding='utf-8'))
bpy.ops.wm.read_factory_settings(use_empty=True)
conversion = Matrix(((1,0,0),(0,0,-1),(0,1,0)))
materials = {}
meshes = {}


def mat(rgb, kind):
    key = tuple(rgb), kind
    if key not in materials:
        m = bpy.data.materials.new(kind+'_'+str(len(materials)))
        m.diffuse_color = (*[v/255 for v in rgb], 1)
        m.use_nodes = True
        bs = m.node_tree.nodes.get('Principled BSDF')
        # RGB inputs are authored sRGB colors, converted to linear for Blender.
        linear = [v/255/12.92 if v/255 <= .04045 else ((v/255+.055)/1.055)**2.4 for v in rgb]
        bs.inputs['Base Color'].default_value = (*linear,1)
        bs.inputs['Roughness'].default_value = .26 if kind == 'SpringWater' else .84
        materials[key] = m
    return materials[key]


def geometry(p, collection):
    key = p['shape'], tuple(p['color']), p['name'] == 'SpringWater'
    if key not in meshes:
        if p['shape'] == 'Ball':
            bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, radius=.5)
        elif p['shape'] == 'Cylinder':
            bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=.5, depth=1, rotation=(0,math.pi/2,0))
            bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
        else: bpy.ops.mesh.primitive_cube_add(size=1)
        template = bpy.context.object
        mesh = template.data
        mesh.materials.append(mat(p['color'], 'SpringWater' if key[2] else p['material']))
        if p['shape'] != 'Block':
            for polygon in mesh.polygons: polygon.use_smooth = True
        bpy.data.objects.remove(template, do_unlink=True)
        meshes[key] = mesh
    obj = bpy.data.objects.new(p['name'], meshes[key]);collection.objects.link(obj)
    # Apply the complete Roblox rotation and axis conversion, including X-axis cylinders.
    r = conversion@Matrix(rotation_matrix(p['rotation']))
    transform = r.to_4x4()@Matrix.Diagonal((*[v*.1 for v in p['size']],1))
    transform.translation = conversion@Vector(p['position'])*.1
    obj.matrix_world = transform
    obj['native_collidable'] = p['solid']
    return obj


groups = {}
for p in data['parts']:
    if p['group'] not in groups:
        c = bpy.data.collections.new(p['group']);bpy.context.scene.collection.children.link(c);groups[p['group']]=c
    geometry(p, groups[p['group']])
context = bpy.data.collections.new('Existing_ground_reference_only');bpy.context.scene.collection.children.link(context)
geometry(dict(name='ExistingCityGround',shape='Block',size=[912,.3,1012],position=[0,.15,-1130],rotation=[0,0,0],
              color=[112,128,102],material='Grass',solid=True),context)

scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 24
scene.cycles.use_denoising = True
scene.render.resolution_x = 1440
scene.render.resolution_y = 1000
scene.render.resolution_percentage = 100
scene.world = bpy.data.worlds.new('Soft daylight')
scene.world.use_nodes = True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.63,.73,.83,1)
scene.world.node_tree.nodes['Background'].inputs[1].default_value=.5
bpy.ops.object.light_add(type='SUN', location=(0,0,100))
sun=bpy.context.object;sun.name='Preview afternoon light';sun.data.energy=2.2;sun.data.angle=math.radians(18)
sun.rotation_euler=(math.radians(25),math.radians(-30),math.radians(-35))
scene.view_settings.view_transform='AgX'
bpy.ops.object.camera_add()
camera=bpy.context.object;scene.camera=camera
camera.data.type='ORTHO'
camera.data.clip_end=1000


def view(name, eye, target, scale):
    # Orthographic framing is distance-invariant; pull back to avoid near-plane
    # clipping through foreground foliage in this isolated landscape study.
    camera.location=conversion@(Vector(target)+(Vector(eye)-Vector(target))*3)*.1
    focus=conversion@Vector(target)*.1
    camera.rotation_euler=(focus-camera.location).to_track_quat('-Z','Y').to_euler()
    camera.data.ortho_scale=scale
    scene.render.filepath=str(OUT/(name+'.png'))
    bpy.ops.render.render(write_still=True)


view('hearth-garden-preview',(-240,65,-835),(-349,5,-920),19)
view('landscape-layout-preview',(600,1050,-330),(0,0,-1130),126)
# Saved authoring file opens on the garden, matching the first preview.
camera.location=conversion@(Vector((-349,5,-920))+(Vector((-240,65,-835))-Vector((-349,5,-920)))*3)*.1
camera.rotation_euler=(conversion@Vector((-349,5,-920))*.1-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.ortho_scale=19
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_Central_Landscape.blend'))
print('LANDSCAPE_BLENDER_RENDERED',len(data['parts']),'exact recipe primitives; existing city buildings not rendered')
