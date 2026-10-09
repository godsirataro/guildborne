"""Self-contained character authoring contract and explicit fit matrix. No fake meshes."""
from __future__ import annotations
import csv
from pathlib import Path
import sys
from forge import ROOT, read_json, save_json

PARTS = ['Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand',
         'RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot',
         'RightUpperLeg','RightLowerLeg','RightFoot']


def validate(catalog: dict, aliases: dict):
    assets = {a[0]: a for a in catalog['assets']}
    if len(assets) != len(catalog['assets']): raise ValueError('Duplicate character IDs')
    presets = {p['bodyPresetId']: p for p in catalog['bodyPresets']}
    if len(presets) != len(catalog['bodyPresets']): raise ValueError('Duplicate body preset')
    races = {'HUMAN','ELF','ORC','DWARF'}
    for p in presets.values():
        if p['raceId'] not in races or not .5 <= p['visualHeightRatioToHuman'] <= 1.5:
            raise ValueError('Unsupported race or extreme body ratio')
    for old, new in aliases.items():
        if old in assets or new not in assets: raise ValueError('Invalid alias mapping')
    palettes = catalog['skinPalettes']
    if len({p['skinPaletteId'] for p in palettes}) != len(palettes): raise ValueError('Duplicate palette')
    for p in palettes:
        import re
        if p['raceId'] not in races or not re.fullmatch(r'#[0-9A-Fa-f]{6}',p['colorHex']):
            raise ValueError('Invalid skin palette')
    return assets, presets


def fit_matrix(catalog: dict):
    rows = []
    for preset in catalog['bodyPresets']:
        for asset in catalog['assets']:
            if asset[6] not in ('LAYERED','RIGID') or asset[1] in ('BODY','HEAD'):
                continue
            race_match = asset[2] in ('ALL',preset['raceId'])
            rows.append({'bodyPresetId':preset['bodyPresetId'],'assetId':asset[0],
                'fitProfile':asset[5], 'technology':asset[6],
                'status':'UNTESTED' if race_match else 'OUT_OF_SCOPE',
                'compatible':False, 'evidence':None})
    return rows


def main():
    base=ROOT/'production/character-kit-v1'
    catalog=read_json(base/'catalog.json'); aliases=read_json(base/'aliases.json')
    validate(catalog,aliases)
    out=ROOT/'build/agentic/character-kit'
    save_json(out/'authoring-contract.json',{'schemaVersion':2,
        'source':'production/character-kit-v1/catalog.json', 'bodyMeshNames':[n+'_Geo' for n in PARTS],
        'runtimeParts':PARTS, 'bodyPresets':catalog['bodyPresets'],'skinPalettes':catalog['skinPalettes'],
        'aliases':aliases,'wizard':'HUMAN_APPEARANCE_NOT_RACE',
        'runtimeImported':False,'fitMatrix':fit_matrix(catalog)})
    with (out/'asset-registry.csv').open('w',encoding='utf-8',newline='') as f:
        writer=csv.writer(f);writer.writerow(['assetId','category','race','variant','slot','fitProfile','technology','priority'])
        writer.writerows(catalog['assets'])
    print(f'CHARACTER_CONTRACT_PASS: {len(catalog["assets"])} planned assets, {len(PARTS)} required body parts; no meshes generated or fit approved')


if __name__=='__main__':
    try:main()
    except (OSError,ValueError,KeyError,TypeError) as exc:
        print(f'Character contract failed: {exc}',file=sys.stderr);sys.exit(1)
