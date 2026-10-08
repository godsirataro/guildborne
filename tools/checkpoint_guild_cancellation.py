"""Checkpoint staged cancellation and a portal texture without enabling release gates."""
from pathlib import Path
from collections import Counter
import json
root=Path(__file__).resolve().parents[1]
path=root/'docs/uat01/intake/registry-reconciled.json'
data=json.loads(path.read_text(encoding='utf-8'))
identity='vfx.guild.portal.texture'
if not any(a['designId']==identity for a in data['assets']):
    data['assets'].append(dict(designId=identity,group='VFX',priority='P1',status='TEXTURE_CANDIDATE_IMPORT_PENDING',source='assets/uat01/generated/guildborne-vfx-guild-portal-v1.png',productionBinding='Original static transparent portal aura; margin/alpha/compression/mobile review pending; no runtime ID',robloxAssetId=None,uatApproved=False))
data['summary'].update(assets=len(data['assets']),assetStatuses=dict(Counter(a['status']for a in data['assets'])))
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Guild cancellation / portal checkpoint — 2026-10-06: 583 domain tests,33 focused guild scenarios including60 cancellation write-fault combinations and delayed-operation races;267strict runtime files. Main/offline/four campaign previews build. Fresh campaign revision217/Hall11 evidence remains valid for its tested sources; later UI/diagnostic changes separately checked. Ashen companion-credit feedback passes6EN/TH native views; underlying RuneCaster anomaly remains unresolved. Registry398assets/31PNGs including new static portal aura candidate. Quota57%used/43%remaining; continue until25%remaining, save/stop owned jobs then normal shutdown. Guild persistence/networking and other release gates remain pending.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
    p=root/'docs/uat01'/name;text=p.read_text(encoding='utf-8')
    if not text.startswith('> Guild cancellation / portal checkpoint — 2026-10-06:'):text=header+text
    if name=='WORK_CHECKLIST.md':
        text=text.replace('schema validation and private roster; 27 focused tests.','schema validation, private roster and staged durable join/cancellation coordinators; 33 focused tests (60 cancellation write-fault combinations).')
        text=text.replace('Durable coordinator/store, authenticated handlers, creation/invite/role screens','Founder/removal coordinators and real store, authenticated handlers, creation/invite/role screens')
    p.write_text(text,encoding='utf-8')
print('398 asset records; 583 domain tests; cancellation remains staged.')
