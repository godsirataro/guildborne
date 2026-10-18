"""Bounded corridor dressing from reviewed local meshes; no network or uploads.

make_art receives the coordinator's finalized centerline. Rendering is separate
and must use an actual generated ground packet, never an illustrative floor.
"""
from pathlib import Path
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parents[4]
SOURCE = ROOT / 'assets/production/world-slice/world-slice.mesh.json'
OUT = ROOT / 'assets/production/world-slice/continuous-corridor'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sample(points, distance):
    for a, b in zip(points, points[1:]):
        length = math.hypot(b[0]-a[0], b[2]-a[2])
        if distance <= length:
            t = distance / length
            return ([a[i] + (b[i]-a[i])*t for i in range(3)],
                    [(b[0]-a[0])/length, (b[2]-a[2])/length])
        distance -= length
    raise ValueError('Station outside centerline')


def original_mesh(name, boxes):
    m = dict(id=name,vertices=[],triangles=[],colors=[[.25,.20,.14],[.38,.39,.34]],faceColors=[])
    for center,size,color in boxes:
        start=len(m['vertices'])
        m['vertices'].extend([[center[i]+size[i]*sign[i]/2 for i in range(3)]
            for sign in [(-1,-1,-1),(1,-1,-1),(1,-1,1),(-1,-1,1),(-1,1,-1),(1,1,-1),(1,1,1),(-1,1,1)]])
        for face in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]:
            for tri in [(face[0],face[1],face[2]),(face[0],face[2],face[3])]:
                m['triangles'].append([start+j+1 for j in tri]);m['faceColors'].append(color)
    m['bounds']={key:[fn(v[i] for v in m['vertices']) for i in range(3)] for key,fn in [('min',min),('max',max)]}
    return m


def default_stations(points,total):
    stations=[]
    for i in range(24):
        distance=310+(total-560)*i/23
        if 810 < distance < 1040: continue
        side=1 if i%2 else -1
        stations.append(dict(distance=distance,offset=29,side=side,
            meshId='tree_a__000' if i%3 else 'tree_b__000',scale=.8 if i%3 else .65))
        stations.append(dict(distance=distance+14,offset=22,side=side,
            meshId='bush__000' if i%2 else 'silhouette_fern_rocks__000',scale=.8))
    for i in range(8):
        stations.append(dict(distance=280+(total-540)*i/7,offset=19,side=-1 if i%2 else 1,
            meshId='silhouette_ruined_waymarker__000',scale=1))
    stations.extend([
        dict(distance=total-180,offset=28,side=1,meshId='tree_a__000',scale=.7),
        dict(distance=total-130,offset=22,side=1,meshId='tree_a__000',scale=.55),
        dict(distance=total-95,offset=19,side=1,meshId='bush__000',scale=.7),
        dict(distance=total-165,offset=23,side=1,meshId='silhouette_fern_rocks__000',scale=.7)])
    return stations


def cliff_mesh(ground):
    m=dict(id='corridor_original_cliff',vertices=[],triangles=[],faceColors=[],
        colors=[[.31,.34,.28],[.39,.40,.32],[.27,.30,.27],[.34,.37,.30]])
    sections=ground['crosssections']
    for side in (0,1):
        for index,(a,b) in enumerate(zip(sections,sections[1:])):
            rings=[]
            for section_index,section in enumerate((a,b)):
                edge=section['shoulder'][side];center=section['center']
                rings.append([[center[0]+(edge[0]-center[0])*scale,edge[1]-depth,
                               center[2]+(edge[2]-center[2])*scale]
                              for scale,depth in ((1,.03),(.95,8+2*math.sin(index+section_index)**2),(.65,24))])
            for level in (0,1):
                quad=[rings[0][level],rings[1][level],rings[1][level+1],rings[0][level+1]]
                for ids in ((0,1,2),(0,2,3)):
                    tri=[quad[i] for i in ids]
                    u=[tri[1][i]-tri[0][i] for i in range(3)];v=[tri[2][i]-tri[0][i] for i in range(3)]
                    normal=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
                    outward=[a['shoulder'][side][i]-a['center'][i] for i in range(3)]
                    if normal[0]*outward[0]+normal[2]*outward[2]<0:tri.reverse()
                    start=len(m['vertices']);m['vertices'].extend(tri)
                    m['triangles'].append([start+1,start+2,start+3]);m['faceColors'].append(1+(index+level)%4)
    m['bounds']={key:[fn(v[i] for v in m['vertices']) for i in range(3)] for key,fn in [('min',min),('max',max)]}
    return m


