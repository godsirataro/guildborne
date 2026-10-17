--!strict
local CollectionService=game:GetService("CollectionService")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local Motion=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local Work=require(game.ReplicatedStorage.Shared.Presentation.CivicWorkMotion)
local BorinMotion=require(game.ReplicatedStorage.Shared.Presentation.BorinWorkMotion)
local Borin=require(game.ReplicatedStorage.Shared.Presentation.BorinPresentation)
local Audio=require(script.Parent.AudioController)
local Life=assert(require(game.ReplicatedStorage.Shared.Data.NpcLifeSchedule)(require(game.ReplicatedStorage.Shared.Config.NpcLifeDefinitions),require(game.ReplicatedStorage.Shared.Config.FriendlyNpcs),{Journal={}}))
local function localDialogueOpen(root:BasePart,id:string):boolean
    local player=Players.LocalPlayer
    local characterRoot=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not characterRoot or not characterRoot:IsA("BasePart") or (characterRoot.Position-root.Position).Magnitude>14 then return false end
    local gui=player:FindFirstChild("PlayerGui")
    local dialogue=gui and gui:FindFirstChild("FriendlyDialogue_"..id,true)
    local cursor:Instance?=dialogue
    if not cursor then return false end
    while cursor and cursor~=gui do
        if cursor:IsA("GuiObject") and not cursor.Visible then return false end
        if cursor:IsA("ScreenGui") and not cursor.Enabled then return false end
        cursor=cursor.Parent
    end
    return true
