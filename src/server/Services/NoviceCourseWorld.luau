--!strict
-- Optional Chapter 00 course: server observations and measured combat lessons.
local Players=game:GetService("Players");local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Art=require(script.Parent.NoviceRoadArt)
local Arena=require(script.Parent.NoviceTrialArena)
local LessonFactory=require(script.Parent.NoviceLessonFactory)
local Lessons=require(script.Parent.Parent.Config.NoviceLessons)
local V=Vector3.new
return function(deps:any)
 local entries:{[Player]:any}={};local occupied:{[number]:boolean}={};local S={}
 local manager=require(script.Parent.NoviceTrialManager)({Data=deps.Data,MaxArenas=8,Now=os.clock,
  NewRunId=function()return Http:GenerateGUID(false)end,CreateArena=Arena,MakeReceipt=deps.MakeReceipt,Notify=deps.Notify,
  Origin=function(slot:number)return V(-4500-(slot-1)*400,25,850)end,
  Trials=require(script.Parent.Parent.Systems.NoviceTrialSession)(require(script.Parent.Parent.Config.NoviceTrials),require(game.ReplicatedStorage.Shared.Util.TableUtil))})
 local function profile(player:Player):any
  local s=deps.Data.Sessions[player.UserId]
  if not s or not s.record or s.closing then return nil end
  local data=s.record.data
  if not data.progression.novice or data.progression.novice.claimed>=6 then return nil end
  return s
 end
 local function nextObjective(data:any):string?
  local chapter=deps.Chapter.Chapters[data.progression.novice.claimed+1]
  if chapter then for _,id in ipairs(chapter.Objectives)do if not data.progression.novice.objectives[id]then return id end end end
  return nil
 end
 local function observe(player:Player,e:any,id:string,branch:string?)
  local s=profile(player)
  if not s or s.state~="Active"or e.pending or nextObjective(s.record.data)~=id then return end
  e.pending=deps.MakeReceipt(player.UserId,{owner=player.UserId,requestId="course:"..Http:GenerateGUID(false),action="NoviceObjective",args={objective=id,branch=branch}})
 end
 local function root(player:Player):BasePart?
  local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local r=c and c:FindFirstChild("HumanoidRootPart")
  return if h and h.Health>0 and r and r:IsA("BasePart")then r else nil
 end
 function S.Add(player:Player)
  if entries[player]or not profile(player)then return end
  local slot=1;while occupied[slot]do slot+=1 end
  if slot>8 then return end
  occupied[slot]=true
  local origin=V(-4500-(slot-1)*400,0,0);local model=Art();model.Name="NoviceCourse_"..player.UserId
  model:SetAttribute("OwnerUserId",player.UserId);model:PivotTo(CFrame.new(origin));model.Parent=workspace
  for _,v in ipairs(model:GetDescendants())do if v:IsA("BillboardGui")then v:Destroy()end end
  local markers={};for _,p in ipairs(model:GetChildren())do if p:IsA("BasePart")and p:GetAttribute("RouteDestination")then markers[p.Name]=p end end
  local walk=Instance.new("Part");walk.Name="CourierPathMarker";walk.Size=V(5,.12,5);walk.Position=origin+V(0,.12,153);walk.Color=Color3.fromRGB(205,164,73);walk.Anchored=true;walk.CanCollide=false;walk.CanQuery=false;walk.CanTouch=false;walk.Parent=model
  local warning=Instance.new("Part");warning.Name="PracticeWarning";warning.Shape=Enum.PartType.Cylinder;warning.Size=V(.12,12,12);warning.Material=Enum.Material.Neon;warning.Color=Color3.fromRGB(247,106,56);warning.Anchored=true;warning.CanCollide=false;warning.CanQuery=false;warning.CanTouch=false;warning.Transparency=1;warning.Parent=model
  local anchor=markers.CourierCamp
  local courier=Instance.new("Part");courier.Name="Courier";courier.Size=V(2,4,1);courier.Position=anchor.Position+V(0,0,-4);courier.Color=Color3.fromRGB(36,52,73);courier.Anchored=true;courier.CanCollide=false;courier.CanQuery=false;courier.CanTouch=false;courier.Parent=model
  courier.Transparency=1
  local function cast(id:string,pos:Vector3):Model
   local folder=require(script.Parent.NoviceCharacterKit)(true,id)
   local actor=assert(folder:FindFirstChild(id)) :: Model
   actor:SetAttribute("OwnerUserId",player.UserId);actor:SetAttribute("FriendlyNPC",true)
   actor:PivotTo(CFrame.new(pos)*CFrame.Angles(0,math.pi,0));actor.Parent=model;folder:Destroy()
   game:GetService("CollectionService"):AddTag(actor,"GuildborneFriendlyNPC");return actor
  end
  local courierActor=cast("courier",V(courier.Position.X,origin.Y,courier.Position.Z))
  local prompt=Instance.new("ProximityPrompt");prompt.Name="CourierInteraction";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=courier
  local board=Instance.new("BillboardGui");board.Size=UDim2.fromOffset(220,58);board.StudsOffset=V(0,5,0);board.MaxDistance=100;board.AlwaysOnTop=true;board.Parent=courier
  local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.TextWrapped=true;label.Font=Enum.Font.GothamMedium;label.TextSize=15;label.BackgroundColor3=Color3.fromRGB(15,21,35);label.TextColor3=Color3.fromRGB(245,236,216);label.Parent=board
  local e:any={model=model,slot=slot,origin=origin,markers=markers,walk=walk,warning=warning,prompt=prompt,label=label,board=board,courier=courier,nextWarning=0,connections={},actions={},epoch=profile(player).epoch,token=profile(player).token}
  entries[player]=e
  local helperFolder=require(script.Parent.FriendlyNpcKit)(true,"mogra")
  local helper=assert(helperFolder:FindFirstChild("mogra")) :: Model;helper.Name="CaravanHelper";helper:SetAttribute("OwnerUserId",player.UserId)
  helper:PivotTo(CFrame.new(origin+V(-79,0,31))*CFrame.Angles(0,math.pi,0));helper.Parent=model;helperFolder:Destroy();e.helper=helper
  game:GetService("CollectionService"):AddTag(helper,"GuildborneFriendlyNPC")
  local function marker(name:string,pos:Vector3):BasePart
   local p=walk:Clone();p.Name=name;p.Position=origin+pos;p.Size=V(2,.12,2);p.Transparency=.2;p.Parent=model;markers[name]=p;return p
  end
  marker("CaravanTracks",V(-65,.12,53));marker("PracticeCaptive",V(80,3,86));marker("FreedCaptive",V(72,3,-50));marker("FalseCrest",V(86,4,-30))
  local travelers={caravan_choice=cast("dwarf_traveler",origin+V(-87,0,25)),free_captive=cast("elf_traveler",origin+V(72,0,-53))}
  local function lesson(id:string)
   local s=profile(player);local def=Lessons[id]
   if not s or s.state~="Active"or s.busy or e.pending or e.lesson or workspace:FindFirstChild("NoviceTrial_"..player.UserId)then return end
   local options=LessonFactory(id);local classId=def.Class or s.record.data.character.classId
   local runId=Http:GenerateGUID(false);local check=options.Create(s.record.data,player.UserId,classId,runId,os.clock())
   if not check then return end
   local send:any=nil
   e.lesson=Arena(player,s.record.data,classId,runId,origin+V(0,25,650),function(receipt:any):boolean
    local current=profile(player)
    if entries[player]~=e or not current or current.epoch~=e.epoch or current.token~=e.token then return false end
    send=send or deps.MakeReceipt(player.UserId,receipt)
    local outcome=send()
    if outcome=="Committed"then deps.Notify(player);deps.Data.FlushAudit(player.UserId);return true end
    return false
   end,function()local current=e.lesson;e.lesson=nil;if current then current.Destroy()end end,options)
  end
  local function action(id:string,where:string,kind:string,branch:string?)
   local p=Instance.new("ProximityPrompt");p.Name="Course_"..id..(branch or "");p.KeyboardKeyCode=Enum.KeyCode.E;p.MaxActivationDistance=12;p.RequiresLineOfSight=false;p.Parent=markers[where]
   local a={id=id,where=where,kind=kind,branch=branch,prompt=p};table.insert(e.actions,a)
   table.insert(e.connections,p.Triggered:Connect(function(who)
    local r=root(player);local s=profile(player)
    if who~=player or not r or not s or not p.Enabled or (r.Position-markers[where].Position).Magnitude>12 then return end
    if kind=="Lesson"then lesson(id)
    elseif kind=="Class"then
     local classId=string.sub(id,5)
     if s.record.data.progression.novice.claimed==4 then lesson(id)
     elseif s.record.data.progression.novice.claimed==5 and not s.record.data.character.classId then manager.Start(player,classId)end
    else
     if id=="caravan_choice"or id=="caravan_fallback"then helper:SetAttribute("GreetingAt",workspace:GetServerTimeNow())end
     local traveler=travelers[id];if traveler then traveler:SetAttribute("GreetingAt",workspace:GetServerTimeNow())end
     observe(player,e,id,if kind=="Fallback"then nil else branch)
    end
   end))
  end
  action("practice_attack","TrainingYard","Lesson");action("rescue_dummy","PracticeCaptive","Interact")
  action("caravan_choice","CaravanRescue","Interact","rescue");action("caravan_choice","CaravanSupplies","Interact","supplies")
  action("caravan_fallback","CaravanRescue","Fallback","rescue");action("caravan_fallback","CaravanSupplies","Fallback","supplies")
  action("defeat_keeper","CrossroadsKeeper","Lesson");action("free_captive","FreedCaptive","Interact");action("inspect_false_crest","FalseCrest","Interact")
  for _,classId in ipairs({"Warrior","Knight","Archer","Mage","Priest"})do action("try_"..classId,"Discipline_"..classId,"Class")end
  action("clear_abandoned_hall","HallForecourt","Lesson");action("register_guild","HallInterior","Interact")
  table.insert(e.connections,prompt.Triggered:Connect(function(who)
   local r=root(player);local s=profile(player)
   if who~=player or not r or not s or (r.Position-courier.Position).Magnitude>12 then return end
   local id=nextObjective(s.record.data)
   if id=="meet_courier"or id=="help_courier"then courierActor:SetAttribute("GreetingAt",workspace:GetServerTimeNow());observe(player,e,id)end
  end))
  local function spawn(character:Model)
   task.delay(1,function()
    if entries[player]~=e or player.Character~=character or not root(player)then return end
    character:PivotTo(CFrame.new(origin+V(0,4,214)));(root(player) :: BasePart).AssemblyLinearVelocity=Vector3.zero
   end)
  end
  table.insert(e.connections,player.CharacterAdded:Connect(spawn));if player.Character then spawn(player.Character)end
 end
 function S.Remove(player:Player)
  local e=entries[player];if not e then return end;entries[player]=nil;occupied[e.slot]=nil
  manager.Remove(player);if e.lesson then e.lesson.Destroy();e.lesson=nil end
  for _,c in ipairs(e.connections)do c:Disconnect()end;e.model:Destroy()
 end
 function S.Update(player:Player)
  if profile(player)then S.Add(player)elseif entries[player]then
   if deps.ReturnToGuild then deps.ReturnToGuild(player)end;S.Remove(player)
  end
 end
 local elapsed=0
 local heartbeat=Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.1 then return end;elapsed=0
  manager.Step()
  for player,e in pairs(entries)do
   local s=profile(player)
   if not s or player.Parent~=Players or s.epoch~=e.epoch or s.token~=e.token then S.Remove(player);continue end
   if e.pending and os.clock()>=(e.nextDelivery or 0)then
    e.nextDelivery=os.clock()+.5
    local status,problem=e.pending();e.model:SetAttribute("DeliveryProblem",problem)
    if status=="Committed"then e.pending=nil;deps.Notify(player);deps.Data.FlushAudit(player.UserId)
    elseif status=="Rejected"then e.pending=nil end
   end
   local data=s.record.data;local id=nextObjective(data);local language=data.settings.language
   local story=data.progression.novice
   local text=if story.claimed==5 and not data.character.classId then Locale.translate(language,if story.trialClass then "Confirm first class"else "Choose a solo class trial.")elseif id then deps.Chapter.ObjectiveLabels[id][if language=="th"then 2 else 1]else Locale.translate(language,"Claim chapter XP in the Guild menu.")
   e.model:SetAttribute("Objective",id);e.model:SetAttribute("ObjectiveText",text);e.label.Text=text
   e.board.Adornee=if id=="walk_route"or id=="dodge_warning"then e.walk else e.courier
   if id=="dodge_area"then e.board.Adornee=e.markers.TrainingYard elseif id=="follow_tracks"then e.board.Adornee=e.markers.CaravanTracks end
   for _,a in ipairs(e.actions)do
    local active=if a.kind=="Class"then (story.claimed==4 and not story.objectives[a.id])or (story.claimed==5 and not data.character.classId)else id==a.id
    if a.kind=="Fallback"then active=active and story.branch~=a.branch end
    if a.id=="clear_abandoned_hall"and not data.character.classId then active=false end
    a.prompt.Enabled=active and s.state=="Active"and not e.pending and not e.lesson
    a.prompt.ObjectText=Locale.translate(language,"Crown Road")
    a.prompt.ActionText=deps.Chapter.ObjectiveLabels[a.id][if language=="th"then 2 else 1]
    if a.kind=="Class"and story.claimed==5 then a.prompt.ActionText=Locale.translate(language,string.sub(a.id,5)).." · "..Locale.translate(language,"Solo class trial")end
    if a.id=="caravan_choice"then a.prompt.ActionText=Locale.translate(language,if a.branch=="rescue"then "Rescue the travelers"else "Recover the supplies")end
    if active and id==a.id then e.board.Adornee=e.markers[a.where]end
   end
   if story.claimed==5 and not data.character.classId then e.board.Adornee=e.markers.FiveDisciplines end
   e.prompt.ActionText=text;e.prompt.ObjectText=Locale.translate(language,"Courier");e.prompt.Enabled=s.state=="Active"and not e.pending and (id=="meet_courier"or id=="help_courier")
   local r=root(player)
   if s.state~="Active"or e.pending or not r then e.warningAt=nil;e.warning.Transparency=1;continue end
   if id=="walk_route"and (r.Position-(e.walk.Position+V(0,3,0))).Magnitude<=6 then observe(player,e,id)end
   if id=="follow_tracks"and (r.Position-(e.markers.CaravanTracks.Position+V(0,3,0))).Magnitude<=7 then observe(player,e,id)end
   if id=="dodge_warning"or id=="dodge_area"then
    local at=os.clock()
    local center=if id=="dodge_warning"then e.walk.Position+V(0,3,0)else e.markers.TrainingYard.Position
    if not e.warningAt and at>=e.nextWarning and (r.Position-center).Magnitude<=14 then
     e.warningAt=at+1.5;e.warningPosition=r.Position;e.warning.CFrame=CFrame.new(r.Position.X,e.origin.Y+.12,r.Position.Z)*CFrame.Angles(0,0,math.pi/2);e.warning.Transparency=.4
    elseif e.warningAt and at>=e.warningAt then
     local delta=r.Position-e.warningPosition;local distance=V(delta.X,0,delta.Z).Magnitude
     if distance>6 and distance<=20 and math.abs(delta.Y)<8 then observe(player,e,id)end
     e.warningAt=nil;e.warning.Transparency=1;e.nextWarning=at+2
    end
   else e.warningAt=nil;e.warning.Transparency=1 end
  end
 end)
 function S.Destroy()heartbeat:Disconnect();for player in pairs(entries)do S.Remove(player)end end
 return S
end
