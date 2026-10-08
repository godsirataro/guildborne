"""Original Tower council and archive outfits on editable Guildborne skeletons."""
from pathlib import Path
import copy,json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/tower-cast';OUT.mkdir(parents=True,exist_ok=True)
course=json.loads((ROOT/'assets/uat01/course-characters/kit.json').read_text(encoding='utf-8'))
orcs=json.loads((ROOT/'assets/uat01/friendly-orcs/kit.json').read_text(encoding='utf-8'))
palette=course['palette']|{'tower_navy':[42,57,76],'ivory':[216,207,185],'brass':[188,149,75],'tower_teal':[64,195,185],'ink':[29,37,50]}
palette.update({'orc_'+k:v for k,v in orcs['palette'].items()});assets=[]
roles=[('charter_warden','courier','Human'),('archivist','elf_traveler','Elf'),('council_clerk','dwarf_traveler','Dwarf'),('bookbinder','ghar','Orc')]
for identity,source,race in roles:
 data=orcs if race=='Orc'else course;a=copy.deepcopy(next(a for a in data['assets']if a['id']==source))
 a.update(id=identity,designId='npc.tower.'+identity,region=race,role='Story',friendly=True)
 removed={'Pack','Bedroll','MapRoll','Apron','Pocket','Mug','MugRim','BreadPouch','Satchel','Letter','Scroll','Staff','StaffTop','StaffGem'}
 a['parts']=[p for p in a['parts']if p['name']not in removed]
 for p in a['parts']:
  if race=='Orc':p['color']='orc_'+p['color']
  elif p['color']in {'red','blue'}:p['color']='tower_navy'
 def box(name,size,pos,color,bone='UpperTorso',rz=0):a['parts'].append(dict(name=name,size=size,position=pos,color=color,bone=bone,rotation=[0,0,rz]))
 if identity=='charter_warden':
  box('WardenTabard',[1.6,1.9,.14],[0,2.8,-.63],'ivory')
  box('CharterCrest',[.65,.65,.1],[0,3.15,-.77],'brass',rz=45)
  for x in [-1,1]:box('ShoulderGuard',[.9,.45,1.1],[x,3.55,0],'brass','LeftUpperArm'if x<0 else 'RightUpperArm')
  box('TrainingShield',[.9,1.5,.2],[1.45,1.85,-.55],'tower_navy','RightHand')
  box('ShieldInlay',[.16,1.1,.1],[1.45,1.85,-.72],'ivory','RightHand')
  box('PermitRoll',[.55,1,.3],[-1.42,1.8,-.55],'ivory','LeftHand')
 elif identity=='archivist':
  box('ArchiveMantle',[2.2,.5,1.45],[0,3.2,0],'ivory')
  box('KeyPendant',[.2,.7,.12],[0,3,-.76],'brass')
  box('ArchiveBook',[.9,1.2,.25],[1.42,1.95,-.55],'tower_navy','RightHand')
  box('BookPages',[.7,1,.3],[1.42,1.95,-.55],'ivory','RightHand')
  box('BookSpine',[.14,1.2,.35],[1.05,1.95,-.55],'brass','RightHand')
  box('ReadingCrystal',[.4,.8,.4],[-1.4,2,-.5],'tower_teal','LeftHand',25)
 elif identity=='council_clerk':
  box('CouncilVest',[1.65,1.6,.14],[0,2.2,-.75],'tower_navy')
  for x in [-.55,.55]:box('VestPiping',[.12,1.5,.1],[x,2.2,-.88],'brass')
  box('LedgerBoard',[1.1,.9,.2],[-1.4,1.75,-.6],'wood','LeftHand')
  box('LedgerPaper',[.9,.7,.06],[-1.4,1.75,-.73],'ivory','LeftHand')
  box('CouncilStamp',[.45,.65,.45],[1.4,1.85,-.55],'brass','RightHand')
  box('StampBase',[.6,.2,.6],[1.4,1.5,-.55],'ink','RightHand')
 else:
  box('BindingApron',[1.8,1.8,.16],[0,2.6,-.75],'ivory')
  box('ApronPocket',[.75,.5,.16],[.35,2.35,-.88],'tower_navy')
  box('BindingBook',[1.1,1.25,.3],[-1.4,1.9,-.55],'tower_navy','LeftHand')
  box('BookEdge',[.9,1.05,.32],[-1.4,1.9,-.55],'ivory','LeftHand')
  box('BindingBand',[.18,1.3,.4],[-1.4,1.9,-.55],'brass','LeftHand')
  box('BindingTool',[.18,1.15,.18],[1.4,1.95,-.5],'wood','RightHand')
  box('BindingTip',[.45,.4,.3],[1.4,2.65,-.5],'brass','RightHand')
 assets.append(a)
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
print('TOWER_CAST',len(assets),'rigs',sum(len(a['parts'])for a in assets),'parts')
