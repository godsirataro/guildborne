"""Reviewed mesh intake/composition/export. Run Blender background with --disable-autoexec.
No imported scripts, generators, network, upload or gameplay mutation.
"""
from pathlib import Path
import bpy, bmesh, json, math, hashlib
from mathutils import Vector, Matrix

ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/production/world-slice'
records=json.loads((OUT/'intake.json').read_text(encoding='utf-8'))
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene
library=bpy.data.collections.new('Curated_CC0_Library');scene.collection.children.link(library)
composition=bpy.data.collections.new('Authored_Woodland_Threshold');scene.collection.children.link(composition)
stage=bpy.data.collections.new('Preview_Only_Stage');scene.collection.children.link(stage)
meshes=[];placements=[];templates={};metrics=[];structural={};colliders=[]
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
 structural[record['id']]=[]
 if record['id'] in ('stable','house','sawmill'):
  for o in objects:
   bm=bmesh.new();bm.from_mesh(o.data);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(o.data);bm.free()
   o.data.calc_loop_triangles()
   for tri in o.data.loop_triangles:
    points=[(o.matrix_world@o.data.vertices[i].co-center)*scale for i in tri.vertices]
    if (points[1]-points[0]).cross(points[2]-points[0]).length/2>15:
     structural[record['id']].append(points)
 vertices=[];triangles=[];colors=[];face_colors=[];selective_backs=0
 for o in objects:
  offset=len(vertices);matrix=o.matrix_world.copy()
  for v in o.data.vertices:
   pos=(matrix@v.co-center)*scale
   if record['id']=='path':pos.y*=.225
   vertices.append(pos)
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
   # Back only large structural roof/wall surfaces with a bounded inward offset.
   # No blanket shell or rim tessellation; silhouette and source colliders stay exact.
   if record['id'] in ('stable','house','sawmill') and (b-a).cross(c-a).length/2>15:
    # Coincident reversed faces sharing topology are ambiguous to mesh conversion.
    # Give only these structural backs their own vertices, 0.02 studs inward.
    normal=(b-a).cross(c-a).normalized();back=[]
    for point in (c,b,a):
     back.append(len(vertices));vertices.append(point-normal*.02)
    triangles.append(back);face_colors.append(colors.index(rgb)+1);selective_backs+=1
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
    v=vertices[idx];key=(round(v.x,5),round(v.z,5),round(-v.y,5))
    # Merge identical exported positions only; per-face colors/normals preserve seams.
    if key not in remap:
     remap[key]=len(coords)+1;coords.append(list(key))
    face.append(remap[key])
   faces.append(face)
  mid=record['id']+f'__{start//2000:03d}';chunk_ids.append(mid)
  bounds={'min':[min(v[i] for v in coords) for i in range(3)],'max':[max(v[i] for v in coords) for i in range(3)]}
  meshes.append(dict(id=mid,vertices=coords,triangles=faces,colors=colors,faceColors=face_colors[start:start+2000],bounds=bounds))
 record['chunks']=chunk_ids
 metrics.append(dict(id=record['id'],sourceBounds=[list(low),list(high)],scale=scale,vertices=len(vertices),triangles=len(triangles),selectiveBackTriangles=selective_backs,materials=len(colors),chunks=len(chunk_ids),height=max(v.z for v in vertices)))
 print('ASSET',record['id'],metrics[-1],flush=True)
 for o in imported:bpy.data.objects.remove(o,do_unlink=True)
