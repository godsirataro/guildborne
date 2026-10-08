--!strict
-- Native physics/TravelService fixture with a dummy character, never player data.
return function():any
 local factory=require(game.ServerScriptService.Server.Services.TravelService)
 local config=require(game.ReplicatedStorage.Shared.Config.City)
 local f=Instance.new("Folder");f.Name="TravelSafetyFixture";f.Parent=workspace
 local town=Instance.new("Folder");town.Name="City";town.Parent=f
 local function part(parent:Instance,name:string,size:Vector3,pos:Vector3,solid:boolean):Part
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true;p.CanCollide=solid;p.Transparency=1;p.Parent=parent;return p
 end
 part(town,"Floor",Vector3.new(920,1,1020),Vector3.new(0,0,-1130),true)
 local island=Instance.new("Model");island.Parent=f
 part(island,"Floor",Vector3.new(170,1,170),Vector3.new(0,1,0),true)
 local character=Instance.new("Model");character.Parent=f
 local root=part(character,"HumanoidRootPart",Vector3.new(2,2,1),Vector3.new(0,5,-1490),false);character.PrimaryPart=root
 local humanoid=Instance.new("Humanoid");humanoid.Parent=character
 local attrs={};local player:any={Character=character,SetAttribute=function(_,key,value)attrs[key]=value end}
 local gates={};for id,definition in pairs(config.GuildPortalStops)do local d:any=definition
  local gate=part(town,id,Vector3.one,Vector3.new(d.X,6,d.Z),false);gate:SetAttribute("TravelDestination","Guild");gate:SetAttribute("CityReturnStop",id);table.insert(gates,gate)
 end
 local guildGate=part(f,"HomeGate",Vector3.one,Vector3.new(-44,6,-65),false);guildGate:SetAttribute("TravelDestination","City")
 local portals=table.clone(gates);table.insert(portals,guildGate)
 local plots:any={[player]={origin=Vector3.new(0,1,0),model=island}}
 local moves=0;local travel=factory({town=town,guildAccessPortals=gates,portals=portals},plots,{Travel=function()moves+=1 end})
 local ok,result=pcall(function():any
  assert(travel.Travel(player,"Guild"));character:PivotTo(CFrame.new(-44,5,-65));assert(attrs.CurrentZone=="Guild")
  local remembered=part(town,"RememberedBlocked",Vector3.new(8,9,20),Vector3.new(0,5,-1506),true)
  local first=part(town,"DefaultBlocked",Vector3.new(8,9,10),Vector3.new(0,5,-720),true)
  local second=part(town,"FallbackBlocked",Vector3.new(8,9,10),Vector3.new(0,5,-750),true)
  local before=character:GetPivot();assert(travel.Validate(player,"City")=="TravelUnavailable")
  assert(not travel.Travel(player,"City")and character:GetPivot()==before and attrs.CurrentZone=="Guild","Unsafe arrival")
  first:Destroy();second:Destroy();assert(travel.Validate(player,"City")==nil)
  assert(travel.Travel(player,"City"));assert((root.Position-Vector3.new(0,5,-720)).Magnitude<.1,"Missing normal fallback")
  remembered:Destroy()
  character:PivotTo(CFrame.new(300,5,-1080));assert(travel.Travel(player,"Guild"));assert(travel.Travel(player,"City"));assert((root.Position-Vector3.new(300,5,-1068)).Magnitude<.1)
  travel.Remove(player);character:PivotTo(CFrame.new(0,5,23));assert(travel.Travel(player,"City"));assert((root.Position-Vector3.new(0,5,-720)).Magnitude<.1,"Return stop survived removal")
  return {allLandingsBlockedRejected=true,blockedRememberedStopUsesDefault=true,newStopReplacesOld=true,removeClearsStop=true,simulatedArrivals=moves,actualPlayerMovement=false,profileWrites=0}
 end)
 travel.Remove(player);table.clear(plots);f:Destroy();if not ok then error(result)end;return result
end
