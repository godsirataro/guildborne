"""Original Chapter 00 cast, reusing the project's editable humanoid topology."""
from pathlib import Path
import copy,json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/course-characters';OUT.mkdir(parents=True,exist_ok=True)
source=json.loads((ROOT/'assets/uat01/hero-kit/kit.json').read_text(encoding='utf-8'))
palette=source['palette']|{'navy':[40,54,79],'teal':[57,110,116],'sage':[99,123,85],'auburn':[132,70,43],'blond':[191,172,126]}
base=next(a for a in source['assets'] if a['id']=='warrior_01')
remove={'GuildClasp','Hair','Headband','ChestStrap','Grip','Guard','Blade','LeftShoulder','RightShoulder'}
assets=[]
for identity,race,cloth,skin,scale in [('courier','Human','navy','skin_mid',[1,1,1]),('dwarf_traveler','Dwarf','red','skin_light',[1.18,.78,1.1]),('elf_traveler','Elf','sage','skin_light',[.94,1.08,.95]),('crossroads_keeper','Human','iron','skin_mid',[1.08,1.07,1.08])]:
 a=copy.deepcopy(base);a.update(id=identity,region=race,role='Melee'if identity=='crossroads_keeper'else 'Story',designId='npc.novice.'+identity,friendly=identity!='crossroads_keeper');a['parts']=[p for p in a['parts']if p['name']not in remove]
 for p in a['parts']:
  if p['color']=='red':p['color']=cloth
  elif p['color']=='skin_light':p['color']=skin
 def box(n,size,pos,color,bone='UpperTorso',rz=0):a['parts'].append(dict(name=n,size=size,position=pos,color=color,bone=bone,rotation=[0,0,rz]))
 hair='auburn'if race=='Dwarf'else 'blond'if race=='Elf'else 'hair'
 box('HairCap',[1.4,.3,1.2],[0,4.99,.02],hair,'Head')
 for side,x in [('Left',-1),('Right',1)]:
  box(side+'Brow',[.25,.065,.065],[x*.3,4.59,-.62],hair,'Head',x*4)
  box(side+'Ear',[.16 if race!='Elf'else .37,.24 if race!='Elf'else .5,.25],[x*(.73 if race!='Elf'else .82),4.4,.0],skin,'Head',x*25 if race=='Elf'else 0)
 box('Mouth',[.25,.045,.06],[0,4.07,-.61],'dark','Head')
 if identity=='courier':
  box('Scarf',[1.48,.24,1.25],[0,3.87,0],'teal');box('ScarfTail',[.38,.8,.17],[.45,3.4,-.63],'teal',rz=-12)
  box('SatchelStrap',[.22,1.7,.15],[0,3.04,-.62],'wood',rz=-35);box('Satchel',[.8,.85,.4],[.86,2.18,-.18],'wood','LowerTorso');box('SatchelFlap',[.86,.23,.1],[.86,2.5,-.44],'gold','LowerTorso')
  box('Envelope',[.83,.5,.1],[1.18,2.01,-.38],'ivory','RightHand');box('Seal',[.15,.15,.05],[1.18,2.01,-.46],'gold','RightHand',45)
 elif identity=='dwarf_traveler':
  box('Beard',[1.1,.7,.3],[0,3.98,-.64],'auburn','Head');box('BeardTip',[.63,.42,.27],[0,3.51,-.64],'auburn','Head')
  box('Pack',[1.3,1.4,.55],[0,3.05,.75],'wood');box('Bedroll',[1.7,.46,.55],[0,3.99,.76],'ivory');box('MapRoll',[.3,.72,.3],[.78,2.3,-.3],'ivory','LowerTorso',-20)
 elif identity=='elf_traveler':
  box('TiedHair',[.5,.8,.3],[0,4.41,.68],'blond','Head');box('Cloak',[1.62,1.9,.18],[0,2.88,.68],'sage');box('Clasp',[.3,.3,.12],[0,3.5,-.59],'gold',rz=45);box('Pack',[1.05,1.05,.5],[0,3.1,.97],'wood')
 else:
  box('Tabard',[1.24,1.65,.17],[0,2.81,-.58],'red');box('FalseCrestLeft',[.26,.57,.09],[-.2,3.16,-.71],'gold',rz=25);box('FalseCrestRight',[.21,.44,.09],[.19,3.23,-.71],'gold',rz=-25)
  box('Helmet',[1.5,.45,1.31],[0,5.02,0],'iron','Head');box('HelmBrow',[1.51,.15,.13],[0,4.76,-.69],'steel','Head')
  for x in [-1,1]:box('Shoulder',[.88,.36,.94],[x*1.14,3.62,0],'iron',('Left'if x<0 else 'Right')+'UpperArm')
  box('Shield',[1.25,1.6,.26],[-1.37,2.22,-.5],'wood','LeftHand');box('ShieldRim',[1.34,.17,.31],[-1.37,3.0,-.5],'iron','LeftHand');box('Grip',[.15,.5,.15],[1.3,1.98,-.35],'wood','RightHand');box('Guard',[.65,.15,.2],[1.3,2.26,-.35],'steel','RightHand');box('Blade',[.25,1.5,.12],[1.3,3.04,-.35],'steel','RightHand')
 for p in a['parts']:
  p['size']=[round(v*scale[i],4)for i,v in enumerate(p['size'])];p['position']=[round(v*scale[i],4)for i,v in enumerate(p['position'])]
 for b in a['bones']:
  for key in ['head','tail']:b[key]=[round(v*scale[i],4)for i,v in enumerate(b[key])]
 assert len(a['parts'])*12<1000
 assets.append(a)
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
print('COURSE_CHARACTERS',len(assets),'parts',sum(len(a['parts'])for a in assets),'triangles',sum(len(a['parts'])*12 for a in assets))
