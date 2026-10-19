"""Render exact matched before/after cameras; native context remains schematic."""
from pathlib import Path
import json,hashlib,sys
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
CAMERAS=json.loads((HERE/'cameras.json').read_text(encoding='utf-8'))
GROUND=ROOT/'production/world/quality-slice/continuous-corridor/ground.json'
DESCRIPTOR=ROOT/'production/world/quality-slice/continuous-corridor/descriptor.json'
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def render(descriptor_path,ground_path):
    """Run only inside the explicitly handed-off Blender process."""
    import bpy
    from mathutils import Matrix,Vector
    packet=json.loads(PACKET.read_text(encoding='utf-8'))
    descriptor=json.loads(Path(descriptor_path).read_text(encoding='utf-8'))
    ground=json.loads(Path(ground_path).read_text(encoding='utf-8'))
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    conversion=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
    def mat(name,color):
        result=bpy.data.materials.new(name);result.diffuse_color=(*color,1)
        result.use_nodes=True;shader=result.node_tree.nodes.get('Principled BSDF')
        shader.inputs['Base Color'].default_value=(*color,1);shader.inputs['Roughness'].default_value=.9
        return result
    def place(mesh,name,cf,scale):
        obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj)
        r=Matrix((cf[3:6],cf[6:9],cf[9:12]));obj.matrix_world=(conversion@r).to_4x4()@Matrix.Diagonal((*scale,1))
        obj.location=conversion@Vector(cf[:3]);return obj
    resources={}
    for source in packet['meshes']:
        mesh=bpy.data.meshes.new(source['id']);mesh.from_pydata(source['vertices'],[],[[i-1 for i in t] for t in source['triangles']]);mesh.update()
        for i,color in enumerate(source['colors']):mesh.materials.append(mat(source['id']+str(i),color))
        for face,ci in zip(mesh.polygons,source['faceColors']):face.material_index=ci-1
        resources[source['id']]=mesh
    for p in packet['placements']:place(resources[p['meshId']],p['name'],p['cframe'],p['scale'])
    vertices=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,-.5),(.5,.5,-.5),(.5,.5,.5),(-.5,.5,.5)]
    faces=[(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]
    wedge_vertices=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
    wedge_faces=[(1,2,3,0),(2,5,4,3),(4,5,1,0),(3,4,0),(5,2,1)]
    for i,p in enumerate(ground['parts']):
        mesh=bpy.data.meshes.new('native_ground_'+str(i))
        wedge=p.get('className')=='WedgePart'
        mesh.from_pydata(wedge_vertices if wedge else vertices,[],wedge_faces if wedge else faces);mesh.update()
        mesh.materials.append(mat('native_'+str(i),p['color']))
        place(mesh,p.get('name',str(i)),p['position']+p['rotation'],p['size'])
    # Context boxes are explicit schematic references, excluded from asset export.
    # They communicate pre-existing land bounds, not imported scene completeness.
    for name,center,size,color in [
        ('REFERENCE_ONLY_CityBounds',[0,-.5,-1130],[920,1,1020],[.26,.29,.25]),
        ('REFERENCE_ONLY_GreenwoodLanding',[0,1,1513],[28,2,26],[.35,.40,.27])]:
        mesh=bpy.data.meshes.new(name);mesh.from_pydata(vertices,[],faces);mesh.materials.append(mat(name,color))
        place(mesh,name,center+[1,0,0,0,1,0,0,0,1],size)
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=CAMERAS['samples']
    scene.render.resolution_x=CAMERAS['resolution'][0];scene.render.resolution_y=CAMERAS['resolution'][1];scene.render.resolution_percentage=100
    scene.view_settings.view_transform='Standard'
    scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.42,.53,.65,1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value=.65
    bpy.ops.object.light_add(type='SUN',location=(0,0,200));bpy.context.object.data.energy=2.1
    bpy.context.object.rotation_euler=(.55,-.35,-.5)
    bpy.ops.object.camera_add();camera=bpy.context.object;scene.camera=camera;camera.data.lens=28;camera.data.clip_end=12000
    views=[(v['name'],v['eye'],v['target']) for v in CAMERAS['views']]
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'landforms.blend'))
    for name,eye,target in views:
        camera.location=conversion@Vector(eye)
        camera.rotation_euler=((conversion@Vector(target))-camera.location).to_track_quat('-Z','Y').to_euler()
        scene.render.filepath=str(OUT/(name+'.png'));bpy.ops.render.render(write_still=True)
    evidence=dict(status='BLENDER_RENDERED_NOT_STUDIO',groundPath=str(ground_path),groundSha256=digest(Path(ground_path)),
        sourceSha256=digest(Path(__file__)),packetSha256=digest(PACKET),cameraSha256=digest(HERE/'cameras.json'),groundParts=len(ground['parts']),views=[v[0] for v in views],
        context='City bounds and Greenwood landing are explicitly schematic reference boxes; omitted game geometry is not claimed imported',
        hashes={p.name:digest(p) for p in OUT.glob('*.png')})
    (OUT/'render-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n',encoding='utf-8')



if __name__=='__main__':
 import argparse
 parser=argparse.ArgumentParser();parser.add_argument('--variant',choices=['before','after'],required=True)
 args=parser.parse_args(sys.argv[sys.argv.index('--')+1:])
 PACKET=ROOT/('assets/production/world-slice/bespoke-spire/scenery.mesh.json' if args.variant=='before' else 'assets/production/world-slice/coast-prop-composition/scenery.mesh.json')
 OUT=ROOT/'assets/production/world-slice/coast-prop-composition'/args.variant;OUT.mkdir(parents=True,exist_ok=True)
 render(DESCRIPTOR,GROUND)
