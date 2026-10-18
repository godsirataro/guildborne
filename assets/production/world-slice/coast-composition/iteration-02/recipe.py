"""Original coastal composition over immutable native road and reviewed assets.

Existing land is only lowered, preserving its no-intrusion proof. New distant
headlands terminate the bay with shore geometry, rather than a naked water edge.
"""
from pathlib import Path
import importlib.util
import json
import math
import hashlib
from copy import deepcopy

ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT/'assets/production/world-slice/coast-composition'
SOURCE = ROOT/'assets/production/world-slice/corridor-landforms-bounded/scenery.mesh.json'

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT/path)
    obj = importlib.util.module_from_spec(spec); spec.loader.exec_module(obj)
    return obj

old = module('landform_original', 'production/world/quality-slice/corridor-landforms/landform_recipe.py')
split = module('bounded_partition', 'production/world/quality-slice/mesh-extents/partition.py')

def smooth(a, b, x):
    t = max(0, min(1, (x-a)/(b-a)))
    return t*t*(3-2*t)

def terrain(mesh):
    result = deepcopy(mesh)
    for p in result['vertices']:
        x,y,z = p
        # The bank begins beyond all west shoulders. Carve an open fan from
        # the bridge approach to the existing beacon's lower visible body.
        fan = smooth(-390,-450,x) * smooth(-220,-80,z) * (1-smooth(470,610,z))
        p[1] = min(y, y*(1-fan)+min(y, 4+4*math.sin(z*.012))*fan)
        # Away from the floor, a series of ledges replaces one broad slope.
        # Lower-only deformation avoids moving scenery into traversable space.
        if x < -410 and -180 < z < 1280:
            strength = smooth(-410,-480,x)*(1-smooth(1180,1280,z))
            terrace = math.floor(p[1]/12)*12
            p[1] -= (p[1]-terrace)*strength*.82
            ravine = math.exp(-((z-720)/58)**2)*smooth(-420,-570,x)
            p[1] -= 32*ravine
    result['bounds'] = split.bounds(result['vertices'])
    # Geological faces receive coherent rock bands after the sculpt.
    for i, face in enumerate(result['triangles']):
        v = [result['vertices'][j-1] for j in face]
        height = sum(p[1] for p in v)/3
        dx = max(p[0] for p in v)-min(p[0] for p in v)
        dz = max(p[2] for p in v)-min(p[2] for p in v)
        slope = (max(p[1] for p in v)-min(p[1] for p in v))/max(.1, math.hypot(dx,dz))
        result['faceColors'][i] = 7 if height < -24 else 8 if height < -8 else 5 if slope>.55 else 2 if height>8 else 1
    return result

def bay():
    water = old.newmesh('coast_bay_water'); water['colors']=[[.12,.28,.32]]
    bank = old.newmesh('coast_headland_banks')
    # Left/right shore cross-sections, starting under existing ocean. Right
    # shore stays west of the reserved private belt until well beyond Z118.
    sections = [(-90,-1470,-195), (0,-1450,-195), (160,-1420,-195),
                (240,-1360,170),(390,-1250,220),(550,-1300,300),
                (730,-1200,340),(920,-1120,280),(1110,-1170,320),
                (1320,-1080,350),(1510,-950,320),(1660,-760,260),
                (1780,-520,140),(1840,-300,-60)]
    for a,b in zip(sections,sections[1:]):
        za,la,ra=a; zb,lb,rb=b
        old.tri(water,[[la,-12.6,za],[ra,-12.6,za],[rb,-12.6,zb]],1)
        old.tri(water,[[la,-12.6,za],[rb,-12.6,zb],[lb,-12.6,zb]],1)
    # Shallow shore shelves, steep broken rock bank, grass-topped headland,
    # outer submerged skirt. All perimeter water seams lie under this bank.
    end_profiles=[]
    for side in (0,1):
        rows=[]
        for i,(z,left,right) in enumerate(sections):
            x=left if side==0 else right
            direction=-1 if side==0 else 1
            # East bank cannot extend into private plots: until Z240 it
            # remains submerged and narrow on the permitted west side.
            private = side==1 and z<=160
            widths=(-3,0,8,12,14,15) if private else (-16,0,32,55,110,165)
            crest=36+24*math.sin(z*.006+side)**2
            heights=(-15,-12,8,crest,crest*.62,-40)
            if private: heights=(-15,-12,-10,-12,-35,-45)
            if z<0: heights=tuple(min(y,-13) for y in heights)
            rows.append([[x+direction*w,y,z] for w,y in zip(widths,heights)])
        end_profiles.append(rows[-1])
        for a,b in zip(rows,rows[1:]):
            for r in range(5):
                # The east transition begins only beyond private belt.
                q=[a[r],b[r],b[r+1],a[r+1]]
                ci=(8,8,5,2,5)[r]
                old.tri(bank,[q[0],q[1],q[2]],ci)
                old.tri(bank,[q[0],q[2],q[3]],ci)
    # North cap closes the final water span with a narrow sand shelf and
    # rising headland. It is beyond the Greenwood landing and route turn.
    z,l,r=sections[-1]
    caprows=[]
    for dz,y,expand in ((-12,-15,0),(0,-10,10),(40,14,45),(95,45,85),(170,-40,130)):
        caprows.append([[l-expand,y,z+dz],[r+expand,y,z+dz]])
    for i,(a,b) in enumerate(zip(caprows,caprows[1:])):
        old.tri(bank,[a[0],a[1],b[1]],8 if i<2 else 5)
        old.tri(bank,[a[0],b[1],b[0]],8 if i<2 else 5)
    # Stitch each final side-bank cross-section to the matching cap edge.
    # The polygon boundary uses the exact neighboring row vertices; a common
    # raised interior point fills the corner without leaving a wedge-shaped gap.
    for side, profile in enumerate(end_profiles):
        capedge=[row[side] for row in caprows]
        boundary=profile+list(reversed(capedge))
        direction=-1 if side==0 else 1
        center=[(l if side==0 else r)+direction*55,18,z+45]
        for a,b in zip(boundary,boundary[1:]+boundary[:1]):
            old.tri(bank,[center,a,b],5)
    old.bounds(water);old.bounds(bank)
    return [water,bank]

