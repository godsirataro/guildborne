--!strict
-- Explicit local review consumer only. Never required by production bootstrap.
local Run = game:GetService("RunService")
local Tags = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Selector = require(game.ReplicatedStorage.Shared.Config.EnemyVisualAssets)
local Binding = {}
function Binding.create(assets: Instance, parent: Instance, onAllocated: ((any) -> ())?): any
	assert(Run:IsStudio() and Run:IsClient() and game.PlaceId == 0 and game.GameId == 0, "Local client review only")
	assert(assets:GetAttribute("IsolatedMemory") == true and parent:IsDescendantOf(workspace) or
		(assets:GetAttribute("IsolatedMemory") == true and parent == workspace), "Isolated workspace parent required")
	local Native = require(assets:FindFirstChild("NativeEnemyPreview") :: ModuleScript)
	local folder = Instance.new("Folder"); folder.Name="BoundEnemySourceReview"; folder.Parent=parent
	local closed, slots, serial = false, 0, 0
	local states: {[Model]: any} = {}
	local retryAt = setmetatable({} :: {[Model]: number}, {__mode="k"})
	local connections: {RBXScriptConnection} = {}
	local dataById: {[string]: any} = {}
	local result: any = {folder=folder, states=states, limit=2}
	local function release(state: any)
		if not state.released then state.released=true; slots-=1 end
	end
	local function dispose(model: Model, state: any)
		if state.closed then return end
		state.closed=true
		if states[model]==state then states[model]=nil end
		for _, connection in ipairs(state.connections) do connection:Disconnect() end
		for part, transparency in pairs(state.hidden) do
			pcall(function() part.LocalTransparencyModifier=transparency end)
		end
		table.clear(state.hidden)
		if state.handle then state.handle.destroy() end
		-- Keep a slot reserved until an async constructor has returned/cancelled.
		if not state.building then release(state) end
	end
	function result.destroy()
		if closed then return end; closed=true
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections)
		for model,state in pairs(states) do dispose(model,state) end
		folder:Destroy()
	end
	local function eligible(model: Model): boolean
		return model:IsDescendantOf(workspace) and Tags:HasTag(model,"GuildborneAnimatedEnemy")
			and model:GetAttribute("GuildborneEnemy")==true and model.PrimaryPart~=nil
			and model:GetAttribute("OwnerUserId")==Players.LocalPlayer.UserId
			and dataById[tostring(model:GetAttribute("EncounterId"))]~=nil
	end
	local function current(model: Model, state: any): boolean
		return not closed and not state.closed and eligible(model) and model.Parent==state.parent
			and model.PrimaryPart==state.root and model:GetAttribute("OwnerUserId")==state.owner
			and model:GetAttribute("EncounterId")==state.id
	end
	local function hide(state: any, instance: Instance)
		if closed or state.closed then return end
		-- Only authored art tagged by AdventureEnemyKit/EnemyArticulation. Roots,
		-- health UI, telegraph parts, carriers and unrelated effects remain intact.
		if instance:IsA("BasePart") and instance~=state.root
			and type(instance:GetAttribute("BindBone"))=="string"
			and type(instance:GetAttribute("EnemyLimb"))=="string" then
			if state.hidden[instance]==nil then state.hidden[instance]=instance.LocalTransparencyModifier end
			instance.LocalTransparencyModifier=1
		end
	end
	local function isDead(model: Model): boolean
		local hp=model:GetAttribute("CombatHealth")
		return model:GetAttribute("CombatState")=="Dead" or (type(hp)=="number" and hp<=0)
	end
	local function add(model: Model)
		if closed or slots>=2 or states[model] or not eligible(model) or (retryAt[model] or 0)>os.clock() then return end
		-- No live ground basis was observed for an existing corpse. Keep its native
		-- presentation until respawn instead of guessing the pre-death transform.
		if isDead(model) then return end
		serial+=1; slots+=1
		local state: any = {id=model:GetAttribute("EncounterId"),owner=model:GetAttribute("OwnerUserId"),
			root=model.PrimaryPart,parent=model.Parent,generation=tostring(serial),connections={},hidden={},building=true,
			lastLivePivot=model:GetPivot()}
		states[model]=state
		local function invalidate() if not current(model,state) then dispose(model,state) end end
		table.insert(state.connections,model.AncestryChanged:Connect(invalidate))
		for _,name in ipairs({"OwnerUserId","EncounterId"}) do
			table.insert(state.connections,model:GetAttributeChangedSignal(name):Connect(invalidate))
		end
		table.insert(state.connections,model:GetPropertyChangedSignal("PrimaryPart"):Connect(invalidate))
		task.spawn(function()
			local ok, problem = pcall(function()
				-- AdventureCombatBridge creates its 1-stud root at base+3 and sets
				-- PivotOffset=(0,-3,0). GetPivot preserves that authored ground base;
				-- using root bottom would incorrectly raise the enemy by 2.5 studs.
				local origin=state.lastLivePivot
				local handle=Native.create(dataById[state.id],folder,origin,function(allocated: any)
					state.handle=allocated
					if not current(model,state) then allocated.destroy(); error("Binding cancelled") end
				end)
				if not current(model,state) then handle.destroy(); return end
				state.offset=origin:ToObjectSpace(handle.part.CFrame)
				for _,instance in ipairs(model:GetDescendants()) do hide(state,instance) end
				table.insert(state.connections,model.DescendantAdded:Connect(function(instance) hide(state,instance) end))
				table.insert(state.connections,model.DescendantRemoving:Connect(function(instance)
					local previous=state.hidden[instance]
					if previous~=nil and instance:IsA("BasePart") then
						instance.LocalTransparencyModifier=previous; state.hidden[instance]=nil
					end
				end))
				state.ready=true
			end)
			state.building=false
			if not ok then
				retryAt[model]=os.clock()+10; dispose(model,state)
				if not closed then warn("Enemy binding preview: "..tostring(problem)) end
			end
			if state.closed then release(state) end
		end)
	end
	local ok, problem = pcall(function()
		if onAllocated then onAllocated(result) end
		assert(not closed,"Binding cancelled")
		table.insert(connections,folder.Destroying:Connect(result.destroy))
		for _,name in ipairs({"Enemy1","Enemy2"}) do
			local dataset=assets:FindFirstChild(name)
			if dataset then
				local data=require(dataset:FindFirstChild("Data") :: ModuleScript)
				assert(not closed,"Binding cancelled")
				assert(Selector.Assets[data.id] and not dataById[data.id],"Unexpected enemy dataset")
				dataById[data.id]=data
			end
		end
		local scanAt=0
		table.insert(connections,Tags:GetInstanceRemovedSignal("GuildborneAnimatedEnemy"):Connect(function(instance)
			if instance:IsA("Model") and states[instance] then dispose(instance,states[instance]) end
		end))
		table.insert(connections,Run.Heartbeat:Connect(function()
			local now=workspace:GetServerTimeNow()
			for model,state in pairs(states) do
				if not current(model,state) then dispose(model,state); continue end
				local dead=isDead(model)
				if state.dead and not dead then dispose(model,state); continue end
				if dead and not state.dead then state.dead=true; state.deathAt=now end
				-- CombatService tilts/lifts the native corpse. Authored Death already
				-- falls to the ground, so retain the last live basis only while dead.
				-- Living actors continue following every frame, including during load.
				if not dead then state.lastLivePivot=model:GetPivot() end
				if not state.ready then continue end
				local success, failure=pcall(function()
					local snapshot: any={EncounterId=state.id,generation=state.generation,present=true,observedDeathAt=state.deathAt}
					for _,name in ipairs({"CombatState","CombatHealth","EnemyActionAt","RegionalTelegraphAt","RegionalTelegraphUntil","RegionalImpactAt","DamageCueAt"}) do
						snapshot[name]=model:GetAttribute(name)
					end
					local selected=Selector.select(snapshot,now)
					if not selected then dispose(model,state); return end
					if state.key~=selected.key then state.key=selected.key; state.started=now end
					local clip=selected.clip or "Idle"
					local elapsed=if selected.looped or selected.clip==nil then math.max(0,now-state.started) else selected.offset
					state.handle.part.CFrame=state.lastLivePivot*state.offset
					state.handle.frame(clip,elapsed)
				end)
				if not success then retryAt[model]=os.clock()+10; dispose(model,state); warn(tostring(failure)) end
			end
			if os.clock()>=scanAt then
				scanAt=os.clock()+.5
				for _,instance in ipairs(Tags:GetTagged("GuildborneAnimatedEnemy")) do
					if instance:IsA("Model") then add(instance) end
				end
			end
		end))
	end)
	if not ok then result.destroy(); error(tostring(problem)) end
	return result
end
return Binding
