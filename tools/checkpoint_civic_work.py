"""Register motion references and original community concept."""
from pathlib import Path
from collections import Counter
import json,re
r=Path(__file__).resolve().parents[1]
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
clips=json.loads((r/'assets/uat01/civic-work-motion/manifest.json').read_text(encoding='utf-8'))['clips']
ids={'animation.civic_work.'+c['id']for c in clips}|{'concept.civic_community'}
d['assets']=[a for a in d['assets']if a['designId']not in ids]
for c in clips:
 d['assets'].append(dict(designId='animation.civic_work.'+c['id'],group='Civic work animation',priority='P1',status='NATIVE_WORK_LOOP_BOUND_GLB_REFERENCE_VERIFIED_POLISH_PENDING',source='assets/uat01/civic-work-motion/'+c['file']+'; docs/uat01/CIVIC_WORK_MOTION.md',productionBinding='Eight-second native joint loop, reduced-motion/distance/destroy restoration; editable Blender object-motion reference. Final performance and platform import pending.',robloxAssetId=None,uatApproved=False))
d['assets'].append(dict(designId='concept.civic_community',group='Concept art',priority='P1',status='GENERATED_CONCEPT_REVIEW_PENDING',source='assets/uat01/civic-community/concept-v1.png; assets/uat01/civic-community/concept-prompt.txt',productionBinding='Original six-envoy community illustration, art direction only; no uploaded runtime binding',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Civic work checkpoint — 2026-10-06: six eight-second native work gestures;306local restoration/leg checks;6GLB reimports/226meshes/zero endpoint error and editable Blender. Original community concept saved.669domain tests;306strict runtime sources;eight builds. Registry445assets/35generatedPNG/29originalWAV. Quota69%used/31%remaining; continue to25%remaining, save/stop owned jobs then normal shutdown. Final performance/imports, full cities, persistence/multiplayer/devices and human acceptance remain.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Civic work checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.','Latest observed quota: 69% used / 31% remaining.',s,count=1);p.write_text(s,encoding='utf-8')
print('CHECKPOINT',len(d['assets']))
