"""Original asymmetric landforms around the immutable reviewed corridor floor.

All new landscape is presentation-only. This recipe imports no remote files,
does not upload assets, and does not certify the scenery as traversable.
"""
from pathlib import Path
import hashlib
import json
import math

ROOT=Path(__file__).resolve().parents[4]
OUT=ROOT/'assets/production/world-slice/corridor-landforms'
SOURCE=ROOT/'assets/production/world-slice/continuous-corridor/scenery.mesh.json'
GROUND=ROOT/'production/world/quality-slice/continuous-corridor/ground.json'
DESCRIPTOR=ROOT/'production/world/quality-slice/continuous-corridor/descriptor.json'
IDENTITY=[0,0,0,1,0,0,0,1,0,0,0,1]
PALETTE=[[.29,.39,.23],[.34,.43,.26],[.39,.45,.29],[.25,.34,.22],
         [.39,.40,.33],[.32,.35,.31],[.25,.29,.28],[.45,.43,.34],
         [.33,.38,.32],[.26,.33,.30]]


def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def sample(points,distance):
    for a,b in zip(points,points[1:]):
        length=math.hypot(b[0]-a[0],b[2]-a[2])
        if distance<=length:
            t=distance/length
            return [a[i]+(b[i]-a[i])*t for i in range(3)],[(b[0]-a[0])/length,(b[2]-a[2])/length]
        distance-=length
    raise ValueError('Outside route')


def newmesh(name):return dict(id=name,vertices=[],triangles=[],colors=PALETTE,faceColors=[])


def tri(mesh,vertices,color,up=True):
    a,b,c=vertices
    ny=(b[2]-a[2])*(c[0]-a[0])-(b[0]-a[0])*(c[2]-a[2])
    if up and ny<0:vertices=[a,c,b]
    start=len(mesh['vertices']);mesh['vertices'].extend(vertices)
    mesh['triangles'].append([start+1,start+2,start+3]);mesh['faceColors'].append(color)


def bounds(mesh):
    mesh['bounds']={k:[fn(v[i] for v in mesh['vertices']) for i in range(3)] for k,fn in [('min',min),('max',max)]}


def landforms(ground):
    original=ground['crosssections'];sections=[]
    # Midsections improve the broad silhouette without changing floor triangles.
    for a,b in zip(original,original[1:]):
        for t in (0,.5):
            sections.append(dict(center=[a['center'][i]*(1-t)+b['center'][i]*t for i in range(3)],
                shoulder=[[a['shoulder'][s][i]*(1-t)+b['shoulder'][s][i]*t for i in range(3)] for s in (0,1)]))
    sections.append(original[-1])
    accumulated=[0]
    for a,b in zip(sections,sections[1:]):accumulated.append(accumulated[-1]+math.dist(a['center'],b['center']))
    total=accumulated[-1];meshes=[];profile=[]
    for side in (0,1):
        m=newmesh('landforms_west' if side==0 else 'landforms_east');rows=[]
        for index,section in enumerate(sections):
            cx,cy,cz=section['center'];edge=section['shoulder'][side]
            dx,dz=edge[0]-cx,edge[2]-cz;edge_len=math.hypot(dx,dz);dx/=edge_len;dz/=edge_len
            distance=accumulated[index]
            taper=min(1,max(0,(distance-40)/340),max(0,(total-distance-40)/330))
            taper=taper*taper*(3-2*taper)
            width=(190+170*math.exp(-((cz-340)/400)**2)+110*math.exp(-((cz-1050)/290)**2)) if side==0 else (110+130*math.exp(-((cz-730)/320)**2))
            width*=taper
            # Steep western ravine beside the bridge; rolling ridge further out.
            valley=math.exp(-((distance-900)/150)**2)
            ridge=(54+28*math.sin(cz*.003+1)**2) if side==0 else (20+25*math.sin(cz*.004)**2)
            row=[]
            for ring,t in enumerate((0,.12,.27,.43,.60,.76,.89,1)):
                spread=width*t*(1+.06*math.sin(cz*.018+side)*math.sin(math.pi*t))
                x,z=edge[0]+dx*spread,edge[2]+dz*spread
                # This conservative broad buffer also catches triangles crossing
                # the private belt with endpoints outside its exact Z bounds.
                if -280<z<340 and x>-190:x=-190
                if ring==0:y=edge[1]-.035
                elif ring==1:y=cy-1.0-14*valley*taper
                elif ring==2:y=cy+(ridge*.37-28*valley)*taper
                elif ring==3:y=cy+ridge*taper*(.78+.22*math.sin(cz*.009+side))
                elif ring==4:y=cy+ridge*.42*taper-6
                elif ring==5:y=-10-8*math.sin(cz*.012+side)**2
                elif ring==6:y=-25-9*math.sin(cz*.008)**2
                else:y=-66-10*math.sin(cz*.006+side)**2
                # Existing city and Greenwood surfaces remain on top.
                if -620<=x<=620 and z<=-470:y=min(y,-10.6)
                if -120<=x<=120 and 1280<=z<=1532:y=min(y,1.2)
                # Prevent narrow taper ends from becoming tall vertical fins.
                if taper<.1 and ring>0:y=min(y,edge[1]-.05-ring*.5)
                row.append([x,y,z])
            rows.append(row)
            profile.append(dict(side=side,index=index,center=section['center'],outer=row[-1],crest=row[3]))
        for i,(a,b) in enumerate(zip(rows,rows[1:])):
            for ring in range(7):
                color=(1+(i+ring)%3) if ring<4 else (5+(i+ring)%4)
                quad=[a[ring],b[ring],b[ring+1],a[ring+1]]
                # Alternate diagonals avoid a repeated sawtooth stripe.
                ids=((0,1,2),(0,2,3)) if i%2 else ((0,1,3),(1,2,3))
                for indices in ids:tri(m,[quad[j] for j in indices],color)
        bounds(m);meshes.append(m)
    return meshes,profile


