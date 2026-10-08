"""Editable Borin art slice with rigid-weight skeletal forge animation.
Original project reference interpretation, not a final approved Roblox import.
Run with Blender --background --python-exit-code 1 --python this_file.
"""
from pathlib import Path
import bpy, math, json, sys
from mathutils import Vector, Matrix
POLISHED='--polished' in sys.argv
R=Path(__file__).resolve().parents[1]; OUT=R/('assets/uat01/borin-forge-v2' if POLISHED else 'assets/uat01/borin-forge-v1'); OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene; scene.render.fps=30; scene.frame_start=0;scene.frame_end=180
colors={'skin':(0.65,.36,.20),'hair':(.27,.095,.025),'beard':(.46,.18,.045),'leather':(.29,.12,.055),'apron':(.43,.22,.09),'cloth':(.53,.49,.37),'navy':(.065,.09,.13),'iron':(.15,.18,.20),'brass':(.62,.39,.10),'wood':(.24,.12,.055),'hot':(.95,.21,.035),'stone':(.19,.20,.22),'white':(.85,.77,.60),'black':(.025,.02,.015)}
mats={}
if POLISHED:
 colors.update(skin=(.80,.58,.40),hair=(.38,.17,.07),beard=(.65,.32,.12),leather=(.32,.19,.11),apron=(.49,.31,.17),cloth=(.70,.67,.56),iron=(.36,.40,.43),brass=(.75,.57,.29),wood=(.39,.25,.14),stone=(.32,.34,.36))
for name,c in colors.items():
 if POLISHED and name!='hot':c=tuple(v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in c)
 m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True
 bs=m.node_tree.nodes['Principled BSDF'];bs.inputs['Base Color'].default_value=(*c,1);bs.inputs['Roughness'].default_value=.68
 if name in {'iron','brass'}:bs.inputs['Metallic'].default_value=.7
 if name=='hot':bs.inputs['Emission Color'].default_value=(*c,1);bs.inputs['Emission Strength'].default_value=2
 mats[name]=m
rigdata=bpy.data.armatures.new('BorinSkeleton');rig=bpy.data.objects.new('Borin_Rig',rigdata);scene.collection.objects.link(rig)
names={'Hips':'LowerTorso','Torso':'UpperTorso'}
for side,word in [('R','Right'),('L','Left')]:
 for short,long in [('UpperArm','UpperArm'),('Forearm','LowerArm'),('Hand','Hand'),('Thigh','UpperLeg'),('Shin','LowerLeg'),('Foot','Foot')]:names[side+short]=word+long
def bone_name(name):return names.get(name,name)
bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
specs=[('Root',(0,0,0),(0,0,1),None),('Hips',(0,0,2.0),(0,0,2.6),'Root'),('Torso',(0,0,2.6),(0,0,3.9),'Hips'),('Head',(0,0,3.9),(0,0,5.0),'Torso')]
for side,sgn in [('R',1),('L',-1)]:
 shoulder=(sgn*.98,0,3.78);elbow=(sgn*1.23,-.12,3.05);wrist=(sgn*.85,-.65,2.8)
 specs += [(side+'UpperArm',shoulder,elbow,'Torso'),(side+'Forearm',elbow,wrist,side+'UpperArm'),(side+'Hand',wrist,(wrist[0],wrist[1],wrist[2]-.30),side+'Forearm'),(side+'Thigh',(sgn*.52,0,2.0),(sgn*.52,0,1.10),'Hips'),(side+'Shin',(sgn*.52,0,1.10),(sgn*.52,0,.40),side+'Thigh')]
for side,sgn in [('R',1),('L',-1)]:specs.append((side+'Foot',(sgn*.52,0,.40),(sgn*.52,-.60,.40),side+'Shin'))
for name,h,t,parent in specs:
 b=rigdata.edit_bones.new(bone_name(name));b.head=h;b.tail=t
 if parent:b.parent=rigdata.edit_bones[bone_name(parent)]
bpy.ops.object.mode_set(mode='OBJECT');rig.select_set(False)
meshes=[]; station=[]
def finish(o,name,mat,bone=None):
 o.name=name;o.data.materials.append(mats[mat]);meshes.append(o)
 if bone:
  group=o.vertex_groups.new(name=bone_name(bone));group.add(list(range(len(o.data.vertices))),1,'REPLACE')
  mod=o.modifiers.new('BorinSkin','ARMATURE');mod.object=rig;o.parent=rig
 else:station.append(o)
 return o
def box(name,pos,size,mat,bone=None,bevel=.06):
 bpy.ops.mesh.primitive_cube_add(size=1,location=pos);o=bpy.context.object;o.scale=size
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if bevel:
  mod=o.modifiers.new('RoundedEdges','BEVEL');mod.width=bevel;mod.segments=2
  bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=mod.name)
 return finish(o,name,mat,bone)
