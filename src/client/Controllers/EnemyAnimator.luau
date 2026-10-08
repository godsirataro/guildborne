--!strict
-- Local cosmetic articulation; no network requests or authoritative root movement.
local Run=game:GetService("RunService")
local Tags=game:GetService("CollectionService")
local Config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local pose=require(script.Parent.ActionPose)
local jointNames={LeftUpperArm="LeftShoulder",RightUpperArm="RightShoulder",LeftLowerArm="LeftElbow",RightLowerArm="RightElbow",LeftUpperLeg="LeftHip",RightUpperLeg="RightHip",UpperTorso="Waist",LowerTorso="RootJoint",Head="Neck"}
return function()
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
    for _,instance in ipairs(Tags:GetTagged("GuildborneAnimatedEnemy")) do add(instance) end
    table.insert(connections,Tags:GetInstanceAddedSignal("GuildborneAnimatedEnemy"):Connect(add))
    table.insert(connections,Tags:GetInstanceRemovedSignal("GuildborneAnimatedEnemy"):Connect(function(instance)
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
            r.phase+=math.min(dt,.1)*(if moving then 9 else 1.7)
            local swing=if moving then math.sin(r.phase)*.4 elseif workspace:GetAttribute(Config.ReducedMotionAttribute) then 0 else math.sin(r.phase)*.025
            local actionAt=math.max(number(model,"EnemyActionAt"),number(model,"BossImpactAt"))
            local age=now-actionAt
            local telegraph=model:GetAttribute("TelegraphAt")
            if type(telegraph)=="number" and now>=telegraph and now-telegraph<(model:GetAttribute("TelegraphDuration") or 0) then age=math.min(.1,now-telegraph) end
            for j in pairs(r.joints) do
                if not j.Parent then r.joints[j]=nil;continue end
                local name=jointNames[j.Name]or j.Name:gsub(" ","")
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
