--!strict
-- Injected platform ownership check may yield. Session identity is rechecked after it.
-- This restores durable ownership; it cannot unlock quests, contribute items or open land.
return function(deps:any)
 local S={};local busy:any={}
 function S.Restore(userId:number,onlyPassId:number?):string
  if deps.Enabled~=true then return "PurchasesDisabled" end
  local session=deps.Data.Sessions[userId]
  if not session or not session.record then return "ProfileNotReady" end
  if session.closing then return "Closing" end
  if busy[userId] then return "Busy" end
  if onlyPassId and not deps.Catalog.ById[onlyPassId] then return "UnknownPass" end
  busy[userId]=true
  local ok,result=pcall(function():string
   local ids=if onlyPassId then {onlyPassId} else deps.Catalog.Order
   local outcome="OK"
   for _,passId in ipairs(ids) do
    if deps.Data.Sessions[userId]~=session or session.closing then return "SessionChanged" end
    local verified,owns=pcall(deps.Owns,userId,passId)
    if deps.Data.Sessions[userId]~=session or session.closing then return "SessionChanged" end
    if not verified or type(owns)~="boolean" then outcome="OwnershipUnavailable"
    elseif owns then
     if session.state=="Degraded" then deps.Data.Refresh(userId) end
     if deps.Data.Sessions[userId]~=session or session.closing then return "SessionChanged" end
     local code=deps.Data.CommitPermanentPass(userId,passId)
     if code=="OK" or code=="AlreadyCommitted" then
      -- Presentation/audit failure must not undo an already durable grant.
      pcall(deps.Notify,userId);pcall(deps.Data.FlushAudit,userId)
     else outcome=code end
    end
   end
   return outcome
  end)
  busy[userId]=nil
  return if ok then result else "RestoreUnavailable"
 end
 return S
end
