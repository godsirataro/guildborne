"""Weapon-specific draw/release study with articulated bow and measured hand/string contact."""
from pathlib import Path
import bpy,math,json,sys
from mathutils import Matrix,Vector
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_civic_art_common import CivicArt,solve_elbow
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/bow-contact-v1'
weapon=json.loads((R/'assets/uat01/weapon-kit/kit.json').read_text());definition=next(x for x in weapon['assets']if x['id']=='yew_longbow')
colors={k:tuple(v/255 for v in rgb)for k,rgb in weapon['palette'].items()};colors.update(skin=(.77,.60,.43),cloth=(.25,.39,.27),dark=(.16,.22,.18),eye=(.12,.15,.17),boot=(.27,.20,.16))
grip=Vector((-.85,-1.85,4.1));back=Vector((1.5,1.3,0)).normalized();nock0=grip+back*(1.05*.65)+Vector((0,0,.35));anchor=Vector((.65,-.55,4.45))
def elbow_for(shoulder,wrist,sign):
 direction=(wrist-shoulder).normalized();distance=(wrist-shoulder).length;assert 0<distance<2.14
 pole=Vector((-direction.y,direction.x,0)).normalized()
 if pole.x*sign<0:pole=-pole
 return shoulder+direction*(distance/2)+pole*math.sqrt(1.07**2-(distance/2)**2)
tips={s:grip+back*(1.05*.65)+Vector((0,0,s*2.3*.65))for s in [-1,1]}
bones=[('Root',(0,0,0),(0,0,.5),None),('LowerTorso',(0,0,2.1),(0,0,2.8),'Root'),('UpperTorso',(0,0,2.8),(0,0,4.3),'LowerTorso'),('Head',(0,0,4.3),(0,0,5.25),'UpperTorso')]
arm_points={}
for side,sign,wrist in [('Left',-1,grip),('Right',1,nock0)]:
 shoulder=Vector((sign*.95,0,4.2));elbow=elbow_for(shoulder,wrist,sign);arm_points[side]=(shoulder,elbow,wrist)
 bones.extend([(side+'UpperArm',shoulder,elbow,'UpperTorso'),(side+'LowerArm',elbow,wrist,side+'UpperArm'),(side+'Hand',wrist,wrist+Vector((0,0,-.32)),side+'LowerArm'),(side+'UpperLeg',(sign*.47,0,2.1),(sign*.47,0,1.2),'LowerTorso'),(side+'LowerLeg',(sign*.47,0,1.2),(sign*.47,0,.35),side+'UpperLeg'),(side+'Foot',(sign*.47,0,.35),(sign*.47,-.55,.2),side+'LowerLeg')])
for sign,name in [(1,'BowUpper'),(-1,'BowLower')]:bones.append((name,grip,tips[sign],'LeftHand'))
a=CivicArt('Bow_Contact',colors,bones)
def pose_arm(side,wrist):
 shoulder=arm_points[side][0];elbow=elbow_for(shoulder,wrist,1 if side=='Right'else -1)
 a.pose_segment(side+'UpperArm',shoulder,elbow);a.pose_segment(side+'LowerArm',elbow,wrist)
 hand=a.rig.pose.bones[side+'Hand'];hand.rotation_mode='QUATERNION';hand.matrix=Matrix.Translation(wrist)@a.data.bones[side+'Hand'].matrix_local.to_3x3().to_4x4();a.key(hand)
a.box('Torso',(0,0,3.3),(1.65,.85,1.8),'cloth','UpperTorso');a.box('Waist',(0,0,2.35),(1.5,.8,.6),'dark','LowerTorso')
a.oval('Head',(0,-.04,4.85),(.57,.46,.64),'skin','Head');a.oval('Hood',(0,.04,5.25),(.65,.50,.32),'cloth','Head')
for x in [-.21,.21]:a.oval('Eye',(x,-.482,4.91),(.05,.045,.05),'eye','Head')
a.oval('Nose',(0,-.49,4.77),(.09,.09,.12),'skin','Head')
pickup=Vector((.8,.45,4.2));quiver_axis=Vector((.6,-.3,.74)).normalized();mouth=pickup-quiver_axis*.6;bottom=pickup-quiver_axis*3.0;lift=pickup+quiver_axis*2.28;guide=Vector((1.25,-1.5,5.15))
bpy.ops.mesh.primitive_cylinder_add(vertices=12,radius=.32,depth=(mouth-bottom).length,end_fill_type='NOTHING',location=(mouth+bottom)/2);quiver=bpy.context.object;quiver.rotation_euler=quiver_axis.to_track_quat('Z','Y').to_euler();a.finish(quiver,'QuiverTube','leather','UpperTorso')
rim=a.ring('QuiverRim',mouth,.33,.055,'gold','UpperTorso');rim.rotation_euler=quiver_axis.to_track_quat('Z','Y').to_euler()
a.rod('QuiverBase',bottom,bottom+quiver_axis*.1,.32,'leather','UpperTorso')
# Stock arrows remain inside the opaque tube; the picked arrow reveals at the palm-covered mouth.
for offset in [Vector((-.11,0,0)),Vector((.11,0,0))]:
 a.rod('QuiverStock',bottom+quiver_axis*.18+offset,pickup-quiver_axis*.10+offset,.023,'wood','UpperTorso')
 fletch=a.box('QuiverFletching',pickup-quiver_axis*.15+offset,(.14,.035,.30),'ivory','UpperTorso');fletch.rotation_euler=quiver_axis.to_track_quat('Z','Y').to_euler()
