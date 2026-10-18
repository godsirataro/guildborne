"""Matched source-geometry renders. No Roblox screenshot or runtime actors are simulated."""
import argparse,json,math,sys
from pathlib import Path
import bpy
from mathutils import Matrix,Vector

parser=argparse.ArgumentParser();parser.add_argument('--geometry',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--view-set',choices=('entry','corridor'),default='entry');args=parser.parse_args(sys.argv[sys.argv.index('--')+1:])
args.geometry=args.geometry.resolve();args.output=args.output.resolve()
args.output.mkdir(parents=True,exist_ok=True)
data=json.loads(args.geometry.read_text())
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene
conversion=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
materials={}
def linear(v):return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
for part in data['parts']:
 if part['transparency']>=1:continue
 color=tuple(part['color']);key=(color,part['material'])
 if key not in materials:
  mat=bpy.data.materials.new(part['material']+'_'+str(len(materials)));mat.use_nodes=True
  mat.diffuse_color=(*map(linear,color),1);bsdf=mat.node_tree.nodes['Principled BSDF'];bsdf.inputs['Base Color'].default_value=mat.diffuse_color;bsdf.inputs['Roughness'].default_value=.85
  materials[key]=mat
 if part['className']=='WedgePart':
  mesh=bpy.data.meshes.new('NativeWedge');mesh.from_pydata([(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)],[],[(1,2,3,0),(2,5,4,3),(4,5,1,0),(3,4,0),(5,2,1)])
  mesh.update();obj=bpy.data.objects.new('NativeWedge',mesh);bpy.context.collection.objects.link(obj);bpy.context.view_layer.objects.active=obj
 elif part['shape']=='Ball':bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,radius=.5)
 elif part['shape']=='Cylinder':
  bpy.ops.mesh.primitive_cylinder_add(vertices=16,radius=.5,depth=1)
  # Roblox cylinder's longitudinal axis is local X, Blender's is Z.
  for vertex in bpy.context.object.data.vertices:vertex.co=Matrix.Rotation(math.pi/2,3,'Y')@vertex.co
 else:
  assert part['shape']=='Block',part['shape']
  bpy.ops.mesh.primitive_cube_add(size=1)
 obj=bpy.context.object;obj.name=part['name'];r=part['rotation'];rotation=Matrix((r[0:3],r[3:6],r[6:9]))
 obj.matrix_world=(conversion@rotation).to_4x4()@Matrix.Diagonal((*part['size'],1))
 obj.location=conversion@Vector(part['position']);obj.data.materials.append(materials[key])
 obj['source_stage']=part['stage'];obj['source_collides']=part['collision']
scene.world=bpy.data.worlds.new('SourcePreviewSky');scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.48,.59,.70,1)
scene.world.node_tree.nodes['Background'].inputs[1].default_value=.65
bpy.ops.object.light_add(type='SUN');sun=bpy.context.object;sun.rotation_euler=(.5,-.35,-.45);sun.data.energy=2;sun.data.angle=.15
bpy.ops.object.camera_add();camera=bpy.context.object;scene.camera=camera;camera.data.lens=32;camera.data.clip_end=2000
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True
scene.render.resolution_x=1440;scene.render.resolution_y=900;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.view_settings.view_transform='Standard'
views={'entry':((30,22,244),(-15,10,165)),'courier':((-34,18,182),(-65,6,149)),'overview':((220,250,350),(0,0,100))}
if args.view_set=='corridor':
 views={'arrival-player':((0,6,180),(3,5,85)),'training-player':((8,6,109),(66,5,82)),'caravan-player':((-9,6,54),(-65,5,20)),'corridor-overview':((190,155,215),(0,2,90))}
for name,(eye,target) in views.items():
 camera.location=conversion@Vector(eye);camera.rotation_euler=(conversion@Vector(target)-camera.location).to_track_quat('-Z','Y').to_euler()
 scene.render.filepath=str(args.output/(name+'.png'));bpy.ops.render.render(write_still=True)
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(args.output/'source-preview.blend'))
(args.output/'render-receipt.json').write_bytes((json.dumps({'evidence':'BLENDER_SOURCE_PREVIEW_NOT_STUDIO','input':str(args.geometry),'views':views,'resolution':[1440,900],'lensMm':32,'runtimeActorsIncluded':False,'visibleParts':sum(p['transparency']<1 for p in data['parts'])},indent=2)+'\n').encode())
print('MATCHED_SOURCE_RENDER_COMPLETE',args.geometry.name)
