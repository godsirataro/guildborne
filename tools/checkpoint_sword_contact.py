from pathlib import Path
from collections import Counter
import json,re
R=Path(__file__).resolve().parents[1]
for name in ['roundtrip-report.json','fbx-roundtrip-report.json']:
 d=json.loads((R/'assets/uat01/sword-contact-v1'/name).read_text());assert d['status']=='PASS'and d['samples']==181
n=json.loads((R/'docs/uat01/validation-sword-contact-native.json').read_text());assert n['status']=='PASS'and n['samples']==181
p=R/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'));identity='animation.watchblade.contact_cut'
d['assets']=[a for a in d['assets']if a['designId']!=identity]
d['assets'].append(dict(designId=identity,group='Weapon animation',priority='P1',status='LOCAL_CONTACT_CUT_VERIFIED_GAMEPLAY_RETARGET_PENDING',source='assets/uat01/sword-contact-v1/; docs/uat01/SWORD_CONTACT_STUDY.md',productionBinding='16-bone watchblade guard/windup/cut/recovery study; 181 frames per GLB/FBX/native check. Ordinary pose-selection UI verified. Original sword sound reused in review video. Production combat binding, trail effects, IDs and human acceptance pending.',robloxAssetId=None,uatApproved=False))
trail=json.loads((R/'docs/uat01/validation-sword-contact-trail.json').read_text());assert trail['status']=='PASS'and trail['ordinaryMouseDisableFullCycle']
identity='vfx.watchblade.contact_trail';d['assets']=[a for a in d['assets']if a['designId']!=identity]
d['assets'].append(dict(designId=identity,group='Weapon VFX',priority='P1',status='LOCAL_BLADE_TRAIL_VERIFIED_GAMEPLAY_BINDING_PENDING',source='tools/sword_contact_effect_review.luau; docs/uat01/validation-sword-contact-trail.json',productionBinding='Native untextured trail follows actual skinned blade endpoints only during cut window. 100 live observations, ordinary toggle and pause suppression passed. Only standalone art fixture is bound; production skill selection and device acceptance pending.',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header=f'> Sword contact checkpoint — 2026-10-07: watchblade and bow now have separate local contact studies with native Roblox pose checks; gameplay retargeting remains pending. Watchblade: 181 poses each in GLB, FBX and native fixture, 16 bones / 2344 triangles. Six cities retain 24 native buildings and six detailed NPC studies have a separate city/cast viewer. Registry {len(d["assets"])} slots / 73 screens / 33 work areas. Audio: 37 original WAV files plus two reuse mixes (39 WAV files, not 39 unique sounds). Latest quota 18% used / 82% remaining; active stop/shutdown boundary remains 25% remaining.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=R/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Sword contact checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
print('SWORD_CHECKPOINT',len(d['assets']))
