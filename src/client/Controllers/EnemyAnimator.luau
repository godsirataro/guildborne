--!strict
-- Local cosmetic articulation; no network requests or authoritative root movement.
local Run=game:GetService("RunService")
local Tags=game:GetService("CollectionService")
local Config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local pose=require(script.Parent.ActionPose)
local jointNames={LeftUpperArm="LeftShoulder",RightUpperArm="RightShoulder",LeftLowerArm="LeftElbow",RightLowerArm="RightElbow",LeftUpperLeg="LeftHip",RightUpperLeg="RightHip",UpperTorso="Waist",LowerTorso="RootJoint",Head="Neck"}
-- Tower attacks are confirmed-hit events, not a new windup. Follow-through
-- begins at that event; only the server's real warning can raise the hammer.
local function towerPose(role: string,name: string,swing: number,breath: number,age: number,warning: number?,hitAge: number): CFrame
    local left=name:find("Left")~=nil;local sign=if left then -1 else 1
    local shoulder=name:find("Shoulder")~=nil;local hip=name:find("Hip")~=nil
    local boss=role=="Spire Warden";local archer=role=="Echo Archer"
    local x,y,z=0,0,0;local shift=Vector3.zero
    local follow=if age>=0 and age<.46 then (1-age/.46)^2 else 0
    local charge=if warning then math.sin(math.clamp(warning/.25,0,1)*math.pi/2) else 0
    if shoulder then
        x=(if left then -.24 else -.12)+swing*(if left then -.35 else .35)
        z=sign*(if boss then .18 else .07)
        if boss then
            if left then x-=.5*charge+.25*follow;z-=.2*charge
            else x-=2.05*charge;x+=.75*follow;y=-.25*charge+.25*follow;z+=.15*charge-.25*follow end
        elseif archer then
            -- Bow stays in the support hand while the drawing hand recoils.
            x=-.35+swing*.15-1.0*follow
            y=if left then -.22*follow else .8*follow
            z=if left then -.12 else .38*follow
        elseif left then x-=.35*follow;z-=.12*follow
        else x+=.4*follow;y=.7*follow;z-=.6*follow end
    elseif hip then
        x=swing*(if left then 1 else -1)-.12*charge
        z=sign*(if boss then .05+.06*charge else .025)
    elseif name=="RootJoint" then
        x=(if boss then .025 else 0)+.12*charge-.12*follow
        y=if archer then .12+.28*follow elseif boss then -.12*charge+.2*follow else .32*follow
        z=swing*(if boss then .055 else .035)
        shift=Vector3.new(0,breath-.1*charge,0)
    elseif name=="Neck" then x=-.08*charge+.08*follow;y=if archer then -.12 else -.08*follow end
    -- DamageCueAt excludes healing feedback. Never shake the authoritative root.
    if hitAge>=0 and hitAge<.18 and (name=="RootJoint" or name=="Neck") then
        x+=math.sin(hitAge/.18*math.pi)*.12
    end
    return CFrame.new(shift)*CFrame.Angles(x,y,z)
end
local function ironveilPose(boss: boolean,name: string,swing: number,breath: number,age: number,warning: number?,pattern: string,hitAge: number): CFrame
    local left=name:find("Left")~=nil;local sign=if left then -1 else 1
    local charge=if warning then math.sin(math.clamp(warning/.35,0,1)*math.pi/2) else 0
    local follow=if age>=0 and age<.5 and not warning then (1-age/.5)^2 else 0
    local fault=pattern=="Fault Line"
    local x,y,z=0,0,0;local shift=Vector3.zero
    if name:find("Shoulder") then
        x=(if left then -.12 else -.22)+swing*(if left then -.3 else .2)
        z=sign*(if boss then .16 else .09)
        if boss then
            if left then x-=.4*charge+.12*follow;z-=.2*charge
            else
                x-=(if fault then .95 else 1.85)*charge;x+=.65*follow
                y=(if fault then -.65 else -.12)*charge+.35*follow;z-=.2*follow
            end
        elseif not left then x+=.5*follow;y=.6*follow;z-=.5*follow
        else x-=.25*follow end
    elseif name:find("Hip") then
        x=swing*(if left then 1 else -1)-.10*charge;z=sign*(if boss then .055 else .025)
    elseif name=="RootJoint" then
        x=(if boss then .04 else .02)+.14*charge-.16*follow
        y=(if fault then -.3 else -.08)*charge+.3*follow
        z=swing*(if boss then .035 else .05)
        shift=Vector3.new(0,breath-.06*charge,0)
    elseif name=="Neck" then x=-.06*charge+.08*follow;y=-.1*follow end
    if hitAge>=0 and hitAge<.18 and (name=="RootJoint" or name=="Neck") then x+=math.sin(hitAge/.18*math.pi)*.1 end
    return CFrame.new(shift)*CFrame.Angles(x,y,z)