def ball(name,pos,scale,mat,bone=None):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=8,radius=1,location=pos);o=bpy.context.object;o.scale=scale
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 for f in o.data.polygons:f.use_smooth=True
 return finish(o,name,mat,bone)
def rod(name,a,b,radius,mat,bone=None):
 a=Vector(a);b=Vector(b);bpy.ops.mesh.primitive_cylinder_add(vertices=10,radius=radius,depth=(b-a).length,location=(a+b)/2);o=bpy.context.object;o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler()
 return finish(o,name,mat,bone)
box('Borin_Trousers',(0,0,1.98),(1.55,.88,.52),'navy','Hips')
ball('Borin_Shirt',(0,.03,3.12),(1.03,.57,.91),'cloth','Torso')
box('Borin_Apron',(0,-.56,2.92),(1.68,.12,1.52),'apron','Torso',.08)
box('Borin_Belt',(0,-.035,2.36),(1.85,1.13,.19),'leather','Torso',.035)
box('Borin_Buckle',(0,-.64,2.36),(.31,.09,.22),'brass','Torso',.035)
for x in [-.65,.65]:
 rod('ApronShoulderStrap',(x,-.46,3.71),(x*.72,-.63,2.75),.075,'leather','Torso')
 for z in [2.65,2.9,3.15]:ball('ApronRivet',(x,-.65,z),(.045,.025,.045),'brass','Torso')
box('ApronPocket',(.35,-.65,2.83),(.58,.10,.40),'leather','Torso',.03)
for side,sgn in [('R',1),('L',-1)]:
 rod(side+'TrouserLeg',(sgn*.52,0,1.98),(sgn*.52,0,1.13),.36,'navy',side+'Thigh')
 rod(side+'BootShaft',(sgn*.52,0,1.12),(sgn*.52,0,.43),.37,'leather',side+'Shin')
 box(side+'Boot',(sgn*.52,-.18,.27),(.80,1.12,.46),'leather',side+'Foot')
 box(side+'BootToe',(sgn*.52,-.59,.34),(.71,.28,.24),'iron',side+'Foot')
 for name in [side+'UpperArm',side+'Forearm']:
  b=rigdata.bones[bone_name(name)];rod(name+'_Body',b.head_local,b.tail_local,.30 if 'Upper' in name else .25,'cloth' if 'Upper' in name else 'skin',name)
 ball(side+'Shoulder',(sgn*.98,0,3.78),(.43,.40,.38),'leather',side+'UpperArm')
 w=rigdata.bones[bone_name(side+'Hand')].head_local
 ball(side+'Glove',w,(.27,.26,.27),'leather',side+'Hand')
 box(side+'GloveCuff',(w.x,w.y,w.z+.17),(.54,.50,.19),'brass',side+'Hand',.03)
ball('Borin_Head',(0,-.02,4.34),(.64,.54,.66),'skin','Head')
for x in [-.66,.66]:ball('Borin_Ear',(x,.01,4.35),(.17,.16,.25),'skin','Head')
ball('Borin_Nose',(0,-.57,4.35),(.19,.20,.16) if POLISHED else (.23,.23,.19),'skin','Head')
for x in [-.25,.25]:
 ball('Borin_Eye',(x,-.52,4.49),(.095,.032,.050),'white','Head')
 ball('Borin_Pupil',(x,-.55,4.49),(.036,.014,.039),'black','Head')
 brow=box('Borin_Brow',(x,-.54,4.62),(.31,.07,.12),'hair','Head',.03);brow.rotation_euler.y=math.copysign(.13,x)
ball('Borin_HairCap',(0,.035,4.69),(.68,.55,.41),'hair','Head')
if POLISHED:
 for n in range(7):
  x=(n-3)*.17;o=ball('Borin_SweptHair',(x,-.37,4.78+.06*math.cos(n)),(.12,.22,.27),'beard','Head');o.rotation_euler.y=-.40
 for x in [-.54,.54]:ball('Borin_Sideburn',(x,-.22,4.27),(.13,.22,.31),'beard','Head')
else:
 for x in [-.43,0,.43]:ball('Borin_SweptHair',(x,-.33,4.82),(.30,.24,.22),'beard','Head')
for x in [-.29,.29]:ball('Borin_Moustache',(x,-.57,4.13),(.35,.18,.15),'beard','Head')
ball('Borin_BeardMass',(0,-.40,3.92),(.58,.35,.43),'beard','Head')
for index,x in enumerate([-.38,0,.38]):
 for k in range(6):
  z=3.96-k*.125;dx=.045*math.sin(k*math.pi+index)
  ball('Borin_Braid',(x+dx,-.63,z),(.145,.13,.125),'beard','Head')
 rod('Borin_BraidRing',(x,-.64,3.40),(x,-.64,3.49),.155,'brass','Head')
 ball('Borin_BraidTip',(x,-.64,3.34),(.13,.12,.15),'hair','Head')
