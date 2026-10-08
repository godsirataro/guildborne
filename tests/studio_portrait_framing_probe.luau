--!strict
-- Client Play only: inspect actual replicated actor portraits and visible head-gear bounds.
return function():any
    local player=game.Players.LocalPlayer
    local make=require(player.PlayerScripts.Client.UI.ActorPortrait)
    local gui=Instance.new("ScreenGui");gui.Name="PortraitFrameProbe";gui.Enabled=false;gui.Parent=player.PlayerGui
    local ok,result=pcall(function():any
        local actors={};if player.Character then table.insert(actors,player.Character) end
        for _,entry in ipairs(workspace:GetDescendants()) do
            if entry:IsA("Model") and entry:GetAttribute("GuildborneHero")==true and entry:GetAttribute("OwnerUserId")==player.UserId then table.insert(actors,entry) end
        end
        assert(#actors==6);local reports={}
        for _,source in ipairs(actors) do
            local parent=Instance.new("Frame");parent.Parent=gui;local portrait=make(parent);portrait.update(source)
            local view=parent:FindFirstChild("Portrait") :: ViewportFrame
            local world=view:FindFirstChildOfClass("WorldModel") :: WorldModel;local camera=view.CurrentCamera :: Camera
            local count=#world:GetChildren();assert(count>0 and count<=64)
            local first=world:GetChildren()[1];portrait.update(source);assert(world:GetChildren()[1]==first,"unchanged snapshot rebuilt")
            local corners=0
            for _,entry in ipairs(world:GetChildren()) do
                local part=entry :: BasePart
                assert(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery)
                assert(not part:FindFirstChildWhichIsA("WeldConstraint",true))
                if part.Position.Y>=-.65 then
                    for _,x in ipairs({-.5,.5}) do for _,y in ipairs({-.5,.5}) do for _,z in ipairs({-.5,.5}) do
                        local point=camera.CFrame:PointToObjectSpace(part.CFrame:PointToWorldSpace(part.Size*Vector3.new(x,y,z)))
                        local extent=-point.Z*math.tan(math.rad(camera.FieldOfView/2))
                        assert(point.Z<0 and math.abs(point.X)<=extent and math.abs(point.Y)<=extent,"head gear clipped: "..source.Name.."/"..part.Name)
                        corners+=1
                    end end end
                end
            end
            table.insert(reports,{actor=source.Name,parts=count,headCorners=corners})
            portrait.update(nil);assert(#world:GetChildren()==0 and not view.Visible);portrait.destroy();parent:Destroy()
        end
        return reports
    end)
    gui:Destroy();assert(ok,tostring(result));return result
end
