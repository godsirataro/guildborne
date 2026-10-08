"""Original elf gardener art/contact slice, authored in Blender; import pending."""
from pathlib import Path
import bpy,math,json
from mathutils import Vector,Matrix
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/vaela-garden-v1';O.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True);s=bpy.context.scene;s.render.fps=30;s.frame_start=0;s.frame_end=180
palette={'skin':(.89,.71,.55),'hair':(.88,.84,.64),'green':(.23,.40,.22),'darkgreen':(.12,.25,.15),'ivory':(.85,.82,.67),'leather':(.34,.22,.12),'gold':(.71,.51,.22),'iron':(.35,.43,.42),'leaf':(.26,.48,.16),'wood':(.39,.25,.13),'soil':(.19,.12,.06),'clay':(.55,.30,.15),'water':(.30,.65,.80),'white':(.88,.87,.80),'pupil':(.13,.20,.12)}
palette['lip']=(.62,.36,.31)
mats={}
for name,rgb in palette.items():
 c=tuple(v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb);m=bpy.data.materials.new(name);m.use_nodes=True;m.diffuse_color=(*c,1);bs=m.node_tree.nodes['Principled BSDF'];bs.inputs['Base Color'].default_value=(*c,1);bs.inputs['Roughness'].default_value=.66
 if name in ['gold','iron']:bs.inputs['Metallic'].default_value=.6
 mats[name]=m
data=bpy.data.armatures.new('VaelaSkeleton');rig=bpy.data.objects.new('Vaela_Rig',data);s.collection.objects.link(rig);bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
bones=[('Root',(0,0,0),(0,0,1),None),('LowerTorso',(0,0,2.5),(0,0,3.2),'Root'),('UpperTorso',(0,0,3.2),(0,0,4.75),'LowerTorso'),('Head',(0,0,4.75),(0,0,5.8),'UpperTorso')]
for side,sgn in [('Right',1),('Left',-1)]:
 wrist=(.75,-.65,4.0) if sgn==1 else (-.60,-1.0,3.45)
 shoulder=Vector((sgn*.68,0,4.55));w=Vector(wrist);direction=(w-shoulder).normalized();distance=(w-shoulder).length
 normal=Vector((sgn,0,0));normal=(normal-direction*normal.dot(direction)).normalized();u=(.78**2-.80**2+distance**2)/(2*distance);elbow=shoulder+direction*u+normal*math.sqrt(.78**2-u*u)
 bones.extend([(side+'UpperArm',tuple(shoulder),tuple(elbow),'UpperTorso'),(side+'LowerArm',tuple(elbow),wrist,side+'UpperArm'),(side+'Hand',wrist,(wrist[0],wrist[1],wrist[2]-.25),side+'LowerArm'),(side+'UpperLeg',(sgn*.34,0,2.5),(sgn*.34,0,1.40),'LowerTorso'),(side+'LowerLeg',(sgn*.34,0,1.40),(sgn*.34,0,.35),side+'UpperLeg'),(side+'Foot',(sgn*.34,0,.35),(sgn*.34,-.48,.35),side+'LowerLeg')])
for name,h,t,parent in bones:
 b=data.edit_bones.new(name);b.head=h;b.tail=t
 if parent:b.parent=data.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT');rig.select_set(False);objects=[]
def finish(o,name,material,bone=None):
 o.name=name;o.data.materials.append(mats[material]);objects.append(o)
 if bone:
  g=o.vertex_groups.new(name=bone);g.add(list(range(len(o.data.vertices))),1,'REPLACE');mod=o.modifiers.new('VaelaSkin','ARMATURE');mod.object=rig;o.parent=rig
 return o
def box(name,pos,size,mat,bone=None):
 bpy.ops.mesh.primitive_cube_add(size=1,location=pos);o=bpy.context.object;o.scale=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);mod=o.modifiers.new('SoftEdges','BEVEL');mod.width=.035;mod.segments=2;bpy.ops.object.modifier_apply(modifier=mod.name);return finish(o,name,mat,bone)
def oval(name,pos,size,mat,bone=None):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=8,radius=1,location=pos);o=bpy.context.object;o.scale=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 for p in o.data.polygons:p.use_smooth=True
 return finish(o,name,mat,bone)
