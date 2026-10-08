"""Append presentation evidence without changing gameplay acceptance claims."""
from pathlib import Path
from collections import Counter
import json
root=Path(__file__).resolve().parents[1]
p=root/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for identity in ['Rescue','Mechanism','Attack']:
 key='vfx.archiveheart.'+identity.lower();d['assets']=[a for a in d['assets']if a['designId']!=key]
 d['assets'].append(dict(designId=key,group='ArchiveHeart',priority='P0',status='NATIVE_ACTIVITY_VFX_FIXTURE_VERIFIED_UAT_PENDING',source='src/client/Controllers/ArchiveHeartEffects.luau; docs/uat01/validation-archive-heart-effects-native.json',productionBinding='Owner-only target glyph, capped16High/8LowTouch; reduced-motion and lifecycle fixture passed; release UAT pending',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=root/'docs/uat01'/name;s=p.read_text(encoding='utf-8');head,tail=s.split('\n\n',1)
 head=head.replace('289 runtime','290 runtime').replace('414 assets','417 assets')
 p.write_text(head+'\n\n'+tail,encoding='utf-8')
p=root/'docs/uat01/ARCHIVE_HEART_FOUNDATION.md';s=p.read_text(encoding='utf-8').replace('-289 runtime','- 290 runtime').replace('-Eight builds','- Eight builds').replace('-`','- `')
s+='\nThree owner-only objective glyphs are now bound through ArchiveHeartEffects: Rescue, Mechanism and Attack. `validation-archive-heart-effects-native.json` passes29 native presentation states and176 part checks, three distinct silhouettes,16High/8LowTouch caps, static reduced-motion poses, owner/distance/expiry/status validation and cleanup. Private arena geometry now carries CampaignOwner for foreign-client visibility filtering. No additional actual-input fight is claimed after this presentation-only change. Registry417 assets; domain regression remains625.\n'
p.write_text(s,encoding='utf-8')
p=root/'docs/uat01/WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8');lines=s.splitlines()
for i,line in enumerate(lines):
 if line.startswith('| Quests / NPCs |'):
  lines[i]='| Quests / NPCs | Fresh Chapter00–04 completed through ordinary input, revision217 / Elementalist70 / Hall11. Chapter05 and06 now have explicit Memory previews: twelve quests,37 objectives,86 prompts. Separate actual Archmage, ward, Warden and Keeper activity wins; native geometry, escort and synthetic receipt evidence recorded. | Full ordinary-input Chapter00–06 journey, Chapter05–06 rewards/choices/recovery; RuneCaster root cause; six-city services, final dialogue/endings, persistence, multiplayer and device UAT. |'
 elif line.startswith('| Image library |'):
  lines[i]='| Image library | 33 original generated PNGs with manifests/prompts; 417 registry assets after Archive Heart scenes, bosses and three objective VFX glyphs. Blender renders tracked separately. | Import, final margins/compression, gameplay acceptance and human art approval. |'
 elif line.startswith('| Acceptance / release |'):
  lines[i]='| Acceptance / release | Fresh Chapter00–04 desktop Memory journey to Hall11. 625 domain tests; 290 runtime sources; eight build variants. Clean Chapter00–06 preview boots at revision0 with36 campaign chapters; later VFX checked separately. | Complete latest full campaign, RuneCaster anomaly, persistent reconnect, real2/4-client tests, physical devices, imports and human UAT. |'
p.write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('ARCHIVE EFFECTS REGISTRY',len(d['assets']))
