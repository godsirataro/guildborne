--!strict
local CollectionService=game:GetService("CollectionService")
local RunService=game:GetService("RunService")
local Motion=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local Work=require(game.ReplicatedStorage.Shared.Presentation.CivicWorkMotion)
type Actor={model:Model,motors:{[Motor6D]:CFrame},added:RBXScriptConnection?,removing:RBXScriptConnection?}
return function(collectionProvider:any?)
    local Collection=collectionProvider or CollectionService
    local actors:{[Instance]:Actor}={}
    local function remove(instance:Instance)
        local actor=actors[instance];if not actor then return end
        actors[instance]=nil
        if actor.added then actor.added:Disconnect()end
        if actor.removing then actor.removing:Disconnect()end
        for motor,base in pairs(actor.motors)do if motor.Parent then motor.C0=base end end
    end
    local function add(instance:Instance)
        if not instance:IsA("Model")or actors[instance]then return end
        local actor:Actor={model=instance,motors={}}
        local function joint(v:Instance)
            if v:IsA("Motor6D")and not actor.motors[v]then actor.motors[v]=v.C0 end
        end
        actors[instance]=actor
        actor.added=instance.DescendantAdded:Connect(joint)
        actor.removing=instance.DescendantRemoving:Connect(function(v)
            if v:IsA("Motor6D")then local base=actor.motors[v];if base then v.C0=base;actor.motors[v]=nil end end
        end)
        for _,v in ipairs(instance:GetDescendants())do joint(v)end
    end
    for _,instance in ipairs(Collection:GetTagged("GuildborneFriendlyNPC")) do add(instance) end
    local added=Collection:GetInstanceAddedSignal("GuildborneFriendlyNPC"):Connect(add)
    local removed=Collection:GetInstanceRemovedSignal("GuildborneFriendlyNPC"):Connect(remove)
    local frame=RunService.RenderStepped:Connect(function()
        local camera=workspace.CurrentCamera;if not camera then return end
        local now=workspace:GetServerTimeNow()
        for _,actor in pairs(actors) do
            local root=actor.model.PrimaryPart
            if not root or not actor.model:IsDescendantOf(workspace) then continue end
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