# Rest grip geometry follows its hand bone. Hammer centre lies 0.8 forward of wrist.
rw=Vector(rigdata.bones[bone_name('RHand')].head_local);lw=Vector(rigdata.bones[bone_name('LHand')].head_local)
rod('Hammer_Handle',rw+Vector((0,.15,0)),rw+Vector((0,-.80,0)),.095,'wood','RHand')
box('Hammer_Head',rw+Vector((0,-.80,.12)),(.72,.43,.44),'iron','RHand',.045)
for dx in [-.38,.38]:box('Hammer_Face',rw+Vector((dx,-.80,.12)),(.10,.42,.40),'brass','RHand',.02)
for dx in [-.07,.07]:
 rod('Tongs_Shaft',lw+Vector((dx,.08,0)),Vector((.35,-1.25,2.68))+Vector((dx,0,0)),.045,'iron','LHand')
 rod('Tongs_Jaw',Vector((.35,-1.25,2.68))+Vector((dx,0,0)),Vector((.35+dx,-1.48,2.68)),.055,'iron','LHand')
box('Forge_Platform',(0,-.7,-.12),(5,4.5,.24),'stone',bevel=.04)
for x in [-.78,.78]:box('AnvilStandLeg',(x,-1.45,.78),(.33,.8,1.56),'wood')
box('AnvilStand',(0,-1.45,1.55),(2.15,1.35,.28),'wood')
box('AnvilFoot',(0,-1.45,1.83),(1.55,.90,.28),'iron')
box('AnvilWaist',(0,-1.45,2.12),(.95,.68,.40),'iron')
box('AnvilFace',(0,-1.45,2.43),(1.90,.85,.20),'iron',bevel=.03)
rod('AnvilHorn',(-.95,-1.45,2.40),(-1.57,-1.45,2.40),.18,'iron')
box('HotWorkpiece',(.35,-1.45,2.615),(.65,.42,.17),'hot',bevel=.025)
box('ForgeBackWall',(0,1.25,2.1),(5,.20,4.2),'stone',bevel=.03)
for x in [-2.3,2.3]:box('ForgeTimberPillar',(x,1.06,2.4),(.28,.30,4.8),'wood')
box('ForgeCrossbeam',(0,1.06,4.53),(4.8,.34,.32),'wood')
for x in [-1.4,-.7,0,.7,1.4]:rod('HangingTool',(x,.88,3.2),(x,.88,3.8),.055,'iron')
contact_frames=[30,90,150];errors=[];reach=[]
def set_bone(name,a,b):
 p=rig.pose.bones[bone_name(name)];p.rotation_mode='QUATERNION';a=Vector(a);b=Vector(b);p.matrix=Matrix.Translation(a)@(b-a).to_track_quat('Y','Z').to_matrix().to_4x4()
 bpy.context.view_layer.update()
 p.keyframe_insert('location');p.keyframe_insert('rotation_quaternion');p.keyframe_insert('scale')
def arm(side,target,wrist_angle=0):
 s=Vector(rigdata.bones[bone_name(side+'UpperArm')].head_local);w=Vector(target)
 L1=rigdata.bones[bone_name(side+'UpperArm')].length;L2=rigdata.bones[bone_name(side+'Forearm')].length;d=(w-s).length
 assert abs(L1-L2)<d<L1+L2, (side,d,L1+L2)
 direction=(w-s).normalized();normal=Vector((1 if side=='R' else -1,0,0));normal=(normal-direction*normal.dot(direction)).normalized()
 u=(L1*L1-L2*L2+d*d)/(2*d);e=s+direction*u+normal*math.sqrt(max(0,L1*L1-u*u))
 set_bone(side+'UpperArm',s,e);set_bone(side+'Forearm',e,w)
 hand=rig.pose.bones[bone_name(side+'Hand')];hand.rotation_mode='QUATERNION'
 # Preserve bind-pose roll. Direction tracking is singular for a vertical hand and can flip the tool180degrees.
 hand.matrix=Matrix.Translation(w)@Matrix.Rotation(wrist_angle,4,'X')@rigdata.bones[bone_name(side+'Hand')].matrix_local.to_3x3().to_4x4()
 bpy.context.view_layer.update();hand.keyframe_insert('location');hand.keyframe_insert('rotation_quaternion');hand.keyframe_insert('scale')
 reach.append(max(abs((e-s).length-L1),abs((w-e).length-L2)))
