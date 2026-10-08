"""Register local finale artifacts and honest acceptance boundaries."""
from pathlib import Path
from collections import Counter
import json
root=Path(__file__).resolve().parents[1]
p=root/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
rows=[dict(designId='world.archiveheart.chapter06.concept',group='ArchiveHeart',priority='P0',status='ARCHIVE_HEART_CONCEPT_REFERENCE',source='assets/uat01/generated/guildborne-archive-heart-v1.png',productionBinding='Atmosphere reference only; not implemented terrain',robloxAssetId=None,uatApproved=False)]
for identity in ['last_warden','keeper_of_names']:
 rows.append(dict(designId='world.archiveheart.boss.'+identity,group='ArchiveHeart',priority='P0',status='ARCHIVE_HEART_NATIVE_ENCOUNTER_INPUT_VERIFIED_UAT_PENDING',source='assets/uat01/archive-heart-bosses/'+identity+'.blend; src/server/Services/ArchiveHeartBossKit.luau; docs/uat01/validation-archive-heart-input-native.json',productionBinding='Isolated actual-input encounter win; Chapter06 preview bound; full campaign and import pending',robloxAssetId=None,uatApproved=False))
kit=json.loads((root/'assets/uat01/archive-heart-story-kit/kit.json').read_text(encoding='utf-8'))
for asset in kit['assets']:
 identity=asset['id'];rows.append(dict(designId='world.archiveheart.scene.'+identity,group='ArchiveHeart',priority='P0',status='ARCHIVE_HEART_PREVIEW_BOUND_ACCEPTANCE_PENDING',source='assets/uat01/archive-heart-story-kit/'+identity+'.glb; src/server/Services/ArchiveHeartStoryKit.luau; docs/uat01/validation-archive-heart-story-native.json',productionBinding='Optional Memory preview; synthetic world/geometry/escort evidence only; actual journey pending',robloxAssetId=None,uatApproved=False))
ids={a['designId']for a in rows};d['assets']=[a for a in d['assets']if a['designId']not in ids]+rows
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Archive Heart foundation — 2026-10-06: Chapter06 now has six quests / eighteen objectives, ninety progression routes and an explicit Chapter00–06 Memory preview. Two bosses have isolated ordinary-input wins; six blockout scenes have 52 paths / 104 clearance checks; 42 world prompts have thirteen synthetic non-combat receipts. Full fresh-player evidence still ends Chapter04, revision217; full Chapter05–06 acceptance remains pending. 625 domain tests / 289 runtime sources / eight builds. Registry: 414 assets / 33 generated PNGs; no imported IDs or human approval. See ARCHIVE_HEART_FOUNDATION.md. Quota: 60% used / 40% remaining; stop at 25% remaining, save/stop owned jobs, then normal shutdown.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=root/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 if s.startswith('> Archive Heart foundation'):s=s.split('\n\n',1)[1]
 p.write_text(header+s,encoding='utf-8')
p=root/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest observed quota: 59% used / 41% remaining.','Latest observed quota: 60% used / 40% remaining.');p.write_text(s,encoding='utf-8')
print('ARCHIVE HEART REGISTRY',len(d['assets']),'assets')
