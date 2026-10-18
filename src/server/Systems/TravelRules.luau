--!strict
return function(config: any)
	local R={}
 -- Identity readiness only. No geometry, activation or eligibility is granted here.
 local walkingPairs:{[string]:{string}}={city_greenwood_west={"City","Greenwood"},greenwood_ironveil_south={"Greenwood","Ironveil"}}
 function R.walkingContext(routeId:any,from:any,to:any):string?
  local pair=if type(routeId)=="string" then walkingPairs[routeId] else nil
  if not pair or not ((from==pair[1] and to==pair[2])or(from==pair[2] and to==pair[1]))then return nil end
  return routeId.."|"..from.."|"..to
 end
 function R.walkingRoutesValid(routes:any):boolean
  if type(routes)~="table" or #routes>16 then return false end
  local count=0;local ids={};local pairsSeen={}
  for key,route in pairs(routes)do
   if type(key)~="number" or key%1~=0 or key<1 or key>#routes or type(route)~="table"
    or not R.walkingContext(route.id,route.fromZone,route.toZone)then return false end
   local pair=if route.fromZone<route.toZone then route.fromZone.."|"..route.toZone else route.toZone.."|"..route.fromZone
   if ids[route.id]or pairsSeen[pair]then return false end
   ids[route.id]=true;pairsSeen[pair]=true;count+=1
  end
  return count==#routes
 end
 function R.walkingZone(city:any,civic:any,zone:string):any
  if not config.Destinations[zone]then return nil end
  if zone=="City"then return {model=city.town,spawn=city.spawn}end
  if config.Regions[zone]then return city.regions and city.regions[zone]end
  if civic.Definitions[zone]then return city.civicRegions and city.civicRegions[zone]end
  return nil -- Guild plots and private campaign pockets are never surface zones.
 end
 function R.walkingSurface(civic:any,zone:string,position:Vector3):boolean
  local x,y,z=position.X,position.Y,position.Z
  if x~=x or y~=y or z~=z or math.abs(x)==math.huge or math.abs(z)==math.huge or y<0 or y>35 then return false end
  if zone=="City"then return config.contains(x,z)end
  local d=config.Regions[zone]
  if d then return x>=d.X-d.HalfWidth and x<=d.X+d.HalfWidth and z>=d.Z-d.Back and z<=d.Z+d.Front end
  return civic.Definitions[zone]~=nil and civic.contains(zone,x,z)
 end
 -- Trusted integration hooks still fail closed on exceptions or accidental yields.
 function R.walkingCall(callback:any,...:any):(boolean,any)
  if type(callback)~="function" then return false,nil end
  local thread=coroutine.create(callback);local ok,value=coroutine.resume(thread,...)
  if coroutine.status(thread)~="dead" then coroutine.close(thread);return false,nil end
  return ok,value
 end
 function R.walkingIdentity(snapshot:any,session:any,character:any):boolean
  return snapshot~=nil and session~=nil and snapshot.session==session and snapshot.epoch==session.epoch
   and snapshot.token==session.token and snapshot.character==character and not session.closing
 end
 function R.walkingProblem(session:any,alive:boolean,downed:boolean,inCombat:boolean,tower:boolean):string?
  if not session or session.state~="Active" or session.closing or not session.record then return "ActorNotReady"end
  if session.busy then return "SavePending"end
  if not alive then return "ActorNotReady"end
  if downed then return "Downed"end
  if inCombat then return "ReturnToGuild"end
  if tower then return "FinishExpedition"end
  return nil
 end
	function R.localCurrent(snapshot:any,session:any):boolean
		return snapshot~=nil and session~=nil and snapshot.session==session and snapshot.epoch==session.epoch and snapshot.token==session.token
			and not session.closing and session.state=="Active" and session.record~=nil and not session.busy
	end
	function R.localValidate(session:any,character:any,snapshot:any,enter:boolean,alive:boolean,downed:boolean,inCombat:boolean,tower:boolean,distance:number,gate:string?):string?
		if not session or session.state~="Active" or session.closing or session.busy or not session.record then return "ActorNotReady"end
		if snapshot and (not R.localCurrent(snapshot,session) or snapshot.character~=character)then return "ActorNotReady"end
		if enter and snapshot then return "AlreadyThere"end
		if not enter and not snapshot then return "TravelUnavailable"end
		if gate then return gate end
		if not alive then return "ActorNotReady"end
		if downed then return "Downed"end
		if inCombat then return "ReturnToGuild"end
		if tower then return "FinishExpedition"end
		if distance~=distance or distance<0 or distance>16 then return "VisitStation"end
		return nil
	end
	function R.validate(zone: any,alive: boolean,downed: boolean,inCombat: boolean,towerActive: boolean,distance: number): string?
		if type(zone)~="string" or not config.Destinations[zone] then return "InvalidZone" end
		if not alive then return "ActorNotReady" end
		if downed then return "Downed" end
		if inCombat then return "ReturnToGuild" end
		if towerActive then return "FinishExpedition" end
		if distance~=distance or distance>16 or distance<0 then return "VisitStation" end
		return nil
	end
	function R.accept(bucket: any,now: number): boolean
		if now<(bucket.nextAt or 0) then return false end
		bucket.nextAt=now+2;return true
	end
	function R.resolve(zone: string,primaryValid: boolean,returnStop: string?): (number,number,number)
  local stop=zone=="City" and returnStop and config.GuildPortalStops and config.GuildPortalStops[returnStop]
  if stop then return if primaryValid then stop.ReturnX else stop.FallbackX,config.Destinations.City.Y,if primaryValid then stop.ReturnZ else stop.FallbackZ end
		local d=config.Destinations[zone] or config.Destinations.Guild
		return if primaryValid then d.X else d.FallbackX,d.Y,if primaryValid then d.Z else d.FallbackZ
	end
	return R
end
