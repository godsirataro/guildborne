"""Deterministic native landscape: one geometry recipe for Roblox and Blender.

No downloaded models, runtime asset IDs, Terrain mutation or online services.
Coordinates are studs, Y up; rotation follows Roblox CFrame.Angles (XYZ).
"""
import json
import math
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/uat01/city-landscape'
PALETTE = {
    'bark': [88, 71, 53], 'barkLight': [117, 99, 75],
    'leafDark': [48, 79, 57], 'leaf': [67, 100, 62], 'leafLight': [91, 120, 69],
    'sage': [112, 136, 85], 'grass': [94, 115, 72], 'earth': [105, 100, 72],
    'rock': [132, 137, 126], 'rockDark': [101, 112, 107],
    'flower': [164, 147, 190], 'cream': [220, 207, 156],
    'water': [71, 132, 139], 'path': [161, 154, 131], 'timber': [108, 79, 54],
}


def rotation_matrix(degrees):
    x, y, z = map(math.radians, degrees)
    cx, sx, cy, sy, cz, sz = math.cos(x), math.sin(x), math.cos(y), math.sin(y), math.cos(z), math.sin(z)
    return ((cy*cz, -cy*sz, sy), (cx*sz+sx*sy*cz, cx*cz-sx*sy*sz, -sx*cy),
            (sx*sz-cx*sy*cz, sx*cz+cx*sy*sz, cx*cy))


def bounds(part):
    r = rotation_matrix(part['rotation'])
    h = [sum(abs(r[i][j])*part['size'][j]/2 for j in range(3)) for i in range(3)]
    x, _, z = part['position']
    return x-h[0], z-h[2], x+h[0], z+h[2]


def exclusions():
    # Conservative footprints include roof overhangs, portal returns, five-companion
    # approaches and NPC work areas. Checked again against source by verification.
    areas = []
    def rect(name, x, z, hx, hz):
        areas.append(dict(name=name, bounds=[x-hx, z-hz, x+hx, z+hz]))
    rect('GrandAvenue', 0, -1105, 24, 457)
    rect('GuildMarketAvenue', 0, -1100, 374, 24)
    rect('TavernApproach', -102.5, -820, 126.5, 24)
    rect('GardenWalk', -193, -960, 17, 157)
    rect('ArrivalAndCivicPortals', 0, -664, 230, 40)
    for x in (-300, 300):
        rect('DistrictLane', x, -1045, 17, 102)
        rect('DistrictBypass', x+math.copysign(40, x), -1195, 13, 88)
        rect('DistrictBypassEntry', x+math.copysign(20, x), -1120, 33, 13)
        rect('ServiceLane', x, -1215, 93, 13)
    for name, x, z, hx, hz in [('Plaza', 0, -1100, 98, 98), ('GuildCourt', -300, -1100, 63, 58),
        ('MarketCourt', 300, -1100, 63, 58), ('TavernCourt', -140, -820, 63, 58),
        ('TowerCourt', 0, -1510, 68, 105), ('ArrivalCourt', 0, -680, 63, 58),
        ('Tavern', -140, -870, 40, 40), ('GuildOffice', -300, -1170, 40, 40),
        ('Exchange', 300, -1180, 40, 40), ('ForgeAndBorinWork', 381, -990, 51, 54),
        ('AlchemyAndHerbalist', 235, -1012, 44, 48), ('FutureGuildHall', -385, -1240, 32, 29),
        ('MarketStalls', 330, -1057, 72, 18), ('Nyra', -42, -1460, 12, 12),
        ('Ghar', 39, -1508, 14, 14), ('Vaela', 260, -1088, 14, 14),
        ('Borin', 370, -958, 14, 14), ('ForgePartyEast', 410, -1050, 14, 64),
        ('ForgePartyApproach', 355, -1100, 69, 14),
        ('SpringReserve', -352, -918, 39, 32), ('StrollReserve', -275, -883, 58, 37)]:
        rect(name, x, z, hx, hz)
    for z in (-760, -920, -1000, -1260, -1380, -1480):
        for side in (-1, 1):
            rect('AvenueLantern', side*24, z, 7, 7)
            if z < -1200: rect('SouthFrontage', side*125, z, 26, 29)
    for z in (-755, -825, -915, -985):
        rect('EastFrontage', 93, z, 30, 33)
        if z in (-755, -985): rect('WestFrontage', -93, z, 30, 33)
    for side in (-1, 1):
        for x in (160, 225):
            rect('CrossFrontage', side*x, -1190, 33, 30)
            rect('CrossFrontage', side*x, -1010, 30, 28)
        for z in (-1260, -1350, -1440): rect('OuterFrontage', side*230, z, 32, 38)
    return areas


