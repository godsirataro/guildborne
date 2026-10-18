-- COMPILE-ONLY until controller runs on local CLIENT in unsaved Studio.
-- Install exact source copies under ReplicatedStorage.GreenwoodProbeModules:
-- AdventureEnemyKit, EnemyArticulation, EnemyAnimator, ActionPose,
-- AdventureEnemyProfiles, AdventureStats, AdventurePatterns; plus
-- BaselineAdventureEnemyKit from commit 9c34435 (untouched baseline source).
-- ActionPose is EnemyAnimator's sibling. Normal bootstrap supplies Shared
-- Config.VFXConfig and Presentation.ActionTimeline. No authoritative gameplay services/remotes run.
-- Tests synthetic cosmetics and pure contracts, not authoritative combat or UAT.
local Run=game:GetService("RunService")
assert(Run:IsStudio() and Run:IsClient() and game.PlaceId==0 and game.GameId==0,"Unsaved local CLIENT only")
local Tags=game:GetService("CollectionService")
local modules=assert(game.ReplicatedStorage:FindFirstChild("GreenwoodProbeModules"))
local function load(name) return require(assert(modules:FindFirstChild(name),"Missing source copy: "..name)) end
local kitFactory,baselineFactory=load("AdventureEnemyKit"),load("BaselineAdventureEnemyKit")
local articulate,animate=load("EnemyArticulation"),load("EnemyAnimator")
local profiles,stats,patterns=load("AdventureEnemyProfiles"),load("AdventureStats"),load("AdventurePatterns")
local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local camera=assert(workspace.CurrentCamera)
local oldType,oldFrame,oldFocus=camera.CameraType,camera.CFrame,camera.Focus
local reduced=workspace:GetAttribute(config.ReducedMotionAttribute)
local center=camera.CFrame.Position+Vector3.new(0,10000,0)
assert(#workspace:GetPartBoundsInRadius(center,70)==0,"Isolated empty fixture space required")
local tag="GuildborneGreenwoodProbeOnly"
assert(#Tags:GetTagged(tag)==0,"Existing probe actors")
local GALLERY_SECONDS=0 -- optionally 1..60, always cleaned up afterward
assert(GALLERY_SECONDS>=0 and GALLERY_SECONDS<=60)
local actors={};local kit,baseline,animator=nil,nil,nil
local function tick() Run.Heartbeat:Wait();Run.Heartbeat:Wait() end
local function diff(a,b)
    local aa,bb={a:GetComponents()},{b:GetComponents()};local d=0
    for i=1,12 do assert(aa[i]==aa[i] and math.abs(aa[i])<math.huge,"Nonfinite pose");d=math.max(d,math.abs(aa[i]-bb[i])) end
    return d
end
local function pose(m)
    local p={};for _,j in ipairs(m.EnemyJoints:GetChildren()) do if j:IsA("Motor6D") then diff(j.Transform,CFrame.identity);p[j.Name]=j.Transform end end
    return p
end
local function changed(a,b)
    for n,v in pairs(a) do if diff(v,b[n])>.0001 then return true end end;return false
end
local function reset(m)
    for _,name in ipairs({"EnemyActionAt","RegionalImpactAt","RegionalTelegraphAt","RegionalTelegraphUntil","TelegraphName","DamageCueAt","FeedbackAt"}) do m:SetAttribute(name,nil) end
    m:SetAttribute("CombatState","Idle")
end
local function identity(m) for _,v in pairs(pose(m)) do assert(diff(v,CFrame.identity)<.00001,"Reset failed") end end
local function signature(m)
    local rows={}
    for _,p in ipairs(m:GetDescendants()) do
        if p:IsA("BasePart") then
            local values={p.ClassName,p.Name,tostring(p.Size),tostring(p.Color),p.Material.Name,tostring(p.Anchored),tostring(p.CanCollide),tostring(p.CanTouch),tostring(p.CanQuery),tostring(p:GetAttribute("BindBone"))}
            table.insert(values,if p:IsA("Part") then p.Shape.Name else "not-Part")
            for _,v in ipairs({p.CFrame:GetComponents()}) do table.insert(values,string.format("%.9g",v)) end
            table.insert(rows,table.concat(values,"|"))
        end
    end
    table.sort(rows);return table.concat(rows,"\n")
end
local function rootInvariant(m,cf)
    local r=m.PrimaryPart
    assert(diff(r.CFrame,cf)<.00001 and r.Size==Vector3.one and r.PivotOffset==CFrame.new(0,-3,0),"Bridge root changed")
    assert(r.Anchored and not r.CanCollide and not r.CanTouch and not r.CanQuery and m:GetScale()==1,"Bridge root physics/scale changed")
end
local ok,outcome=xpcall(function()
    camera.CameraType=Enum.CameraType.Scriptable
    camera.CFrame=CFrame.lookAt(center+Vector3.new(14,11,-28),center+Vector3.new(0,4,0));camera.Focus=CFrame.new(center)
    workspace:SetAttribute(config.ReducedMotionAttribute,true)
    kit=kitFactory();baseline=baselineFactory()
    assert(#kit:GetChildren()==12 and #baseline:GetChildren()==12,"Template inventory changed")
    local unaffected=0
    for _,m in ipairs(kit:GetChildren()) do
        if m.Name~="greenwood_scout" and m.Name~="forest_captain" then
            local prior=assert(baseline:FindFirstChild(m.Name));assert(signature(m)==signature(prior),"Unowned template changed: "..m.Name)
            for _,key in ipairs({"Region","VisualRole","RigType","TemplateOnly","EnemyVisualStyle","EnemyVisualPartCount"}) do assert(m:GetAttribute(key)==prior:GetAttribute(key)) end
            unaffected+=1
        end
    end
    assert(unaffected==10)
    local expected={greenwood_scout={135,12,12,5,25,30,1.6},forest_captain={650,24,10,10,28,30,2}}
    for id,values in pairs(expected) do
        local p=profiles[id]
        for i,key in ipairs({"health","power","speed","range","detect","leash","interval"}) do assert(p[key]==values[i],"Gameplay profile changed") end
        local s=stats.build(p,if id=="forest_captain" then "Boss" else "Melee")
        assert(s.MaxHealth==values[1] and s.Attack==values[2] and s.Defense==3 and s.MoveSpeed==values[3] and s.AttackRange==values[4] and s.AttackInterval==values[7])
    end
    local a={templateId="forest_captain",health=300,maxHealth=650,position={x=0,y=0,z=0},patternCount=0}
    local target={x=0,y=0,z=-8}
    local cleave=assert(patterns.begin(a,target,10))
    assert(cleave.name=="Antler Cleave" and cleave.shape=="Cone" and cleave.radius==10 and cleave.halfAngle==55 and cleave.duration==1.1 and cleave.recovery==1.5)
    patterns.cancel(a,10)
    local burst=assert(patterns.begin(a,target,20))
    assert(burst.name=="Root Burst" and burst.shape=="Circle" and burst.radius==8 and burst.duration==1.5 and burst.recovery==2)
    animator=animate(tag)
    local reports={}
    for index,id in ipairs({"greenwood_scout","forest_captain"}) do
        local m=assert(kit:FindFirstChild(id)):Clone();m.Parent=nil;table.insert(actors,m)
        local prior=assert(baseline:FindFirstChild(id))
        for _,name in ipairs({"Head","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}) do
            local p,b=assert(m:FindFirstChild(name)),assert(prior:FindFirstChild(name))
            assert(p.Size==b.Size and diff(p.CFrame,b.CFrame)<.000001 and p:GetAttribute("BindBone")==b:GetAttribute("BindBone"),"Authored socket changed: "..name)
        end
        local wedges,blocks=0,0
        for _,item in ipairs(m:GetDescendants()) do
            if item:IsA("WedgePart") then wedges+=1 elseif item:IsA("Part") and item.Shape==Enum.PartType.Block then blocks+=1 end
            assert(not item:IsA("ParticleEmitter") and not item:IsA("Beam") and not item:IsA("Trail") and not item:IsA("Light"),"Unexpected effect budget")
        end
        assert(wedges>0 and blocks>0,"Native shape vocabulary missing")
        local origin=CFrame.new(center+Vector3.new((index-1.5)*10,0,0));m:PivotTo(origin)
        local r=Instance.new("Part");r.Name="HumanoidRootPart";r.Size=Vector3.one;r.CFrame=m:GetPivot()*CFrame.new(0,3,0)
        r.Transparency=1;r.Anchored=true;r.CanCollide=false;r.CanTouch=false;r.CanQuery=false;r.Parent=m
        r.PivotOffset=CFrame.new(0,-3,0);m.PrimaryPart=r
        m:SetAttribute("EncounterId",id);m:SetAttribute("GuildborneEnemy",true);m:SetAttribute("CombatHealth",profiles[id].health);reset(m)
        local cf=r.CFrame;articulate(m,false);Tags:RemoveTag(m,"GuildborneAnimatedEnemy")
        rootInvariant(m,cf);assert(diff(m:GetPivot(),origin)<.00001,"Ground pivot mismatch")
        local parts,joints,carriers=0,0,0
        for _,item in ipairs(m:GetDescendants()) do
            if item:IsA("Motor6D") then joints+=1;assert(item.Part0 and item.Part1 and item.Part1.Parent==m.EnemyJoints)
            elseif item:IsA("BasePart") and item~=r then
                assert(not item.Anchored and item.Massless and not item.CanCollide and not item.CanTouch and not item.CanQuery)
                if item.Parent==m.EnemyJoints then carriers+=1 else
                    parts+=1;local w=assert(item:FindFirstChild("EnemyArtWeld"))
                    assert(w:IsA("WeldConstraint") and w.Part1==item and w.Part0==m.EnemyJoints:FindFirstChild(item:GetAttribute("EnemyLimb")),"Art weld mismatch")
                end
            end
        end
        local expectedParts=if id=="greenwood_scout" then 58 else 70
        assert(joints==6 and carriers==6 and parts==expectedParts and parts<=90 and parts==m:GetAttribute("EnemyVisualPartCount"),"Actor budget/binding count")
        local function binding(name,bone,limb,count)
            local found=0
            for _,p in ipairs(m:GetChildren()) do if p.Name==name then
                assert(p:GetAttribute("BindBone")==bone and p:GetAttribute("EnemyLimb")==limb,"Wrong authored binding: "..name);found+=1
            end end
            assert(found==count,"Missing/duplicate authored feature: "..name)
        end
        for _,name in ipairs({"SwordGrip","SwordWrap1","SwordWrap2","SwordWrap3","SwordPommel","SwordGuard","SwordBlade","SwordFuller","SwordTip"}) do binding(name,"RightHand","RightArm",1) end
        if id=="forest_captain" then
            for _,name in ipairs({"AntlerRoot","AntlerBeam","AntlerFork","AntlerTine"}) do binding(name,"Head","Head",2) end
            for _,name in ipairs({"ShieldBack","ShieldBark1","ShieldBark2","ShieldBark3","ShieldCrestTrunk","ShieldCrestSeed"}) do binding(name,"LeftHand","LeftArm",1) end
            binding("ShieldRim","LeftHand","LeftArm",2);binding("ShieldCrestBranch","LeftHand","LeftArm",2)
        end
        assert(m:GetAttribute("EnemyVisualStyle")=="GreenwoodForgedV1")
        m.Parent=workspace;Tags:AddTag(m,tag);tick();local idle=pose(m)
        m:SetAttribute("CombatState","Approach");task.wait(.2);tick();assert(changed(idle,pose(m)),"No walking pose")
        reset(m);task.wait(.9);tick();idle=pose(m)
        task.wait(.2);tick();assert(not changed(idle,pose(m)),"Reduced-motion idle not settled")
        for _,offset in ipairs({-10,10}) do
            m:SetAttribute("EnemyActionAt",workspace:GetServerTimeNow()+offset)
            m:SetAttribute("RegionalImpactAt",workspace:GetServerTimeNow()+offset);tick()
            assert(not changed(idle,pose(m)),"Stale/future action was played")
        end
        reset(m)
        local stamp=workspace:GetServerTimeNow();m:SetAttribute("EnemyActionAt",stamp);tick()
        assert(workspace:GetServerTimeNow()-stamp<.2,"INCONCLUSIVE: attack stalled");assert(changed(idle,pose(m)),"No immediate hit follow-through")
        task.wait(.55);tick();assert(not changed(idle,pose(m)),"Hit failed to settle")
        stamp=workspace:GetServerTimeNow();m:SetAttribute("RegionalImpactAt",stamp+10);m:SetAttribute("EnemyActionAt",stamp);tick()
        assert(workspace:GetServerTimeNow()-stamp<.2,"INCONCLUSIVE: future-clock test stalled");assert(changed(idle,pose(m)),"Future impact masked valid basic")
        reset(m);m:SetAttribute("FeedbackAt",workspace:GetServerTimeNow());tick();assert(not changed(idle,pose(m)),"Healing feedback caused hit reaction")
        reset(m)
        stamp=workspace:GetServerTimeNow();m:SetAttribute("DamageCueAt",stamp);task.wait(.05);tick()
        assert(workspace:GetServerTimeNow()-stamp<.16,"INCONCLUSIVE: damage cue stalled");assert(changed(idle,pose(m)),"Damage cue absent")
        task.wait(.2);tick();assert(not changed(idle,pose(m)),"Damage cue failed to settle");reset(m)
        if id=="forest_captain" then
            local warnings={}
            for _,offset in ipairs({-10,10}) do
                stamp=workspace:GetServerTimeNow()+offset;m:SetAttribute("CombatState","Windup");m:SetAttribute("TelegraphName","Antler Cleave")
                m:SetAttribute("RegionalTelegraphAt",stamp);m:SetAttribute("RegionalTelegraphUntil",stamp+.8);tick()
                assert(not changed(idle,pose(m)),"Stale/future warning was played")
            end
            reset(m)
            stamp=workspace:GetServerTimeNow();m:SetAttribute("CombatState","Windup");m:SetAttribute("TelegraphName","Unknown")
            m:SetAttribute("RegionalTelegraphAt",stamp);m:SetAttribute("RegionalTelegraphUntil",stamp+.8);tick()
            assert(not changed(idle,pose(m)),"Unknown warning was played");reset(m)
            for _,warning in ipairs({{name="Antler Cleave",duration=1.1},{name="Root Burst",duration=1.5}}) do
                local name,duration=warning.name,warning.duration
                stamp=workspace:GetServerTimeNow();m:SetAttribute("CombatState","Windup");m:SetAttribute("TelegraphName",name)
                m:SetAttribute("RegionalTelegraphAt",stamp);m:SetAttribute("RegionalTelegraphUntil",stamp+duration)
                task.wait(.3);tick();assert(workspace:GetServerTimeNow()-stamp<.7,"INCONCLUSIVE: warning stalled")
                warnings[name]=pose(m);assert(changed(idle,warnings[name]),"Missing committed warning pose")
                task.wait(math.max(0,stamp+duration-.2-workspace:GetServerTimeNow()));tick()
                assert(workspace:GetServerTimeNow()<stamp+duration,"INCONCLUSIVE: held warning stalled")
                assert(changed(idle,pose(m)),"Warning released before committed duration")
                task.wait(math.max(0,stamp+duration+.08-workspace:GetServerTimeNow()));tick()
                assert(not changed(idle,pose(m)),"Natural warning expiry failed")
                reset(m)
            end
            assert(changed(warnings["Antler Cleave"],warnings["Root Burst"]),"Warnings indistinguishable")
            stamp=workspace:GetServerTimeNow();m:SetAttribute("CombatState","Windup");m:SetAttribute("TelegraphName","Antler Cleave")
            m:SetAttribute("RegionalTelegraphAt",stamp);m:SetAttribute("RegionalTelegraphUntil",stamp+1.1)
            task.wait(.3);tick();assert(workspace:GetServerTimeNow()-stamp<1,"INCONCLUSIVE: cancel fixture stalled")
            assert(changed(idle,pose(m)),"Cancellation fixture had no active warning")
            reset(m);tick();assert(not changed(idle,pose(m)),"Cancelled warning persists")
            reset(m)
            stamp=workspace:GetServerTimeNow();m:SetAttribute("RegionalImpactAt",stamp);tick()
            assert(workspace:GetServerTimeNow()-stamp<.2,"INCONCLUSIVE: impact stalled");assert(changed(idle,pose(m)),"No confirmed impact pose")
            reset(m);tick()
        end
        m:SetAttribute("CombatHealth",0);tick();identity(m)
        m:SetAttribute("CombatHealth",profiles[id].health);reset(m);tick()
        m.Parent=nil;tick();identity(m);m.Parent=workspace;tick();rootInvariant(m,cf)
        Tags:RemoveTag(m,tag);tick();identity(m);Tags:AddTag(m,tag);tick()
        table.insert(reports,{id=id,parts=parts,motors=joints,carriers=carriers,root={cf:GetComponents()}})
    end
    if GALLERY_SECONDS>0 then
        print("GREENWOOD_FRONT_GALLERY",game:GetService("HttpService"):JSONEncode(reports));task.wait(GALLERY_SECONDS/2)
        camera.CFrame=CFrame.lookAt(center+Vector3.new(28,11,-6),center+Vector3.new(0,4,0))
        print("GREENWOOD_SIDE_GALLERY");task.wait(GALLERY_SECONDS/2)
    end
    animator.Destroy();animator=nil;tick();for _,m in ipairs(actors) do identity(m) end
    return {status="PASS_LOCAL_GREENWOOD_COSMETICS",actors=reports,unchangedTemplates=10,profileCases=2,patternCases=2,serverCombatTested=false,visualApproval=false}
end,debug.traceback)
if animator then animator.Destroy() end
for _,m in ipairs(actors) do Tags:RemoveTag(m,tag);m:Destroy() end
if kit then kit:Destroy() end;if baseline then baseline:Destroy() end
workspace:SetAttribute(config.ReducedMotionAttribute,reduced)
camera.CameraType=oldType;camera.CFrame=oldFrame;camera.Focus=oldFocus
assert(ok,outcome);return outcome
