"""Local geometric checks, not Roblox physics/device acceptance."""
import hashlib
import json
import math
import re
from collections import Counter
from pathlib import Path
from build_city_landscape import ROOT, OUT, make_recipe, bounds

data=json.loads((OUT/'landscape.json').read_text(encoding='utf-8'))
assert data == make_recipe(), 'Generated recipe differs from deterministic source'
assert 1 <= len(data['parts']) <= 1800, 'Native detail budget exceeded'
errors=[]
for p in data['parts']:
    assert all(math.isfinite(v) for field in ('size','position','rotation','color') for v in p[field])
    assert all(v > 0 for v in p['size'])
    a,b,c,d=bounds(p)
    assert -438 <= a <= c <= 438 and -1614 <= b <= d <= -707
    for r in data['exclusions']:
        if p['group']=='HearthSpring' and r['name'] in ('SpringReserve','StrollReserve'):continue
        x,z,xx,zz=r['bounds']
        if a < xx and c > x and b < zz and d > z:errors.append((p['name'],r['name']))
assert not errors, errors[:10]

# Independent swept party path: regressions found at tavern and rotated forge door.
# Radius 6 is a geometric reservation, not a replacement for the physical five-hero walk.
routes=[[(0,-720),(0,-820),(-140,-820),(-140,-870),(-140,-820)],
        [(0,-820),(0,-1100),(300,-1100),(410,-1100),(410,-1000),(370,-1000)],
        [(0,-1100),(0,-1490)], [(-350,-1100),(350,-1100)]]
samples=0
for route in routes:
    for (x,z),(xx,zz) in zip(route,route[1:]):
        steps=math.ceil(math.hypot(xx-x,zz-z)/2)
        for i in range(steps+1):
            px,pz=x+(xx-x)*i/steps,z+(zz-z)*i/steps
            samples+=1
            for p in data['parts']:
                a,b,c,d=bounds(p)
                assert not (a < px+6 and c > px-6 and b < pz+6 and d > pz-6), (p['name'],px,pz)

native=(ROOT/'src/server/Services/CityLandscapeData.luau').read_text(encoding='utf-8')
assert native.count('{group=')==len(data['parts'])
world=(ROOT/'src/server/Services/CentralCityWorld.luau').read_text(encoding='utf-8')
assert 'require(script.Parent.CityLandscape)(town)' in world
assert 'asset("TreeA"' not in world and 'asset("TreeB"' not in world
# Service identities and authority integration must survive landscape integration.
for token in ('CityForgeStation','CityTavernStation','GuildborneCityCraftingStation','MaxServiceDistance'):
    assert token in world
report=dict(status='PASS',scope='deterministic recipe and projected geometry only',
    parts=len(data['parts']),counts=dict(Counter(p['name'] for p in data['parts'])),
    collisionParts=sum(p['solid'] for p in data['parts']),protectedRectangles=len(data['exclusions']),
    independentRouteSamples=samples,partyEnvelopeRadiusStuds=6,
    studioTested=False,physicalDeviceTested=False,humanArtApproved=False,
    recipeSha256=hashlib.sha256((OUT/'landscape.json').read_bytes()).hexdigest())
(OUT/'validation.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2))
