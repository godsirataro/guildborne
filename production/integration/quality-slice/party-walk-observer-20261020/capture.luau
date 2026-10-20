--!strict
-- Execute once through the server MCP evaluator in the disposable party lab.
-- Observations only: no movement, remote commands, attributes or gameplay writes.
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
assert(Run:IsServer() and Run:IsStudio() and game.PlaceId==0 and game.GameId==0,"Unsaved server Studio only")
local runtime=require(game.ServerScriptService.Server.Config.Runtime)
assert(runtime.StudioPersistence=="Memory" and type(runtime.AllowedDataStoreUniverses)=="table" and next(runtime.AllowedDataStoreUniverses)==nil,"Memory only")
local lab=workspace:FindFirstChild("PartyPresentationLab")
assert(lab and lab:GetAttribute("Ready")==true and lab:GetAttribute("Synthetic")==true,"Ready synthetic party lab required")
local players=Players:GetPlayers()
assert(#players==1,"Exactly one local player required")
local owner=players[1]
assert(lab:GetAttribute("OwnerUserId")==owner.UserId,"Lab owner mismatch")
local character=owner.Character
assert(character and character:IsDescendantOf(workspace),"Player character required")
local previous=(_G :: any).GuildborneWalkCapture
assert(previous==nil,"Existing capture retained; export and explicitly clear after completion")
assert((_G :: any).GuildborneWalkStop==nil,"Existing observer stop handle refused")
local world=workspace:FindFirstChild("GuildborneWorld")
assert(world,"World required")
local plot=world:FindFirstChild("PersonalGuild")
assert(plot and plot:IsA("Model") and plot:GetAttribute("OwnerUserId")==owner.UserId,"Owned fixture plot required")
local heroFolder=plot:FindFirstChild("Heroes")
assert(heroFolder and heroFolder:IsA("Folder"),"Owned Heroes folder required")
local heroes={}
local children=heroFolder:GetChildren()
assert(#children==5,"Exactly five direct hero children required")
for _,model in ipairs(children) do
 if model:IsA("Model") and model:GetAttribute("GuildborneHero")==true and model:GetAttribute("OwnerUserId")==owner.UserId then
  table.insert(heroes,model)
 end
end
assert(#heroes==5,"Exactly five existing companions required")
table.clear(children)
table.sort(heroes,function(a,b)return tostring(a:GetAttribute("AdventurerId"))<tostring(b:GetAttribute("AdventurerId"))end)
local roster:any={};local models:{Instance}={character};local seen={player=true}
local expected={["a:Knight"]=true,["a:Warrior"]=true,["a:Archer"]=true,["a:Mage"]=true,["a:Priest"]=true}
local function bind(id:string,model:Model)
 local root=model:FindFirstChild("HumanoidRootPart")
 local humanoid=model:FindFirstChildOfClass("Humanoid")
 assert(root and root:IsA("BasePart") and humanoid and humanoid.Health>0,"Live complete actor required: "..id)
 local class=if id=="player" then "Warrior" else string.sub(id,3)
 assert(model:GetAttribute("ClassId")==class,"Fixture class mismatch: "..id)
 table.insert(roster,{id=id,class=class,model=model,root=root,humanoid=humanoid})
end
bind("player",character)
for _,hero in ipairs(heroes)do
 local id=hero:GetAttribute("AdventurerId")
 assert(type(id)=="string" and expected[id] and not seen[id],"Exact unique fixture companion identity required")
 seen[id]=true;table.insert(models,hero);bind(id,hero)
end
local params=RaycastParams.new()
params.FilterType=Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances=models
params.RespectCanCollide=true
local began=workspace:GetServerTimeNow()
local result:any={version=1,scope="SYNTHETIC_PARTY_WALK_OBSERVATION_NOT_EARNED",status="CAPTURING",startedAt=began,
 durationLimit=1200,sampleLimit=6001,interval=.2,ownerUserId=owner.UserId,threeRoadWalk=lab:GetAttribute("ThreeRoadWalk")==true,
 roster={},events={},samples={}}
for _,actor in ipairs(roster)do table.insert(result.roster,{id=actor.id,name=actor.model.Name,class=actor.model:GetAttribute("ClassId")})end
local connections:{RBXScriptConnection}={}
local closed=false
local function finish(reason:string)
 if closed then return end
 closed=true;result.status=reason;result.endedAt=workspace:GetServerTimeNow()
 table.insert(result.events,{t=result.endedAt,kind=reason})
 for _,connection in ipairs(connections)do connection:Disconnect()end
 table.clear(connections);
 (_G :: any).GuildborneWalkStop=nil
end
local function vector(v:Vector3):{number}return {v.X,v.Y,v.Z}end
local function sample(now:number)
 if owner.Parent~=Players or owner.Character~=character or #Players:GetPlayers()~=1 then finish("PLAYER_IDENTITY_CHANGED");return end
 if not lab:IsDescendantOf(workspace) or lab:GetAttribute("Ready")~=true or lab:GetAttribute("OwnerUserId")~=owner.UserId or lab:GetAttribute("Synthetic")~=true then finish("LAB_NOT_READY");return end
 if workspace:FindFirstChild("GuildborneWorld")~=world or plot.Parent~=world or world:FindFirstChild("PersonalGuild")~=plot
  or plot:GetAttribute("OwnerUserId")~=owner.UserId or plot:FindFirstChild("Heroes")~=heroFolder or heroFolder.Parent~=plot then finish("PARTY_CONTAINER_CHANGED");return end
 if #heroFolder:GetChildren()~=5 then finish("PARTY_ROSTER_CHANGED");return end
 local row:any={t=now,zone=owner:GetAttribute("CurrentZone"),walking=character:GetAttribute("WalkingRouteContext"),
  respawn=if owner.RespawnLocation then owner.RespawnLocation:GetFullName()else nil,actors={}}
 local downed=false
 for _,actor in ipairs(roster)do
  local model,root,humanoid=actor.model,actor.root,actor.humanoid
  if not model:IsDescendantOf(workspace) or model:FindFirstChild("HumanoidRootPart")~=root or model:FindFirstChildOfClass("Humanoid")~=humanoid or model:GetAttribute("ClassId")~=actor.class
   or (actor.id~="player" and (model.Parent~=heroFolder or model:GetAttribute("AdventurerId")~=actor.id or model:GetAttribute("OwnerUserId")~=owner.UserId or model:GetAttribute("GuildborneHero")~=true))then
   table.insert(result.events,{t=now,kind="ACTOR_IDENTITY_CHANGED",actor=actor.id});finish("IDENTITY_CHANGED");return
  end
  local position=root.Position
  local hit=workspace:Raycast(position+Vector3.new(0,3,0),Vector3.new(0,-35,0),params)
  local health=model:GetAttribute("CombatHealth")
  local data:any={p=vector(position),v=vector(root.AssemblyLinearVelocity),anchored=root.Anchored,
   humanoidHealth=humanoid.Health,combatHealth=health,heroState=model:GetAttribute("HeroState"),combatState=model:GetAttribute("CombatState"),recoveryCount=model:GetAttribute("RecoveryCount"),
   ground={hit=hit~=nil}}
  if hit then data.ground={hit=true,distance=position.Y-hit.Position.Y,position=vector(hit.Position),normal=vector(hit.Normal),part=hit.Instance:GetFullName()}end
  row.actors[actor.id]=data
  if humanoid.Health<=0 or (type(health)=="number" and health<=0)then
   table.insert(result.events,{t=now,kind=if humanoid.Health<=0 then "HUMANOID_DEAD"else "COMBAT_DOWNED",actor=actor.id});downed=true
  end
 end
 table.insert(result.samples,row)
 if downed then finish("ACTOR_DOWNED")elseif #result.samples>=result.sampleLimit then finish("SAMPLE_CAP")end
end
(_G :: any).GuildborneWalkCapture=result;
(_G :: any).GuildborneWalkStop=function()finish("MANUAL_STOP");return {status=result.status,samples=#result.samples}end
local last=began
local function tick()
 if closed then return end
 local now=workspace:GetServerTimeNow()
 if now-began>=result.durationLimit then finish("DURATION_LIMIT");return end
 if now-last>=result.interval then last=now;sample(now)end
end
local initialOk,initialProblem=pcall(sample,began)
if not initialOk then result.error=tostring(initialProblem);finish("OBSERVER_ERROR")end
if not closed then
 table.insert(connections,Run.Heartbeat:Connect(function()
  local ok,problem=pcall(tick)
  if not ok then result.error=tostring(problem);finish("OBSERVER_ERROR")end
 end))
 table.insert(connections,owner.CharacterRemoving:Connect(function()finish("PLAYER_CHARACTER_REMOVED")end))
 table.insert(connections,Players.PlayerRemoving:Connect(function(player)if player==owner then finish("OWNER_LEFT")end end))
 table.insert(connections,lab.Destroying:Connect(function()finish("LAB_DESTROYED")end))
end
return {status=result.status,startedAt=began,actors=#roster,sampleLimit=result.sampleLimit,durationLimit=result.durationLimit}
