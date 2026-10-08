--!strict
-- Native arena adapter. The caller supplies eligible profile data and completion
-- delivery; this module never grants XP/classes or writes a player profile.
local Players=game:GetService("Players");local RunService=game:GetService("RunService")
local Shared=game.ReplicatedStorage.Shared;local Server=script.Parent.Parent
local Util=require(Shared.Util.TableUtil);local Content=require(Server.Config.Content);local Combat=require(Server.Config.Combat)
local Locale=require(Shared.Config.Localization)
local TrialConfig=require(Server.Config.NoviceTrials);local Trials=require(Server.Systems.NoviceTrialSession)(TrialConfig,Util)
local Gear=require(Shared.Data.Equipment)(Content,require(Shared.Data.Expansion),require(Shared.Data.StatusPoints))
local create=require(Server.Systems.NoviceTrialCombat)({Util=Util,Content=Content,Combat=Combat,Trials=Trials,
 Stats=require(Server.Systems.CombatStats)(Content,Combat,Gear),Targeting=require(Server.Systems.CombatTargeting),Damage=require(Server.Systems.CombatDamage),Abilities=require(Server.Systems.CombatAbilities)})
local V=Vector3.new
return function(player:Player,data:any,classId:string,runId:string,origin:Vector3,onComplete:any,onExit:any?,options:any?):any
 local make=if options then options.Create else create
 local goalsConfig=if options then options.Goals else TrialConfig.Classes[classId].Goals
 local abilityId=if options and options.AbilityId then options.AbilityId else Combat.Classes[classId].Ability
 local trialAbility=assert((options and options.Ability)or Combat.Abilities[abilityId],"Missing trial ability")
 local sim,problem=make(data,player.UserId,classId,runId,os.clock());assert(sim,problem)
 local character=assert(player.Character);local humanoid=assert(character:FindFirstChildOfClass("Humanoid"))
 local root=assert(character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local returnTo=character:GetPivot();local disposed=false;local delivered=false;local connections:{RBXScriptConnection}={}
 local pendingReceipt:any=nil;local delivering=false;local nextDelivery=0
 local started=false
 local inputHint:string?=nil;local hintUntil=0
 local language=(data.settings and data.settings.language)or "en"
 local function T(value:string):string return Locale.translate(language,value)end
 local enemyName=if options and options.EnemyName then options.EnemyName else "Sentinel"
 local goalNames={basic_hit={"Basic hits","โจมตีพื้นฐาน"},ranged_hit={"Long-range hits","โจมตีระยะไกล"},ability_hit={"Skill hits","โจมตีด้วยสกิล"},skill_used={"Skills used","ใช้สกิลสำเร็จ"},heal={"HP restored","ฟื้นฟู HP"},taunt={"Taunts","ยั่วยุศัตรู"},dodge={"Warnings dodged","หลบพื้นที่เตือน"},victory={"Sentinel defeated","ปราบหุ่นฝึก"}}
 local problemNames={TrialExpired="Time is up. Try again.",SoloTrialRequired="Complete this trial alone.",TrialDefeated="Try again when you are ready.",TrialLeftArena="You left the trial arena.",TrialLessonsIncomplete="Complete the lessons before defeating the sentinel.",TrialEventLimit="Restart this trial.",TrialCancelled="Trial ended."}
 local model=Instance.new("Model");model.Name="NoviceTrial_"..player.UserId;model:SetAttribute("OwnerUserId",player.UserId);model:SetAttribute("ClassId",classId);model.Parent=workspace
 local function part(name:string,p:Vector3,size:Vector3,color:Color3,solid:boolean):Part
  local v=Instance.new("Part");v.Name=name;v.Position=origin+p;v.Size=size;v.Color=color;v.Anchored=true;v.CanCollide=solid;v.CanQuery=solid;v.CanTouch=false;v.TopSurface=Enum.SurfaceType.Smooth;v.BottomSurface=Enum.SurfaceType.Smooth;v.Parent=model;return v
 end
 require(script.Parent.NoviceTrialArt)(model,origin,classId)
 local sentinel=assert(model:FindFirstChild("TrialSentinel")) :: BasePart
 local enemyVisual:Model?=nil;local previousWarning:any=nil;local previousHP=sim.snapshot().enemyHealth
 if options and options.EnemyVisual then
  for _,p in ipairs(model:GetChildren())do if p:IsA("BasePart")and p:GetAttribute("TrialArtGroup")=="Sentinel"then p.Transparency=1 end end
  local folder=require(script.Parent.NoviceCharacterKit)(true,options.EnemyVisual)
  local actor=assert(folder:FindFirstChild(options.EnemyVisual)) :: Model;enemyVisual=actor
  actor:PivotTo(CFrame.new(origin)*CFrame.Angles(0,math.pi,0));actor:SetAttribute("GuildborneEnemy",true);actor:SetAttribute("OwnerUserId",player.UserId)
  actor:SetAttribute("EnemyAnimationClass","Warrior");actor:SetAttribute("CombatState","Idle");actor:SetAttribute("CombatHealth",previousHP)
  actor.Parent=model;folder:Destroy();game:GetService("CollectionService"):AddTag(actor,"GuildborneAnimatedEnemy")
 end
 local warn=part("CommittedWarning",V(0,.1,0),V(.12,12,12),Color3.fromRGB(247,106,56),false)
 warn.Shape=Enum.PartType.Cylinder;warn.Material=Enum.Material.Neon;warn.Transparency=1
 model:SetAttribute("NoviceTrialArena",true)
 local input=Instance.new("RemoteEvent");input.Name="TrialInput";input.Parent=model
 local acceptInput=require(Server.Systems.NoviceTrialInput)(player.UserId)
 model:SetAttribute("BasicLabel",T("Basic Attack"));model:SetAttribute("AbilityLabel",T(trialAbility.Name))
 model:SetAttribute("ReturnLabel",T("Leave trial"))
 local api:any={model=model}
 local function sample(at:number):string?
  if disposed then return "TrialCancelled" end
  if player.Parent~=Players or player.Character~=character or not root.Parent then sim.cancel();return "TrialCancelled" end
  local alone=true
  for _,other in ipairs(Players:GetPlayers())do
   local c=other.Character;local r=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
   if other~=player and r and (r.Position-origin).Magnitude<=45 then alone=false end
  end
  local pos=root.Position-origin
  return sim.step(at,{x=pos.X,y=pos.Y-3,z=pos.Z},alone,humanoid.Health>0)
 end
 local function update()
  local s=sim.snapshot();model:SetAttribute("TrialStatus",s.status);model:SetAttribute("TrialProblem",s.problem)
  if enemyVisual then
   enemyVisual:SetAttribute("CombatHealth",s.enemyHealth)
   if s.enemyHealth<previousHP then enemyVisual:SetAttribute("FeedbackAt",workspace:GetServerTimeNow());previousHP=s.enemyHealth end
   if s.warning and s.warning.startsAt~=previousWarning then previousWarning=s.warning.startsAt;enemyVisual:SetAttribute("TelegraphAt",workspace:GetServerTimeNow());enemyVisual:SetAttribute("TelegraphDuration",math.max(0,s.warning.impactAt-os.clock()))
   elseif not s.warning and previousWarning then previousWarning=nil;enemyVisual:SetAttribute("BossImpactAt",workspace:GetServerTimeNow())end
  end
  model:SetAttribute("PlayerHealth",s.playerHealth);model:SetAttribute("EnemyHealth",s.enemyHealth)
  model:SetAttribute("WarningToken",if s.warning then s.warning.startsAt else nil)
  local goals={};for kind,needed in pairs(goalsConfig)do local label=if kind=="victory"and options and options.Lesson then T("Defeat the opponent")else goalNames[kind][if language=="th"then 2 else 1];table.insert(goals,label.." "..tostring(s.progress[kind]or 0).."/"..needed)end;table.sort(goals)
  model:SetAttribute("DisplayTitle",T(classId).." · "..T(if not started then "Ready"elseif s.status=="Won"then (if options and options.Lesson then "Lesson complete"else "Trial complete")elseif s.status=="Failed"then "Try again"else "Training"))
  model:SetAttribute("DisplayHealth","HP "..s.playerHealth.."/"..s.playerMaxHealth.." · "..T(enemyName).." "..s.enemyHealth.."/"..s.enemyMaxHealth)
  model:SetAttribute("DisplayGoals",table.concat(goals," · "))
  model:SetAttribute("DisplayHint",if s.status=="Won"then T(if delivered then (if options and options.Lesson then "Leave training to continue your journey."else "Leave the trial to confirm your class.")else "Saving trial result...")elseif s.problem then T(problemNames[s.problem]or "Trial ended.")else T("Use F/Q or the buttons. Dodge orange warnings."))
  if s.status=="Active"and inputHint and os.clock()<hintUntil then model:SetAttribute("DisplayHint",T(inputHint))end
  model:SetAttribute("NextBasicAt",if s.nextAttack>os.clock()then workspace:GetServerTimeNow()+s.nextAttack-os.clock()else 0)
  model:SetAttribute("NextAbilityAt",if s.nextAbility>os.clock()then workspace:GetServerTimeNow()+s.nextAbility-os.clock()else 0)
  if s.warning and s.status=="Active"then warn.CFrame=CFrame.new(origin+V(s.warning.x,.1,s.warning.z))*CFrame.Angles(0,0,math.pi/2);warn.Transparency=.35 else warn.Transparency=1 end
  sentinel.Color=if s.enemyHealth==0 then Color3.fromRGB(90,90,90)else Color3.fromRGB(69,90,108)
  if s.status=="Won" and not delivered and not delivering and os.clock()>=nextDelivery then
   pendingReceipt=pendingReceipt or sim.receipt(os.clock())
   if pendingReceipt then
    delivering=true;nextDelivery=os.clock()+.5
    local ok,accepted=pcall(onComplete,Util.copy(pendingReceipt),s)
    delivered=ok and accepted==true;delivering=false
    if not disposed then model:SetAttribute("ReceiptDelivered",delivered)end
   end
  end
 end
 table.insert(connections,input.OnServerEvent:Connect(function(who,action,...)
   if disposed or who~=player then return end
   local at=os.clock()
   if not acceptInput(who.UserId,action,at,select("#",...))then return end
   if action=="Return"then
    if sim.snapshot().status=="Won"and not delivered then return end
    if onExit then onExit()else api.Destroy()end
    return
   end
   if not started then local fresh,reason=make(data,player.UserId,classId,runId,at);if not fresh then model:SetAttribute("TrialProblem",reason);return end;sim=fresh;started=true end
   if sample(at)then return end
   local accepted,reason=sim.input(action,at)
   local hints={OutOfRange="Move closer to your target.",Cooldown="Your skill is recharging.",NoDeficit="The practice patient has enough health."}
   inputHint=if accepted then nil else hints[reason];hintUntil=at+1.4
   if accepted then
    local ability=trialAbility
    model:SetAttribute("ActionEffect",if action=="Basic"then "Basic"else ability.Effect)
    model:SetAttribute("ActionAbilityId",if action=="Basic"then nil else ability.Id)
    model:SetAttribute("ActionOriginPosition",root.Position)
    model:SetAttribute("ActionTargetPosition",origin+V(0,3,if action=="Ability"and ability.TargetType=="Ally"then -10 else 0))
    model:SetAttribute("ActionAt",workspace:GetServerTimeNow())
   end
   update()
  end))
 local z=if classId=="Warrior"or classId=="Knight"then 4 elseif classId=="Archer"then 16 else 12
 character:PivotTo(CFrame.new(origin+V(0,3,z)));root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 local elapsed=0
 table.insert(connections,RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.1 or disposed then return end;elapsed=0;if started then sample(os.clock())end;update()
 end))
 function api.Snapshot():any return sim.snapshot()end
 function api.Destroy()
  if disposed then return end;disposed=true;sim.cancel();for _,c in ipairs(connections)do c:Disconnect()end
  model:Destroy();if player.Character==character and root.Parent and humanoid.Health>0 then character:PivotTo(returnTo);root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero end
 end
 update();return api
end

