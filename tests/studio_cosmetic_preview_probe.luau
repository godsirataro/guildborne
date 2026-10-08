--!strict
-- Client Play; no commands, profile operations, or ownership flags.
return function():any
    local player=game.Players.LocalPlayer;local create=require(player.PlayerScripts.Client.UI.CosmeticPreview)
    local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
    local gui=Instance.new("ScreenGui");gui.Name="CosmeticPreviewProbe";gui.Enabled=false;gui.Parent=player.PlayerGui
    local ok,result=pcall(function():any
        local holder=Instance.new("Frame");holder.Size=UDim2.fromOffset(320,420);holder.Parent=gui
        local preview=create(holder,function(key:string):string return locale.translate("th",key) end)
        local checks=0;local total=0
        for _,width in ipairs({240,640}) do
            holder.Size=UDim2.fromOffset(width,420)
            for index,entry in ipairs(preview.entries) do
                preview.select(index);game:GetService("RunService").RenderStepped:Wait()
                local world=preview.view:FindFirstChildOfClass("WorldModel");assert(#world:GetChildren()==1)
                local model=world:GetChildren()[1];assert(model.Name==entry.id and model:GetAttribute("EntitlementBound")==false)
                local camera=preview.view.CurrentCamera;local aspect=preview.view.AbsoluteSize.X/preview.view.AbsoluteSize.Y
                for _,p in ipairs(model:GetDescendants()) do
                    if p:IsA("BasePart") then
                        assert(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch);total+=1
                        for _,x in ipairs({-.5,.5}) do for _,y in ipairs({-.5,.5}) do for _,z in ipairs({-.5,.5}) do
                            local point=camera.CFrame:PointToObjectSpace(p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)))
                            local bound=-point.Z*math.tan(math.rad(camera.FieldOfView/2))
                            assert(point.Z<0 and math.abs(point.X)<=bound*aspect and math.abs(point.Y)<=bound,"clipped: "..entry.id);checks+=1
                        end end end
                    end
                end
                assert(preview.frame.SelectedCosmetic.Text:find(locale.translate("th",entry.name),1,true))
            end
        end
        preview.select(9);assert(preview.view:GetAttribute("CosmeticId")=="founder_cloak")
        preview.select(0);assert(preview.view:GetAttribute("CosmeticId")=="pale_spell_trail")
        for _,name in ipairs({"PreviousCosmetic","RotateCosmetic","NextCosmetic"}) do assert(preview.frame[name].AbsoluteSize.Y>=44) end
        preview.frame:Destroy();assert(preview.view.Parent==nil)
        return {entries=8,widths={240,640},partChecks=total,cornerChecks=checks,wraps=true,localized=true,cleanup=true}
    end)
    gui:Destroy();assert(ok,tostring(result));return result
end
