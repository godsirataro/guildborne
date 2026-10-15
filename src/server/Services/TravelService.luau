--!strict
return function(city: any,plots: any,heroes: any,localTravel:any?,platform:any?)
	local Config=if platform then platform.Config else require(game.ReplicatedStorage.Shared.Config.City)
	local Civic=if platform then platform.Civic else require(game.ReplicatedStorage.Shared.Config.CivicCities)
	local Rules=if platform then platform.Rules else require(script.Parent.Parent.Systems.TravelRules)(Config)
	local Vector3=if platform then platform.Vector3 else Vector3
	local CFrame=if platform then platform.CFrame else CFrame
	local RaycastParams=if platform then platform.RaycastParams else RaycastParams
	local OverlapParams=if platform then platform.OverlapParams else OverlapParams
	local Enum=if platform then platform.Enum else Enum
	local workspace=if platform then platform.Workspace else workspace
	local RunService=if platform then platform.RunService else game:GetService("RunService")
	local now=if platform then platform.Now else os.clock
	local V=Vector3.new
	local localStops:{[Player]:any}={}
	local localRespawnReady:{[Player]:Model?}={}
	local returnStops:{[Player]:string}={}
 local S={};local buckets: {[Player]: any}={};local zones: {[Player]: string}={}
	local function alive(player: Player): boolean
		local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid")
		return h~=nil and h.Health>0 and c~=nil and c:FindFirstChild("HumanoidRootPart")~=nil
	end
	local function destination(player: Player,zone: string): Vector3?
		local plot=plots[player];if not plot or not Config.Destinations[zone] then return nil end
		local origin=if zone=="Guild" then plot.origin else Vector3.zero
		local region=(city.regions and city.regions[zone])or(city.civicRegions and city.civicRegions[zone])
		local geometry=if zone=="Guild" then plot.model elseif region then region.model else city.town
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances={geometry};params.RespectCanCollide=true;params.CollisionGroup="GuildborneCharacters"
		local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
		overlap.FilterDescendantsInstances={geometry};overlap.RespectCanCollide=true;overlap.CollisionGroup="GuildborneCharacters"
		for _,primary in ipairs({true,false}) do
			local x,y,z=Rules.resolve(zone,primary,if zones[player]=="Guild"then returnStops[player]else nil);local target=origin+V(x,y,z)
			local hit=workspace:Raycast(target+V(0,8,0),V(0,-20,0),params)
			if hit and math.abs(hit.Position.Y-(origin.Y+(Config.Destinations[zone].GroundY or .5)))<2 and #workspace:GetPartBoundsInBox(CFrame.new(target),V(4,5,4),overlap)==0 then return target end
  end
  if zone=="City" and zones[player]=="Guild" and returnStops[player]then
   for _,primary in ipairs({true,false})do
    local x,y,z=Rules.resolve("City",primary);local target=V(x,y,z)
    local hit=workspace:Raycast(target+V(0,8,0),V(0,-20,0),params)
    if hit and math.abs(hit.Position.Y-.5)<2 and #workspace:GetPartBoundsInBox(CFrame.new(target),V(4,5,4),overlap)==0 then return target end
   end
  end
  return nil
 end
 function S.Validate(player: Player,zone: string): string?
		local plot=plots[player];local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
		local portal:BasePart?=nil;local nearest=math.huge
		for _,candidate in ipairs(city.portals or {city.cityPortal,city.guildPortal}) do
			if root and candidate:GetAttribute("TravelDestination")==zone then
				local distance=(root.Position-candidate.Position).Magnitude
				if distance<nearest then portal=candidate;nearest=distance end
			end
		end
		local problem=Rules.validate(zone,alive(player),c~=nil and (c:GetAttribute("CombatHealth") or 1)<=0,
			plot~=nil and plot.model:GetAttribute("InCombat")==true,plot~=nil and plot.model:GetAttribute("TowerState")~=nil,
			if root and portal then (root.Position-portal.Position).Magnitude else math.huge)
		if problem then return problem end
		if not destination(player,zone) then return "TravelUnavailable" end
		local bucket=buckets[player] or {};buckets[player]=bucket
		if not Rules.accept(bucket,now()) then return "TravelCooling" end
		return nil
	end
	local function arrive(player:Player,zone:string,target:Vector3):boolean
		local plot=plots[player];local c=player.Character
		if not plot or not c or not alive(player) or not Config.Destinations[zone] then return false end
		c:PivotTo(CFrame.lookAt(target,target+V(0,0,-1)))
		local root=c:FindFirstChild("HumanoidRootPart") :: BasePart
		root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
		zones[player]=zone;player:SetAttribute("CurrentZone",zone)
		local region=(city.regions and city.regions[zone])or(city.civicRegions and city.civicRegions[zone])
		player.RespawnLocation=if zone=="City" then city.spawn elseif region then region.spawn else plot.spawn
		heroes.Travel(player)
		return true
	end
 local function rememberCityStop(player:Player)
  local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
  if not root or not Config.contains(root.Position.X,root.Position.Z)then return end
  local closest=16;local chosen:string?=nil
  for _,portal in ipairs(city.guildAccessPortals or {city.cityPortal})do
   local id=portal:GetAttribute("CityReturnStop")
   if portal:IsDescendantOf(city.town)and type(id)=="string"and Config.GuildPortalStops[id]then
    local distance=(root.Position-portal.Position).Magnitude
    if distance<=closest then closest=distance;chosen=id end
   end
  end
  if chosen then returnStops[player]=chosen end
 end
	function S.Travel(player: Player,zone: string): boolean
		local target=destination(player,zone);if not target then return false end
  localStops[player]=nil;localRespawnReady[player]=nil
  if zone=="Guild"then rememberCityStop(player)end
		return arrive(player,zone,target)
	end
	-- Only the server visit adapter supplies a checked landing. Respawn stays at home.
	function S.Visit(player:Player,target:Vector3):boolean rememberCityStop(player);local ok=arrive(player,"Guild",target);if ok then localStops[player]=nil;localRespawnReady[player]=nil end;return ok end
	local function safeLocal(target:Vector3,geometry:Instance):boolean
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={geometry};params.RespectCanCollide=true;params.CollisionGroup="GuildborneCharacters"
		local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={geometry};overlap.RespectCanCollide=true;overlap.CollisionGroup="GuildborneCharacters"
		local hit=workspace:Raycast(target+V(0,3,0),V(0,-10,0),params)
		return hit~=nil and target.Y-hit.Position.Y>=2 and target.Y-hit.Position.Y<=6 and #workspace:GetPartBoundsInBox(CFrame.new(target),V(4,5,4),overlap)==0
	end
	local function moveLocal(player:Player,target:CFrame)
		local character=player.Character :: Model;character:PivotTo(target)
		local root=character:FindFirstChild("HumanoidRootPart") :: BasePart
		root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
		heroes.Travel(player)
	end
	function S.IsLocal(player:Player):boolean return localStops[player]~=nil end
	function S.EnterLocal(player:Player):(boolean,string)
		if not localTravel then return false,"TravelUnavailable"end
		local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?;local plot=plots[player]
		local session=localTravel.Session(player);local entry=if type(localTravel.Entry)=="function"then localTravel.Entry(player)else localTravel.Entry
		local problem=Rules.localValidate(session,c,localStops[player],true,alive(player),c~=nil and(c:GetAttribute("CombatHealth")or 1)<=0,
			plot~=nil and plot.model:GetAttribute("InCombat")==true,plot~=nil and plot.model:GetAttribute("TowerState")~=nil,
			if root and entry and entry.Parent then(root.Position-entry.Position).Magnitude else math.huge,localTravel.Gate(player,true))
		if problem then return false,problem end
		if not plot or not c or not root or not localTravel.Geometry.Parent then return false,"TravelUnavailable"end
		local target=if safeLocal(localTravel.Landing,localTravel.Geometry)then localTravel.Landing elseif safeLocal(localTravel.Fallback,localTravel.Geometry)then localTravel.Fallback else nil
		if not target then return false,"TravelUnavailable"end
		local bucket=buckets[player]or {};buckets[player]=bucket;if not Rules.accept(bucket,now())then return false,"TravelCooling"end
		-- No yields between the final identity check and movement.
		if localTravel.Session(player)~=session or player.Character~=c then return false,"ActorNotReady"end
		localRespawnReady[player]=nil
		localStops[player]={session=session,epoch=session.epoch,token=session.token,character=c,zone=zones[player]or "Guild",transform=c:GetPivot(),spawn=player.RespawnLocation,stop=returnStops[player]}
		player:SetAttribute("CurrentZone","SharedLocalCandidate");if localTravel.Spawn then player.RespawnLocation=localTravel.Spawn end
		moveLocal(player,CFrame.lookAt(target,target+V(0,0,-1)));return true,"OK"
	end
	local function returnLocal(player:Player,recovery:boolean):(boolean,string)
		local snapshot=localStops[player];if not localTravel or not snapshot then return false,"TravelUnavailable"end
		local session=localTravel.Session(player);local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?;local plot=plots[player]
		if not Rules.localCurrent(snapshot,session)then return false,"ActorNotReady"end
		if not recovery then
			local exit=localTravel.Exit
			local problem=Rules.localValidate(session,c,snapshot,false,alive(player),c~=nil and(c:GetAttribute("CombatHealth")or 1)<=0,
				plot~=nil and plot.model:GetAttribute("InCombat")==true,plot~=nil and plot.model:GetAttribute("TowerState")~=nil,
				if root and exit and exit.Parent then(root.Position-exit.Position).Magnitude else math.huge,localTravel.Gate(player,false))
			if problem then return false,problem end
		end
		if not c or not root or not alive(player)or not plot then return false,"ActorNotReady"end
		local region=(city.regions and city.regions[snapshot.zone])or(city.civicRegions and city.civicRegions[snapshot.zone])
		local geometry=if snapshot.zone=="Guild"then plot.model elseif region then region.model else city.town
		local target=if safeLocal(snapshot.transform.Position,geometry)then snapshot.transform else nil
		if not target then local fallback=destination(player,snapshot.zone);if fallback then target=CFrame.new(fallback)end end
		if not target then return false,"TravelUnavailable"end
		if localTravel.Session(player)~=session or player.Character~=c then return false,"ActorNotReady"end
		localStops[player]=nil;localRespawnReady[player]=nil;zones[player]=snapshot.zone;returnStops[player]=snapshot.stop;player:SetAttribute("CurrentZone",snapshot.zone)
		player.RespawnLocation=snapshot.spawn;moveLocal(player,target);return true,"OK"
	end
	function S.ReturnLocal(player:Player):(boolean,string)return returnLocal(player,false)end
	function S.Respawn(player: Player)
		if localStops[player]then
			-- World calls this only after its CharacterAdded spawn-settle wait.
			-- Heartbeat must not consume the return snapshot before that final pivot.
			localRespawnReady[player]=player.Character
			returnLocal(player,true);return
		end
		S.Travel(player,zones[player] or "Guild")
	end
	function S.Remove(player: Player) localStops[player]=nil;localRespawnReady[player]=nil;zones[player]=nil;buckets[player]=nil;returnStops[player]=nil end
	local elapsed=0
	RunService.Heartbeat:Connect(function(dt)
		elapsed+=dt;if elapsed<.5 then return end;elapsed=0
		for player in pairs(plots) do
			local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
			local snapshot=localStops[player]
			if snapshot and localTravel then
				local session=localTravel.Session(player)
				if session~=snapshot.session or (session and(session.epoch~=snapshot.epoch or session.token~=snapshot.token))then localStops[player]=nil;S.Travel(player,zones[player]or "Guild")
				elseif root and alive(player)and(c==snapshot.character or localRespawnReady[player]==c)
					and(root.Position.Y< -15 or c~=snapshot.character or not localTravel.Contains(root.Position)or(localTravel.Recover and localTravel.Recover()))then returnLocal(player,true)end
				continue
			end
			if root and alive(player) then
				local zone=zones[player] or "Guild"
					if root.Position.Y< -15 or (Config.Regions[zone] and Config.region(root.Position.X,root.Position.Z)~=zone) or ((Civic.Definitions :: any)[zone] and not Civic.contains(zone,root.Position.X,root.Position.Z)) then S.Travel(player,zone) end
			end
		end
	end)
	return S
end
