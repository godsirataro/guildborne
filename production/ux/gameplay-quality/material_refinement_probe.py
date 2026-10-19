"""Bounded ore/timber source comparison. CPU approximation, never Studio proof."""
import argparse
import hashlib
import json
import re
import numpy as np
from PIL import Image, ImageDraw
import material_portraits_probe as geometry

ROOT = geometry.ROOT
BASE = 'e34a2e7'
IDS = ('iron_ore', 'timber')
OUT = ROOT / 'assets/production/ui-slice/material-refinement-v9'


def runtime_matches(kit):
    """Parse emitted runtime pieces independently; catch stale generated geometry."""
    source = (ROOT / 'src/shared/Data/ItemVisuals.luau').read_text()
    blocks = dict(re.findall(r'\["([^"\n]+)"\]=\{\n(.*?)\n\t\},', source, re.S))
    assert set(blocks) == {a['id'] for a in kit['assets']}, 'runtime IDs'
    pattern = r'name=("(?:[^"\\]|\\.)*"),size=V\(([^)]+)\),position=V\(([^)]+)\),rotation=V\(([^)]+)\),color=Color3.fromRGB\(([^)]+)\),kind="([^"\n]+)"'
    count = 0
    for asset in kit['assets']:
        pieces = re.findall(pattern, blocks[asset['id']])
        assert len(pieces) == len(asset['parts']), asset['id'] + ' runtime count'
        for emitted, part in zip(pieces, asset['parts']):
            name, size, position, rotation, color, kind = emitted
            assert json.loads(name) == part['name']
            for vector, field in zip((size, position, rotation), ('size', 'position', 'rotation')):
                assert np.allclose([float(n) for n in vector.split(',')], part[field], rtol=0, atol=.0000051), (asset['id'], field)
            assert [int(n) for n in color.split(',')] == kit['palette'][part['color']]
            assert kind == ('WedgePart' if part.get('shape') == 'Wedge' else 'Part')
            count += 1
    return count


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    # Reuse the historical renderer without touching its script or output files.
    geometry.BASE, geometry.IDS = BASE, IDS
    raw = (ROOT / 'assets/uat01/item-kit/kit.json').read_bytes()
    before = json.loads(geometry.git_file('assets/uat01/item-kit/kit.json'))
    after = json.loads(raw)
    assert before['palette'] == after['palette'], 'entire palette must remain frozen'
    old, new = geometry.verify(before, after)
    runtime_parts = runtime_matches(after)
    report = {
        'status': 'PASS', 'evidence': 'LOCAL APPROXIMATION NOT STUDIO',
        'baseline': BASE, 'sourceSha256': hashlib.sha256(raw).hexdigest(),
        'changedDefinitions': list(IDS), 'frozenDefinitionsAndResolvedColors': 28,
        'entirePaletteUnchanged': True, 'constructorUnchanged': True,
        'runtimePiecesMatchedToKit': runtime_parts, 'frustumCheckedItems': 30,
        'camera': {'pixels': [80,80], 'verticalFov': 35, 'direction': [1,.4,-3], 'sphereFitMargin': 1.12},
        'smallPreview': '48px Lanczos downsample of the 80px CPU image; not a native 48px render',
        'limitations': 'Source geometry with approximate lighting; not Roblox pixels, device QA, asset import or human approval.',
        'materials': {},
    }
    sheet = Image.new('RGB', (850,490), (15,21,35))
    draw = ImageDraw.Draw(sheet)
    draw.text((15,12), 'LOCAL APPROXIMATION NOT STUDIO | ore and timber refinement', fill=(245,236,216))
    draw.text((15,32), 'Each cell: native-size 80px CPU render | nearest 2x | 48px downsample', fill=(220,183,107))
    for row, key in enumerate(IDS):
        y = 92 + row * 195
        draw.text((15,y-24), key, fill=(245,236,216))
        for col, (label, assets, palette) in enumerate((('before',old,before['palette']), ('after',new,after['palette']))):
            x = 15 + col*420
            draw.text((x,y-10), label, fill=(220,183,107))
            img, fit, covered = geometry.render(assets[key], palette)
            small = img.resize((48,48), Image.Resampling.LANCZOS)
            sheet.paste(img, (x,y+16))
            sheet.paste(img.resize((160,160),Image.Resampling.NEAREST), (x+92,y+16))
            sheet.paste(small, (x+267,y+16))
            report['materials'].setdefault(key,{})[label] = {'parts':len(assets[key]['parts']), 'maximumFrustumFraction':fit, 'coveredPixels':covered}
            if not args.check_only:
                OUT.mkdir(parents=True,exist_ok=True)
                img.save(OUT/f'{key}-{label}-80.png')
                small.save(OUT/f'{key}-{label}-48.png')
    if not args.check_only:
        sheet.save(OUT/'comparison.png')
        (OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
