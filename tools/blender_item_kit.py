"""Build/render thirty original inventory meshes, icons and portable exports."""
from pathlib import Path
import bpy,json,math,sys,argparse
from mathutils import Matrix,Vector
ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser();parser.add_argument('--kit',default='assets/uat01/item-kit');parser.add_argument('--name',default='Guildborne_Item_Kit');parser.add_argument('--max-triangles',type=int,default=300)
parser.add_argument('--large-assets',action='store_true')
parser.add_argument('--front-view',action='store_true',help='Show authored +Z fronts and elevated gallery views')
options=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else []);OUT=ROOT/options.kit
data=json.loads((OUT/'kit.json').read_text(encoding='utf-8'))
bpy.ops.wm.read_factory_settings(use_empty=True)
materials={}
for name,rgb in data['palette'].items():
    def linear(v):
        v/=255;return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
    m=bpy.data.materials.new(name);m.use_nodes=True;m.diffuse_color=(*map(linear,rgb),1)
    m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=m.diffuse_color
    m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.65;materials[name]=m
convert=Matrix(((1,0,0),(0,0,-1),(0,1,0)));records=[];models=[]
scene=bpy.context.scene;scene.world=bpy.data.worlds.new('InventoryStudio');scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.4,.4,.4,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.7
scene.render.engine='CYCLES';scene.cycles.samples=16;scene.cycles.use_denoising=True
scene.render.resolution_x=512;scene.render.resolution_y=512;scene.render.resolution_percentage=100
scene.render.film_transparent=True;scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA';scene.view_settings.view_transform='Standard'
for pos,power in [((3,4,7),900),((-4,-2,4),600)]:
    bpy.ops.object.light_add(type='AREA',location=pos);lamp=bpy.context.object;lamp.data.energy=power;lamp.data.size=6
    lamp.rotation_euler=(Vector((0,0,0))-lamp.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add();camera=bpy.context.object;camera.data.type='ORTHO';scene.camera=camera
for a in data['assets']:
    pieces=[]
    for part in a['parts']:
        if part.get('shape')=='Wedge':
            verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
            mesh=bpy.data.meshes.new(part['name']);mesh.from_pydata([convert@Vector(v) for v in verts],[],[(0,1,3,2),(2,3,5,4),(0,2,4),(1,5,3),(0,4,5,1)])
            o=bpy.data.objects.new(part['name'],mesh);scene.collection.objects.link(o)
        else:bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object
        o.name=part['name'];o.location=convert@Vector(part['position']);o.scale=(part['size'][0],part['size'][2],part['size'][1])
        rx,ry,rz=map(math.radians,part['rotation']);rotation=Matrix.Rotation(rx,3,'X')@Matrix.Rotation(ry,3,'Y')@Matrix.Rotation(rz,3,'Z')
        o.rotation_euler=(convert@rotation@convert.inverted()).to_euler();o.data.materials.append(materials[part['color']]);pieces.append(o)
    bpy.ops.object.select_all(action='DESELECT')
    for o in pieces:o.select_set(True)
    bpy.context.view_layer.objects.active=pieces[0];bpy.ops.object.join();o=bpy.context.object;o.name=a['id']
    scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR');bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    o.data.calc_loop_triangles();triangles=len(o.data.loop_triangles);assert triangles<options.max_triangles
    bpy.ops.export_scene.fbx(filepath=str(OUT/(a['id']+'.fbx')),use_selection=True,object_types={'MESH'},add_leaf_bones=False,bake_anim=False,axis_forward='-Z',axis_up='Y')
    bpy.ops.export_scene.gltf(filepath=str(OUT/(a['id']+'.glb')),use_selection=True,export_format='GLB')
    bounds=[o.matrix_world@Vector(v) for v in o.bound_box];center=sum(bounds,Vector())/8
    radius=max((v-center).length for v in bounds)
    if options.large_assets:
        for lamp,pos,power in zip([v for v in scene.objects if v.type=='LIGHT'],[(3,4,7),(-4,-2,4)],[900,600]):
            lamp.location=center+Vector(pos).normalized()*radius*3;lamp.data.energy=power*radius*radius;lamp.data.size=radius*1.5
            lamp.rotation_euler=(center-lamp.location).to_track_quat('-Z','Y').to_euler()
    direction=(1,-3,1.8) if options.front_view else (1,3,.8)
    camera.location=center+Vector(direction).normalized()*(max(12,radius*3) if options.large_assets else 12);camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.ortho_scale=radius*2.4
    scene.render.filepath=str(OUT/(a['id']+'.png'));bpy.ops.render.render(write_still=True)
    records.append({'id':a['id'],'triangles':triangles,'bounds':list(o.dimensions),'sourceParts':len(a['parts']),'icon':a['id']+'.png','robloxMeshAssetId':None,'robloxImageAssetId':None})
    models.append((o,center));o.hide_render=True
columns=4 if len(models)<=8 else 6;rows=math.ceil(len(models)/columns)
for i,(o,center) in enumerate(models):
    x=((columns-1)/2-i%columns)*4.2;z=(rows-1-i//columns)*4.7
    scale=3.3/max(o.dimensions);o.scale*=scale
    orientation=Matrix.Rotation(math.radians(-25),3,'X')@Matrix.Rotation(math.radians(155),3,'Z') if options.front_view else Matrix.Identity(3)
    o.rotation_euler=orientation.to_euler();o.location=Vector((x,0,z))-orientation@center*scale;o.hide_render=False
    bpy.ops.object.text_add(location=(x+1.7,.3,z-2.15),rotation=(math.pi/2,0,math.pi))
    label=bpy.context.object;label.data.body=o.name.replace('_',' ').upper();label.data.size=.17;label.data.materials.append(materials['ivory'])
targetZ=(rows-1)*4.7/2;camera.location=(0,45,targetZ);camera.rotation_euler=(Vector((0,0,targetZ))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.ortho_scale=20 if columns==4 else 28
scene.render.resolution_x=1600;scene.render.resolution_y=1500;scene.render.filepath=str(OUT/'preview.png')
scene.world.node_tree.nodes['Background'].inputs[1].default_value=.9
for lamp in [o for o in scene.objects if o.type=='LIGHT']:bpy.data.objects.remove(lamp,do_unlink=True)
bpy.ops.object.light_add(type='AREA',location=(0,15,17));lamp=bpy.context.object;lamp.data.energy=6500;lamp.data.size=28
lamp.rotation_euler=(Vector((0,0,10))-lamp.location).to_track_quat('-Z','Y').to_euler()
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/(options.name+'.blend')))
bpy.ops.render.render(write_still=True)
(OUT/'export-report.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
print('ITEM_KIT_COMPLETE',len(records),sum(r['triangles'] for r in records),'triangles')
