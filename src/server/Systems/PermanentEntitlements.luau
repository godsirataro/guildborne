--!strict
-- Trusted ownership verifier calls this through PlayerDataService, never a Remote.
return function(catalog:any,land:any,themes:any,util:any)
 local S={}
 function S.apply(record:any,passId:number):(any,any,any)
  local def=catalog.ById[passId]
  if not def then return nil,{code="UnknownPass"},{} end
  local candidate=util.copy(record)
  local reference="gamepass:"..tostring(passId)
  local code:string
  if def.kind=="Land" then
   if not candidate.data.guildLand then return nil,{code="LandUnavailable"},{} end
   code=land.recordVerifiedEntitlement(candidate.data.guildLand,def.key,passId,reference)
  else code=themes.recordVerified(candidate.data.expansion,def.key,passId,reference) end
  if code=="AlreadyCommitted" or code=="AlreadyOwned" or code=="ThemeAlreadyOwned" then return nil,{code="AlreadyCommitted"},{} end
  if code~="OK" then return nil,{code=code},{} end
  return candidate,{code="OK"},{{name="permanent_pass_restored",payload={passId=passId,kind=def.kind,key=def.key}}}
 end
 return S
end
