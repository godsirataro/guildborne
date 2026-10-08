--!strict
local Rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
local templates=require(game.ReplicatedStorage.Shared.Presentation.FurnitureKit)()
local Appearance=require(game.ReplicatedStorage.Shared.Presentation.FurnitureAppearance)
return function(plot:any,data:any)
    plot.furnitureModels=plot.furnitureModels or {}
    local models=plot.furnitureModels
    local owned=data.expansion.furniture or {}
    for id,m in pairs(models) do if not owned[id] or owned[id].stored then m:Destroy();models[id]=nil end end
    for id,b in pairs(owned) do if not b.stored then
        local def=Rules.Furniture[b.kind];local m=models[id]
        local w,d=def.Width,def.Depth;if b.rotation%2==1 then w,d=d,w end
        local cf=CFrame.new(plot.origin+Vector3.new((b.x+w/2)*8,.02,(b.z+d/2)*8))*CFrame.Angles(0,b.rotation*math.pi/2,0)
        if not m then
            local template=templates:FindFirstChild(b.kind) :: Model
            m=template:Clone();m.Name=id;m:SetAttribute("FurnitureKind",b.kind)
            if b.kind~="woven_rug" then
                local proxy=Instance.new("Part");proxy.Name="CollisionProxy";proxy.Size=Vector3.new(def.Width*8-.2,def.Height,def.Depth*8-.2)
                proxy.CFrame=CFrame.new(0,def.Height/2,0);proxy.Transparency=1;proxy.Anchored=true;proxy.CanTouch=false;proxy.Parent=m
            end
            m:PivotTo(cf);m.Parent=plot.expansionFolder;models[id]=m
        else m:PivotTo(cf) end
        if m:GetAttribute("BuildingTheme")~=(b.theme or "human") then Appearance.apply(m,b.theme or "human") end
    end end
end
