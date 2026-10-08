--!strict
-- Optional Chapter02 adapter. Server measurements produce private, retryable receipts.
local Players=game:GetService("Players");local Run=game:GetService("RunService");local Http=game:GetService("HttpService")
local V=Vector3.new
local makeArt=require(script.Parent.IronveilMineArt)
local makeCast=require(script.Parent.IronveilCharacterKit)
local tasks=require(script.Parent.Parent.Config.IronveilTasks)
local makePuzzle=require(script.Parent.Parent.Systems.IronveilPuzzle)
local makeProtection=require(script.Parent.Parent.Systems.IronveilProtection)
local makeEscort=require(script.Parent.EscortActor)
local Expansion=require(game.ReplicatedStorage.Shared.Data.Expansion)
return function(deps:any)
 local S={};local entries:{[Player]:any}={};local occupied={}
 local function session(player:Player):any?
  local s=deps.Data.Sessions[player.UserId];local d=s and s.record and s.record.data
  if not s or s.closing or not d or not d.progression.campaign then return nil end
  local claimed=d.progression.campaign.claimed
  return if claimed>=6 and claimed<12 and d.personalGuild.buildings.guildHall>=2 then s else nil
 end
 local function nextId(data:any):string?
  local state=data.progression.campaign;local def=deps.Config.Chapters[state.claimed+1]
  if def then for _,id in ipairs(def.Objectives)do if not state.objectives[id]then return id end end end;return nil
 end
 local function root(player:Player):BasePart?
  local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local r=c and c:FindFirstChild("HumanoidRootPart")
  return if h and h.Health>0 and c and (c:GetAttribute("CombatHealth")or 1)>0 and r and r:IsA("BasePart")then r else nil
 end
 local function current(player:Player,e:any):any?
  local s=session(player)
  return if entries[player]==e and s and s.epoch==e.epoch and s.token==e.token and s.state=="Active"and not s.busy then s else nil
 end
 local function ready(player:Player,e:any,id:string):boolean
  local s=current(player,e);if not s or e.pending or not root(player)or nextId(s.record.data)~=id then return false end
  local c=deps.Config.Chapters[s.record.data.progression.campaign.claimed+1]
  return s.record.data.character.level>=c.Level and s.record.data.personalGuild.buildings.guildHall>=(c.Hall or 1)
 end
 local function observe(player:Player,e:any,id:string,choice:string?,receipt:any?)
  if not ready(player,e,id)then return end
  e.pending=deps.MakeReceipt(player.UserId,receipt or {owner=player.UserId,requestId="ironveil:"..Http:GenerateGUID(false),action="CampaignObjective",args={objective=id,choice=choice}})
  e.pendingObjective=id
 end
 local function stopActivity(e:any)
  if e.escort then e.escort.Destroy();e.escort=nil end
  if e.protection then e.protection.cancel();e.protection=nil end
  if e.trial then e.trial.Destroy();e.trial=nil end
 end
 function S.Remove(player:Player)
  local e=entries[player];if not e then return end
  entries[player]=nil;occupied[e.slot]=nil;stopActivity(e)
  local r=root(player)
  if r and math.abs(r.Position.Y-e.art.origin.Y)<45 and (Vector2.new(r.Position.X,r.Position.Z)-Vector2.new(500,1400)).Magnitude<165 then deps.World.IntentCommitted(player,"TravelZone",{zone="Ironveil"})end
  for _,c in ipairs(e.connections)do c:Disconnect()end;e.art.model:Destroy()
 end
 function S.Update(player:Player)
  local s=session(player);local old=entries[player]
  if not s then S.Remove(player);return end
  if old then if old.epoch==s.epoch and old.token==s.token then return else S.Remove(player)end end
  local slot=nil;for i=1,8 do if not occupied[i]then slot=i;break end end;if not slot then return end
  occupied[slot]=true
  local art=makeArt(player.UserId,slot);local e:any={slot=slot,art=art,epoch=s.epoch,token=s.token,connections={},markers={},notes={},sets={},puzzles={}}
  entries[player]=e
  local actors=makeCast(true);actors.Parent=art.model;e.actors={}
  local offsets={carrier=V(-69,0,73),miner=V(42,0,70),engineer=V(-67,0,8)}
  for _,actor in ipairs(actors:GetChildren())do if actor:IsA("Model")then
   actor:PivotTo(CFrame.new(art.origin+offsets[actor.Name])*CFrame.Angles(0,math.pi,0));e.actors[actor.Name]=actor
   game:GetService("CollectionService"):AddTag(actor,"GuildborneFriendlyNPC")
  end end
  local worker=e.actors.miner:Clone();worker.Name="guarded_worker";worker:PivotTo(CFrame.new(art.origin+V(-32,0,-46)));worker.Parent=actors;e.actors.guarded_worker=worker
  game:GetService("CollectionService"):AddTag(worker,"GuildborneFriendlyNPC")
  local mentors=require(script.Parent.HeroVisualKit)(true,"mage_03")
  local mentor=assert(mentors:FindFirstChild("mage_03")) :: Model;mentor.Name="class_mentor";mentor:PivotTo(CFrame.new(art.origin+V(55,0,-74))*CFrame.Angles(0,math.pi,0));mentor.Parent=actors;mentors:Destroy()
  game:GetService("CollectionService"):AddTag(mentor,"GuildborneFriendlyNPC")
  local function feedback(en:string,th:string)e.message={en,th};e.messageUntil=os.clock()+2.5 end
  local function marker(name:string,id:string?,position:Vector3,label:any,callback:any,active:any?)
   local p=Instance.new("Part");p.Name=name;p.Size=V(2,.15,2);p.Position=position;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(214,174,78);p.Parent=art.model
   local prompt=Instance.new("ProximityPrompt");prompt.Name="Ironveil_"..name;prompt.MaxActivationDistance=7;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.R;prompt.GamepadKeyCode=Enum.KeyCode.ButtonY;prompt.Enabled=false;prompt.Parent=p
   local board=Instance.new("BillboardGui");board.Size=UDim2.fromOffset(290,100);board.StudsOffset=V(0,4,0);board.MaxDistance=65;board.AlwaysOnTop=true;board.Enabled=false;board.Parent=p
   local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.TextWrapped=true;text.Font=Enum.Font.GothamMedium;text.TextSize=15;text.TextColor3=Color3.fromRGB(244,233,208);text.BackgroundColor3=Color3.fromRGB(22,29,38);text.Parent=board
   table.insert(e.markers,{part=p,prompt=prompt,board=board,text=text,id=id,label=label,active=active,name=name})
   table.insert(e.connections,prompt.Triggered:Connect(function(who)
    local r=root(player);local live=current(player,e)
    if who~=player or not live or not r or e.pending or not prompt.Enabled or (r.Position-p.Position).Magnitude>9 then return end
    if id and not ready(player,e,id)then return end
    if active and not active(live.record.data)then return end
    callback(live.record.data)
   end))
  end
  local function at(scene:string,id:string):Vector3 return assert(art.markers[scene.."/"..id]).Position end
  local function objective(scene:string,point:string,id:string,callback:any?,label:any?)
   marker(id.."_"..point,id,at(scene,point),label or deps.Config.ObjectiveLabels[id],callback or function()observe(player,e,id)end)
  end
  local function note(scene:string,position:Vector3,ids:{string},copy:any)
   local p=Instance.new("Part");p.Name="MineInstructions";p.Size=V(1,1,1);p.Position=art.scenes[scene]:GetPivot().Position+position;p.Anchored=true;p.Transparency=1;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=art.model
   local b=Instance.new("BillboardGui");b.Size=UDim2.fromOffset(320,120);b.MaxDistance=50;b.AlwaysOnTop=true;b.Parent=p
   local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(1,1);l.TextWrapped=true;l.Font=Enum.Font.GothamMedium;l.TextSize=16;l.BackgroundColor3=Color3.fromRGB(22,29,38);l.TextColor3=Color3.fromRGB(244,233,208);l.Parent=b
   table.insert(e.notes,{board=b,label=l,ids=ids,copy=copy})
  end
  local function set(id:string,key:string,total:number)
   local values=e.sets[id]or {};e.sets[id]=values;values[key]=true
   local n=0;for _ in pairs(values)do n+=1 end
   if n>=total then observe(player,e,id)else feedback("Checked "..n.." / "..total,"ตรวจแล้ว "..n.." / "..total)end
  end
  local function sequence(id:string,key:string,order:{string})
   e.puzzles[id]=e.puzzles[id]or makePuzzle(order)
   local ok,code=e.puzzles[id].press(key,os.clock())
   if ok and code=="Complete"then observe(player,e,id)
   elseif code=="TrySequenceAgain"then feedback("Wrong order. Start again.","ลำดับไม่ถูกต้อง เริ่มใหม่ได้")
   elseif ok then feedback("Correct. Continue the sequence.","ถูกต้อง ไปจุดถัดไป")end
  end
  marker("MineEntrance",nil,V(500,2.15,1498),{"Enter Ironveil mine","เข้าเหมืองไอรอนเวล"},function()
   if player:GetAttribute("CurrentZone")~="Ironveil"or e.trial then return end
   local c=player.Character;local r=root(player);if c and r then c:PivotTo(CFrame.new(art.entry));r.AssemblyLinearVelocity=V(0,0,0);deps.World.RefreshCampaignCompanions(player)end
  end)
  marker("MineExit",nil,art.exit.Position,{"Return to Ironveil surface","กลับสู่ทางเข้าไอรอนเวล"},function()stopActivity(e);deps.World.IntentCommitted(player,"TravelZone",{zone="Ironveil"})end)
  for i=1,3 do
   objective("scale_yard","scale_"..i,"inspect_ironveil_scales",function()set("inspect_ironveil_scales",tostring(i),3)end)
   e.markers[#e.markers].active=function()return not (e.sets.inspect_ironveil_scales or {})[tostring(i)]end
  end
  objective("scale_yard","carrier","interview_carrier",function()e.actors.carrier:SetAttribute("GreetingAt",workspace:GetServerTimeNow());observe(player,e,"interview_carrier")end)
  marker("MineReception","enter_ironveil",art.origin+V(0,.15,92),deps.Config.ObjectiveLabels.enter_ironveil,function()observe(player,e,"enter_ironveil")end)
  note("signal_shaft",V(0,11,-16),{"read_mine_signal","choose_safe_shaft"},tasks.Signal.Instruction)
  note("shoring_gallery",V(0,12,-10),{"repair_shoring"},tasks.Repair.Instruction)
  for i,symbol in ipairs(tasks.Signal.Sequence)do
   objective("signal_shaft","signal_"..i,"read_mine_signal",function()sequence("read_mine_signal",symbol,tasks.Signal.Sequence)end,{"Read signal "..tasks.Signal.Symbols[symbol],"อ่านสัญญาณ "..tasks.Signal.Symbols[symbol]})
   objective("signal_shaft","signal_"..i,"choose_safe_shaft",function()
    if symbol==tasks.Signal.SafeShaft then observe(player,e,"choose_safe_shaft")else feedback("This shaft is unsafe. Choose the diamond.","ทางนี้ไม่ปลอดภัย เลือกข้าวหลามตัด")end
   end,{"Choose shaft "..tasks.Signal.Symbols[symbol],"เลือกทาง "..tasks.Signal.Symbols[symbol]})
  end
  objective("signal_shaft","trapped_miner","rescue_miner",function()
   if e.escort and e.escort.Snapshot().status~="Failed"and e.escort.Snapshot().status~="Cancelled"then return end
   if e.escort then e.escort.Destroy()end
   local origin=art.scenes.signal_shaft:GetPivot().Position
   e.escort=makeEscort(e.actors.miner,{origin+V(-13,0,5),origin+V(-7,0,5),origin+V(-7,0,13),origin+V(0,0,13)},{art.scenes.signal_shaft},function():any
    local r=root(player);return {current=current(player,e)~=nil and nextId(s.record.data)=="rescue_miner",alive=r~=nil,position=r and r.Position,npcAlive=true}
   end,function()observe(player,e,"rescue_miner")end)
  end,{"Start / retry miner rescue. Stay nearby.","เริ่ม / ลองช่วยคนงานใหม่ อยู่ใกล้ระหว่างเดิน"})
  for i=1,3 do
   objective("shoring_gallery","support_"..i,"inspect_shoring",function()set("inspect_shoring",tostring(i),3)end)
   e.markers[#e.markers].active=function()return not (e.sets.inspect_shoring or {})[tostring(i)]end
   objective("shoring_gallery","support_"..i,"repair_shoring",function()sequence("repair_shoring","support_"..i,tasks.Repair.Sequence)end,{"Repair support "..i,"ซ่อมค้ำยัน "..i})
  end
  local function protection(scene:string,startPoint:string,id:string)
   objective(scene,startPoint,id,function()
    if e.protection and e.protection.snapshot().status=="Active"then return end
    e.protection=makeProtection(tasks.Protection,os.clock());e.protectionId=id
   end,{"Start / retry safety inspection","เริ่ม / ลองตรวจความปลอดภัยใหม่"})
   e.markers[#e.markers].protectionStatus=true
   for i,lane in ipairs(tasks.Protection.Lanes)do
    objective(scene,(if scene=="shoring_gallery"then "support_"else "mechanism_")..i,id,function()
     if not e.protection then return end
     local ok,code=e.protection.block(lane,os.clock())
     if not ok then feedback(if code=="WrongLane"then "Wrong shutter"else "Wait for the warning",if code=="WrongLane"then "บานนิรภัยผิดช่อง"else "รอสัญญาณเตือน")end
    end,{"Close shutter "..i,"ปิดบานนิรภัย "..i})
    e.markers[#e.markers].lane=lane
   end
  end
  protection("shoring_gallery","engineer","protect_engineer")
  objective("ink_office","reagent","collect_reagent")
  for i=1,2 do
   objective("ink_office","seal_"..i,"compare_mine_seals",function()set("compare_mine_seals",tostring(i),2)end)
   e.markers[#e.markers].active=function()return not (e.sets.compare_mine_seals or {})[tostring(i)]end
  end
  for i,choice in ipairs({"workers","council"})do
   marker("Review_"..choice,"choose_joint_review",at("ink_office","evidence_desk")+V((i-1)*6,0,0),if choice=="workers"then {"Workers host the joint review","ให้คนงานเป็นเจ้าภาพตรวจสอบร่วม"}else {"Council hosts the joint review","ให้สภาเป็นเจ้าภาพตรวจสอบร่วม"},function()observe(player,e,"choose_joint_review",choice)end)
   e.markers[#e.markers].prompt.MaxActivationDistance=4
  end
  for i=1,3 do objective("warden_mechanism","mechanism_"..i,"operate_mine_mechanism",function()sequence("operate_mine_mechanism",tostring(i),{"1","2","3"})end,{"Safety control "..i.." · order 1 → 2 → 3","กลไก "..i.." · ลำดับ 1 → 2 → 3"})end
  protection("warden_mechanism","protected_worker","protect_mine_worker")
  objective("warden_mechanism","arena_entry","return_mine_key")
  objective("training_camp","mentor","meet_class_mentor")
  objective("training_camp","mentor","submit_ironveil_evidence")
  for i,class in ipairs({"Warrior","Knight","Archer","Mage","Priest"})do
   local paths={};for pathId,def in pairs(Expansion.Paths)do if def.Class==class and def.Tier==2 then table.insert(paths,pathId)end end;table.sort(paths)
   for j,pathId in ipairs(paths)do
    local function startTrial(data:any)
    if e.trial then return end
    local runId=Http:GenerateGUID(false);e.trialDelivery=nil
    e.trial=require(script.Parent.NoviceTrialArena)(player,data,class,runId,art.origin+V(0,25,0),function(receipt)
     if e.trialDelivery=="Committed"then return true end
     observe(player,e,"complete_borrowed_path",nil,receipt);return false
    end,function()if e.trial then e.trial.Destroy();e.trial=nil end end,require(script.Parent.BorrowedPathFactory)(pathId))
    end
    marker("Borrowed_"..pathId,"complete_borrowed_path",at("training_camp","trial_"..i)+V((j-1)*8-4,0,0),{"Try "..Expansion.Paths[pathId].Name,"ทดลอง "..Expansion.Paths[pathId].Name},startTrial,function(data)return data.character.classId==class end)
    e.markers[#e.markers].prompt.MaxActivationDistance=4
   end
  end
  art.model.Parent=workspace:FindFirstChild("GuildborneWorld")or workspace
  game:GetService("CollectionService"):AddTag(art.model,"GuildborneMineActivity")
 end
 function S.Victory(player:Player,ticket:any)
  local e=entries[player];if not e or not ready(player,e,"defeat_mine_warden")or ticket.owner~=player.UserId or ticket.encounterId~="quarry_guardian"or player:GetAttribute("CurrentZone")~="Ironveil"then return end
  local r=root(player);if not r or r.Position.Y>35 then return end
  for _,id in ipairs(ticket.members)do if id~="player"then
   local actor=deps.World.CompanionEvidence(player,id)
   if actor and actor.health>0 and (actor.position-r.Position).Magnitude<=30 then observe(player,e,"defeat_mine_warden");return end
  end end
 end
 local elapsed=0
 local heartbeat=Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  for player,e in pairs(entries)do
   local s=session(player)
   if not s or s.epoch~=e.epoch or s.token~=e.token or player.Parent~=Players then S.Remove(player);continue end
   if e.pending and os.clock()>=(e.deliveryAt or 0)then
    e.deliveryAt=os.clock()+.5;local outcome,problem=e.pending();e.art.model:SetAttribute("DeliveryProblem",problem)
    if outcome=="Committed"then
     if e.pendingObjective=="complete_borrowed_path"then e.trialDelivery="Committed"end
     e.pending=nil;deps.Notify(player);deps.Data.FlushAudit(player.UserId)
    elseif outcome=="Rejected"then
     e.puzzles[e.pendingObjective]=nil;e.sets[e.pendingObjective]=nil;stopActivity(e);e.pending=nil
    end
   end
   if entries[player]~=e then continue end
   local data=s.record.data;local id=nextId(data);local th=data.settings.language=="th";local index=if th then 2 else 1
   if e.objective~=id then stopActivity(e);e.objective=id;e.message=nil end
   e.art.model:SetAttribute("EscortStatus",if e.escort then e.escort.Snapshot().status else nil)
   e.art.model:SetAttribute("EscortPosition",if e.escort then e.actors.miner:GetPivot().Position else nil)
   e.art.model:SetAttribute("EscortExit",if e.escort then e.art.scenes.signal_shaft:GetPivot().Position+V(0,0,13)else nil)
   if e.escort then
    local escort=e.escort.Snapshot()
    if escort.reason=="MeetAtExit"then e.message={"Meet the miner at the safe exit.","ไปพบคนงานที่ทางออกปลอดภัย"};e.messageUntil=os.clock()+.3
    elseif escort.reason=="WaitForOwner"then e.message={"The miner is waiting. Move closer.","คนงานกำลังรอ เดินเข้าไปใกล้"};e.messageUntil=os.clock()+.3
    elseif escort.status=="Failed"or escort.status=="Cancelled"then e.message={"Rescue paused. Return to retry.","การช่วยคนงานหยุดแล้ว กลับมาเริ่มใหม่ได้"};e.messageUntil=os.clock()+.3 end
   end
   if e.protection then
    local r=root(player);local near=r and math.abs(r.Position.Y-e.art.origin.Y)<10 and (r.Position-e.art.origin).Magnitude<165
    local state=e.protection.step(os.clock(),near~=nil and near~=false,current(player,e)~=nil)
    local snapshot=e.protection.snapshot()
    local warning=snapshot.warning;local warningPosition=nil
    if warning then for _,m in ipairs(e.markers)do if m.id==e.protectionId and m.lane==warning.lane then warningPosition=m.part.Position;break end end end
    e.art.model:SetAttribute("ProtectionStatus",snapshot.status)
    e.art.model:SetAttribute("ProtectionWarningPosition",warningPosition)
    e.art.model:SetAttribute("ProtectionWarningBlocked",warning and warning.blocked or false)
    e.art.model:SetAttribute("ProtectionImpactAt",if warning then workspace:GetServerTimeNow()+math.max(0,warning.impactAt-os.clock())else nil)
    e.art.model:SetAttribute("WorkerHealth",snapshot.health)
    local worker=if e.protectionId=="protect_engineer"then e.actors.engineer else e.actors.guarded_worker
    worker:SetAttribute("ProtectedHealth",snapshot.health)
    if state=="Completed"then observe(player,e,e.protectionId)
    elseif state=="Active"then
     e.message=if warning then {"Warning: "..warning.lane.." shutter · "..snapshot.blocks.."/3","เตือน: บาน "..({left="ซ้าย",centre="กลาง",right="ขวา"})[warning.lane].." · "..snapshot.blocks.."/3"}else {"Prepare for the next warning","เตรียมรับสัญญาณถัดไป"};e.messageUntil=os.clock()+.3
    elseif state=="Failed"then e.message={"Inspection failed. Start again at the worker.","ตรวจไม่สำเร็จ เริ่มใหม่ที่คนงาน"};e.messageUntil=os.clock()+.3 end
   else
    for _,attribute in ipairs({"ProtectionStatus","ProtectionWarningPosition","ProtectionWarningBlocked","ProtectionImpactAt"})do e.art.model:SetAttribute(attribute,nil)end
   end
   for _,m in ipairs(e.markers)do
    local active=(not m.id or id==m.id)and (not m.active or m.active(data))
    m.part.Transparency=if active then .25 else 1;m.board.Enabled=active
    m.prompt.Enabled=active and current(player,e)~=nil and not e.pending and (not m.id or ready(player,e,m.id))
    local text=m.label[index]
    local warning=e.protection and e.protection.snapshot().warning
    local urgent=m.lane and warning and warning.lane==m.lane and not warning.blocked
    m.part.Color=if urgent then Color3.fromRGB(242,107,67)else Color3.fromRGB(214,174,78)
    if urgent then text=text..(if th then " · ปิดตอนนี้"else " · CLOSE NOW")end
    if m.id and not m.lane and e.message and os.clock()<(e.messageUntil or 0)then text=text.."\n"..e.message[index]end
    m.text.Text=text;m.prompt.ActionText=m.label[index];m.prompt.ObjectText=if th then "ไอรอนเวล · บท 2"else "Ironveil · Chapter 2"
   end
   for _,n in ipairs(e.notes)do n.board.Enabled=id~=nil and table.find(n.ids,id)~=nil;n.label.Text=n.copy[index]end
  end
 end)
 function S.Destroy()heartbeat:Disconnect();for player in pairs(entries)do S.Remove(player)end end
 return S
end
