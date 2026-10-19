--!strict
-- Local launch arena: the selected owned hero's real model, isolated training stats.
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Shared=game.ReplicatedStorage.Shared
local Server=script.Parent.Parent
local Rules=require(Shared.Data.Expansion)
local Content=require(Server.Config.Content)
local Combat=require(Server.Config.Combat)
local Gear=require(Shared.Data.Equipment)(Content,Rules,require(Shared.Data.StatusPoints))
local Stats=require(Server.Systems.CombatStats)(Content,Combat,Gear)
local V=Vector3.new
return function(deps:any):any
 local entries:{[Player]:any}={};local S={}
 local function notify(player:Player,e:any,code:string?)
  if player.Parent~=Players then return end
  if e.run.proof then if deps.Class3Notify then deps.Class3Notify(player,code)end else deps.Notify(player,code)end
 end
 local function finish(player:Player,code:string?,silent:boolean?)
  local e=entries[player];if not e then return end
  entries[player]=nil
  if e.cancel then e.cancel:Disconnect()end
  -- Restore the hero BEFORE deleting its arena parent.
  local restored,restoreError=pcall(deps.World.EndHeroMentor,player)
  if not restored then warn("[Guildborne] Hero mentor restore failed: "..tostring(restoreError))end
  -- Never delete a selected hero if a partial restore left it inside the arena.
  if e.model and e.hero:IsDescendantOf(e.model) then
   local rescued,rescueError=pcall(function()e.hero.Parent=e.heroParent;e.hero:PivotTo(e.heroReturn);local r=e.hero.PrimaryPart;if r then r.Anchored=e.heroAnchored end end)
   if not rescued then warn("[Guildborne] Hero mentor rescue failed: "..tostring(rescueError));code="HeroMentorCleanupFailed"end
  end
  if e.model and not e.hero:IsDescendantOf(e.model) then e.model:Destroy()end
  if player.Character==e.character and e.character.Parent then
   local humanoid=e.character:FindFirstChildOfClass("Humanoid")
   if humanoid and humanoid.Health>0 then e.character:PivotTo(e.returnTo)end
  end
  player:SetAttribute("HeroMentorStatus",code or "Cancelled")
  if not silent then notify(player,e,code)end
 end
 function S.Remove(player:Player)finish(player,nil,true)end
 function S.State(player:Player):any? local e=entries[player];return if e and not e.run.proof then deps.Trial.sessionView(e) else nil end
 function S.Class3State(player:Player):any?
  local e=entries[player];if not e or not e.run.proof then return nil end
  return {actorId=e.run.actorId,pathId=e.run.pathId,status=if e.delivery then "Saving" else "Active",problem=e.deliveryProblem}
 end
 function S.Active(player:Player):boolean return entries[player]~=nil end
 function S.Intent(player:Player,action:string,args:any):string
  if action=="CancelHeroMentor" or action=="CancelClass3Trial"then
   local e=entries[player]
   if not e or (e.run.proof~=nil)~=(action=="CancelClass3Trial")then return "InvalidAction"end
   if entries[player] and entries[player].delivery then return "SavePending"end
   finish(player,"HeroMentorCancelled");return "OK"
  end
  local isClass3=action=="StartClass3Trial"
  if action~="StartHeroMentor" and not isClass3 then return "InvalidAction"end
  if isClass3 and (not deps.Class3Proof or not deps.MakeClass3Receipt)then return "Class3TrialUnavailable"end
  if type(args)~="table" or type(args.actorId)~="string" or type(args.pathId)~="string" then return "InvalidTrial"end
  if entries[player]then return "HeroMentorActive"end
  if deps.AdmissionProblem then local problem=deps.AdmissionProblem(player);if problem then return problem end end
  local session=deps.Data.Sessions[player.UserId]
  if not session or session.state~="Active" or session.busy or session.closing then return "ProfileNotReady"end
  local data=session.record.data;local context=deps.World.CampaignContext(player)
  local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
  local humanoid=character and character:FindFirstChildOfClass("Humanoid")
  if not context or not character or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health<=0 then return "ActorNotReady"end
  if player:GetAttribute("CurrentZone")~="Guild" or (root.Position-context.origin).Magnitude>165 or context.model:GetAttribute("InCombat") then return "ReturnToGuild"end
  local start=if isClass3 then deps.Trial.startClass3 else deps.Trial.start
  local run,problem=start(data,player.UserId,args.actorId,args.pathId,Http:GenerateGUID(false),os.clock());if not run then return problem end
  local acquired,heroModel=pcall(deps.World.BeginHeroMentor,player,args.actorId)
  if not acquired then deps.World.EndHeroMentor(player);return "HeroMentorUnavailable"end
  if not heroModel then return "HeroUnavailable"end
  local e:any={run=run,startFence={session=session,epoch=session.epoch,token=session.token},epoch=session.epoch,token=session.token,character=character,returnTo=character:GetPivot(),origin=context.origin+V(0,50,0),hero=heroModel,heroParent=heroModel.Parent,heroReturn=heroModel:GetPivot(),heroAnchored=true,nextDelivery=0}
  entries[player]=e
  e.guard=function():boolean
   local current=deps.Data.Sessions[player.UserId]
   local hum=e.character:FindFirstChildOfClass("Humanoid");local r=e.character:FindFirstChild("HumanoidRootPart")
   return entries[player]==e and current==e.startFence.session and current.epoch==e.epoch and current.token==e.token
    and not current.closing and current.state~="LeaseLost" and player.Character==e.character and e.character.Parent~=nil
    and hum~=nil and hum.Health>0 and r~=nil and r:IsA("BasePart") and (r.Position-e.origin).Magnitude<=40
    and e.hero.Parent~=nil and player:GetAttribute("CurrentZone")=="Guild"
  end
  local ok=pcall(function()
   local model=Instance.new("Model");e.model=model;model.Name="HeroMentor_"..player.UserId;model:SetAttribute("ActorId",run.actorId);model:SetAttribute("PathId",run.pathId);model.Parent=workspace
   local function part(name:string,size:Vector3,pos:Vector3,color:Color3):Part
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=e.origin+pos;p.Color=color;p.Anchored=true;p.Parent=model;return p
   end
   local floor=part("TrainingDeck",V(48,1,48),V(0,-.5,0),Color3.fromRGB(66,75,81))
   e.enemy=part("MentorConstruct",V(3,5,3),V(0,2.5,0),Color3.fromRGB(153,119,74))
   e.patient=part("PracticePatient",V(2,3,2),V(0,1.5,6),Color3.fromRGB(89,148,119))
   local board=Instance.new("BillboardGui");board.Size=UDim2.fromOffset(400,90);board.StudsOffset=V(0,9,0);board.AlwaysOnTop=true;board.Parent=floor
   local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.TextSize=17;label.TextWrapped=true;label.BackgroundTransparency=.2;label.TextColor3=Color3.new(1,1,1);label.Parent=board;e.label=label
   local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Cancel training / ยกเลิกฝึก";prompt.MaxActivationDistance=30;prompt.RequiresLineOfSight=false;prompt.Parent=floor
   e.cancel=prompt.Triggered:Connect(function(who)if who==player then local code=S.Intent(player,if e.run.proof then "CancelClass3Trial" else "CancelHeroMentor",{});if code~="OK"then notify(player,e,code)end end end)
   heroModel.Parent=model;heroModel:PivotTo(CFrame.new(e.origin+V(0,3,4)))
   character:PivotTo(CFrame.new(e.origin+V(12,3,12)));root.AssemblyLinearVelocity=V(0,0,0)
   local loadout=Gear.loadout(data,run.hero)
   local stats=Stats.hero(run.hero.classId,run.hero.level,loadout.weapon,loadout.armor,loadout.accessory,Gear.extras(data,run.hero));assert(stats)
   e.combat=deps.Trial.combat(run,{stats=stats,config=Combat,Stats=Stats,Targeting=require(Server.Systems.CombatTargeting),Damage=require(Server.Systems.CombatDamage),Abilities=require(Server.Systems.CombatAbilities),emit=function(name:string,a:any,b:any,value:any)
    if a.id==run.actorId and (name=="hero_basic_attack" or name=="hero_ability_used")then
     local ability=Rules.Abilities[value]
     heroModel:SetAttribute("ActionAt",workspace:GetServerTimeNow());heroModel:SetAttribute("ActionAbilityId",if ability then value else nil)
     heroModel:SetAttribute("ActionEffect",if ability then ability.Effect else "Basic");heroModel:SetAttribute("ActionTargetPosition",e.origin+V(b.position.x,3,b.position.z))
     heroModel:SetAttribute("CombatState","Attack")
    end
   end})
   player:SetAttribute("HeroMentorStatus","Training")
  end)
  if not ok then finish(player,"HeroMentorUnavailable");return "HeroMentorUnavailable"end
  if isClass3 then notify(player,e,"Class3Active")end
  return "OK"
 end
 local elapsed=0
 RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.1 then return end;local step=math.min(elapsed,.25);elapsed=0
  for player,e in pairs(entries)do
   if e.busy then continue end
   local session=deps.Data.Sessions[player.UserId];local root=e.character:FindFirstChild("HumanoidRootPart");local hum=e.character:FindFirstChildOfClass("Humanoid")
   if not session or (e.run.proof and not e.guard()) or session.epoch~=e.epoch or session.token~=e.token or session.closing or session.state=="LeaseLost" or player.Character~=e.character or not root or not root:IsA("BasePart") or not hum or hum.Health<=0 or (root.Position-e.origin).Magnitude>40 or not e.hero.Parent then finish(player,"HeroMentorCancelled",session~=e.startFence.session or (session~=nil and (session.epoch~=e.epoch or session.token~=e.token)));continue end
   if not e.delivery and not deps.Trial.matches(session.record.data,e.run)then finish(player,"HeroChanged");continue end
   if not e.delivery then
    local position=e.hero:GetPivot().Position-e.origin
    local desired=V(0,3,math.min(4,e.combat.actor.stats.AttackRange))
    local delta=desired-position;local moved=position+(if delta.Magnitude>0 then delta.Unit*math.min(delta.Magnitude,step*12)else V(0,0,0))
    e.hero:PivotTo(CFrame.lookAt(e.origin+moved,e.origin+V(0,moved.Y,0)))
    local state=e.combat.step(os.clock(),{x=moved.X,y=0,z=moved.Z})
    local snap=e.combat.snapshot();e.hero:SetAttribute("CombatHealth",snap.heroHealth);e.hero:SetAttribute("CombatMaxHealth",e.combat.actor.stats.MaxHealth);e.enemy:SetAttribute("CombatHealth",snap.enemyHealth);e.patient:SetAttribute("CombatHealth",e.combat.patient.health);e.model:SetAttribute("Status",state);e.model:SetAttribute("HeroHealth",snap.heroHealth);e.model:SetAttribute("EnemyHealth",snap.enemyHealth);e.model:SetAttribute("ArtEffectProven",snap.effect)
    e.label.Text="Hero mentor / ฝึกฮีโร่ · "..e.run.hero.name.."\nHP "..math.ceil(snap.heroHealth).." · Construct "..snap.enemyHealth.." · "..state.."\nSkills → Cancel / ยกเลิก"
    if state=="Failed"then finish(player,"HeroMentorFailed");continue end
    if state=="Won"then
     local receipt=deps.Trial.receipt(e.run);if not receipt then finish(player,"HeroMentorFailed");continue end
     if e.run.proof then
      e.delivery=deps.MakeClass3Receipt(player.UserId,receipt,e.startFence,function()return e.guard() and deps.Trial.class3ActivityProblem(session.record.data,e.run.actorId)==nil end)
     else e.delivery=deps.MakeReceipt(player.UserId,receipt,e.epoch,e.token)end;e.model:SetAttribute("Status","Saving");e.label.Text="Saving hero trial / กำลังบันทึกผลฝึก";notify(player,e,if e.run.proof then "Class3Saving" else "HeroMentorSaving")end
   end
   if e.delivery and os.clock()>=e.nextDelivery then
    e.nextDelivery=os.clock()+.5;e.busy=true
    task.spawn(function()
     local ok,outcome,reason=pcall(e.delivery);e.busy=false
     -- A yield may outlive cancel, replacement session, respawn or a new trial.
     local current=deps.Data.Sessions[player.UserId]
     if entries[player]~=e then return end
     if not current or current~=e.startFence.session or current.epoch~=e.epoch or current.token~=e.token or player.Character~=e.character then finish(player,"HeroMentorCancelled",true);return end
     if e.run.proof and not e.guard()then finish(player,"ActorNotReady");return end
     if ok and outcome=="Committed"then finish(player,"HeroMentorComplete")elseif ok and outcome=="Rejected"then finish(player,if type(reason)=="string"then reason else "HeroChanged")
     else
      local problem=if ok and type(reason)=="string"then reason else "CommitUnavailable"
      if e.deliveryProblem~=problem then e.deliveryProblem=problem;notify(player,e,problem)end
     end
    end)
   end
  end
 end)
 return S
end
