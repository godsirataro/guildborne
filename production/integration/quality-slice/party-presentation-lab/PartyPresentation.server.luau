--!strict
-- Disposable synthetic party; no DataService/profile storage or economic grants.
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local Replicated=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
assert(Run:IsServer() and Run:IsStudio() and game.PlaceId==0 and game.GameId==0,"Unsaved Studio only")
local server=game.ServerScriptService:WaitForChild("Server")
assert(server.ServerBootstrap.Disabled,"Normal bootstrap must be disabled")
local runtime=require(server.Config.Runtime)
assert(runtime.StudioPersistence=="Memory" and type(runtime.AllowedDataStoreUniverses)=="table" and next(runtime.AllowedDataStoreUniverses)==nil,"Memory only")
local threeRoadWalk=script:GetAttribute("ThreeRoadWalk")==true
if threeRoadWalk then
 assert(runtime.FullConnectedWorldCandidate==true,"Three-road lab requires full-connected runtime")
 assert(runtime.LaunchCandidate~=true and runtime.SharedCombatCandidate~=true and runtime.ContinuousWorldCandidate~=true,"Mixed launch/shared runtime refused")
 for _,flag in ipairs({"NoviceJourney","IronveilJourney","AshenJourney","TowerJourney","CrosshavenJourney","ArchiveHeartJourney"}) do
  assert(runtime[flag]==true,"Missing full campaign journey: "..flag)
 end
