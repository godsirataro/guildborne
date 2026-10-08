"""Idempotent optional ending-motion checkpoint."""
from pathlib import Path
from collections import Counter
import json,re
r=Path(__file__).resolve().parents[1]
header='> Ending playback checkpoint — 2026-10-06: three optional8second viewport replays, stop/reduced-motion/hidden/destroy cleanup;943native lifecycle checks,729camera samples/5832bounds,144completion views/1032text bounds. Editable Blender library +3GLBs reimported,46animated parts/zero endpoint error.656domain tests;302strict runtime sources;eight builds. Registry431assets/34generatedPNG. Quota67%used/33%remaining; continue to25%remaining then checkpoint, stop owned work and normal shutdown. Paid offers remain disabled; no live imports or purchases.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Ending playback checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=r/'docs/uat01/WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8').replace('653 domain tests; 300 runtime sources','656 domain tests; 302 runtime sources').replace('428 registry assets','431 registry assets').replace('144 completion UI views/996 bounds','144 completion UI views/1032 bounds')
s=s.replace('Sentinel16-bone rig/9clips plus12regional rigs/48clips round-trip verified','Sentinel16-bone rig/9clips plus12regional rigs/48clips round-trip verified;3optional ending replays,editable Blender/3GLBs,943lifecycle checks/5832camera bounds')
p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/ARCHIVE_ENDINGS.md';s=p.read_text(encoding='utf-8');marker='\n## Optional eight-second replay\n';s=s.split(marker)[0]+marker+'''
Current completion UI keeps each tableau static by default and offers Replay/Stop. The archive ring/ledger, refuge canopy and memorial plants move gently within the viewport; the gameplay camera and character are untouched. Reduced motion keeps the scene static. Hiding/destroying the view or stopping restores every original transform and disconnects its render callback. This adds environmental motion, not a fully acted character cinematic.

Native fixtures passed943lifecycle checks,729sampled camera poses/5832bounding corners, and144EN/TH completion views/1032text bounds. Three deterministic domain checks bring the complete suite to656. Strict analysis/eight builds pass at302runtime sources. See validation-ending-playback-native.json. The full fresh campaign predates this optional presentation feature.

Editable assets: assets/uat01/archive-ending-motion/Guildborne_Archive_Ending_Motion.blend and three Replay.glb files,8seconds/30fps/241samples. All223parts survived reimport;46animated parts moved and returned with zero endpoint error. Each GLB has one coordinated scene animation. These object-motion storyboards are reference/export assets, not uploaded Roblox Animation IDs. The render was visually inspected; final art/acting/imports/device/human review remain pending.
''';p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'));ids={'animation.archiveheart.ending.'+x for x in ['preserve','transform','dismantle']};d['assets']=[a for a in d['assets']if a['designId']not in ids]
for identity in ['preserve','transform','dismantle']:
 d['assets'].append(dict(designId='animation.archiveheart.ending.'+identity,group='ArchiveHeart',priority='P0',status='OPTIONAL_ENDING_MOTION_NATIVE_VERIFIED_IMPORT_UAT_PENDING',source='assets/uat01/archive-ending-motion/'+identity+'_Replay.glb; assets/uat01/archive-ending-motion/Guildborne_Archive_Ending_Motion.blend; docs/uat01/validation-ending-playback-native.json',productionBinding='Eight-second opt-in viewport replay; lifecycle/reduced motion/camera checks passed; environment only, no acted cinematic or gameplay reward',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('CHECKPOINT',len(d['assets']))
