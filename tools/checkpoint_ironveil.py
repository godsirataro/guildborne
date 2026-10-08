"""Idempotent evidence-only local Ironveil checkpoint; no release flags or IDs."""
from pathlib import Path
from collections import Counter
import json
root=Path(__file__).resolve().parents[1]
p=root/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
new=[]
for identity in ['concept','scale_yard','signal_shaft','shoring_gallery','ink_office','warden_mechanism','training_camp']:
    concept=identity=='concept'
    new.append(dict(designId='world.ironveil.chapter02.'+identity,group='Ironveil story',priority='P0',status='CONCEPT_REFERENCE' if concept else 'LOCAL_STORY_JOURNEY_VERIFIED_IMPORT_UAT_PENDING',source='assets/uat01/generated/guildborne-ironveil-chapter02-v1.png' if concept else 'assets/uat01/ironveil-story-kit/'+identity+'.glb; src/server/Services/IronveilStoryKit.luau; docs/uat01/validation-ironveil-story-native.json',productionBinding='Explicit memory-only Chapter02 six-quest actual journey to Hall4/Lv35/revision108; six scene prototypes,29 approach markers/paths,58 clearances,12 round-trip exports; final prompt polish fixtures passed; import/device/multiplayer/human UAT pending',robloxAssetId=None,uatApproved=False))
for identity in ['miner','engineer','carrier']:
    new.append(dict(designId='npc.ironveil.'+identity,group='Ironveil cast',priority='P0',status='LOCAL_STORY_RIG_JOURNEY_VERIFIED_IMPORT_UAT_PENDING',source='assets/uat01/ironveil-cast/'+identity+'.blend; src/server/Services/IronveilCharacterKit.luau; docs/uat01/validation-ironveil-cast-native.json',productionBinding='Three friendly original work roles: dwarf miner/engineer and Orc carrier;114 visible parts,45 native motors,12 walking limbs;12 local clips/18 round-trip exports; actual Orc interview and moving miner rescue bound in explicit memory preview; imported asset/device/multiplayer/human acceptance pending',robloxAssetId=None,uatApproved=False))
ids={a['designId'] for a in new};d['assets']=[a for a in d['assets'] if a['designId'] not in ids]+new
for screen in d['screens']:
    if screen['designId']=='screen.campaign.chapter01':
        screen['requiredStates']='90 Chapter01 plus108 Chapter02 EN/TH views,882 Chapter02 bounds/36 captured callbacks; actual fresh Chapter00-02 run completed; final Hall guidance fixtures verified; human/device acceptance pending'
d['summary'].update(assets=len(d['assets']),screens=len(d['screens']),screenScopes=dict(Counter(s['scope'] for s in d['screens'])),assetStatuses=dict(Counter(a['status'] for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=root/'docs/uat01/WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8')
s=s.replace('Runtime validation is 510 tests','Runtime validation is 526 tests').replace(';223 runtime scripts',';237 runtime scripts').replace('54Novice/84Campaign','54Novice/90Campaign')
s=s.replace('Chapter02 and remaining240 draft cards need concrete events/rewards','Chapter02 staged6quest domain/Hall3-4 economy plus6scenes/3cast/12clips; moving-NPC isolated17checks pass; Chapter02 world/receipt/trial bindings and remaining draft cards need implementation')
s=s.replace('| Image library |25 local PNG','| Image library |26 local PNG').replace('| Logo / key art | 25 original','| Logo / key art | 26 original')
p.write_text(s,encoding='utf-8')
p=root/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest verified usage:40%used/60%remaining','Latest verified usage:43%used/57%remaining');p.write_text(s,encoding='utf-8')
print('IRONVEIL_REGISTRY',len(d['assets']),'assets',len(d['screens']),'screens')
