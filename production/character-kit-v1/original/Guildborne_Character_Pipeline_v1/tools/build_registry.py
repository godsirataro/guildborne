#!/usr/bin/env python3
"""Generate PLANNED design registry; NOT mesh generation. No external dependencies."""
from pathlib import Path
import json,csv
BASE=Path(__file__).resolve().parents[1]
M=BASE/'manifest'
M.mkdir(parents=True,exist_ok=True)

races={
 'HUMAN': {'label_th':'มนุษย์','body':['SLIM','STANDARD','ATHLETIC','HEAVY'],'reference_height':1.00,'skin':['PORCELAIN','LIGHT','TAN','BROWN','DEEP'],'hair':6,'beard':3,'head':2},
 'ELF': {'label_th':'เอลฟ์','body':['GRACEFUL','RANGER','STURDY'],'reference_height':1.06,'skin':['PEARL','FAIR','GOLDEN','BRONZE','ASH'],'hair':5,'beard':1,'head':2},
 'ORC': {'label_th':'ออร์ค','body':['LEAN','STANDARD','HEAVY'],'reference_height':1.12,'skin':['SAGE','OLIVE','MOSS','FOREST','GREY_GREEN'],'hair':4,'beard':2,'head':2},
 'DWARF': {'label_th':'คนแคระ','body':['COMPACT','BROAD','STOUT'],'reference_height':0.78,'skin':['FAIR','RUDDY','TAN','BRONZE','DEEP_BROWN'],'hair':4,'beard':4,'head':2},
}
extra_ratios={
'HUMAN':{'SLIM':(1.00,0.91),'STANDARD':(1.00,1.00),'ATHLETIC':(1.01,1.07),'HEAVY':(.99,1.17)},
'ELF':{'GRACEFUL':(1.06,.89),'RANGER':(1.04,1.01),'STURDY':(1.04,1.12)},
'ORC':{'LEAN':(1.08,1.05),'STANDARD':(1.12,1.25),'HEAVY':(1.10,1.40)},
'DWARF':{'COMPACT':(.78,1.12),'BROAD':(.79,1.31),'STOUT':(.76,1.43)} }

presets=[]
for race,r in races.items():
 for p in r['body']:
  ratio, width=extra_ratios[race][p]
  presets.append({'bodyPresetId':f'{race}_{p}','raceId':race,'visualHeightRatioToHuman':ratio,'relativeShoulderWidth':width,
   'fitProfile': 'FAMILY_DWARF' if race=='DWARF' else 'FAMILY_ORC' if race=='ORC' else 'FAMILY_HUMANOID',
   'status':'PLANNED','notes':'Art target only; Studio geometry and fit must be tested, not combat-stat scaling.'})
