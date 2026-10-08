"""Editable Ashen story cast; original outfits on existing Guildborne skeletons."""
from pathlib import Path
import copy,json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/ashen-cast';OUT.mkdir(parents=True,exist_ok=True)
course=json.loads((ROOT/'assets/uat01/course-characters/kit.json').read_text(encoding='utf-8'))
orcs=json.loads((ROOT/'assets/uat01/friendly-orcs/kit.json').read_text(encoding='utf-8'))
palette=course['palette']|{'ash_cloth':[90,82,108],'ivory':[210,203,186],'copper':[185,121,73],'memory_teal':[73,192,183],'coal':[44,42,58]}
palette.update({'orc_'+k:v for k,v in orcs['palette'].items()})
assets=[]
for identity,source,race in [('gatekeeper','courier','Human'),('survivor','elf_traveler','Elf'),('bridgewright','dwarf_traveler','Dwarf'),('witness','ghar','Orc')]:
 data=orcs if race=='Orc'else course;base=next(a for a in data['assets']if a['id']==source)
 a=copy.deepcopy(base);a.update(id=identity,designId='npc.ashen.'+identity,region=race,role='Story',friendly=True)
 removed={'Pack','Bedroll','MapRoll','Apron','Pocket','Mug','MugRim','BreadPouch','Satchel','Letter','Scroll','Staff','StaffTop','StaffGem'}
 a['parts']=[p for p in a['parts']if p['name']not in removed]
 for p in a['parts']:
  if race=='Orc':p['color']='orc_'+p['color']
  elif p['color']in {'red','blue'}:p['color']='ash_cloth'
 def box(name,size,pos,color,bone='UpperTorso',rz=0):a['parts'].append(dict(name=name,size=size,position=pos,color=color,bone=bone,rotation=[0,0,rz]))
 if identity=='gatekeeper':
  box('RecoveryTabard',[1.6,1.9,.13],[0,2.8,-.61],'ivory')
  box('CheckpointBadge',[.55,.55,.08],[0,3.2,-.73],'copper',rz=45)
  box('LanternHandle',[.18,.6,.18],[1.45,1.7,-.5],'copper','RightHand')
  box('LanternCage',[.85,.9,.65],[1.45,1.08,-.5],'coal','RightHand')
  box('LanternGlow',[.55,.65,.7],[1.45,1.08,-.5],'gold','RightHand')
  box('GateLedger',[.85,1,.16],[-1.42,1.8,-.5],'ash_cloth','LeftHand')
 elif identity=='survivor':
  box('MemoryShawl',[2.1,.45,1.4],[0,3.2,0],'ivory')
  box('KeepsakeFrame',[.75,.9,.16],[1.42,1.9,-.55],'copper','RightHand')
  box('KeepsakeGlass',[.55,.7,.06],[1.42,1.9,-.67],'memory_teal','RightHand')
  box('MemoryPendant',[.32,.32,.12],[0,3,-.71],'memory_teal',rz=45)
 elif identity=='bridgewright':
  box('WorkApron',[1.6,1.5,.15],[0,2.15,-.72],'ivory')
  box('ToolBelt',[1.8,.25,1.3],[0,1.7,0],'coal','LowerTorso')
  box('HammerHandle',[.18,1.2,.18],[1.4,1.9,-.5],'wood','RightHand')
  box('HammerHead',[.85,.4,.45],[1.4,2.5,-.5],'copper','RightHand')
  box('PlanBoard',[1,.7,.14],[-1.45,1.8,-.55],'memory_teal','LeftHand')
  for y in [1.65,1.95]:box('PlanMark',[.7,.06,.06],[-1.45,y,-.67],'ivory','LeftHand')
 else:
  box('WitnessSash',[.38,1.9,.15],[0,3,-.7],'ivory',rz=-25)
  box('EvidenceRoll',[.65,.95,.3],[1.42,2,-.55],'ivory','RightHand')
  box('EvidenceSeal',[.22,.22,.1],[1.42,2,-.75],'memory_teal','RightHand',45)
  box('TravelCloak',[1.9,2.2,.2],[0,2.8,.72],'ash_cloth')
 assets.append(a)
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
print('ASHEN_CAST',len(assets),'rigs',sum(len(a['parts'])for a in assets),'parts')
