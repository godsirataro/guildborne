--!strict
-- Tactical intent only. Existing combat validates every target, hit and cooldown.
local T={}
function T.isOrder(action:string):boolean
 return ({Focus=true,Regroup=true,Retreat=true,Hold=true,TacticBalanced=true,TacticDefensive=true})[action]==true
end
function T.apply(actor:any,action:string,position:any)
 if action=="TacticBalanced" or action=="TacticDefensive"then
  actor.tactic=if action=="TacticDefensive"then "Defensive"else "Balanced"
  actor.order=nil;actor.holdPoint=nil;actor.focusTarget=nil
 else actor.order=action;actor.holdPoint=if action=="Hold"then position else nil end
end
function T.clear(actor:any)
 actor.order=nil;actor.holdPoint=nil;actor.focusTarget=nil;actor.tacticReason=nil
end
function T.offset(class:string,slot:number):any
 local row=if class=="Knight"then -4 elseif class=="Warrior"then 0 else 5
 return {x=(slot-3)*3,z=row}
end
function T.select(actor:any,leader:any,enemies:any,target:any,engage:boolean,close:boolean,now:number,distance:any):(any,string)
 if actor.order=="Hold"then return nil,"TacticHolding"end
 if actor.order=="Regroup"then return nil,"TacticRegrouping"end
 if actor.order=="Retreat"then return nil,"TacticRetreating"end
 if not close then return nil,"TacticLeash"end
 if not engage then return nil,"TacticFollowing"end
 local focus=actor.focusTarget
 if actor.order=="Focus" and focus and table.find(enemies,focus)and target.valid(actor,focus,actor.detectionRange)then return focus,"TacticFocusing"end
 if actor.tactic=="Defensive"then
  if not leader then return nil,"TacticGuarding"end
  local candidates={};local threats={}
  for _,enemy in ipairs(enemies)do
   if target.valid(actor,enemy,actor.detectionRange)and distance(leader,enemy)<=12 then
    table.insert(candidates,enemy)
    if enemy.target==leader then table.insert(threats,enemy)end
   end
  end
  local choice=target.enemy(actor,if #threats>0 then threats else candidates,actor.previousTarget,actor.detectionRange,now)
  if choice and not table.find(candidates,choice) then choice=nil end
  return choice,if choice then "TacticProtecting"else "TacticGuarding"
 end
 local choice=target.enemy(actor,enemies,actor.previousTarget,actor.detectionRange,now)
 return choice,if choice then "TacticEngaging"else "TacticFollowing"
end
return T
