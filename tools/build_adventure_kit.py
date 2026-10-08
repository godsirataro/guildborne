"""Original low-poly prop definitions shared by Blender and native Roblox.

Coordinates are Roblox studs, Y-up. No downloaded meshes, textures or scripts.
Run with Python to write the deterministic JSON and Luau source.
"""
from pathlib import Path
import json
import math

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/uat01/adventure-kit'
PALETTE = {
    'wood': [91, 58, 43], 'timber': [157, 110, 65],
    'stone': [100, 116, 127], 'slate': [64, 75, 101],
    'gold': [217, 170, 77], 'cloth': [113, 43, 66],
    'paper': [238, 220, 174], 'leaf': [55, 112, 78],
    'mint': [93, 160, 102], 'cyan': [88, 211, 215],
    'iron': [161, 180, 190], 'ember': [244, 117, 59],
}
assets = []

def asset(name, region, purpose):
    entry = dict(id=name, region=region, purpose=purpose, parts=[])
    assets.append(entry)
    return entry['parts']

def box(parts, name, size, at, color, rz=0, ry=0):
    parts.append(dict(name=name, size=size, position=at, color=color,
                      rotation=[0, ry, rz], shape='Block'))

p = asset('GreenwoodWaystone', 'Greenwood', 'Route landmark; no travel entitlement')
box(p, 'Foot', [3.8,.6,3], [0,.3,0], 'stone')
box(p, 'Shaft', [2,5,1.6], [0,3,0], 'stone', -6)
box(p, 'Cap', [2.8,.5,2], [-.25,5.5,0], 'slate')
box(p, 'Crest', [1.2,1.2,.2], [0,3.8,.9], 'gold', 45)
box(p, 'Rune', [.22,2.1,.22], [0,3.6,1.04], 'cyan')
for x,z in [(-1.6,.8),(1.2,-.7)]:
    box(p, 'Moss', [1,.3,1.1], [x,.68,z], 'leaf', 0, 25)

p = asset('GreenwoodSupplyCache', 'Greenwood', 'Quest supplies; reward handled separately')
box(p, 'Body', [3,2.2,2.4], [0,1.1,0], 'timber')
box(p, 'Lid', [3.2,.35,2.6], [0,2.35,0], 'wood')
for x in [-1.05,1.05]:
    box(p, 'Strap', [.22,2.5,2.65], [x,1.25,0], 'gold')
box(p, 'Seal', [.8,.8,.15], [0,1.45,1.3], 'paper', 45)

p = asset('GreenwoodFern', 'Greenwood', 'Low-cost vegetation cluster')
box(p, 'Soil', [1.4,.2,1.4], [0,.1,0], 'wood')
for i in range(6):
    a = i*math.pi/3
    box(p, 'Leaf', [.55,2.1,.25], [math.cos(a)*.55,1,math.sin(a)*.55],
        'leaf' if i%2 else 'mint', 25, i*60)

p = asset('IronveilOreCart', 'Ironveil', 'Quarry landmark; stationary')
box(p, 'Floor', [3.4,.35,4.4], [0,1.3,0], 'wood')
for x in [-1.65,1.65]:
    box(p, 'Side', [.22,1.8,4.4], [x,2.1,0], 'timber')
    for z in [-1.5,1.5]:
        box(p, 'Wheel', [.45,1.1,1.1], [x*1.14,.7,z], 'slate', 0, 0)
for z in [-2.1,2.1]:
    box(p, 'End', [3.4,1.8,.22], [0,2.1,z], 'timber')
for i in range(3):
    box(p, 'Ore', [1.2,1.2,1.3], [(i-1)*.8,2.8,(i%2)*1.2-.6], 'iron', 20, i*35)

p = asset('IronveilCrystalCluster', 'Ironveil', 'Ore silhouette; no automatic resource rewards')
box(p, 'Rock', [4,1,3.2], [0,.5,0], 'slate', 0, 12)
for x,h,r in [(-1,2.3,-20),(0,4,0),(1.1,2.8,22)]:
    box(p, 'Crystal', [.65,h,.65], [x,1+h/2,0], 'gold', r, 45)
    box(p, 'CrystalTip', [.65,.65,.65], [x,1+h,0], 'paper', 45, 45)

p = asset('IronveilForge', 'Ironveil', 'Crafting-station visual; existing server craft rules remain authoritative')
box(p, 'Hearth', [4,1.8,3.6], [0,.9,0], 'stone')
box(p, 'Coal', [2.7,.2,2.3], [0,1.85,0], 'slate')
for x in [-.7,0,.7]:
    box(p, 'Embers', [.5,.15,1.5], [x,1.98,0], 'ember')
box(p, 'Chimney', [1.5,4.2,1.3], [0,3.6,-1.7], 'slate')
box(p, 'AnvilBase', [2.2,.4,1.8], [3,.2,0], 'slate')
box(p, 'AnvilStem', [.8,1.1,1], [3,.9,0], 'iron')
box(p, 'AnvilTop', [3,.55,1.4], [3,1.65,0], 'iron')

