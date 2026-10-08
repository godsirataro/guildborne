--!strict
-- Private course-facing lifecycle. Never expose Start or completion to a Remote.
-- Arena creation, spatial allocation and notifications are supplied by the world.
return function(deps:any)
 local entries:{[number]:any}={};local slots:{[number]:number}={};local M={}
 local function remove(userId:number)
  local entry=entries[userId];if not entry then return end
  entries[userId]=nil;slots[entry.slot]=nil;if entry.arena then entry.arena.Destroy()end
 end
 function M.Start(player:any,classId:string):string
  local userId=player.UserId;local session=deps.Data.Sessions[userId]
  if not session or session.closing or session.state~="Active"then return "ProfileNotReady"end
  if session.busy then return "Busy"end
  local old=entries[userId]
  if old then
   if not old.arena then return "Busy"end
   local state=old.arena.Snapshot()
   if state.status=="Active"then return "TrialAlreadyActive"end
   if state.status=="Won"and old.delivery~="Committed"and old.delivery~="Rejected"then return "SavePending"end
   remove(userId)
  end
  local slot:number?=nil
  for i=1,deps.MaxArenas do if not slots[i]then slot=i;break end end
  if not slot then return "TrialCapacity"end
  local runId=deps.NewRunId();local eligible,problem=deps.Trials.start(session.record.data,userId,classId,runId,deps.Now())
  if not eligible then return problem end
  local entry:any={slot=slot,epoch=session.epoch,token=session.token,delivery="Waiting"}
  slots[slot]=userId;entries[userId]=entry
  local function completed(receipt:any):boolean
   local current=deps.Data.Sessions[userId]
   if entries[userId]~=entry or not current or current.epoch~=entry.epoch or current.token~=entry.token or current.closing then return false end
   if entry.delivery=="Committed"then return true end
   if entry.delivery=="Rejected"then return false end
   if type(receipt)~="table"or type(receipt.args)~="table"or receipt.owner~=userId or receipt.requestId~="trial:"..runId or receipt.action~="NoviceTrial"or receipt.args.classId~=classId then entry.delivery="Rejected";entry.problem="InvalidReceipt";return false end
   entry.send=entry.send or deps.MakeReceipt(userId,receipt)
   local outcome,code=entry.send();entry.delivery=outcome;entry.problem=code
   if outcome=="Committed"then pcall(deps.Notify,player);pcall(deps.Data.FlushAudit,userId);return true end
   return false
  end
  local ok,arena=pcall(deps.CreateArena,player,session.record.data,classId,runId,deps.Origin(slot),completed,function()return M.Stop(player)end)
  if not ok then entries[userId]=nil;slots[slot]=nil;return "TrialUnavailable"end
  entry.arena=arena;return "OK"
 end
 function M.Stop(player:any):string
  local entry=entries[player.UserId];if not entry then return "NoTrial"end
  if not entry.arena then return "Busy"end
  if entry.arena.Snapshot().status=="Won"and entry.delivery~="Committed"and entry.delivery~="Rejected"then return "SavePending"end
  remove(player.UserId);return "OK"
 end
 function M.Remove(player:any)remove(player.UserId)end
 function M.Step()
  for userId,entry in pairs(entries)do
   local session=deps.Data.Sessions[userId]
   if not session or session.closing or session.epoch~=entry.epoch or session.token~=entry.token then remove(userId)end
  end
 end
 function M.State(userId:number):any
  local entry=entries[userId];if not entry then return nil end
  return {slot=entry.slot,delivery=entry.delivery,problem=entry.problem,status=if entry.arena then entry.arena.Snapshot().status else "Preparing"}
 end
 return M
end
