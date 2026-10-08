"""Merge trial source/evidence records; never assigns cloud IDs or UAT approval."""
from pathlib import Path
from collections import Counter
import json,hashlib
root=Path(__file__).resolve().parents[1]
p=root/'assets/uat01/manifest.json';data=json.loads(p.read_text(encoding='utf-8'))
file='assets/uat01/generated/guildborne-five-disciplines-v1.png'
entry=dict(file=file,width=1536,height=1024,mode='RGB',sha256=hashlib.sha256((root/file).read_bytes()).hexdigest(),generator='built-in image_gen',date='2026-10-04',robloxAssetId=None,uploaded=False,status='trial_concept_reference',alphaRange=None,promptSource='assets/uat01/FIVE_DISCIPLINES_PROMPT.md')
data['images']=[i for i in data['images'] if i['file']!=file]+[entry];data['generatedAssetCount']=len(data['images']);p.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
p=root/'docs/uat01/intake/registry-reconciled.json';data=json.loads(p.read_text(encoding='utf-8'))
new=[]
for group in ['concept','court','pillars','sentinel','patient']:
 new.append(dict(designId='asset.novice.trial.'+group,group='Novice trial',priority='P0',status='TRIAL_CONCEPT_REFERENCE_NOT_PLAYABLE'if group=='concept'else 'NATIVE_COURSE_LOCAL_EXPORTS_IMPORT_PENDING',source=file if group=='concept'else 'assets/uat01/trial-arena/trial_arena_'+group+'.glb; src/server/Services/NoviceTrialArt.luau',productionBinding='Optional memory-only Chapter 00 course; actual six-chapter Mage/Knight rescue journey revision28; production import and UAT pending',robloxAssetId=None,uatApproved=False))
ids={a['designId']for a in new};data['assets']=[a for a in data['assets']if a['designId']not in ids]+new
screen=dict(designId='screen.novice.solo_trial',name='Solo class trial HUD',scope='UAT01',implementationCandidate='src/client/Controllers/NoviceTrialController.luau',status='NATIVE_COURSE_INPUT_VERIFIED_REQUIRES_UAT',requiredBehavior='Owner-bound health, lesson progress, ready/failure/victory; F/Q and clickable bounded attack intents, cooldowns and leave; no client outcome claims.',requiredStates='EN/TH; compact layout; one actual full course journey passed; persistent rejoin, retry and physical device acceptance pending',uatApproved=False)
data['screens']=[s for s in data['screens']if s['designId']!=screen['designId']]+[screen]
data['summary'].update(assets=len(data['assets']),screens=len(data['screens']),screenScopes=dict(Counter(s['scope']for s in data['screens'])),assetStatuses=dict(Counter(a['status']for a in data['assets'])))
p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('TRIAL_REGISTRY',len(data['assets']),'assets',len(data['screens']),'screens')
