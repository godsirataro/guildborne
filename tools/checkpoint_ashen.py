"""Reconcile local Ashen evidence without changing runtime gates or approvals."""
from pathlib import Path
from collections import Counter
import json
root=Path(__file__).resolve().parents[1]
p=root/'docs/uat01/intake/registry-reconciled.json'
d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
    identity=a['designId']
    if identity.startswith('world.ashen.chapter03.'):
        if not identity.endswith('.concept'):
            a['status']='LOCAL_STORY_JOURNEY_VERIFIED_IMPORT_UAT_PENDING'
        a['productionBinding']='Explicit memory-only Chapter00-03 actual journey revision151/Hall7/Mage50;6scenes/178parts/33native paths/12exports; world observations, puzzles, moving escorts and party victories bound; import/device/multiplayer/human UAT pending'
    elif identity.startswith('npc.ashen.'):
        a['status']='LOCAL_STORY_RIG_JOURNEY_VERIFIED_IMPORT_UAT_PENDING'
        a['productionBinding']='4friendly roles/140parts/60motors/16clips/24roundtrips; actual gatekeeper and sheltered bridge escort, Elf survivor and Orc witness interactions; import/device/multiplayer/human UAT pending'
    elif 'mine.' in identity and a.get('status')=='NATIVE_ACTIVITY_VFX_FIXTURE_VERIFIED_UAT_PENDING':
        a['productionBinding']='Explicit Ironveil/Ashen activity attributes;18native stages/106part checks,14High/8Low-touch cap, reduced-motion/cleanup; latest actual Chapter00-03 includes moving escorts and timed shutters; physical device/human review pending'
for s in d['screens']:
    if s['designId']=='screen.campaign.chapter01':
        s['requiredStates']='90Chapter01 and108eachChapter02/03 EN-THviews; actual Chapter00-03 journey revision151; post-run guidance108views/882bounds/36callbacks; human/device acceptance pending'
d['summary'].update(assets=len(d['assets']),screens=len(d['screens']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
checkpoint='> Ashen actual checkpoint — 2026-10-04: fresh Chapter00-03 journey completed at revision151: Mage50/2515XP,Hall7,236Gold,Bram50/Sage47;24claimed story quests,scene cleanup and surface return verified. Rescue/workers/courage/compass/workers/Spellblade/sheltered/trust.530domain tests;244runtime files;strict/compile/all5builds pass. Updated guidance108UI/882bounds/36callbacks passes. Registry375assets/73screens/33workareas,27generatedPNG. Only explicit memory-only preview; import,persistence,multiplayer,devices and human UAT pending. Quota45%used/55%remaining;stop50%. See ASHEN_ACCEPTANCE.md.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
    p=root/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
    if not s.startswith('> Ashen actual checkpoint'):
        s=checkpoint+'Earlier checkpoints below are historical; use the latest checkpoint and ASHEN_ACCEPTANCE.md for current state.\n\n'+s
    s=s.replace(';237 runtime scripts',';244 runtime scripts').replace('| Image library |26 local PNG','| Image library |27 local PNG').replace('| Logo / key art | 26 original','| Logo / key art | 27 original')
    s=s.replace('Chapter02 six-quest actual run passed through Hall4/Lv35, moving rescue, safety shutters, puzzles, party guardian and Elementalist borrowed trial; final prompt/Hall guidance fixtures passed. Remaining draft cards, six-city content, enemy-wave protection, balance/persistence/device/human UAT','Chapter00-03 actual run reachedHall7/Lv50/revision151; Ironveil Elementalist and Spellblade borrowed trials, Ashen puzzles, two escorts, Orc witness, safety wards and party bosses verified. Remaining draft cards, six-city content, enemy-wave protection, balance/persistence/device/human UAT')
    s=s.replace('Polished supplies/Mage/Knight/Priest run and alternate town allocation completed through Chapter02/revision108;','Polished supplies/town route through Chapter02/revision108 and rescue/workers route through Chapter03/revision151 completed;')
    p.write_text(s,encoding='utf-8')
p=root/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest verified usage:44%used/56%remaining','Latest verified usage:45%used/55%remaining');p.write_text(s,encoding='utf-8')
p=root/'docs/uat01/ASHEN_FOUNDATION.md';s=p.read_text(encoding='utf-8')
s=s.replace('Staged only. ChapterThree is not selected by Bootstrap or any playable preview.','Enabled only in the explicit memory-only Ashen preview. A fresh actual Chapter00-03 journey completed at revision151/Hall7/level50; see ASHEN_ACCEPTANCE.md.')
s=s.replace("the new arc's world observations, escort routes, memory/bell puzzles, combat protection and full actual journey are pending.","37prompt/15private-receipt world fixtures,33assembled paths and3physical escort routes pass; one full actual journey includes moving escorts, puzzles, timed safety wards and party combat victories. Enemy-wave NPC defense and further release acceptance remain pending.")
p.write_text(s,encoding='utf-8')
print('ASHEN_CHECKPOINT',len(d['assets']),'assets',len(d['screens']),'screens')
