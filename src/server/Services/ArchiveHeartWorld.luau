--!strict
-- Staged Chapter06 adapter. Server measurements produce private, retryable receipts.
local Players=game:GetService("Players");local Run=game:GetService("RunService");local Http=game:GetService("HttpService")
local V=Vector3.new
local makeArt=require(script.Parent.ArchiveHeartCourtArt)
local memory=require(game.ReplicatedStorage.Shared.Data.ArchiveStoryMemory)
local makeEnding=require(game.ReplicatedStorage.Shared.Presentation.ArchiveEndingKit)
local makeCast=require(script.Parent.CityCharacterKit)
local makePuzzle=require(script.Parent.Parent.Systems.IronveilPuzzle)
local makeLesson=require(script.Parent.TowerLessonArena)
local makeEscort=require(script.Parent.EscortActor)
return function(deps:any)
 local clock=deps.Now or os.clock;local heartbeatSource=deps.Heartbeat or Run.Heartbeat
 local S={};local entries:{[Player]:any}={};local occupied={}
 local function session(player:Player):any?
  local s=deps.Data.Sessions[player.UserId];local d=s and s.record and s.record.data
  if not s or s.closing or not d or not d.progression.campaign then return nil end
  local claimed=d.progression.campaign.claimed
  return if claimed>=30 and claimed<36 and d.personalGuild.buildings.guildHall>=14 then s else nil
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
  e.pending=deps.MakeReceipt(player.UserId,receipt or {owner=player.UserId,requestId="archiveheart:"..Http:GenerateGUID(false),action="CampaignObjective",args={objective=id,choice=choice}})
  e.pendingObjective=id
 end
 local function stopActivity(e:any)
  if e.escort then e.escort.Destroy();e.escort=nil end
  if e.lesson then e.lesson.Destroy();e.lesson=nil end
  if e.trial then e.trial.Destroy();e.trial=nil end
 end
 function S.Remove(player:Player)
  local e=entries[player];if not e then return end
  entries[player]=nil;occupied[e.slot]=nil;stopActivity(e)
  local r=root(player)
  if r and math.abs(r.Position.Y-e.art.origin.Y)<60 and math.abs(r.Position.X-e.art.origin.X)<180 and math.abs(r.Position.Z-e.art.origin.Z)<200 then deps.World.IntentCommitted(player,"TravelZone",{zone="City"})end
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
  local offsets={marshal_elian=V(-126,0,-144),arborist_vaela=V(-46,0,-144),smith_borin=V(58,0,-30),cartographer_nyra=V(-86,0,136),harbormaster_sela=V(66,0,158),steward_roka=V(-106,0,-144)}
  for _,actor in ipairs(actors:GetChildren())do if actor:IsA("Model")then
   actor:PivotTo(CFrame.new(art.origin+offsets[actor.Name])*CFrame.Angles(0,math.pi,0));e.actors[actor.Name]=actor
   game:GetService("CollectionService"):AddTag(actor,"GuildborneFriendlyNPC")
  end end
  local function feedback(en:string,th:string)e.message={en,th};e.messageUntil=clock()+2.5 end
  local function marker(name:string,id:string?,position:Vector3,label:any,callback:any,active:any?)
   local p=Instance.new("Part");p.Name=name;p.Size=V(2,.15,2);p.Position=position;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(214,174,78);p.Parent=art.model
   local prompt=Instance.new("ProximityPrompt");prompt.Name="ArchiveHeart_"..name;prompt.MaxActivationDistance=7;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.R;prompt.GamepadKeyCode=Enum.KeyCode.ButtonY;prompt.Enabled=false;prompt.Parent=p
   local board=Instance.new("BillboardGui");board.Size=UDim2.fromOffset(290,100);board.StudsOffset=V(0,4,0);board.MaxDistance=65;board.AlwaysOnTop=true;board.Enabled=false;board.Parent=p
   local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.TextWrapped=true;text.Font=Enum.Font.GothamMedium;text.TextSize=15;text.TextColor3=Color3.fromRGB(244,233,208);text.BackgroundColor3=Color3.fromRGB(22,29,38);text.Parent=board
   table.insert(e.markers,{part=p,prompt=prompt,board=board,text=text,id=id,label=label,active=active,name=name})
   local function trigger(who:Player)
    local r=root(player);local live=current(player,e)
    if who~=player or not live or not r or e.pending or not prompt.Enabled or (r.Position-p.Position).Magnitude>9 then return end
    if id and not ready(player,e,id)then return end
    if active and not active(live.record.data)then return end
    callback(live.record.data)
   end
   table.insert(e.connections,if deps.BindPrompt then deps.BindPrompt(prompt,trigger)else prompt.Triggered:Connect(trigger))
  end
  local function at(scene:string,id:string):Vector3 return assert(art.markers[scene.."/"..id]).Position end
  local function objective(scene:string,point:string,id:string,callback:any?,label:any?)
   marker(id.."_"..point,id,at(scene,point),label or deps.Config.ObjectiveLabels[id],callback or function()observe(player,e,id)end)
  end
  local function note(scene:string,position:Vector3,ids:{string},copy:any)
   local p=Instance.new("Part");p.Name="TowerInstructions";p.Size=V(1,1,1);p.Position=art.scenes[scene]:GetPivot().Position+position;p.Anchored=true;p.Transparency=1;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=art.model
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
   local ok,code=e.puzzles[id].press(key,clock())
   if ok and code=="Complete"then observe(player,e,id)
   elseif code=="TrySequenceAgain"then feedback("Wrong order. Start again.","ลำดับไม่ถูกต้อง เริ่มใหม่ได้")
   elseif ok then feedback("Correct. Continue the sequence.","ถูกต้อง ไปจุดถัดไป")end
  end
  local function checked(scene:string,point:string,id:string,key:string,total:number)
   objective(scene,point,id,function()set(id,key,total)end)
   e.markers[#e.markers].active=function()return not (e.sets[id]or {})[key]end
  end
  local function escort(scene:string,point:string,id:string,actorName:string,routeFor:any)
   objective(scene,point,id,function(data)
    if e.escort and e.escort.Snapshot().status~="Failed"and e.escort.Snapshot().status~="Cancelled"then return end
    if e.escort then e.escort.Destroy()end
    local route=routeFor(data);e.escortActor=e.actors[actorName];e.escortExit=route[#route]
    e.escort=makeEscort(e.escortActor,route,{art.scenes[scene]},function():any
     local live=current(player,e);local r=root(player)
     return {current=live~=nil and nextId(live.record.data)==id,alive=r~=nil,position=r and r.Position,npcAlive=true}
    end,function()observe(player,e,id)end)
   end,{"Start / retry escort. Stay nearby.","เริ่ม / ลองคุ้มกันใหม่ อยู่ใกล้ผู้ร่วมทาง"})
  end

  marker("CourtEntrance",nil,V(-18,2.15,-700),{"Enter the Archive Heart expedition","เข้าสำรวจหัวใจหอจดหมายเหตุ"},function()
   if player:GetAttribute("CurrentZone")~="City"or e.trial then return end
   local c=player.Character;local r=root(player)
   if c and r then c:PivotTo(CFrame.new(art.entry));r.AssemblyLinearVelocity=V(0,0,0);deps.World.RefreshCampaignCompanions(player)end
  end)
  marker("CourtExit",nil,art.exit.Position,{"Return to the central city","กลับเมืองรวม"},function()stopActivity(e);deps.World.IntentCommitted(player,"TravelZone",{zone="City"})end)

  local function route(scene:string,points:{string}):{Vector3}
   local values={};for _,point in ipairs(points)do local p=at(scene,point);table.insert(values,V(p.X,art.origin.Y,p.Z))end;return values
  end
  local function ward(scene:string,point:string,id:string,role:string,label:any)
   objective(scene,point,id,function()
    if e.lesson then local state=e.lesson.Snapshot();if state and state.status=="Active"then return end;e.lesson.Destroy()end
    e.lesson=makeLesson({Parent=art.model,Config=require(script.Parent.Parent.Config.CrosshavenWards),TargetStyle="Ward",Title={"Alliance wards · temporary tools","เกราะพันธมิตร · เครื่องมือชั่วคราว"}})
    local origin=art.scenes[scene]:GetPivot().Position
    local ok=e.lesson.Start(player,origin,role,function():any
     local live=current(player,e);local r=root(player)
     return {current=live~=nil and nextId(live.record.data)==id,alive=r~=nil,near=r~=nil and (r.Position-origin).Magnitude<40,language=live and live.record.data.settings.language}
    end,function()observe(player,e,id)end)
    if not ok then e.lesson.Destroy();e.lesson=nil end
   end,label)
  end
  local function encounter(scene:string,point:string,id:string,mode:string)
   objective(scene,point,id,function(data:any)
    if e.trial then return end;e.trialDelivery=nil
    e.trial=require(script.Parent.ArchiveHeartArena)(player,data,mode,Http:GenerateGUID(false),art.origin+V(0,34,0),function()
     local live=current(player,e);return live~=nil and nextId(live.record.data)==id
    end,function(receipt:any)
     if e.trialDelivery=="Committed"then return true end
     observe(player,e,id,nil,receipt);return false
    end,function()if e.trial then e.trial.Destroy();e.trial=nil end end)
   end)
  end
  for _,choice in ipairs({"guard","stealth","puzzle"})do
   objective("three_gates","choose_"..choice,"choose_citadel_approach",function()observe(player,e,"choose_citadel_approach",choice)end,
    if choice=="guard"then {"Defend with temporary shields","ป้องกันด้วยโล่ชั่วคราว"}elseif choice=="stealth"then {"Follow the covered ally route","ตามพันธมิตรผ่านทางกำบัง"}else {"Solve the symbol sequence","แก้ลำดับสัญลักษณ์"})
  end
  ward("three_gates","guard_step_1","complete_alliance_entry","Guard",{"Start / retry shield approach","เริ่ม / ลองเส้นทางป้องกันใหม่"})
  e.markers[#e.markers].active=function(data)return data.progression.campaign.choices.choose_citadel_approach=="guard"end
  escort("three_gates","stealth_step_1","complete_alliance_entry","cartographer_nyra",function()return route("three_gates",{"stealth_step_1","stealth_step_2","stealth_step_3"})end)
  e.markers[#e.markers].active=function(data)return data.progression.campaign.choices.choose_citadel_approach=="stealth"end
  note("three_gates",V(35,12,16),{"complete_alliance_entry"},{"Symbol approach: 2 → 1 → 3. All classes can use every approach.","ทางสัญลักษณ์: 2 → 1 → 3 ทุกอาชีพเลือกได้ทุกทาง"})
  for i=1,3 do
   objective("three_gates","puzzle_step_"..i,"complete_alliance_entry",function()sequence("complete_alliance_entry",tostring(i),{"2","1","3"})end,{"Press symbol "..i,"กดสัญลักษณ์ "..i})
   e.markers[#e.markers].active=function(data)return data.progression.campaign.choices.choose_citadel_approach=="puzzle"end
  end
  objective("three_gates","command_post","establish_heart_command")
  note("supply_court",V(-20,13,26),{"greet_returning_caravan","escort_supply_column"},function(data:any):any
   local caravan=assert(memory(data,"caravan"));local timber=assert(memory(data,"timber"))
   return {caravan[1].."\n"..timber[1],caravan[2].."\n"..timber[2]}
  end)
  objective("supply_court","caravan_greeting","greet_returning_caravan")
  escort("supply_court","escort_start","escort_supply_column","harbormaster_sela",function()return route("supply_court",{"escort_start","escort_turn","escort_exit"})end)
  ward("supply_court","supply_anchor","secure_supply_anchor","Combined",{"Protect the supplies · start / retry","ป้องกันเสบียง · เริ่ม / ลองใหม่"})
  for i=1,3 do
   checked("warden_approach","warning_"..i,"read_last_warden_patterns",tostring(i),3)
   e.markers[#e.markers].label=if i==1 then {"Line · step sideways","เส้น · ก้าวออกด้านข้าง"}elseif i==2 then {"Ring · center or outside is safe","วงแหวน · กลางวงหรือนอกวงปลอดภัย"}else {"Circle · leave the marked position","วงกลม · ออกจากตำแหน่งที่ถูกหมาย"}
  end
  encounter("warden_approach","warden_trial","break_warden_seals","warden")
  for _,choice in ipairs({"release","renew"})do
   objective("warden_approach",choice.."_oath","choose_warden_release",function()observe(player,e,"choose_warden_release",choice)end,
    if choice=="release"then {"Free the warden · equal reward","ปลดผู้เฝ้า · รางวัลเท่ากัน"}else {"Offer a voluntary new oath · equal reward","เสนอคำมั่นใหม่โดยสมัครใจ · รางวัลเท่ากัน"})
  end
  objective("living_ledger","recovery_start","recover_named_ledgers",function()
   e.recoveryUntil=clock()+90;e.sets.recover_named_ledgers={};feedback("90 seconds. Recover all three ledgers.","เวลา 90 วินาที กู้บัญชีให้ครบสามจุด")
  end,{"Start / retry 90-second recovery","เริ่ม / ลองกู้บัญชีใหม่ใน 90 วินาที"})
  e.markers[#e.markers].active=function()return not e.recoveryUntil or clock()>=e.recoveryUntil end
  for i=1,3 do
   objective("living_ledger","recover_"..i,"recover_named_ledgers",function()
    if not e.recoveryUntil or clock()>=e.recoveryUntil then return end
    set("recover_named_ledgers",tostring(i),3)
   end,{"Recover named ledger "..i,"กู้บัญชีรายชื่อ "..i})
   e.markers[#e.markers].active=function()return e.recoveryUntil~=nil and clock()<e.recoveryUntil and not (e.sets.recover_named_ledgers or {})[tostring(i)]end
   checked("living_ledger","backup_"..i,"duplicate_named_ledgers",tostring(i),3)
   objective("living_ledger","interlock_"..i,"disconnect_ledger_engine",function()sequence("disconnect_ledger_engine",tostring(i),{"2","1","3"})end,{"Disconnect interlock "..i,"ปลดล็อก "..i})
  end
  note("living_ledger",V(0,12,0),{"recover_named_ledgers","duplicate_named_ledgers","disconnect_ledger_engine"},function()
   local remaining=if e.recoveryUntil then math.max(0,math.ceil(e.recoveryUntil-clock()))else 90
   return {"Recovery: "..remaining.."s. Copy all three names before disconnecting 2 → 1 → 3.","เวลากู้บัญชี "..remaining.." วินาที สำรองครบสามจุดก่อนปลด 2 → 1 → 3"}
  end)
  for i,name in ipairs({"Human envoy","Orc steward","Dwarf smith","Mage archivist","Elf caretaker"})do
   checked("alliance_gate","pledge_"..i,"gather_voluntary_oaths",tostring(i),5)
   e.markers[#e.markers].label={name.." · hear a voluntary pledge",({"ตัวแทนมนุษย์","ผู้ดูแลออร์ค","ช่างคนแคระ","นักจดหมายเหตุนักเวท","ผู้ดูแลเอลฟ์"})[i].." · ฟังคำมั่นโดยสมัครใจ"}
  end
  ward("alliance_gate","evacuation_station","protect_evacuation_gate","Combined",{"Protect evacuation · start / retry","ป้องกันการอพยพ · เริ่ม / ลองใหม่"})
  objective("alliance_gate","heart_gate","open_archive_heart")
  encounter("heart_chamber","keeper_trial","complete_keeper_of_names","keeper")
  for _,choice in ipairs({"preserve","transform","dismantle"})do
   objective("heart_chamber","ending_"..choice,"choose_tower_future",function()observe(player,e,"choose_tower_future",choice)end,
    if choice=="preserve"then {"Preserve the archive · equal reward","รักษาหอจดหมายเหตุ · รางวัลเท่ากัน"}elseif choice=="transform"then {"Transform it into a refuge · equal reward","ปรับเป็นที่พักพิง · รางวัลเท่ากัน"}else {"Dismantle the engine, preserve the names","รื้อเครื่อง แต่เก็บรายชื่อทุกคน"})
  end
  note("alliance_gate",V(-20,12,-28),{"gather_voluntary_oaths"},function(data:any):any return memory(data,"reconciliation")end)
  note("living_ledger",V(0,13,35),{"recover_named_ledgers"},function(data:any):any return memory(data,"warden")end)
  objective("heart_chamber","epilogue_record","record_alliance_epilogue")
  art.model.Parent=workspace:FindFirstChild("GuildborneWorld")or workspace
 end
 local elapsed=0
 local heartbeat=heartbeatSource:Connect(function(dt:number)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  for player,e in pairs(entries)do
   local s=session(player)
   if not s or s.epoch~=e.epoch or s.token~=e.token or player.Parent~=Players then S.Remove(player);continue end
   if e.pending and clock()>=(e.deliveryAt or 0)then
    e.deliveryAt=clock()+.5;local outcome,problem=e.pending();e.art.model:SetAttribute("DeliveryProblem",problem)
    if outcome=="Committed"then
     if e.pendingObjective=="break_warden_seals"or e.pendingObjective=="complete_keeper_of_names"then e.trialDelivery="Committed"end
     e.pending=nil;deps.Notify(player);deps.Data.FlushAudit(player.UserId)
    elseif outcome=="Rejected"then e.puzzles[e.pendingObjective]=nil;e.sets[e.pendingObjective]=nil;stopActivity(e);e.pending=nil end
   end
   if entries[player]~=e then continue end
   local data=s.record.data;local id=nextId(data);local th=data.settings.language=="th";local index=if th then 2 else 1
   -- Only a committed choice may change the epilogue display. No new receipt.
   local choice=if data.progression.campaign.objectives.choose_tower_future then data.progression.campaign.choices.choose_tower_future else nil
   if choice~=e.endingChoice then
    if e.endingVisual then e.endingVisual:Destroy();e.endingVisual=nil end
    e.endingChoice=choice
    if choice then
     local display=makeEnding(choice)
     if display then display:ScaleTo(.35);display:PivotTo(e.art.scenes.heart_chamber:GetPivot()*CFrame.new(0,3.6,44));display.Parent=e.art.model;e.endingVisual=display end
    end
    e.art.model:SetAttribute("EndingChoice",choice)
   end
   if e.objective~=id then
    -- The private campaign receipt is committed; restore the avatar from training.
    if e.trial and e.trialDelivery=="Committed"then
     e.trial.Destroy();e.trial=nil
    end
    stopActivity(e);e.objective=id;e.message=nil
   end
   if e.escort then
    local state=e.escort.Snapshot()
    if state.reason=="MeetAtExit"then e.message={"Meet your companion at the route exit.","ไปพบผู้ร่วมทางที่ปลายเส้นทาง"};e.messageUntil=clock()+.3
    elseif state.reason=="WaitForOwner"then e.message={"Your companion is waiting. Move closer.","ผู้ร่วมทางกำลังรอ เดินเข้าไปใกล้"};e.messageUntil=clock()+.3
    elseif state.status=="Failed"or state.status=="Cancelled"then e.message={"Return to the escort start to retry.","กลับจุดเริ่มคุ้มกันเพื่อลองใหม่"};e.messageUntil=clock()+.3 end
   end
   local r=root(player);local inside=r~=nil and math.abs(r.Position.Y-e.art.origin.Y)<30 and math.abs(r.Position.X-e.art.origin.X)<180 and math.abs(r.Position.Z-e.art.origin.Z)<200
   local chapter=deps.Config.Chapters[data.progression.campaign.claimed+1]
   local hallReady=chapter~=nil and data.personalGuild.buildings.guildHall>=(chapter.Hall or 1)and data.character.level>=chapter.Level
   local navigation:any=nil;local nearest=math.huge
   for _,m in ipairs(e.markers)do
    local active=(not m.id or id==m.id)and (not m.active or m.active(data))
    m.part.Transparency=if active then .25 else 1;m.board.Enabled=active
    m.prompt.Enabled=active and current(player,e)~=nil and not e.pending and not e.trial and (not m.id or ready(player,e,m.id))
    local text=m.label[index]
    if m.id and e.message and clock()<(e.messageUntil or 0)then text=text.."\n"..e.message[index]end
    m.text.Text=text;m.prompt.ActionText=(m.action or m.label)[index];m.prompt.ObjectText=if th then "หัวใจหอจดหมายเหตุ · บท 6"else "Archive Heart · Chapter 6"
    local wanted=if not inside then m.name=="CourtEntrance"and player:GetAttribute("CurrentZone")=="City"elseif not hallReady then m.name=="CourtExit"else id~=nil and m.id==id and active
    if wanted and r then local distance=(r.Position-m.part.Position).Magnitude;if distance<nearest then nearest=distance;navigation=m end end
   end
   local navText=if navigation then navigation.label[index]elseif inside and not id then (if th then "เปิดเมนูกิลด์เพื่อรับรางวัลบทนี้"else "Open the Guild menu to claim chapter rewards")elseif not inside then (if th then "กลับเมืองรวม · เข้าหอจดหมายเหตุข้างวาปเกาะกิลด์"else "Return to City · enter Archive Heart beside the Guild Zone Warp")else nil
   e.art.model:SetAttribute("NavigationPosition",if navigation then navigation.part.Position else nil)
   e.art.model:SetAttribute("NavigationText",navText)
   e.art.model:SetAttribute("NavigationThai",th)
   e.art.model:SetAttribute("NavigationVisible",navText~=nil and not e.trial and not e.lesson)
   for _,n in ipairs(e.notes)do local copy=if type(n.copy)=="function"then n.copy(data)else n.copy;n.board.Enabled=id~=nil and table.find(n.ids,id)~=nil;n.label.Text=copy[index]end
  end
 end)
 function S.Destroy()heartbeat:Disconnect();for player in pairs(entries)do S.Remove(player)end end
 return S
end
