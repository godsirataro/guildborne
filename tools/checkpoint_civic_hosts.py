"""Record city orientation UI and six friendly city hosts."""
from pathlib import Path
from collections import Counter
import json,re
r=Path(__file__).resolve().parents[1]
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
cities=['crownford','sylvaris','deepforge','astralis','crosshaven','ironroot']
ids={'npc.civic_host.'+c for c in cities}|{'ui.civic.local_map'}
d['assets']=[a for a in d['assets']if a['designId']not in ids]
for c in cities:
 d['assets'].append(dict(designId='npc.civic_host.'+c,group='Civic hosts',priority='P1',status='CITY_HOST_DIALOGUE_BOUND_SHARED_RIG_FINAL_ART_PENDING',source='src/shared/Config/FriendlyNpcs.luau; src/server/Services/CivicCityWorld.luau',productionBinding='Friendly bilingual nonreward host using existing civic rig/work loop. Six paths/talk ranges verified; only Crownford actual dialogue. Distinct final host art pending.',robloxAssetId=None,uatApproved=False))
d['assets'].append(dict(designId='ui.civic.local_map',group='City UI',priority='P0',status='NATIVE_CIVIC_MAP_LAYOUT_AND_CROWNFORD_INPUT_VERIFIED',source='src/client/UI/CivicMapView.luau; docs/uat01/CIVIC_CITY_TRAVEL.md',productionBinding='Six-city landmark/host/return map,144EN/TH bounds at3widths. Actual Crownford N-key map, host waypoint and dialogue; other actual city/device checks pending.',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Civic orientation checkpoint — 2026-10-06: six bilingual city hosts with existing rigs/work loops;48native paths/12landings/24prompts.36map views/144bounds pass; actual fresh Crownford N-key map, mouse host waypoint and dialogue preserve revision10/25Gold.672domain tests;311strict runtime sources;eight builds. Registry452assets/35PNG/29WAV. Quota1%used/99%remaining after external reset; agent did not reset. Continue to25%remaining, save/stop owned work then normal shutdown. City services/final terrain/art, five other actual host journeys, imports/persistence/multiplayer/device/human acceptance remain.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Civic orientation checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.','Latest observed quota: 1% used / 99% remaining.',s,count=1);p.write_text(s,encoding='utf-8')
print('CHECKPOINT',len(d['assets']))
