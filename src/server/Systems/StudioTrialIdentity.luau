--!strict
-- Trusted local fixture policy. Never accept this context from a remote/profile.
return function(context:any,ownerId:any,isCurrentOriginalPlayer:any):any
 local localTest=type(context)=="table"and context.IsStudio==true and context.PlaceId==0 and context.GameId==0 and context.PersistenceMode=="Memory"
 return function(id:any):boolean
  if type(id)~="number"or id~=id or id==0 or math.abs(id)>9007199254740991 or id%1~=0 then return false end
  if id~=ownerId or type(isCurrentOriginalPlayer)~="function"then return false end
  local thread=coroutine.create(isCurrentOriginalPlayer);local ok,current=coroutine.resume(thread)
  if coroutine.status(thread)~="dead"then coroutine.close(thread);return false end
  if not ok or current~=true then return false end
  return id>0 or localTest
 end
end
