"""Export the original Roblox solo trial court geometry as an editable Blender scene."""
from pathlib import Path
import bpy,json
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/trial-arena'
data=json.loads((OUT/'geometry.json').read_text(encoding='utf-8'))
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene;groups={};materials={};report=[]
def linear(v):return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
for part in data:
 color=tuple(round(x,5) for x in part['color'])
 if color not in materials:
  m=bpy.data.materials.new('Palette_'+str(len(materials)));m.use_nodes=True;m.diffuse_color=(*map(linear,color),1)
  m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=m.diffuse_color
  m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.8;materials[color]=m
 x,y,z=part['position'];sx,sy,sz=part['size']
 bpy.ops.mesh.primitive_cube_add(size=1,location=(x,-z,y));o=bpy.context.object;o.name=part['name'];o.scale=(sx,sz,sy)
 o.data.materials.append(materials[color]);groups.setdefault(part['stage'],[]).append(o)
models=[]
def select(objects):
 bpy.ops.object.select_all(action='DESELECT')
 for o in objects:o.select_set(True)
 bpy.context.view_layer.objects.active=objects[0]
def export(o,parts):
 select([o]);o.data.calc_loop_triangles()
 bpy.ops.export_scene.fbx(filepath=str(OUT/(o.name+'.fbx')),use_selection=True,object_types={'MESH'},add_leaf_bones=False,bake_anim=False,axis_forward='-Z',axis_up='Y')
 bpy.ops.export_scene.gltf(filepath=str(OUT/(o.name+'.glb')),use_selection=True,export_format='GLB')
 report.append(dict(id=o.name,triangles=len(o.data.loop_triangles),bounds=list(o.dimensions),sourceParts=parts,robloxMeshAssetId=None))
for stage,objects in groups.items():
 select(objects);bpy.ops.object.join();o=bpy.context.object;o.name='trial_arena_'+stage.lower()
 scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR');bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
 export(o,len(objects));models.append(o)
select(models);bpy.ops.object.duplicate();bpy.ops.object.join();combined=bpy.context.object;combined.name='trial_arena_complete'
export(combined,len(data));bpy.data.objects.remove(combined,do_unlink=True)
scene.world=bpy.data.worlds.new('TrialArenaSky');scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.4,.55,.65,1)
scene.world.node_tree.nodes['Background'].inputs[1].default_value=.7
bpy.ops.object.light_add(type='SUN',location=(0,-200,400));bpy.context.object.rotation_euler=(.35,-.4,-.4);bpy.context.object.data.energy=2
bpy.ops.object.camera_add(location=(92,-125,112));camera=bpy.context.object
camera.rotation_euler=(Vector((0,0,0))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=150;scene.camera=camera
scene.render.engine='CYCLES';scene.cycles.samples=16;scene.cycles.use_denoising=True
scene.render.resolution_x=1536;scene.render.resolution_y=1024;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.filepath=str(OUT/'preview.png');scene.view_settings.view_transform='Standard'
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_Trial_Arena.blend'))
bpy.ops.render.render(write_still=True)
(OUT/'export-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
assert len(models)==4 and sum(len(x) for x in groups.values())==81
print('TRIAL_ARENA_EXPORT',len(models),'stages',len(data),'parts',len(report)*2,'exports')
