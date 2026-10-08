"""Inventory authored buildings and distinguish fixture acceptance from full-game UAT."""
from pathlib import Path
from collections import Counter
import json,re
R=Path(__file__).resolve().parents[1];cities=['Crownford','Sylvaris','Deepforge','Astralis','Crosshaven','Ironroot']
p=R/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
counts={}
for city in cities:
 folder=f'assets/uat01/{city.lower()}-services-v1';reports=json.loads((R/folder/'roundtrip-report.json').read_text());assert len(reports)==4 and all(v['status']=='PASS'for v in reports)
 kit=json.loads((R/folder/'kit.json').read_text());counts[city]={k:len(v['parts'])for k,v in kit['buildings'].items()}
 for kind in ['Market','Tavern']:
  identity=f'world.{city.lower()}.{kind.lower()}_architecture'
  d['assets']=[a for a in d['assets']if a['designId']!=identity]
  d['assets'].append(dict(designId=identity,group='City architecture',priority='P1',status='LOCAL_SERVICE_ARCHITECTURE_WALK_VERIFIED_FINAL_ART_PENDING',source=folder+'/; docs/uat01/CIVIC_SERVICE_ARCHITECTURE.md',productionBinding=f'{counts[city][kind]} native parts replace the {city} {kind} shell; existing service marker preserved. Blender+GLB+FBX geometry checks, isolated pathfinding and ordinary WASD entry passed. Full-game repeat transactions, final likeness, devices and human approval pending.',robloxAssetId=None,uatApproved=False))
 for a in d['assets']:
  if a['designId']=='world.city_layout.'+city.lower():
   a['status']='LOCAL_CITY_SERVICES_ARCHITECTURE_BOUND_JOURNEY_PENDING';a['productionBinding']='Earned travel and local services retain existing rules. New native market/tavern architecture bound; all 48 fixture paths and ordinary entry into 12 buildings passed. Full island art, other earned city journeys and device acceptance pending.'
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header=f'> Civic architecture checkpoint — 2026-10-06: 12 city-specific market/tavern buildings now bound as native parts, six editable Blender scenes and 24 verified GLB/FBX exports. 48 native paths / ordinary fixture WASD entry into all 12 buildings passed; full-game repeat service transactions and device/final art approval pending. Six detailed NPC contact studies remain separate from current gameplay rigs. Registry {len(d["assets"])} assets / 73 screens / 33 work areas; 35 AI images / 37 original WAVs. Domain baseline 672 tests; 315 runtime sources; main/offline and architecture review builds updated. Latest quota 11% used / 89% remaining. Stop at 25% remaining, checkpoint/stop owned work, then normal Windows shutdown.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=R/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Civic architecture checkpoint[^\n]*\n\n','',s)
 if name=='WORK_CHECKLIST.md':
  s=s.replace('34 original generated PNGs with manifests/prompts; 438 registry assets after Archive Heart scenes, bosses and three objective VFX glyphs.',f'35 original generated PNGs with manifests/prompts; {len(d["assets"])} registry design slots including six NPC contact studies and twelve city service buildings.')
  s=s.replace('29 original WAVs (10UI+12combat+7city/guild loops)','37 original WAVs (10UI+12combat+7city/guild loops+8civic activity files)')
  s=s.replace('Studio rig import/retarget/blending, motion polish','Six local civic 16-bone activity studies and 96-bone native contact viewer now verified; main-world NPC replacement, Studio rig import/retarget/blending, motion polish')
  s=s.replace('six-city geometry/story and public/shared encounter policy','twelve city service architecture studies now native-bound; 48 updated fixture paths and all12 ordinary WASD entries pass; full island geometry/story and public/shared encounter policy')
 p.write_text(header+'\n\n'+s,encoding='utf-8')
p=R/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.', 'Latest observed quota: 11% used / 89% remaining.',s);p.write_text(s,encoding='utf-8')
for name in ['CIVIC_ART_PRODUCTION.md','CIVIC_CONTACT_ART_V2.md']:
 p=R/'docs/uat01'/name;s=p.read_text(encoding='utf-8');note='> Updated checkpoint: all six local NPC activity studies and twelve native city service buildings now exist; see CIVIC_CONTACT_SIX.md and CIVIC_SERVICE_ARCHITECTURE.md. Historical pending counts below describe their original checkpoint. Final likeness, main-world NPC replacement and human approval remain pending.\n\n'
 if not s.startswith('> Updated checkpoint:'):p.write_text(note+s,encoding='utf-8')
print('CIVIC_ARCHITECTURE_CHECKPOINT',len(d['assets']),counts)