def make_art(descriptor,ground=None):
    source = json.loads(SOURCE.read_text(encoding='utf-8'))
    wanted = ('tree_a__000', 'tree_b__000', 'bush__000',
              'silhouette_fern_rocks__000', 'silhouette_ruined_waymarker__000')
    meshes = [m for m in source['meshes'] if m['id'] in wanted]
    assert len(meshes) == len(wanted)
    points = descriptor['centerline']
    total = sum(math.hypot(b[0]-a[0], b[2]-a[2]) for a,b in zip(points,points[1:]))
    placements = []
    # Exact stations are supplied by geometry so roots sit on real shoulders.
    # Each station may exclude trees (bridge approaches, short sightline zones).
    for index, station in enumerate(descriptor.get('artStations', default_stations(points,total))):
        p, tangent = sample(points, station['distance'])
        normal = [-tangent[1], tangent[0]]
        side = station.get('side', -1 if index % 2 else 1)
        offset = station['offset'] * side
        yaw = math.atan2(tangent[0], tangent[1]) + (index % 5)*.37
        asset = station.get('meshId', wanted[index % len(wanted)])
        assert asset in wanted
        scale = station.get('scale', 1)
        x,z = p[0]+normal[0]*offset,p[2]+normal[1]*offset
        y = station.get('groundY',p[1]-.20)
        c,s = math.cos(yaw),math.sin(yaw)
        placements.append(dict(meshId=asset,name=f'CorridorScenery_{index:03d}',
            cframe=[x,y,z,c,0,s,0,1,0,-s,0,c],scale=[scale]*3,
            collision=False,query=False,touch=False))
    # Original rail/support silhouettes outside the 24-stud clear walking lane.
    rail_boxes=[]
    for x in (-15,15):
        for z in range(-60,61,20):
            rail_boxes.append(([x,-4,z],[1.2,16,1.2],1))
        for y in (1.8,4):rail_boxes.append(([x,y,0],[.7,.7,130],1))
        rail_boxes.append(([x,-1.2,0],[2,2,130],2))
    bridge=original_mesh('corridor_bridge_rails',rail_boxes)
    lookout=original_mesh('corridor_lookout_pier',[
        ([0,-5,0],[5,10,5],2),([0,.4,0],[6,.8,6],2),([0,3,0],[1.4,5,1.4],1),
        ([0,5.5,0],[3,.8,3],2)])
    meshes.extend([bridge,lookout])
    p,t=sample(points,900);yaw=math.atan2(t[0],t[1]);c,s=math.cos(yaw),math.sin(yaw)
    placements.append(dict(meshId=bridge['id'],name='Corridor_OriginalCliffBridge',
        cframe=p+[c,0,s,0,1,0,-s,0,c],scale=[1,1,1],collision=False,query=False,touch=False))
    p=points[6]
    for i,x in enumerate((-30,30)):
        placements.append(dict(meshId=lookout['id'],name=f'Corridor_LookoutPier_{i}',
            cframe=[p[0]+x,p[1],p[2],1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    if ground:
        cliff=cliff_mesh(ground);meshes.append(cliff)
        placements.append(dict(meshId=cliff['id'],name='Corridor_OriginalRockSkirt',
            cframe=[0,0,0,1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    assert 0 < len(placements) <= 120, 'Finalized art stations required (1..120)'
    packet = dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',
        pivot='Inherited reviewed asset pivot; absolute placements',
        meshes=meshes,placements=placements,runtimeImported=False,
        compositionOnly=True,runtimeIds=None)
    provenance = dict(status='FILE_GENERATED_ONLY',source=str(SOURCE.relative_to(ROOT)),
        sourceSha256=digest(SOURCE),routeLength=total,
        intake='assets/production/world-slice/intake.json',
        licenses=['assets/production/world-slice/village-LICENSE.txt',
                  'assets/production/world-slice/ruins-LICENSE.txt'],
        originalRecipes=['production/world/quality-slice/silhouette_recipe.py',str(Path(__file__).relative_to(ROOT))],
        meshReuse='Five exact reviewed mesh records; unchanged vertices, triangles and colors. Bridge, lookout and cliff are original recipe geometry.',
        meshCount=len(meshes),placementCount=len(placements),
        instanceTriangles=sum(len(next(m for m in meshes if m['id']==p['meshId'])['triangles']) for p in placements),
        runtimeIds=None,studioTested=False,humanApproved=False)
    return packet,provenance


def write_packet(descriptor_path,ground_path=None):
    descriptor = json.loads(Path(descriptor_path).read_text(encoding='utf-8'))
    ground=json.loads(Path(ground_path).read_text(encoding='utf-8')) if ground_path else None
    packet, provenance = make_art(descriptor,ground)
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'scenery.mesh.json').write_text(json.dumps(packet,separators=(',',':'))+'\n',encoding='utf-8')
    provenance['descriptorSha256'] = digest(Path(descriptor_path))
    (OUT/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n',encoding='utf-8')
    return packet


def render(descriptor_path,ground_path):
    """Run only inside the explicitly handed-off Blender process."""
    import bpy
    from mathutils import Matrix,Vector
    packet=write_packet(descriptor_path,ground_path)
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
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=24
    scene.render.resolution_x=1440;scene.render.resolution_y=900;scene.render.resolution_percentage=100
    scene.view_settings.view_transform='Standard'
    scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.42,.53,.65,1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value=.65
    bpy.ops.object.light_add(type='SUN',location=(0,0,200));bpy.context.object.data.energy=2.1
    bpy.context.object.rotation_euler=(.55,-.35,-.5)
    bpy.ops.object.camera_add();camera=bpy.context.object;scene.camera=camera;camera.data.lens=28;camera.data.clip_end=12000
    bridge,_=sample(descriptor['centerline'],925)
    views=[('overview',[1100,1700,1700],[-150,0,400]),
           ('citygate',[60,32,-700],[-60,2,-555]),
           ('cliffbridge',[bridge[0]+45,25,bridge[2]-110],[bridge[0],6,bridge[2]+65]),
           ('forestarrival',[-185,12,1535],[-30,5,1550])]
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'corridor.blend'))
    for name,eye,target in views:
        camera.location=conversion@Vector(eye)
        camera.rotation_euler=((conversion@Vector(target))-camera.location).to_track_quat('-Z','Y').to_euler()
        scene.render.filepath=str(OUT/(name+'.png'));bpy.ops.render.render(write_still=True)
    evidence=dict(status='BLENDER_RENDERED_NOT_STUDIO',groundPath=str(ground_path),groundSha256=digest(Path(ground_path)),
        sourceSha256=digest(Path(__file__)),groundParts=len(ground['parts']),views=[v[0] for v in views],
        context='City bounds and Greenwood landing are explicitly schematic reference boxes; omitted game geometry is not claimed imported',
        hashes={p.name:digest(p) for p in OUT.glob('*.png')})
    (OUT/'render-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n',encoding='utf-8')


if __name__=='__main__':
    import argparse,sys
    parser=argparse.ArgumentParser();parser.add_argument('--descriptor',required=True)
    parser.add_argument('--ground');parser.add_argument('--render',action='store_true')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else sys.argv[1:])
    if args.render:
        if not args.ground:parser.error('--render requires actual --ground')
        render(args.descriptor,args.ground)
    else:write_packet(args.descriptor,args.ground)
