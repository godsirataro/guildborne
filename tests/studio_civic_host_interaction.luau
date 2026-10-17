--!strict
-- Server-side controller fixture. Exercise REAL client prompt input between Prepare and Verify.
-- No FireSignal/getconnections or copied production callback. Not multiplayer acceptance.
return function(player:Player):any
 assert(game:GetService("RunService"):IsStudio(),"Studio only")
 assert(game.PlaceId==0 and game.GameId==0,"isolated unpublished candidate only")
 local Shared=game.ReplicatedStorage.Shared
 local cities=require(Shared.Config.CivicCities)
 local motion=require(Shared.Presentation.BorinWorkMotion)
 local character=assert(player.Character,"character required")
 local playerRoot=assert(character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local savedPivot=character:GetPivot();local savedAnchored=playerRoot.Anchored
 local fixture=Instance.new("Model");fixture.Name="CivicHostPromptFixture";fixture.Parent=workspace
 local town=Instance.new("Folder");town.Name="FixtureTown";town.Parent=fixture
 local opened:{any}={};local observed:{any}={};local connections:{RBXScriptConnection}={}
 local hosts:{any}={};local active:any=nil;local index=0;local passed=0;local destroyed=false
 local function destroy()
  if destroyed then return end;destroyed=true
  for _,connection in ipairs(connections)do connection:Disconnect()end
  fixture:Destroy()
  if player.Character==character and playerRoot.Parent then
   character:PivotTo(savedPivot);playerRoot.Anchored=savedAnchored
  end
 end
 local ok,problem=pcall(function()
  require(game.ServerScriptService.Server.Services.CivicCityWorld)(fixture,town,function()error("fixture must not travel")end,function(who:Player,panel:string)
   table.insert(opened,{player=who,panel=panel})
  end)
  -- Separate disposable geometry from the live world's same-coordinate city districts.
  fixture:PivotTo(fixture:GetPivot()+Vector3.new(50000,0,0))
  for _,cityId in ipairs(cities.Order)do
   local id="host_"..string.lower(cityId)
   local model=assert(fixture:FindFirstChild(id,true)) :: Model
   local root=assert(model.PrimaryPart)
   local prompt=assert(root:FindFirstChildOfClass("ProximityPrompt"))
   assert(model:GetAttribute("NpcId")==id and model:GetAttribute("CivicHost")==cityId)
   table.insert(hosts,{id=id,model=model,root=root,prompt=prompt,pivot=model:GetPivot(),motion=model:GetAttribute("WorkMotionIdentity")})
   table.insert(connections,prompt.Triggered:Connect(function(who)
    table.insert(observed,{player=who,prompt=prompt})
   end))
   prompt.Enabled=false
  end
 end)
 if not ok then destroy();error(problem)end
 local S={}
 function S.Prepare():any
  assert(not destroyed and not active,"verify current case before preparing next")
  assert(player.Character==character and playerRoot.Parent,"fixture character changed")
  index+=1
  if index>#hosts*2 then return {complete=true,passed=passed,expected=#hosts*2}end
  local host=hosts[math.ceil(index/2)];local near=index%2==1
  for _,item in ipairs(hosts)do item.prompt.Enabled=false end
  -- Enlarged fixture-only engine radius lets genuine input reach the application's 14-stud rejection guard.
  host.prompt.MaxActivationDistance=40;host.prompt.Enabled=true
  playerRoot.Anchored=true
  character:PivotTo(CFrame.new(host.root.Position+Vector3.new(if near then 8 else 24,0,0)))
  active={host=host,near=near,opened=#opened,observed=#observed,started=workspace:GetServerTimeNow(),
   greeting=host.model:GetAttribute("GreetingAt"),deadline=host.model:GetAttribute("NpcInteractUntil"),interactor=host.model:GetAttribute("NpcInteractor")}
  return {case=index,npcId=host.id,expect=if near then "ACCEPT" else "REJECT_DISTANCE",key="E",instruction="Focus game and press/release E once, then call Verify; do not write attributes manually."}
 end
 function S.Verify():any
  assert(not destroyed and active,"Prepare required")
  local a=active;local host=a.host
  assert(#observed==a.observed+1,"one real Triggered event required; absent input is not rejection proof")
  assert(observed[#observed].player==player and observed[#observed].prompt==host.prompt,"wrong trigger source")
  assert(host.model:GetPivot()==host.pivot,"host moved")
  assert(host.model:GetAttribute("NpcId")==host.id and host.model:GetAttribute("WorkMotionIdentity")==host.motion,"identity changed")
  if a.near then
   assert(#opened==a.opened+1 and opened[#opened].player==player and opened[#opened].panel=="FriendlyNPC:"..host.id,"actual open callback mismatch")
   local greeting=host.model:GetAttribute("GreetingAt");local deadline=host.model:GetAttribute("NpcInteractUntil")
   assert(type(greeting)=="number" and greeting>=a.started and greeting<=workspace:GetServerTimeNow(),"server greeting clock missing")
   assert(type(deadline)=="number" and deadline-greeting==motion.InteractSeconds,"deadline must share exact greeting clock")
   assert(host.model:GetAttribute("NpcInteractor")==player.UserId,"wrong interactor")
  else
   assert(#opened==a.opened,"distant input opened dialogue")
   assert(host.model:GetAttribute("GreetingAt")==a.greeting and host.model:GetAttribute("NpcInteractUntil")==a.deadline and host.model:GetAttribute("NpcInteractor")==a.interactor,"distant input changed hints")
  end
  host.prompt.Enabled=false;passed+=1;active=nil
  return {status="PASS_ACTUAL_PROMPT_FIXTURE_CASE",case=index,npcId=host.id,accepted=a.near,passed=passed,multiplayerTested=false,questJourneyTested=false}
 end
 S.Destroy=destroy
 return S
end
