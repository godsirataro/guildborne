"""Serialize original hero art and optional native Motor6D rigs from the shared kit."""
from pathlib import Path
import json
import argparse
parser=argparse.ArgumentParser()
parser.add_argument('--kit',default='assets/uat01/hero-kit')
parser.add_argument('--output',default='src/server/Services/HeroVisualKit.luau')
parser.add_argument('--folder',default='HeroVisualKit')
parser.add_argument('--friendly',action='store_true')
args=parser.parse_args()
assert args.folder.isidentifier()
ROOT=Path(__file__).resolve().parents[1];data=json.loads((ROOT/args.kit/'kit.json').read_text(encoding='utf-8'));P=data['palette'];assets=data['assets']
v=lambda xyz:'V('+','.join(str(x) for x in xyz)+')'
lines=['--!strict','-- Generated visual templates; no recruitment grants or stat/rarity advantage.','local V=Vector3.new',
'type Piece={name:string,size:Vector3,pos:Vector3,rotation:Vector3,color:Color3,bone:string}',
'type Bone={name:string,pos:Vector3,parent:string?}',
'type Asset={id:string,class:string,designId:string,bones:{Bone},parts:{Piece}}','local assets:{Asset}={']
for a in assets:
    identity_class=a.get('race',a['region']) if args.friendly else a['region']
    lines.append('{id="%s",class="%s",designId="%s",bones={'%(a['id'],identity_class,a['designId']))
    for b in a['bones']:lines.append('{name="%s",pos=%s,parent=%s},'%(b['name'],v(b['head']),json.dumps(b['parent']) if b['parent'] else 'nil'))
    lines.append('},parts={')
    for p in a['parts']:lines.append('{name="%s",size=%s,pos=%s,rotation=%s,color=Color3.fromRGB(%s),bone="%s"},'%(p['name'],v(p['size']),v(p['position']),v(p['rotation']),','.join(map(str,P[p['color']])),p['bone']))
    lines.append('}},')
lines.extend(['}', '''return function(rigged:boolean?,onlyId:string?): Folder
    local folder=Instance.new("Folder");folder.Name="HeroVisualKit"
    for _,asset in ipairs(assets) do
        if onlyId and asset.id~=onlyId then continue end
        local m=Instance.new("Model");m.Name=asset.id;m.WorldPivot=CFrame.identity
        m:SetAttribute("ClassId",asset.class);m:SetAttribute("DesignId",asset.designId);m:SetAttribute("RecruitmentBound",false)
        local bones:{[string]:BasePart}={}
        if rigged then
            local skeleton=Instance.new("Folder");skeleton.Name="Skeleton";skeleton.Parent=m
            for _,entry in ipairs(asset.bones) do
                local bone=Instance.new("Part");bone.Name=entry.name;bone.Size=V(.1,.1,.1);bone.CFrame=CFrame.new(entry.pos)
                bone.Transparency=1;bone.Anchored=entry.parent==nil;bone.Massless=true
                bone.CanCollide=false;bone.CanTouch=false;bone.CanQuery=false;bone.Parent=skeleton;bones[entry.name]=bone
                if entry.parent then
                    local parent=bones[entry.parent];assert(parent)
                    local motor=Instance.new("Motor6D");motor.Name=entry.name;motor.Part0=parent;motor.Part1=bone
                    motor.C0=parent.CFrame:ToObjectSpace(bone.CFrame);motor.C1=CFrame.identity;motor.Parent=parent
                else m.PrimaryPart=bone end
            end
        end
        for _,entry in ipairs(asset.parts) do
            local p=Instance.new("Part");p.Name=entry.name;p.Size=entry.size
            p.CFrame=CFrame.new(entry.pos)*CFrame.Angles(math.rad(entry.rotation.X),math.rad(entry.rotation.Y),math.rad(entry.rotation.Z))
            p.Color=entry.color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=not rigged;p.Massless=true
            p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p:SetAttribute("BindBone",entry.bone);p.Parent=m
            if rigged then
                local weld=Instance.new("WeldConstraint");weld.Part0=bones[entry.bone];weld.Part1=p;weld.Parent=p
            end
        end
        m.Parent=folder
    end
    return folder
end'''])
source='\n'.join(lines)+'\n'
source=source.replace('folder.Name="HeroVisualKit"','folder.Name="'+args.folder+'"')
if args.friendly:
    source=source.replace('m:SetAttribute("ClassId",asset.class)','m:SetAttribute("RaceId",asset.class);m:SetAttribute("FriendlyNPC",true)')
(ROOT/args.output).write_text(source,encoding='utf-8');print(args.folder,len(assets))
