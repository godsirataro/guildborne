"""Six original civic outfits using the project's editable friendly skeletons."""
from pathlib import Path
import copy,json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/city-cast';OUT.mkdir(parents=True,exist_ok=True)
course=json.loads((ROOT/'assets/uat01/course-characters/kit.json').read_text(encoding='utf-8'))
orcs=json.loads((ROOT/'assets/uat01/friendly-orcs/kit.json').read_text(encoding='utf-8'))
palette=course['palette']|{'civic_navy':[40,59,83],'ivory':[229,216,185],'brass':[192,151,75],'fern':[66,119,80],'copper':[178,111,69],'astral':[97,80,151],'harbor':[51,140,151],'hearth':[160,79,50]}
palette.update({'orc_'+k:v for k,v in orcs['palette'].items()})
roles=[('marshal_elian','courier','Human','Crownford','Charter marshal','civic_navy'),('arborist_vaela','elf_traveler','Elf','Sylvaris','Garden keeper','fern'),('smith_borin','dwarf_traveler','Dwarf','Deepforge','Forge steward','copper'),('cartographer_nyra','courier','Human','Astralis','Astral cartographer','astral'),('harbormaster_sela','courier','Human','Crosshaven','Harbormaster','harbor'),('steward_roka','ghar','Orc','Ironroot','Community steward','hearth')]
assets=[]
for identity,source,race,city,role,color in roles:
 data=orcs if race=='Orc'else course
 a=copy.deepcopy(next(a for a in data['assets']if a['id']==source))
 a.update(id=identity,designId='npc.city.'+identity,region=city,role=role,friendly=True,race=race)
 removed={'Pack','Bedroll','MapRoll','Apron','Pocket','Mug','MugRim','BreadPouch','Satchel','Letter','Scroll','Staff','StaffTop','StaffGem'}
 a['parts']=[p for p in a['parts']if p['name']not in removed]
 for p in a['parts']:
  if race=='Orc':p['color']='orc_'+p['color']
  elif p['color']in {'red','blue'}:p['color']=color
 def box(name,size,pos,tint,bone='UpperTorso',angle=0):
  a['parts'].append(dict(name=name,size=size,position=pos,color=tint,bone=bone,rotation=[0,0,angle]))
 if city=='Crownford':
  box('CivicTabard',[1.55,1.8,.18],[0,2.7,-.65],color)
  box('CharterSash',[.25,2,.16],[0,2.95,-.8],'ivory',angle=24)
  box('CivicSeal',[.55,.55,.12],[0,3.2,-.94],'brass',angle=45)
  box('CharterCase',[.75,1.15,.3],[-1.4,1.9,-.5],'ivory','LeftHand')
  box('CaseBand',[.85,.2,.4],[-1.4,1.9,-.5],'brass','LeftHand')
 elif city=='Sylvaris':
  box('GardenApron',[1.5,1.7,.18],[0,2.5,-.66],color)
  box('SeedPouch',[.65,.6,.28],[.4,2.25,-.84],'ivory')
  box('PruningHandle',[.16,1.1,.16],[1.4,1.9,-.5],'wood','RightHand')
  box('PruningBlade',[.45,.15,.18],[1.6,2.5,-.5],'brass','RightHand',20)
  box('SaplingTray',[.8,.18,.7],[-1.4,1.65,-.6],'wood','LeftHand')
  for x in [-1.6,-1.3]:
   box('SeedlingStem',[.08,.55,.08],[x,1.95,-.6],'fern','LeftHand')
   box('SeedlingLeaf',[.32,.16,.12],[x,2.12,-.6],'fern','LeftHand',30)
 elif city=='Deepforge':
  box('HeatApron',[1.75,1.5,.2],[0,2.1,-.76],color)
  box('ApronPocket',[.7,.45,.16],[.35,1.95,-.94],'civic_navy')
  box('HammerHandle',[.17,1.1,.17],[1.4,1.8,-.55],'wood','RightHand')
  box('HammerHead',[.8,.4,.38],[1.4,2.4,-.55],'brass','RightHand')
  box('ForgeTongs',[.14,.95,.15],[-1.5,1.9,-.55],'civic_navy','LeftHand',-12)
  box('ForgeTongs',[.14,.95,.15],[-1.25,1.9,-.55],'civic_navy','LeftHand',12)
 elif city=='Astralis':
  box('AstrolabeMantle',[2.2,.45,1.4],[0,3.35,0],color)
  box('MapSatchel',[.75,.85,.35],[.8,2.35,-.68],'civic_navy')
  box('ChartBoard',[1.1,1,.18],[-1.4,1.9,-.55],'brass','LeftHand')
  box('StarChart',[.95,.85,.1],[-1.4,1.9,-.7],'ivory','LeftHand')
  for x,y in [(-1.65,2.12),(-1.2,1.92),(-1.5,1.65)]:box('ChartStar',[.13,.13,.05],[x,y,-.77],color,'LeftHand',45)
  box('SurveyWand',[.13,1.3,.13],[1.4,2,-.5],'brass','RightHand')
  box('SurveyPrism',[.4,.5,.4],[1.4,2.8,-.5],'harbor','RightHand',45)
 elif city=='Crosshaven':
  box('HarborCoat',[1.7,1.9,.18],[0,2.6,-.66],color)
  for x in [-.45,.45]:
   for y in [2.2,2.6,3]:box('CoatButton',[.14,.14,.08],[x,y,-.8],'brass')
  box('CargoLedger',[.95,1.15,.25],[-1.4,1.9,-.55],'ivory','LeftHand')
  box('LedgerSpine',[.15,1.15,.3],[-1.8,1.9,-.55],color,'LeftHand')
  box('SignalFlagPole',[.13,1.6,.13],[1.4,2,-.5],'wood','RightHand')
  box('SignalFlag',[.75,.65,.08],[1.78,2.6,-.5],'ivory','RightHand')
 else:
  box('HearthApron',[1.85,1.9,.2],[0,2.55,-.76],color)
  box('ApronBorder',[1.9,.2,.12],[0,1.75,-.92],'ivory')
  box('CommunityMedal',[.55,.55,.14],[0,3.15,-.92],'brass',angle=45)
  box('ServingBoard',[1.1,.18,.75],[-1.4,1.7,-.65],'wood','LeftHand')
  box('SharedBread',[.85,.4,.55],[-1.4,1.98,-.65],'ivory','LeftHand')
  box('LadleHandle',[.15,1.3,.15],[1.4,1.95,-.5],'wood','RightHand')
  box('LadleBowl',[.55,.3,.55],[1.4,2.65,-.5],'brass','RightHand')
 assets.append(a)
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
print('CITY_CAST',len(assets),'rigs',sum(len(a['parts'])for a in assets),'parts; gameplay unbound')
