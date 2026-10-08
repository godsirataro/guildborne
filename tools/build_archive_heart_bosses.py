"""Two original duty-bound automata on editable shared humanoid skeletons."""
from pathlib import Path
import copy,json,math
root=Path(__file__).resolve().parents[1]
out=root/'assets/uat01/archive-heart-bosses';out.mkdir(parents=True,exist_ok=True)
source=json.loads((root/'assets/uat01/hero-kit/kit.json').read_text(encoding='utf-8'))
base=next(a for a in source['assets']if a['id']=='warrior_01')
palette={'ivory':[223,215,192],'navy':[36,49,70],'bronze':[184,139,69],'teal':[69,201,187],'dark':[25,32,42],'violet':[137,111,186]}
assets=[]
for identity,scale in [('last_warden',1.8),('keeper_of_names',2.4)]:
 a=copy.deepcopy(base);a.update(id=identity,designId='boss.archive_heart.'+identity,region='ArchiveHeart',role='Boss',friendly=False)
 a['parts']=[]
 def box(name,size,pos,color,bone='UpperTorso',rz=0):a['parts'].append(dict(name=name,size=size,position=pos,color=color,bone=bone,rotation=[0,0,rz]))
 box('Waist',[1.45,.7,.85],[0,2.3,0],'navy','LowerTorso')
 box('Chest',[1.85,1.25,1.1],[0,3.2,0],'ivory')
 box('ChestInlay',[.65,1.05,.15],[0,3.2,-.65],'navy')
 box('NameChannel',[.17,.9,.1],[0,3.2,-.76],'teal')
 box('Belt',[1.65,.2,1],[0,2.45,0],'bronze','LowerTorso')
 box('Mask',[1.1,1.3,.9],[0,4.45,0],'ivory','Head')
 box('Visor',[.7,.16,.12],[0,4.6,-.5],'dark','Head')
 box('VisorSpine',[.13,.9,.15],[0,4.45,-.54],'bronze','Head')
 for side,x in [('Left',-1),('Right',1)]:
  box(side+'Shoulder',[.95,.5,1.2],[x*1.12,3.65,0],'bronze',side+'UpperArm')
  box(side+'UpperArm',[.65,.82,.7],[x*1.12,3.2,0],'ivory',side+'UpperArm')
  box(side+'Elbow',[.6,.3,.6],[x*1.17,2.76,0],'navy',side+'LowerArm')
  box(side+'Forearm',[.65,.65,.75],[x*1.18,2.42,0],'ivory',side+'LowerArm')
  box(side+'Hand',[.56,.38,.62],[x*1.18,1.97,0],'bronze',side+'Hand')
  box(side+'Thigh',[.67,.85,.82],[x*.48,1.7,0],'ivory',side+'UpperLeg')
  box(side+'Knee',[.74,.35,.9],[x*.48,1.15,-.05],'bronze',side+'LowerLeg')
  box(side+'Shin',[.6,.74,.75],[x*.48,.7,0],'navy',side+'LowerLeg')
  box(side+'Foot',[.76,.35,1.15],[x*.48,.2,-.2],'ivory',side+'Foot')
 def ring(name,x,y,z,radius,segments,color,bone):
  for i in range(segments):
   angle=2*math.pi*i/segments
   box(name,[radius*2*math.sin(math.pi/segments)*1.04,.12,.13],[x+radius*math.cos(angle),y+radius*math.sin(angle),z],color,bone,math.degrees(angle)+90)
 ring('HollowCrown',0,4.65,.42,1.0,12 if identity=='keeper_of_names'else 8,'bronze','Head')
 if identity=='keeper_of_names':
  for i,(x,y)in enumerate([(-2.05,4.25),(2.05,4.25),(0,6.15)]):
   ring('SealRing'+str(i+1),x,y,-.1,.4,8,'bronze','UpperTorso')
   box('SealCore'+str(i+1),[.22,.42,.12],[x,y,-.1],'teal'if i<2 else 'violet',rz=45)
  box('LedgerPlate',[1.35,.2,.95],[0,2.0,-1.0],'bronze','LowerTorso')
  box('LedgerPages',[1.18,.1,.8],[0,2.16,-1.0],'ivory','LowerTorso')
 else:
  box('OathShield',[1.35,1.9,.25],[-1.38,2.3,-.55],'navy','LeftHand')
  box('ShieldSigil',[.65,.65,.14],[-1.38,2.4,-.75],'teal','LeftHand',45)
  for i in range(3):box('BindingSeal'+str(i+1),[.38,.45,.14],[(i-1)*.5,3.65,-.66],'violet',rz=45)
 for p in a['parts']:
  p['position']=[round(v*scale,5)for v in p['position']];p['size']=[round(v*scale,5)for v in p['size']]
 for b in a['bones']:
  for key in ['head','tail']:b[key]=[round(v*scale,5)for v in b[key]]
 assert len(a['parts'])*12<1000
 assets.append(a)
(out/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
print('ARCHIVE_HEART_BOSSES',len(assets),'rigs',sum(len(a['parts'])for a in assets),'parts',sum(len(a['parts'])*12 for a in assets),'triangles')
