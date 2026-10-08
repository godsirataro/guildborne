"""Advance art evidence without marking unimported models as game-ready."""
from pathlib import Path
from collections import Counter
import json,re
r=Path(__file__).resolve().parents[1]
for folder in ['borin-forge-v2','vaela-garden-v1']:
 for filename in ['roundtrip-report.json','fbx-roundtrip-report.json']:
  d=json.loads((r/'assets/uat01'/folder/filename).read_text());assert d['status']=='PASS'and d['bones']==16
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['designId']=='npc.city.smith_borin':
  a['productionBinding']='Existing envoy remains bound. New v2local16bone rig: materials/hair polish, accelerating hammer strike/rebound/wrist arc; GLB/FBX contact/loop checks and motion GIF. New art not yet platform-imported or gameplay-bound.'
  a['source']='assets/uat01/city-cast/smith_borin.blend; assets/uat01/borin-forge-v2/; docs/uat01/CIVIC_CONTACT_ART_V2.md'
 if a['designId']=='npc.city.arborist_vaela':
  a['productionBinding']='Existing envoy remains bound. New local16bone elf/garden study with spout-following water;7active/4inactive poses, arm symmetry, loop and skin checks pass inGLB/FBX. New art/import/final likeness pending.'
  a['source']='assets/uat01/city-cast/arborist_vaela.blend; assets/uat01/vaela-garden-v1/; docs/uat01/CIVIC_CONTACT_ART_V2.md'
 if a['designId']in ['animation.borin.forge_contact','world.deepforge.forge_station','vfx.borin.forge_contact']:
  a['source']='assets/uat01/borin-forge-v2/; docs/uat01/CIVIC_CONTACT_ART_V2.md'
  if a['designId']=='animation.borin.forge_contact':a['productionBinding']='v2anticipation/accelerating strike/rebound/20degree wrist arc; cleanGLB/FBX actual mesh contacts/loop pass. Silent15fps motion preview. Runtime import/binding pending.'
new=[('animation.vaela.watering','Animation','Six-second can-tilt activity;16bones, symmetric arms and fixed support hand. GLB/FBX loop/skin checks pass.'),('world.sylvaris.garden_station','City props','Bench, open-rim soil pot and sapling. Local art scene; full city/platform binding pending.'),('vfx.vaela.watering','VFX','Eight-drop cosmetic stream follows posed spout to soil atframes60–120; seven active/four inactive checks inGLB/FBX. Runtime binding pending.'),('audio.vaela.watering','Audio','Two original48k16bit mono WAVs; cue timing and0.4peak checks pass. Listening/import pending.')]
ids={a[0]for a in new};d['assets']=[a for a in d['assets']if a['designId']not in ids]
for identity,group,binding in new:d['assets'].append(dict(designId=identity,group=group,priority='P1',status='LOCAL_CONTACT_ART_VERIFIED_PLATFORM_BINDING_PENDING',source='assets/uat01/vaela-garden-v1/; docs/uat01/CIVIC_CONTACT_ART_V2.md',productionBinding=binding,robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])));p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header=f'> Civic contact art checkpoint — 2026-10-06: Borin v2materials/hair/wrist/strike timing and motion GIF; Vaela v1elf gardener/can/soil contact. Both16bone GLB+FBX reimports pass contacts/loop/skin; water7active/4inactive checks.2new original water WAVs; listening and Roblox import/binding pending. Registry{len(d["assets"])}assets/35AI PNGs/33originalWAV files. Four other detailed contact-art slices/fullcity final art remain. Gameplay baseline672tests/311sources/eight builds unchanged. Latest quota4%used/96%remaining; stop at25%remaining then checkpoint/stop owned work and normal shutdown.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Civic contact art checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
print('CIVIC_CONTACT_CHECKPOINT',len(d['assets']))
