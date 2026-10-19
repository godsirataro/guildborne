"""Faithful bounded city context; standalone --survey or background Blender -- before/after.

Only the additive packet differs between matched views. Native geometry is a
source reconstruction, not evidence of Roblox import, actors, lighting or UI.
"""
from pathlib import Path
import hashlib,json,math,re,sys
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
ASSETS=ROOT/'assets/production/world-slice/city-smith-apron'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def mm(a,b):return [[sum(a[i][k]*b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def rot(x=0,y=0,z=0):
 x,y,z=map(math.radians,(x,y,z));cx,sx=math.cos(x),math.sin(x);cy,sy=math.cos(y),math.sin(y);cz,sz=math.cos(z),math.sin(z)
 return mm(mm([[1,0,0],[0,cx,-sx],[0,sx,cx]],[[cy,0,sy],[0,1,0],[-sy,0,cy]]),[[cz,-sz,0],[sz,cz,0],[0,0,1]])
def survey():
 palette={k:[int(n) for n in v.split(',')] for k,v in re.findall(r'(\w+)\s*=\s*Color3.fromRGB\(([^)]+)\)',(ROOT/'src/shared/Config/Art.luau').read_text())}
 parts=[]
 def part(name,size,pos,color,rotation=None,shape='Block',pivot=(0,0,0),yaw=0):
  r=rot(y=yaw);p=[pivot[i]+sum(r[i][k]*pos[k] for k in range(3)) for i in range(3)];r=mm(r,rotation or rot())
  parts.append(dict(name=name,size=size,position=p,rotationMatrix=sum(r,[]),color=[n/255 for n in (palette[color] if isinstance(color,str) else color)],shape=shape))
 def house(name,pivot,yaw,color):
  def p(n,s,v,c,r=None):part(name+'_'+n,s,v,c,r,pivot=pivot,yaw=yaw)
  p('Foundation',[58,.8,42],[0,.4,0],'Stone');p('RearWall',[56,20,1],[0,10,-20],'Timber')
  for side in (-1,1):
   p('SideWall',[1,20,40],[side*28,10,0],'Timber');p('FrontWall',[20,20,1],[side*18,10,20],'Timber')
   for z in (-20,0,20):p('TimberPost',[1.3,22,1.3],[side*28,11,z],'Wood')
   p('PitchedRoof',[32,1.2,48],[side*14,25,0],color,rot(z=-side*20))
   p('Window',[7,7,.3],[side*18,12,20.7],[15,21,35]);p('WindowMullion',[.5,7,.4],[side*18,12,20.9],'Gold')
  p('Ridge',[1,1,49],[0,30,0],'Gold');p('DoorLintel',[16,5,1.5],[0,18,20],'Wood')
  # Literal generated interior parts, transformed by the same model pivot.
  source=(ROOT/'src/server/Services/CityInteriorKit.luau').read_text()
  section=source.split('m:SetAttribute("BuildingName","'+name+'")')[1].split('\ndo local m=')[0]
  pat=r'p.Name="([^"]+)";p.Size=Vector3.new\(([^)]+)\);p.CFrame=CFrame.new\(Vector3.new\(([^)]+)\)\)\*CFrame.Angles\(0,0,math.rad\(([^)]+)\)\);p.Color=Color3.fromRGB\(([^)]+)\)'
  for n,s,v,a,c in re.findall(pat,section):p('Interior_'+n,list(map(float,s.split(','))),list(map(float,v.split(','))),list(map(int,c.split(','))),rot(z=float(a)))
 def banner(x,z,color):
  pivot=(x,1,z)
  for n,s,v,c,r in [('Pole',[.7,18,.7],[0,9,0],'Wood',None),('Cloth',[7,11,.3],[0,11,0],color,None),('GuildDiamond',[2.3,2.3,.5],[0,12,.3],'Gold',rot(z=45)),('Blade',[.5,5,.6],[0,12,.6],'Parchment',None)]:part('Banner_'+n,s,v,c,r,pivot=pivot)
 part('CityFoundation',[920,8,1020],[0,-4,-1130],'Stone');part('CityGround',[912,.3,1012],[0,.15,-1130],[112,128,102])
 house('Blacksmith',(370,1,-1000),90,[119,87,66]);house('Alchemy Shop',(235,1,-1000),0,[91,127,110])
 for x in (334,406):banner(x,-976,[119,87,66])
 for x in (199,271):banner(x,-976,[91,127,110])
 part('ForgeChimney',[9,40,9],[360,21,-1010],'Stone')
 part('Blacksmith_sign_without_GUI',[8,4,.5],[398,4,-1000],'Wood');part('Alchemy_sign_without_GUI',[8,4,.5],[235,4,-972],'Wood')
 part('MarketCourtyard',[110,.2,100],[300,.6,-1100],'StoneLight')
 for x in (255,330,380):
  part('StallCounter',[12,3,5],[x,2.5,-1060],'Timber')
  for dx in (-6,6):part('StallPost',[.6,9,.6],[x+dx,5.5,-1060],'Wood')
  part('StallAwning',[15,.6,10],[x,10,-1060],[180,108,55])
 roads=[('GuildMarketAvenue',(-350,-1100),(350,-1100),32),('ForgeApproach',(350,-1100),(410,-1100),18),('ForgeEastLane',(410,-1100),(410,-1000),18),('ForgeThreshold',(410,-1000),(390,-1000),12),('DistrictLane',(300,-960),(300,-1130),18)]
 for n,a,b,w in roads:
  dx,dz=b[0]-a[0],b[1]-a[1];length=math.hypot(dx,dz)
  # CFrame.lookAt uses local -Z toward destination.
  part(n,[w,.3,length+w],[(a[0]+b[0])/2,.4,(a[1]+b[1])/2],'StoneLight',rot(y=math.degrees(math.atan2(-dx,-dz))))
 # Exact east boundary wall rhythm, visible beyond the workshop in broad views.
 for z in range(-1115,-874,40):
  part('EastWall',[40,18,5],[455,9,z],'Stone',rot(y=90))
  for x in (-16,-8,0,8,16):part('EastMerlon',[4,3,6],[455,19.5,z-x],'Stone',rot(y=90))
 landscape=json.loads((ROOT/'assets/uat01/city-landscape/landscape.json').read_text())
 for p in landscape['parts']:
  x,y,z=p['position']
  if 160<=x<=455 and -1130<=z<=-880:part('Landscape_'+p['group']+'_'+p['name'],p['size'],p['position'],p['color'],rot(*p['rotation']),p['shape'])
 files=['src/server/Services/CityKit.luau','src/server/Services/CentralCityWorld.luau','src/server/Services/CityInteriorKit.luau','src/server/Services/CityLandscape.luau','src/server/Services/CityLandscapeData.luau','src/shared/Config/Art.luau','src/shared/Config/City.luau','assets/uat01/city-landscape/landscape.json']
 result=dict(status='SOURCE_RECONSTRUCTION_NOT_STUDIO',nativeParts=parts,sourceHashes={p:sha(ROOT/p) for p in files},context='Literal CityKit Blacksmith and Alchemy shells/interiors with actual pivots, roof rotations, palette, banners; chimney, sign boards, market stalls, ground, market courtyard, five roads, bounded east walls, landscape centers within X160..455/Z-1130..-880.',omissions=['Actors/companions/NPCs and GUI labels omitted; no population proof','Distant city buildings, roads, monuments, island scenery and landscape outside bounded context omitted','Native materials, Roblox lighting/shadows and physical collision not reproduced; Blender comparison only'],coordinateSystem='Roblox Y-up studs; conversion to Blender X,-Z,Y')
 (HERE/'source-survey.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 return result
def main(variant):
 if variant not in ('before','after'):raise ValueError('choose before or after')
 import bpy
 from mathutils import Matrix,Vector
 data=json.loads((HERE/'source-survey.json').read_text());cameras=json.loads((HERE/'cameras.json').read_text())
 for path,digest in data['sourceHashes'].items():assert sha(ROOT/path)==digest, 'Stale survey: '+path
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 conv=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
 mats={}
 def material(color):
  key=tuple(color)
  if key not in mats:
   m=bpy.data.materials.new('RGB_'+str(key));m.diffuse_color=(*color,1);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Roughness'].default_value=.82;mats[key]=m
  return mats[key]
 def place(mesh,name,cf,scale):
  o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o);r=Matrix((cf[3:6],cf[6:9],cf[9:12]));o.matrix_world=(conv@r).to_4x4()@Matrix.Diagonal((*scale,1));o.location=conv@Vector(cf[:3]);return o
 boxv=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,-.5),(.5,.5,-.5),(.5,.5,.5),(-.5,.5,.5)]
 boxf=[(1,2,3,0),(7,6,5,4),(4,5,1,0),(5,6,2,1),(6,7,3,2),(7,4,0,3)]
 for index,p in enumerate(data['nativeParts']):
  if p['shape']=='Block':
   mesh=bpy.data.meshes.new(p['name']);mesh.from_pydata(boxv,[],boxf);mesh.update()
  else:
   if p['shape']=='Ball':bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=12,radius=.5)
   elif p['shape']=='Cylinder':bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=.5,depth=1)
   else:raise ValueError(p['shape'])
   temp=bpy.context.object;mesh=temp.data
   # Roblox cylinder length follows X, Blender primitive follows Z.
   if p['shape']=='Cylinder':mesh.transform(Matrix.Rotation(math.pi/2,4,'Y'))
   bpy.data.objects.remove(temp,do_unlink=True)
  mesh.materials.append(material(p['color']));place(mesh,'EXISTING_'+str(index)+'_'+p['name'],p['position']+p['rotationMatrix'],p['size'])
 packet_path=ASSETS/'scenery.mesh.json'
 if variant=='after':
  packet=json.loads(packet_path.read_text());meshes={}
  for m in packet['meshes']:
   mesh=bpy.data.meshes.new(m['id']);mesh.from_pydata(m['vertices'],[],[[i-1 for i in t] for t in m['triangles']]);mesh.update()
   for c in m['colors']:mesh.materials.append(material(c))
   for f,ci in zip(mesh.polygons,m['faceColors']):f.material_index=ci-1
   meshes[m['id']]=mesh
  for p in packet['placements']:place(meshes[p['meshId']],'NEW_'+p['name'],p['cframe'],p['scale'])
 scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=cameras['samples'];scene.render.resolution_x=cameras['resolution'][0];scene.render.resolution_y=cameras['resolution'][1];scene.render.resolution_percentage=100
 scene.view_settings.view_transform='Standard';scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.40,.50,.62,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.55
 bpy.ops.object.light_add(type='SUN',location=(400,100,200));bpy.context.object.data.energy=2.2;bpy.context.object.rotation_euler=(.6,-.5,-.6)
 bpy.ops.object.camera_add();cam=bpy.context.object;scene.camera=cam;cam.data.lens=cameras['lens'];cam.data.clip_end=4000
 out=ASSETS/variant;out.mkdir(parents=True,exist_ok=True)
 for view in cameras['views']:
  cam.location=conv@Vector(view['eye']);cam.rotation_euler=((conv@Vector(view['target']))-cam.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(out/(view['name']+'.png'));bpy.ops.render.render(write_still=True)
 bpy.ops.wm.save_as_mainfile(filepath=str(out/'source.blend'))
 report=dict(status='BLENDER_RENDERED_NOT_NATIVE',variant=variant,nativePartCount=len(data['nativeParts']),cameraSha256=sha(HERE/'cameras.json'),packetSha256=sha(packet_path) if packet_path.exists() else None,packetIncluded=variant=='after',surveySha256=sha(HERE/'source-survey.json'),rendererSha256=sha(Path(__file__)),context=data['context'],omissions=data['omissions'],images={p.name:sha(p) for p in out.glob('*.png')})
 (out/'render-evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
if __name__=='__main__':
 if '--survey' in sys.argv:survey()
 else:main(sys.argv[sys.argv.index('--')+1])
