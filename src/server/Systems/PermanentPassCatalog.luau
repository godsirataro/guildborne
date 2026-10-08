--!strict
-- Permanent land/theme purchases use Game Pass IDs, not Developer Product IDs.
-- Existing ProductId fields retain their save/config shape. Zero means unconfigured.
return function(land:any,themes:any)
 local byId:any={};local ordered:{number}={}
 local function add(passId:any,kind:string,key:string)
  assert(type(passId)=="number" and passId==passId and passId%1==0 and passId>=0 and passId<=9007199254740991,"Invalid permanent pass ID")
  if passId==0 then return end
  assert(not byId[passId],"Pass ID must identify exactly one permanent entitlement")
  byId[passId]={kind=kind,key=key,passId=passId};table.insert(ordered,passId)
 end
 for key,def in pairs(land) do add(def.productId,"Land",key) end
 for key,def in pairs(themes.Themes) do if def.Mode=="Purchase" then add(def.ProductId,"Theme",key) end end
 table.sort(ordered)
 return {ById=byId,Order=ordered}
end
