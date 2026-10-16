"""Reviewed mesh intake/composition/export. Run Blender background with --disable-autoexec.
No imported scripts, generators, network, upload or gameplay mutation.
"""
from pathlib import Path
import bpy, json, math, hashlib
from mathutils import Vector

ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/production/world-slice'
records=json.loads((OUT/'intake.json').read_text(encoding='utf-8'))
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene
library=bpy.data.collections.new('Curated_CC0_Library');scene.collection.children.link(library)
composition=bpy.data.collections.new('Authored_Woodland_Threshold');scene.collection.children.link(composition)
stage=bpy.data.collections.new('Preview_Only_Stage');scene.collection.children.link(stage)
meshes=[];placements=[];templates={};metrics=[]
def srgb(v):return max(0,min(1,12.92*v if v<=.0031308 else 1.055*v**(1/2.4)-.055))
def color(mat):
 c=mat.diffuse_color[:3] if mat else (.35,.35,.35)
 if mat and mat.use_nodes:
  node=next((n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None)
  if node:c=node.inputs['Base Color'].default_value[:3]
 return [round(srgb(float(v)),5) for v in c]
def link_only(obj,collection):
 for c in list(obj.users_collection):c.objects.unlink(obj)
 collection.objects.link(obj)
for record in records:
 source=ROOT/record['source'];assert hashlib.sha256(source.read_bytes()).hexdigest()==record['sourceSha256']
 before=set(bpy.data.objects)
 bpy.ops.import_scene.fbx(filepath=str(source),use_anim=False)
 imported=[o for o in bpy.data.objects if o not in before]
 objects=[o for o in imported if o.type=='MESH']
 assert objects,record['id']
 points=[o.matrix_world@v.co for o in objects for v in o.data.vertices]
 low=Vector([min(v[i] for v in points) for i in range(3)])
 high=Vector([max(v[i] for v in points) for i in range(3)])
 center=Vector(((low.x+high.x)/2,(low.y+high.y)/2,low.z))
 scale=record['height']/max(.001,high.z-low.z) if record['height'] else 18/(high.x-low.x)
 vertices=[];triangles=[];colors=[];face_colors=[]
 for o in objects:
  offset=len(vertices);matrix=o.matrix_world.copy()
  for v in o.data.vertices:vertices.append((matrix@v.co-center)*scale)
  o.data.calc_loop_triangles()
  for tri in o.data.loop_triangles:
   indices=[offset+i for i in tri.vertices]
   a,b,c=(vertices[i] for i in indices)
   if (b-a).cross(c-a).length<1e-8:continue
   material=o.data.materials[tri.material_index] if tri.material_index<len(o.data.materials) else None
   rgb=color(material)
   # Ruins foliage FBXs carry white/unbound diffuse material in this source.
   # Author a small matte palette from real face geometry instead of inventing a texture binding.
   if record['id'].startswith('tree_'):
    height=((a.z+b.z+c.z)/3)/(scale*(high.z-low.z))
    rgb=([.28,.20,.12] if height<.43 else
         ([.25,.43,.19] if height<.67 else [.36,.53,.25]))
   elif record['id']=='bush':rgb=[.31,.46,.20]
   elif record['id']=='ruin_wall' and min(rgb)>.8:rgb=[.27,.42,.18]
   elif record['id']=='stag':rgb=[.49,.51,.42]
   if rgb not in colors:colors.append(rgb)
   triangles.append(indices);face_colors.append(colors.index(rgb)+1)
 assert triangles
 # Keep original material colors, with roughness unified for a coherent matte miniature look.
 material_list=[]
 for i,rgb in enumerate(colors):
  mat=bpy.data.materials.new(record['id']+f'_palette_{i}');mat.use_nodes=True
  linear=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb]
  mat.diffuse_color=(*linear,1);node=mat.node_tree.nodes['Principled BSDF']
  node.inputs['Base Color'].default_value=(*linear,1);node.inputs['Roughness'].default_value=.82
  material_list.append(mat)
 asset_mesh=bpy.data.meshes.new(record['id']);asset_mesh.from_pydata(vertices,[],triangles);asset_mesh.update()
 for mat in material_list:asset_mesh.materials.append(mat)
 for poly,ci in zip(asset_mesh.polygons,face_colors):poly.material_index=ci-1;poly.use_smooth=False
 template=bpy.data.objects.new(record['id'],asset_mesh);library.objects.link(template)
 templates[record['id']]=template
 chunk_ids=[]
 for start in range(0,len(triangles),2000):
  remap={};coords=[];faces=[]
  for tri in triangles[start:start+2000]:
   face=[]
   for idx in tri:
    if idx not in remap:
     remap[idx]=len(coords)+1;v=vertices[idx];coords.append([round(v.x,5),round(v.z,5),round(-v.y,5)])
    face.append(remap[idx])
   faces.append(face)
  mid=record['id']+f'__{start//2000:03d}';chunk_ids.append(mid)
  bounds={'min':[min(v[i] for v in coords) for i in range(3)],'max':[max(v[i] for v in coords) for i in range(3)]}
  meshes.append(dict(id=mid,vertices=coords,triangles=faces,colors=colors,faceColors=face_colors[start:start+2000],bounds=bounds))
 record['chunks']=chunk_ids
 metrics.append(dict(id=record['id'],sourceBounds=[list(low),list(high)],scale=scale,vertices=len(vertices),triangles=len(triangles),materials=len(colors),chunks=len(chunk_ids),height=max(v.z for v in vertices)))
 print('ASSET',record['id'],metrics[-1],flush=True)
 for o in imported:bpy.data.objects.remove(o,do_unlink=True)