for side,sign in [('Left',-1),('Right',1)]:
 shoulder,elbow,wrist=arm_points[side]
 a.rod(side+'Sleeve',shoulder,elbow,.29,'cloth',side+'UpperArm');a.oval(side+'Elbow',elbow,(.28,.28,.28),'cloth',side+'LowerArm');a.rod(side+'Forearm',elbow,wrist,.23,'skin',side+'LowerArm');a.oval(side+'Palm',wrist,(.22,.22,.23),'skin',side+'Hand')
 a.rod(side+'Thigh',(sign*.47,0,2.1),(sign*.47,0,1.2),.34,'dark',side+'UpperLeg');a.rod(side+'Shin',(sign*.47,0,1.2),(sign*.47,0,.35),.29,'boot',side+'LowerLeg');a.box(side+'Boot',(sign*.47,-.22,.25),(.70,1.05,.5),'boot',side+'Foot')
C=Matrix(((1,0,0),(0,0,-1),(0,1,0)));angle=math.atan2(back.y,back.x)-math.pi;turn=Matrix.Rotation(angle,4,'Z')
for index,p in enumerate(definition['parts']):
 if p['name']=='String':continue
 bpy.ops.mesh.primitive_cube_add(size=1);obj=bpy.context.object;obj.scale=Vector((p['size'][0],p['size'][2],p['size'][1]))*.65;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 rx,ry,rz=map(math.radians,p['rotation']);rot=Matrix.Rotation(rx,3,'X')@Matrix.Rotation(ry,3,'Y')@Matrix.Rotation(rz,3,'Z');obj.matrix_world=Matrix.Translation(grip+turn.to_3x3()@(C@Vector(p['position'])*.65))@turn@(C@rot@C.transposed()).to_4x4()
 bind='LeftHand'if p['name']=='Grip'else'BowUpper'if p['position'][1]>=0 else'BowLower'
 a.finish(obj,f'Bow_{index}_{p["name"]}',p['color'],bind)
strings={s:a.rod('StringUpper'if s==1 else'StringLower',tips[s],nock0,.012,'ivory')for s in [-1,1]}
# One arrow object, with a local origin exactly at its nock.
arrow_parts=[]
arrow_parts.append(a.rod('ArrowShaft',(0,0,0),(0,0,2.55),.025,'wood'))
bpy.ops.mesh.primitive_cone_add(vertices=8,radius1=.11,radius2=0,depth=.35,location=(0,0,2.67));arrow_parts.append(a.finish(bpy.context.object,'ArrowHead','steel'))
for angle in [0,math.pi/2]:
 o=a.box('Fletching',(0,0,.22),(.22,.025,.40),'ivory');o.rotation_euler[2]=angle;arrow_parts.append(o)
bpy.ops.object.select_all(action='DESELECT')
for o in arrow_parts:o.select_set(True)
bpy.context.view_layer.objects.active=arrow_parts[0];bpy.ops.object.join();arrow=bpy.context.object;arrow.name='Arrow';bpy.context.scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
a.objects=[o for o in a.objects if o not in arrow_parts]+[arrow]
string_lengths={s:o.dimensions.z for s,o in strings.items()}
def ease(x):x=max(0,min(1,x));return x*x*(3-2*x)
def object_key(obj):
 obj.keyframe_insert('location');obj.keyframe_insert('rotation_quaternion');obj.keyframe_insert('scale')
