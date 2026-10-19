"""Source-context comparison in owned background Blender; never Studio proof."""
from pathlib import Path
import hashlib,json,math,re,sys
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
OUTROOT=ROOT/'assets/production/world-slice/ironveil-ashen'
MAP=ROOT/'src/server/Services/AdventureMapKit.luau'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def survey():
    text=MAP.read_text();parts=[]
    pattern=r'\{name="([^"]+)",size=V\(([^)]+)\),pos=V\(([^)]+)\),color=Color3.fromRGB\(([^)]+)\),collide=(true|false),wedge=(true|false),yaw=([^}]+)\}'
    def nums(v):return [float(x) for x in v.split(',')]
    for region,x in [('Ironveil',500),('Ashen',1000)]:
        section=text.split('{id="'+region+'",parts={',1)[1].split('},markers={',1)[0]
        for m in re.finditer(pattern,section):
            name,size,pos,color,solid,wedge,yaw=m.groups();p=nums(pos);p[0]+=x;p[2]+=1400
            parts.append(dict(name=region+'_'+name,position=p,size=nums(size),color=[v/255 for v in nums(color)],collide=solid=='true',className='WedgePart' if wedge=='true' else 'Part',yaw=float(yaw)))
        for dx in [-5,5]:parts.append(dict(name=region+'_ReturnPost',position=[x+dx,7,1527],size=[1,10,1.5],color=[104/255,79/255,54/255],className='Part',yaw=0))
        parts.append(dict(name=region+'_ReturnLintel',position=[x,12,1527],size=[11,1,1.5],color=[163/255,143/255,88/255],className='Part',yaw=0))
    sources=['src/server/Services/AdventureMapKit.luau','src/server/Services/RegionalWorld.luau','src/shared/Config/City.luau']
    data=dict(status='SOURCE_RECONSTRUCTION_NOT_NATIVE',sourceHashes={p:sha(ROOT/p) for p in sources},parts=parts,omissions=['Actors, dynamic resource art, GUI, private campaign pockets and distant city omitted','Roblox materials, lighting, physics and gameplay not reproduced'])
    (HERE/'render-context.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
    print('survey parts',len(parts))
def main(variant):
    import bpy
    from mathutils import Matrix,Vector
    data=json.loads((HERE/'render-context.json').read_text());cameras=json.loads((HERE/'cameras.json').read_text())
    for p,h in data['sourceHashes'].items():assert sha(ROOT/p)==h
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    conv=Matrix(((1,0,0),(0,0,-1),(0,1,0)));inputs={};mats={}
    def material(color):
        key=tuple(color)
        if key not in mats:
            m=bpy.data.materials.new('RGB'+str(key));m.diffuse_color=(*color,1);m.use_nodes=True
            m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*color,1)
            m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.85;mats[key]=m
        return mats[key]
    def place(mesh,name,cf,size):
        o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o)
        r=Matrix((cf[3:6],cf[6:9],cf[9:12]));o.matrix_world=(conv@r).to_4x4()@Matrix.Diagonal((*size,1));o.location=conv@Vector(cf[:3]);return o
    def packet(rel,prefix):
        path=ROOT/rel;inputs[rel]=sha(path);packet=json.loads(path.read_text());meshes={}
        for m in packet['meshes']:
            mesh=bpy.data.meshes.new(prefix+m['id']);mesh.from_pydata(m['vertices'],[],[[i-1 for i in t] for t in m['triangles']]);mesh.update()
            for c in m['colors']:mesh.materials.append(material(c))
            for f,ci in zip(mesh.polygons,m['faceColors']):f.material_index=ci-1
            meshes[m['id']]=mesh
        for p in packet['placements']:place(meshes[p['meshId']],prefix+p['name'],p['cframe'],p['scale'])
    boxv=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,-.5),(.5,.5,-.5),(.5,.5,.5),(-.5,.5,.5)]
    boxf=[(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]
    wedgev=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
    wedgef=[(1,2,3,0),(2,5,4,3),(4,5,1,0),(3,4,0),(5,2,1)]
    def native(p,prefix):
        wedge=p.get('className')=='WedgePart';mesh=bpy.data.meshes.new(prefix+p['name'])
        mesh.from_pydata(wedgev if wedge else boxv,[],wedgef if wedge else boxf);mesh.materials.append(material(p['color']));mesh.update()
        a=math.radians(p.get('yaw',0));c,s=math.cos(a),math.sin(a)
        place(mesh,prefix+p['name'],p['position']+p.get('rotation',[c,0,s,0,1,0,-s,0,c]),p['size'])
    for p in data['parts']:native(p,'EXISTING_')
    oldground='production/world/quality-slice/greenwood-ironveil/ground.json';inputs[oldground]=sha(ROOT/oldground)
    for p in json.loads((ROOT/oldground).read_text())['parts']:native(p,'EXISTING_ROAD_')
    for name in ['greenwood-ironveil','ironveil-ore-yard']:packet('assets/production/world-slice/'+name+'/scenery.mesh.json','EXISTING_'+name)
    coast='coast-prop-composition' if variant=='before' else 'coast-prop-ashen-cut'
    packet('assets/production/world-slice/'+coast+'/scenery.mesh.json','COAST_')
    if variant=='after':
        rel='production/world/quality-slice/ironveil-ashen/ground.json';inputs[rel]=sha(ROOT/rel)
        for p in json.loads((ROOT/rel).read_text())['parts']:native(p,'NEW_ROAD_')
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=cameras['samples']
    scene.render.resolution_x=cameras['resolution'][0];scene.render.resolution_y=cameras['resolution'][1];scene.render.resolution_percentage=100
    scene.view_settings.view_transform='Standard';scene.world.use_nodes=True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.40,.50,.62,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.55
    bpy.ops.object.light_add(type='SUN',location=(750,100,1500));bpy.context.object.data.energy=2.2;bpy.context.object.rotation_euler=(.6,-.5,-.6)
    bpy.ops.object.camera_add();cam=bpy.context.object;scene.camera=cam;cam.data.lens=cameras['lens'];cam.data.clip_end=5000
    out=OUTROOT/variant;out.mkdir(parents=True,exist_ok=True)
    for view in cameras['views']:
        cam.location=conv@Vector(view['eye']);cam.rotation_euler=((conv@Vector(view['target']))-cam.location).to_track_quat('-Z','Y').to_euler()
        scene.render.filepath=str(out/(view['name']+'.png'));bpy.ops.render.render(write_still=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(out/'source.blend'))
    report=dict(status='BLENDER_RENDERED_NOT_NATIVE',variant=variant,inputHashes=inputs,cameraSHA256=sha(HERE/'cameras.json'),contextSHA256=sha(HERE/'render-context.json'),rendererSHA256=sha(Path(__file__)),nativeParts=len(data['parts']),omissions=data['omissions'],images={p.name:sha(p) for p in out.glob('*.png')})
    (out/'render-evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
if __name__=='__main__':
    if '--survey' in sys.argv:survey()
    else:main(sys.argv[sys.argv.index('--')+1])
