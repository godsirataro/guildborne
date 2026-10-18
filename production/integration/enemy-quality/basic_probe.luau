-- Actual LOCAL CLIENT probe, unsaved Studio after full-game bootstrap.
-- Source-copy/compile only until controller runs it. No remotes/combat/audio.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0,"Unsaved Studio only")
local player=assert(game.Players.LocalPlayer)
local factory=require(player.PlayerScripts.Client.Controllers.SkillEffects)
local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local camera=assert(workspace.CurrentCamera)
local oldType,oldFrame,oldFocus=camera.CameraType,camera.CFrame,camera.Focus
local quality=workspace:GetAttribute(config.QualityAttribute)
local probeFrame=oldFrame+Vector3.new(0,10000,0)
local center=probeFrame:PointToWorldSpace(Vector3.new(0,0,-12))
-- Refuse populated fixture space before installing observers or changing camera.
assert(#workspace:GetPartBoundsInRadius(center,40)==0,"Probe requires empty isolated space")
local actors,parts={},{}
local connection=workspace.DescendantAdded:Connect(function(item)
    if item:IsA("Part") and item.Name=="GuildborneSkillEffect" and (item.Position-center).Magnitude<20 then table.insert(parts,item) end
end)
local function actor(age)
    local model=Instance.new("Model");model.Name="BasicTimingProbe"
    local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Anchored=true;root.Transparency=1;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.Position=center;root.Parent=model;model.PrimaryPart=root
    local hand=root:Clone();hand.Name="RightHand";hand.Parent=model
    model:SetAttribute("ClassId","Warrior");model:SetAttribute("ActionEffect","Basic");model:SetAttribute("CombatHealth",100)
    model:SetAttribute("ActionTargetPosition",center+Vector3.new(0,0,-4));model:SetAttribute("ActionAt",workspace:GetServerTimeNow()-age)
    table.insert(actors,model);model.Parent=workspace;return model
end
local function counts(start)
    local release,contact=0,0
    for i=start+1,#parts do
        local p=parts[i]
        if p:GetAttribute("VFXFamily")=="Warrior.Basic" then
            assert(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery)
            if p:GetAttribute("VFXStage")=="Release" then release+=1 else contact+=1 end
        end
    end
    assert(release<=12 and contact<=4,"Basic budget exceeded")
    return release,contact
end
local function at(stamp,age)
    while workspace:GetServerTimeNow()<stamp+age do task.wait() end
end
local function empty(start,model)
    for i=start+1,#parts do
        local p=parts[i]
        if p:GetAttribute("VFXFamily")=="Warrior.Basic" then assert(p.Parent==nil,"Active Basic part leaked") end
    end
    assert(not model:FindFirstChild("GuildborneCastTrail",true),"Trail leaked")
    assert(not model:FindFirstChildWhichIsA("Attachment",true),"Attachment leaked")
end
local ok,err=xpcall(function()
    camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=probeFrame;camera.Focus=CFrame.new(center)
    for _,mode in ipairs({"High","Low"}) do
        workspace:SetAttribute(config.QualityAttribute,mode)
        for _,age in ipairs({0,.15,.30}) do
            local start=#parts;local model=actor(age);local cast=factory();local stamp=model:GetAttribute("ActionAt")
            cast(model);cast(model) -- duplicate must not queue another action
            if age==0 then
                task.wait();assert(workspace:GetServerTimeNow()-stamp<.10,"INCONCLUSIVE: frame stall before release")
                local r,c=counts(start);assert(r==0 and c==0,"Immediate Basic VFX")
                at(stamp,.15);task.wait();assert(workspace:GetServerTimeNow()-stamp<.24,"INCONCLUSIVE: frame stall before contact")
                r,c=counts(start);assert(r>0 and c==0,"Release/contact ordering")
            end
            at(stamp,.50);task.wait()
            local r,c=counts(start)
            assert(r==(if age==0 then (if mode=="Low" or game:GetService("UserInputService").TouchEnabled then 8 else 12) else 0))
            assert(c==(if age<.24 then 4 else 0),"Late or duplicate contact")
            at(stamp,.75);task.wait();empty(start,model);model:Destroy()
        end
    end
    for _,phase in ipairs({.05,.15,.28}) do
        for _,kind in ipairs({"replacement","clear","death","removal"}) do
            local start=#parts;local model=actor(0);local cast=factory();local stamp=model:GetAttribute("ActionAt");cast(model)
            at(stamp,phase)
            assert(workspace:GetServerTimeNow()-stamp<phase+.06,"INCONCLUSIVE: cancellation phase missed")
            local beforeR,beforeC=counts(start)
            if phase==.05 then
                assert(workspace:GetServerTimeNow()-stamp<.10 and beforeR==0 and beforeC==0,"INCONCLUSIVE: pre-release window missed")
            elseif phase==.15 then
                assert(workspace:GetServerTimeNow()-stamp<.24 and beforeR>0 and beforeC==0,"INCONCLUSIVE: live sweep not observed")
                assert(model:FindFirstChild("GuildborneCastTrail",true),"Expected live sweep trail")
            else assert(beforeC==4,"INCONCLUSIVE: contact not observed before cancellation") end
            if phase~=.05 then
                local live=false
                for i=start+1,#parts do
                    if parts[i]:GetAttribute("VFXFamily")=="Warrior.Basic" and parts[i].Parent then live=true end
                end
                assert(live,"INCONCLUSIVE: no active geometry before cancellation")
            end
            if kind=="replacement" then model:SetAttribute("ActionAt",workspace:GetServerTimeNow())
            elseif kind=="clear" then model:SetAttribute("ActionAt",nil)
            elseif kind=="death" then model:SetAttribute("CombatHealth",0)
            else model.Parent=nil end
            task.wait();empty(start,model)
            local r,c=counts(start);at(stamp,.80);task.wait();local rr,cc=counts(start)
            assert(r==rr and c==cc,"Cancelled callback created a stage");empty(start,model);model:Destroy()
        end
    end
    local start=#parts;local model=actor(0);local cast=factory();cast(model)
    at(model:GetAttribute("ActionAt"),.15)
    model:SetAttribute("ActionAt",nil);task.wait();empty(start,model)
    local replacement=#parts;model:SetAttribute("ActionAt",workspace:GetServerTimeNow());cast(model)
    at(model:GetAttribute("ActionAt"),.50);task.wait()
    local r,c=counts(replacement);assert(r==8 and c==4,"Replacement failed to play once in Low mode")
    at(model:GetAttribute("ActionAt"),.75);task.wait();empty(replacement,model)
    print("PASS Basic native probe: fresh/.15/.30 duplicate, High/Low, cancellation before release/during sweep/after contact, replacement/clear/death/removal, replacement replay, TTL and part budgets")
end,debug.traceback)
connection:Disconnect();workspace:SetAttribute(config.QualityAttribute,quality)
camera.CameraType=oldType;camera.CFrame=oldFrame;camera.Focus=oldFocus
for _,model in ipairs(actors) do model:Destroy() end
for _,part in ipairs(parts) do if part:GetAttribute("VFXFamily")=="Warrior.Basic" then part:Destroy() end end
assert(ok,err)