end
-- Greenwood receives confirmed strikes after damage; never replay a cast windup.
-- Only the current regional warning is allowed to anticipate an attack.
local function greenwoodPose(captain: boolean,name: string,swing: number,breath: number,age: number,warning: number?,pattern: string,hitAge: number): CFrame
    local left=name:find("Left")~=nil;local sign=if left then -1 else 1
    local charge=if warning then math.sin(math.clamp(warning/.3,0,1)*math.pi/2) else 0
    local follow=if not warning and age>=0 and age<.48 then (1-age/.48)^2 else 0
    local roots=pattern=="Root Burst"
    local x,y,z=0,0,0;local shift=Vector3.zero
    if name:find("Shoulder") then
        x=(if left and captain then -.32 else -.16)+swing*(if left then -.25 else .3)
        z=sign*(if captain then .12 else .06)
        if left then
            x-=(if roots then .7 else .35)*charge+.15*follow
            y=-.15*charge;z-=.10*charge
        else
            x-=(if roots then .75 else 1.35)*charge
            y=(if roots then -.1 else -.65)*charge+.75*follow
            z+=(if roots then .35 else .22)*charge-.45*follow
            x+=.55*follow
        end
    elseif name:find("Hip") then
        x=swing*(if left then 1 else -1)-(if roots then .16 else .06)*charge
        z=sign*((if captain then .045 else .02)+(if roots then .045 else .015)*charge)
    elseif name=="RootJoint" then
        x=.025+(if roots then .22 else .1)*charge-.12*follow
        y=(if roots then 0 else -.4)*charge+.38*follow
        z=swing*(if captain then .025 else .04)
        shift=Vector3.new(0,breath-(if roots then .12 else .035)*charge,0)
    elseif name=="Neck" then
        x=(if roots then .12 else -.05)*charge+.06*follow;y=.12*charge-.12*follow
    end
    if hitAge>=0 and hitAge<.18 and (name=="RootJoint" or name=="Neck") then x+=math.sin(hitAge/.18*math.pi)*.1 end
    return CFrame.new(shift)*CFrame.Angles(x,y,z)
