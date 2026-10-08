--!strict
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local region=workspace.GuildborneWorld:FindFirstChild("Greenwood") :: Model
    local nodes={};for _,p in ipairs(region:GetDescendants()) do if p:IsA("BasePart") and p:GetAttribute("ResourceNodeId") then nodes[p:GetAttribute("ResourceNodeId")]=p end end
    local character=Instance.new("Model");character.Name="GreenwoodGatherProbe";character.Parent=workspace
    local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Anchored=true;root.Parent=character
    local humanoid=Instance.new("Humanoid");humanoid.RequiresNeck=false;humanoid.Parent=character
    local zone="Greenwood";local player:any={Character=character,GetAttribute=function()return zone end}
    local plot={nodes=nodes,model=character};local checks=0
    local function check(ok:boolean)assert(ok,"Regional gather "..checks);checks+=1 end
    local ok,problem=pcall(function()
        local service=require(game.ServerScriptService.Server.Services.ExpansionWorld)(function()error("Unexpected UI")end,function()error("Unexpected intent")end)
        for _,id in ipairs({"greenwood_wood","greenwood_herbs"}) do
            local node:BasePart?=nodes[id];check(node~=nil);assert(node);check(node:FindFirstChildOfClass("ProximityPrompt")~=nil)
            root.Position=node.Position+Vector3.new(0,1,4)
            check(service.validate(player,plot,"GatherResource",{nodeId=id})==nil)
            zone="Guild";check(service.validate(player,plot,"GatherResource",{nodeId=id})=="ResourceTooFar");zone="Greenwood"
            root.Position+=Vector3.new(30,0,0);check(service.validate(player,plot,"GatherResource",{nodeId=id})=="ResourceTooFar")
        end
        root.Position=nodes.greenwood_wood.Position;character:SetAttribute("CombatHealth",0)
        check(service.validate(player,plot,"GatherResource",{nodeId="greenwood_wood"})=="Downed")
        character:SetAttribute("CombatHealth",100);humanoid.Health=0
        check(service.validate(player,plot,"GatherResource",{nodeId="greenwood_wood"})=="ActorNotReady")
    end)
    character:Destroy();if not ok then error(tostring(problem)) end
    return {checks=checks,nodes=2,profileWrites=0,fixtureDestroyed=true}
end
