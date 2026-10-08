--!strict
-- No client prices or IDs. One prompt at a time; verified ownership restores instead.
return function(deps:any)
 local S={};local pending:any={};local last:any={}
 function S.Finished(userId:number,passId:number)
  if pending[userId] and pending[userId].passId==passId then pending[userId]=nil end
 end
 function S.Remove(userId:number)pending[userId]=nil;last[userId]=nil end
 function S.Request(userId:number,revision:number,kind:string,key:string):string
  if deps.Enabled~=true then return "PurchaseUnavailable" end
  local session=deps.Data.Sessions[userId]
  local function ready():string?
   if not session or deps.Data.Sessions[userId]~=session or not session.record then return "ProfileNotReady" end
   if session.closing then return "Closing" end
   if session.state~="Active" or session.busy then return "SavePending" end
   if session.record.revision~=revision then return "StaleRevision" end
   if deps.Now()>=session.record.session.leaseExpiresAt-deps.LeaseSafetySeconds then return "LeaseExpiring" end
   return deps.Spatial(userId)
  end
  local problem=ready();if problem then return problem end
  if pending[userId] then return "PurchasePromptOpen" end
  local now=deps.Clock();if last[userId] and now-last[userId]<3 then return "PurchaseCooling" end
  local code,passId=deps.Offers.resolve(session.record.data,kind,key)
  if code~="OK" or not passId then return code end
  local ticket={passId=passId};pending[userId]=ticket;last[userId]=now
  local ok,result=pcall(function():string
   local owns=deps.Owns(userId,passId)
   if type(owns)~="boolean" then return "OwnershipUnavailable" end
   local changed=ready();if changed then return changed end
   local current,currentPass=deps.Offers.resolve(session.record.data,kind,key)
   if current~="OK" or currentPass~=passId then return current end
   if owns then return deps.Data.CommitPermanentPass(userId,passId) end
   deps.Prompt(userId,passId);return "PurchasePromptOpened"
  end)
  -- The finish event releases a successful prompt. Failed checks never strand it.
  if not ok or result~="PurchasePromptOpened" then
   if pending[userId]==ticket then pending[userId]=nil end
  end
  return if ok then result else "PurchaseUnavailable"
 end
 return S
end
