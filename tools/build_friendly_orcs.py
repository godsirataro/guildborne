"""Original friendly Orc townspeople: editable geometry and shared16-bone rigs."""
from pathlib import Path
import copy,json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/friendly-orcs';OUT.mkdir(parents=True,exist_ok=True)
hero=json.loads((ROOT/'assets/uat01/hero-kit/kit.json').read_text(encoding='utf-8'))
palette={'olive':[111,146,91],'sage':[139,166,105],'deepgreen':[87,127,91],'teal':[70,130,133],'ochre':[183,139,70],'burgundy':[131,62,67],'cream':[222,211,179],'slate':[79,101,126],'rust':[155,88,60],'leather':[76,61,53],'wood':[131,92,55],'steel':[162,175,175],'gold':[198,160,79],'dark':[36,42,40],'leaf':[69,135,82],'glass':[110,192,176]}
assets=[]
for name,role,skin,cloth in [('borga','Innkeeper','olive','ochre'),('mogra','Herbalist','sage','cream'),('rukk','ApprenticeSmith','deepgreen','teal'),('ghar','Mercenary','olive','slate')]:
 p=[]
 def box(n,size,pos,color,bone='UpperTorso',rz=0):p.append(dict(name=n,size=size,position=pos,color=color,bone=bone,rotation=[0,0,rz]))
 for n,size,pos,color,bone in [('Waist',[1.48,.6,.85],[0,2.45,0],cloth,'LowerTorso'),('Chest',[1.9,.9,1.05],[0,3.2,0],cloth,'UpperTorso'),('Belt',[1.55,.18,.94],[0,2.35,0],'leather','LowerTorso'),('Head',[1.45,1.12,1.18],[0,4.35,0],skin,'Head')]:box(n,size,pos,color,bone)
 for side,sign in [('Left',-1),('Right',1)]:
  box(side+'EyeWhite',[.24,.22,.045],[sign*.3,4.45,-.606],'cream','Head')
  box(side+'Eye',[.14,.16,.055],[sign*.3,4.45,-.61],'dark','Head')
  box(side+'Ear',[.42,.42,.28],[sign*.83,4.47,.02],skin,'Head',sign*22)
  box(side+'Tusk',[.12,.27,.14],[sign*.4,4.02,-.66],'cream','Head',-sign*14)
  for n,size,y,color,bone in [('UpperArm',[.62,.74,.7],3.27,cloth,'UpperArm'),('LowerArm',[.58,.6,.64],2.57,skin,'LowerArm'),('Hand',[.55,.36,.61],2.03,skin,'Hand')]:box(side+n,size,[sign*1.16,y,0],color,side+bone)
  for n,size,y,z,color,bone in [('UpperLeg',[.65,.87,.71],1.69,0,'leather','UpperLeg'),('LowerLeg',[.61,.7,.69],.77,0,cloth,'LowerLeg'),('Boot',[.76,.43,1.05],.235,-.18,'leather','Foot')]:box(side+n,size,[sign*.48,y,z],color,side+bone)
 box('Smile',[.36,.055,.06],[0,4.04,-.615],'dark','Head')
 for sign in [-1,1]:
  box('Brow',[.35,.07,.08],[sign*.3,4.67,-.64],'dark','Head',-sign*4)
  box('SmileCorner',[.06,.12,.065],[sign*.2,4.07,-.62],'dark','Head')
 if name=='borga':
  box('HairCrown',[1.5,.3,1.2],[0,4.97,.03],'leather','Head')
  box('ShortBeard',[1.05,.3,.23],[0,3.9,-.55],'leather','Head')
  for sign in [-1,1]:box('Sideburn',[.2,.4,.18],[sign*.66,4.15,-.5],'leather','Head')
  box('Apron',[1.5,1.6,.15],[0,2.78,-.58],'burgundy');box('Pocket',[.52,.38,.12],[.32,2.49,-.7],'ochre')
  box('Mug',[.42,.52,.42],[1.16,1.97,-.45],'wood','RightHand');box('MugRim',[.46,.08,.46],[1.16,2.26,-.45],'steel','RightHand')
  box('BreadPouch',[.5,.55,.4],[-.72,2.27,-.5],'wood','LowerTorso')
 elif name=='mogra':
  box('HairCrown',[1.5,.3,1.2],[0,4.97,.03],'dark','Head')
  box('HairBun',[.63,.6,.62],[0,5.36,.17],'dark','Head')
  box('BunRibbon',[.65,.1,.64],[0,5.3,.17],'ochre','Head')
  for i in range(3):box('Braid'+str(i),[.3,.3,.28],[-.68,4.14-i*.25,-.55],'dark','Head',8*(-1 if i%2 else 1))
  box('Shawl',[2,.22,1.13],[0,3.68,0],'leaf');box('Apron',[1.4,1.4,.16],[0,2.6,-.57],'leaf')
  box('Satchel',[.65,.65,.5],[-.89,2.3,.05],'wood','LowerTorso')
  for i in range(3):box('Herb'+str(i),[.12,.52,.13],[-1.07+i*.17,2.82,.05],'leaf','LowerTorso',i*12-12)
  box('Potion',[.3,.4,.3],[1.15,1.96,-.43],'glass','RightHand');box('Stopper',[.2,.14,.2],[1.15,2.22,-.43],'wood','RightHand')
 elif name=='rukk':
  for i in range(4):box('HairTuft'+str(i),[.33,.32,.9],[-.54+i*.35,5.02,.09],'dark','Head',i*9-12)
  box('Apron',[1.5,1.6,.17],[0,2.77,-.58],'leather');box('HammerHandle',[.15,.8,.15],[1.16,2,-.38],'wood','RightHand')
  box('HammerHead',[.62,.28,.3],[1.16,2.39,-.38],'steel','RightHand')
  box('GoggleStrap',[1.49,.17,1.2],[0,4.85,0],'leather','Head')
  for sign in [-1,1]:box('GoggleRim',[.4,.3,.15],[sign*.32,4.87,-.65],'gold','Head');box('GoggleGlass',[.25,.17,.08],[sign*.32,4.87,-.77],'glass','Head')
 else:
  box('CroppedHair',[1.48,.18,1.16],[0,4.93,.03],'dark','Head')
  box('Beard',[.95,.23,.2],[0,3.92,-.55],'dark','Head')
  box('Breastplate',[1.6,.85,.19],[0,3.22,-.6],'steel');box('Scarf',[1.62,.25,1.16],[0,3.78,0],'rust')
  box('ScarfTail',[.32,.95,.15],[-.48,3.3,-.74],'rust')
  box('Shield',[1.2,1.7,.25],[-1.34,2.06,-.49],'wood','LeftHand');box('ShieldBand',[1.22,.17,.14],[-1.34,2.08,-.68],'steel','LeftHand')
 assert len(p)<=64
 assets.append(dict(id=name,displayName=name.title(),region='Orc',role=role,designId='NPC_ORC_'+name.upper(),rigType='Humanoid',parts=p,bones=copy.deepcopy(hero['assets'][0]['bones'])))
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
print('FRIENDLY_ORCS',len(assets),'actors',sum(len(a['parts']) for a in assets),'parts')