def rod(name,a,b,r,mat,bone=None):
 a=Vector(a);b=Vector(b);bpy.ops.mesh.primitive_cylinder_add(vertices=10,radius=r,depth=(b-a).length,location=(a+b)/2);o=bpy.context.object;o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler();return finish(o,name,mat,bone)
oval('Vaela_Tunic',(0,0,3.82),(.71,.38,.87),'ivory','UpperTorso');box('Vaela_GardenApron',(0,-.39,3.5),(1.05,.10,1.25),'green','UpperTorso');box('Vaela_Belt',(0,0,3.04),(1.27,.82,.16),'leather','UpperTorso')
for x in [-.40,.40]:rod('ApronStrap',(x,-.26,4.52),(x,-.43,3.52),.043,'green','UpperTorso')
box('SeedPouch',(.36,-.49,3.12),(.40,.21,.40),'leather','UpperTorso');box('PouchClasp',(.36,-.62,3.2),(.13,.04,.11),'gold','UpperTorso')
for side,sgn in [('Right',1),('Left',-1)]:
 for name,mat,r in [(side+'UpperArm','ivory',.18),(side+'LowerArm','skin',.14),(side+'UpperLeg','darkgreen',.23),(side+'LowerLeg','leather',.20)]:
  b=data.bones[name];rod(name+'_Mesh',b.head_local,b.tail_local,r,mat,name)
 w=data.bones[side+'Hand'].head_local;oval(side+'Glove',w,(.17,.18,.19),'leather',side+'Hand')
 box(side+'Boot',(sgn*.34,-.13,.22),(.48,.78,.40),'leather',side+'Foot')
 oval(side+'LeafShoulder',(sgn*.69,0,4.50),(.31,.37,.20),'green',side+'UpperArm')
oval('Vaela_Face',(0,-.03,5.17),(.40,.35,.54),'skin','Head');oval('Vaela_HairCap',(0,.055,5.48),(.44,.37,.29),'hair','Head')
for x in [-.16,.16]:
 oval('Eye',(x,-.351,5.24),(.082,.025,.047),'white','Head');oval('Pupil',(x,-.373,5.24),(.035,.014,.038),'pupil','Head');box('Brow',(x,-.352,5.34),(.19,.035,.045),'leather','Head')
oval('Nose',(0,-.376,5.14),(.07,.07,.09),'skin','Head')
rod('SmileLeft',(-.085,-.355,5.005),(0,-.362,4.99),.012,'lip','Head');rod('SmileRight',(0,-.362,4.99),(.085,-.355,5.005),.012,'lip','Head')
for sign in [-1,1]:
 # Tapered elf ear uses an authored wedge, not a round human ear.
 verts=[(sign*.32,0,5.34),(sign*.79,.06,5.50),(sign*.39,-.06,5.03),(sign*.42,.09,5.18)]
 mesh=bpy.data.meshes.new('ElfEar');mesh.from_pydata(verts,[],[(0,1,2),(0,3,1),(1,3,2),(0,2,3)]);mesh.update();o=bpy.data.objects.new('Vaela_ElfEar',mesh);s.collection.objects.link(o);finish(o,'Vaela_ElfEar','skin','Head')
 for k in range(6):oval('HairBraid',(sign*.33,.25,5.20-k*.12),(.11,.12,.12),'hair','Head')
 rod('BraidTie',(sign*.33,.25,4.56),(sign*.33,.25,4.64),.12,'gold','Head')
for n in range(5):
 o=oval('SideSweptFringe',((n-2)*.13,-.27,5.51),(.10,.16,.22),'hair','Head');o.rotation_euler.y=.42
box('GardenDeck',(0,-.7,-.1),(4.3,3.6,.2),'wood')
for x in [-1.3,1.3]:
 for y in [-1.9,-.85]:box('GardenBenchLeg',(x,y,1.33),(.16,.16,2.66),'wood')
box('GardenBench',(0,-1.4,2.68),(2.95,1.45,.14),'wood')
rod('TerracottaPot',(0,-1.4,2.77),(0,-1.4,3.24),.43,'clay')
bpy.ops.mesh.primitive_torus_add(major_segments=16,minor_segments=6,location=(0,-1.4,3.27),major_radius=.44,minor_radius=.04);finish(bpy.context.object,'PotRim','clay')
rod('Soil',(0,-1.4,3.28),(0,-1.4,3.30),.42,'soil')
rod('SaplingStem',(-.1,-1.4,3.30),(-.1,-1.4,3.92),.032,'leaf')
for n in range(5):
 angle=n*2.3;o=oval('SaplingLeaf',(-.1+math.cos(angle)*.16,-1.4+math.sin(angle)*.12,3.47+n*.095),(.20,.075,.07),'leaf');o.rotation_euler.z=angle
