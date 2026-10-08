"""Editable eight-second epilogue storyboards; original motion matches native UI.
Separate transform-animation GLBs are review assets, not Roblox Animation IDs.
"""
from pathlib import Path
import bpy,json,math
from mathutils import Matrix,Vector
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/uat01/archive-ending-motion';OUT.mkdir(parents=True,exist_ok=True)
data=json.loads((ROOT/'assets/uat01/archive-endings/kit.json').read_text(encoding='utf-8'))
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
convert=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
materials={}
for name,rgb in data['palette'].items():
 m=bpy.data.materials.new(name);m.use_nodes=True
 def linear(c):
  c/=255;return c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4
 m.diffuse_color=(*[linear(c)for c in rgb],1)
 m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=m.diffuse_color
 m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.82;materials[name]=m
scene=bpy.context.scene;scene.render.fps=30;scene.frame_start=0;scene.frame_end=240
records=[]
mode=bpy.ops.export_scene.gltf.get_rna_type().properties['export_animation_mode']
assert 'SCENE' in [x.identifier for x in mode.enum_items]
for asset in data['assets']:
 identity=asset['id'];collection=bpy.data.collections.new(identity);scene.collection.children.link(collection);objects=[];animated=[]
 for index,p in enumerate(asset['parts']):
  bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object;o.name=f'{identity}_{index:03d}_{p["name"]}'
  for c in list(o.users_collection):c.objects.unlink(o)
  collection.objects.link(o);base=Vector(p['position']);rz=math.radians(p['rotation'][2]);rot=Matrix.Rotation(rz,3,'Z')
  o.location=convert@base;o.rotation_euler=(convert@rot@convert.inverted()).to_euler();o.scale=(p['size'][0],p['size'][2],p['size'][1]);o.data.materials.append(materials[p['color']]);objects.append(o)
  name=p['name']
  if name not in {'ArchiveRing','Canopy','GardenLeaf','Flower','OpenLedger'}:continue
  animated.append(o)
  for frame in range(241):
   t=frame/30;envelope=math.sin(math.pi*t/8)**2;pos=base.copy();rotation=rot.copy()
   if name=='ArchiveRing':
    angle=.075*math.sin(t*.9)*envelope;q=Matrix.Rotation(angle,3,'Z');center=Vector((0,6,-10));pos=center+q@(base-center);rotation=q@rot
   elif name in {'Canopy','GardenLeaf','Flower'}:rotation=rot@Matrix.Rotation(.035*math.sin(t*1.5)*envelope,3,'Z')
   else:rotation=rot@Matrix.Rotation(.055*math.sin(t*1.4)*envelope,3,'X')
   o.location=convert@pos;o.rotation_euler=(convert@rotation@convert.inverted()).to_euler()
   o.keyframe_insert(data_path='location',frame=frame);o.keyframe_insert(data_path='rotation_euler',frame=frame)
 bpy.ops.object.select_all(action='DESELECT')
 for o in objects:o.select_set(True)
 bpy.context.view_layer.objects.active=objects[0];scene.frame_set(0)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(identity+'_Replay.glb')),use_selection=True,export_format='GLB',export_animations=True,export_animation_mode='SCENE',export_anim_scene_split_object=False,export_frame_range=True,export_force_sampling=True)
 records.append(dict(id=identity,seconds=8,fps=30,frames=241,parts=len(objects),animatedParts=len(animated),file=identity+'_Replay.glb',robloxAnimationId=None,role='editable native-motion reference; platform import pending'))
 # Move each library collection with a parent root, preserving local animated keys.
 root=bpy.data.objects.new(identity+'_LibraryRoot',None);collection.objects.link(root)
 for o in objects:o.parent=root
 root.location.x=(len(records)-2)*40
scene.frame_set(90)
scene.world.color=(.18,.18,.18)
for loc,power,size in [((0,-30,55),130000,50),((-45,5,35),80000,40)]:
 bpy.ops.object.light_add(type='AREA',location=loc);light=bpy.context.object;light.data.energy=power;light.data.shape='DISK';light.data.size=size;light.rotation_euler=(Vector((0,0,3))-light.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(55,-85,70));camera=bpy.context.object;camera.rotation_euler=(Vector((0,-6,2))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=145;scene.camera=camera
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.render.resolution_x=1600;scene.render.resolution_y=1000;scene.render.resolution_percentage=100;scene.view_settings.view_transform='Standard'
scene.render.image_settings.file_format='PNG';scene.render.filepath=str(OUT/'preview.png')
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_Archive_Ending_Motion.blend'))
bpy.ops.render.render(write_still=True)
(OUT/'manifest.json').write_text(json.dumps(dict(schema=1,clips=records,units='stud',conversion='Roblox (x,y,z) to Blender (x,-z,y)',nativeSource='src/shared/Presentation/ArchiveEndingMotion.luau'),indent=2)+'\n',encoding='utf-8')
print('ENDING_MOTION_EXPORTED',len(records),sum(r['animatedParts']for r in records))
