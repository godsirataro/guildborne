"""Local geometric checks, not Roblox physics/device acceptance."""
import hashlib
import json
import math
import re
from collections import Counter
from pathlib import Path
from build_city_landscape import ROOT, OUT, make_recipe, bounds, rotation_matrix, luau_source

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

# Cylinder length is local X. Check the generated rotations against intended
# branch endpoints, independently of the angle formula used by the authoring code.
branch_checks=0
branch_max_error=0
trunk=None
for p in data['parts']:
    if p['name']=='Trunk':trunk=p
    if p['name']!='Bough':continue
    assert trunk is not None and trunk['group']==p['group'], 'Bough lacks its trunk'
    start=[trunk['position'][0],trunk['size'][0]*.52,trunk['position'][2]]
    end=[2*p['position'][i]-start[i] for i in range(3)]
    rotation=rotation_matrix(p['rotation'])
    for sign,expected in ((-1,start),(1,end)):
        actual=[p['position'][i]+sign*rotation[i][0]*p['size'][0]/2 for i in range(3)]
        error=math.dist(actual,expected)
        branch_max_error=max(branch_max_error,error)
        assert error < .001, ('Bough endpoint mismatch',p['position'],error)
    branch_checks+=1
assert branch_checks > 0

# Independent swept party path: regressions found at tavern and rotated forge door.
# Radius 6 is a geometric reservation, not a replacement for the physical five-hero walk.
routes=[[(0,-720),(0,-820),(-140,-820),(-140,-870),(-140,-820)],
        [(0,-820),(0,-1100),(300,-1100),(410,-1100),(410,-1000),(370,-1000)],
        [(0,-1100),(0,-1490)], [(-350,-1100),(350,-1100)],
        [(300,-1100),(300,-1160)]]
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
assert native==luau_source(data), 'Generated Luau differs from the verified recipe'
assert b'\r' not in (ROOT/'src/server/Services/CityLandscapeData.luau').read_bytes(), 'Generated Luau must use LF'
world=(ROOT/'src/server/Services/CentralCityWorld.luau').read_text(encoding='utf-8')
# Check the actual authored road dimensions, rather than merely testing that
# decoration avoids a hypothetical route. These straight segments must carry a
# six-stud envelope and reach the CityKit front wall (local z=20) at each door.
road_pattern=r'road\("([^"\n]+)",V\((-?[\d.]+),0,(-?[\d.]+)\),V\((-?[\d.]+),0,(-?[\d.]+)\),([\d.]+)\)'
road_bounds={}
for name,x,z,xx,zz,width in re.findall(road_pattern,world):
    x,z,xx,zz,width=map(float,(x,z,xx,zz,width))
    assert x==xx or z==zz, ('Expected axis-aligned road',name)
    road_bounds[name]=(min(x,xx)-width/2,min(z,zz)-width/2,
                       max(x,xx)+width/2,max(z,zz)+width/2)
paved_routes={
    'ForgeApproach':((350,-1100),(410,-1100)),
    'ForgeEastLane':((410,-1100),(410,-1000)),
    'ForgeThreshold':((410,-1000),(390,-1000)),
    'ExchangeThreshold':((300,-1130),(300,-1160)),
}
paved_samples=0
for name,(start,end) in paved_routes.items():
    assert name in road_bounds, ('Missing paved service approach',name)
    a,b,c,d=road_bounds[name]
    steps=math.ceil(math.dist(start,end)/2)
    for i in range(steps+1):
        x,z=[start[j]+(end[j]-start[j])*i/steps for j in range(2)]
        assert a<=x-6 and c>=x+6 and b<=z-6 and d>=z+6, ('Paving gap',name,x,z)
        paved_samples+=1
        for part in data['parts']:
            pa,pb,pc,pd=bounds(part)
            assert not (pa<x+6 and pc>x-6 and pb<z+6 and pd>z-6), ('Landscape blocks paved approach',name,part['name'])
assert 'require(script.Parent.CityLandscape)(town)' in world
assert 'asset("TreeA"' not in world and 'asset("TreeB"' not in world
# Service identities and authority integration must survive landscape integration.
for token in ('CityForgeStation','CityTavernStation','GuildborneCityCraftingStation','MaxServiceDistance'):
    assert token in world
report=dict(status='PASS',scope='deterministic recipe and projected geometry only',
    parts=len(data['parts']),counts=dict(Counter(p['name'] for p in data['parts'])),
    collisionParts=sum(p['solid'] for p in data['parts']),protectedRectangles=len(data['exclusions']),
    independentRouteSamples=samples,partyEnvelopeRadiusStuds=6,
    pavedServiceApproachSamples=paved_samples,
    branchEndpointChecks=branch_checks*2,maxBranchEndpointErrorStuds=branch_max_error,
    studioTested=False,physicalDeviceTested=False,humanArtApproved=False,
    recipeSha256=hashlib.sha256((OUT/'landscape.json').read_bytes()).hexdigest())
(OUT/'validation.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(report,indent=2))
