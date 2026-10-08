--!strict
-- Server Play only: a neutral test R15 walks each authored path. No player/profile interaction.
return function(): any
    local Players=game:GetService("Players")
    local kit=require(game.ServerScriptService.Server.Services.AdventureMapKit)()
    kit.Name="RegionWalkProbe";kit.Parent=workspace
    local dummy:Model?=nil
    local ok,result=pcall(function(): any
        local description=Instance.new("HumanoidDescription")
        local avatar=Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
        description:Destroy();dummy=avatar;avatar.Name="RegionWalker";avatar.Parent=kit
        local humanoid=avatar:FindFirstChildOfClass("Humanoid") :: Humanoid
        local root=avatar:FindFirstChild("HumanoidRootPart") :: BasePart
        root:SetNetworkOwner(nil);humanoid.WalkSpeed=24;humanoid.AutoJumpEnabled=false
        local reports={};local distance=0
        for index,entry in ipairs(kit:GetChildren()) do
            if entry==avatar then continue end
            local model=entry :: Model;local offset=Vector3.new(8000+index*350,100,0);model:PivotTo(CFrame.new(offset))
            local routes=model:FindFirstChild("ReviewRoutes") :: Folder
            for _,path in ipairs(routes:GetChildren()) do
                local points=path:GetChildren();table.sort(points,function(a,b) return (tonumber(a.Name) or 0)<(tonumber(b.Name) or 0) end)
                local first=(points[1] :: Vector3Value).Value+offset
                avatar:PivotTo(CFrame.new(first+Vector3.new(0,4,0)));root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;task.wait(.5)
                for i=2,#points do
                    local target=(points[i] :: Vector3Value).Value+offset
                    local start=root.Position;humanoid:MoveTo(target)
                    local deadline=os.clock()+12
                    repeat
                        task.wait(.1)
                        assert(humanoid.Health>0,"walker died")
                        assert(root.Position.Y>offset.Y-5,"walker fell")
                    until (Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(target.X,0,target.Z)).Magnitude<2.5 or os.clock()>deadline
                    assert(os.clock()<=deadline,model.Name.."/"..path.Name.." stuck segment "..i.." at "..tostring(root.Position-offset))
                    distance+=(target-start).Magnitude
                end
                table.insert(reports,{region=model.Name,route=path.Name,passed=true})
                kit:SetAttribute("RoutesCompleted",#reports)
            end
        end
        return {routes=reports,walkSpeed=24,approxDistance=distance,standardR15=true,playerInteraction=false}
    end)
    if dummy then dummy:Destroy() end;kit:Destroy();assert(ok,tostring(result));return result
end
