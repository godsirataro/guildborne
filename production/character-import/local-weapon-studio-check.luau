--!strict
-- Client-only synthetic local fixture; pass the LocalWeaponPresentation module.
-- This asserts lifecycle/source preservation, not actual avatar grip or combat acceptance.
return function(Weapon: any): any
	local run = game:GetService("RunService")
	assert(run:IsStudio() and run:IsClient() and game.PlaceId == 0 and game.GameId == 0)
	local localPlayer = game:GetService("Players").LocalPlayer; assert(localPlayer)
	local holder = Instance.new("Folder"); holder.Name = "LocalWeaponPolicyCheck"; holder.Parent = workspace
	local actor = Instance.new("Model"); actor.Name = "SyntheticOwnedHero"; actor.Parent = holder
	actor:SetAttribute("GuildborneHero",true); actor:SetAttribute("OwnerUserId",localPlayer.UserId)
	local root = Instance.new("Part"); root.Name = "HumanoidRootPart"; root.Anchored = true; root.CanCollide = false; root.Parent = actor
	local arm = root:Clone(); arm.Name = "Right Arm"; arm.Parent = actor
	local humanoid = Instance.new("Humanoid"); humanoid.RequiresNeck = false; humanoid.BreakJointsOnDeath = false; humanoid.Parent = actor
	local preview = Instance.new("Model"); preview.Name = "SyntheticPreview"; preview.Parent = holder
	preview:SetAttribute("LOCAL_TEST_ONLY",true); preview:SetAttribute("BodyPresetId","HUMAN_STANDARD")
	local hand = root:Clone(); hand.Name = "RightHand"; hand:SetAttribute("CoreBodyPart",true); hand.Parent = preview
	local socket = Instance.new("Attachment"); socket.Name = "RightGripAttachment"; socket.Parent = hand
	socket:SetAttribute("SourceDerived",true); socket:SetAttribute("SourceBone","RightHand")
	local states: {any} = {}
	local cases: {string} = {}
	local function check(name: string, condition: boolean) assert(condition,name); table.insert(cases,name) end
	local function sameFrame(a: CFrame,b: CFrame): boolean
		local _, angle = a.Rotation:ToObjectSpace(b.Rotation):ToAxisAngle()
		return (a.Position-b.Position).Magnitude < .001 and math.abs(angle) < .001
	end
	local function makeGear(): (Model,{[string]: BasePart},{[string]: WeldConstraint})
		-- ArtKit source dimensions/positions, then the existing HeroRig .65 scale.
		local V = Vector3.new
		local specs: {[string]: {any}} = {
			Grip={"Part",V(.3,1,.3),CFrame.new(0,.8,0)},
			Guard={"Part",V(1.5,.22,.4),CFrame.new(0,1.4,0)},
			Blade={"Part",V(.5,2.6,.16),CFrame.new(0,2.8,0)},
			Point={"WedgePart",V(.16,.6,.5),CFrame.new(0,4.4,0)*CFrame.Angles(0,math.pi/2,0)},
			Pommel={"Part",V(.45,.3,.4),CFrame.new(0,.15,0)},
		}
		local gear = Instance.new("Model"); gear.Name = "EquippedWeapon"
		local parts: {[string]: BasePart} = {}; local welds: {[string]: WeldConstraint} = {}
		for name, spec in pairs(specs) do
			local p = Instance.new(spec[1] :: string) :: BasePart; p.Name = name
			p.Size = (spec[2] :: Vector3)*.65
			local authored = spec[3] :: CFrame
			p.CFrame = CFrame.new(authored.Position*.65)*authored.Rotation
			p.Color = Color3.fromRGB(99,65,43); p.Material = Enum.Material.Wood
			p.Transparency = .15; p.LocalTransparencyModifier = .35
			p.Anchored = false; p.Massless = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false
			local w = Instance.new("WeldConstraint"); w.Part0 = arm; w.Part1 = p; w.Parent = p
			p.Parent = gear; parts[name] = p; welds[name] = w
		end
		gear.PrimaryPart = parts.Grip; gear.Parent = actor; actor:SetAttribute("WeaponId","training_sword")
		return gear,parts,welds
	end
	local function newState(): any
		local state, err = Weapon.New(actor,preview); assert(state,err); table.insert(states,state); return state
	end
	local ok, result = pcall(function()
		local state = newState(); assert(state:Sync())
		check("unequipped_no_copy",state:GetModel() == nil and state:GetDiagnostics().status == "NO_WEAPON")
		local gear, parts, welds = makeGear()
		local originalLTM = parts.Grip.LocalTransparencyModifier
		local before: {[string]: any} = {}
		for name, p in pairs(parts) do before[name] = {cf=p.CFrame,size=p.Size,color=p.Color,material=p.Material,
			transparency=p.Transparency,anchored=p.Anchored,massless=p.Massless,collide=p.CanCollide,touch=p.CanTouch,query=p.CanQuery,weld=welds[name]} end
		assert(state:Sync()); local visual = state:GetModel(); assert(visual)
		check("five_copies_and_five_hidden",#visual:GetChildren() == 5 and state:GetDiagnostics().hiddenOriginalParts == 5)
		check("source_socket_center_and_fixed_fit",sameFrame(visual.Grip.CFrame,socket.WorldCFrame*CFrame.Angles(math.pi+.45,0,0)))
		for name, p in pairs(parts) do
			local copy = visual:FindFirstChild(name); assert(copy and copy:IsA("BasePart"))
			local saved = before[name]
			check("safe_geometry_copy_"..name,copy.ClassName == p.ClassName and copy.Size == p.Size and copy.Color == p.Color
				and copy.Material == p.Material and copy.Transparency == p.Transparency and #copy:GetChildren() == 0
				and copy.Anchored and copy.Massless and not copy.CanCollide and not copy.CanTouch and not copy.CanQuery)
			check("original_preserved_"..name,p.CFrame == saved.cf and p.Size == saved.size and p.Color == saved.color
				and p.Material == saved.material and p.Transparency == saved.transparency and p.Anchored == saved.anchored
				and p.Massless == saved.massless and p.CanCollide == saved.collide and p.CanTouch == saved.touch
				and p.CanQuery == saved.query and welds[name] == saved.weld and welds[name].Part0 == arm and welds[name].Part1 == p
				and p.LocalTransparencyModifier == 1)
		end
		socket.CFrame = CFrame.new(.2,-.3,.1)*CFrame.Angles(.3,-.4,.2); assert(state:Sync())
		check("moving_socket_lockstep",sameFrame(visual.Grip.CFrame,socket.WorldCFrame*CFrame.Angles(math.pi+.45,0,0)))
		parts.Blade.Color = Color3.fromRGB(110,70,40); assert(state:Sync())
		check("source_color_refresh",visual.Blade.Color == parts.Blade.Color)
		actor:SetAttribute("WeaponId","iron_sword"); assert(state:Sync())
		check("unsupported_visible",state:GetModel() == nil and parts.Grip.LocalTransparencyModifier == originalLTM and state:GetDiagnostics().status == "UNSUPPORTED_WEAPON")
		actor:SetAttribute("WeaponId","training_sword"); assert(state:Sync())
		welds.Blade.Enabled = false; assert(state:Sync())
		check("disabled_weld_restores",state:GetModel() == nil and parts.Blade.LocalTransparencyModifier == originalLTM)
		welds.Blade.Enabled = true; assert(state:Sync()); check("valid_weld_recovers",state:GetModel() ~= nil)
		welds.Blade.Part0 = root; assert(state:Sync())
		check("wrong_weld_target_restores",state:GetModel() == nil and parts.Grip.LocalTransparencyModifier == originalLTM)
		welds.Blade.Part0 = arm
		local injected = Instance.new("ModuleScript"); injected.Name = "UnreviewedCode"; injected.Parent = parts.Grip
		assert(state:Sync()); check("unreviewed_descendant_no_clone",state:GetModel() == nil and parts.Grip.LocalTransparencyModifier == originalLTM)
		injected:Destroy(); assert(state:Sync())
		parts.Blade.Size *= 2; assert(state:Sync())
		check("changed_source_geometry_restores",state:GetModel() == nil and parts.Blade.LocalTransparencyModifier == originalLTM)
		parts.Blade.Size = before.Blade.size; assert(state:Sync())
		gear.Parent = holder; local replacement, nextParts = makeGear(); assert(state:Sync())
		check("gear_replacement_restores_old",parts.Grip.LocalTransparencyModifier == originalLTM and nextParts.Grip.LocalTransparencyModifier == 1)
		local other = newState()
		check("duplicate_state_releases_old",state:GetDiagnostics().destroyed and state:GetModel() == nil and nextParts.Grip.LocalTransparencyModifier == originalLTM)
		assert(other:Sync()); actor:SetAttribute("OwnerUserId",localPlayer.UserId+1)
		local ownerOK = other:Sync()
		check("lost_owner_restores_and_stops",not ownerOK and other:GetDiagnostics().destroyed and nextParts.Grip.LocalTransparencyModifier == originalLTM)
		local denied = Weapon.New(actor,preview); check("foreign_actor_rejected",denied == nil)
		actor:SetAttribute("OwnerUserId",localPlayer.UserId)
		local damaged = newState(); assert(damaged:Sync()); local damagedModel = damaged:GetModel(); assert(damagedModel)
		damagedModel.Grip:Destroy(); local damageOK = damaged:Sync()
		check("damaged_copy_cleanup",not damageOK and damaged:GetModel() == nil and nextParts.Grip.LocalTransparencyModifier == originalLTM)
		local detached = newState(); assert(detached:Sync()); preview.Parent = nil; local detachOK = detached:Sync()
		check("preview_removal_cleanup",not detachOK and detached:GetModel() == nil and nextParts.Grip.LocalTransparencyModifier == originalLTM)
		preview.Parent = holder
		local dead = newState(); assert(dead:Sync()); humanoid.Health = 0; local deathOK = dead:Sync()
		check("actor_death_cleanup",not deathOK and dead:GetModel() == nil and nextParts.Grip.LocalTransparencyModifier == originalLTM)
		for _, savedState in ipairs(states) do savedState:Destroy(); savedState:Destroy()
			check("state_resources_released_"..tostring(#cases),savedState:GetModel() == nil and savedState:GetDiagnostics().hiddenOriginalParts == 0
				and savedState:GetDiagnostics().connections == 0 and savedState:GetDiagnostics().restoreFailures == 0) end
		check("replacement_source_still_exists",replacement.Parent == actor and #replacement:GetChildren() == 5)
		return {passed=#cases,cases=cases,syntheticLocalFixture=true,actualPlayerGripAccepted=false,combatAccepted=false}
	end)
	for _, state in ipairs(states) do state:Destroy() end
	preview:Destroy(); holder:Destroy()
	assert(ok,result); return result
end
