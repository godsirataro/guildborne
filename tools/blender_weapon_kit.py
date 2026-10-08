"""Export original weapon definitions at their hand-grip pivots."""
from pathlib import Path
import bpy,json,math
from mathutils import Matrix,Vector
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/weapon-kit'
data=json.loads((OUT/'kit.json').read_text(encoding='utf-8'))
bpy.ops.wm.read_factory_settings(use_empty=True);materials={}
for name,rgb in data['palette'].items():
    def linear(v):
        v/=255
        return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
    m=bpy.data.materials.new(name);m.use_nodes=True;m.diffuse_color=(*map(linear,rgb),1)
    m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=m.diffuse_color
    m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.65;materials[name]=m
convert=Matrix(((1,0,0),(0,0,-1),(0,1,0)));records=[]
for index,asset in enumerate(data['assets']):
    objects=[]
    for part in asset['parts']:
        if part.get('shape')=='Wedge':
            # Wedge in Y-up authoring coordinates, converted before object rotation.
            vertices=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
            mesh=bpy.data.meshes.new(part['name']);mesh.from_pydata([convert@Vector(v) for v in vertices],[],[(0,1,3,2),(2,3,5,4),(0,2,4),(1,5,3),(0,4,5,1)])
            o=bpy.data.objects.new(part['name'],mesh);bpy.context.scene.collection.objects.link(o)
        else:
            bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object
        o.name=part['name'];o.location=convert@Vector(part['position'])
        o.scale=(part['size'][0],part['size'][2],part['size'][1]);rx,ry,rz=map(math.radians,part['rotation']);rotation=Matrix.Rotation(rx,3,'X')@Matrix.Rotation(ry,3,'Y')@Matrix.Rotation(rz,3,'Z')
        o.rotation_euler=(convert@rotation@convert.inverted()).to_euler();o.data.materials.append(materials[part['color']]);objects.append(o)
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.join();o=bpy.context.object;o.name=asset['id']
    bpy.context.scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR');bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    o.data.calc_loop_triangles();triangles=len(o.data.loop_triangles);assert triangles<300
    bpy.ops.export_scene.fbx(filepath=str(OUT/(asset['id']+'.fbx')),use_selection=True,object_types={'MESH'},add_leaf_bones=False,bake_anim=False,axis_forward='-Z',axis_up='Y')
    bpy.ops.export_scene.gltf(filepath=str(OUT/(asset['id']+'.glb')),use_selection=True,export_format='GLB')
    records.append({'id':asset['id'],'triangles':triangles,'bounds':list(o.dimensions),'pivot':'grip','robloxMeshAssetId':None})
    o.location=((index-2)*3.1,0,2)
    bpy.ops.object.text_add(location=(o.location.x-1.15,-1.8,.05));label=bpy.context.object;label.data.body=asset['id'].replace('_',' ').upper();label.data.size=.24;label.data.materials.append(materials['ivory'])
bpy.ops.mesh.primitive_plane_add(size=100,location=(0,0,-.03));stage=bpy.context.object
mat=bpy.data.materials.new('Stage');mat.diffuse_color=(.06,.08,.13,1);mat.use_nodes=True;mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=mat.diffuse_color;stage.data.materials.append(mat)
scene=bpy.context.scene;scene.world=bpy.data.worlds.new('World');scene.world.color=(.2,.2,.2)
for loc,power,size in [((0,-6,13),3500,10),((-9,3,8),2000,9)]:
    bpy.ops.object.light_add(type='AREA',location=loc);light=bpy.context.object;light.data.energy=power;light.data.size=size
    light.rotation_euler=(Vector((0,0,2))-light.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(9,-19,15));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,3))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=19;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.render.resolution_x=1600;scene.render.resolution_y=900;scene.render.resolution_percentage=100
scene.view_settings.view_transform='Standard';scene.render.image_settings.file_format='PNG';scene.render.filepath=str(OUT/'preview.png')
(OUT/'export-report.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_Weapon_Kit.blend'));bpy.ops.render.render(write_still=True)
print('WEAPON_EXPORT_COMPLETE',len(records),sum(r['triangles'] for r in records),'triangles')
