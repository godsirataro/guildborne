--!strict
-- Client Play, isolated non-gameplay actors. Never changes health or profile state.
return function(): any
    local player=game.Players.LocalPlayer
    local factory=require(player.PlayerScripts.Client.Controllers.SkillEffects)
    local camera=workspace.CurrentCamera :: Camera
    local actors: {Model}={};local spawned: {Instance}={};local afterRemoval=0;local watching=false
    local connection=workspace.ChildAdded:Connect(function(child)
        if child.Name=="GuildborneSkillEffect" then
            table.insert(spawned,child)
            if watching then afterRemoval+=1 end
        end
    end)
    local function actor(class: string): Model
        local m=Instance.new("Model");m.Name="VFXLifecycleProbe"
        local p=Instance.new("Part");p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Transparency=1
        p.CFrame=camera.CFrame*CFrame.new(0,0,-15);p.Parent=m;m.PrimaryPart=p
        m:SetAttribute("ClassId",class);m:SetAttribute("ActionEffect","Basic")
        m:SetAttribute("ActionTargetPosition",p.Position+Vector3.new(3,0,0));m.Parent=workspace
        table.insert(actors,m);return m
    end
    local ok,result=pcall(function():any
        for _,class in ipairs({"Archer","Mage"}) do
            local m=actor(class);factory()(m);assert(#spawned>0,"no initial missile")
            m:Destroy();watching=true;task.wait(.32);watching=false
            assert(afterRemoval==0,"delayed impact spawned after caster removal")
        end
        local m=actor("Knight");local effect=factory();local initial=#spawned
        m:SetAttribute("TelegraphDuration",.25)
        effect(m,true);assert(#spawned==initial,"missing stamp rendered")
        m:SetAttribute("TelegraphAt",workspace:GetServerTimeNow()-2)
        effect(m,true);assert(#spawned==initial,"expired warning rendered")
        m:SetAttribute("TelegraphAt",workspace:GetServerTimeNow());effect(m,true)
        local marker=spawned[#spawned];assert(marker.Name=="GuildborneBossTelegraph")
        assert(marker:IsA("BasePart") and not marker.CanCollide and not marker.CanQuery and not marker.CanTouch)
        m.Parent=game.ReplicatedStorage;task.wait(.12);assert(marker.Parent==nil,"warning survived leaving world")
        local before=#spawned;effect(m,true);assert(#spawned==before,"detached actor rendered")
        m.Parent=workspace;m:SetAttribute("TelegraphAt",workspace:GetServerTimeNow());effect(m,true)
        marker=spawned[#spawned];m:SetAttribute("TelegraphAt",nil);task.wait(.12)
        assert(marker.Parent==nil,"cancelled warning survived")
        m:SetAttribute("TelegraphAt",workspace:GetServerTimeNow());effect(m,true)
        marker=spawned[#spawned];task.wait(.5);assert(marker.Parent==nil,"warning exceeded lifetime")
        effect(m,false,true);assert(#spawned>before,"impact missing")
        task.wait(1.1)
        for _,p in ipairs(spawned) do assert(p.Parent==nil,"effect leaked") end
        return {removedCasterImpacts=afterRemoval,missingStampRejected=true,expiredRejected=true,leaveWorldCleanup=true,cancelCleanup=true,lifetimeCleanup=true,impactCleanup=true}
    end)
    connection:Disconnect();for _,m in ipairs(actors) do m:Destroy() end
    for _,p in ipairs(spawned) do p:Destroy() end
    assert(ok,tostring(result));return result
end
