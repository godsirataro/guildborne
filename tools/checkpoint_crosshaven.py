"""Register staged Crosshaven sources without implying gameplay acceptance."""
from pathlib import Path
from collections import Counter
import json
root=Path(__file__).resolve().parents[1]
p=root/'docs/uat01/intake/registry-reconciled.json'
d=json.loads(p.read_text(encoding='utf-8'))
kit=json.loads((root/'assets/uat01/crosshaven-story-kit/kit.json').read_text(encoding='utf-8'))
rows=[dict(designId='world.crosshaven.chapter05.concept',group='Crosshaven',priority='P0',status='CROSSHAVEN_CONCEPT_REFERENCE',source='assets/uat01/generated/guildborne-crosshaven-chapter05-v1.png',productionBinding='Atmosphere concept only; not implemented terrain',robloxAssetId=None,uatApproved=False)]
for asset in kit['assets']:
    identity=asset['id']
    rows.append(dict(designId='world.crosshaven.scene.'+identity,group='Crosshaven',priority='P0',status='CROSSHAVEN_PREVIEW_BOUND_ACCEPTANCE_PENDING',source='assets/uat01/crosshaven-story-kit/'+identity+'.glb; src/server/Services/CrosshavenStoryKit.luau; docs/uat01/validation-crosshaven-story-native.json',productionBinding='Optional Memory preview bound; native synthetic world/escort fixtures pass; ordinary-input full journey pending',robloxAssetId=None,uatApproved=False))
ids={a['designId']for a in rows}
d['assets']=[a for a in d['assets']if a['designId']not in ids]+rows
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Crosshaven foundation — 2026-10-06: six staged quests / nineteen objectives, forty progression routes, fourteen temporary Class3 lesson paths. Six scene blockouts: 241 parts / 52 markers, 52 native paths / 104 body-floor checks, twelve verified exports. Future campaign Hall bypass corrected with EN/TH disabled-click evidence. Chapter05 now binds through 44 prompts in a separate Memory preview; 15 synthetic receipts and two physical NPC routes pass. Native Archmage mastery and camp ward wins used ordinary input with one completion each. Twelve EN/TH navigation states pass. 612 domain tests / 279 runtime sources; seven builds pass. Registry: 405 assets / 32 PNGs; no imported IDs or human approval. See CROSSHAVEN_FOUNDATION.md. Quota: 59% used / 41% remaining; stop at 25% remaining, save/stop owned jobs, then normal shutdown.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
    p=root/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
    if s.startswith('> Crosshaven foundation'):s=s.split('\n\n',1)[1]
    p.write_text(header+s,encoding='utf-8')
p=root/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest observed quota: 58% used / 42% remaining.','Latest observed quota: 59% used / 41% remaining.');p.write_text(s,encoding='utf-8')
print('Crosshaven staged registry:',len(d['assets']),'assets')
