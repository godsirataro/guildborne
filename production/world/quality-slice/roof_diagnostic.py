"""Local diagnostic only: emulate one-sided rendering from exported Blender geometry."""
import bpy,json,math,sys,subprocess
from pathlib import Path
from mathutils import Vector,Matrix
root=Path(__file__).resolve().parents[3]
bpy.ops.wm.open_mainfile(filepath=str(root/'assets/production/world-slice/woodland-threshold.blend'))
scene=bpy.context.scene
# Optional exact JSON reconstruction, using exported chunk vertices and placement matrices.
if '--json' in sys.argv:
 for obj in list(bpy.data.collections['Authored_Woodland_Threshold'].objects):bpy.data.objects.remove(obj,do_unlink=True)
 packet=json.loads(subprocess.check_output(['git','-C',str(root),'show','0e3b07f:assets/production/world-slice/world-slice.mesh.json']) if '--baseline' in sys.argv else (root/'assets/production/world-slice/world-slice.mesh.json').read_bytes())
 models={}
 for m in packet['meshes']:
  mesh=bpy.data.meshes.new(m['id']);mesh.from_pydata([(v[0],-v[2],v[1]) for v in m['vertices']],[],[[i-1 for i in f] for f in m['triangles']]);mesh.update()
  for index,c in enumerate(m['colors']):
   mat=bpy.data.materials.new(m['id']+str(index));mat.use_nodes=True
   linear=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in c]
   mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*linear,1);mat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.82
   mesh.materials.append(mat)
  for f,c in zip(mesh.polygons,m['faceColors']):f.material_index=c-1
  models[m['id']]=mesh
 basis=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
 for p in packet['placements']:
  obj=bpy.data.objects.new(p['name'],models[p['meshId']]);scene.collection.objects.link(obj)
  cf=p['cframe'];rotation=basis@Matrix((cf[3:6],cf[6:9],cf[9:12]))@basis.transposed()
  obj.rotation_euler=rotation.to_euler();obj.location=(cf[0],1410-cf[2],cf[1]-2)
  if '--extra-center' in sys.argv:
   m=next(m for m in packet['meshes'] if m['id']==p['meshId'])
   center=Vector([(a+b)/2 for a,b in zip(m['bounds']['min'],m['bounds']['max'])])
   obj.location+=rotation@(basis@center)
for mat in bpy.data.materials:
 if not mat.use_nodes:continue
 nodes=mat.node_tree.nodes;links=mat.node_tree.links
 output=next((n for n in nodes if n.type=='OUTPUT_MATERIAL'),None)
 if not output or not output.inputs['Surface'].links:continue
 surface=output.inputs['Surface'].links[0].from_socket
 geo=nodes.new('ShaderNodeNewGeometry');mix=nodes.new('ShaderNodeMixShader');transparent=nodes.new('ShaderNodeBsdfTransparent')
 links.new(geo.outputs['Backfacing'],mix.inputs[0]);links.new(surface,mix.inputs[1]);links.new(transparent.outputs[0],mix.inputs[2]);links.new(mix.outputs[0],output.inputs['Surface'])
scene.camera.location=(105,-135,92)
scene.camera.rotation_euler=(Vector((0,0,6))-scene.camera.location).to_track_quat('-Z','Y').to_euler()
scene.camera.data.type='PERSP';scene.camera.data.lens=24
scene.render.resolution_x=1000;scene.render.resolution_y=1000;scene.cycles.samples=24
scene.render.filepath=str(root/'production/world/quality-slice'/('roof-extra-center.png' if '--extra-center' in sys.argv else 'roof-json-before.png' if '--baseline' in sys.argv else 'roof-json-after.png' if '--json' in sys.argv else 'roof-source-cull.png'))
bpy.ops.render.render(write_still=True)
