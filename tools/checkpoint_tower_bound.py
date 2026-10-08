"""Record explicit Tower preview binding and honest acceptance limits."""
from pathlib import Path
from collections import Counter
import json
r=Path(__file__).resolve().parents[1]
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['designId'].startswith('world.tower.chapter04.') and not a['designId'].endswith('.concept'):
  a['status']='NATIVE_STORY_BOUND_EXPLICIT_PREVIEW_UAT_PENDING'
  a['productionBinding']='Chapter04 explicit memory-only preview;6scenes/47shared-entry paths/44story prompts;15synthetic receipts; full real campaign journey pending'
 elif a['designId'].startswith('npc.tower.'):
  a['status']='NATIVE_STORY_CAST_BOUND_UAT_PENDING'
  a['productionBinding']='4friendly roles bound to Chapter04 court; memory echo22stud physical route with synthetic owner passes; actual full story, import and human UAT pending'
 elif a['designId'].startswith('vfx.tower.'):
  a['productionBinding']='Bootstrapped read-only owned lesson cues;14High/8Low-touch cap;18native fixture stages/114part checks; actual full story/device/human UAT pending'
identity='world.tower.chapter04.court'
d['assets']=[a for a in d['assets']if a['designId']!=identity]+[dict(designId=identity,group='Tower story',priority='P1',status='NATIVE_STORY_BOUND_EXPLICIT_PREVIEW_UAT_PENDING',source='src/server/Services/TowerCourtArt.luau; src/server/Config/TowerCourtLayout.luau',productionBinding='330x330stud private assembly;6rooms/47entry paths/94body-floor checks,80stud vertical separation/8slots; actual full story and multiplayer pending',robloxAssetId=None,uatApproved=False)]
d['summary'].update(assets=len(d['assets']),screens=len(d['screens']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Tower binding checkpoint — 2026-10-04:543domain tests;257strict runtime files;6builds pass. Explicit memory-only Chapter00-04 preview now binds6rooms/44prompts/20objectives;15synthetic receipts,47court paths,22stud physical echo,108UI/936bounds. All5root classes passed standalone real-input records guardian trials; support lessons also passed separately. Fresh real full journey is running atrevision40/Mage14/Hall1/2campaign quests withBram andSage; Chapter04 actual completion remains pending. Registry389assets/73screens/33workareas,28generatedPNG. Quota47%used/53%remaining;stop50%. See TOWER_FOUNDATION.md.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 if not s.startswith('> Tower binding checkpoint'):s=header+s
 s=s.replace('Runtime validation is 539 tests','Runtime validation is 543 tests').replace('18objective metadata','20objective metadata')
 p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest verified usage:46%used/54%remaining','Latest verified usage:47%used/53%remaining');p.write_text(s,encoding='utf-8')
print('TOWER_BOUND_CHECKPOINT',len(d['assets']),'assets')
