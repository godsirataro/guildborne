-- COMPILE-ONLY until controller runs on local CLIENT in unsaved Studio.
-- Install exact source copies under ReplicatedStorage.IronveilProbeModules:
-- AdventureEnemyKit, EnemyArticulation, EnemyAnimator, ActionPose,
-- AdventureEnemyProfiles, AdventureStats, AdventurePatterns; plus
-- BaselineAdventureEnemyKit from commit 3279e6d (untouched baseline source).
-- ActionPose is EnemyAnimator's sibling. Normal bootstrap supplies Shared
-- Config.VFXConfig and Presentation.ActionTimeline. No authoritative gameplay services/remotes run.
-- Tests synthetic cosmetics and pure contracts, not authoritative combat or UAT.
local Run=game:GetService("RunService")
assert(Run:IsStudio() and Run:IsClient() and game.PlaceId==0 and game.GameId==0,"Unsaved local CLIENT only")
local Tags=game:GetService("CollectionService")
local modules=assert(game.ReplicatedStorage:FindFirstChild("IronveilProbeModules"))
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
local tag="GuildborneIronveilProbeOnly"
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
        if m.Name~="quarry_raider" and m.Name~="quarry_guardian" then
            local prior=assert(baseline:FindFirstChild(m.Name));assert(signature(m)==signature(prior),"Unowned template changed: "..m.Name)
            for _,key in ipairs({"Region","VisualRole","RigType","TemplateOnly"}) do assert(m:GetAttribute(key)==prior:GetAttribute(key)) end
            unaffected+=1
        end
    end
    assert(unaffected==10)
    local expected={quarry_raider={210,18,12,5,26,30,1.5},quarry_guardian={950,32,8,20,30,32,2}}
    for id,values in pairs(expected) do
        local p=profiles[id]
        for i,key in ipairs({"health","power","speed","range","detect","leash","interval"}) do assert(p[key]==values[i],"Gameplay profile changed") end
        local s=stats.build(p,if id=="quarry_guardian" then "Boss" else "Melee")
        assert(s.MaxHealth==values[1] and s.Attack==values[2] and s.Defense==3 and s.MoveSpeed==values[3] and s.AttackRange==values[4] and s.AttackInterval==values[7])
    end
    local a={templateId="quarry_guardian",health=400,maxHealth=950,position={x=0,y=0,z=0},patternCount=0}
    local target={x=0,y=0,z=-8}
    local hammer=assert(patterns.begin(a,target,10))
    assert(hammer.name=="Hammer Fall" and hammer.shape=="Circle" and hammer.radius==6 and hammer.targeted and hammer.duration==1.4 and hammer.recovery==1.8)
    patterns.cancel(a,10)
    local fault=assert(patterns.begin(a,target,20))
    assert(fault.name=="Fault Line" and fault.shape=="Line" and fault.length==22 and fault.width==5 and fault.duration==1.7 and fault.recovery==2.2)
    animator=animate(tag)
    local reports={}
    for index,id in ipairs({"quarry_raider","quarry_guardian"}) do
        local m=assert(kit:FindFirstChild(id)):Clone();m.Parent=nil;table.insert(actors,m)
        local prior=assert(baseline:FindFirstChild(id))
        for _,name in ipairs({"Head","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"}) do
            local p,b=assert(m:FindFirstChild(name)),assert(prior:FindFirstChild(name))
            assert(p.Size==b.Size and diff(p.CFrame,b.CFrame)<.000001 and p:GetAttribute("BindBone")==b:GetAttribute("BindBone"),"Authored socket changed: "..name)
        end
        local wedges,cylinders=0,0
        for _,item in ipairs(m:GetDescendants()) do
            if item:IsA("WedgePart") then wedges+=1 elseif item:IsA("Part") and item.Shape==Enum.PartType.Cylinder then cylinders+=1 end
            assert(not item:IsA("ParticleEmitter") and not item:IsA("Beam") and not item:IsA("Trail") and not item:IsA("Light"),"Unexpected effect budget")
        end
        assert(wedges>0 and cylinders>0,"Native shape vocabulary missing")
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
        local expectedParts=if id=="quarry_raider" then 63 else 65
        assert(joints==6 and carriers==6 and parts==expectedParts and m:GetAttribute("EnemyVisualPartCount")==parts,"Actor budget/binding count")
        local weapons=if id=="quarry_raider" then {"PickHaft","PickCrossbar","PickPoint","PickAdze"} else {"HammerHaft","HammerHead","HammerFace","HammerBevel","HammerClamp"}
        for _,name in ipairs({"WeaponGrip","WeaponPommel","WeaponSocket"}) do table.insert(weapons,name) end
        for _,name in ipairs(weapons) do
            local found=0
            for _,p in ipairs(m:GetChildren()) do if p.Name==name then
                assert(p:GetAttribute("BindBone")=="RightHand" and p:GetAttribute("EnemyLimb")=="RightArm","Weapon escaped right-hand binding");found+=1
            end end
            assert(found>0,"Missing weapon geometry: "..name)
        end
        assert(m:GetAttribute("EnemyVisualStyle")=="IronveilForgedV1")
        m.Parent=workspace;Tags:AddTag(m,tag);tick();local idle=pose(m)
        m:SetAttribute("CombatState","Approach");task.wait(.2);tick();assert(changed(idle,pose(m)),"No walking pose")
        reset(m);task.wait(.9);tick();idle=pose(m)
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
        if id=="quarry_guardian" then
            local warnings={}
            for _,name in ipairs({"Hammer Fall","Fault Line"}) do
                stamp=workspace:GetServerTimeNow();m:SetAttribute("CombatState","Windup");m:SetAttribute("TelegraphName",name)
                m:SetAttribute("RegionalTelegraphAt",stamp);m:SetAttribute("RegionalTelegraphUntil",stamp+.8)
                task.wait(.3);tick();assert(workspace:GetServerTimeNow()-stamp<.7,"INCONCLUSIVE: warning stalled")
                warnings[name]=pose(m);assert(changed(idle,warnings[name]),"Missing committed warning pose")
                reset(m);tick();assert(not changed(idle,pose(m)),"Cancelled warning persists")
            end
            assert(changed(warnings["Hammer Fall"],warnings["Fault Line"]),"Warnings indistinguishable")
            stamp=workspace:GetServerTimeNow();m:SetAttribute("CombatState","Windup");m:SetAttribute("TelegraphName","Hammer Fall")
            m:SetAttribute("RegionalTelegraphAt",stamp);m:SetAttribute("RegionalTelegraphUntil",stamp+.3)
            task.wait(.4);tick();assert(not changed(idle,pose(m)),"Expired warning persists")
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
    if GALLERY_SECONDS>0 then print("IRONVEIL_FRONT_GALLERY",game:GetService("HttpService"):JSONEncode(reports));task.wait(GALLERY_SECONDS) end
    animator.Destroy();animator=nil;tick();for _,m in ipairs(actors) do identity(m) end
    return {status="PASS_LOCAL_IRONVEIL_COSMETICS",actors=reports,unchangedTemplates=10,profileCases=2,patternCases=2,serverCombatTested=false,visualApproval=false}
end,debug.traceback)
if animator then animator.Destroy() end
for _,m in ipairs(actors) do Tags:RemoveTag(m,tag);m:Destroy() end
if kit then kit:Destroy() end;if baseline then baseline:Destroy() end
workspace:SetAttribute(config.ReducedMotionAttribute,reduced)
camera.CameraType=oldType;camera.CFrame=oldFrame;camera.Focus=oldFocus
assert(ok,outcome);return outcome
