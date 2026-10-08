--!strict
-- Server-only escort state. Pure coordinates make timing/failure rules testable.
-- The caller supplies measured player/NPC evidence; no client commands or rewards.
type Point={x:number,y:number,z:number}
type Evidence={ownerAlive:boolean,ownerDistance:number,exitDistance:number?,npcAlive:boolean,blocked:boolean,sessionCurrent:boolean}
local function finite(n:any):boolean return type(n)=="number"and n==n and math.abs(n)<1000000 end
local function point(p:any):boolean return type(p)=="table"and finite(p.x)and finite(p.y)and finite(p.z)end
local function distance(a:Point,b:Point):number return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2+(a.z-b.z)^2)end
return function(route:{Point},speed:number?):any
 assert(#route>=2 and #route<=128,"Invalid escort route")
 local nodes={};local length=0
 for i,p in ipairs(route)do
  assert(point(p),"Invalid escort coordinate")
  nodes[i]={x=p.x,y=p.y,z=p.z}
  if i>1 then local segment=distance(p,route[i-1]);assert(segment>.01 and segment<=100,"Invalid escort segment");length+=segment end
 end
 assert(length<=500,"Escort route too long")
 local rate=speed or 5;assert(finite(rate)and rate>=1 and rate<=10,"Invalid escort speed")
 local state:any={status="Walking",position=nodes[1],next=2,elapsed=0,pause=0,blocked=0,traveled=0,reason=nil}
 local S={}
 function S.snapshot():any
  return {status=state.status,position={x=state.position.x,y=state.position.y,z=state.position.z},next=state.next,elapsed=state.elapsed,traveled=state.traveled,reason=state.reason,length=length}
 end
 function S.cancel(reason:string?)
  if state.status=="Completed"or state.status=="Failed"or state.status=="Cancelled"then return end
  state.status="Cancelled";state.reason=reason or "Cancelled"
 end
 function S.step(dt:number,e:Evidence):any
  assert(finite(dt)and dt>=0,"Invalid escort delta")
  assert(finite(e.ownerDistance)and e.ownerDistance>=0,"Invalid escort distance")
  assert(e.exitDistance==nil or (finite(e.exitDistance)and e.exitDistance>=0),"Invalid exit distance")
  if state.status=="Completed"or state.status=="Failed"or state.status=="Cancelled"then return S.snapshot()end
  if not e.sessionCurrent then S.cancel("SessionChanged");return S.snapshot()end
  if not e.ownerAlive or not e.npcAlive then state.status="Failed";state.reason=if not e.ownerAlive then "OwnerDefeated"else "NpcDefeated";return S.snapshot()end
  -- A delayed frame cannot teleport the actor or instantly complete the journey.
  local slice=math.min(dt,.25);state.elapsed+=slice
  if state.elapsed>=180 then state.status="Failed";state.reason="TimedOut";return S.snapshot()end
  if e.ownerDistance>24 then
   state.pause+=slice;state.status="Paused";state.reason="WaitForOwner"
   if state.pause>=30 then state.status="Failed";state.reason="OwnerLeft"end
   return S.snapshot()
  end
  state.pause=0
  if e.blocked then
   state.blocked+=slice;state.status="Paused";state.reason="PathBlocked"
   if state.blocked>=5 then state.status="Failed"end
   return S.snapshot()
  end
  state.blocked=0;state.status="Walking";state.reason=nil
  local remaining=rate*slice
  while remaining>0 and state.next<=#nodes do
   local target=nodes[state.next];local span=distance(state.position,target)
   local advance=math.min(span,remaining)
   local alpha=if span>.0001 then advance/span else 1
   state.position={x=state.position.x+(target.x-state.position.x)*alpha,y=state.position.y+(target.y-state.position.y)*alpha,z=state.position.z+(target.z-state.position.z)*alpha}
   state.traveled+=advance;remaining-=advance
   if advance>=span-.0001 then state.next+=1 else break end
  end
  if state.next>#nodes then
   if (e.exitDistance or e.ownerDistance)<=8 then state.status="Completed"else state.status="Paused";state.reason="MeetAtExit"end
  end
  return S.snapshot()
 end
 return S
end
