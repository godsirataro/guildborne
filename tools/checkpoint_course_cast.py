"""Record local cast and actual course evidence without release approval."""
from pathlib import Path
from collections import Counter
import json,hashlib
root=Path(__file__).resolve().parents[1]
p=root/'assets/uat01/manifest.json';d=json.loads(p.read_text());file='assets/uat01/generated/guildborne-crown-road-cast-v1.png'
d['images']=[a for a in d['images']if a['file']!=file]+[dict(file=file,width=1536,height=1024,mode='RGB',sha256=hashlib.sha256((root/file).read_bytes()).hexdigest(),generator='built-in image_gen',date='2026-10-04',robloxAssetId=None,uploaded=False,status='course_cast_concept_reference',alphaRange=None,promptSource='assets/uat01/CROWN_ROAD_CAST_PROMPT.md')]
d['generatedAssetCount']=len(d['images']);p.write_text(json.dumps(d,indent=2)+'\n')
p=root/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
new=[]
for identity in ['concept','courier','dwarf_traveler','elf_traveler','crossroads_keeper']:
 new.append(dict(designId='npc.novice.'+identity,group='Novice cast',priority='P0',status='COURSE_CAST_CONCEPT_REFERENCE'if identity=='concept'else 'NATIVE_COURSE_CAST_EXPORTS_VERIFIED_IMPORT_PENDING',source=file if identity=='concept'else 'assets/uat01/course-characters/'+identity+'.blend; src/server/Services/NoviceCharacterKit.luau; docs/uat01/validation-course-cast-native.json',productionBinding='Optional memory-only course; friendly streaming lifecycle and Keeper input/motion fixtures verified; imported assets and human/device UAT pending',robloxAssetId=None,uatApproved=False))
ids={a['designId']for a in new};d['assets']=[a for a in d['assets']if a['designId']not in ids]+new
d['summary'].update(assets=len(d['assets']),screens=len(d['screens']),screenScopes=dict(Counter(a['scope']for a in d['screens'])),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=root/'docs/uat01/WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8')
replacements={'Runtime validation is 495 tests':'Runtime validation is 499 tests',';209 runtime scripts':';215 runtime scripts','guided-order journey, persistent reconnect and v2 migration acceptance remain':'actual Chapter00 rescue/Mage/Knight journey reachedrevision28; persistent reconnect and v2 migration acceptance remain','actual Novice route and full57-surface state audit':'actual six-chapter Novice route passed once; full57-surface state audit','full saved-profile course, retry entry, class-role balancing':'one actual memory-profile course passed; retry entry, class-role balancing','| Image library |23 local PNG':'| Image library |25 local PNG','| Logo / key art | 24 original':'| Logo / key art | 25 original','full Chapter00 world binding, six-city geometry/story':'optional full Chapter00 world binding and one actual journey passed; six-city geometry/story','implement Chapters00–02 first':'Chapter00 bound offline with four cast prototypes/16clips/24exports; implement Chapters01–02 next','| v2 onboarding | Design reconciled; no circular Hall/recruit requirement in proposed rules | Playable Novice1–10,soloClass1trial,freeHall1,guaranteedHero10 |':'| v2 onboarding | Optional memory-only six-chapter course; actual Novice1–10, Mage solo trial/class weapon, freeHall1/KnightLv10, revision28/Gold0; returns Guild and removes course | Persistent reconnect, other full native paths, device/multiplayer/human UAT and production cutover |'}
for old,new in replacements.items():
 assert old in s,old;s=s.replace(old,new)
p.write_text(s,encoding='utf-8')
p=root/'tools/registry-workbook/build.mjs';s=p.read_text(encoding='utf-8').replace('03 Oct 2026','04 Oct 2026');p.write_text(s,encoding='utf-8')
print('COURSE_CAST_REGISTRY',len(d['assets']),'assets',len(d['screens']),'screens')
