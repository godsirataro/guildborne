--!strict
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local world=workspace.GuildborneWorld
    local city=require(game.ReplicatedStorage.Shared.Config.City)
    local encounters=require(game.ServerScriptService.Server.Config.AdventureEncounters)
    local checks=0;local paths=0;local nodes=0
    local function check(ok:boolean,message:string?)assert(ok,message or ("Regional traversal "..checks));checks+=1 end
    for _,id in ipairs(city.RegionOrder) do
        local model=world:FindFirstChild(id) :: Model;local d=city.Destinations[id]
        check(model:GetAttribute("TraversalEnabled")==true and type(model:GetAttribute("EncountersEnabled"))=="boolean")
        local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={model};ray.RespectCanCollide=true
        local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={model};overlap.RespectCanCollide=true
        for _,z in ipairs({d.Z,d.FallbackZ,d.Z+7}) do
            local p=Vector3.new(d.X,d.Y,z);local hit=workspace:Raycast(p,Vector3.new(0,-12,0),ray)
            check(hit~=nil and math.abs(hit.Position.Y-d.GroundY)<.2,id.." landing ground")
            check(#workspace:GetPartBoundsInBox(CFrame.new(p),Vector3.new(4,5,4),overlap)==0,id.." landing clearance")
        end
        local spawn=model:FindFirstChild(d.Spawn) :: SpawnLocation
        check(not spawn.Enabled and not spawn.CanCollide)
        local targets={};local markers=model:FindFirstChild("EncounterMarkers") :: Folder
        for _,encounter in ipairs(encounters.Regions[id].Encounters) do
            local marker=markers:FindFirstChild(encounter.Marker) :: BasePart;table.insert(targets,{name=marker.Name,position=marker.Position+Vector3.yAxis})
        end
        for _,node in ipairs(model:GetDescendants()) do if node:IsA("BasePart") and node:GetAttribute("ResourceNodeId") then
            nodes+=1;check(node:FindFirstChildOfClass("ProximityPrompt")~=nil)
            -- Approach from the open side, not through the resource art itself.
            table.insert(targets,{name=node.Name,position=node.Position+Vector3.new(0,1,5)})
        end end
        for _,target in ipairs(targets) do
            local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=4})
            path:ComputeAsync(Vector3.new(d.X,3,d.Z),target.position)
            check(path.Status==Enum.PathStatus.Success,id.." path "..target.name)
            for _,waypoint in ipairs(path:GetWaypoints()) do check(waypoint.Action~=Enum.PathWaypointAction.Jump) end
            paths+=1
        end
    end
    check(nodes==6)
    return {checks=checks,paths=paths,nodes=nodes,regions=3,readOnly=true,profileWrites=0}
end
