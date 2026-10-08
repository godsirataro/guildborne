"""Export original native district geometry into editable Blender and per-city meshes."""
from pathlib import Path
import bpy,json,math
from mathutils import Matrix,Vector
r=Path(__file__).resolve().parents[1];out=r/'assets/uat01/city-districts'
data=json.loads((out/'native-layouts-v2.json').read_text(encoding='utf-8'))
bpy.ops.wm.read_factory_settings(use_empty=True)
conversion=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
materials={};manifest=[];collections=[]
for city in data['cities']:
 collection=bpy.data.collections.new(city['name']);bpy.context.scene.collection.children.link(collection);collections.append(collection)
 objects=[]
 for index,p in enumerate(city['parts']):
  bpy.ops.mesh.primitive_cube_add(size=1)
  obj=bpy.context.object;obj.name=f"{city['name']}_{index:03}_{p['name']}"
  for c in list(obj.users_collection):c.objects.unlink(obj)
  collection.objects.link(obj)
  x,y,z=p['size'];obj.scale=(x*.1,z*.1,y*.1)
  c=p['cframe'];rotation=Matrix((c[3:6],c[6:9],c[9:12]));obj.rotation_euler=(conversion@rotation@conversion.inverted()).to_euler()
  obj.location=conversion@Vector(c[:3])*.1
  key=tuple(round(v,4)for v in p['color'])
  if key not in materials:
   mat=bpy.data.materials.new('CityColor_'+str(len(materials)));mat.diffuse_color=(*key,1);materials[key]=mat
  obj.data.materials.append(materials[key]);obj['roblox_collide']=p['collide'];obj['native_name']=p['name'];objects.append(obj)
 bpy.ops.object.select_all(action='DESELECT')
 for obj in objects:obj.select_set(True)
 bpy.context.view_layer.objects.active=objects[0]
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 name=city['name'].lower()+'-district-v2'
 bpy.ops.export_scene.fbx(filepath=str(out/(name+'.fbx')),use_selection=True,object_types={'MESH'},add_leaf_bones=False,bake_anim=False)
 bpy.ops.export_scene.gltf(filepath=str(out/(name+'.glb')),use_selection=True,export_format='GLB',export_yup=True)
 points=[o.matrix_world@Vector(v)for o in objects for v in o.bound_box]
 bounds=[min(p[i]for p in points)for i in range(3)]+[max(p[i]for p in points)for i in range(3)]
 manifest.append(dict(id=name,city=city['name'],identity=city['identity'],parts=len(objects),triangles=len(objects)*12,bounds=bounds,studToMeter=.1,markers=city['markers'],runtimeBound=False))
for index,collection in enumerate(collections):
 for obj in collection.objects:obj.location+=Vector(((index%3)*25,-(index//3)*30,0))
scene=bpy.context.scene;scene.render.engine='BLENDER_WORKBENCH';scene.display.shading.light='STUDIO';scene.display.shading.color_type='MATERIAL'
scene.display.shading.show_shadows=True;scene.display.shading.show_cavity=True;scene.display.shading.cavity_type='BOTH'
scene.display.shading.background_type='WORLD';scene.world=bpy.data.worlds.new('World');scene.world.color=(.065,.085,.12)
bpy.ops.object.camera_add(location=(65,-95,115));camera=bpy.context.object;camera.rotation_euler=(Vector((25,-15,0))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=92;scene.camera=camera
scene.render.resolution_x=1800;scene.render.resolution_y=1300;scene.render.resolution_percentage=100;scene.render.image_settings.file_format='PNG';scene.render.filepath=str(out/'city-districts-v2-preview.png')
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(out/'Guildborne_City_Districts_v2.blend'))
bpy.ops.render.render(write_still=True)
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print('CITY_DISTRICT_EXPORT_PASS',len(manifest),sum(x['parts']for x in manifest))
