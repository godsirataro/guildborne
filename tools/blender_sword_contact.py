"""One-handed watchblade: guard, anticipation, diagonal cut and recovery."""
from pathlib import Path
import bpy,math,json,sys
from mathutils import Matrix,Vector,Quaternion
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_civic_art_common import CivicArt
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/sword-contact-v1'
kit=json.loads((R/'assets/uat01/weapon-kit/kit.json').read_text());weapon=next(v for v in kit['assets']if v['id']=='watchblade')
colors={k:tuple(v/255 for v in rgb)for k,rgb in kit['palette'].items()};colors.update(skin=(.77,.60,.43),cloth=(.23,.31,.43),dark=(.15,.19,.26),eye=(.12,.15,.17),boot=(.27,.20,.16))
ready=Vector((1,-1,3.65));guard=Vector((-1,-.65,3.75));ready_aim=Vector((.15,-.60,.78)).normalized().to_track_quat('Z','Y')
def elbow(shoulder,wrist,sign):
 delta=wrist-shoulder;distance=delta.length;assert .01<distance<2.4,(tuple(wrist),distance)
 direction=delta.normalized();pole=Vector((-direction.y,direction.x,0)).normalized()
 if pole.x*sign<0:pole=-pole
 return shoulder+direction*(distance/2)+pole*math.sqrt(1.2**2-(distance/2)**2)
bones=[('Root',(0,0,0),(0,0,.5),None),('LowerTorso',(0,0,2.1),(0,0,2.8),'Root'),('UpperTorso',(0,0,2.8),(0,0,4.3),'LowerTorso'),('Head',(0,0,4.3),(0,0,5.25),'UpperTorso')];arms={}
for side,sign,wrist in [('Left',-1,guard),('Right',1,ready)]:
 shoulder=Vector((sign*.95,0,4.2));bend=elbow(shoulder,wrist,sign);arms[side]=(shoulder,bend,wrist)
 bones.extend([(side+'UpperArm',shoulder,bend,'UpperTorso'),(side+'LowerArm',bend,wrist,side+'UpperArm'),(side+'Hand',wrist,wrist+Vector((0,0,.32)),side+'LowerArm'),(side+'UpperLeg',(sign*.47,0,2.1),(sign*.47,0,1.2),'LowerTorso'),(side+'LowerLeg',(sign*.47,0,1.2),(sign*.47,0,.35),side+'UpperLeg'),(side+'Foot',(sign*.47,0,.35),(sign*.47,-.55,.2),side+'LowerLeg')])
a=CivicArt('Sword_Contact',colors,bones)
a.box('Torso',(0,0,3.3),(1.65,.85,1.8),'cloth','UpperTorso');a.box('Waist',(0,0,2.35),(1.5,.8,.6),'dark','LowerTorso')
a.oval('Head',(0,-.04,4.85),(.57,.46,.64),'skin','Head');a.oval('Cap',(0,.04,5.25),(.65,.50,.32),'dark','Head')
for x in [-.21,.21]:a.oval('Eye',(x,-.482,4.91),(.05,.045,.05),'eye','Head')
a.oval('Nose',(0,-.49,4.77),(.09,.09,.12),'skin','Head')
for side,sign in [('Left',-1),('Right',1)]:
 shoulder,bend,wrist=arms[side]
 a.rod(side+'Sleeve',shoulder,bend,.29,'cloth',side+'UpperArm');a.oval(side+'Elbow',bend,(.28,.28,.28),'cloth',side+'LowerArm');a.rod(side+'Forearm',bend,wrist,.23,'skin',side+'LowerArm');a.oval(side+'Palm',wrist,(.22,.22,.23),'skin',side+'Hand')
 a.rod(side+'Thigh',(sign*.47,0,2.1),(sign*.47,0,1.2),.34,'dark',side+'UpperLeg');a.rod(side+'Shin',(sign*.47,0,1.2),(sign*.47,0,.35),.29,'boot',side+'LowerLeg');a.box(side+'Boot',(sign*.47,-.22,.25),(.7,1.05,.5),'boot',side+'Foot')
