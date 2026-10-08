"""Record verified bow art independently of production combat acceptance."""
from pathlib import Path
from collections import Counter
import json,re
R=Path(__file__).resolve().parents[1]
for name in ['roundtrip-report.json','fbx-roundtrip-report.json']:
 d=json.loads((R/'assets/uat01/bow-contact-v1'/name).read_text());assert d['status']=='PASS' and d['sampleCount']==40
n=json.loads((R/'docs/uat01/validation-bow-contact-native.json').read_text());assert n['status']=='PASS' and n['poseSamples']==36
p=R/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
identity='animation.yew_longbow.contact_reload'
d['assets']=[a for a in d['assets'] if a['designId']!=identity]
d['assets'].append(dict(designId=identity,group='Weapon animation',priority='P1',status='LOCAL_CONTACT_RELOAD_VERIFIED_GAMEPLAY_RETARGET_PENDING',source='assets/uat01/bow-contact-v1/; docs/uat01/BOW_CONTACT_STUDY.md',productionBinding='Blender/GLB/FBX contact and quiver reload study. 40 poses per roundtrip; 36 native fixture poses, 23 bones, 3218 triangles. Existing bow SFX synchronized as review mix. Production R6/R15 binding, combat timing, IDs and human approval pending.',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header=f'> Bow contact checkpoint — 2026-10-06: draw/release/quiver withdrawal/nocking study verified in GLB, FBX and native Roblox fixture; see BOW_CONTACT_STUDY.md. Gameplay retarget and final likeness pending. Registry {len(d["assets"])} slots. Audio: 37 original WAVs plus one synchronized reuse mix, not 38 unique sounds. Latest quota 14% used / 86% remaining; stop at 25% remaining and perform the requested normal shutdown after checkpoint.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=R/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Bow contact checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=R/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.', 'Latest observed quota: 14% used / 86% remaining.',s);p.write_text(s,encoding='utf-8')
print('BOW_CHECKPOINT',len(d['assets']))
