--!strict
return function(make:any,makeLandmarks:any):any
    local folder=make(makeLandmarks);folder.Name="CityDistrictFixture";folder.Parent=workspace
    local routes={};local parts=0
    local ok,result=pcall(function():any
        for index,entry in ipairs(folder:GetChildren()) do
            local model=entry :: Model;model:PivotTo(CFrame.new(5000+index*280,0,5000))
            local arrival=model:FindFirstChild("Arrival") :: BasePart;assert(arrival)
            for _,p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") then assert(p.Anchored and not p.CanTouch);parts+=1 end
            end
            task.wait(.15)
            for _,id in ipairs({"Market","Forge","Tavern","QuestHall","Landmark","GuildIslandPortal","RegionalGate","Plaza"}) do
                local marker=model:FindFirstChild(id) :: BasePart;assert(marker,id)
                local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
                path:ComputeAsync(arrival.Position,marker.Position)
                assert(path.Status==Enum.PathStatus.Success,model.Name.." blocked route "..id)
                local waypoints=path:GetWaypoints();assert(#waypoints>1)
                local length=0;for i=2,#waypoints do length+=(waypoints[i].Position-waypoints[i-1].Position).Magnitude end
                assert(length<300,model.Name.." indirect route "..id)
                table.insert(routes,{city=model.Name,destination=id,studs=math.round(length),waypoints=#waypoints})
                path:Destroy()
            end
        end
        return {cities=6,parts=parts,routes=routes,routeCount=#routes,agentRadius=2,agentHeight=5,jumping=false,synthetic=true,actualPlayerTraversal=false,profileWrites=0}
    end)
    folder:Destroy();assert(ok,tostring(result));return result
end
