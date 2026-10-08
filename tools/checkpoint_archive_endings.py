from pathlib import Path
from collections import Counter
import json,hashlib
r=Path('.')
p=r/'assets/uat01/archive-endings/manifest.json'
p.write_text(json.dumps({'generator':'built-in image_gen; original procedural native/Blender geometry','concept':'concept-v1.png','conceptPrompt':'CONCEPT_PROMPT.txt','conceptSha256':hashlib.sha256((p.parent/'concept-v1.png').read_bytes()).hexdigest(),'conceptIsRuntimeArt':False,'scenes':['preserve','transform','dismantle'],'nativeParts':223,'triangles':2676,'exports':6,'runtime':'Completed campaign UI replay and committed court epilogue table display','robloxAssetId':None,'humanApproved':False,'limitations':['Native models are blockout tableaus, not the final illustrated scenery or animated cinematics.','No imported assets, real-device acceptance or human art approval.']},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
rows=[]
for id in ['preserve','transform','dismantle']:
 rows.append(dict(designId='world.archiveheart.ending.'+id,group='ArchiveHeart',priority='P0',status='ENDING_TABLEAU_NATIVE_VERIFIED_UAT_PENDING',source='assets/uat01/archive-endings/'+id+'.glb; src/shared/Presentation/ArchiveEndingKit.luau; docs/uat01/validation-archive-endings-native.json',productionBinding='Committed-choice court tableau and completion UI replay; static blockout, not final cinematic',robloxAssetId=None,uatApproved=False))
rows.append(dict(designId='world.archiveheart.endings.concept',group='ArchiveHeart',priority='P0',status='ARCHIVE_HEART_CONCEPT_REFERENCE',source='assets/uat01/archive-endings/concept-v1.png',productionBinding='Original built-in generated three-future art direction; not implemented scenery',robloxAssetId=None,uatApproved=False))
ids={a['designId']for a in rows};d['assets']=[a for a in d['assets']if a['designId']not in ids]+rows
for a in d['assets']:
 if a['designId'].startswith('world.archiveheart.scene.') or a['designId'].startswith('world.archiveheart.boss.'):
  a['productionBinding']='Chapter00–06 fresh ordinary-input Memory journey complete, revision266; later UI/tableau polish separately checked. Final art, imports, multiplayer/devices and human UAT pending.'
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('REGISTERED',len(d['assets']))
