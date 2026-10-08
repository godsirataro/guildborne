"""Three distinct civic desk professions with exported tool-contact motion."""
from pathlib import Path
import sys,math,json,bpy
from mathutils import Vector
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_civic_art_common import CivicArt,solve_elbow
R=Path(__file__).resolve().parents[1]
cast=[('elian','Crownford','marshal_elian',(.16,.23,.34)),('nyra','Astralis','cartographer_nyra',(.35,.21,.49)),('sela','Crosshaven','harbormaster_sela',(.13,.38,.42))]
def tip_at(who,frame):
 if who=='elian':return Vector((.22,-1.10,3.22+.55*(1+math.cos(frame/180*2*math.pi))*.5))
 if who=='nyra':
  t=(frame/180*5)%5;i=int(t);u=t-i;points=[Vector((.27*math.cos(k*4*math.pi/5),-1.22+.27*math.sin(k*4*math.pi/5),3.22))for k in range(5)];return points[i].lerp(points[(i+1)%5],u)
 f=frame%60;row=(frame//60)%3
 if f<=44:return Vector((-.25+.50*f/44,-1.04-row*.16,3.22))
 u=(f-44)/16;return Vector((.25-.5*u,-1.04-row*.16+((row-(row+1)%3)*.16)*u,3.22+.20*math.sin(math.pi*u)))
for who,city,identity,coat in cast:
 O=R/('assets/uat01/'+who+'-desk-v1');offset=Vector((0,0,.50))if who=='elian'else Vector((.20,.30,.45));right=tip_at(who,0)+offset;left=Vector((-.68,-1.0,3.40))
 colors={'skin':(.80,.59,.43),'hair':(.20,.13,.10),'coat':coat,'ivory':(.85,.82,.69),'leather':(.34,.22,.12),'gold':(.72,.53,.23),'wood':(.38,.25,.14),'paper':(.85,.80,.65),'ink':(.14,.18,.25),'white':(.9,.87,.80),'lip':(.56,.31,.25),'prism':(.25,.67,.75)}
 if who=='nyra':colors['hair']=(.15,.10,.17)
 bones=[('Root',(0,0,0),(0,0,1),None),('LowerTorso',(0,0,2.4),(0,0,3.05),'Root'),('UpperTorso',(0,0,3.05),(0,0,4.70),'LowerTorso'),('Head',(0,0,4.70),(0,0,5.7),'UpperTorso')]
 for side,sign in [('Right',1),('Left',-1)]:
  h=Vector((sign*.82,0,4.47));w=right if sign==1 else left;e=solve_elbow(h,w,.88,.88,sign)
  bones.extend([(side+'UpperArm',h,e,'UpperTorso'),(side+'LowerArm',e,w,side+'UpperArm'),(side+'Hand',w,w+Vector((0,0,-.27)),side+'LowerArm'),(side+'UpperLeg',(sign*.38,0,2.4),(sign*.38,0,1.34),'LowerTorso'),(side+'LowerLeg',(sign*.38,0,1.34),(sign*.38,0,.37),side+'UpperLeg'),(side+'Foot',(sign*.38,0,.37),(sign*.38,-.5,.37),side+'LowerLeg')])
 a=CivicArt(who.title(),colors,bones);box=a.box;oval=a.oval;rod=a.rod
 oval('Shirt',(0,0,3.72),(.80,.43,.96),'coat' if who=='elian' else 'ivory','UpperTorso')
 for x in [-.54,.54]:box('CoatPanel',(x,-.38,3.44),(.45,.13,1.95),'coat','UpperTorso')
 box('CoatBack',(0,.33,3.43),(1.40,.20,1.97),'coat','UpperTorso');box('Belt',(0,0,2.95),(1.52,.93,.16),'leather','UpperTorso');box('Buckle',(0,-.50,2.95),(.22,.07,.19),'gold','UpperTorso')
 for side,sign in [('Right',1),('Left',-1)]:
  for name,mat,r in [(side+'UpperArm','coat',.24),(side+'LowerArm','coat',.20),(side+'UpperLeg','ink',.26),(side+'LowerLeg','leather',.24)]:
   b=a.data.bones[name];rod(name+'_Mesh',b.head_local,b.tail_local,r,mat,name)
  oval(side+'Shoulder',a.data.bones[side+'UpperArm'].head_local,(.30,.31,.30),'coat',side+'UpperArm');oval(side+'Elbow',a.data.bones[side+'LowerArm'].head_local,(.22,.22,.22),'coat',side+'LowerArm')
  oval(side+'HandMesh',a.data.bones[side+'Hand'].head_local,(.20,.18,.21),'skin',side+'Hand');box(side+'Boot',(sign*.38,-.15,.22),(.58,.85,.4),'leather',side+'Foot')
 oval('Face',(0,-.03,5.15),(.43,.37,.53),'skin','Head');oval('Nose',(0,-.41,5.13),(.09,.09,.11),'skin','Head')
 for x in [-.17,.17]:
  oval('Eye',(x,-.37,5.26),(.082,.023,.045),'white','Head');oval('Pupil',(x,-.394,5.26),(.032,.014,.035),'ink','Head');box('Brow',(x,-.369,5.35),(.18,.033,.045),'hair','Head')
  oval('Ear',(math.copysign(.43,x),0,5.15),(.10,.10,.17),'skin','Head')
 rod('MouthLeft',(-.09,-.365,4.995),(0,-.38,4.985),.012,'lip','Head');rod('MouthRight',(0,-.38,4.985),(.09,-.365,4.995),.012,'lip','Head')
 oval('HairCap',(0,.01,5.46),(.46,.39,.31),'hair','Head')
 for n in range(5):
  o=oval('HairLock',((n-2)*.16,-.30,5.34 if who=='sela' else 5.50),(.13,.17,.24),'hair','Head');o.rotation_euler.y=-.35
 if who=='elian':
  sash=box('IvoryCharterSash',(0,-.48,3.73),(.23,.09,1.66),'ivory','UpperTorso');sash.rotation_euler.y=.42
  oval('CivicSeal',(-.40,-.51,4.14),(.17,.04,.17),'gold','UpperTorso')
 elif who=='nyra':
  oval('HairBun',(0,.29,5.65),(.28,.27,.28),'hair','Head');a.ring('BunBand',(0,.29,5.52),.22,.027,'gold','Head')
  for sign in [-1,1]:
   o=oval('AstralMantleLapel',(sign*.40,-.27,4.39),(.42,.18,.25),'coat','UpperTorso');o.rotation_euler.y=sign*.45
   rod('MantleGoldEdge',(sign*.13,-.43,4.60),(sign*.62,-.44,4.20),.021,'gold','UpperTorso')
  for x in [-.70,.70]:rod('RobeGoldTrim',(x,-.48,2.55),(x,-.48,4.34),.023,'gold','UpperTorso')
  for z in [3.25,3.65,4.05]:
   o=box('RobeStar',(.54,-.46,z),(.10,.04,.10),'gold','UpperTorso');o.rotation_euler.y=math.pi/4
 else:
  for sign in [-1,1]:
   for k in range(4):oval('HarborHairBraid',(sign*.34,.17,5.03-k*.13),(.12,.13,.12),'hair','Head')
  # Rounded three-lobed brim reads as the harbor officer's hat.
  verts=[]
  for z in [5.59,5.69]:
   for n in range(24):t=n*math.pi/12;radius=.64+.10*math.cos(t*3);verts.append((math.cos(t)*radius,math.sin(t)*radius,z))
  faces=[tuple(reversed(range(24))),tuple(range(24,48))]+[(n,(n+1)%24,(n+1)%24+24,n+24)for n in range(24)]
  mesh=bpy.data.meshes.new('HarborBrim');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new('HarborHatBrim',mesh);a.scene.collection.objects.link(o);a.finish(o,'HarborHatBrim','coat','Head');oval('HatCrown',(0,.03,5.73),(.40,.33,.23),'coat','Head')
  rod('HatEmblemStem',(0,-.61,5.68),(0,-.61,5.84),.021,'gold','Head');rod('HatEmblemBar',(-.10,-.61,5.72),(.10,-.61,5.72),.021,'gold','Head')
  for x in [-.53,.53]:
   for z in [3.23,3.58,3.93]:oval('CoatButton',(x,-.48,z),(.043,.026,.043),'gold','UpperTorso')
 box('CityWorkDeck',(0,-.65,-.10),(4.3,3.8,.20),'wood');box('Desk',(0,-1.26,3.08),(2.70,1.25,.20),'wood')
 for x in [-1.16,1.16]:
  for y in [-1.72,-.78]:box('DeskLeg',(x,y,1.49),(.18,.18,2.98),'wood')
 box('Document',(0,-1.22,3.20),(1.65,.86,.04),'ink'if who=='nyra'else'paper')
 tip=tip_at(who,0)
 if who=='elian':
  rod('StampGrip',right,tip+Vector((0,0,.10)),.065,'leather','RightHand');rod('StampFoot',tip,tip+Vector((0,0,.10)),.17,'gold','RightHand')
  for row in range(5):rod('CharterWriting',(-.58,-1.48+row*.10,3.225),(-.08,-1.48+row*.10,3.225),.008,'ink')
  seal=rod('StampedSeal',(.22,-1.10,3.224),(.22,-1.10,3.228),.15,'gold')
  for f,scale in [(0,0),(89,0),(90,1),(160,1),(180,0)]:a.scene.frame_set(f);seal.scale=(scale,scale,scale);seal.keyframe_insert('scale')
 else:
  rod('WritingTool',right+Vector((0,0,.1)),tip,.032,'gold'if who=='nyra'else'leather','RightHand');oval('ToolTip',tip,(.015,.015,.015),'gold'if who=='nyra'else'ink','RightHand')
  if who=='nyra':
   points=[Vector((.27*math.cos(k*4*math.pi/5),-1.22+.27*math.sin(k*4*math.pi/5),3.225))for k in range(5)]
   for k in range(5):rod('StarChartLine',points[k],points[(k+1)%5],.009,'gold');oval('ChartStar',points[k],(.035,.035,.012),'gold')
   rod('PrismStand',(-.90,-1.35,3.18),(-.90,-1.35,3.47),.07,'gold');prism=oval('SurveyPrism',(-.90,-1.35,3.62),(.15,.15,.25),'prism')
  else:
   for row in range(3):rod('LedgerLine',(-.40,-1.04-row*.16,3.225),(.38,-1.04-row*.16,3.225),.007,'ink')
   box('LedgerSpine',(-.81,-1.22,3.23),(.08,.87,.08),'coat')
 errors=[]
 for frame in range(181):
  a.scene.frame_set(frame);target=tip_at(who,frame);a.arm('Right',target+offset)
  actual=a.rig.pose.bones['RightHand'].matrix@a.data.bones['RightHand'].matrix_local.inverted()@tip;errors.append((actual-target).length)
 a.export(O,who.title()+'_Desk',frame=90 if who!='sela' else 82)
 report={'status':'LOCAL_CONTACT_ART_PLATFORM_IMPORT_PENDING','id':identity,'city':city,'bones':16,'seconds':6,'fps':30,'toolBindTip':list(tip),'paperSurfaceZ':3.22,'maxAuthoredTipError':max(errors),'activity':{'elian':'charter stamp','nyra':'trace five-point star chart','sela':'write three ledger lines with lifted return'}[who],'robloxAssetId':None,'notes':'Original costume/reference interpretation; exported contact and human visual review required. Not yet replacing gameplay NPC.'}
 assert max(errors)<.00003;(O/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print('DESK_CAST',json.dumps(report))
