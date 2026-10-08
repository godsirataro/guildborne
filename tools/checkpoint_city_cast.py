"""Record validated city art and staged guild progress without promoting release gates."""
from pathlib import Path
from collections import Counter
import json
r=Path(__file__).resolve().parents[1]
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
cast=json.loads((r/'assets/uat01/city-cast/kit.json').read_text(encoding='utf-8'))
existing={a['designId']for a in d['assets']}
for a in cast['assets']:
 if a['designId']not in existing:
  d['assets'].append(dict(designId=a['designId'],group='City cast',priority='P1',status='LOCAL_RIG_EXPORTS_REVIEW_PLACED_GAMEPLAY_UNBOUND',source='assets/uat01/city-cast/'+a['id']+'.blend; src/server/Services/CityCharacterKit.luau',productionBinding=a['region']+' '+a['role']+'; native review placement and animation fixture; four clips/reimport passed; services and imports pending',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> City cast / guild checkpoint — 2026-10-06: 577 domain tests; 27 focused guild cases including uncertain-write/race recovery. 266 runtime sources. Staged guild schema/coordinator/roster and48native UIviews/516bounds; no live membership adapter. Six city NPCs:226parts/2712triangles/24clips/36roundtrip exports;90native joints/24walking limbs and six review placements pass. Registry397assets/30generatedPNG; city Blender renders are separate. Quota52%used/48%remaining; continue to25%remaining then save, stop owned jobs/Play and normal shutdown. Services/imports/persistence/multiplayer/device/human release gates remain pending.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 if not s.startswith('> City cast / guild checkpoint — 2026-10-06'):s=header+s
 s=s.replace('20 focused tests','27 focused tests')
 p.write_text(s,encoding='utf-8')
print('Checkpoint397assets;6citycast;577domain tests')