library.hide_render=True;library.hide_viewport=True
by_id={r['id']:r for r in records}
def place(asset,name,x,y,yaw=0,z=0):
 obj=templates[asset].copy();obj.data=templates[asset].data;composition.objects.link(obj);obj.name=name
 obj.location=(x,y,z);obj.rotation_euler.z=math.radians(yaw)
 theta=math.radians(yaw);c=round(math.cos(theta),8);s=round(math.sin(theta),8)
 # Explicit Greenwood art-preview placement, not a new travel destination.
 cf=[x,z+2,1410-y,c,0,s,0,1,0,-s,0,c]
 for mid in by_id[asset]['chunks']:placements.append(dict(meshId=mid,name=name+'_'+mid,cframe=cf,scale=[1,1,1]))
 return obj
# A legible lived-in street opens into an older forest threshold. Architecture remains
# outside a 20-stud center aisle; curated silhouettes replace procedural cube art.
place('stable','Caravan_Stable',-35,-38,90)
place('house','Gatekeepers_House',34,-32,-90)
place('sawmill','Woodcutters_Lodge',-41,20,90)
place('cart','Arrival_Cart',-18,-62,15)
place('cart','Timber_Cart',-23,1,-25)
for i,(x,y) in enumerate([(-22,-40),(-25,-43),(22,-32),(24,-35),(-24,23)]):place('barrel',f'Provision_Barrel_{i}',x,y)
for i,y in enumerate([-80,-46,-12,22,56,90]):place('path',f'Worn_Causeway_{i}',0,y)
place('arch','Old_Greenwood_Arch',0,30)
place('ruin_wall','Ivy_Wall_West',-24,34,8)
place('ruin_wall','Ivy_Wall_East',24,38,180)
place('stag','Forest_Warden_Stag',23,59,-25)
place('bridge','Old_Stone_Crossing',0,65)
place('bridge_support','Crossing_Foundation_West',-10,65,z=-9)
place('bridge_support','Crossing_Foundation_East',10,65,z=-9)
for i,(x,y,yaw) in enumerate([(-20,-67,0),(20,-64,0),(-20,-54,0),(20,-51,0),(-20,48,0),(20,44,0)]):place('fence',f'Roadside_Fence_{i}',x,y,yaw)
trees=[(-48,58),(-34,73),(-25,96),(-46,100),(-59,84),(36,83),(49,64),(31,108),(54,103),(60,82),(-59,40),(56,42),(-62,-7),(62,4)]
for i,(x,y) in enumerate(trees):place('tree_a' if i%2==0 else 'tree_b',f'Greenwood_Tree_{i}',x,y,(i*73)%360)
for i,(x,y) in enumerate([(-18,48),(19,53),(-28,60),(27,78),(-19,85),(20,94),(-45,44),(45,24),(-52,-24),(51,-48),(-25,-70),(24,-66)]):place('bush',f'Undergrowth_{i}',x,y,i*37)
# Reusable library and real composed GLB; preview base/lights do not enter game geometry.
packet=dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',pivot='asset XZ centered; minY=0; chunks share asset pivot',previewWorldOrigin=[0,2,1410],meshes=meshes,placements=placements,runtimeImported=False,compositionOnly=True)
(OUT/'world-slice.mesh.json').write_text(json.dumps(packet,separators=(',',':'))+'\n',encoding='utf-8')
bpy.ops.object.select_all(action='DESELECT')
for o in composition.objects:o.select_set(True)
bpy.context.view_layer.objects.active=next(iter(composition.objects))
bpy.ops.export_scene.gltf(filepath=str(OUT/'woodland-threshold.glb'),export_format='GLB',use_selection=True,export_animations=False)
# Staging only: soft beveled presentation plinth and an unobtrusive water strip.
def stage_cube(name,location,scale,rgb,bevel=0):
 bpy.ops.mesh.primitive_cube_add(size=1,location=location);o=bpy.context.object;o.name=name;o.scale=scale
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);link_only(o,stage)
 mat=bpy.data.materials.new(name);mat.use_nodes=True;mat.diffuse_color=(*rgb,1)
 mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*rgb,1)
 mat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.9;o.data.materials.append(mat)
 if bevel:m=o.modifiers.new('Soft display edge','BEVEL');m.width=bevel;m.segments=3
 return o
