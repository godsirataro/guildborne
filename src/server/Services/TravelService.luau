--!strict
return function(city: any,plots: any,heroes: any,localTravel:any?,platform:any?,walking:any?)
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
 local walkingStops:{[Player]:any}={};local walkingSamples:{[Player]:any}={}
 local walkingNotified:{[Player]:number}={}
 local walkingArrivals:{[Player]:any}={}
 local function clearWalkingDisplay(player:Player)
  if not walking then return end
  local old=walkingStops[player];local character=player.Character
  if old and old.character then old.character:SetAttribute("WalkingRouteContext",nil)end
  if character and (not old or character~=old.character)then character:SetAttribute("WalkingRouteContext",nil)end
 end
 local function clearWalking(player:Player)
  clearWalkingDisplay(player);walkingStops[player]=nil;walkingSamples[player]=nil;walkingArrivals[player]=nil
 end
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
  clearWalking(player)
  localStops[player]=nil;localRespawnReady[player]=nil
  if zone=="Guild"then rememberCityStop(player)end
		return arrive(player,zone,target)
	end
	-- Only the server visit adapter supplies a checked landing. Respawn stays at home.
	function S.Visit(player:Player,target:Vector3):boolean rememberCityStop(player);local ok=arrive(player,"Guild",target);if ok then clearWalking(player);localStops[player]=nil;localRespawnReady[player]=nil end;return ok end
	local function safeLocal(target:Vector3,geometry:Instance,extra:Instance?):boolean
  local geometryList={geometry};if extra and extra~=geometry then table.insert(geometryList,extra)end
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances=geometryList;params.RespectCanCollide=true;params.CollisionGroup="GuildborneCharacters"
		local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances=geometryList;overlap.RespectCanCollide=true;overlap.CollisionGroup="GuildborneCharacters"
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
  clearWalking(player)
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
  clearWalking(player)
		if localStops[player]then
			-- World calls this only after its CharacterAdded spawn-settle wait.
			-- Heartbeat must not consume the return snapshot before that final pivot.
			localRespawnReady[player]=player.Character
			returnLocal(player,true);return
		end
		S.Travel(player,zones[player] or "Guild")
	end
	function S.Remove(player: Player) clearWalking(player);walkingNotified[player]=nil;localStops[player]=nil;localRespawnReady[player]=nil;zones[player]=nil;buckets[player]=nil;returnStops[player]=nil end
 local function walkingSession(player:Player):any
  if not walking then return nil end
  local ok,session=Rules.walkingCall(walking.Session,player)
  return if ok then session else nil
 end
 local function routeReady(route:any):boolean
  if type(route)~="table" or Rules.walkingContext(route.id,route.fromZone,route.toZone)==nil
   or not route.geometry or not route.geometry.Parent or type(route.volumes)~="table"
   or #route.volumes==0 or #route.volumes>128 or type(route.entries)~="table" or type(route.safeRecovery)~="table" then return false end
  local ok,ready=Rules.walkingCall(route.isReady)
  return ok and ready==true
 end
 local function routeContains(route:any,position:Vector3):boolean
  if position.Y~=position.Y or position.Y<0 or position.Y>35 then return false end
  if Config.walkingContains(route.entries[route.fromZone],position) or Config.walkingContains(route.entries[route.toZone],position) then return true end
  for _,volume in ipairs(route.volumes)do if Config.walkingContains(volume,position)then return true end end
  return false
 end
 local function localReturnAxis(delta:Vector3):Vector3?
  local length=math.sqrt(delta.X*delta.X+delta.Z*delta.Z)
  -- Keep the last meaningful validated horizontal approach through idle samples.
  return if length>.1 and length<math.huge then V(-delta.X/length,0,-delta.Z/length)else nil
 end
 local function inZone(zone:string,position:Vector3):boolean
  return Rules.walkingSurface(Civic,zone,position)
 end
 local function walkingZone(zone:string):any
  return Rules.walkingZone(city,Civic,zone)
 end
 local function gate(player:Player,session:any,from:string,to:string):string?
  local c=player.Character;local plot=plots[player]
  local problem=Rules.walkingProblem(session,alive(player),c~=nil and(c:GetAttribute("CombatHealth")or 1)<=0,
   plot~=nil and plot.model:GetAttribute("InCombat")==true,plot~=nil and plot.model:GetAttribute("TowerState")~=nil)
  if problem then return problem end
  local ok,reason=Rules.walkingCall(walking.Gate,player,session,from,to)
  if not ok or (reason~=nil and type(reason)~="string") then return "TravelUnavailable"end
  return reason
 end
 local function recoverWalking(player:Player,snapshot:any,reason:string):boolean
  clearWalkingDisplay(player)
  snapshot.recovering=true
  local session=walkingSession(player);local c=player.Character
  if not Rules.walkingIdentity(snapshot,session,c) then clearWalking(player);return true end
  if walking.Notify and now()>=(walkingNotified[player]or 0)then
   walkingNotified[player]=now()+2;Rules.walkingCall(walking.Notify,player,reason)
  end
  local target=snapshot.route.safeRecovery[snapshot.from]
  -- Recovery is exceptional; never guess a landing or use another owner's plot.
  if not alive(player) or not target then return true end
  local region=walkingZone(snapshot.from)
  local sourceGeometry=region and region.model
  local routeGeometry=if snapshot.route.geometry.Parent then snapshot.route.geometry else nil
  local geometry=sourceGeometry or routeGeometry
  local supported,valid=pcall(function()return geometry~=nil and inZone(snapshot.from,target.Position) and safeLocal(target.Position,geometry,routeGeometry)end)
  if not supported or not valid or not Rules.walkingIdentity(snapshot,walkingSession(player),player.Character)then return true end
  local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
  if not root then return true end
  local recoveryDistance=(root.Position-target.Position).Magnitude
  if recoveryDistance~=recoveryDistance or recoveryDistance>.1 then moveLocal(player,target)end
  clearWalking(player)
  return true
 end
 function S.CanFollowWalking(player:Player,position:Vector3):boolean
  local snapshot=walkingStops[player]
  if not snapshot or snapshot.recovering or localStops[player] then return false end
  local session=walkingSession(player)
  return Rules.walkingIdentity(snapshot,session,player.Character) and session.state=="Active"
   and Rules.walkingRoutesValid(walking.Routes) and table.find(walking.Routes,snapshot.route)~=nil
   and routeReady(snapshot.route) and routeContains(snapshot.route,position)
 end
 local function walkingTick(player:Player,c:Model?,root:BasePart?):boolean
  if not walking then return false end
  local snapshot=walkingStops[player];local session=walkingSession(player)
  if not root or not alive(player)then clearWalking(player);return false end
  if not Rules.walkingRoutesValid(walking.Routes)then
   if snapshot then return recoverWalking(player,snapshot,"TravelUnavailable")end
   clearWalking(player);return false
  end
  if snapshot then
   if not Rules.walkingIdentity(snapshot,session,c)then clearWalking(player);return true end
   if snapshot.recovering then return recoverWalking(player,snapshot,"TravelUnavailable")end
   local route=snapshot.route
   if not table.find(walking.Routes,route) or not routeReady(route)then return recoverWalking(player,snapshot,"TravelUnavailable")end
   local problem=gate(player,session,snapshot.from,snapshot.to)
   if problem then return recoverWalking(player,snapshot,problem)end
   if not Rules.walkingIdentity(snapshot,walkingSession(player),player.Character)then clearWalking(player);return true end
   local delta=root.Position-snapshot.position
   if delta.Magnitude~=delta.Magnitude or delta.Magnitude>35 or now()-snapshot.at>2 then return recoverWalking(player,snapshot,"TravelUnavailable")end
   if not routeContains(route,root.Position) and inZone(snapshot.from,root.Position) then
    local region=walkingZone(snapshot.from)
    local geometry=region and region.model
    if geometry and safeLocal(root.Position,geometry)then clearWalking(player);return false end
   end
   -- Sample the short observed segment, not a broad rectangle across bends/islands.
   for i=0,math.ceil(delta.Magnitude/2)do
    local fraction=if delta.Magnitude==0 then 0 else math.min(1,i/math.ceil(delta.Magnitude/2))
    local position=snapshot.position+delta*fraction
    if not routeContains(route,position)then return recoverWalking(player,snapshot,"TravelUnavailable")end
   end
   snapshot.returnAxis=localReturnAxis(delta)or snapshot.returnAxis
   snapshot.position=root.Position;snapshot.at=now()
   if Config.walkingContains(route.entries[snapshot.to],root.Position) and inZone(snapshot.to,root.Position)then
    local region=walkingZone(snapshot.to)
    local spawn=region and region.spawn
    if not spawn then return recoverWalking(player,snapshot,"TravelUnavailable")end
    -- No yields, player pivot, velocity reset, follower reset or persistence write.
    zones[player]=snapshot.to;player:SetAttribute("CurrentZone",snapshot.to);player.RespawnLocation=spawn
    clearWalking(player)
    -- Keep an identity-bound arrival sample: standing/jitter is not a return trip.
    local arrival={session=session,epoch=session.epoch,token=session.token,character=c,position=root.Position,at=now(),route=route,zone=snapshot.to,
     axis=snapshot.returnAxis or V(0,0,0),progress=0}
    walkingArrivals[player]=arrival;walkingSamples[player]=arrival
   end
   return true
  end
  local zone=zones[player]or "Guild"
  if not walkingZone(zone)then return false end
  local previous=walkingSamples[player]
  local sample={session=session,epoch=session and session.epoch,token=session and session.token,character=c,position=root.Position,at=now()}
  walkingSamples[player]=sample
  if not session then return false end
  local arrival=walkingArrivals[player]
  if arrival and (not Rules.walkingIdentity(arrival,session,c) or arrival.zone~=zone or not routeContains(arrival.route,root.Position))then
   walkingArrivals[player]=nil;arrival=nil
  end
  -- Resolve all possible entries before choosing; descriptor order grants no priority.
  local choices=0
  for _,route in ipairs(walking.Routes)do
   if routeReady(route) and (zone==route.fromZone or zone==route.toZone)then
    local entry=Config.walkingContains(route.entries[zone],root.Position) and inZone(zone,root.Position)
    local corridor=routeContains(route,root.Position)
    if entry or (corridor and not inZone(zone,root.Position)) or (arrival and arrival.route==route and corridor)then choices+=1 end
   end
  end
  -- Ambiguity is not a validated movement sample or arrival continuation.
  if choices>1 then clearWalking(player);return true end
  for _,route in ipairs(walking.Routes or {})do
   if routeReady(route) and (zone==route.fromZone or zone==route.toZone)then
    local to=if zone==route.fromZone then route.toZone else route.fromZone
    local atEntry=Config.walkingContains(route.entries[zone],root.Position) and inZone(zone,root.Position)
    local unauthorized=routeContains(route,root.Position) and not inZone(zone,root.Position)
    local returnMotion=false
    if arrival and arrival.route==route then
     local offset=root.Position-arrival.position
     local progress=offset.X*arrival.axis.X+offset.Z*arrival.axis.Z
     arrival.progress=math.min(arrival.progress,progress)
     returnMotion=progress-arrival.progress>=2
    end
    -- An immediate turnaround may cross the entry edge between samples.
    local returning=arrival and arrival.route==route and previous and Rules.walkingIdentity(previous,session,c)
     and routeContains(route,root.Position)
    if atEntry or unauthorized or returning then
     local candidate={session=session,epoch=session.epoch,token=session.token,character=c,route=route,from=zone,to=to,position=root.Position,at=now()}
     local problem=gate(player,session,zone,to)
     if (unauthorized and not returning) or problem then
      walkingStops[player]=candidate;return recoverWalking(player,candidate,problem or "VisitStation")
     end
     -- Need two samples of this same actor; a remote jump cannot create admission.
     if previous and Rules.walkingIdentity(previous,session,c)then
      local distance=(root.Position-previous.position).Magnitude
      if distance~=distance or distance>35 or now()-previous.at>2 then
       walkingStops[player]=candidate;return recoverWalking(player,candidate,"VisitStation")
      end
      if returning then
       local delta=root.Position-previous.position
       for i=0,math.ceil(distance/2)do
        local position=previous.position+delta*(if distance==0 then 0 else math.min(1,i/math.ceil(distance/2)))
        if not routeContains(route,position)then
         walkingStops[player]=candidate;return recoverWalking(player,candidate,"VisitStation")
        end
       end
      end
      if arrival and arrival.route==route and not returnMotion then return true end
      if not Rules.walkingIdentity(candidate,walkingSession(player),player.Character)then return true end
      candidate.returnAxis=localReturnAxis(root.Position-previous.position)
      walkingArrivals[player]=nil
      walkingStops[player]=candidate
      -- Atomic presentation hint only; never consulted by authority or eligibility.
      if c then c:SetAttribute("WalkingRouteContext",Rules.walkingContext(route.id,zone,to))end
     end
     return true
    end
   end
  end
  return false
 end
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
   if walkingTick(player,c,root)then continue end
			if root and alive(player) then
				local zone=zones[player] or "Guild"
					if root.Position.Y< -15 or (Config.Regions[zone] and Config.region(root.Position.X,root.Position.Z)~=zone) or ((Civic.Definitions :: any)[zone] and not Civic.contains(zone,root.Position.X,root.Position.Z)) then S.Travel(player,zone) end
			end
		end
	end)
	return S
end
