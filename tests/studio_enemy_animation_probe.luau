--!strict
-- Client fixture exercises the running bootstrap animator, not a second controller.
return function()
    local source: Model?=nil
    for _,m in ipairs(game:GetService("CollectionService"):GetTagged("GuildborneAnimatedEnemy")) do if m:IsA("Model") and m:IsDescendantOf(workspace) then source=m;break end end
    assert(source,"No live articulated enemy")
    local camera=assert(workspace.CurrentCamera)
    local model=source:Clone();model.Name="EnemyAnimationFixture";model:SetAttribute("OwnerUserId",-999)
    model:SetAttribute("CombatHealth",100);model:SetAttribute("CombatState","Idle");model:SetAttribute("EnemyActionAt",nil);model:SetAttribute("BossImpactAt",nil);model:SetAttribute("FeedbackAt",nil);model:SetAttribute("TelegraphAt",nil)
    model:PivotTo(CFrame.new(camera.CFrame.Position+camera.CFrame.LookVector*12));model.Parent=workspace
    local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig);local oldReduced=workspace:GetAttribute(config.ReducedMotionAttribute)
    local ok,result=pcall(function()
        local root=assert(model.PrimaryPart);local before=root.CFrame;local motors: {Motor6D}={}
        for _,j in ipairs(model:GetDescendants()) do if j:IsA("Motor6D") then table.insert(motors,j) end end
        local function posed(): boolean for _,j in ipairs(motors) do if j.Transform~=CFrame.identity then return true end end;return false end
        local function sample()task.wait(.22)end
        workspace:SetAttribute(config.ReducedMotionAttribute,true);sample();assert(not posed(),"Reduced idle should settle")
        model:SetAttribute("CombatState","Approach");sample();assert(posed(),"Walk not animated")
        model:SetAttribute("CombatState","Attack");model:SetAttribute("EnemyActionAt",workspace:GetServerTimeNow());sample();assert(posed(),"Attack not animated")
        assert((root.Position-before.Position).Magnitude<.001,"Cosmetic moved authoritative root")
        model:SetAttribute("EnemyActionAt",nil);model:SetAttribute("CombatState","Windup");model:SetAttribute("TelegraphAt",workspace:GetServerTimeNow());model:SetAttribute("TelegraphDuration",1.5);sample();assert(posed(),"Windup not held")
        model:SetAttribute("TelegraphAt",nil);model:SetAttribute("CombatState","Idle");sample();assert(not posed(),"Cancelled windup stuck")
        model:SetAttribute("CombatState","Approach");sample();assert(posed())
        model.Parent=game.ReplicatedStorage;sample();assert(not posed(),"Detached rig not restored")
        model.Parent=workspace;sample();assert(posed(),"Reparented rig did not resume")
        model:SetAttribute("CombatHealth",0);sample();assert(not posed(),"Dead rig retains pose")
        model:SetAttribute("CombatHealth",100);sample();assert(posed(),"Respawn did not resume")
        model:PivotTo(CFrame.new(camera.CFrame.Position+Vector3.new(0,0,500)));sample();assert(not posed(),"Culled rig stuck")
        return {walk=true,attack=true,windup=true,cancelRestores=true,reducedIdle=true,reparentResume=true,deathRespawn=true,distanceCullResets=true,rootUntouched=true,motors=#motors}
    end)
    workspace:SetAttribute(config.ReducedMotionAttribute,oldReduced);model:Destroy();assert(ok,tostring(result));return result
end
