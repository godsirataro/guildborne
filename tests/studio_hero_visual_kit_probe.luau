--!strict
return function(): any
    local factory=require(game.ServerScriptService.Server.Services.HeroVisualKit)
    local reports={}
    for _,rigged in ipairs({false,true}) do
        local folder=factory(rigged)
        local ok,result=pcall(function(): any
            assert(#folder:GetChildren()==15)
            local pieces,joints,welds=0,0,0;local classes:{[string]:number}={}
            for _,entry in ipairs(folder:GetChildren()) do
                local model=entry :: Model;local class=model:GetAttribute("ClassId") :: string
                classes[class]=(classes[class] or 0)+1
                assert(model:GetAttribute("DesignId")=="ui.heroes."..model.Name and model:GetAttribute("RecruitmentBound")==false)
                local anchored=0
                for _,obj in ipairs(model:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        pieces+=1;assert(not obj.CanCollide and not obj.CanTouch and not obj.CanQuery)
                        if obj.Anchored then anchored+=1 end
                    elseif obj:IsA("Motor6D") then
                        joints+=1;assert(obj.Part0 and obj.Part1)
                        assert(((obj.Part0.CFrame*obj.C0).Position-(obj.Part1.CFrame*obj.C1).Position).Magnitude<.001)
                    elseif obj:IsA("WeldConstraint") then welds+=1;assert(obj.Part0 and obj.Part1) end
                end
                if rigged then assert(anchored==1 and model.PrimaryPart and model.PrimaryPart.Name=="Root") end
            end
            for _,class in ipairs({"Knight","Warrior","Archer","Mage","Priest"}) do assert(classes[class]==3) end
            assert(pieces==(if rigged then 679 else 439));assert(joints==(if rigged then 225 else 0));assert(welds==(if rigged then 439 else 0))
            return {rigged=rigged,models=15,parts=pieces,motors=joints,welds=welds,recruitmentBound=false}
        end)
        folder:Destroy();assert(ok,tostring(result));table.insert(reports,result)
    end
    return reports
end