for frame in range(181):
 scene.frame_set(frame);phase=(frame%60)/60
 # Original symmetric lift remains reproducible; v2 adds anticipation, acceleration and rebound.
 lift=(1+math.cos(phase*2*math.pi))*.5
 if POLISHED:
  if phase<.30:lift=1
  elif phase<.50:lift=1-((phase-.30)/.20)**2
  elif phase<.60:lift=.10*math.sin((phase-.50)/.10*math.pi/2)
  else:
   u=(phase-.60)/.40;lift=.10+.90*(u*u*(3-2*u))
 arm('R',(.35+(.12*lift if POLISHED else 0),-.65,2.80+.80*lift),-.35*lift if POLISHED else 0);arm('L',tuple(lw))
 if frame in contact_frames:
  bpy.context.view_layer.update()
  # Bone Y points downward; local Z is world Y for this fixed-orientation hand.
  delta=(rig.pose.bones[bone_name('RHand')].matrix@rigdata.bones[bone_name('RHand')].matrix_local.inverted())
  actual=delta@(rw+Vector((0,-.80,-.10)))
  errors.append({'frame':frame,'hammerBottom':list(actual),'surfaceZ':2.70,'verticalError':abs(actual.z-2.70)})
# Local cosmetic spark preview. Contact times are the same as the audio cue sheet.
for n in range(9):
 o=ball('ContactSpark_'+str(n),(.35,-1.45,2.70),(.025,.025,.025),'hot')
 angle=n*2*math.pi/9;direction=Vector((math.cos(angle)*.7,math.sin(angle)*.7,.35+(n%3)*.15))
 for impact in contact_frames:
  for f,travel,scale in [(impact-1,0,0),(impact,0,1),(impact+5,1,1),(impact+10,1.6,0)]:
   scene.frame_set(f);o.location=Vector((.35,-1.45,2.70))+direction*travel;o.scale=(scale,scale,scale);o.keyframe_insert('location');o.keyframe_insert('scale')
for action in bpy.data.actions:
 for layer in action.layers:
  for strip in layer.strips:
   for bag in strip.channelbags:
    for curve in bag.fcurves:
     for key in curve.keyframe_points:key.interpolation='LINEAR'
rig['review_status']='CONTACT_ART_SLICE_NOT_PLATFORM_IMPORTED';rig['reference']='civic-community/concept-v1.png';rig['contact_frames']='30,90,150'
scene.world=bpy.data.worlds.new('ForgeWorld');scene.world.color=(.10,.10,.10)
for loc,power,size in [((4,-6,9),1100,5),((-4,-3,6),850,4),((0,4,7),1100,3)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=size;o.rotation_euler=(Vector((0,-.4,2.7))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(8,-13,8));cam=bpy.context.object;cam.rotation_euler=(Vector((0,-.3,2.5))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=7.8;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.render.resolution_x=1200;scene.render.resolution_y=1200;scene.render.resolution_percentage=100;scene.view_settings.view_transform='AgX'
scene.frame_set(30);bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_Borin_Forge.blend'))
bpy.ops.object.select_all(action='DESELECT');rig.select_set(True)
for o in meshes:o.select_set(True)
bpy.context.view_layer.objects.active=rig
bpy.ops.export_scene.gltf(filepath=str(OUT/'Borin_Forge.glb'),use_selection=True,export_format='GLB',export_animations=True,export_animation_mode='SCENE',export_anim_scene_split_object=False,export_frame_range=True,export_force_sampling=True)
for label,frame in [('contact',30),('windup',0)]:
 scene.frame_set(frame);scene.render.filepath=str(OUT/(label+'.png'));bpy.ops.render.render(write_still=True)
report={'reference':'assets/uat01/civic-community/concept-v1.png','status':'SKELETAL_ART_CONTACT_REVIEW_PLATFORM_IMPORT_PENDING','frames':181,'fps':30,'durationSeconds':6,'bones':len(rigdata.bones),'meshObjects':len(meshes),'stationMeshes':len(station),'contact':errors,'maxArmLengthError':max(reach),'robloxMeshId':None,'robloxAnimationId':None,'notes':'Rigid skin weights; analytic two-bone reach; stable feet. Hammer hand orientation fixed for first vertical strike study; detailed wrist arc, cloth deformation and human review pending.'}
if POLISHED:report['notes']='v2: corrected sRGB material conversion, swept hair locks, smaller nose; anticipation, accelerating strike, rebound and20degree wrist arc. Body weight shift/cloth deformation, platform import and human review pending.'
assert max(e['verticalError']for e in errors)<.006,errors
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print('BORIN_FORGE_PASS',json.dumps(report))
