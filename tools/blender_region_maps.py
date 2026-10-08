"""Export original region shells with the same collision geometry as native Studio kit."""
from pathlib import Path
import bpy,json,math
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/region-kit';data=json.loads((OUT/'kit.json').read_text(encoding='utf-8'));report=[]
for a in data['assets']:
    bpy.ops.wm.read_factory_settings(use_empty=True);scene=bpy.context.scene;materials={}
    for name,rgb in data['palette'].items():
        linear=lambda v:(v/255)/12.92 if v/255<=.04045 else ((v/255+.055)/1.055)**2.4
        m=bpy.data.materials.new(name);m.use_nodes=True;m.diffuse_color=(*map(linear,rgb),1);m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=m.diffuse_color;m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.8;materials[name]=m
    parts=[]
    for p in a['parts']:
        if p['shape']=='Wedge':
            # Roblox high face +Z -> Blender -Y. Six vertices, five manifold faces.
            vertices=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,.5,-.5),(.5,.5,-.5),(-.5,-.5,.5),(.5,-.5,.5)]
            faces=[(0,2,3,1),(0,1,5,4),(0,4,2),(1,3,5),(2,4,5,3)]
            mesh=bpy.data.meshes.new(p['name']);mesh.from_pydata(vertices,[],faces);mesh.update();o=bpy.data.objects.new(p['name'],mesh);scene.collection.objects.link(o)
        else:bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object;o.name=p['name']
        x,y,z=p['position'];sx,sy,sz=p['size'];o.location=(x,-z,y);o.scale=(sx,sz,sy);o.rotation_euler.z=math.radians(p['yaw']);o.data.materials.append(materials[p['color']]);o['CanCollide']=p['collide'];parts.append(o)
    bpy.ops.object.select_all(action='DESELECT')
    for o in parts:o.select_set(True)
    bpy.context.view_layer.objects.active=parts[0];bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    triangles=0
    for o in parts:o.data.calc_loop_triangles();triangles+=len(o.data.loop_triangles)
    bpy.ops.export_scene.fbx(filepath=str(OUT/(a['id']+'.fbx')),use_selection=True,object_types={'MESH'},bake_anim=False,axis_forward='-Z',axis_up='Y')
    bpy.ops.export_scene.gltf(filepath=str(OUT/(a['id']+'.glb')),use_selection=True,export_format='GLB',export_animations=False)
    for entry in a['markers']:
        x,y,z=entry['position'];bpy.ops.object.empty_add(type='PLAIN_AXES',location=(x,-z,y));o=bpy.context.object;o.name='MARKER_'+entry['name'];o['Role']=entry['role']
    scene.world=bpy.data.worlds.new('RegionStudio');scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.12,.18,.24,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.8
    bpy.ops.object.light_add(type='AREA',location=(20,-50,200));o=bpy.context.object;o.data.energy=220000;o.data.size=220
    bpy.ops.object.camera_add(location=(210,-290,250));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,0))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=340;scene.camera=cam
    scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True;scene.render.resolution_x=1400;scene.render.resolution_y=1200;scene.render.resolution_percentage=100;scene.render.image_settings.file_format='PNG';scene.view_settings.view_transform='Standard'
    scene.render.filepath=str(OUT/(a['id']+'.png'));bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/(a['id']+'.blend')));bpy.ops.render.render(write_still=True)
    report.append(dict(id=a['id'],parts=len(parts),triangles=triangles,markers=len(a['markers']),runtimeBound=False))
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print('REGION_MAP_EXPORTS',len(report))