# Original connected terrain surface recipe; all native collision remains unchanged.
import runpy
terrain_resources=runpy.run_path(str(ROOT/'production/world/quality-slice/terrain_recipe.py'))['make_terrain']()
silhouette_recipe=runpy.run_path(str(ROOT/'production/world/quality-slice/silhouette_recipe.py'))
silhouette_resources=silhouette_recipe['make_silhouette']()
for authored in terrain_resources+silhouette_resources:
 asset=authored['id'];coords=[[round(x,5),round(y-2,5),round(z-1410,5)] for x,y,z in authored['vertices']]
 verts=[Vector((x,-z,y)) for x,y,z in coords]
 faces=authored['triangles'];palette=authored['colors'];bands=authored['faceColors']
 mesh=bpy.data.meshes.new(asset);mesh.from_pydata(verts,[],faces);mesh.update()
 for index,rgb in enumerate(palette):
  mat=bpy.data.materials.new(asset+str(index));mat.use_nodes=True
  linear=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb]
  mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*linear,1)
  mat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=1
  mesh.materials.append(mat)
 for poly,band in zip(mesh.polygons,bands):poly.material_index=band-1
 template=bpy.data.objects.new(asset,mesh);library.objects.link(template);templates[asset]=template
 mid=asset+'__000'
 meshes.append(dict(id=mid,vertices=coords,triangles=[[i+1 for i in f] for f in faces],colors=palette,faceColors=bands,bounds={'min':[min(v[i] for v in coords) for i in range(3)],'max':[max(v[i] for v in coords) for i in range(3)]}))
 records.append(dict(id=asset,chunks=[mid]));structural[asset]=[]
 metrics.append(dict(id=asset,authorship='Original Guildborne authored surface/rock geometry; existing native gameplay retained',vertices=len(verts),triangles=len(faces),materials=len(palette),chunks=1))
library.hide_render=True;library.hide_viewport=True
by_id={r['id']:r for r in records}
def terrain_height(world_z):return 2 if world_z>=1380 else 6 if world_z<=1355 else 2+(1380-world_z)*.16
def collision_part(name,kind,size,center,rotation=None):
 r=rotation or Matrix.Identity(3)
 colliders.append(dict(name=name,kind=kind,size=[round(v,6) for v in size],cframe=[round(v,6) for v in center]+[round(r[i][j],8) for i in range(3) for j in range(3)]))
def collision_triangle(name,a,b,c):
 # Split on the longest side into two exact right triangular prisms. Roblox
 # WedgePart has its high edge at local +Z; normals are irrelevant to collision.
 pairs=[(a,b,c),(b,c,a),(c,a,b)];a,b,c=max(pairs,key=lambda p:(p[2]-p[1]).length_squared)
 axis=(c-b).normalized();foot=b+axis*(a-b).dot(axis);height=(a-foot).length
 if height<.05:return
 up=(a-foot).normalized()
 for i,end in enumerate((b,c)):
  length=(end-foot).length
  if length<.05:continue
  back=-(end-foot).normalized();right=up.cross(back).normalized()
  rotation=Matrix((right,up,back)).transposed()
  collision_part(name+f'_{i}','WedgePart',(.06,height,length),(a+end)/2,rotation)
def place(asset,name,x,y,yaw=0,z=None,pitch=0):
 if z is None:z=terrain_height(1410-y)-2
 obj=templates[asset].copy();obj.data=templates[asset].data;composition.objects.link(obj);obj.name=name
 obj.location=(x,y,z);obj.rotation_euler=(pitch,0,math.radians(yaw))
 theta=math.radians(yaw);c=round(math.cos(theta),8);s=round(math.sin(theta),8);cp=math.cos(pitch);sp=math.sin(pitch)
 # Explicit Greenwood art-preview placement, not a new travel destination.
 cf=[x,z+2,1410-y,c,s*sp,s*cp,0,cp,-sp,-s,c*sp,c*cp]
 for mid in by_id[asset]['chunks']:placements.append(dict(meshId=mid,name=name+'_'+mid,cframe=cf,scale=[1,1,1]))
 if structural[asset]:
  rot=Matrix((cf[3:6],cf[6:9],cf[9:12]));offset=Vector(cf[:3])
  for i,tri in enumerate(structural[asset]):
   world=[offset+rot@Vector((v.x,v.z,-v.y)) for v in tri]
   collision_triangle(name+f'_SourceSurface_{i}',*world)
 return obj
