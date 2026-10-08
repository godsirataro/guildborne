"""Persist measured membership progress and the new original texture candidate."""
from pathlib import Path
from collections import Counter
import json
r=Path(__file__).resolve().parents[1]
p=r/'docs/uat01/intake/registry-reconciled.json'
d=json.loads(p.read_text(encoding='utf-8'))
identity='vfx.healing.ward.texture'
if not any(a['designId']==identity for a in d['assets']):
 d['assets'].append(dict(designId=identity,group='VFX',priority='P1',status='TEXTURE_CANDIDATE_IMPORT_PENDING',source='assets/uat01/generated/guildborne-vfx-healing-ward-v1.png',productionBinding='Original transparent static ward sprite; margin/compression/terrain review pending; no runtime ID',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status'] for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Membership checkpoint — 2026-10-06: 567 domain tests; 17 focused guild tests; 262 strict runtime sources; compile/main/offline/four campaign preview builds pass. Player Guild membership, recovery planner and private roster projection are staged: persistence, networking and UI remain unbound. New healing ward transparent texture candidate; registry391assets/30PNGs. Quota last51%used/49%remaining. Continue until25%remaining, save and stop owned jobs/Play, then normal computer shutdown per latest user instruction. No live publishing or commerce activation.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 if not s.startswith('> Membership checkpoint — 2026-10-06'):p.write_text(header+s,encoding='utf-8')
print('Checkpoint: staged membership, 391 assets, 30 PNGs')
