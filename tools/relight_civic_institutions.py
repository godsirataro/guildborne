"""Update institution lighting/banner contrast, retaining verified geometry."""
import bpy,sys,json
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parents[1];sys.path.insert(0,str(R/'tools'))
from civic_interior_lighting import add_interior_lights
cities=sys.argv[sys.argv.index('--')+1:]if '--'in sys.argv else['Crownford','Sylvaris','Deepforge','Astralis','Crosshaven','Ironroot']
for city in cities:
 O=R/f'assets/uat01/{city.lower()}-institutions-v1';blend=O/f'Guildborne_{city}_Institutions.blend';bpy.ops.wm.open_mainfile(filepath=str(blend));s=bpy.context.scene
 kit=json.loads((O/'kit.json').read_text())
 banner=next(p for p in kit['buildings']['QuestHall']['parts']if p['name']=='CharterBanner')
 for obj in s.objects:
  if obj.name.endswith('_CharterBanner'):
   mat=obj.data.materials[0].copy();obj.data.materials[0]=mat;color=[v/255 for v in banner['color']];color=[v/12.92 if v<=.04045 else((v+.055)/1.055)**2.4 for v in color];mat.diffuse_color=(*color,1);mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*color,1)
 # Export the same selected mesh collections after the contrast correction.
 for kind,x in [('Forge',-20),('QuestHall',20)]:
  objects=[o for o in bpy.data.collections[kind].objects if o.type=='MESH'];bpy.ops.object.select_all(action='DESELECT')
  for obj in objects:obj.location.x-=x;obj.select_set(True)
  bpy.context.view_layer.update()
  bpy.ops.export_scene.gltf(filepath=str(O/(kind+'.glb')),use_selection=True,export_format='GLB',export_animations=False,export_extras=True)
  bpy.ops.export_scene.fbx(filepath=str(O/(kind+'.fbx')),use_selection=True,object_types={'MESH'},bake_anim=False,use_custom_props=True,axis_forward='-Z',axis_up='Y')
  for obj in objects:obj.location.x+=x
 add_interior_lights();s.render.engine='BLENDER_EEVEE';bpy.context.preferences.filepaths.save_version=0
 camera=s.camera;camera.data.type='ORTHO';camera.data.ortho_scale=88;camera.location=(62,-95,62);camera.rotation_euler=(Vector((0,0,8))-camera.location).to_track_quat('-Z','Y').to_euler()
 s.render.resolution_x=1500;s.render.resolution_y=1000;s.render.filepath=str(O/'preview.png');bpy.ops.wm.save_as_mainfile(filepath=str(blend));bpy.ops.render.render(write_still=True)
 camera.data.type='PERSP';camera.data.lens=20;s.render.resolution_x=1100;s.render.resolution_y=750
 for kind,x in [('Forge',-20),('QuestHall',20)]:
  camera.location=(x,-10,5.5);camera.rotation_euler=(Vector((x,8,4.5))-camera.location).to_track_quat('-Z','Y').to_euler();s.render.filepath=str(O/(kind.lower()+'-interior.png'));bpy.ops.render.render(write_still=True)
 p=O/'manifest.json';d=json.loads(p.read_text());d['reviewLighting']='Authored lantern and ember point lights; Eevee preview, geometry exports unchanged';p.write_text(json.dumps(d,indent=2)+'\n');print('RELIT',city)
