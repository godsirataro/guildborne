"""Inventory local institutional architecture after export and walkthrough checks."""
from pathlib import Path
from collections import Counter
import json,re
R=Path(__file__).resolve().parents[1];cities=['Crownford','Sylvaris','Deepforge','Astralis','Crosshaven','Ironroot']
w=json.loads((R/'docs/uat01/validation-civic-institutions-walk.json').read_text());assert w['routeCount']==48 and len(w['ordinaryWalk'])==12 and all(v['distance']<2 and v['health']==100 for v in w['ordinaryWalk'])
p=R/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for city in cities:
 folder=f'assets/uat01/{city.lower()}-institutions-v1';reports=json.loads((R/folder/'roundtrip-report.json').read_text());assert len(reports)==4 and all(v['status']=='PASS'for v in reports)
 kit=json.loads((R/folder/'kit.json').read_text())
 for kind in ['Forge','QuestHall']:
  identity=f'world.{city.lower()}.{kind.lower()}_architecture';d['assets']=[a for a in d['assets']if a['designId']!=identity]
  d['assets'].append(dict(designId=identity,group='City architecture',priority='P1',status='LOCAL_INSTITUTION_ARCHITECTURE_WALK_VERIFIED_GAMEPLAY_PENDING',source=folder+'/; docs/uat01/CIVIC_INSTITUTIONS.md',productionBinding=f'{len(kit["buildings"][kind]["parts"])} native parts replace the {city} {kind} shell. Blender, GLB and FBX geometry checks; 48 district paths and ordinary WASD entry into all 12 new buildings passed. No new game service or reward rules; final likeness, device and human approval pending.',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header=f'> Institutions and cast checkpoint — 2026-10-07: all six cities now have native market, tavern, forge and quest-hall architecture (24 buildings). Twelve new forge/hall buildings: 24 GLB/FBX checks, 48 district routes, 12 ordinary WASD entries pass. Standalone six-NPC city/cast fixture supports independently paused/distance-culled work, with ordinary E acceptance; main-world detailed NPC binding still pending. Bow draw/reload contact study verified; gameplay retarget pending. Registry {len(d["assets"])} assets / 73 screens / 33 work areas. 316 runtime sources; main/offline and review builds updated. Latest quota 17% used / 83% remaining; stop at 25% remaining and normal shutdown after saving.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=R/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Institutions and cast checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=R/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.', 'Latest observed quota: 17% used / 83% remaining.',s);p.write_text(s,encoding='utf-8')
print('INSTITUTIONS_CHECKPOINT',len(d['assets']))
