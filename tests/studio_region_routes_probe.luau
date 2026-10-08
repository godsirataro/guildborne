--!strict
-- Isolated geometry probe. Does not move players, spawn enemies or award anything.
return function(): any
    local source=game.ServerScriptService.Server.Services.AdventureMapKit:Clone();source.Parent=game.ServerScriptService.Server.Services
    local factory=(require :: any)(source);source:Destroy()
    local kit=factory();kit.Name="RegionRoutesProbe";kit.Parent=workspace
    local ok,result=pcall(function(): any
        local reports={};local total=0
        for _,entry in ipairs(kit:GetChildren()) do
            local model=entry :: Model
            local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={model};ray.RespectCanCollide=true
            local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={model};overlap.RespectCanCollide=true
            local samples=0;local maxSlope=0
            local routes=model:FindFirstChild("ReviewRoutes") :: Folder
            for _,path in ipairs(routes:GetChildren()) do
                local points=path:GetChildren();table.sort(points,function(a,b) return (tonumber(a.Name) or 0)<(tonumber(b.Name) or 0) end)
                for i=1,#points-1 do
                    local a=(points[i] :: Vector3Value).Value;local b=(points[i+1] :: Vector3Value).Value
                    local steps=math.ceil((b-a).Magnitude/2)
                    for step=0,steps do
                        local pos=a:Lerp(b,step/steps)
                        for _,side in ipairs({-2,0,2}) do
                            local offset=Vector3.new(side,0,0)
                            local hit=workspace:Raycast(pos+offset+Vector3.new(0,15,0),Vector3.new(0,-30,0),ray)
                            assert(hit,model.Name.."/"..path.Name.." missing floor")
                            assert(math.abs(hit.Position.Y-pos.Y)<0.2,model.Name.."/"..path.Name.." floor mismatch at "..tostring(pos).." hit "..tostring(hit.Position))
                            local slope=math.deg(math.acos(math.clamp(hit.Normal.Y,-1,1)));maxSlope=math.max(maxSlope,slope)
                            assert(slope<=20,"steep ramp")
                            local blockers=workspace:GetPartBoundsInBox(CFrame.new(hit.Position+Vector3.new(0,3.1,0)),Vector3.new(1,5,1),overlap)
                            -- Wedge bounding boxes include air above their slope; floor ray already validates the surface.
                            for _,block in ipairs(blockers) do assert(block:IsA("WedgePart"),model.Name.." obstructed by "..block.Name) end
                            samples+=1
                        end
                    end
                end
            end
            local markers=model:FindFirstChild("EncounterMarkers") :: Folder
            for _,entry in ipairs(markers:GetChildren()) do
                local marker=entry :: BasePart
                local hit=workspace:Raycast(marker.Position+Vector3.new(0,15,0),Vector3.new(0,-30,0),ray)
                assert(hit and math.abs(hit.Position.Y-marker.Position.Y)<0.2,"marker floor "..marker.Name)
                local blockers=workspace:GetPartBoundsInBox(CFrame.new(marker.Position+Vector3.new(0,3.5,0)),Vector3.new(8,6,8),overlap)
                assert(#blockers==0,"marker clearance "..marker.Name)
            end
            table.insert(reports,{region=model.Name,samples=samples,maxSlope=maxSlope,routes=#routes:GetChildren(),markers=#markers:GetChildren()});total+=samples
        end
        return {regions=reports,totalSamples=total,liveBindings=false}
    end)
    kit:Destroy();assert(ok,tostring(result));return result
end