axis=Vector((-back.y,back.x,0));events=[]
for frame in range(181):
 a.scene.frame_set(frame);t=(frame/30)%2;draw=ease(t/.10)if t<=.24 else 1-ease((t-.24)/.06)
 hand_draw=ease(t/.10)if t<=.34 else 1-ease((t-.34)/.28)
 wrist=nock0.lerp(anchor,hand_draw)
 if .24<t<.34:wrist+=back*(math.sin((t-.24)/.10*math.pi)*.06)
 if .62<t<.85:wrist=nock0.lerp(Vector((.95,-.55,4.1)),ease((t-.62)/.23))
 elif .85<=t<1.10:wrist=Vector((.95,-.55,4.1)).lerp(pickup,ease((t-.85)/.25))
 elif 1.10<=t<1.40:wrist=pickup.lerp(lift,ease((t-1.10)/.30))
 elif 1.40<=t<1.60:wrist=lift.lerp(guide,ease((t-1.40)/.20))
 elif 1.60<=t<1.85:wrist=guide.lerp(nock0,ease((t-1.60)/.25))
 pose_arm('Left',grip);pose_arm('Right',wrist)
 glance=ease((t-.62)/.23)*(1-ease((t-1.4)/.45));head_angle=-math.atan2(back.x,back.y)*(1-glance)+.35*glance
 head=a.rig.pose.bones['Head'];head.rotation_mode='QUATERNION';head.matrix=Matrix.Translation(Vector(a.data.bones['Head'].head_local))@Matrix.Rotation(head_angle,4,'Z')@a.data.bones['Head'].matrix_local.to_3x3().to_4x4();a.key(head)
 posed_tips={}
 for sign,name in [(1,'BowUpper'),(-1,'BowLower')]:
  bone=a.rig.pose.bones[name];bone.rotation_mode='QUATERNION';rotation=Matrix.Rotation(sign*.09*draw,4,axis);bone.matrix=Matrix.Translation(grip)@rotation@a.data.bones[name].matrix_local.to_3x3().to_4x4();a.key(bone)
  posed_tips[sign]=grip+rotation.to_3x3()@(tips[sign]-grip)
 nock=nock0.lerp(anchor,draw)
 if .30<t<.50:nock+=back*(.035*math.sin((t-.30)*90)*math.exp(-(t-.30)*18))
 for sign,o in strings.items():
  delta=nock-posed_tips[sign];o.rotation_mode='QUATERNION';o.location=(nock+posed_tips[sign])/2;o.rotation_quaternion=delta.to_track_quat('Z','Y');o.scale=(1,1,delta.length/string_lengths[sign]);object_key(o)
 flight=max(0,t-.24);visible=t<=.60 or t>=1.1
 arrow.location=anchor-back*(flight*18)if t>=.24 and t<=.60 else wrist
 arrow.rotation_mode='QUATERNION';aim=(-back).to_track_quat('Z','Y');stored=(-quiver_axis).to_track_quat('Z','Y')
 arrow.rotation_quaternion=stored if 1.1<=t<=1.4 else stored.slerp(aim,ease((t-1.4)/.2))if 1.4<t<1.6 else aim
 arrow.scale=(1,1,1)if visible else(.001,.001,.001);object_key(arrow)
 if frame in [7,67,127]:events.append({'releaseSeconds':.24+(frame//60)*2,'nearestFrame':frame,'note':'Subframe release timing; 30fps export samples .2333 and .2667 around release.'})
a.export(O,'Bow_Contact',view=(8,-13,8),target=(0,-.5,2.8),frame=6)
manifest={'status':'LOCAL_WEAPON_CONTACT_STUDY','weapon':'yew_longbow','bones':18,'bodyBones':16,'bowBones':2,'fps':30,'duration':6,'leftGrip':list(grip),'readyNock':list(nock0),'drawAnchor':list(anchor),'backDirection':list(back),'tipBind':{str(k):list(v)for k,v in tips.items()},'releaseSeconds':[.24,2.24,4.24],'recoveryEndSeconds':[.62,2.62,4.62],'pickupSeconds':[1.1,3.1,5.1],'nockedSeconds':[1.85,3.85,5.85],'quiverMouth':list(mouth),'quiverAxis':list(quiver_axis),'pickupPoint':list(pickup),'extractedPoint':list(lift),'timingBasis':'Existing cosmetic ActionPose release interpolation ends at .24; the two-second complete study is not an imposed gameplay attack cadence or server damage change.','arrowSpeed':18,'platformImported':False,'gameplayBound':False,'pending':['draw/release and nocking polish','platform import','main-world interruption/retargeting','server/client impact timing integration','sound/VFX listening and device acceptance']}
(O/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('BOW_CONTACT_EXPORTED')
