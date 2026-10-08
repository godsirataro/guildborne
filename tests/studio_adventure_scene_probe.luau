--!strict
return function(): any
    local build=require(game.ServerScriptService.Server.Services.AdventureScene)
    assert(build("not-a-region")==nil)
    local reports={}
    for _,id in ipairs({"Greenwood","Ironveil","Ashen"}) do
        local model=build(id);assert(model and model.Parent==nil)
        local ok,result=pcall(function(): any
            assert(model:GetAttribute("EncountersEnabled")==false)
            local actors=model:FindFirstChild("EncounterArt") :: Folder
            assert(#actors:GetChildren()==4)
            local parts=0;local bosses=0
            for _,entry in ipairs(actors:GetChildren()) do
                local actor=entry :: Model
                assert(actor:GetAttribute("PreviewOnly")==true)
                if actor:GetAttribute("VisualRole")=="Boss" then bosses+=1 end
                local markers=model:FindFirstChild("EncounterMarkers") :: Folder
                local marker=markers:FindFirstChild(actor:GetAttribute("EncounterMarker") :: string) :: BasePart
                assert((actor:GetPivot().Position-marker.Position).Magnitude<.01)
                for _,part in ipairs(actor:GetDescendants()) do
                    assert(not part:IsA("BaseScript") and not part:IsA("Humanoid"))
                    if part:IsA("BasePart") then
                        assert(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery);parts+=1
                    end
                end
            end
            assert(bosses==1)
            return {region=id,enemies=4,bosses=bosses,artParts=parts,gameplayEnabled=false}
        end)
        model:Destroy();assert(ok,tostring(result));table.insert(reports,result)
    end
    return reports
end
