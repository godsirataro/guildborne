--!strict
return function():any
    local Shared=game.ReplicatedStorage.Shared
    local appearance=require(Shared.Presentation.FurnitureAppearance)
    local catalog=require(Shared.Config.BuildingThemes)
    local kit=require(Shared.Presentation.FurnitureKit)()
    local checks=0;local variants=0
    local function check(ok:boolean) assert(ok,"Furniture theme invariant "..checks);checks+=1 end
    local ok,problem=pcall(function()
        for _,original in ipairs(kit:GetChildren()) do
            local model=original :: Model;local baseline={}
            model:PivotTo(CFrame.new(900,3,900)*CFrame.Angles(0,math.pi/2,0))
            for _,part in ipairs(model:GetDescendants()) do if part:IsA("BasePart") then
                baseline[part]={color=part.Color,material=part.Material,cf=part.CFrame,size=part.Size,collide=part.CanCollide,query=part.CanQuery,touch=part.CanTouch}
            end end
            local proxy=Instance.new("Part");proxy.Name="CollisionProxy";proxy.Transparency=1;proxy.Color=Color3.new(.1,.2,.3);proxy.Parent=model
            local proxyColor=proxy.Color;local pivot=model:GetPivot();local count=#model:GetDescendants()
            for _,id in ipairs(catalog.Order) do
                appearance.apply(model,id);variants+=1
                check(model:GetAttribute("BuildingTheme")==id);check(model:GetPivot()==pivot);check(#model:GetDescendants()==count)
                check(proxy.Color==proxyColor);check(proxy.CanCollide)
                local colors={};for part,base in pairs(baseline) do
                    check(part.CFrame==base.cf and part.Size==base.size)
                    check(part.CanCollide==base.collide and part.CanQuery==base.query and part.CanTouch==base.touch)
                    colors[part]={color=part.Color,material=part.Material}
                end
                appearance.apply(model,id)
                for part,color in pairs(colors) do check(part.Color==color.color and part.Material==color.material) end
                appearance.apply(model,"human")
                for part,base in pairs(baseline) do check(part.Color==base.color and part.Material==base.material) end
            end
        end
    end)
    kit:Destroy();if not ok then error(tostring(problem)) end
    return {checks=checks,variants=variants,fixtureDestroyed=kit.Parent==nil}
end
