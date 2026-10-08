"""Record six local art studies without declaring production approval."""
from pathlib import Path
from collections import Counter
import json,re
R=Path(__file__).resolve().parents[1]
cast=[('elian','marshal_elian','elian-desk-v1','crownford','charter_stamp'),('vaela','arborist_vaela','vaela-garden-v1','sylvaris','watering'),('borin','smith_borin','borin-forge-v2','deepforge','forge_contact'),('nyra','cartographer_nyra','nyra-desk-v1','astralis','chart_trace'),('sela','harbormaster_sela','sela-desk-v1','crosshaven','ledger_write'),('roka','steward_roka','roka-hearth-v1','ironroot','hearth_stir')]
p=R/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for short,identity,folder,city,activity in cast:
 for report in ['roundtrip-report.json','fbx-roundtrip-report.json']:
  result=json.loads((R/'assets/uat01'/folder/report).read_text());assert result['status']=='PASS' and result['bones']==16
 source=f'assets/uat01/{folder}/; docs/uat01/CIVIC_CONTACT_SIX.md'
 for a in d['assets']:
  if a['designId']=='npc.city.'+identity:
   a['source']=source;a['productionBinding']='Existing gameplay envoy/host remains bound. New local 16-bone contact-art study verified in Blender exports and native Studio viewer. Final likeness, platform import and main-world replacement pending.'
 if short in ['borin','vaela']:continue
 additions=[(f'animation.{short}.{activity}','Animation','Six-second profession-specific contact loop; GLB/FBX reimport and native Studio pose probes pass.'),(f'world.{city}.{activity}_station','City props','Matching local activity station and held props; full city placement pending.'),(f'audio.{short}.{activity}','Audio','Original 48kHz mono 16-bit WAV; cue and peak checked, listening/platform import pending.')]
 if short!='sela':additions.append((f'vfx.{short}.{activity}','VFX','Local authored cosmetic effect and deterministic native review equivalent; final particle art and gameplay binding pending.'))
 for identity,group,binding in additions:
  d['assets']=[a for a in d['assets']if a['designId']!=identity]
  d['assets'].append(dict(designId=identity,group=group,priority='P1',status='LOCAL_CONTACT_ART_VERIFIED_PLATFORM_BINDING_PENDING',source=source,productionBinding=binding,robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header=f'> Six civic art checkpoint — 2026-10-06: six local Blender/GLB/FBX activity studies; 96 native Studio bones, 52 contact poses and 12 effect samples verified. Standalone viewer ordinary mouse Pause/Reset/solo/All/Resume passed; silent, local only. Final likeness/import/main-world binding remain pending. Registry {len(d["assets"])} assets / 73 screens / 33 work areas; 35 AI images / 37 original WAVs. Gameplay baseline 672 tests / 311 sources / eight builds unchanged. Latest quota 9% used / 91% remaining; stop at 25% remaining, save and stop owned work, then normal shutdown.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=R/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> (?:Six civic art|Civic contact art) checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=R/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.', 'Latest observed quota: 9% used / 91% remaining.',s);p.write_text(s,encoding='utf-8')
print('SIX_CIVIC_CHECKPOINT',len(d['assets']))