def main():
    source=json.loads(SOURCE.read_text(encoding='utf-8'))
    packet=deepcopy(source); packet['meshes']=[];packet['placements']=[]
    mapping={}
    for m in source['meshes']:
        if m['id'].startswith('landforms_coastal_water'):continue
        candidate=terrain(m) if m['id'].startswith(('landforms_west','landforms_east')) else deepcopy(m)
        parts=split.partition(candidate,[2000]*3)
        mapping[m['id']]=parts;packet['meshes'].extend(parts)
    for p in source['placements']:
        if p['meshId'] not in mapping:continue
        for n,m in enumerate(mapping[p['meshId']]):
            q=deepcopy(p);q['meshId']=m['id']
            if len(mapping[p['meshId']])>1:q['name']+=f'__coast_{n}'
            packet['placements'].append(q)
    for m in bay():
        for part in split.partition(m,[2000]*3):
            packet['meshes'].append(part)
            packet['placements'].append(dict(meshId=part['id'],name=part['id'],cframe=old.IDENTITY,scale=[1,1,1],collision=False,query=False,touch=False))
    report=split.validate_extents(packet)
    lookup={m['id']:m for m in packet['meshes']}
    unique=sum(len(m['triangles']) for m in packet['meshes'])
    instanced=sum(len(lookup[p['meshId']]['triangles']) for p in packet['placements'])
    assert unique<=12000 and instanced<=50000 and len(packet['placements'])<=100
    retained=[p for p in source['placements'] if not p['meshId'].startswith('landforms_')]
    assert len(retained)==57 and all(p in packet['placements'] for p in retained)
    assert all(m in packet['meshes'] for m in source['meshes'] if not m['id'].startswith(('landforms_west','landforms_east','landforms_coastal_water')))
    OUT.mkdir(parents=True,exist_ok=True)
    raw=(json.dumps(packet,separators=(',',':'))+'\n').encode('utf-8')
    (OUT/'scenery.mesh.json').write_bytes(raw)
    provenance=dict(status='FILE_GENERATED_NOT_STUDIO',source=str(SOURCE.relative_to(ROOT)),sourceSha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),packetSha256=hashlib.sha256(raw).hexdigest(),author='Original Guildborne deterministic sculpt and coastal geometry',retainedPlacements=57,beaconUnchanged=True,runtimeIds=None,studioTested=False,humanApproved=False,uniqueTriangles=unique,instancedTriangles=instanced,placements=len(packet['placements']),groundUnchanged=True,description='Lowered western sight fan, stepped ravine, curved bay with shore shelves and headlands; no added scatter')
    (OUT/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n',encoding='utf-8')
    report.update(provenance)
    (OUT/'metrics.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(provenance,indent=2))

if __name__=='__main__':main()
