"""Four matched views with all45 literal native Ironveil parts and existing bridge."""
from pathlib import Path
import json,math,sys,hashlib
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
ASSETS=ROOT/'assets/production/world-slice/ironveil-ore-yard'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main(variant):
 import bpy
 from mathutils import Matrix,Vector
 survey=json.loads((HERE/'source-survey.json').read_text());cameras=json.loads((HERE/'cameras.json').read_text())
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 conv=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
 def material(name,color):
  m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Roughness'].default_value=.82;return m
 def place(mesh,name,cf,scale):
  o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o);r=Matrix((cf[3:6],cf[6:9],cf[9:12]));o.matrix_world=(conv@r).to_4x4()@Matrix.Diagonal((*scale,1));o.location=conv@Vector(cf[:3]);return o
 def packet(path,prefix):
  data=json.loads(path.read_text());meshes={}
  for m in data['meshes']:
   mesh=bpy.data.meshes.new(prefix+m['id']);mesh.from_pydata(m['vertices'],[],[[i-1 for i in t] for t in m['triangles']]);mesh.update()
   for i,color in enumerate(m['colors']):mesh.materials.append(material(prefix+m['id']+str(i),color))
   for face,ci in zip(mesh.polygons,m['faceColors']):face.material_index=ci-1
   meshes[m['id']]=mesh
  for p in data['placements']:place(meshes[p['meshId']],prefix+p['name'],p['cframe'],p['scale'])
 boxv=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,-.5),(.5,.5,-.5),(.5,.5,.5),(-.5,.5,.5)]
 boxf=[(1,2,3,0),(7,6,5,4),(4,5,1,0),(5,6,2,1),(6,7,3,2),(7,4,0,3)]
 wedgev=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,-.5,.5),(-.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
 wedgef=[(1,2,3,0),(2,5,4,3),(4,5,1,0),(3,4,0),(5,2,1)]
 def native(name,position,size,color,yaw=0,wedge=False,rotation=None,alpha=1):
  m=bpy.data.meshes.new(name);m.from_pydata(wedgev if wedge else boxv,[],wedgef if wedge else boxf);m.materials.append(material(name,color));m.update()
  a=math.radians(yaw);c,s=math.cos(a),math.sin(a);r=rotation or [c,0,s,0,1,0,-s,0,c]
  return place(m,name,position+r,size)
 for p in survey['nativeParts']:native('EXISTING_NATIVE_'+str(p['index'])+'_'+p['name'],p['position'],p['size'],p['color'],p['yaw'],p['className']=='WedgePart')
 # Exact public portal geometry from RegionalWorld, excluding labels/prompts.
 for x in (-5,5):native('EXISTING_RETURN_POST'+str(x),[500+x,7,1527],[1,10,1.5],[104/255,79/255,54/255])
 native('EXISTING_RETURN_LINTEL',[500,12,1527],[11,1,1.5],[163/255,143/255,88/255])
 native('EXISTING_MINE_MARKER',[500,2.15,1498],[2,.15,2],[214/255,174/255,78/255])
 # Existing accepted corridor always present in both images, unlike initial corridor before.
 g=json.loads((ROOT/'production/world/quality-slice/greenwood-ironveil/ground.json').read_text())
 for p in g['parts']:native('EXISTING_BRIDGE_'+p['name'],p['position'],p['size'],p['color'],wedge=True,rotation=p['rotation'])
 packet(ROOT/'assets/production/world-slice/greenwood-ironveil/scenery.mesh.json','EXISTING_BRIDGE_')
 if variant=='after':packet(ASSETS/'scenery.mesh.json','NEW_YARD_')
 scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=cameras['samples'];scene.render.resolution_x=cameras['resolution'][0];scene.render.resolution_y=cameras['resolution'][1];scene.render.resolution_percentage=100
 scene.view_settings.view_transform='Standard';scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.40,.50,.62,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.55
 bpy.ops.object.light_add(type='SUN',location=(400,100,200));bpy.context.object.data.energy=2.2;bpy.context.object.rotation_euler=(.6,-.5,-.6)
 bpy.ops.object.camera_add();cam=bpy.context.object;scene.camera=cam;cam.data.lens=cameras['lens'];cam.data.clip_end=4000
 out=ASSETS/variant;out.mkdir(parents=True,exist_ok=True)
 for view in cameras['views']:
  cam.location=conv@Vector(view['eye']);cam.rotation_euler=((conv@Vector(view['target']))-cam.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(out/(view['name']+'.png'));bpy.ops.render.render(write_still=True)
 bpy.ops.wm.save_as_mainfile(filepath=str(out/'source.blend'))
 (out/'render-evidence.json').write_text(json.dumps(dict(status='BLENDER_RENDERED_NOT_NATIVE',variant=variant,nativeParts=len(survey['nativeParts']),cameraSha256=sha(HERE/'cameras.json'),packetSha256=sha(ASSETS/'scenery.mesh.json'),surveySha256=sha(HERE/'source-survey.json'),context='All45 literal native Ironveil map parts with actual source colors/yaws/wedges; existing bridge and public portal frame/mine marker. Dynamic actors, private pockets, generated resource art and GUI excluded; anchors protected by full survey keepouts.',images={p.name:sha(p) for p in out.glob('*.png')}),indent=2)+'\n',encoding='utf-8')
if __name__=='__main__':main(sys.argv[sys.argv.index('--')+1])
