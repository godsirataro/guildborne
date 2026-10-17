"""Package rendered frames for local review; does not certify motion quality."""
from pathlib import Path
import hashlib
import json
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[3]
for actor in ('greenwood_scout', 'forest_captain'):
    folder = ROOT / 'assets/production/enemy-slice/review' / actor
    sheet = Image.new('RGB', (320 * 8, 340 * 2), '#18202b')
    draw = ImageDraw.Draw(sheet)
    for row, view in enumerate(('front', 'side')):
        frames = [Image.open(folder / 'walk-loop' / view / f'{i:03d}.png').convert('RGB') for i in range(30)]
        frames[0].save(folder / f'Walk-{view}-three-loops.webp', save_all=True,
                       append_images=frames[1:] + frames + frames, lossless=True,
                       duration=[33, 33, 34] * 30, loop=1)
        for column, frame in enumerate((24, 25, 26, 27, 28, 29, 0, 1)):
            sheet.paste(frames[frame], (column * 320, row * 340 + 20))
            draw.text((column * 320 + 8, row * 340 + 3), f'{view}: frame {frame}', fill='white')
    sheet.save(folder / 'Walk-seam-contact-sheet.png')
    hashes = {p.relative_to(folder).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in sorted(folder.rglob('*')) if p.is_file() and p.name != 'hashes.json'}
    (folder / 'hashes.json').write_text(json.dumps(hashes, indent=2) + '\n', encoding='utf-8')
    print(actor, len(hashes), 'artifacts hashed; two three-cycle previews generated')
