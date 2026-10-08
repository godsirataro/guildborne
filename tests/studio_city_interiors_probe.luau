--!strict
-- Server Play: checks actual decorated buildings and a clear central entrance corridor.
return function(): any
    local expected={['Guild Administration']=true,['The Hearth and Banner']=true,['Guildborne Exchange']=true,Blacksmith=true,['Alchemy Shop']=true}
    local report={};local total=0
    for _,m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") and expected[m.Name] and m:FindFirstChild("Interior") then
            local decor=m.Interior;local count=0
            for _,p in ipairs(decor:GetDescendants()) do
                if p:IsA("BasePart") then
                    count+=1;assert(p.Anchored and not p.CanTouch)
                    local localP=m:GetPivot():PointToObjectSpace(p.Position)
                    assert(math.abs(localP.X)<26 and localP.Z>-19 and localP.Z<19,"furnishing outside shell")
                end
            end
            local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.GuildborneWorld.City}
            local samples=0
            for z=-5,25 do
                local at=m:GetPivot()*CFrame.new(0,3.8,z)
                for _,p in ipairs(workspace:GetPartBoundsInBox(at,Vector3.new(8,5,.5),params)) do
                    assert(not p.CanCollide,"entrance obstructed: "..m.Name.."/"..p.Name)
                end
                samples+=1
            end
            assert(count>20);total+=count;table.insert(report,{building=m.Name,parts=count,entranceSamples=samples})
        end
    end
    assert(#report==5 and total==169,"expected all five decorated buildings")
    return {buildings=report,totalParts=total,clearCorridorWidth=8}
end