rw=Vector(data.bones['RightHand'].head_local);tip=Vector((.15,-1.45,4.25));target=Vector((.15,-1.45,3.30))
rod('WateringCanBody',(.75,-.92,3.57),(.75,-.92,4.0),.30,'iron','RightHand');rod('CanSpout',(.55,-1.05,3.90),tip,.065,'iron','RightHand');oval('SpoutRose',tip,(.12,.10,.045),'gold','RightHand')
rod('CanGrip',rw+Vector((-.15,0,0)),rw+Vector((.15,0,0)),.05,'gold','RightHand')
for dx in [-.15,.15]:rod('CanGripSupport',rw+Vector((dx,0,0)),rw+Vector((dx,-.15,-.15)),.035,'gold','RightHand')
drops=[oval('WaterDrop_'+str(n),target,(.022,.022,.045),'water')for n in range(8)];start_errors=[]
for frame in range(181):
 s.frame_set(frame);phase=frame/180
 angle=.65*math.sin(math.pi*phase)**2
 hand=rig.pose.bones['RightHand'];hand.rotation_mode='QUATERNION';hand.matrix=Matrix.Translation(rw)@Matrix.Rotation(angle,4,'X')@data.bones['RightHand'].matrix_local.to_3x3().to_4x4();bpy.context.view_layer.update()
 hand.keyframe_insert('location');hand.keyframe_insert('rotation_quaternion');hand.keyframe_insert('scale')
 mouth=hand.matrix@data.bones['RightHand'].matrix_local.inverted()@tip
 pouring=60<=frame<=120
 for n,o in enumerate(drops):
  u=n/7;o.location=mouth.lerp(target,u);o.scale=(1,1,1)if pouring else(0,0,0);o.keyframe_insert('location');o.keyframe_insert('scale')
 if pouring:start_errors.append((drops[0].location-mouth).length)
for action in bpy.data.actions:
 for layer in action.layers:
  for strip in layer.strips:
   for bag in strip.channelbags:
    for curve in bag.fcurves:
     for key in curve.keyframe_points:key.interpolation='LINEAR'
s.world=bpy.data.worlds.new('GardenStudio');s.world.color=(.12,.12,.12)
for loc,power in [((4,-6,8),1100),((-4,-3,7),800),((0,4,7),1100)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=5;o.rotation_euler=(Vector((0,-.4,3))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(8,-13,8));cam=bpy.context.object;cam.rotation_euler=(Vector((0,-.5,2.9))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=7.3;s.camera=cam
s.render.engine='CYCLES';s.cycles.samples=24;s.render.resolution_x=1200;s.render.resolution_y=1200;s.render.resolution_percentage=100;s.view_settings.view_transform='AgX';s.frame_set(90);bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(O/'Guildborne_Vaela_Garden.blend'));bpy.ops.object.select_all(action='DESELECT');rig.select_set(True)
for o in objects:o.select_set(True)
bpy.context.view_layer.objects.active=rig;bpy.ops.export_scene.gltf(filepath=str(O/'Vaela_Garden.glb'),use_selection=True,export_format='GLB',export_animations=True,export_animation_mode='SCENE',export_anim_scene_split_object=False,export_frame_range=True,export_force_sampling=True)
s.render.filepath=str(O/'watering.png');bpy.ops.render.render(write_still=True)
report={'status':'LOCAL_ELF_GARDEN_ART_REVIEW_IMPORT_PENDING','bones':len(data.bones),'meshObjects':len(objects),'fps':30,'seconds':6,'pourFrames':[60,120],'maxSpoutStreamError':max(start_errors),'spoutBindPosition':list(tip),'soilTarget':list(target),'reference':'assets/uat01/civic-community/concept-v1.png','robloxAssetId':None,'notes':'Original standing elf interpretation. Stream follows posed spout to soil; drop-chain cosmetic study, not fluid simulation. Contact/skin roundtrip and visual review required.'}
(O/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print('VAELA_GARDEN',json.dumps(report))
