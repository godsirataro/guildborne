--!strict
local CollectionService=game:GetService("CollectionService")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local Motion=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local Work=require(game.ReplicatedStorage.Shared.Presentation.CivicWorkMotion)
local BorinMotion=require(game.ReplicatedStorage.Shared.Presentation.BorinWorkMotion)
local Borin=require(game.ReplicatedStorage.Shared.Presentation.BorinPresentation)
local Audio=require(script.Parent.AudioController)
local function localBorinDialogueOpen(root:BasePart):boolean
    local player=Players.LocalPlayer
    local characterRoot=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not characterRoot or not characterRoot:IsA("BasePart") or (characterRoot.Position-root.Position).Magnitude>14 then return false end
    local gui=player:FindFirstChild("PlayerGui")
    local dialogue=gui and gui:FindFirstChild("FriendlyDialogue_smith_borin",true)
    local cursor:Instance?=dialogue
    if not cursor then return false end
    while cursor and cursor~=gui do
        if cursor:IsA("GuiObject") and not cursor.Visible then return false end
        if cursor:IsA("ScreenGui") and not cursor.Enabled then return false end
        cursor=cursor.Parent
    end
    return true
end
type Actor={model:Model,motors:{[Motor6D]:CFrame},added:RBXScriptConnection?,removing:RBXScriptConnection?,destroying:RBXScriptConnection?,borin:BorinMotion.State?,flashUntil:number?}
return function(collectionProvider:any?)
    local Collection=collectionProvider or CollectionService
    local actors:{[Instance]:Actor}={}
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
        local actor:Actor={model=instance,motors={}}
        if instance:GetAttribute("NpcId")=="smith_borin" then actor.borin=BorinMotion.new() end
        local function joint(v:Instance)
            if v:IsA("Motor6D")and not actor.motors[v]then actor.motors[v]=v.C0 end
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
            local root=actor.model.PrimaryPart
            if not root or not actor.model:IsDescendantOf(workspace) then
                for motor,base in pairs(actor.motors)do if motor.Parent then motor.C0=base end end
                if actor.borin then Borin.apply(actor.model,actor.motors,BorinMotion.step(actor.borin,now,nil,false,false,false)) end
                continue
            end
            if actor.borin then
                local distance=(root.Position-camera.CFrame.Position).Magnitude
                local rawUntil=actor.model:GetAttribute("BorinInteractUntil")
                local untilTime:number?=if type(rawUntil)=="number" then rawUntil else nil
                local interactorId=actor.model:GetAttribute("BorinInteractor")
                local interactor=if type(interactorId)=="number" then Players:GetPlayerByUserId(interactorId) else nil
                local interactorRoot=interactor and interactor.Character and interactor.Character:FindFirstChild("HumanoidRootPart")
                if interactorRoot and interactorRoot:IsA("BasePart") and (interactorRoot.Position-root.Position).Magnitude>14 then untilTime=nil end
                -- Existing visible local dialogue extends presentation only; no new remote or reward path.
                if localBorinDialogueOpen(root) then untilTime=math.max(if type(untilTime)=="number" then untilTime else 0,now+.2) end
                local sample=BorinMotion.step(actor.borin,now,untilTime,distance<=BorinMotion.CullDistance,workspace:GetAttribute(Motion.ReducedMotionAttribute)==true,actor.model:GetAttribute("EscortMoving")==true)
                actor.model:SetAttribute("BorinLocalPresentationState",sample.mode)
                actor.model:SetAttribute("BorinLocalWorkClock",sample.clock or 0)
                actor.model:SetAttribute("BorinLocalWorkWeight",sample.weight)
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
            if (root.Position-camera.CFrame.Position).Magnitude>160 then
                for motor,base in pairs(actor.motors) do motor.C0=base end
                continue
            end
            local at=actor.model:GetAttribute("GreetingAt")
            local elapsed=if type(at)=="number" then now-at else 10
            local wave=if elapsed>=0 and elapsed<1.8 then math.sin(math.pi*elapsed/1.8) else 0
            local idle=if workspace:GetAttribute(Motion.ReducedMotionAttribute) then 0 else 1
            local walk=if actor.model:GetAttribute("EscortMoving")==true then math.sin(now*8)*.38 else 0
            local identity=actor.model:GetAttribute("WorkMotionIdentity")
            local work=Work.sample(if type(identity)=="string"then identity else actor.model.Name,now,idle==0 or actor.model:GetAttribute("EscortMoving")==true)
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
                    local weight=1-wave
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
