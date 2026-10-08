--!strict
-- Run before installing the controller in bootstrap, so one controller owns the fixture.
return function():any
    local player=game.Players.LocalPlayer;local camera=workspace.CurrentCamera :: Camera
    local oldCF,oldFocus,oldType=camera.CFrame,camera.Focus,camera.CameraType
    local character=player.Character :: Model;local focus=character:FindFirstChild("Head") :: BasePart
    local fixture=Instance.new("Folder");fixture.Name="OcclusionProbe";fixture.Parent=workspace
    local controller:any=nil
    local ok,result=pcall(function():any
        camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(focus.Position+Vector3.new(0,2,12),focus.Position)
        local point=camera.CFrame.Position:Lerp(focus.Position,.5)
        local function actor(name:string,owner:number,state:string,side:number):(Model,BasePart)
            local m=Instance.new("Model");m.Name=name;m:SetAttribute("GuildborneHero",true);m:SetAttribute("OwnerUserId",owner);m:SetAttribute("HeroState",state)
            local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Transparency=1;root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.CanTouch=false;root.Position=point-Vector3.new(0,1.3,0)+Vector3.new(side,0,0);root.Parent=m;m.PrimaryPart=root
            local body=root:Clone();body.Name="Body";body.Transparency=0;body.Position=point+Vector3.new(side,0,0);body.LocalTransparencyModifier=.2;body.Parent=m;m.Parent=fixture;return m,body
        end
        local own,body=actor("OwnedFollowing",player.UserId,"Following",0)
        local _,foreign=actor("OtherOwner",player.UserId+1,"Following",0)
        local _,resting=actor("OwnedResting",player.UserId,"Resting at guild",0)
        local _,side=actor("OffCameraLine",player.UserId,"Following",10)
        controller=require(player.PlayerScripts.Client.Controllers.CompanionOcclusion)();controller.update()
        assert(math.abs(body.LocalTransparencyModifier-.82)<.001)
        for _,part in ipairs({foreign,resting,side}) do assert(math.abs(part.LocalTransparencyModifier-.2)<.001) end
        assert(body.Transparency==0,"authoritative transparency changed")
        local late=body:Clone();late.LocalTransparencyModifier=.35;late.Parent=own;task.wait(.06);controller.update()
        assert(math.abs(late.LocalTransparencyModifier-.82)<.001,"new equipment not tracked")
        own:SetAttribute("HeroState","Resting at guild");controller.update()
        assert(math.abs(body.LocalTransparencyModifier-.2)<.001 and math.abs(late.LocalTransparencyModifier-.35)<.001)
        own:SetAttribute("HeroState","Following");controller.update();controller.destroy();controller=nil
        assert(math.abs(body.LocalTransparencyModifier-.2)<.001 and math.abs(late.LocalTransparencyModifier-.35)<.001)
        return {ownedFade=true,foreignUnchanged=true,restingUnchanged=true,offAxisUnchanged=true,lateEquipment=true,originalValuesRestored=true,serverTransparencyUnchanged=true}
    end)
    if controller then controller.destroy() end
    fixture:Destroy();camera.CFrame=oldCF;camera.Focus=oldFocus;camera.CameraType=oldType
    assert(ok,tostring(result));return result
end
