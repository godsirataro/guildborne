--!strict
return function():any
    local Rig=require(game.ServerScriptService.Server.Services.HeroRig)
    local apply=require(game.ServerScriptService.Server.Services.HeroAppearance)
    local root=Instance.new("Folder");root.Name="HeroAppearanceProbe";root.Parent=workspace
    local ok,result=pcall(function():any
        local cases={};local count=0
        for _,class in ipairs({"Knight","Warrior","Archer","Mage","Priest"}) do
            for variant=1,3 do
                local id=string.lower(class).."_0"..variant;local m=Rig.Build(class,id);m.Parent=root
                m:PivotTo(CFrame.new(12000+count*8,100,0));count+=1
                assert(m:GetAttribute("VisualTemplateId")==id);local visual=m:FindFirstChild("HeroAppearance") :: Model
                assert(visual);local parts=0;local motors=0
                for _,obj in ipairs(m:GetDescendants()) do if obj:IsA("Motor6D") then motors+=1 end end
                assert(motors==6,"companion locomotion joints replaced")
                for _,obj in ipairs(visual:GetChildren()) do
                    assert(obj:IsA("BasePart"));parts+=1
                    assert(not obj.Anchored and obj.Massless and not obj.CanCollide and not obj.CanQuery and not obj.CanTouch)
                    local weld=obj:FindFirstChildOfClass("WeldConstraint");assert(weld and weld.Part0 and weld.Part0:IsDescendantOf(m) and weld.Part1==obj)
                    assert(not table.find({"Grip","Guard","Blade","BowLimb","Bowstring","Staff","Focus"},obj.Name),"baked weapon retained")
                    assert((obj.Position-(m:FindFirstChild("Torso") :: BasePart).Position).Magnitude<5,"out of body bounds")
                end
                assert(parts>=20 and parts<=40)
                assert(apply(m,id) and m:FindFirstChild("HeroAppearance")==visual)
                assert(not apply(m,"bad-id") and m:FindFirstChild("HeroAppearance")==visual)
                table.insert(cases,{id=id,visualParts=parts,motors=motors})
            end
        end
        return {cases=cases,profileMutation=false}
    end)
    root:Destroy();assert(ok,tostring(result));return result
end
