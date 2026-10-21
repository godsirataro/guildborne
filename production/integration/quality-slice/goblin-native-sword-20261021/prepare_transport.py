"""Read frozen reviewed sword data; decode exact preview PNG pixels for local transport."""
from pathlib import Path
import hashlib
import json
import math
from PIL import Image

ROOT = Path('C:/Work/MySelf/Guildborne/assets/production/enemy-slice/goblin-equipment/export')
OUT = Path('C:/Work/MySelf/Guildborne-controller/build/goblin-native-sword-20261021')
OUT.mkdir(parents=True, exist_ok=True)
sha = lambda b: hashlib.sha256(b).hexdigest()
raw = (ROOT/'goblin_warrior_sword.mesh.json').read_bytes()
assert sha(raw) == '9c606cc4d964583ab7f61dc2b5b49947c5ffe007fb04bece7085c90a4687fd69'
data = json.loads(raw)
assert data['id'] == 'goblin_warrior_sword' and data['units'] == 'stud'
assert len(data['positions']) == 983 and len(data['triangles']) == 1666
for v in data['positions']:
    assert len(v) == 3 and all(type(n) in (int,float) and math.isfinite(n) and abs(n)<10 for n in v)
for f in data['triangles']:
    assert len(f['vertices']) == 3 and len(set(f['vertices'])) == 3
    assert all(type(i) is int and 0<=i<len(data['positions']) for i in f['vertices'])
    assert f['material'] == 0 and len(f['uv']) == len(f['normals']) == 3
    for uv in f['uv']:
        assert len(uv)==2 and all(math.isfinite(x) and 0<=x<=1 for x in uv)
    for n in f['normals']:
        assert len(n)==3 and all(math.isfinite(x) for x in n) and abs(sum(x*x for x in n)-1)<1e-5
(OUT/'mesh.json').write_bytes(raw)
receipt={'mesh':{'sha256':sha(raw),'bytes':len(raw)},'images':[]}
rows=json.loads((ROOT/'native-preview1024/manifest.json').read_text())
rows=[r for r in rows if r['derivative'].startswith('first-batch_')]
assert len(rows)==4 and {r['role'] for r in rows}=={'ColorMap','NormalMap','RoughnessMap','MetalnessMap'}
for r in rows:
    path=ROOT/'native-preview1024'/r['derivative']
    assert path.parent.resolve()==(ROOT/'native-preview1024').resolve()
    assert sha(path.read_bytes())==r['derivativeSha256']
    assert sha((ROOT/r['source']).read_bytes())==r['sourceSha256']
    with Image.open(path) as im:
        assert im.size==(1024,1024)
        rgba=im.convert('RGBA').tobytes()
    assert len(rgba)==4194304 and sha(rgba)==r['rgbaSha256']
    (OUT/(r['role']+'.rgba')).write_bytes(rgba)
    receipt['images'].append(r)
(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({'meshBytes':len(raw),'images':len(rows),'rgbaBytesEach':4194304,'output':str(OUT)}))
