--!strict
-- Local readability only: owned Following companions between camera and commander fade temporarily.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
return function()
    local player=Players.LocalPlayer
    local tracked:{[Model]:any}={};local watched:{[Model]:RBXScriptConnection}={}
    local function restore(entry:any)
        for part,original in pairs(entry.saved) do if part.Parent then part.LocalTransparencyModifier=original end end
        table.clear(entry.saved)
    end
    local function untrack(model:Model)
        local entry=tracked[model]
        if entry then restore(entry);entry.added:Disconnect();entry.removing:Disconnect();tracked[model]=nil end
        local watcher=watched[model];if watcher then watcher:Disconnect();watched[model]=nil end
    end
    local function track(model:Model)
        if tracked[model] or model:GetAttribute("GuildborneHero")~=true then return end
        local entry:any={parts={},saved={}}
        local function added(part:Instance) if part:IsA("BasePart") then entry.parts[part]=true end end
        for _,part in ipairs(model:GetDescendants()) do added(part) end
        entry.added=model.DescendantAdded:Connect(added)
        entry.removing=model.DescendantRemoving:Connect(function(part)
            if part:IsA("BasePart") then
                if entry.saved[part]~=nil then part.LocalTransparencyModifier=entry.saved[part];entry.saved[part]=nil end
                entry.parts[part]=nil
            end
        end)
        tracked[model]=entry
    end
    local function added(instance:Instance)
        if not instance:IsA("Model") or watched[instance] then return end
        watched[instance]=instance:GetAttributeChangedSignal("GuildborneHero"):Connect(function() track(instance) end)
        track(instance)
    end
    for _,instance in ipairs(workspace:GetDescendants()) do added(instance) end
    local addConnection=workspace.DescendantAdded:Connect(added)
    local removeConnection=workspace.DescendantRemoving:Connect(function(instance) if instance:IsA("Model") then untrack(instance) end end)
    local elapsed=0
    local function update()
        local camera=workspace.CurrentCamera;local character=player.Character
        local focus=character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")) :: BasePart?
        for model,entry in pairs(tracked) do
            local root=model.PrimaryPart;local fade=false
            if camera and focus and root and model:GetAttribute("GuildborneHero")==true and model:GetAttribute("OwnerUserId")==player.UserId and model:GetAttribute("HeroState")=="Following" then
                local start=camera.CFrame.Position;local ray=focus.Position-start;local point=root.Position+Vector3.new(0,1.3,0)
                local length=ray.Magnitude
                if length>.5 then
                    local projection=(point-start):Dot(ray.Unit)
                    local nearest=start+ray.Unit*math.clamp(projection,0,length)
                    fade=(projection>0 and projection<length and (point-nearest).Magnitude<2.7) or (point-start).Magnitude<3.5
                else fade=(point-start).Magnitude<4 end
            end
            if fade then
                for part in pairs(entry.parts) do
                    if part.Transparency<1 then
                        if entry.saved[part]==nil then entry.saved[part]=part.LocalTransparencyModifier end
                        part.LocalTransparencyModifier=math.max(entry.saved[part],.82)
                    end
                end
            else restore(entry) end
        end
    end
    local tickConnection=RunService.PreRender:Connect(function(dt)
        elapsed+=dt;if elapsed<.05 then return end;elapsed=0;update()
    end)
    return {update=update,destroy=function()
        tickConnection:Disconnect();addConnection:Disconnect();removeConnection:Disconnect()
        for model in pairs(tracked) do untrack(model) end
        for model,connection in pairs(watched) do connection:Disconnect();watched[model]=nil end
    end}
end