end
type Actor={model:Model,motors:{[Motor6D]:CFrame},added:RBXScriptConnection?,removing:RBXScriptConnection?,destroying:RBXScriptConnection?,borin:BorinMotion.State?,flashUntil:number?,id:string?,nextSample:number,tier:string?,activity:string,interactUntil:number?,localDialogueUntil:number?,weight:number,restored:boolean,lastTime:number?}
return function(collectionProvider:any?)
    local Collection=collectionProvider or CollectionService
    local actors:{[Instance]:Actor}={}
    local function attribute(actor:Actor,name:string,value:any)
        if actor.model:GetAttribute(name)~=value then actor.model:SetAttribute(name,value) end
    end
    local function restore(actor:Actor)
        if actor.restored then return end
        for motor,base in pairs(actor.motors)do if motor.Parent then motor.C0=base end end
        local flash=actor.model:FindFirstChild("BorinContactFlash",true)
        if flash and flash:IsA("PointLight") then flash.Enabled=false end
        actor.flashUntil=nil;actor.restored=true
    end
    local function remove(instance:Instance)
        local actor=actors[instance];if not actor then return end
        actors[instance]=nil
        if actor.added then actor.added:Disconnect()end
        if actor.removing then actor.removing:Disconnect()end
        if actor.destroying then actor.destroying:Disconnect()end
        for motor,base in pairs(actor.motors)do if motor.Parent then motor.C0=base end end
        local flash=actor.model:FindFirstChild("BorinContactFlash",true)
        if flash and flash:IsA("PointLight") then flash.Enabled=false end
    end
    local function add(instance:Instance)
        if not instance:IsA("Model")or actors[instance]then return end
        local actor:Actor={model=instance,motors={},id=Life.resolve(instance:GetAttribute("NpcId")),nextSample=0,activity="Work",weight=0,restored=false}
        if instance:GetAttribute("NpcId")=="smith_borin" then actor.borin=BorinMotion.new() end
        local function joint(v:Instance)
            if v:IsA("Motor6D")and not actor.motors[v]then actor.motors[v]=v.C0;actor.restored=false end
        end
        actors[instance]=actor
        actor.added=instance.DescendantAdded:Connect(joint)
        actor.removing=instance.DescendantRemoving:Connect(function(v)
            if v:IsA("Motor6D")then local base=actor.motors[v];if base then v.C0=base;actor.motors[v]=nil end end
        end)
        for _,v in ipairs(instance:GetDescendants())do joint(v)end
        actor.destroying=instance.Destroying:Connect(function()remove(instance)end)
    end
    for _,instance in ipairs(Collection:GetTagged("GuildborneFriendlyNPC")) do add(instance) end
    local added=Collection:GetInstanceAddedSignal("GuildborneFriendlyNPC"):Connect(add)
    local removed=Collection:GetInstanceRemovedSignal("GuildborneFriendlyNPC"):Connect(remove)
    local frame=RunService.RenderStepped:Connect(function()
        local camera=workspace.CurrentCamera;if not camera then return end
        local now=workspace:GetServerTimeNow()
        for _,actor in pairs(actors) do
            local dt=if actor.lastTime then now-actor.lastTime else 0;actor.lastTime=now
            local root=actor.model.PrimaryPart
            if not root or not actor.model:IsDescendantOf(workspace) then
                restore(actor);actor.weight=0;actor.nextSample=0
                if actor.borin then BorinMotion.step(actor.borin,now,nil,false,false,false) end
                continue
            end
            local distance=(root.Position-camera.CFrame.Position).Magnitude
            local reduced=workspace:GetAttribute(Motion.ReducedMotionAttribute)==true
            local moving=actor.model:GetAttribute("EscortMoving")==true
            -- Day phase uses the world's existing clock; interaction deadlines use server time.
            -- Near dialogue scans are capped at ten per second, and far actors do no GUI scans.
            if now>=actor.nextSample or (actor.tier=="Far" and distance<=140) then
                local sample=if actor.id then Life.sample(actor.id,Lighting.ClockTime*3600,distance,actor.tier) else nil
                actor.tier=if sample then sample.tier elseif distance>160 then "Far" else "Near"
                actor.activity=if sample then sample.activity else "Work"
                actor.nextSample=now+(if sample then sample.updateSeconds else .1)
                local rawUntil=actor.model:GetAttribute(if actor.borin then "BorinInteractUntil" else "NpcInteractUntil")
                local untilTime:number?=if type(rawUntil)=="number" and rawUntil==rawUntil and rawUntil<math.huge then math.min(rawUntil,now+BorinMotion.InteractSeconds) else nil
                local interactorId=actor.model:GetAttribute(if actor.borin then "BorinInteractor" else "NpcInteractor")
                local interactor=if type(interactorId)=="number" then Players:GetPlayerByUserId(interactorId) else nil
                local interactorRoot=interactor and interactor.Character and interactor.Character:FindFirstChild("HumanoidRootPart")
                -- A streamed-out character cannot extend this absolute server deadline.
                -- A departed player or a known distant root cancels the shared hint.
                if not interactor or (interactorRoot and interactorRoot:IsA("BasePart") and (interactorRoot.Position-root.Position).Magnitude>14) then untilTime=nil end
                if actor.id and actor.tier~="Far" and localDialogueOpen(root,actor.id) then
                    actor.localDialogueUntil=now+.2;actor.nextSample=now+.1
                end
                if actor.localDialogueUntil then untilTime=math.max(untilTime or 0,actor.localDialogueUntil) end
                actor.interactUntil=untilTime
                attribute(actor,"NpcLifeScheduledActivity",actor.activity)
                attribute(actor,"NpcLifeTier",actor.tier)
            end
            if actor.borin then
                local sample=BorinMotion.step(actor.borin,now,actor.interactUntil,distance<=BorinMotion.CullDistance,reduced,moving,actor.activity=="Work")
                attribute(actor,"BorinLocalPresentationState",sample.mode)
                attribute(actor,"BorinLocalWorkClock",sample.clock or 0)
                attribute(actor,"BorinLocalWorkWeight",sample.weight)
                attribute(actor,"NpcLifeWorkWeight",sample.weight)
                attribute(actor,"NpcLifeActivity",if sample.mode=="Idle" then actor.activity else sample.mode)
                if distance>BorinMotion.CullDistance or reduced or moving then restore(actor);continue end
                actor.restored=false
                if actor.model:GetAttribute("DetailedBorinPreview")==true then
                    Borin.apply(actor.model,actor.motors,{weight=0})
                    actor.flashUntil=nil
                    continue -- Isolated authored-mesh adapter owns that preview's pose/effects.
                end
                local contact=Borin.apply(actor.model,actor.motors,sample)
                if contact and distance<=BorinMotion.DetailDistance then
                    actor.flashUntil=now+.1
                    local target=actor.model:FindFirstChild("BorinContactTarget",true)
                    if target and target:IsA("Attachment") then Audio.PlayFor(actor.model,"forge_strike",target.WorldPosition) end
                end
                local flash=actor.model:FindFirstChild("BorinContactFlash",true)
                if flash and flash:IsA("PointLight") then flash.Enabled=sample.mode=="Work" and distance<=BorinMotion.DetailDistance and now<(actor.flashUntil or 0) end
                continue -- Borin adapter is this actor's only pose owner.
            end
            if actor.tier=="Far" or distance>160 or reduced then
                restore(actor);actor.weight=0;attribute(actor,"NpcLifeWorkWeight",0)
                attribute(actor,"NpcLifeActivity",actor.activity)
                continue
            end
            actor.restored=false
            local interacting=actor.interactUntil~=nil and actor.interactUntil>now
            actor.weight=BorinMotion.activityWeight(actor.weight,dt,actor.activity=="Work" and not interacting,moving)
            attribute(actor,"NpcLifeWorkWeight",actor.weight)
            attribute(actor,"NpcLifeActivity",if interacting then "Interact" elseif actor.activity=="Work" and actor.weight<1 and not moving then "Recover" else actor.activity)
            local at=actor.model:GetAttribute("GreetingAt")
            local elapsed=if type(at)=="number" then now-at else 10
            local wave=if elapsed>=0 and elapsed<1.8 then math.sin(math.pi*elapsed/1.8) else 0
            local idle=1
            local walk=if moving then math.sin(now*8)*.38 else 0
            local identity=actor.model:GetAttribute("WorkMotionIdentity")
            local work=Work.sample(if type(identity)=="string"then identity else actor.model.Name,now,moving)
            for motor,base in pairs(actor.motors) do
                local name=motor.Name
                local offset=CFrame.identity
                if name=="UpperTorso" then offset=CFrame.Angles(0,0,idle*.012*math.sin(now*2))
                elseif name=="Head" then offset=CFrame.Angles(0,idle*.035*math.sin(now*.8),0)
                elseif name=="LeftUpperArm" then offset=CFrame.Angles(walk,0,0)
                elseif name=="LeftUpperLeg" then offset=CFrame.Angles(-walk,0,0)
                elseif name=="RightUpperLeg" then offset=CFrame.Angles(walk,0,0)
                elseif name=="RightUpperArm" then offset=CFrame.Angles(-walk,0,-1.4*wave)
                elseif name=="RightLowerArm" then offset=CFrame.Angles(0,0,.2*wave*math.sin(elapsed*16)) end
                local angles=work[name]
                if angles then
                    local weight=(1-wave)*actor.weight
                    offset=offset*CFrame.Angles(angles[1]*weight,angles[2]*weight,angles[3]*weight)
                end
                motor.C0=base*offset
            end
        end
    end)
    return {Destroy=function()
        frame:Disconnect();added:Disconnect();removed:Disconnect()
        for instance in pairs(actors)do remove(instance)end
    end}
end