# A legible lived-in street opens into an older forest threshold. Architecture remains
# outside a 20-stud center aisle; curated silhouettes replace procedural cube art.
place('stable','Caravan_Stable',-40,-80,90)
place('house','Gatekeepers_House',36,-68,-90)
place('sawmill','Woodcutters_Lodge',-90,20,90)
place('cart','Arrival_Cart',-18,-62,15)
place('cart','Timber_Cart',-23,1,-25)
for i,(x,y) in enumerate([(-22,-40),(-25,-43),(22,-32),(24,-35),(-24,23)]):place('barrel',f'Provision_Barrel_{i}',x,y)
path_top=max(v.co.z for v in templates['path'].data.vertices)
for i,wz in enumerate(list(range(1507,1382,-8))+[1376,1368,1360]+[1351,1343,1335,1327]):
 slope=math.atan(.16) if 1355<wz<1380 else 0
 place('path',f'Worn_Causeway_{i}',0,1410-wz,z=terrain_height(wz)-2+.08-path_top,pitch=slope)
# Preserve native ramp/court collision; add a thin continuous road support following
# those same heights. This does not relocate any encounter or portal.
collision_part('ArrivalStreet','Part',(18,.16,64.5),(0,2,1412.25))
collision_part('ArrivalStreetSouth','Part',(18,.16,64.5),(0,2,1476.75))
collision_part('ForestRoad','Part',(18,.16,35),(0,6,1337.5))
collision_part('StableApron','Part',(44,.2,60),(-40,1.9,1490))
place('arch','Old_Greenwood_Arch',0,30)
place('ruin_wall','Ivy_Wall_West',-24,34,8)
place('ruin_wall','Ivy_Wall_East',24,38,180)
place('stag','Forest_Warden_Stag',23,59,-25)
bridge_top=max(v.co.z for v in templates['bridge'].data.vertices)
place('bridge','Old_Stone_Crossing',0,65,z=6.08-2-bridge_top)
collision_part('StoneCrossingDeck','Part',(18,.16,15.54),(0,6,1345))
place('bridge_support','Crossing_Foundation_West',-10,65,z=-9)
place('bridge_support','Crossing_Foundation_East',10,65,z=-9)
for i,(x,y,yaw) in enumerate([(-20,-67,0),(20,-64,0),(-20,-54,0),(20,-51,0),(-20,48,0),(20,44,0)]):place('fence',f'Roadside_Fence_{i}',x,y,yaw)
trees=[(-48,58),(-34,73),(-25,96),(-46,100),(-59,84),(36,83),(49,64),(31,108),(54,103),(60,82),(-59,40),(56,42),(-62,-7),(62,4)]
for i,(x,y) in enumerate(trees):place('tree_a' if i%2==0 else 'tree_b',f'Greenwood_Tree_{i}',x,y,(i*73)%360)
for i,(x,y) in enumerate([(-18,48),(19,53),(-28,60),(27,78),(-19,85),(20,94),(-45,44),(45,24),(-52,-24),(51,-48),(-25,-70),(24,-66)]):place('bush',f'Undergrowth_{i}',x,y,i*37)
# Authored groups frame inhabited courts and the two outer woodland edges.
# All additions remain outside combat envelopes/roads and on native Island Y2.
# Avoid terrain_height here: BossRise is elevated only within its X footprint.
for side,label in [(-1,'West'),(1,'East')]:
 for i,wz in enumerate((1480,1448,1322)):
  if side==1 and wz==1448:continue # review-camera rays to archer telegraphs must stay clear
  place('tree_a',f'GroundEdge_{label}_Tree_{i}',side*94,1410-wz,z=0)
 for i,(x,wz) in enumerate(((82,1468),(100,1460),(87,1440),(100,1435),(82,1340),(100,1344))):
  place('bush',f'GroundEdge_{label}_Bush_{i}',side*x,1410-wz,z=0)
