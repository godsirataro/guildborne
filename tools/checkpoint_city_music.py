"""Idempotent original-music checkpoint."""
from pathlib import Path
from collections import Counter
import json,re
r=Path(__file__).resolve().parents[1]
header='> City music checkpoint — 2026-10-06: seven original24second stereo loops/168seconds plus editable scores; technical signal checks passed, listening/import pending. Two-voice music transitions and EN/TH volume control;32native text checks and actual mouse adjustment verified, zero unbound Sounds.662domain tests;305strict runtime sources;eight builds. Registry438assets/34generatedPNG/29originalWAV. Quota68%used/32%remaining; continue to25%remaining, save/stop owned work, then normal shutdown. All live audio/import/purchase IDs remain blank/zero.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> City music checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=r/'docs/uat01/WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8').replace('656 domain tests; 302 runtime sources','662 domain tests; 305 runtime sources').replace('431 registry assets','438 registry assets')
s=re.sub(r'^\| Audio \|[^\n]*$','| Audio | 29 original WAVs (10UI+12combat+7city/guild loops), editable scores; signal checks,16SFX/2music voice bounds; actual Music volume input and32native EN/TH text checks | Listening/composition/mix review, Roblox import/permissions, configured streaming failures, audible transitions and device acceptance |',s,flags=re.M);p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.', 'Latest observed quota: 68% used / 32% remaining.',s,count=1);p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'));tracks=json.loads((r/'assets/uat01/city-music/manifest.json').read_text(encoding='utf-8'));ids={x['id']for x in tracks};d['assets']=[a for a in d['assets']if a['designId']not in ids]
for t in tracks:
 d['assets'].append(dict(designId=t['id'],group='Music',priority='P0',status='ORIGINAL_MUSIC_SKETCH_SIGNAL_VERIFIED_LISTENING_IMPORT_PENDING',source=t['file']+'; assets/uat01/city-music/scores.json; docs/uat01/CITY_MUSIC.md',productionBinding='24second original loop; two-voice route adapter staged with all IDs blank. Listening, platform import and audible device acceptance pending',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8');print('CHECKPOINT',len(d['assets']))