end
return function(animationTag: string?)
    local tag=animationTag or "GuildborneAnimatedEnemy"
    local rigs: {[Model]: any}={}
    local connections: {RBXScriptConnection}={}
    local function add(instance: Instance)
        local model=if instance:IsA("Model") then instance else instance:FindFirstAncestorOfClass("Model")
        if not model or not model:IsDescendantOf(workspace) or not model:GetAttribute("GuildborneEnemy") then return end
        local rig=rigs[model]
        if not rig then
            rig={joints={},phase=0};rigs[model]=rig
            rig.added=model.DescendantAdded:Connect(function(child) if child:IsA("Motor6D") then rig.joints[child]=true end end)
        end
        if instance:IsA("Motor6D") then rig.joints[instance]=true
        elseif instance:IsA("Model") then for _,j in ipairs(instance:GetDescendants()) do if j:IsA("Motor6D") then rig.joints[j]=true end end end
    end
    local function reset(rig: any)
        for j in pairs(rig.joints) do if j.Parent then j.Transform=CFrame.identity end end
    end
    local function remove(model: Model)
        local rig=rigs[model];if not rig then return end
        reset(rig);rig.added:Disconnect();rigs[model]=nil
    end
    local function number(model: Model,name: string): number
        local value=model:GetAttribute(name);return if type(value)=="number" and value==value and math.abs(value)<math.huge then value else 0
    end
    for _,instance in ipairs(Tags:GetTagged(tag)) do add(instance) end
    table.insert(connections,Tags:GetInstanceAddedSignal(tag):Connect(add))
    table.insert(connections,Tags:GetInstanceRemovedSignal(tag):Connect(function(instance)
        if instance:IsA("Model") then remove(instance) end
    end))
    table.insert(connections,Run.PreSimulation:Connect(function(dt: number)
        local camera=workspace.CurrentCamera;local now=workspace:GetServerTimeNow()
        for model,r in pairs(rigs) do
            local root=model.PrimaryPart
            if not model:IsDescendantOf(workspace) then
                if r.posed then reset(r);r.posed=false end
                continue
            end
            if not root or not camera or (root.Position-camera.CFrame.Position).Magnitude>90 or (model:GetAttribute("CombatHealth") or 0)<=0 then
                if r.posed then reset(r);r.posed=false end
                continue
            end
            local state=model:GetAttribute("CombatState")
            local moving=state=="Approach" or state=="ReturnToLeader"
            local role=tostring(model:GetAttribute("VisualRole"))
            local tower=role=="Echo Guard" or role=="Echo Archer" or role=="Spire Warden"
            local encounter=model:GetAttribute("EncounterId")
            local ironveil=model:GetAttribute("EnemyVisualStyle")=="IronveilForgedV1" and (encounter=="quarry_raider" or encounter=="quarry_guardian")
            local guardian=ironveil and encounter=="quarry_guardian"
            local greenwood=model:GetAttribute("EnemyVisualStyle")=="GreenwoodForgedV1" and (encounter=="greenwood_scout" or encounter=="forest_captain")
            local captain=greenwood and encounter=="forest_captain"
            r.phase+=math.min(dt,.1)*(if moving then (if captain then 6 elseif greenwood then 9 elseif guardian then 5.5 elseif ironveil then 8 elseif tower and role=="Spire Warden" then 6.5 else 9) else 1.7)
            local swing=if moving then math.sin(r.phase)*.4 elseif workspace:GetAttribute(Config.ReducedMotionAttribute) then 0 else math.sin(r.phase)*.025
            local actionAt=math.max(number(model,"EnemyActionAt"),number(model,"BossImpactAt"))
            if tower then
                local basic,impact=number(model,"EnemyActionAt"),number(model,"BossImpactAt")
                actionAt=math.max(if basic<=now then basic else 0,if impact<=now then impact else 0)
            end
            local age=now-actionAt
            local telegraph=model:GetAttribute("TelegraphAt")
            local warning: number?=nil
            if type(telegraph)=="number" and telegraph>0 and now>=telegraph and now-telegraph<number(model,"TelegraphDuration") then
                if tower then warning=now-telegraph else age=math.min(.1,now-telegraph) end
            end
            if ironveil then
                -- Regional warning clocks are distinct from Tower's circular marker.
                -- Confirmed hit events begin follow-through immediately, never a new windup.
                local basic,impact=number(model,"EnemyActionAt"),number(model,"RegionalImpactAt")
                actionAt=math.max(if basic<=now then basic else 0,if impact<=now then impact else 0)
                age=if actionAt>0 then now-actionAt else -1
                local started,untilAt=number(model,"RegionalTelegraphAt"),number(model,"RegionalTelegraphUntil")
                warning=if guardian and state=="Windup" and started>0 and started<=now and untilAt>now and untilAt>started then now-started else nil
                r.moveBlend=(r.moveBlend or 0)+((if moving then 1 else 0)-(r.moveBlend or 0))*(1-math.exp(-math.min(dt,.1)*10))
                swing=math.sin(r.phase)*r.moveBlend*(if guardian then .22 else .34)
                if warning then swing*=.2 end
            end
            if tower then
                r.moveBlend=(r.moveBlend or 0)+((if moving then 1 else 0)-(r.moveBlend or 0))*(1-math.exp(-math.min(dt,.1)*12))
                swing=math.sin(r.phase)*r.moveBlend*(if role=="Spire Warden" then .23 else .34)
                if warning then swing*=.25 end
            end
            if greenwood then
                local basic,impact=number(model,"EnemyActionAt"),number(model,"RegionalImpactAt")
                actionAt=math.max(if basic>0 and basic<=now then basic else 0,if impact>0 and impact<=now then impact else 0)
                age=if actionAt>0 then now-actionAt else -1
                local started,untilAt=number(model,"RegionalTelegraphAt"),number(model,"RegionalTelegraphUntil")
                local pattern=model:GetAttribute("TelegraphName")
                warning=if captain and state=="Windup" and (pattern=="Antler Cleave" or pattern=="Root Burst")
                    and started>0 and started<=now and untilAt>now and untilAt>started then now-started else nil
                r.moveBlend=(r.moveBlend or 0)+((if moving then 1 else 0)-(r.moveBlend or 0))*(1-math.exp(-math.min(dt,.1)*10))
                swing=math.sin(r.phase)*r.moveBlend*(if captain then .23 else .34)
                if warning then swing*=.15 end
            end
            for j in pairs(r.joints) do
                if not j.Parent then r.joints[j]=nil;continue end
                local name=jointNames[j.Name]or j.Name:gsub(" ","")
                if greenwood then
                    local breath=if workspace:GetAttribute(Config.ReducedMotionAttribute) then 0 else math.sin(r.phase)*.008
                    j.Transform=greenwoodPose(captain,name,swing,breath,age,warning,tostring(model:GetAttribute("TelegraphName")),now-number(model,"DamageCueAt"))
                    continue
                end
                if ironveil then
                    local breath=if workspace:GetAttribute(Config.ReducedMotionAttribute) then 0 else math.sin(r.phase)*.008
                    j.Transform=ironveilPose(guardian,name,swing,breath,age,warning,tostring(model:GetAttribute("TelegraphName")),now-number(model,"DamageCueAt"))
                    continue
                end
                if tower then
                    local breath=if workspace:GetAttribute(Config.ReducedMotionAttribute) then 0 else math.sin(r.phase)*.012
                    j.Transform=towerPose(role,name,swing,breath,if actionAt>0 then age else -1,warning,now-number(model,"DamageCueAt"))
                    continue
                end
                local limb=name:find("Shoulder") or name:find("Hip")
                local sign=if name=="LeftShoulder" or name=="RightHip" then 1 else -1
                local base=if limb then CFrame.Angles(swing*sign,0,0) else CFrame.identity
                local action=pose(tostring(model:GetAttribute("EnemyAnimationClass")),"Basic",age,name)
                local hit=now-(model:GetAttribute("FeedbackAt") or 0)<.18
                j.Transform=if action then base*action elseif limb and hit then base*CFrame.Angles(.15*sign,0,0) else base
            end
            r.posed=true
        end
    end))
    return {Destroy=function()
        for _,connection in ipairs(connections) do connection:Disconnect() end
        for model in pairs(rigs) do remove(model) end
        table.clear(rigs)
    end}
end
