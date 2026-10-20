--!strict
-- Local inspection only. The caller resets ALL C0 to bind, applies walking, then Step.
-- Cancellation/expiry writes no pose; the caller's next reset removes the old overlay.
local Retarget={}
local function finite(value: any): boolean
	return type(value)=="number" and value==value and math.abs(value)<math.huge
end
local function stampKey(value: any): string
	return typeof(value)..":"..tostring(value)
end

-- Pure observation clock, also used by offline rejection/lifecycle checks.
function Retarget.NewClock(initialStamp: any,attachedAt: number,timeline: any): any
	assert(finite(attachedAt),"INVALID_ATTACH_CLOCK")
	local seen=stampKey(initialStamp)
	local latest=attachedAt
	local previousNow=attachedAt
	local event: any=nil
	local destroyed=false
	local status="WAITING_FRESH_ACTION"
	local starts,cancellations,rejections=0,0,0
	local lastStarted: number?=nil
	local age: number?=nil
	local clock={}
	function clock:Cancel(reason: string)
		if event then cancellations+=1 end
		event=nil;age=nil;status=reason
	end
	function clock:Step(snapshot: any,now: number): any
		if destroyed then return nil end
		if not finite(now) or now<previousNow then self:Cancel("INVALID_OR_REVERSED_CLOCK");return nil end
		previousNow=now
		local changed=stampKey(snapshot.stamp)~=seen
		seen=stampKey(snapshot.stamp)
		local candidate: number?=nil
		if changed then
			self:Cancel("REPLACED")
			local stamp=snapshot.stamp
			local reason: string?=nil
			if not finite(stamp) then reason="INVALID_ACTION_TIMESTAMP"
			elseif stamp>now then reason="FUTURE_ACTION_TIMESTAMP"
			elseif stamp<=latest then reason="PREATTACH_OR_REORDERED_ACTION"
			elseif not timeline.accept(stamp,now,latest) then reason="STALE_ACTION_TIMESTAMP" end
			if finite(stamp) and stamp<=now then latest=math.max(latest,stamp) end
			if reason then rejections+=1;status=reason;return nil end
			candidate=stamp
		end
		-- Every finite observation advances the cursor, even when its metadata is
		-- unsupported. A later reordered supported action must never replay it.
		if snapshot.problem then self:Cancel(snapshot.problem);return nil end
		if snapshot.classId~="Warrior" or snapshot.weaponId~="training_sword" then self:Cancel("UNSUPPORTED_CLASS_OR_WEAPON");return nil end
		if snapshot.action~="Basic Attack" or snapshot.effect~="Basic" or snapshot.abilityId~=nil then
			self:Cancel("UNSUPPORTED_ACTION");return nil
		end
		if candidate then
			event={stamp=candidate,classId=snapshot.classId,effect=snapshot.effect,weaponId=snapshot.weaponId}
			lastStarted=candidate;starts+=1
		end
		if not event then return nil end
		age=now-event.stamp
		if not timeline.active(age) then event=nil;status="COMPLETED";return nil end
		status=timeline.phase(age)
		return {stamp=event.stamp,classId=event.classId,effect=event.effect,weaponId=event.weaponId,age=age}
	end
	function clock:GetDiagnostics(): any
		return {status=status,starts=starts,cancellations=cancellations,rejections=rejections,
			lastStartedAt=lastStarted,lastObservedAt=latest,age=age,active=event~=nil,destroyed=destroyed}
	end
	function clock:Destroy() self:Cancel("DESTROYED");destroyed=true end
	return clock
end

-- A full CFrame conjugation converts translation as well as rotation.
-- Does not reset walking or accumulate on last frame; caller owns that reset contract.
function Retarget.MapPose(walking: any,basis: any,pose: any): any
	return walking*basis:Inverse()*pose*basis
end

local function finiteFrame(value: any): boolean
	if typeof(value)~="CFrame" then return false end
	for _,component in ipairs({value:GetComponents()}) do if not finite(component) then return false end end
	return true
end

