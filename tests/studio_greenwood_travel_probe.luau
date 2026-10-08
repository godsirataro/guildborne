--!strict
-- Read-only geometry/portal checks on the live owned offline test scene.
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local world=workspace:FindFirstChild("GuildborneWorld") :: Folder
    local region=world:FindFirstChild("Greenwood") :: Model
    local city=world:FindFirstChild("City") :: Folder
    local checks=0;local paths=0
    local function check(ok:boolean)assert(ok,"Greenwood travel "..checks);checks+=1 end
    check(region:GetAttribute("TraversalEnabled")==true);check(region:GetAttribute("EncountersEnabled")==false)
    local entry:BasePart?=nil;local exit:BasePart?=nil
    for _,p in ipairs(city:GetDescendants()) do if p:IsA("BasePart") and p:GetAttribute("TravelDestination")=="Greenwood" then entry=p end end
    for _,p in ipairs(region:GetDescendants()) do if p:IsA("BasePart") and p:GetAttribute("TravelDestination")=="City" then exit=p end end
    check(entry~=nil and exit~=nil);assert(entry and exit)
    check(not entry.CanCollide and not exit.CanCollide)
    check(entry:FindFirstChildOfClass("ProximityPrompt")~=nil and exit:FindFirstChildOfClass("ProximityPrompt")~=nil)
    local spawn=region:FindFirstChild("GreenwoodSpawn") :: SpawnLocation?
    check(spawn~=nil and not spawn.Enabled and not spawn.CanCollide)
    local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={region};ray.RespectCanCollide=true
    local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={region};overlap.RespectCanCollide=true
    for _,z in ipairs({1505,1495,1512}) do
        local position=Vector3.new(0,7,z);local hit=workspace:Raycast(position,Vector3.new(0,-12,0),ray)
        check(hit~=nil and math.abs(hit.Position.Y-2)<.2)
        check(#workspace:GetPartBoundsInBox(CFrame.new(position),Vector3.new(4,5,4),overlap)==0)
    end
    local markers=region:FindFirstChild("EncounterMarkers") :: Folder
    for _,name in ipairs({"ScoutCamp","ArcherCamp","BoarTrail","ForestCaptain"}) do
        local target=markers:FindFirstChild(name) :: BasePart
        local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=4})
        path:ComputeAsync(Vector3.new(0,3,1505),target.Position+Vector3.new(0,1,0))
        check(path.Status==Enum.PathStatus.Success)
        for _,point in ipairs(path:GetWaypoints()) do check(point.Action~=Enum.PathWaypointAction.Jump) end
        paths+=1
    end
    return {checks=checks,paths=paths,profileWrites=0,readOnly=true}
end
