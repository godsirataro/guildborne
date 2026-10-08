"""Render/export the exact shared architectural kit, preserving collision metadata."""
import bpy,json,math,sys,argparse
from pathlib import Path
from mathutils import Matrix,Vector
parser=argparse.ArgumentParser();parser.add_argument('--city',default='Crownford');parser.add_argument('--set',choices=['services','institutions'],default='services');args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]if '--'in sys.argv else[])
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01'/f'{args.city.lower()}-{args.set}-v1';d=json.loads((O/'kit.json').read_text());kinds=list(d['buildings'])
bpy.ops.wm.read_factory_settings(use_empty=True);s=bpy.context.scene
C=Matrix(((1,0,0),(0,0,-1),(0,1,0)));materials={};groups={}
for kind,building in d['buildings'].items():
 col=bpy.data.collections.new(kind);s.collection.children.link(col);objects=[];offset=Vector((-20 if kind==kinds[0] else 20,0,0))
 for i,p in enumerate(building['parts']):
  color=tuple(p['color'])
  if color not in materials:
   m=bpy.data.materials.new('Crownford_'+str(len(materials)));m.use_nodes=True;c=[v/255 for v in color];c=[v/12.92 if v<=.04045 else((v+.055)/1.055)**2.4 for v in c];m.diffuse_color=(*c,1);bs=m.node_tree.nodes['Principled BSDF'];bs.inputs['Base Color'].default_value=(*c,1);bs.inputs['Roughness'].default_value=.72;materials[color]=m
  if p['shape']=='Ball':bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=8,radius=.5)
  elif p['shape']=='Cylinder':
   bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=.5,depth=1);bpy.context.object.rotation_euler[1]=math.pi/2;bpy.ops.object.transform_apply(location=False,rotation=True,scale=False)
  else:bpy.ops.mesh.primitive_cube_add(size=1)
  obj=bpy.context.object;obj.name=f'{kind}_{i:03}_{p["name"]}';scale=p['size'];obj.scale=(scale[0],scale[2],scale[1]);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
  rx,ry,rz=[math.radians(x)for x in p['rotation']];rot=Matrix.Rotation(rx,3,'X')@Matrix.Rotation(ry,3,'Y')@Matrix.Rotation(rz,3,'Z');obj.rotation_euler=(C@rot@C.transposed()).to_euler();obj.location=C@Vector(p['position'])+offset;obj.data.materials.append(materials[color]);obj['Collision']=p['collision'];obj['SourceIndex']=i
  for current in list(obj.users_collection):current.objects.unlink(obj)
  col.objects.link(obj);objects.append(obj)
 groups[kind]=objects
expected={}
for kind,objects in groups.items():
 offset=Vector((-20 if kind==kinds[0] else 20,0,0))
 for o in objects:o.location-=offset
 bpy.context.view_layer.update()
 expected[kind]={}
 for o in objects:
  points=[o.matrix_world@v.co for v in o.data.vertices]
  expected[kind][o.name]={'min':[min(p[i]for p in points)for i in range(3)],'max':[max(p[i]for p in points)for i in range(3)],'collision':o['Collision'],'triangles':sum(len(p.vertices)-2 for p in o.data.polygons)}
 bpy.ops.object.select_all(action='DESELECT')
 for o in objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(O/(kind+'.glb')),use_selection=True,export_format='GLB',export_animations=False,export_extras=True)
 bpy.ops.export_scene.fbx(filepath=str(O/(kind+'.fbx')),use_selection=True,object_types={'MESH'},bake_anim=False,use_custom_props=True,axis_forward='-Z',axis_up='Y')
 for o in objects:o.location+=offset
(O/'export-geometry.json').write_text(json.dumps(expected,indent=2)+'\n')
s.world=bpy.data.worlds.new('CrownfordStudio');s.world.use_nodes=True;s.world.node_tree.nodes['Background'].inputs[0].default_value=(.22,.29,.36,1);s.world.node_tree.nodes['Background'].inputs[1].default_value=.6
sys.path.insert(0,str(R/'tools'))
from civic_interior_lighting import add_interior_lights
add_interior_lights()
for location,power,size in [((0,-35,55),65000,45),((-35,-10,30),35000,30),((15,30,45),50000,30)]:
 bpy.ops.object.light_add(type='AREA',location=location);o=bpy.context.object;o.data.energy=power;o.data.shape='DISK';o.data.size=size;o.rotation_euler=(Vector((0,0,7))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(62,-95,62));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,8))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=88;s.camera=cam
s.render.engine='CYCLES';s.cycles.samples=24;s.render.resolution_x=1500;s.render.resolution_y=1000;s.render.resolution_percentage=100;s.view_settings.view_transform='AgX';bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(O/f'Guildborne_{args.city}_{args.set.title()}.blend'))
s.render.filepath=str(O/'preview.png');bpy.ops.render.render(write_still=True)
cam.data.type='PERSP';cam.data.lens=20;s.render.resolution_x=1100;s.render.resolution_y=750
for kind,x in zip(kinds,[-20,20]):
 cam.location=(x,-10,5.5);cam.rotation_euler=(Vector((x,8,4.5))-cam.location).to_track_quat('-Z','Y').to_euler();s.render.filepath=str(O/(kind.lower()+'-interior.png'));bpy.ops.render.render(write_still=True)
manifest={'status':'LOCAL_ARCHITECTURE_STUDY','objects':{k:len(v)for k,v in groups.items()},'doorWidth':8,'doorClearance':10,'centralAisleWidth':8,'render':'preview.png','platformImported':False,'humanApproved':False}
(O/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
