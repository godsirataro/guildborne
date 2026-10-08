"""Register local art evidence; preserve existing gameplay/import distinctions."""
from pathlib import Path
from collections import Counter
import json,re
r=Path(__file__).resolve().parents[1];o=r/'assets/uat01/borin-forge-v1'
v=json.loads((o/'roundtrip-report.json').read_text());assert v['status']=='PASS' and v['bones']==16
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['designId']=='npc.city.smith_borin':
  a['source']+='; assets/uat01/borin-forge-v1/Guildborne_Borin_Forge.blend; docs/uat01/BORIN_FORGE_ART.md'
  a['productionBinding']='Existing CentralCity envoy/dialogue/quest remains bound. New local16bone reference interpretation with forge contact GLB verified separately; new mesh/animation not imported or gameplay-bound. Final likeness and human acceptance pending.'
records=[('animation.borin.forge_contact','Animation','Local16bone six-second clip; three evaluated hammer contacts, stable feet/root and loop seam. Natural wrist arc, retarget/import/runtime pending.'),('world.deepforge.forge_station','City props','Editable anvil/workpiece/tools and modular backdrop. Local art study; full city architecture and platform binding pending.'),('vfx.borin.forge_contact','VFX','Nine local cosmetic sparks timed to contact frames30/90/150 in Blender. Runtime lifecycle/device/import pending.'),('audio.borin.forge_contact','Audio','Original mono48k16bit single strike and six-second sync sequence; timing/peak verified, listening/platform import pending.')]
ids={x[0]for x in records};d['assets']=[a for a in d['assets']if a['designId']not in ids]
for identity,group,binding in records:
 d['assets'].append(dict(designId=identity,group=group,priority='P1',status='LOCAL_CONTACT_ART_VERIFIED_PLATFORM_BINDING_PENDING',source='assets/uat01/borin-forge-v1/; docs/uat01/BORIN_FORGE_ART.md',productionBinding=binding,robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])));p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header=f'> Borin art checkpoint — 2026-10-06: reference interpretation with16bone rig and6second forge clip; local sparks plus2originalWAV cues. CleanGLB reimport passes3surface contacts, stable feet/root/loop seam; {v["triangles"]}triangles including station/effects. New art is not yet Roblox-imported/gameplay-bound; likeness, wrist/body polish, LOD, listening and human review pending. Registry{len(d["assets"])}assets;35AI PNGs/31originalWAV files. Existing gameplay672tests/311runtime sources/eight builds unchanged. Quota4%used/96%remaining last observed; continue to25%remaining then checkpoint/stop owned work and normal shutdown.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Borin art checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
print('BORIN_CHECKPOINT',len(d['assets']))
