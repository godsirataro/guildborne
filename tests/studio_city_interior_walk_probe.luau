--!strict
-- Standard neutral R15 walks into and out of all five actual city interiors.
return function(): any
    local actors=Instance.new("Folder");actors.Name="CityInteriorWalkProbe";actors.Parent=workspace
    local ok,result=pcall(function():any
        local description=Instance.new("HumanoidDescription")
        local avatar=game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
        description:Destroy();avatar.Name="InteriorWalker";avatar.Parent=actors
        local humanoid=avatar:FindFirstChildOfClass("Humanoid") :: Humanoid
        local root=avatar:FindFirstChild("HumanoidRootPart") :: BasePart
        root:SetNetworkOwner(nil);humanoid.WalkSpeed=16;humanoid.AutoJumpEnabled=false
        local buildings={}
        for _,m in ipairs(workspace:GetDescendants()) do if m:IsA("Model") and m:FindFirstChild("Interior") then table.insert(buildings,m) end end
        assert(#buildings==5);local reports={}
        for _,m in ipairs(buildings) do
            avatar:PivotTo(m:GetPivot()*CFrame.new(0,4,27));root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;task.wait(.4)
            for _,z in ipairs({-5,27}) do
                local goal=m:GetPivot():PointToWorldSpace(Vector3.new(0,2,z));humanoid:MoveTo(goal)
                local deadline=os.clock()+7
                repeat task.wait(.1);assert(humanoid.Health>0 and root.Position.Y>-5,"walker fell/died")
                until (Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(goal.X,0,goal.Z)).Magnitude<2 or os.clock()>deadline
                assert(os.clock()<=deadline,"walker stuck: "..m.Name.."/"..z.." local="..tostring(m:GetPivot():PointToObjectSpace(root.Position)).." state="..humanoid:GetState().Name)
            end
            table.insert(reports,{building=m.Name,entered=true,exited=true})
        end
        return {routes=reports,standardR15=true,autoJump=false,walkSpeed=16,profileInteraction=false}
    end)
    actors:Destroy();assert(ok,tostring(result));return result
end