def make_recipe():
    rng = random.Random(16062026)
    parts, groups = [], []
    forbidden = exclusions()
    group = ''

    def part(name, size, position, color, rotation=(0, 0, 0), shape='Block', material='SmoothPlastic', solid=False):
        p = dict(group=group, name=name, size=[round(v, 4) for v in size],
                 position=[round(v, 4) for v in position], rotation=[round(v, 4) for v in rotation],
                 color=PALETTE[color], shape=shape, material=material, solid=solid)
        a, b, c, d = bounds(p)
        if a < -438 or c > 438 or b < -1614 or d > -707: return False
        if any(a < r['bounds'][2] and c > r['bounds'][0] and b < r['bounds'][3] and d > r['bounds'][1]
               for r in forbidden if not (group == 'HearthSpring' and r['name'] in ('SpringReserve','StrollReserve'))): return False
        parts.append(p)
        return True

    def branch(a, b, width):
        dx, dy, dz = (b[i]-a[i] for i in range(3))
        length = math.sqrt(dx*dx+dy*dy+dz*dz)
        # Cylinder local X is aligned with the branch vector.
        part('Bough', (length, width, width), tuple((a[i]+b[i])/2 for i in range(3)), 'bark',
             (0, -math.degrees(math.atan2(dz, dx)), math.degrees(math.atan2(dy, math.hypot(dx, dz)))), 'Cylinder', 'Wood')

    def tree(x, z, scale, phase):
        # Asymmetric boughs and overlapping flattened crowns, with a smaller crown
        # at the top: varied silhouettes rather than three identical spheres.
        h = 22*scale
        part('Trunk', (h, 2.1*scale, 2.4*scale), (x, h/2+.3, z), 'bark', (0, 0, 90), 'Cylinder', 'Wood', True)
        for i in range(3):
            theta = phase+i*2.2
            dx, dz = math.cos(theta)*6*scale, math.sin(theta)*6*scale
            y = h*(.77+i*.12)
            branch((x, h*.52, z), (x+dx, y, z+dz), 1.1*scale)
            part('OakCrown', ((16+i*2)*scale, (7+i%2*2)*scale, (12+i)*scale),
                 (x+dx, y+3*scale, z+dz), ['leafDark','leaf','leafLight'][i],
                 (8*i, math.degrees(theta), 15-i*14), 'Ball', 'Grass')
            if i != 1:
                part('OakCrown', (11*scale, 7*scale, 10*scale),
                     (x+dx*1.6,y+5*scale,z+dz*.9),['leaf','leafLight'][i//2],
                     (-12,math.degrees(theta)+30,19),'Ball','Grass')

    # Composed groves are intentionally asymmetric; no uniform random field/grid.
    groves = [('HearthGarden', -300, -872, 79, 84, 12), ('WestSpring', -350, -951, 60, 43, 7),
        ('ArrivalOrchard', -156, -745, 70, 29, 5), ('EastArrivalGrove', 254, -796, 130, 66, 13),
        ('ArtisanGrove', 330, -898, 90, 44, 8), ('WestWallGarden', -403, -1095, 21, 61, 4),
        ('EastWallGarden', 407, -1150, 23, 60, 4), ('CouncilGarden', -340, -1375, 62, 115, 11),
        ('EastCommons', 346, -1396, 65, 120, 12), ('TowerWoodland', -160, -1530, 63, 53, 6),
        ('TowerEastWoodland', 169, -1552, 76, 44, 7), ('AvenuePocketWest', -49, -1280, 10, 70, 3),
        ('AvenuePocketEast', 47, -1328, 10, 73, 3)]
    for name, cx, cz, rx, rz, count in groves:
        group = name
        groups.append(dict(name=name, center=[cx, cz], radius=[rx, rz]))
        accepted = []
        for _ in range(count*12):
            if len(accepted) >= count: break
            t, r = rng.uniform(0, math.tau), math.sqrt(rng.random())
            x, z = cx+math.cos(t)*rx*r, cz+math.sin(t)*rz*r
            scale = rng.uniform(.72, 1.48)
            radius = 17*scale
            if any(math.hypot(x-a, z-b) < 22 for a, b in accepted): continue
            if x-radius < -438 or x+radius > 438 or z-radius < -1614 or z+radius > -707: continue
            if any(x-radius < q['bounds'][2] and x+radius > q['bounds'][0] and z-radius < q['bounds'][3] and z+radius > q['bounds'][1] for q in forbidden): continue
            accepted.append((x, z));tree(x, z, scale, rng.uniform(0, math.tau))
            # Flat moss/earth islands tie each trunk into the ground rather than floating.
            part('RootBed', (18*scale, .12, 13*scale), (x, .35, z), 'grass', (0, rng.uniform(0, 180), 0), 'Ball', 'Grass')
        for _ in range(count*5):
            t, r = rng.uniform(0, math.tau), math.sqrt(rng.random())
            x, z = cx+math.cos(t)*rx*r, cz+math.sin(t)*rz*r
            s = rng.uniform(2, 4.5)
            part('Understory', (s*2, s*.8, s*1.3), (x, .3+s*.27, z), rng.choice(['leaf','sage','grass']),
                 (0, rng.uniform(0, 180), 0), 'Ball', 'Grass')
            if rng.random() < .55:
                part('Wildflowers', (.9, 1.5, .9), (x+1, .95, z-.5), rng.choice(['flower','cream']), (9, 0, 14), 'Ball')
        for _ in range(max(3, count//2)):
            x, z = cx+rng.uniform(-rx, rx), cz+rng.uniform(-rz, rz)
            s = rng.uniform(3, 6)
            part('WeatheredRock', (s*1.7, s*.8, s), (x, s*.22, z), rng.choice(['rock','rockDark']),
                 (rng.uniform(-12,12), rng.uniform(0,180), rng.uniform(-15,15)), 'Ball', 'Slate', True)

    # Solid native ellipsoids introduce low relief without changing shared Terrain.
    group = 'PerimeterBerms'
    for x,z,sx,sz,h in [(-400,-800,60,96,5),(-410,-1470,46,115,7),
                        (401,-800,58,100,5),(402,-1480,51,112,6),
                        (-330,-1570,95,59,5),(320,-1577,100,54,6)]:
        part('GrassyBerm',(sx,h*2,sz),(x,.3,z),'grass',shape='Ball',material='Grass',solid=True)
    # Spring pocket: a calm shallow ornamental basin; no swim/currency interactions.
    group = 'HearthSpring'
    for i, (x, z, sx, sz) in enumerate([(-349,-920,48,36),(-365,-912,25,25)]):
        part('SpringBed', (sx+4, .5, sz+4), (x,.38,z), 'rockDark', shape='Ball', material='Slate')
        part('SpringWater', (sx,.25,sz), (x,.65+i*.025,z), 'water', shape='Ball', material='SmoothPlastic')
    for i in range(18):
        t = i*math.tau/18
        x,z=-349+math.cos(t)*(25+rng.uniform(-1,2)),-920+math.sin(t)*(19+rng.uniform(-1,2))
        if math.hypot(x+322,z+914)>10:
            part('SpringBank', (rng.uniform(3,7), rng.uniform(1,2.4), rng.uniform(2,4)), (x,.8,z),
                 'rock', (5, math.degrees(t), 9), 'Ball', 'Slate')
        for j in range(2):
            radius=28+j*4+rng.uniform(-2,3)
            x,z=-349+math.cos(t)*radius,-920+math.sin(t)*radius*.78
            if math.hypot(x+322,z+914)>12:
                part('WatersidePlant',(rng.uniform(2,4),rng.uniform(1.6,2.4),2.8),(x,1.1,z),'sage',(0,i*21,0),'Ball','Grass')
    # Curved stepping route connects tavern's west garden edge to the spring.
    for i in range(22):
        t = i/21
        x, z = -224-98*t-5*math.sin(t*math.pi), -854-60*t
        yaw=math.degrees(math.atan2(-98-5*math.pi*math.cos(t*math.pi),-60))
        part('GardenFlagstone', (rng.uniform(6.7,8.2), .16, 3.8), (x,.41,z), 'path', (0, yaw+rng.uniform(-4,4), 0), 'Block', 'Cobblestone')
    return dict(schema=1, seed=16062026, units='stud', upAxis='Y', provenance='Original procedural geometry',
                runtimeAssetIds=[], studioTested=False, groups=groups, exclusions=forbidden, parts=parts)


def luau_source(data):
    lines = ['--!strict', '-- Generated by tools/build_city_landscape.py; do not hand-edit.',
             'export type Detail={group:string,name:string,shape:string,size:{number},position:{number},rotation:{number},color:{number},material:string,solid:boolean}',
             'local parts:{Detail}={']
    for p in data['parts']:
        fields=[]
        for k,v in p.items():
            value = '{'+','.join(map(str,v))+'}' if isinstance(v,list) else (str(v).lower() if isinstance(v,bool) else json.dumps(v))
            fields.append(k+'='+value)
        lines.append('{'+','.join(fields)+'},')
    lines += ['}', 'return parts']
    return '\n'.join(lines)+'\n'


def write_recipe():
    data = make_recipe()
    if len(data['parts']) > 1800:
        raise ValueError('Central landscape exceeds its 1800-native-part authoring budget')
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT/'landscape.json').write_text(json.dumps(data, indent=2)+'\n', encoding='utf-8', newline='\n')
    (ROOT/'src/server/Services/CityLandscapeData.luau').write_text(luau_source(data), encoding='utf-8', newline='\n')
    print('CITY_LANDSCAPE_GENERATED', len(data['parts']), 'native parts')


if __name__ == '__main__':
    write_recipe()
