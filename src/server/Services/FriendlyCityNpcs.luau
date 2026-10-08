--!strict
local Shared=game:GetService("ReplicatedStorage").Shared
local entries=require(Shared.Config.FriendlyNpcs)
local build=require(script.Parent.FriendlyNpcKit)
local Kit=require(script.Parent.ArtKit)
return function(town:Instance,open:(Player,string)->(),prompt:(BasePart,string,(Player)->())->())
    local folder=build(true);folder.Name="FriendlyOrcs";folder.Parent=town
    local civic=require(script.Parent.CityCharacterKit)(true)
    for _,model in ipairs(civic:GetChildren())do model.Parent=folder end
    civic:Destroy()
    local roots:{[string]:BasePart}={}
    for _,model in ipairs(folder:GetChildren()) do
        if not model:IsA("Model") then continue end
        local id=model.Name;local entry=entries[id];local root=model.PrimaryPart
        if not entry or not root then continue end
        -- Kit geometry starts at ground zero, while its root sits above the feet.
        model:PivotTo(CFrame.new(entry.x,1+root.Position.Y,entry.z))
        model:SetAttribute("NpcId",id);model:SetAttribute("CityAmbience",true)
        if entry.homeCity then
            model:SetAttribute("HomeCity",entry.homeCity)
            local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={town};ray.RespectCanCollide=true
            local ground=workspace:Raycast(root.Position+Vector3.new(0,40,0),Vector3.new(0,-80,0),ray)
            local at=Vector3.new(entry.x,if ground then ground.Position.Y else 1,entry.z)
            model:PivotTo(CFrame.lookAt(at,Vector3.new(0,at.Y,entry.z)))
        end
        local label=Kit.Label(root,entry.name.." · "..entry.role,entry.nameTh.." · "..entry.roleTh,5)
        local billboard=label.Parent :: BillboardGui;billboard.Size=UDim2.fromOffset(240,70)
        prompt(root,"Talk",function(player)
            model:SetAttribute("GreetingAt",workspace:GetServerTimeNow())
            open(player,"FriendlyNPC:"..id)
        end)
        local talk=root:FindFirstChildOfClass("ProximityPrompt")
        if talk then talk.ObjectText=entry.name.." / "..entry.nameTh end
        root:SetAttribute("QuestNPC",entry.name);roots[entry.name]=root
        game:GetService("CollectionService"):AddTag(root,"GuildborneQuestNPC")
        game:GetService("CollectionService"):AddTag(model,"GuildborneFriendlyNPC")
    end
    return roots
end