stage_cube('PREVIEW_ONLY_Ground',(0,12,-2),(145,205,4),(.13,.21,.12),3)
stage_cube('PREVIEW_ONLY_Stream',(0,65,.04),(135,8,.08),(.045,.24,.26))
world=bpy.data.worlds.new('Woodland_Morning');scene.world=world;world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.15,.21,.26,1);world.node_tree.nodes['Background'].inputs[1].default_value=.45
bpy.ops.object.light_add(type='SUN',location=(0,0,100));sun=bpy.context.object;sun.rotation_euler=(math.radians(28),math.radians(-22),math.radians(-30));sun.data.energy=2.2;sun.data.angle=.12;link_only(sun,stage)
bpy.ops.object.light_add(type='AREA',location=(0,-30,120));light=bpy.context.object;light.data.energy=18000;light.data.shape='DISK';light.data.size=100;link_only(light,stage)
bpy.ops.object.camera_add(location=(155,-215,180));camera=bpy.context.object
camera.rotation_euler=(Vector((0,15,10))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=255;scene.camera=camera;link_only(camera,stage)
scene.render.engine='CYCLES';scene.cycles.samples=32;scene.cycles.use_denoising=True
scene.render.resolution_x=1400;scene.render.resolution_y=1400;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.view_settings.view_transform='AgX'
scene.render.filepath=str(OUT/'woodland-threshold.png');bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'woodland-threshold.blend'))
bpy.ops.render.render(write_still=True)
summary=dict(status='BLENDER_EXPORTED_NOT_STUDIO_IMPORTED',blender=bpy.app.version_string,assets=metrics,uniqueMeshChunks=len(meshes),placements=len(placements),authoredObjects=len(composition.objects),uniqueTriangles=sum(len(m['triangles']) for m in meshes),instancedTriangles=sum(len(next(m for m in meshes if m['id']==p['meshId'])['triangles']) for p in placements),runtimeIds=None,studioTested=False,humanApproved=False)
summary['files']={p.name:dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in OUT.iterdir() if p.is_file() and p.name!='export-report.json' and p.suffix!='.log'}
(OUT/'export-report.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
print('WORLD_SLICE_EXPORTED',summary['uniqueTriangles'],summary['instancedTriangles'],flush=True)
