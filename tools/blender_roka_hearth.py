"""Friendly Orc cook with bowl-relative stirring and steam source study."""
from pathlib import Path
import sys,math,json,bpy
from mathutils import Vector
sys.path.insert(0,str(Path(__file__).resolve().parent))
from blender_civic_art_common import CivicArt,solve_elbow
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/roka-hearth-v1'
colors={'skin':(.37,.50,.20),'hair':(.16,.12,.08),'ivory':(.84,.81,.67),'green':(.20,.32,.16),'leather':(.36,.22,.12),'gold':(.69,.48,.19),'wood':(.42,.28,.13),'food':(.56,.35,.12),'leaf':(.24,.46,.13),'carrot':(.86,.40,.11),'steam':(.80,.83,.79),'white':(.9,.87,.75),'pupil':(.16,.12,.07)}
bones=[('Root',(0,0,0),(0,0,1),None),('LowerTorso',(0,0,2.0),(0,0,2.65),'Root'),('UpperTorso',(0,0,2.65),(0,0,4.30),'LowerTorso'),('Head',(0,0,4.30),(0,0,5.25),'UpperTorso')]
left=Vector((-.85,-.75,3.15));bowl=Vector((-.35,-1.35,2.83));rest_tip=Vector((-.10,-1.35,3.03));offset=Vector((.55,.40,.70));right=rest_tip+offset
for side,sign in [('Right',1),('Left',-1)]:
 h=Vector((sign*1.03,0,4.15));w=right if sign==1 else left;e=solve_elbow(h,w,.90,.85,sign)
 bones.extend([(side+'UpperArm',h,e,'UpperTorso'),(side+'LowerArm',e,w,side+'UpperArm'),(side+'Hand',w,w+Vector((0,0,-.30)),side+'LowerArm'),(side+'UpperLeg',(sign*.53,0,2.0),(sign*.53,0,1.12),'LowerTorso'),(side+'LowerLeg',(sign*.53,0,1.12),(sign*.53,0,.38),side+'UpperLeg'),(side+'Foot',(sign*.53,0,.38),(sign*.53,-.55,.38),side+'LowerLeg')])
a=CivicArt('Roka',colors,bones);box=a.box;oval=a.oval;rod=a.rod
oval('Roka_Shirt',(0,.02,3.30),(1.12,.57,1.0),'ivory','UpperTorso');box('Roka_Apron',(0,-.57,3.0),(1.85,.13,1.65),'green','UpperTorso');box('Roka_ApronHem',(0,-.66,2.25),(1.84,.05,.13),'ivory','UpperTorso')
for x in [-.7,.7]:rod('ApronStrap',(x,-.42,4.04),(x*.75,-.66,3.05),.07,'leather','UpperTorso')
for n in range(5):
 z=2.7+n*.16;rod('ApronLeafStem',(0,-.665,z),(0,-.665,z+.17),.018,'gold','UpperTorso')
 for sign in [-1,1]:
  o=oval('ApronLeaf',(sign*.13,-.68,z+.06),(.15,.018,.055),'gold','UpperTorso');o.rotation_euler.y=sign*.4
box('Belt',(0,0,2.40),(2,1.14,.18),'leather','UpperTorso')
for side,sign in [('Right',1),('Left',-1)]:
 for name,mat,radius in [(side+'UpperArm','ivory',.31),(side+'LowerArm','skin',.29),(side+'UpperLeg','green',.36),(side+'LowerLeg','leather',.33)]:
  b=a.data.bones[name];rod(name+'_Mesh',b.head_local,b.tail_local,radius,mat,name)
 oval(side+'Shoulder',a.data.bones[side+'UpperArm'].head_local,(.40,.39,.37),'ivory',side+'UpperArm')
 oval(side+'Elbow',a.data.bones[side+'LowerArm'].head_local,(.29,.29,.29),'skin',side+'LowerArm')
 w=a.data.bones[side+'Hand'].head_local;oval(side+'HandMesh',w,(.30,.26,.26),'skin',side+'Hand');box(side+'Boot',(sign*.53,-.16,.26),(.80,1.0,.46),'leather',side+'Foot')
oval('Roka_Head',(0,-.02,4.70),(.64,.47,.58),'skin','Head');oval('Roka_Jaw',(0,-.24,4.42),(.55,.35,.27),'skin','Head');oval('Roka_Nose',(0,-.50,4.75),(.18,.16,.13),'skin','Head')
for x in [-.25,.25]:
 oval('Eye',(x,-.441,4.87),(.10,.031,.056),'white','Head');oval('Pupil',(x,-.47,4.87),(.041,.016,.042),'pupil','Head');box('Brow',(x,-.43,4.98),(.23,.06,.055),'hair','Head')
