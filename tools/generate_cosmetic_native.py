"""Native review models only; no purchase or equip authorization lives here."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1];d=json.loads((ROOT/'assets/uat01/cosmetic-kit/kit.json').read_text());v=lambda x:'Vector3.new('+','.join(map(str,x))+')'
lines=['--!strict','-- Original cosmetic preview art; no live entitlements, purchases or stat modifiers.','return function(onlyId: string?): Folder','local folder=Instance.new("Folder");folder.Name="CosmeticVisualKit"']
for a in d['assets']:
    lines+=['if onlyId==nil or onlyId=="'+a['id']+'" then local m=Instance.new("Model");m.Name="'+a['id']+'";m.WorldPivot=CFrame.identity;m:SetAttribute("Category","'+a['kind']+'");m:SetAttribute("EntitlementBound",false);m.Parent=folder']
    for p in a['parts']:
        lines+=['do local p=Instance.new("Part");p.Name="'+p['name']+'";p.Size='+v(p['size'])+';p.CFrame=CFrame.new('+v(p['position'])+')*CFrame.Angles('+','.join('math.rad('+str(x)+')' for x in p['rotation'])+');p.Color=Color3.fromRGB('+','.join(map(str,d['palette'][p['color']]))+');p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Parent=m end']
    lines+=['end']
lines+=['return folder','end'];(ROOT/'src/shared/Data/CosmeticVisuals.luau').write_text('\n'.join(lines)+'\n',encoding='utf-8')
(ROOT/'src/server/Services/CosmeticVisualKit.luau').write_text('--!strict\nreturn require(game.ReplicatedStorage.Shared.Data.CosmeticVisuals)\n',encoding='utf-8');print('COSMETIC_NATIVE',len(d['assets']))