(M/'body_presets.json').write_text(json.dumps({'schemaVersion':1,'presets':presets},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

palettes=[]
# illustrative palette hex codes, not demographic classification; require visual review after material tinting
pal_colors={
 'HUMAN':['F3D9C0','E8BE97','C68D60','94613E','573928'],
 'ELF':['F0E4D8','EBD1B8','DDAC79','A77C58','A1A3A0'],
 'ORC':['ADB48A','929C60','687746','455D39','8C9B87'],
 'DWARF':['EDCCB2','DCA98E','C18C63','90623F','624737']
}
for race,r in races.items():
 for i,(name,hx) in enumerate(zip(r['skin'],pal_colors[race]),1):
  palettes.append({'skinPaletteId':f'SKIN_{race}_{i:02d}','raceId':race,'label':name,'colorHex':f'#{hx}',
  'status':'PLANNED','notes':'Config option, not individual new body mesh. Validate tint with actual material.'})
(M/'skin_palettes.json').write_text(json.dumps({'schemaVersion':1,'palettes':palettes},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

entries=[]
def add(asset_id,category,race='ALL',variant='',slot='',fit='ANY',tech='MESH',priority='P1',note=''):
 if category=='BODY': prefix='characters'
 elif category in ('CLOTHING','ARMOR'): prefix='clothing'
 else: prefix='accessories'
 rec={
  'asset_id':asset_id,'category':category,'race':race,'variant':variant,'slot':slot,
  'fit_profile':fit,'technology':tech,
  'source_path':f'assets/{prefix}/source/{asset_id}.blend',
  'export_path':f'assets/{prefix}/export/{asset_id}.fbx',
  'studio_path':('ServerStorage/CharacterAssets/Bodies' if category=='BODY' else 'ServerStorage/CharacterAssets/Clothing' if category in ('CLOTHING','ARMOR') else 'ServerStorage/CharacterAssets/Accessories')+f'/{asset_id}',
  'priority':priority,'status':'PLANNED','roblox_asset_id':None,'notes':note
 }
 entries.append(rec)

for p in presets:
 r, variant=p['raceId'],p['bodyPresetId'].split('_',1)[1]
 add(f'CHR_BDY_{r}_{variant}_V01','BODY',r,variant,'BODY',p['fitProfile'],'R15_15PART',
  'P0' if r=='HUMAN' and variant in ('STANDARD','HEAVY') else 'P1' if variant in ('STANDARD','GRACEFUL','COMPACT') else 'P2',
  '15 actual visible meshes + rig + cage/attachments; modesty-safe; not a complete garment.')
for race,r in races.items():
 for i in range(1,r['head']+1):
  add(f'CHR_HEAD_{race}_{i:02d}','HEAD',race,f'FACE_{i:02d}','HEAD',
  'FAMILY_DWARF' if race=='DWARF' else 'FAMILY_ORC' if race=='ORC' else 'FAMILY_HUMANOID',
  'HEAD_R15', 'P1' if i==1 else 'P2', 'Alternate head geometry; head mesh/joints/cage must remain compatible.')
 for i in range(1,r['hair']+1):
  add(f'ACC_HAIR_{race}_{i:02d}','HAIR',race,f'HAIR_{i:02d}','HAIR',
   'PRESET_SPECIFIC' if race in ('ORC','DWARF') else 'FAMILY_HUMANOID','RIGID','P1' if i<=2 else 'P2', 'Removable hairstyle; test attachment offsets on all claimed presets.')
 for i in range(1,r['beard']+1):
  add(f'ACC_BEARD_{race}_{i:02d}','BEARD',race,f'BEARD_{i:02d}','BEARD','PRESET_SPECIFIC','RIGID',
   'P1' if race=='DWARF' and i==1 else 'P2','Optional removable facial hair; never permanently fused to head.')
for i in range(1,3):
 add(f'ACC_EAR_ELF_{i:02d}','RACE_FEATURE','ELF',f'EAR_{i:02d}','RACE_FEATURE','FAMILY_HUMANOID','RIGID','P1','Paired removable pointed ears, fit to Elf heads.')
 add(f'ACC_TUSK_ORC_{i:02d}','RACE_FEATURE','ORC',f'TUSK_{i:02d}','RACE_FEATURE','FAMILY_ORC','RIGID','P1','Paired short tusks, independently removable and fit to Orc heads.')

clothes=[
('TUNIC_TRAVELER_01','INNER_TOP','FAMILY_HUMANOID','LAYERED','P0'),
('TROUSERS_TRAVELER_01','INNER_BOTTOM','FAMILY_HUMANOID','LAYERED','P0'),
('TUNIC_TRAVELER_02','INNER_TOP','FAMILY_HUMANOID','LAYERED','P1'),
('TROUSERS_TRAVELER_02','INNER_BOTTOM','FAMILY_HUMANOID','LAYERED','P1'),
('SHIRT_LINEN_01','INNER_TOP','FAMILY_HUMANOID','LAYERED','P1'),
('PANTS_WORKER_01','INNER_BOTTOM','FAMILY_HUMANOID','LAYERED','P1'),
('ROBE_MAGE_01','OUTER_TOP','FAMILY_HUMANOID','LAYERED','P1'),
('ROBE_PRIEST_01','OUTER_TOP','FAMILY_HUMANOID','LAYERED','P1'),
('CLOAK_TRAVELER_01','CAPE','FAMILY_HUMANOID','LAYERED','P1'),
('CLOAK_GUILD_01','CAPE','FAMILY_HUMANOID','LAYERED','P2'),
('GLOVES_LEATHER_01','GLOVES','FAMILY_HUMANOID','RIGID','P1'),
('BOOTS_LEATHER_01','BOOTS','FAMILY_HUMANOID','RIGID','P1'),
('BELT_TRAVELER_01','BELT','FAMILY_HUMANOID','RIGID','P1'),
('HOOD_RANGER_01','HEADWEAR','FAMILY_HUMANOID','RIGID','P1'),
('TUNIC_ORC_01','INNER_TOP','FAMILY_ORC','LAYERED','P1'),
('TROUSERS_ORC_01','INNER_BOTTOM','FAMILY_ORC','LAYERED','P1'),
('TUNIC_DWARF_01','INNER_TOP','FAMILY_DWARF','LAYERED','P1'),
('TROUSERS_DWARF_01','INNER_BOTTOM','FAMILY_DWARF','LAYERED','P1'),
('ROBE_WIZARD_01','OUTER_TOP','FAMILY_HUMANOID','LAYERED','P1'),
('HAT_WIZARD_01','HEADWEAR','FAMILY_HUMANOID','RIGID','P1'),
('SHOULDER_KNIGHT_01','SHOULDERS','FAMILY_HUMANOID','RIGID','P1'),
('CHEST_KNIGHT_01','CHEST_ARMOR','FAMILY_HUMANOID','RIGID','P1'),
('CHEST_WARRIOR_01','CHEST_ARMOR','FAMILY_HUMANOID','RIGID','P1'),
('CHEST_RANGER_01','CHEST_ARMOR','FAMILY_HUMANOID','RIGID','P1'),
('CHEST_ORC_01','CHEST_ARMOR','FAMILY_ORC','RIGID','P2'),
('CHEST_DWARF_01','CHEST_ARMOR','FAMILY_DWARF','RIGID','P2'),
('BOOTS_DWARF_01','BOOTS','FAMILY_DWARF','RIGID','P2'),
('GLOVES_ORC_01','GLOVES','FAMILY_ORC','RIGID','P2'),
]
for asset,slot,fit,tech,priority in clothes:
 typ='ARMOR' if slot in ('CHEST_ARMOR','SHOULDERS') else 'CLOTHING'
 add(f'{"ARM" if typ=="ARMOR" else "CLO"}_{asset}',typ,'ALL',asset,slot,fit,tech,priority,
  'Independent wearable. For LAYERED, generate valid cages and test bends; for RIGID, configure attachments. Fit profile is target, not pass proof.')

# canonical weapon visual test references: do not replace existing weapon IDs in production
for cls,w in [('KNIGHT','SHIELD'),('WARRIOR','SWORD'),('ARCHER','BOW'),('MAGE','STAFF'),('PRIEST','MACE')]:
 add(f'ACC_TESTWEAPON_{w}_01','TEST_ACCESSORY','ALL',cls,'WEAPON','FAMILY_HUMANOID','RIGID','P1',
  'QA attachment visual only; map to existing gameplay weapon if available; do not make new weapons accidentally.')

# one outfit preset, no new body biology
for name,slot in [('WIZARD_HAIR_01','HAIR'),('WIZARD_BEARD_01','BEARD')]:
 add(f'ACC_{name}','WIZARD_APPEARANCE','HUMAN',name,slot,'FAMILY_HUMANOID','RIGID','P2',
 'Wizard Human visual bundle; not a race/class unlock.')

manifest={'schemaVersion':1,'catalogStatus':'PLANNED_SPECIFICATION_NOT_GENERATED_ASSETS',
 'sourceOfTruth':'03_SHARED_CONTRACT.md','assets':entries}
(M/'asset_registry.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
fields=list(entries[0].keys())
with (M/'asset_registry.csv').open('w',newline='',encoding='utf-8-sig') as f:
 w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(entries)
with (M/'body_presets.csv').open('w',newline='',encoding='utf-8-sig') as f:
 w=csv.DictWriter(f,fieldnames=list(presets[0].keys()));w.writeheader();w.writerows(presets)
with (M/'skin_palettes.csv').open('w',newline='',encoding='utf-8-sig') as f:
 w=csv.DictWriter(f,fieldnames=list(palettes[0].keys()));w.writeheader();w.writerows(palettes)

check=[]
check_clothes=['CLO_TUNIC_TRAVELER_01','CLO_TROUSERS_TRAVELER_01','CLO_ROBE_MAGE_01','CLO_BOOTS_LEATHER_01','ARM_CHEST_KNIGHT_01']
for p in presets:
 for cl in check_clothes:
  check.append({'body_preset_id':p['bodyPresetId'],'clothing_asset_id':cl,'visual_fit':'NOT_TESTED',
                'deformation':'NOT_TESTED','clipping':'NOT_TESTED','mobile':'NOT_TESTED','notes':''})
with (M/'fit_qa_matrix.csv').open('w',newline='',encoding='utf-8-sig') as f:
 w=csv.DictWriter(f,fieldnames=list(check[0].keys()));w.writeheader();w.writerows(check)

# Generated human-readable table, no inferred completed work
lines=['# Planned Asset Registry (Generated from manifest)','',
 '**All rows are design entries (`PLANNED`), not 3D meshes already generated, rigged, imported or verified.**','',
 '| Asset ID | Category | Race | Slot | Fit target | Method | Priority |',
 '|---|---|---|---|---|---|---|']
for e in entries:
 lines.append('| '+ ' | '.join([e['asset_id'],e['category'],e['race'],e['slot'] or '—',e['fit_profile'],e['technology'],e['priority']])+' |')
(BASE/'04_ASSET_REGISTRY.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('Registry rows:',len(entries),'Presets:',len(presets),'Palettes:',len(palettes),'Fitting test rows:',len(check))
from collections import Counter
print('By category:',dict(Counter(e['category'] for e in entries)))
