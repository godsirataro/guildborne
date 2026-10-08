--!strict
-- Twenty client-only actor clones. No Players, remotes, profile or reward writes.
return function()
    local p=game.Players.LocalPlayer;local run=game:GetService("RunService");local stats=game:GetService("Stats")
    local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
    local source: Model?=nil
    for _,m in ipairs(workspace:GetDescendants()) do if m:IsA("Model") and m:GetAttribute("GuildborneHero") and m:GetAttribute("OwnerUserId")==p.UserId and m.PrimaryPart then source=m;break end end
    assert(source,"Owned hero required for geometry-only clone")
    local original=workspace:GetAttribute(config.ReducedMotionAttribute)
    workspace:SetAttribute(config.ReducedMotionAttribute,true)
    local clones: {Model}={};local base: {CFrame}={};local motorCount=0;local parts=0
    local camera=assert(workspace.CurrentCamera);local origin=camera.CFrame.Position+camera.CFrame.LookVector*20
    local function angle(j: Motor6D): number local _,value=j.Transform:ToAxisAngle();return math.abs(value) end
    local function frames(n: number): {number}
        local samples={};for _=1,n do table.insert(samples,run.Heartbeat:Wait()) end;table.sort(samples);return samples
    end
    local ok,result=pcall(function()
        local before=frames(30);local memory=stats:GetTotalMemoryUsageMb()
        for index=1,20 do
            local m=(source :: Model):Clone();m.Name="HeroLifecycleFixture_"..index
            m:SetAttribute("OwnerUserId",0);m:SetAttribute("ActionAt",0);m:SetAttribute("FeedbackAt",0);m:SetAttribute("CombatState","Follow")
            m:SetAttribute("CombatHealth",100);m:SetAttribute("ClassId",({"Knight","Warrior","Archer","Mage","Priest"})[(index-1)%5+1])
            for _,child in ipairs(m:GetDescendants()) do
                if child:IsA("LuaSourceContainer") or child:IsA("BillboardGui") then child:Destroy()
                elseif child:IsA("BasePart") then child.CanCollide=false;child.CanTouch=false;child.CanQuery=false;parts+=1
                elseif child:IsA("Motor6D") then motorCount+=1 end
            end
            local root=assert(m.PrimaryPart);root.Anchored=true
            local cf=CFrame.new(origin+Vector3.new(((index-1)%5-2)*4,0,math.floor((index-1)/5)*4))
            m:PivotTo(cf);m.Parent=workspace;table.insert(clones,m);table.insert(base,cf)
        end
        task.wait(.12)
        local model=clones[1];local root=assert(model.PrimaryPart);local joint=assert(model:FindFirstChild("Left Hip",true)) :: Motor6D
        assert(angle(joint)<.001,"Reduced idle motion missing")
        local moving=false;local stress={}
        for index=1,90 do
            local dt=run.Heartbeat:Wait();table.insert(stress,dt)
            for i,m in ipairs(clones) do m:PivotTo(base[i]+Vector3.new(math.sin(index*.09)*2,0,0)) end
            if angle(joint)>.02 then moving=true end
        end
        assert(moving,"Anchored followers did not walk")
        model:PivotTo(CFrame.new(camera.CFrame.Position+Vector3.new(200,0,0)));task.wait(.08);assert(angle(joint)<.001,"Distance cull left a stale pose")
        model:PivotTo(base[1]);model:SetAttribute("CombatState","Downed");task.wait(.08);assert(angle(joint)>.5,"Downed pose missing")
        model.Parent=game.ReplicatedStorage;task.wait(.04);assert(angle(joint)<.001,"Detached hero retained pose")
        model:SetAttribute("CombatState","Follow");model.Parent=workspace;task.wait(.08);assert(angle(joint)<.001,"Reparent idle did not recover")
        local replacement=joint:Clone();local parent=assert(joint.Parent);joint:Destroy();replacement.Parent=parent
        workspace:SetAttribute(config.ReducedMotionAttribute,false);task.wait(.15);assert(angle(replacement)>.0001,"Replacement joint not observed")
        assert(root.Anchored and (root.Position-base[1].Position).Magnitude<.001,"Animator moved authoritative root")
        table.sort(stress)
        return {actors=20,motors=motorCount,parts=parts,kinematicWalk=true,cullReset=true,downedPose=true,reparentRecovery=true,lateJointRecovery=true,rootUntouched=true,
            baselineHeartbeatP50Ms=before[math.ceil(#before*.5)]*1000,stressHeartbeatP50Ms=stress[math.ceil(#stress*.5)]*1000,stressHeartbeatP95Ms=stress[math.ceil(#stress*.95)]*1000,
            observedMemoryDeltaMb=stats:GetTotalMemoryUsageMb()-memory,mobilePerformanceCertified=false,multiplayerCertified=false,noProfileWrites=true}
    end)
    for _,model in ipairs(clones) do model:Destroy() end
    workspace:SetAttribute(config.ReducedMotionAttribute,original)
    assert(ok,tostring(result));return result
end
