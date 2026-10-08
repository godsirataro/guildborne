"""Six editable object-hierarchy motion references sampled from native Luau.
These GLBs are review clips, not published Roblox skeletal Animation IDs.
"""
from pathlib import Path
import bpy,json,math
from mathutils import Matrix,Vector,Euler
R=Path(__file__).resolve().parents[1];out=R/'assets/uat01/civic-work-motion'
data=json.loads((R/'assets/uat01/city-cast/kit.json').read_text(encoding='utf-8'))
samples=json.loads((out/'samples.json').read_text(encoding='utf-8-sig'))
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene;scene.render.fps=30;scene.frame_start=0;scene.frame_end=240
convert=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
materials={}
for name,rgb in data['palette'].items():
 m=bpy.data.materials.new(name);m.use_nodes=True
 def linear(v):
  v/=255;return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
 m.diffuse_color=(*map(linear,rgb),1);m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=m.diffuse_color
 m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.8;materials[name]=m
records=[]
for index,a in enumerate(data['assets']):
 identity=a['id'];collection=bpy.data.collections.new(identity);scene.collection.children.link(collection)
 bones={};positions={};objects=[]
 for b in a['bones']:
  o=bpy.data.objects.new(identity+'_'+b['name'],None);collection.objects.link(o);objects.append(o)
  pos=Vector(b['head']);positions[b['name']]=pos
  parent=b.get('parent')
  if parent:o.parent=bones[parent];o.location=convert@(pos-positions[parent])
  else:o.location=convert@pos
  bones[b['name']]=o
 for n,p in enumerate(a['parts']):
  bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object;o.name=f'{identity}_{n:03d}_{p["name"]}'
  for c in list(o.users_collection):c.objects.unlink(o)
  collection.objects.link(o);objects.append(o);o.parent=bones[p['bone']]
  o.location=convert@(Vector(p['position'])-positions[p['bone']]);o.scale=(p['size'][0],p['size'][2],p['size'][1])
  rot=Euler(tuple(math.radians(v)for v in p.get('rotation',[0,0,0])),'XYZ').to_matrix()
  o.rotation_euler=(convert@rot@convert.inverted()).to_euler();o.data.materials.append(materials[p['color']])
 for frame,pose in enumerate(samples['frames'][identity]):
  for name,angles in pose.items():
   # Roblox CFrame.Angles applies Rx*Ry*Rz; explicit order avoids Euler convention mismatch.
   rot=Matrix.Rotation(angles[0],3,'X')@Matrix.Rotation(angles[1],3,'Y')@Matrix.Rotation(angles[2],3,'Z')
   o=bones[name];o.rotation_euler=(convert@rot@convert.inverted()).to_euler();o.keyframe_insert(data_path='rotation_euler',frame=frame)
 scene.frame_set(0);bpy.ops.object.select_all(action='DESELECT')
 for o in objects:o.select_set(True)
 bpy.context.view_layer.objects.active=bones['Root']
 bpy.ops.export_scene.gltf(filepath=str(out/(identity+'_Work.glb')),use_selection=True,export_format='GLB',export_animations=True,export_animation_mode='SCENE',export_anim_scene_split_object=False,export_frame_range=True,export_force_sampling=True)
 records.append(dict(id=identity,file=identity+'_Work.glb',parts=len(a['parts']),joints=len(bones),seconds=8,fps=30,rootMotion=False,robloxAnimationId=None))
 bones['Root'].location.x=(index%3-1)*7;bones['Root'].location.y=(index//3)*8
scene.frame_set(120)
scene.world=bpy.data.worlds.new('CivicStudio');scene.world.color=(.18,.18,.18)
for loc,power,size in [((0,15,20),6000,15),((-12,5,13),4500,12)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=size;o.rotation_euler=(Vector((0,3,2))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(2,40,18));cam=bpy.context.object;cam.rotation_euler=(Vector((0,3.5,2.5))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=25;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.render.resolution_x=1600;scene.render.resolution_y=1200;scene.render.resolution_percentage=100;scene.view_settings.view_transform='Standard';scene.render.image_settings.file_format='PNG';scene.render.filepath=str(out/'preview.png')
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(out/'Guildborne_Civic_Work.blend'));bpy.ops.render.render(write_still=True)
(out/'manifest.json').write_text(json.dumps(dict(clips=records,source='src/shared/Presentation/CivicWorkMotion.luau',status='LOCAL_OBJECT_HIERARCHY_REVIEW_CLIPS'),indent=2)+'\n',encoding='utf-8')
print('CIVIC_WORK_EXPORTED',len(records))