function Retarget.New(actor: Model,joints: any,poseCallback: any): any
	local run=game:GetService("RunService")
	assert(run:IsStudio() and run:IsClient() and game.PlaceId==0 and game.GameId==0,"LOCAL_UNPUBLISHED_CLIENT_STUDIO_ONLY")
	assert(typeof(actor)=="Instance" and actor:IsA("Model") and type(joints)=="table" and type(poseCallback)=="function","INVALID_ACTION_RETARGET_INPUT")
	local players=game:GetService("Players")
	local owner=players.LocalPlayer
	assert(owner,"LOCAL_OWNER_REQUIRED")
	local root=actor:FindFirstChild("HumanoidRootPart")
	local humanoid=actor:FindFirstChildOfClass("Humanoid")
	assert(root and root:IsA("BasePart") and humanoid,"ACTOR_ROOT_AND_HUMANOID_REQUIRED")
	local isPlayer=players:GetPlayerFromCharacter(actor)==owner
	local heroId=actor:GetAttribute("AdventurerId")
	local function identityProblem(): string?
		if not actor:IsDescendantOf(workspace) or root.Parent~=actor or humanoid.Parent~=actor then return "ACTOR_DEPARTED_OR_REPLACED" end
		if actor:GetAttribute("OwnerUserId")~=owner.UserId then return "ACTOR_OWNER_CHANGED" end
		if isPlayer then
			if owner.Character~=actor or players:GetPlayerFromCharacter(actor)~=owner or actor:GetAttribute("GuildbornePlayer")~=true then return "PLAYER_IDENTITY_CHANGED" end
		elseif actor:GetAttribute("GuildborneHero")~=true or type(heroId)~="string" or heroId==""
			or actor:GetAttribute("AdventurerId")~=heroId or players:GetPlayerFromCharacter(actor)~=nil then return "HERO_IDENTITY_CHANGED" end
		local health=actor:GetAttribute("CombatHealth")
		if humanoid.Health<=0 or not finite(health) or health<=0 then return "ACTOR_DOWNED" end
		return nil
	end
	assert(identityProblem()==nil,identityProblem())
	local owned={}
	local preview: Model?=nil
	for name,joint in pairs(joints) do
		local motor=joint.motor
		assert(type(name)=="string" and typeof(motor)=="Instance" and motor:IsA("Motor6D") and motor:GetAttribute("SourceDerived")==true,"SOURCE_MOTOR_REQUIRED")
		local model=motor:FindFirstAncestorOfClass("Model")
		assert(model and model~=actor and model:GetAttribute("AssetStatus")=="LOCAL_EDITABLE_MESH_PREVIEW_ONLY","ISOLATED_SOURCE_PREVIEW_REQUIRED")
		if preview then assert(preview==model,"ONE_PREVIEW_REQUIRED") else preview=model end
		assert(finiteFrame(joint.bind) and finiteFrame(joint.basis) and joint.basis.Position.Magnitude<1e-6,"FINITE_ROTATION_BASIS_REQUIRED")
		owned[name]={motor=motor,bind=joint.bind,basis=joint.basis}
	end
	assert(preview and next(owned),"SOURCE_JOINTS_REQUIRED")
	assert(preview:GetAttribute("BodyPresetId")=="HUMAN_STANDARD","LOCAL_HUMAN_STANDARD_ACTION_ONLY")
	local timeline=require(game.ReplicatedStorage.Shared.Presentation.ActionTimeline)
	local localPose=require(script.Parent.LocalWarriorBasicPose)
	local clock=Retarget.NewClock(actor:GetAttribute("ActionAt"),workspace:GetServerTimeNow(),timeline)
	local state={}
	local disposed=false
	function state:Step(now: number): (boolean,string)
		if disposed then return false,"DESTROYED" end
		local problem=identityProblem()
		if not run:IsStudio() or not run:IsClient() or game.PlaceId~=0 or game.GameId~=0 then problem="LOCAL_GATE_CLOSED" end
		local event=clock:Step({stamp=actor:GetAttribute("ActionAt"),classId=actor:GetAttribute("ClassId"),
			weaponId=actor:GetAttribute("WeaponId"),action=actor:GetAttribute("Action"),effect=actor:GetAttribute("ActionEffect"),
			abilityId=actor:GetAttribute("ActionAbilityId"),problem=problem},now)
		if not event then return false,clock:GetDiagnostics().status end
		local updates={}
		local ok,err=pcall(function()
			assert(preview and preview:IsDescendantOf(workspace),"PREVIEW_DEPARTED")
			for name,joint in pairs(owned) do
				local motor=joint.motor
				assert(motor:IsDescendantOf(preview) and motor.Part0 and motor.Part1
					and motor.Part0:IsDescendantOf(preview) and motor.Part1:IsDescendantOf(preview),"SOURCE_JOINT_REPLACED")
				local pose=poseCallback(event.classId,event.effect,event.age,name)
				-- Only this gated local Human/Warrior/training-sword Basic profile.
				-- Preserve the injected choreography for every other joint.
				pose=localPose.Apply(event.age,name,pose,timeline)
				if pose~=nil then
					assert(finiteFrame(pose) and finiteFrame(motor.C0),"NONFINITE_ACTION_POSE")
					local value=Retarget.MapPose(motor.C0,joint.basis,pose)
					assert(finiteFrame(value),"NONFINITE_RETARGET_RESULT")
					table.insert(updates,{motor=motor,value=value})
				end
			end
			assert(#updates>0,"NO_SUPPORTED_JOINT_POSE")
		end)
		if not ok then clock:Cancel("POSE_REJECTED:"..tostring(err));return false,clock:GetDiagnostics().status end
		for _,update in ipairs(updates) do update.motor.C0=update.value end
		return true,clock:GetDiagnostics().status
	end
	function state:GetDiagnostics(): any return clock:GetDiagnostics() end
	function state:Destroy() if disposed then return end;disposed=true;clock:Destroy() end
	return state
end

return Retarget