C=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
for i,p in enumerate(weapon['parts']):
 if p.get('shape')=='Wedge':
  # Native WedgePart rising toward +Z, transformed into Blender coordinates.
  vertices=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
  faces=[(0,2,3,1),(2,4,5,3),(0,1,5,4),(0,4,2),(1,3,5)]
  mesh=bpy.data.meshes.new('WatchbladeWedge');mesh.from_pydata([C@Vector(v)for v in vertices],[],faces);mesh.update();obj=bpy.data.objects.new('WatchbladeWedge',mesh);a.scene.collection.objects.link(obj)
 else:bpy.ops.mesh.primitive_cube_add(size=1);obj=bpy.context.object
 obj.scale=Vector((p['size'][0],p['size'][2],p['size'][1]))*.65;bpy.context.view_layer.objects.active=obj;obj.select_set(True);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 rx,ry,rz=map(math.radians,p['rotation']);rotation=Matrix.Rotation(rx,3,'X')@Matrix.Rotation(ry,3,'Y')@Matrix.Rotation(rz,3,'Z')
 obj.matrix_world=Matrix.Translation(ready+ready_aim@(C@Vector(p['position'])*.65))@ready_aim.to_matrix().to_4x4()@(C@rotation@C.transposed()).to_4x4();a.finish(obj,f'Sword_{i}_{p["name"]}',p['color'],'RightHand');obj.select_set(False)
def ease(t):t=max(0,min(1,t));return t*t*(3-2*t)
keys=[(0,ready,ready_aim,0),(.2,Vector((1.3,-.7,4.65)),Vector((.25,.3,.92)).normalized().to_track_quat('Z','Y'),.15),(.3,Vector((.35,-1.55,3.9)),Vector((0,-1,0)).to_track_quat('Z','Y'),-.10),(.45,Vector((-.4,-1.65,3.35)),Vector((-.35,-.9,-.26)).normalized().to_track_quat('Z','Y'),-.22),(.6,Vector((-.6,-1.5,3.1)),Vector((-.4,-.75,-.5)).normalized().to_track_quat('Z','Y'),-.22),(.95,ready,ready_aim,0),(2,ready,ready_aim,0)]
for frame in range(181):
 a.scene.frame_set(frame);time=(frame/30)%2
 for start,end in zip(keys,keys[1:]):
  if start[0]<=time<=end[0]:
   weight=ease((time-start[0])/(end[0]-start[0]));wrist=start[1].lerp(end[1],weight);aim=start[2].slerp(end[2],weight);yaw=start[3]*(1-weight)+end[3]*weight;break
 torso=a.rig.pose.bones['UpperTorso'];torso.rotation_mode='QUATERNION';turn=Matrix.Rotation(yaw,4,'Z');pivot=Vector((0,0,2.8));torso.matrix=Matrix.Translation(pivot)@turn@a.data.bones['UpperTorso'].matrix_local.to_3x3().to_4x4();a.key(torso)
 for side,sign,target in [('Left',-1,guard),('Right',1,wrist)]:
  shoulder=pivot+turn.to_3x3()@(arms[side][0]-pivot);bend=elbow(shoulder,target,sign)
  a.pose_segment(side+'UpperArm',shoulder,bend);a.pose_segment(side+'LowerArm',bend,target)
  hand=a.rig.pose.bones[side+'Hand'];hand.rotation_mode='QUATERNION';rotation=(aim@ready_aim.inverted()).to_matrix().to_4x4()if side=='Right'else Matrix.Identity(4);hand.matrix=Matrix.Translation(target)@rotation@a.data.bones[side+'Hand'].matrix_local.to_3x3().to_4x4();a.key(hand)
 head=a.rig.pose.bones['Head'];head.rotation_mode='QUATERNION';head.matrix=Matrix.Translation((0,0,4.3))@a.data.bones['Head'].matrix_local.to_3x3().to_4x4();a.key(head)
a.export(O,'Sword_Contact',view=(8,-13,8),target=(0,-.7,2.8),frame=9)
manifest={'status':'LOCAL_WEAPON_CONTACT_STUDY','weapon':'watchblade','bones':16,'fps':30,'duration':6,'cycle':2,'anticipationEnd':.2,'cutSample':.3,'followThroughEnd':.6,'recoveryEnd':.95,'platformImported':False,'gameplayBound':False,'notes':'Guard, torso anticipation, right-hand grip, diagonal cut and recovery. No target damage, server timing or locomotion retarget claimed.'}
(O/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('SWORD_CONTACT_EXPORTED')
