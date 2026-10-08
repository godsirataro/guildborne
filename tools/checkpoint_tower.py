"""Reconcile staged Tower assets and tests; do not activate story or approvals."""
from pathlib import Path
from collections import Counter
import hashlib,json
from PIL import Image
root=Path(__file__).resolve().parents[1]
p=root/'assets/uat01/manifest.json';d=json.loads(p.read_text(encoding='utf-8'));file='assets/uat01/generated/guildborne-tower-chapter04-v1.png';im=Image.open(root/file)
entry=dict(file=file,width=im.width,height=im.height,mode=im.mode,sha256=hashlib.sha256((root/file).read_bytes()).hexdigest(),generator='built-in image_gen',date='2026-10-04',robloxAssetId=None,uploaded=False,status='concept_reference',alphaRange=None,promptSource='assets/uat01/TOWER_CHAPTER04_PROMPT.md')
d['images']=[v for v in d['images']if v['file']!=file]+[entry];d['generatedAssetCount']=len(d['images']);p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=root/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'));new=[]
for identity in ['concept','charter_gate','guardian_school','hidden_archive','memory_chamber','twin_doors','first_ledger']:
 new.append(dict(designId='world.tower.chapter04.'+identity,group='Tower story',priority='P1',status='CONCEPT_REFERENCE'if identity=='concept'else'NATIVE_GEOMETRY_EXPORTS_VERIFIED_QUEST_BINDING_PENDING',source=file if identity=='concept'else'assets/uat01/tower-story-kit/'+identity+'.glb; src/server/Services/TowerStoryKit.luau',productionBinding='Staged Chapter04;6scenes/332parts/47markers/94clearances/47native paths/12roundtrip exports; no campaign activation or actual Chapter04 journey',robloxAssetId=None,uatApproved=False))
for identity in ['charter_warden','archivist','council_clerk','bookbinder']:
 new.append(dict(designId='npc.tower.'+identity,group='Tower cast',priority='P1',status='NATIVE_RIG_EXPORTS_VERIFIED_STORY_BINDING_PENDING',source='assets/uat01/tower-cast/'+identity+'.blend; src/server/Services/TowerCharacterKit.luau',productionBinding='4friendly roles/146parts/60motors/16clips/24roundtrips; native walking/restoration verified; Chapter04 world binding/import/human UAT pending',robloxAssetId=None,uatApproved=False))
for identity in ['training_shield','training_heal']:
 new.append(dict(designId='vfx.tower.'+identity,group='Tower VFX',priority='P1',status='NATIVE_ACTIVITY_VFX_FIXTURE_VERIFIED_UAT_PENDING',source='src/client/Controllers/TowerLessonEffects.luau; docs/uat01/validation-tower-effects-native.json',productionBinding='Staged14High/8Low-touch shape-distinct shield/heal cues;18native stages/114part checks,owner/distance/stale/reduced-motion/cleanup;3frozen panels visually reviewed; full motion/device/story binding pending',robloxAssetId=None,uatApproved=False))
ids={a['designId']for a in new};d['assets']=[a for a in d['assets']if a['designId']not in ids]+new
d['summary'].update(assets=len(d['assets']),screens=len(d['screens']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Tower foundation — 2026-10-04:539domain tests; staged6quest balance reachesHall11/Lv70 across20class/choice combinations.6scenes/332parts/47paths/12exports;4cast/146parts/16clips/24exports;108UI/900bounds. Guard/Mend/Combined standalone real-input trials passed without profile grants; staged bounded VFX18native stages. Chapter04 world/campaign remains unbound. Registry388assets/73screens/33workareas,28generatedPNG. Lastquota46%used/54%remaining;stop50%. See TOWER_FOUNDATION.md.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=root/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 if not s.startswith('> Tower foundation'):s=header+s
 s=s.replace('Runtime validation is 530 tests','Runtime validation is 539 tests').replace('| Image library |27 local PNG','| Image library |28 local PNG').replace('| Logo / key art | 27 original','| Logo / key art | 28 original')
 if name=='WORK_CHECKLIST.md':s=s.replace('| Tower | Existing10 floors and exact-stat bestiary previews | New objective variety and full fresh-profile/multiplayer completion |','| Tower | Existing10 combat floors; stagedChapter04 six-quest domain/Hall8-11 economy,6scenes/4cast,18objective metadata; three standalone real-input support lessons, bounded shield/heal VFX and108UI states | Chapter04 world/receipt/checkpoint/story binding, existing Tower full fresh-profile journey, multiplayer/device/human acceptance |')
 p.write_text(s,encoding='utf-8')
p=root/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest verified usage:45%used/55%remaining','Latest verified usage:46%used/54%remaining');p.write_text(s,encoding='utf-8')
print('TOWER_CHECKPOINT',len(d['assets']),'assets',len(d['screens']),'screens')
