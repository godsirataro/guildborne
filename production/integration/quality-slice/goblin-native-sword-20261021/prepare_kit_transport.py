"""Decode exact frozen palette pixels for an isolated native review, no resizing."""
from pathlib import Path
from PIL import Image
import hashlib
import json

source = Path('C:/Work/MySelf/Guildborne/assets/production/enemy-slice/goblin-equipment/export/r6-authored')
out = Path('C:/Work/MySelf/Guildborne-controller/build/goblin-native-sword-20261021/kit')
out.mkdir(parents=True, exist_ok=True)
receipt = []
for role, filename in [('ColorMap', 'color.png'), ('RoughnessMap', 'roughness.png'), ('MetalnessMap', 'metalness.png')]:
    path = source / filename
    with Image.open(path) as im:
        assert im.size == (128, 16)
        raw = im.convert('RGBA').tobytes()
    (out / (role + '.rgba')).write_bytes(raw)
    receipt.append(dict(role=role, source=str(path), sourceSha256=hashlib.sha256(path.read_bytes()).hexdigest(), rgbaSha256=hashlib.sha256(raw).hexdigest(), width=128, height=16))
(out / 'palette-receipt.json').write_text(json.dumps(receipt, indent=2)+'\n')
print(json.dumps(receipt))