for authored in terrain_resources:place(authored['id'],authored['id'],0,0,z=0)
for asset,name,x,wz,yaw in silhouette_recipe['PLACEMENTS']:place(asset,name,x,1410-wz,yaw,z=0)
# Reusable library and real composed GLB; preview base/lights do not enter game geometry.
packet=dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',pivot='asset XZ centered; minY=0; chunks share asset pivot',previewWorldOrigin=[0,2,1410],meshes=meshes,placements=placements,runtimeImported=False,compositionOnly=True)
(OUT/'world-slice.mesh.json').write_text(json.dumps(packet,separators=(',',':'))+'\n',encoding='utf-8')
mesh_lookup={m['id']:m for m in meshes}
art_contract=[]
for p in placements:
 bounds=mesh_lookup[p['meshId']]['bounds'];center=Vector([(a+b)/2 for a,b in zip(bounds['min'],bounds['max'])])
 cf=p['cframe'];r=Matrix((cf[3:6],cf[6:9],cf[9:12]));position=Vector(cf[:3])+r@center
 art_contract.append(dict(name=p['name'],meshId=p['meshId'],position=[round(v,5) for v in position],rotation=cf[3:]))
collision_data=dict(schemaVersion=1,sourceMeshSha256=hashlib.sha256((OUT/'world-slice.mesh.json').read_bytes()).hexdigest(),expectedArtNames=[p['name'] for p in placements],expectedArt=art_contract,minArtPlacements=len(placements),colliders=colliders)
(OUT/'collision.json').write_text(json.dumps(collision_data,indent=2)+'\n',encoding='utf-8')
def luau(value):
 if isinstance(value,str):return json.dumps(value)
 if isinstance(value,(int,float)):return repr(value)
 if isinstance(value,list):return '{'+','.join(luau(v) for v in value)+'}'
 return '{'+','.join('['+json.dumps(k)+']='+luau(v) for k,v in value.items())+'}'
(ROOT/'src/server/Services/WorldQualityAssets.luau').write_text('--!strict\n-- Generated source-derived static collision; opt-in only.\nreturn '+luau(collision_data)+'\n',encoding='utf-8')
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
stage_cube('PREVIEW_ONLY_Ground',(0,10,-2),(220,200,4),(.06848,.17789,.06480))
stage_cube('PREVIEW_ONLY_Landing',(0,-103,-2),(28,26,4),(.175,.078,.032))
stage_cube('PREVIEW_ONLY_StableApron',(-40,-100,-.1),(44,20,.2),(.06848,.17789,.06480))
stage_cube('PREVIEW_ONLY_BossCourt',(0,80,2),(96,50,4),(.1274,.0762,.0395))
# Native trails shown in previews; no invented river strip.
for x in (-60,60):stage_cube('PREVIEW_ONLY_Loop'+str(x),(x,-10,-1.95),(18,90,4),(.4564,.3185,.15))
for wz in (1450,1375):stage_cube('PREVIEW_ONLY_Cross'+str(wz),(0,1410-wz,-1.94),(138,18,4),(.4564,.3185,.15))
world=bpy.data.worlds.new('Woodland_Morning');scene.world=world;world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.15,.21,.26,1);world.node_tree.nodes['Background'].inputs[1].default_value=.45
bpy.ops.object.light_add(type='SUN',location=(0,0,100));sun=bpy.context.object;sun.rotation_euler=(math.radians(28),math.radians(-22),math.radians(-30));sun.data.energy=2.2;sun.data.angle=.12;link_only(sun,stage)
bpy.ops.object.light_add(type='AREA',location=(0,-30,120));light=bpy.context.object;light.data.energy=18000;light.data.shape='DISK';light.data.size=100;link_only(light,stage)
bpy.ops.object.camera_add(location=(155,-215,180));camera=bpy.context.object
camera.rotation_euler=(Vector((-10,0,10))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=295;scene.camera=camera;link_only(camera,stage)
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
