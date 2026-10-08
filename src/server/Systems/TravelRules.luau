--!strict
return function(config: any)
	local R={}
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
