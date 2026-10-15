--!strict
-- Internal owner keys only route delivery; they never enter telemetry payloads.
-- Session-local best effort, not a durable or exactly-once analytics ledger.
return function(deps:any)
 local sessions:any={};local count=0;local S={}
 local function finite(n:any):boolean return type(n)=="number" and n==n and n~=math.huge and n~=-math.huge end
 local function key(id:any):boolean return finite(id) and id%1==0 and id~=0 and math.abs(id)<=9007199254740991 end
 local function clock():number?
  local ok,value=pcall(deps.Now);return if ok and finite(value) and value>=0 then value else nil
 end
 local function milestone(id:number,state:any,name:string):boolean
  if state.seen[name]then return false end
  local now=clock();if not now then return false end
  state.seen[name]=true
  local elapsed=math.clamp(math.floor(now-state.start),0,86400)
  pcall(deps.Emit,id,"onboarding_milestone",{version=1,milestone=name,elapsedSeconds=elapsed})
  return true
 end
 function S.Begin(id:number):boolean
  if not key(id) or sessions[id] or count>=256 then return false end
  local now=clock();if not now then return false end
  local state={start=now,seen={}};sessions[id]=state;count+=1
  milestone(id,state,"session_ready");return true
 end
 function S.Observe(id:number,event:string,payload:any):boolean
  if not key(id)then return false end
  local state=sessions[id];if not state or type(payload)~="table"then return false end
  if event=="combat_player_damage" or event=="combat_player_heal"then
   if not finite(payload.amount) or payload.amount<=0 then return false end
   return milestone(id,state,"first_effective_combat")
  elseif event=="hero_order_accepted"then
   local order=payload.order
   if type(order)~="string" or not ({Focus=true,Regroup=true,Retreat=true,Hold=true,TacticBalanced=true,TacticDefensive=true})[order]then return false end
   return milestone(id,state,"first_hero_order")
  elseif event=="novice_class_selected" or event=="player_class_selected"then return milestone(id,state,"class_selected")
  elseif event=="novice_guild_founded"then
   local changed=milestone(id,state,"guild_founded")
   return milestone(id,state,"first_npc_recruited") or changed
  elseif event=="adventurer_recruited" or event=="campaign_recruit_granted"then return milestone(id,state,"first_npc_recruited")
  elseif event=="combat_reward"then return milestone(id,state,"first_combat_reward")
  elseif event=="campaign_chapter_claimed"then return milestone(id,state,"first_campaign_chapter")end
  return false
 end
 function S.End(id:number)
  if key(id) and sessions[id]then sessions[id]=nil;count-=1 end
 end
 return S
end
