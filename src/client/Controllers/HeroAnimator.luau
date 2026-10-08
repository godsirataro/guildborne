--!strict
-- Cosmetic motion only; server owns following, membership and equipment.
local RunService=game:GetService("RunService")
local pose=require(script.Parent.ActionPose)
local Config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
return function()
	local rigs: { [Model]: any } = {}
	local connections: {RBXScriptConnection}={}
	local function reset(entry: any)
		for _,joint in pairs(entry.joints) do if joint.Parent then joint.Transform=CFrame.identity end end
		entry.posed=false;entry.speed=0
	end
	local function added(instance: Instance)
		if instance:IsA("Motor6D") then
			local model=instance:FindFirstAncestorOfClass("Model")
			if model and model:GetAttribute("GuildborneHero") then
				local entry=rigs[model] or {joints={},phase=0,speed=0}
				entry.joints[instance.Name]=instance; rigs[model]=entry
			end
			return
		end
		if not instance:IsA("Model") or not instance:GetAttribute("GuildborneHero") then return end
		local joints={}
		for _,j in ipairs(instance:GetDescendants()) do if j:IsA("Motor6D") then joints[j.Name]=j end end
		rigs[instance]={joints=joints,phase=0,speed=0}
	end
	for _,instance in ipairs(workspace:GetDescendants()) do added(instance) end
	table.insert(connections,workspace.DescendantAdded:Connect(added))
	table.insert(connections,workspace.DescendantRemoving:Connect(function(instance)
		if instance:IsA("Model") and rigs[instance] then reset(rigs[instance]);rigs[instance]=nil
		elseif instance:IsA("Motor6D") then
			local model=instance:FindFirstAncestorOfClass("Model");local entry=model and rigs[model]
			if entry and entry.joints[instance.Name]==instance then entry.joints[instance.Name]=nil end
		end
	end))
	table.insert(connections,RunService.PreSimulation:Connect(function(dt: number)
		local camera=workspace.CurrentCamera
		local now=workspace:GetServerTimeNow()
		for model,r in pairs(rigs) do
			local root=model.PrimaryPart
			if not root or not camera or (root.Position-camera.CFrame.Position).Magnitude>90 then
				if r.posed then reset(r) end;r.lastPosition=root and root.Position;continue
			end
			local velocity=root.AssemblyLinearVelocity
			local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
			if root.Anchored then
				local delta=if r.lastPosition then root.Position-r.lastPosition else Vector3.zero
				local distance=Vector3.new(delta.X,0,delta.Z).Magnitude
				local measured=if distance<=12 then math.min(64,distance/math.max(dt,.001)) else 0
				r.speed+= (measured-r.speed)*math.min(dt*10,1);speed=r.speed
			end
			r.lastPosition=root.Position
			r.phase+=math.min(dt,.1)*(if speed>1 then 9 else 1.7)
			local swing=if speed>1 then math.sin(r.phase)*.45 elseif workspace:GetAttribute(Config.ReducedMotionAttribute) then 0 else math.sin(r.phase)*.025
			local actionAge=now-(model:GetAttribute("ActionAt") or 0)
			local hit=now-(model:GetAttribute("FeedbackAt") or 0)<.18
			for name,j in pairs(r.joints) do
				if not j.Parent then r.joints[name]=nil;continue end
				local limb=name:find("Shoulder") or name:find("Hip")
				local sign=if name=="Left Shoulder" or name=="Right Hip" then 1 else -1
				local base=if limb then CFrame.Angles(swing*sign*(if name=="Right Shoulder" and model:GetAttribute("WeaponId") then .3 else 1),0,0) else CFrame.identity
				local action=pose(tostring(model:GetAttribute("ClassId")),tostring(model:GetAttribute("ActionEffect")),actionAge,name)
				if model:GetAttribute("CombatState")=="Downed" then j.Transform=if limb then CFrame.Angles(1.2,0,.2*sign) else CFrame.identity
				elseif action then j.Transform=base*action
				elseif limb and hit then j.Transform=base*CFrame.Angles(.18*sign,0,0)
				else j.Transform=base end
			end
			r.posed=true
		end
	end))
	return {Destroy=function()
		for _,connection in ipairs(connections) do connection:Disconnect() end
		for _,entry in pairs(rigs) do reset(entry) end;table.clear(rigs)
	end}
end
