--!strict
local Config=require(game.ReplicatedStorage.Shared.Config.City)
local Civic=require(game.ReplicatedStorage.Shared.Config.CivicCities)
local Rules=require(script.Parent.Parent.Systems.TravelRules)(Config)
local V=Vector3.new
return function(city: any,plots: any,heroes: any)
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
		if not Rules.accept(bucket,os.clock()) then return "TravelCooling" end
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
  if zone=="Guild"then rememberCityStop(player)end
		return arrive(player,zone,target)
	end
	-- Only the server visit adapter supplies a checked landing. Respawn stays at home.
	function S.Visit(player:Player,target:Vector3):boolean rememberCityStop(player);return arrive(player,"Guild",target) end
	function S.Respawn(player: Player) S.Travel(player,zones[player] or "Guild") end
	function S.Remove(player: Player) zones[player]=nil;buckets[player]=nil;returnStops[player]=nil end
	local elapsed=0
	game:GetService("RunService").Heartbeat:Connect(function(dt)
		elapsed+=dt;if elapsed<.5 then return end;elapsed=0
		for player in pairs(plots) do
			local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
			if root and alive(player) then
				local zone=zones[player] or "Guild"
					if root.Position.Y< -15 or (Config.Regions[zone] and Config.region(root.Position.X,root.Position.Z)~=zone) or ((Civic.Definitions :: any)[zone] and not Civic.contains(zone,root.Position.X,root.Position.Z)) then S.Travel(player,zone) end
			end
		end
	end)
	return S
end
