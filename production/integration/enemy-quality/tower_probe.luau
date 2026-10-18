-- Compile-only artifact until explicitly run by controller on LOCAL CLIENT.
-- Unsaved Studio: copy exact reviewed modules into ReplicatedStorage.TowerProbeModules:
-- EnemyAppearance, EnemyArticulation, EnemyAnimator, ActionPose, EnemyProfiles, Combat.
-- ActionPose must be EnemyAnimator's sibling. Real Shared.Config.VFXConfig and
-- Shared.Presentation.ActionTimeline must exist from full-game bootstrap.
-- Do not start another canonical animator. This probe passes a private tag to
-- the actual EnemyAnimator factory and articulates unparented fixture models.
-- Synthetic cosmetics only: no remotes, server combat, rewards or device proof.
local Run=game:GetService("RunService")
assert(Run:IsStudio() and Run:IsClient() and game.PlaceId==0 and game.GameId==0,"Unsaved local client only")
local Tags=game:GetService("CollectionService")
local modules=assert(game.ReplicatedStorage:FindFirstChild("TowerProbeModules"),"Install exact source-copy modules first")
local appearance=require(modules:FindFirstChild("EnemyAppearance"))
local articulate=require(modules:FindFirstChild("EnemyArticulation"))
local animate=require(modules:FindFirstChild("EnemyAnimator"))
local config=require(modules:FindFirstChild("Combat"))
local profiles=require(modules:FindFirstChild("EnemyProfiles"))(config)
local vfx=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local tag="GuildborneTowerProbeOnly"
-- Set to at most 60 for a bounded live gallery after assertions; cleanup still runs.
local GALLERY_SECONDS=0
assert(GALLERY_SECONDS>=0 and GALLERY_SECONDS<=60)
assert(#Tags:GetTagged(tag)==0,"Existing private probe actors")
local camera=assert(workspace.CurrentCamera)
local oldType,oldFrame,oldFocus=camera.CameraType,camera.CFrame,camera.Focus
local oldReduced=workspace:GetAttribute(vfx.ReducedMotionAttribute)
local frame=oldFrame+Vector3.new(0,10000,0)
local center=frame:PointToWorldSpace(Vector3.new(0,0,-15))
local cameraBinding="TowerProbeCamera_"..game:GetService("HttpService"):GenerateGUID(false)
local galleryFrame=CFrame.lookAt(center+Vector3.new(-4,7,-23),center+Vector3.new(0,3,0))
assert(#workspace:GetPartBoundsInRadius(center,50)==0,"Fixture space must be empty")
local actors={}
local animator=nil
local function finite(cf)
    for _,v in ipairs({cf:GetComponents()}) do assert(v==v and math.abs(v)<math.huge,"Nonfinite transform") end
end
local function difference(a,b)
    local aa,bb={a:GetComponents()},{b:GetComponents()};local result=0
    for i=1,12 do result=math.max(result,math.abs(aa[i]-bb[i])) end
    return result
end
local function tick()
    -- Observe after the animator's PreSimulation callback, including deferred tags.
    Run.Heartbeat:Wait();Run.Heartbeat:Wait()
end
local function snapshot(model)
    local result={}
    for _,j in ipairs(model.EnemyJoints:GetChildren()) do
        if j:IsA("Motor6D") then finite(j.Transform);result[j.Name]=j.Transform end
    end
    return result
end
local function changed(a,b)
    for name,cf in pairs(a) do if difference(cf,b[name])>.0001 then return true end end
    return false
end
local function identity(model)
    for _,cf in pairs(snapshot(model)) do assert(difference(cf,CFrame.identity)<.00001,"Joint failed to reset") end
end
local function clear(model)
    for _,name in ipairs({"EnemyActionAt","BossImpactAt","TelegraphAt","TelegraphDuration","FeedbackAt"}) do model:SetAttribute(name,nil) end
    model:SetAttribute("CombatState","Idle")
end
local function rootInvariant(model,cf,size)
    assert(difference(model.PrimaryPart.CFrame,cf)<.00001 and model.PrimaryPart.Size==size,"Presentation moved/resized authoritative root")
    assert(model.PrimaryPart.Anchored,"Root unanchored")
end
local expectedClass={["Echo Guard"]="Knight",["Echo Archer"]="Archer",["Spire Warden"]="Warrior"}
local expectedParts={["Echo Guard"]=60,["Echo Archer"]=63,["Spire Warden"]=63}
local function fixture(role,index)
    local m=Instance.new("Model");m.Name="TowerProbe_"..index;table.insert(actors,m)
    local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Size=Vector3.new(2,2,2)
    root.CFrame=CFrame.new(0,2,0);root.Transparency=1;root.Anchored=true
    root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.Parent=m;m.PrimaryPart=root
    m:SetAttribute("GuildborneEnemy",true);m:SetAttribute("CombatHealth",100);m:SetAttribute("CombatState","Idle")
    local before,size=root.CFrame,root.Size
    appearance(m,role);articulate(m,false)
    rootInvariant(m,before,size)
    Tags:RemoveTag(m,"GuildborneAnimatedEnemy") -- still unparented, canonical animator cannot adopt it
    assert(m:GetAttribute("EnemyAnimationClass")==expectedClass[role])
    local joints,carriers,parts,welds=0,0,0,0
    for _,item in ipairs(m.EnemyJoints:GetChildren()) do
        if item:IsA("Motor6D") then
            joints+=1;assert(item.Part0 and item.Part1 and item.Part1.Parent==m.EnemyJoints)
            assert(item.Part0==(if item.Part1.Name=="Torso" then root else m.EnemyJoints.Torso))
            finite(item.C0);finite(item.C1)
        elseif item:IsA("BasePart") then
            carriers+=1;assert(item.Transparency==1 and item.Massless and not item.Anchored)
            assert(not item.CanCollide and not item.CanTouch and not item.CanQuery)
        end
    end
    for _,p in ipairs(m.EnemyAppearance:GetDescendants()) do
        if p:IsA("BasePart") then
            parts+=1;assert(not p.Anchored and p.Massless and not p.CanCollide and not p.CanTouch and not p.CanQuery)
            local weld=assert(p:FindFirstChild("EnemyArtWeld"));assert(weld:IsA("WeldConstraint"))
            assert(weld.Part1==p and weld.Part0==m.EnemyJoints:FindFirstChild(p:GetAttribute("EnemyLimb")))
            assert(p:GetAttribute("EnemyVisualLimb")==p:GetAttribute("EnemyLimb"),"Authored limb binding changed")
            if p.Name:match("^Shield") or p.Name:match("^Bow") then assert(weld.Part0.Name=="LeftArm") end
            if p.Name:match("^Sword") or p.Name:match("^Hammer") then assert(weld.Part0.Name=="RightArm") end
            if p.Name:match("^Quiver") or p.Name=="ArrowFletch" then assert(weld.Part0.Name=="Torso") end
            welds+=1;finite(p.CFrame)
        end
    end
    assert(joints==6 and carriers==6 and welds==parts and parts==expectedParts[role] and parts<=85,"Geometry/articulation count bound")
    assert(m:GetAttribute("EnemyVisualStyle")=="SpireForgedV2" and m:GetAttribute("EnemyVisualPartCount")==parts)
    articulate(m,false)
    assert(#m.EnemyJoints:GetChildren()==12,"Articulation is not idempotent")
    if role=="Spire Warden" then m:ScaleTo(1.6) end -- actual Tower display scale
    m:PivotTo(CFrame.new(center+Vector3.new((index-2)*8,2*m:GetScale(),0)))
    m.Parent=workspace;Tags:AddTag(m,tag)
    return m,{role=role,parts=parts,carriers=carriers,motors=joints,welds=welds}
end
local ok,outcome=xpcall(function()
    local function holdCamera()
        camera.CameraType=Enum.CameraType.Scriptable
        camera.CFrame=galleryFrame;camera.Focus=CFrame.new(center)
    end
    holdCamera()
    -- The live game's camera also updates every frame; keep private elevated
    -- fixtures within the real animator's culling radius while this probe runs.
    Run:BindToRenderStep(cameraBinding,Enum.RenderPriority.Last.Value+1,holdCamera)
    workspace:SetAttribute(vfx.ReducedMotionAttribute,true)
    -- Frozen gameplay expectations: no appearance or animation inputs participate.
    for floor=1,10 do
        for index=1,4 do
            local s,boss,role=profiles.resolve(floor,index)
            local expectedBoss=floor%5==0 and index==1
            assert(boss==expectedBoss)
            assert(s.MaxHealth==(65+floor*18)*(if boss then 2.4 else 1))
            assert(s.Attack==(5+floor*1.3)*(if boss then 1.5 else 1) and s.Defense==floor)
            local ranged=floor%2==0 and not boss
            assert(s.AttackRange==(if ranged then 18 else 5) and s.MoveSpeed==(if ranged then 8 else 12))
            assert(s.AttackInterval==(if boss then 3 else 1.6))
            assert(role==(if boss then "Spire Warden" elseif ranged then "Echo Archer" else "Echo Guard"))
        end
    end
    animator=animate(tag)
    local reports={}
    for index,role in ipairs({"Echo Guard","Echo Archer","Spire Warden"}) do
        local m,report=fixture(role,index);local root=m.PrimaryPart;local cf,size=root.CFrame,root.Size
        tick();local idle=snapshot(m)
        assert((root.Position-camera.CFrame.Position).Magnitude<90,"INCONCLUSIVE: fixture camera escaped culling radius")
        m:SetAttribute("CombatState","Approach");task.wait(.18);tick();local moving=snapshot(m)
        assert(changed(idle,moving),"Approach indistinguishable from idle")
        clear(m);task.wait(.9);tick() -- allow the approved eased gait to settle
        idle=snapshot(m);m:SetAttribute("CombatState","Attack")
        local stamp=workspace:GetServerTimeNow();m:SetAttribute("EnemyActionAt",stamp);tick()
        assert(workspace:GetServerTimeNow()-stamp<.20,"INCONCLUSIVE: attack sample stalled")
        assert(changed(idle,snapshot(m)),"Confirmed attack has no pose")
        -- Nil cancels the action; reduced idle removes time-dependent idle motion.
        clear(m);tick();assert(not changed(idle,snapshot(m)),"Cleared attack retained action pose")
        -- A fresh confirmed hit after cancellation must still animate.
        stamp=workspace:GetServerTimeNow();m:SetAttribute("EnemyActionAt",stamp);tick()
        assert(workspace:GetServerTimeNow()-stamp<.20,"INCONCLUSIVE: replacement sample stalled")
        assert(changed(idle,snapshot(m)),"Fresh confirmed hit did not animate")
        task.wait(.5);tick();assert(not changed(idle,snapshot(m)),"Expired hit retained follow-through")
        clear(m);tick()
        m:SetAttribute("EnemyActionAt",workspace:GetServerTimeNow()+30);tick()
        assert(not changed(idle,snapshot(m)),"Future basic animated")
        m:SetAttribute("BossImpactAt",workspace:GetServerTimeNow()+30);tick()
        assert(not changed(idle,snapshot(m)),"Future impact animated")
        stamp=workspace:GetServerTimeNow();m:SetAttribute("EnemyActionAt",stamp);tick()
        assert(workspace:GetServerTimeNow()-stamp<.20,"INCONCLUSIVE: mixed clock sample stalled")
        assert(changed(idle,snapshot(m)),"Future impact masked valid basic")
        clear(m);tick()
        if role=="Spire Warden" then
            stamp=workspace:GetServerTimeNow();m:SetAttribute("CombatState","Windup")
            m:SetAttribute("TelegraphDuration",.5);m:SetAttribute("TelegraphAt",stamp)
            task.wait(.25);tick();assert(workspace:GetServerTimeNow()-stamp<.45,"INCONCLUSIVE: warning expired")
            assert(changed(idle,snapshot(m)),"Warden warning has no windup")
            task.wait(.5);tick();assert(not changed(idle,snapshot(m)),"Expired warning retained windup")
            -- Valid impact after warning expiration starts immediate follow-through.
            stamp=workspace:GetServerTimeNow();m:SetAttribute("BossImpactAt",stamp);tick()
            assert(workspace:GetServerTimeNow()-stamp<.20,"INCONCLUSIVE: boss impact sample stalled")
            assert(changed(idle,snapshot(m)),"Confirmed boss impact has no follow-through")
            clear(m);tick()
            stamp=workspace:GetServerTimeNow();m:SetAttribute("CombatState","Windup")
            m:SetAttribute("TelegraphDuration",1);m:SetAttribute("TelegraphAt",stamp)
            task.wait(.25);tick();assert(workspace:GetServerTimeNow()-stamp<.8,"INCONCLUSIVE: cancellation warning expired")
            assert(changed(idle,snapshot(m)),"Cancellation requires active warning pose")
            clear(m);tick();assert(not changed(idle,snapshot(m)),"Cancelled warning retained pose")
        end
        m:SetAttribute("CombatState","Approach");tick();m:SetAttribute("CombatHealth",0);tick();identity(m)
        m:SetAttribute("CombatHealth",100);clear(m);m:SetAttribute("EnemyActionAt",workspace:GetServerTimeNow());tick()
        m.Parent=nil;tick();identity(m)
        m.Parent=workspace;clear(m);tick();rootInvariant(m,cf,size)
        m:SetAttribute("CombatState","Approach");tick();Tags:RemoveTag(m,tag);tick();identity(m)
        Tags:AddTag(m,tag);tick();table.insert(reports,report)
    end
    for _,m in ipairs(actors) do clear(m) end
    task.wait(.9);tick()
    local gallery={camera={camera.CFrame:GetComponents()},roles={}}
    for _,m in ipairs(actors) do
        table.insert(gallery.roles,{role=m:GetAttribute("VisualRole"),scale=m:GetScale(),pivot={m:GetPivot():GetComponents()}})
    end
    if GALLERY_SECONDS>0 then print("TOWER_GALLERY_READY",game:GetService("HttpService"):JSONEncode(gallery));task.wait(GALLERY_SECONDS) end
    animator.Destroy();animator=nil;tick()
    for _,m in ipairs(actors) do identity(m) end
    return {status="PASS_LOCAL_TOWER_COSMETIC_PROBE",roles=reports,profileCases=40,gallery=gallery,
        authoritativeCombatTested=false,physicalDeviceTested=false,visualApproval=false}
end,debug.traceback)
if animator then animator.Destroy() end
Run:UnbindFromRenderStep(cameraBinding)
for _,m in ipairs(actors) do Tags:RemoveTag(m,tag);m:Destroy() end
workspace:SetAttribute(vfx.ReducedMotionAttribute,oldReduced)
camera.CameraType=oldType;camera.CFrame=oldFrame;camera.Focus=oldFocus
assert(ok,outcome)
return outcome