end
assert(not workspace:FindFirstChild("GuildborneWorld") and not workspace:FindFirstChild("PartyPresentationLab"),"Existing world refused")
assert(not Replicated:FindFirstChild("GuildborneRemotes") and not game.ServerStorage:FindFirstChild("GuildborneArtKit"),"Existing runtime refused")
local owner=Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
assert(#Players:GetPlayers()==1,"Exactly one local player")
local character=owner.Character or owner.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid") :: Humanoid
assert(humanoid.Health>0 and owner:GetAttribute("CurrentZone")==nil,"Existing session refused")
for _,name in ipairs({"GuildbornePlayer","CombatHealth","ClassId"}) do assert(character:GetAttribute(name)==nil,"Existing earned character refused") end
-- PlayerScripts is client-only; inspect the server-visible template here.
assert(game.StarterPlayer.StarterPlayerScripts.Client.ClientBootstrap.Disabled,"Normal client bootstrap must be disabled")
assert(#Players:GetPlayers()==1 and owner.Parent==Players and owner.Character==character,"Owner changed during setup")
assert(not workspace:FindFirstChild("GuildborneWorld") and not Replicated:FindFirstChild("GuildborneRemotes"),"Runtime appeared during setup")
-- Every safety guard above precedes fixture mutations.
local folder=Instance.new("Folder");folder.Name="PartyPresentationLab";folder.Parent=workspace
folder:SetAttribute("ThreeRoadWalk",threeRoadWalk);folder:SetAttribute("Synthetic",true);folder:SetAttribute("OwnerUserId",owner.UserId)
local report=Instance.new("StringValue");report.Name="Report";report.Parent=folder
local remotes=Instance.new("Folder");remotes.Name="GuildborneRemotes";remotes.Parent=Replicated
local intent=Instance.new("RemoteEvent");intent.Name="CombatIntent";intent.Parent=remotes
local state=Instance.new("RemoteEvent");state.Name="State";state.Parent=remotes
local ready=Instance.new("RemoteEvent");ready.Name="LabReady";ready.Parent=remotes
local result:any={scope="SYNTHETIC_PARTY_PRESENTATION_NOT_EARNED",status="STARTING",threeRoadWalk=threeRoadWalk,walkingRouteCount=if threeRoadWalk then 3 else 2,commands={},rewardCallbacks=0,profileWrites=0,notifications={}}
local connections:{RBXScriptConnection}={}
local closed=false;local world:any=nil
local function save() report.Value=Http:JSONEncode(result) end
local function connect(signal:RBXScriptSignal,callback:any) table.insert(connections,signal:Connect(callback)) end
local function finish(reason:string)
 if closed then return end;closed=true
 result.status=reason;save();folder:SetAttribute("Ready",false)
 for _,c in ipairs(connections) do c:Disconnect() end
 if world then pcall(world.Remove,owner);pcall(world.DestroyHeroRuntime) end
 remotes:Destroy()
 -- WorldService/TravelService have no complete world teardown. Stop Play required.
end
connect(script.Destroying,function()finish("STOPPED_REQUIRES_STOP_PLAY")end)
connect(owner.CharacterRemoving,function()finish("CHARACTER_REPLACED_RESTART_REQUIRED")end)
connect(humanoid.Died,function()finish("HUMANOID_DIED_RESTART_REQUIRED")end)
connect(Players.PlayerRemoving,function(p)if p==owner then finish("OWNER_LEFT")end end)
connect(Players.PlayerAdded,function()finish("MULTIPLAYER_REFUSED")end)
local ok,problem=xpcall(function()
 local shared=Replicated.Shared;local content=require(server.Config.Content)
 local expansion=require(shared.Data.Expansion);local gear=require(shared.Data.Equipment)(content,expansion)
 local schema=require(server.Systems.ProfileSchema)(content,require(shared.Util.TableUtil),gear,expansion)
 local record=schema.new(owner.UserId,1);local data=record.data
 data.character.classId="Warrior";data.character.level=10;data.character.xp=450
 data.personalGuild.buildings.guildHall=1;data.party.adventurerIds={}
 local classes={"Knight","Warrior","Archer","Mage","Priest"}
 local actors:{[string]:boolean}={player=true}
 for _,class in ipairs(classes) do
  local id="a:"..class;actors[id]=true
  data.adventurers[id]={id=id,classId=class,name="Fixture "..class,level=10,xp=450,condition="Healthy",equipmentSlots={},rank="F"}
  data.progression.recruitedClasses[class]=true;table.insert(data.party.adventurerIds,id)
 end
 local session={state="Active",record=record,epoch=1,token="isolated-party-presentation"}
 local function living():boolean return not closed and owner.Parent==Players and owner.Character==character and humanoid.Health>0 end
 local function reward()result.rewardCallbacks+=1;save()end -- recorded, never granted
 local function travel(p:Player,action:string,args:any)
  if not living() or p~=owner or action~="TravelZone" or type(args)~="table" or type(args.zone)~="string" then return end
  local rejection=world.ValidateIntent(p,action,{zone=args.zone})
  if rejection then return end
  world.IntentCommitted(p,action,{zone=args.zone})
 end
 world=require(server.Services.WorldService).new(function()end,reward,reward,travel,nil,nil,nil,nil,{
  FullConnectedWorld=threeRoadWalk,
  Session=function(p:Player)return if living() and p==owner then session else nil end,
  Gate=function(p:Player,s:any,from:string,to:string):string?
   if not living() or p~=owner or s~=session then return "FixtureIdentityChanged" end
   if not ((from=="City" and to=="Greenwood")or(from=="Greenwood" and to=="City")or(from=="Greenwood" and to=="Ironveil")or(from=="Ironveil" and to=="Greenwood")or(threeRoadWalk and ((from=="Ironveil" and to=="Ashen")or(from=="Ashen" and to=="Ironveil"))))then return "InvalidZone"end
   return nil -- synthetic eligibility, not earned release-gate evidence
  end,
  Notify=function(_p:Player,code:string)if #result.notifications<100 then table.insert(result.notifications,code);save()end end,
 })
 world.Add(owner);task.wait(1);assert(living(),"Owner lost during setup")
 world.Update(owner,1,data,true)
 local start=script:GetAttribute("StartZone") or "Guild"
 assert(start=="Guild" or start=="City","Unsupported initial setup zone")
 world.IntentCommitted(owner,"TravelZone",{zone=start}) -- one setup relocation; no forced attacks
 local actions={Basic=true,Ability=true,Ability1=true,Ability2=true,Ability3=true,Focus=true,Regroup=true,Retreat=true,Hold=true,TacticBalanced=true,TacticDefensive=true}
 local tokens=12;local last=os.clock();local readySent=false
 connect(ready.OnServerEvent,function(p:Player)
  if p~=owner or not living() or readySent then return end;readySent=true
  local names={};for id,h in pairs(data.adventurers)do names[id]={name=h.name}end
  state:FireClient(owner,{data={language="en",adventurers=names}})
 end)
 connect(intent.OnServerEvent,function(p:Player,payload:any)
  if p~=owner or not living() then return end
  local now=os.clock();tokens=math.min(12,tokens+(now-last)*8);last=now
  if tokens<1 then return end;tokens-=1
  if type(payload)~="table" then return end
  local count=0;for key in pairs(payload)do if key~="action" and key~="actorId" then return end;count+=1 end
  if count~=2 or type(payload.action)~="string" or not actions[payload.action] or type(payload.actorId)~="string" or not actors[payload.actorId] then return end
  local accepted,reason=world.PlayerAction(owner,payload.action,payload.actorId)
  if #result.commands<256 then
   table.insert(result.commands,{at=workspace:GetServerTimeNow(),action=payload.action,actorId=payload.actorId,accepted=accepted,reason=reason})
   save()
  end
  intent:FireClient(owner,reason)
 end)
 result.status="READY_SYNTHETIC";result.roster=classes;result.startZone=start;save()
 folder:SetAttribute("Ready",true)
end,debug.traceback)
if not ok then result.error=tostring(problem);finish("FAILED");warn(problem)end
