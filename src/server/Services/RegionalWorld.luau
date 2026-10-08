--!strict
-- Traversal connection; encounter authority and rewards are a separate integration.
local MapKit=require(script.Parent.AdventureMapKit)
local Kit=require(script.Parent.ArtKit)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
local Content=require(script.Parent.Parent.Config.Content)
local City=require(game.ReplicatedStorage.Shared.Config.City)
local V=Vector3.new
return function(parent:Instance,town:Instance,intent:any,templates:Folder):any
    local maps=MapKit();local regions={}
    local function portal(container:Instance,name:string,position:Vector3,destination:string):Part
        for _,x in ipairs({-5,5}) do Kit.Part(container,"RegionalGatePost",V(1,10,1.5),position+V(x,0,0),Color3.fromRGB(104,79,54),Enum.Material.Wood,true) end
        Kit.Part(container,"RegionalGateLintel",V(11,1,1.5),position+V(0,5,0),Color3.fromRGB(163,143,88),Enum.Material.Wood,true)
        local anchor=Kit.Part(container,name,V(8,9,.3),position,Color3.fromRGB(110,185,132),Enum.Material.Neon,false)
        anchor.Transparency=.8;anchor.CanQuery=false;anchor.CanTouch=false;anchor:SetAttribute("TravelDestination",destination)
        game:GetService("CollectionService"):AddTag(anchor,"GuildborneTravelPortal")
        Kit.Label(anchor,name,Locale.translate("th",name),5)
        local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Travel / เดินทาง";prompt.ObjectText=name.." / "..Locale.translate("th",name)
        prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=anchor
        prompt.Triggered:Connect(function(player)
            local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and root:IsA("BasePart") and (root.Position-anchor.Position).Magnitude<=14 then intent(player,"TravelZone",{zone=destination}) end
        end)
        return anchor
    end
    for _,regionId in ipairs(City.RegionOrder) do
    local worldDef=City.Regions[regionId];local landing=City.Destinations[regionId]
    local model=maps:FindFirstChild(regionId) :: Model;model.Parent=parent;model:PivotTo(CFrame.new(worldDef.X,0,worldDef.Z))
    model:SetAttribute("TraversalEnabled",true)
    local entry=portal(town,regionId,V(0,5.5,worldDef.CityGateZ),regionId)
    local exit=portal(model,"Central City",V(landing.X,7,landing.Z+12),"City")
    local spawn=Instance.new("SpawnLocation");spawn.Name=landing.Spawn;spawn.Size=V(6,1,6);spawn.Position=V(landing.X,2.5,landing.Z)
    spawn.Anchored=true;spawn.Transparency=1;spawn.CanCollide=false;spawn.CanTouch=false;spawn.CanQuery=false
    spawn.Neutral=true;spawn.Enabled=false;spawn.Duration=0;spawn.Parent=model
    local nodes={}
    for id,def in pairs(Rules.Nodes) do if def.Region==regionId then
        local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={model};ray.RespectCanCollide=true
        local hit=workspace:Raycast(V(worldDef.X+def.X,100,worldDef.Z+def.Z),V(0,-150,0),ray);assert(hit,"Regional resource needs ground")
        local position=hit.Position
        local anchor=Kit.Part(model,"Resource_"..id,V(2,2,2),position+V(0,2,0),Color3.fromRGB(102,161,104),Enum.Material.Grass,false)
        anchor.Transparency=1;anchor.CanQuery=false;anchor.CanTouch=false;anchor:SetAttribute("ResourceNodeId",id);nodes[id]=anchor
        if def.Item=="timber" then
            local logs=(templates:FindFirstChild("TimberLogs") :: Model):Clone();logs.Name="RegionalTimber";logs:PivotTo(CFrame.new(position));logs.Parent=model
        elseif def.Item=="stone" or def.Item=="iron_ore" then
            local rock=(templates:FindFirstChild(if def.Item=="stone" then "RockA" else "IronOreNode") :: Model):Clone()
            rock.Name="RegionalResourceArt";rock:PivotTo(CFrame.new(position));rock.Parent=model
        else
            for i=0,4 do
                local angle=i*math.pi*2/5
                local leaf=Kit.Part(model,"HerbLeaf",V(.8,.2,2),position+V(math.sin(angle),.5,math.cos(angle)),Color3.fromRGB(87,162,101),Enum.Material.Grass,false)
                leaf.CFrame*=CFrame.Angles(0,angle,math.rad(20));leaf.CanQuery=false;leaf.CanTouch=false
            end
        end
        local name=Content.Items[def.Item].Name;Kit.Label(anchor,name,Locale.translate("th",name),3)
        local prompt=Instance.new("ProximityPrompt");prompt.Name="Gather";prompt.ActionText="Gather / เก็บ";prompt.ObjectText=name.." / "..Locale.translate("th",name)
        prompt.HoldDuration=.5;prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false;prompt.Parent=anchor
        prompt.Triggered:Connect(function(player)intent(player,"GatherResource",{nodeId=id})end)
    end end
    regions[regionId]={model=model,spawn=spawn,entry=entry,exit=exit,nodes=nodes}
    end
    maps:Destroy();return regions
end
