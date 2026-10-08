--!strict
return function()
    assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
    local sync=require(game.ServerScriptService.Server.Services.FurnitureWorld)
    local rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
    local folder=Instance.new("Folder");folder.Name="FurnitureWorldProbe";folder.Parent=workspace
    local plot:any={origin=Vector3.new(5000,1,5000),expansionFolder=folder}
    local data:any={expansion={furniture={}}};local checks=0
    local function check(ok:boolean)assert(ok,"Furniture check "..(checks+1));checks+=1 end
    local ok,reason=pcall(function()
        for i,kind in ipairs(rules.FurnitureOrder) do data.expansion.furniture["f:"..i]={kind=kind,stored=false,x=i*3,z=0,rotation=0} end
        for rotation=0,3 do
            for _,b in pairs(data.expansion.furniture) do b.rotation=rotation end;sync(plot,data)
            check(#folder:GetChildren()==10)
            for id,m in pairs(plot.furnitureModels) do
                local b=data.expansion.furniture[id];local def=rules.Furniture[b.kind]
                local w,d=def.Width,def.Depth;if rotation%2==1 then w,d=d,w end
                local center=plot.origin+Vector3.new((b.x+w/2)*8,.02,(b.z+d/2)*8)
                check((m:GetPivot().Position-center).Magnitude<.001)
                local proxies=0
                for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then
                    check(p.Anchored and not p.CanTouch)
                    if p.CanCollide then proxies+=1;check(p.Name=="CollisionProxy" and p.Transparency==1 and p.CanQuery) end
                    for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
                        local point=m:GetPivot():PointToObjectSpace(p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2))
                        check(math.abs(point.X)<=def.Width*4+.001 and math.abs(point.Z)<=def.Depth*4+.001 and point.Y>=-.001)
                    end end end
                end end
                check(proxies==(if b.kind=="woven_rug" then 0 else 1))
            end
        end
        local same=plot.furnitureModels["f:1"];sync(plot,data);check(same==plot.furnitureModels["f:1"])
        local cf=same:GetPivot();local proxy=same:FindFirstChild("CollisionProxy")
        data.expansion.furniture["f:1"].theme="orc";sync(plot,data)
        check(same==plot.furnitureModels["f:1"] and same:GetAttribute("BuildingTheme")=="orc")
        check(same:GetPivot()==cf and same:FindFirstChild("CollisionProxy")==proxy)
        for _,b in pairs(data.expansion.furniture) do b.stored=true end;sync(plot,data);check(#folder:GetChildren()==0)
        data.expansion.furniture["f:1"].stored=false;sync(plot,data);check(#folder:GetChildren()==1)
        check(plot.furnitureModels["f:1"]~=same)
        check(plot.furnitureModels["f:1"]:GetAttribute("BuildingTheme")=="orc")
    end)
    folder:Destroy();assert(ok,reason)
    return {checks=checks,models=10,rotations=4,fixtureDestroyed=true,profileWrites=0}
end