rod('FriendlySmile',(-.25,-.552,4.49),(.25,-.552,4.49),.018,'leather','Head')
for sign in [-1,1]:
 bpy.ops.mesh.primitive_cone_add(vertices=10,radius1=.085,radius2=.012,depth=.30,location=(sign*.31,-.57,4.55));a.finish(bpy.context.object,'OrcTusk','ivory','Head')
 verts=[(sign*.53,0,4.89),(sign*.97,.05,5.05),(sign*.61,-.07,4.56),(sign*.65,.12,4.72)];mesh=bpy.data.meshes.new('OrcEar');mesh.from_pydata(verts,[],[(0,1,2),(0,3,1),(1,3,2),(0,2,3)]);mesh.update();o=bpy.data.objects.new('OrcEar',mesh);a.scene.collection.objects.link(o);a.finish(o,'OrcEar','skin','Head')
oval('Roka_HairCap',(0,-.04,5.01),(.65,.47,.30),'hair','Head');oval('Roka_HairKnot',(0,.31,5.23),(.30,.27,.25),'hair','Head');a.ring('HairTie',(0,.31,5.15),.24,.035,'gold','Head')
for x in [-.35,0,.35]:
 o=oval('HairSweep',(x,-.24,5.15),(.21,.30,.16),'hair','Head');o.rotation_euler.z=.3
# Open-sided bowl with exposed food. Every bowl component follows the supporting left hand.
bpy.ops.mesh.primitive_cone_add(vertices=16,radius1=.40,radius2=.65,depth=.50,end_fill_type='NOTHING',location=bowl);a.finish(bpy.context.object,'ServingBowl','wood','LeftHand')
a.ring('BowlRim',bowl+Vector((0,0,.25)),.65,.045,'wood','LeftHand');rod('BowlBase',bowl+Vector((0,0,-.26)),bowl+Vector((0,0,-.23)),.40,'wood','LeftHand');rod('Stew',bowl+Vector((0,0,.14)),bowl+Vector((0,0,.17)),.58,'food','LeftHand')
for n in range(8):
 t=n*math.pi/4;oval('Vegetable',bowl+Vector((math.cos(t)*.39,math.sin(t)*.39,.18)),(.10,.07,.045),'leaf'if n%2 else'carrot','LeftHand')
rod('LadleHandle',right+Vector((0,0,.10)),rest_tip,.075,'wood','RightHand');oval('LadleCup',rest_tip,(.16,.13,.075),'wood','RightHand')
steam=[]
mat=a.materials['steam'];mat.node_tree.nodes['Principled BSDF'].inputs['Alpha'].default_value=.18
if hasattr(mat,'surface_render_method'):mat.surface_render_method='DITHERED'
for n in range(5):steam.append(oval('Steam_'+str(n),bowl+Vector((0,0,.45)),(.10,.10,.15),'steam'))
box('HearthDeck',(0,-.7,-.1),(4.5,3.8,.2),'wood');box('ServingCounter',(1.65,-1.4,2.45),(.65,1.2,.15),'wood');box('ServingCounterLeg',(1.65,-1.4,1.2),(.30,.7,2.4),'wood')
errors=[]
for frame in range(181):
 a.scene.frame_set(frame);t=frame/180*math.pi*4;target=Vector((bowl.x+.25*math.cos(t),bowl.y+.25*math.sin(t),3.03));a.arm('Right',target+offset)
 actual=a.rig.pose.bones['RightHand'].matrix@a.data.bones['RightHand'].matrix_local.inverted()@rest_tip;errors.append((actual-target).length)
 for n,o in enumerate(steam):
  phase=((frame/180)+n/5)%1;o.location=bowl+Vector((.16*math.sin(phase*math.pi*2+n),.13*math.cos(n),.35+phase*.65));size=math.sin(math.pi*phase);o.scale=(size,size,size);o.keyframe_insert('location');o.keyframe_insert('scale')
a.export(O,'Roka_Hearth',frame=90)
report={'status':'LOCAL_FRIENDLY_ORC_CONTACT_REVIEW_IMPORT_PENDING','bones':16,'frames':181,'fps':30,'seconds':6,'bowlCenter':list(bowl),'stirRadius':.25,'ladleRadius':.16,'innerBowlRadius':.58,'maxAuthoredLadleError':max(errors),'robloxAssetId':None,'notes':'Bowl follows left hand; right-hand ladle circles within stew. Translucent steam source over food. Original reference interpretation; final likeness, cloth/fingers, import/runtime and human review pending.'}
assert max(errors)<.00002;(O/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print('ROKA_HEARTH',json.dumps(report))
