#!/usr/bin/env python3
"""Safety-first design manifest checks (no Blender/Roblox execution)."""
from pathlib import Path
import json,csv,collections,sys
ROOT=Path(__file__).resolve().parents[1]
M=ROOT/'manifest'
a=json.loads((M/'asset_registry.json').read_text(encoding='utf-8'))
p=json.loads((M/'body_presets.json').read_text(encoding='utf-8'))
s=json.loads((M/'skin_palettes.json').read_text(encoding='utf-8'))
assets=a['assets']; presets=p['presets']; palettes=s['palettes']
errors=[]

allowed_races={'HUMAN','ELF','ORC','DWARF'}
allowed_status={'PLANNED','IN_PROGRESS','EXPORTED','IMPORTED','TESTED','ACCEPTED'}
asset_ids=[r['asset_id'] for r in assets]
if len(asset_ids)!=len(set(asset_ids)):errors.append('duplicate asset_id')
expected_race_counts={'HUMAN':4,'ELF':3,'ORC':3,'DWARF':3}
for race,expected in expected_race_counts.items():
 if sum(x['raceId']==race for x in presets)!=expected:errors.append(f'body preset count for {race}')
 if sum(x['raceId']==race for x in palettes)!=5:errors.append(f'palette count for {race}')
for x in assets:
 if x['status'] not in allowed_status:errors.append('invalid status: '+x['asset_id'])
 if x['race'] not in allowed_races | {'ALL'}:errors.append('invalid race: '+x['asset_id'])
 if not x['source_path'].endswith('.blend'):errors.append('bad source: '+x['asset_id'])
 if not x['export_path'].endswith('.fbx'):errors.append('bad export: '+x['asset_id'])
 if x['category']=='BODY' and x['technology']!='R15_15PART':errors.append('bad body geometry type: '+x['asset_id'])
 # Verified imports need actual file, not a placeholder
 if x['status'] in {'EXPORTED','IMPORTED','TESTED','ACCEPTED'} and not (ROOT/x['export_path']).is_file():
  errors.append('missing exported file for '+x['asset_id'])
 if x['status'] in {'IMPORTED','TESTED','ACCEPTED'} and not x.get('roblox_asset_id'):
  # Studio-local import path may be valid without Marketplace ID; require note not empty
  if not x.get('studio_path'):errors.append('imported status without runtime path '+x['asset_id'])
for x in presets:
 if x['raceId'] not in allowed_races:errors.append('invalid preset race')
 if f"CHR_BDY_{x['bodyPresetId']}_V01" not in asset_ids:errors.append('missing body ID '+x['bodyPresetId'])
for x in palettes:
 if not x['colorHex'].startswith('#') or len(x['colorHex'])!=7:errors.append('invalid palette color '+x['skinPaletteId'])
body_parts=['Head_Geo','UpperTorso_Geo','LowerTorso_Geo','LeftUpperArm_Geo','LeftLowerArm_Geo','LeftHand_Geo','RightUpperArm_Geo','RightLowerArm_Geo','RightHand_Geo','LeftUpperLeg_Geo','LeftLowerLeg_Geo','LeftFoot_Geo','RightUpperLeg_Geo','RightLowerLeg_Geo','RightFoot_Geo']
if len(body_parts)!=15 or len(set(body_parts))!=15:errors.append('R15 body parts spec invalid')
with (M/'fit_qa_matrix.csv').open(encoding='utf-8-sig') as f:
 rows=list(csv.DictReader(f))
for row in rows:
 if row['body_preset_id'] not in {p['bodyPresetId'] for p in presets}:errors.append('invalid fit preset: '+row['body_preset_id'])
 if row['clothing_asset_id'] not in asset_ids:errors.append('invalid fit garment: '+row['clothing_asset_id'])
print(f"Assets={len(assets)}; BodyPresets={len(presets)}; SkinPalettes={len(palettes)}; FitQARows={len(rows)}; R15Parts=15")
print('Asset categories:', dict(collections.Counter(x['category'] for x in assets)))
if errors:
 for msg in errors:print('FAIL:',msg)
 sys.exit(1)
print('PASS: design registry integrity. This is NOT a Blender mesh or Roblox Studio test.')
