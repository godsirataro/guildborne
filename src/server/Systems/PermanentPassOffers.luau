--!strict
-- Re-evaluated from authoritative data immediately before opening a platform prompt.
return function(catalog:any,land:any,themes:any)
 local S={};local keys:any={Land={},Theme={}}
 for _,def in pairs(catalog.ById)do keys[def.kind][def.key]=def.passId end
 function S.resolve(data:any,kind:string,key:string):(string,number?)
  local group=keys[kind];local passId=group and group[key]
  if not passId then return "PurchaseUnavailable",nil end
  if kind=="Land" then
   if not data.guildLand then return "LandUnavailable",nil end
   local plot=data.guildLand.plots[key]
   if plot and plot.entitlement then return "AlreadyCommitted",nil end
   if land.describe(data.guildLand,key).status~="PurchaseRequired" then return "QuestLocked",nil end
  elseif themes.owned(data.expansion,key) then return "AlreadyCommitted",nil end
  return "OK",passId
 end
 return S
end