p = asset('AshenRunePillar', 'Ashen', 'Readable ruins landmark')
box(p, 'Base', [3.8,.6,3.8], [0,.3,0], 'slate')
box(p, 'Column', [2.2,7,2.2], [0,4.1,0], 'stone')
box(p, 'Capital', [3.2,.6,3.2], [0,7.9,0], 'slate')
for y in [2.4,4,5.6]:
    box(p, 'RuneDiamond', [.8,.8,.15], [0,y,1.18], 'cyan',45)
box(p, 'Fracture', [2.3,.15,2.3], [0,6.5,0], 'slate', -5)

p = asset('AshenShrine', 'Ashen', 'Boss-arena centerpiece; no boss logic implied')
for i in range(3):
    box(p, 'Step', [6-i*1.2,.55,6-i*1.2], [0,.275+i*.55,0], 'slate',0,i*15)
box(p, 'Core', [1.5,1.5,1.5], [0,3.1,0], 'cyan',45,45)
for x in [-2.3,2.3]:
    box(p, 'Arm', [.55,3.2,.55], [x,2,0], 'stone',x*8)
    box(p, 'Sigil', [.7,.7,.7], [x,3.8,0], 'gold',45,45)

p = asset('AdventurerQuestBoard', 'Shared', 'Quest station frame; notices have no baked text')
for x in [-2.9,2.9]:
    box(p, 'Post', [.45,7,.45], [x,3.5,0], 'wood')
box(p, 'Board', [6,3.5,.35], [0,4.6,0], 'timber')
for x in [-1.8,0,1.8]:
    box(p, 'Notice', [1.35,2.2,.1], [x,4.6,.25], 'paper',x*3)
    box(p, 'Pin', [.2,.2,.12], [x,5.5,.34], 'gold',45)
box(p, 'Awning', [7,.35,2], [0,6.9,0], 'cloth')
box(p, 'Crest', [1,1,.2], [0,7.2,1.05], 'gold',45)

p = asset('HarborMarketStall', 'Shared', 'Market visual; no commerce enablement')
for x in [-3,3]:
    for z in [-2,2]:
        box(p, 'Post', [.35,6.8,.35], [x,3.4,z], 'wood')
box(p, 'Counter', [6.6,.45,2.4], [0,2.6,1], 'timber')
box(p, 'Front', [6,2.1,.2], [0,1.35,2.15], 'wood')
for i in range(5):
    box(p, 'Canopy', [1.35,.35,5], [(i-2)*1.35,6.8,0], 'cloth' if i%2 else 'paper')
for x in [-1.8,0,1.8]:
    box(p, 'Goods', [1.2,.7,1.1], [x,3.2,1], 'gold' if x==0 else 'mint')

OUT.mkdir(parents=True, exist_ok=True)
data = dict(version=1, units='stud', upAxis='Y', palette=PALETTE, assets=assets)
(OUT/'kit.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')

def vec(values):
    return 'V('+','.join(str(round(v,5)) for v in values)+')'

lines = ['--!strict', '-- Generated by tools/build_adventure_kit.py; edit definitions there.',
         'local V = Vector3.new', 'return function(): Folder',
         '\tlocal folder = Instance.new("Folder"); folder.Name = "AdventurePropKit"']
for a in assets:
    lines += ['\tdo', '\t\tlocal m = Instance.new("Model")',
              f'\t\tm.Name = "{a["id"]}"; m.WorldPivot = CFrame.identity; m.Parent = folder',
              f'\t\tm:SetAttribute("Region", "{a["region"]}"); m:SetAttribute("DecorativeOnly", true)',
              f'\t\tm:SetAttribute("AssetVersion", 1); m:SetAttribute("PartCount", {len(a["parts"])})']
    for p in a['parts']:
        rgb = ','.join(map(str, PALETTE[p['color']]))
        r = ','.join(f'math.rad({v})' for v in p['rotation'])
        lines += ['\t\tdo local p = Instance.new("Part")',
                  f'\t\t\tp.Name = "{p["name"]}"; p.Size = {vec(p["size"])}',
                  f'\t\t\tp.CFrame = CFrame.new({vec(p["position"])}) * CFrame.Angles({r})',
                  f'\t\t\tp.Color = Color3.fromRGB({rgb}); p.Material = Enum.Material.SmoothPlastic',
                  '\t\t\tp.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false',
                  '\t\t\tp.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth; p.Parent = m end']
    lines += ['\tend']
lines += ['\treturn folder','end','']
(ROOT/'src/server/Services/AdventurePropKit.luau').write_text('\n'.join(lines),encoding='utf-8')
print(json.dumps({'assets': len(assets), 'parts': sum(len(a['parts']) for a in assets)}))