def landmark():
    m=newmesh('landforms_ruined_beacon')
    # Original decagonal broken watch-spire, built in world coordinates.
    cx,cz=-565,460
    rings=[]
    for level,(radius,height) in enumerate(((18,-12),(15,54),(11,85),(10,112))):
        ring=[]
        for i in range(10):
            angle=2*math.pi*i/10
            y=height+(9*math.sin(i*2.1) if level==3 else 0)
            ring.append([cx+math.cos(angle)*radius,y,cz+math.sin(angle)*radius])
        rings.append(ring)
    for a,b in zip(rings,rings[1:]):
        for i in range(10):
            j=(i+1)%10
            tri(m,[a[i],a[j],b[j]],5+i%3,False);tri(m,[a[i],b[j],b[i]],5+i%3,False)
    for i in range(10):tri(m,[[cx,108,cz],rings[-1][i],rings[-1][(i+1)%10]],8,False)
    bounds(m);return m


def chunk(mesh):
    results=[]
    for start in range(0,len(mesh['triangles']),2000):
        part=newmesh(mesh['id']+f'__{start//2000:03d}');part['colors']=mesh['colors']
        mapping={}
        for triangle,color in zip(mesh['triangles'][start:start+2000],mesh['faceColors'][start:start+2000]):
            face=[]
            for index in triangle:
                if index not in mapping:
                    mapping[index]=len(part['vertices'])+1;part['vertices'].append(mesh['vertices'][index-1])
                face.append(mapping[index])
            part['triangles'].append(face);part['faceColors'].append(color)
        bounds(part);results.append(part)
    return results


def write_packet(descriptor_path=DESCRIPTOR,ground_path=GROUND):
    source=json.loads(SOURCE.read_text());ground=json.loads(Path(ground_path).read_text())
    packet={**source,'meshes':[m for m in source['meshes'] if m['id']!='corridor_original_cliff'],
        'placements':[p for p in source['placements'] if p['meshId']!='corridor_original_cliff']}
    generated,profile=landforms(ground);generated.append(landmark())
    water=newmesh('landforms_coastal_water');water['colors']=[[.12,.28,.32]]
    for face in ([[-1500,-12.6,-90],[-190,-12.6,-90],[-190,-12.6,1900]],
                 [[-1500,-12.6,-90],[-190,-12.6,1900],[-1500,-12.6,1900]]):tri(water,face,1)
    bounds(water);generated.append(water)
    for mesh in generated:
        for part in chunk(mesh):
            packet['meshes'].append(part)
            packet['placements'].append(dict(meshId=part['id'],name=part['id'],cframe=IDENTITY,scale=[1,1,1],collision=False,query=False,touch=False))
    unique=sum(len(m['triangles']) for m in packet['meshes']);lookup={m['id']:m for m in packet['meshes']}
    instanced=sum(len(lookup[p['meshId']]['triangles']) for p in packet['placements'])
    assert unique<=12000 and instanced<=50000 and len(packet['placements'])<=100
    assert len(ground['parts'])==444
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'scenery.mesh.json').write_text(json.dumps(packet,separators=(',',':'))+'\n')
    (OUT/'profiles.json').write_text(json.dumps(profile,indent=2)+'\n')
    provenance=dict(status='FILE_GENERATED_NOT_STUDIO',source=str(SOURCE.relative_to(ROOT)),sourceSha256=digest(SOURCE),
        groundSha256=digest(ground_path),groundParts=444,unchangedSceneryPlacements=57,
        author='Original Guildborne procedural landforms and beacon; reviewed existing art retained exactly',
        collisions='None on all new landforms; native approved ground remains separate',
        uniqueTriangles=unique,instanceTriangles=instanced,meshes=len(packet['meshes']),placements=len(packet['placements']),
        maxChunkTriangles=max(len(m['triangles']) for m in packet['meshes']),runtimeIds=None,studioTested=False,humanApproved=False)
    (OUT/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
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
    views=[('overview',[800,1800,1600],[-300,0,450])]
    for name,distance in [('citygate',330),('cliffbridge',900),('ridge',1450),('woodland',2050),('forestarrival',2400)]:
        p,t=sample(descriptor['centerline'],distance)
        views.append((name,[p[0],p[1]+6,p[2]],[p[0]+t[0]*100,p[1]+4,p[2]+t[1]*100]))
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'landforms.blend'))
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
    parser=argparse.ArgumentParser();parser.add_argument('--render',action='store_true')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else sys.argv[1:])
    if args.render:render(DESCRIPTOR,GROUND)
    else:write_packet()
