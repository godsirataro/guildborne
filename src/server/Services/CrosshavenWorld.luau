--!strict
-- Staged Chapter05 adapter. Server measurements produce private, retryable receipts.
local Players=game:GetService("Players");local Run=game:GetService("RunService");local Http=game:GetService("HttpService")
local Shared=game.ReplicatedStorage.Shared
local V=Vector3.new
local makeArt=require(script.Parent.CrosshavenCourtArt)
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
  return if claimed>=24 and claimed<30 and d.personalGuild.buildings.guildHall>=11 then s else nil
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
  e.pending=deps.MakeReceipt(player.UserId,receipt or {owner=player.UserId,requestId="crosshaven:"..Http:GenerateGUID(false),action="CampaignObjective",args={objective=id,choice=choice}})
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
  if r and math.abs(r.Position.Y-e.art.origin.Y)<45 and (Vector2.new(r.Position.X,r.Position.Z)-Vector2.new(2600,1400)).Magnitude<240 then deps.World.IntentCommitted(player,"TravelZone",{zone="City"})end
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
  local offsets={marshal_elian=V(-108,0,112),arborist_vaela=V(-108,0,-98),smith_borin=V(-80,0,-140),cartographer_nyra=V(54,0,6),harbormaster_sela=V(-108,0,90),steward_roka=V(-80,0,28)}
  for _,actor in ipairs(actors:GetChildren())do if actor:IsA("Model")then
   actor:PivotTo(CFrame.new(art.origin+offsets[actor.Name])*CFrame.Angles(0,math.pi,0));e.actors[actor.Name]=actor
   game:GetService("CollectionService"):AddTag(actor,"GuildborneFriendlyNPC")
  end end
  local function feedback(en:string,th:string)e.message={en,th};e.messageUntil=clock()+2.5 end
  local function marker(name:string,id:string?,position:Vector3,label:any,callback:any,active:any?)
   local p=Instance.new("Part");p.Name=name;p.Size=V(2,.15,2);p.Position=position;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(214,174,78);p.Parent=art.model
   local prompt=Instance.new("ProximityPrompt");prompt.Name="Crosshaven_"..name;prompt.MaxActivationDistance=7;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.R;prompt.GamepadKeyCode=Enum.KeyCode.ButtonY;prompt.Enabled=false;prompt.Parent=p
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

  marker("CourtEntrance",nil,V(18,2.15,-700),{"Enter Crosshaven's charter court","เข้าลานรับรองครอสเฮเวน"},function()
   if player:GetAttribute("CurrentZone")~="City"or e.trial then return end
   local c=player.Character;local r=root(player)
   if c and r then c:PivotTo(CFrame.new(art.entry));r.AssemblyLinearVelocity=V(0,0,0);deps.World.RefreshCampaignCompanions(player)end
  end)
  marker("CourtExit",nil,art.exit.Position,{"Return to the central city","กลับเมืองรวม"},function()stopActivity(e);deps.World.IntentCommitted(player,"TravelZone",{zone="City"})end)
  objective("rift_refuge","mentor","meet_crosshaven_mentor",nil,{"Sela · prepare for the rift","Sela · เตรียมตัวเข้ารอยแยก"})
  objective("rift_refuge","mastery_trial","complete_borrowed_mastery",function(data:any)
   if e.trial then return end;e.trialDelivery=nil
   local expansion=require(Shared.Data.Expansion);local build=expansion.build(data,"player")
   local defaults={Warrior="warlord",Knight="fortress",Archer="beastwarden",Mage="archmage",Priest="high_priest"}
   local pathId=defaults[data.character.classId]
   if build.path and expansion.Paths[build.path]then
    local path=expansion.Paths[build.path]
    if path.Tier==3 then pathId=build.path else for id,p in pairs(expansion.Paths)do if p.Parent==build.path then pathId=id;break end end end
   end
   e.trial=require(script.Parent.NoviceTrialArena)(player,data,data.character.classId,Http:GenerateGUID(false),art.origin+V(0,32,0),function(receipt:any)
    if e.trialDelivery=="Committed"then return true end
    observe(player,e,"complete_borrowed_mastery",nil,receipt);return false
   end,function()if e.trial then e.trial.Destroy();e.trial=nil end end,require(script.Parent.BorrowedPathFactory)(pathId,true))
  end)
  local function route(scene:string,points:{string}):{Vector3}
   local values={};for _,point in ipairs(points)do local p=at(scene,point);table.insert(values,V(p.X,art.origin.Y,p.Z))end;return values
  end
  escort("rift_refuge","rival_start","rescue_former_rival","marshal_elian",function()return route("rift_refuge",{"rival_start","rival_waypoint","rival_refuge"})end)
  objective("rift_refuge","charter","claim_crosshaven_charter")
  for _,side in ipairs({"human","orc"})do for i=1,3 do
   checked("hearing_square",side.."_record_"..i,"collect_both_testimonies",side..i,6)
   e.markers[#e.markers].label=if side=="human"then {"Human neighborhood record "..i,"บันทึกย่านมนุษย์ "..i}else {"Orc neighborhood record "..i,"บันทึกย่านออร์ค "..i}
  end end
  for _,side in ipairs({"human","orc"})do
   checked("hearing_square","speaker_"..side,"hold_crosshaven_hearing",side,2)
   e.markers[#e.markers].label=if side=="human"then {"Sela · hear the harbor account","Sela · ฟังเรื่องจากท่าเรือ"}else {"Roka · hear the refuge account","Roka · ฟังเรื่องจากค่ายพักพิง"}
  end
  for _,choice in ipairs({"shared_table","joint_work"})do
   objective("hearing_square",choice,"choose_reconciliation",function()observe(player,e,"choose_reconciliation",choice)end,if choice=="shared_table"then {"Share a meal · equal reward","ร่วมมื้ออาหาร · รางวัลเท่ากัน"}else {"Rebuild together · equal reward","ร่วมซ่อมชุมชน · รางวัลเท่ากัน"})
  end
  for _,point in ipairs({"sleeping_space","water_space","care_space"})do checked("refuge_camp",point,"prepare_refuge_spaces",point,3)end
  for i=1,3 do checked("refuge_camp","supply_bundle_"..i,"prepare_certain_supplies",tostring(i),3)end
  objective("refuge_camp","camp_steward","defend_refuge_camp",function()
   if e.lesson then local state=e.lesson.Snapshot();if state and state.status=="Active"then return end;e.lesson.Destroy()end
   e.lesson=makeLesson({Parent=art.model,Config=require(script.Parent.Parent.Config.CrosshavenWards),TargetStyle="Ward",Title={"Camp wards · temporary tools","เกราะค่าย · เครื่องมือชั่วคราว"}})
   local origin=art.scenes.refuge_camp:GetPivot().Position
   local ok=e.lesson.Start(player,origin,"Combined",function():any
    local live=current(player,e);local r=root(player)
    return {current=live~=nil and nextId(live.record.data)=="defend_refuge_camp",alive=r~=nil,near=r~=nil and (r.Position-origin).Magnitude<40,language=live and live.record.data.settings.language}
   end,function()observe(player,e,"defend_refuge_camp")end)
   if not ok then e.lesson.Destroy();e.lesson=nil end
  end,{"Roka · start / retry ward defense","Roka · เริ่ม / ลองป้องกันเกราะใหม่"})
  objective("forger_passage","witness","interview_crest_witness",nil,{"Nyra · hear the witness","Nyra · ฟังคำให้การ"})
  note("forger_passage",V(0,12,0),{"solve_refuge_passage"},{"Read all three plaques. Then press 2 → 1 → 3. Follow the hidden turn and exit.","อ่านป้ายทั้งสาม แล้วกด 2 → 1 → 3 ตามจุดเลี้ยวลับไปทางออก"})
  for i=1,3 do
   objective("forger_passage","passage_clue_"..i,"solve_refuge_passage",function()
    e.clues=e.clues or {};local count=0;for _ in pairs(e.clues)do count+=1 end
    if count<3 then e.clues[i]=true;feedback("Read all three clues before the sequence.","อ่านคำใบ้ครบสามป้ายก่อนกดลำดับ");return end
    e.passagePuzzle=e.passagePuzzle or makePuzzle({"2","1","3"})
    local ok,code=e.passagePuzzle.press(tostring(i),clock())
    if ok and code=="Complete"then e.passageOpen=true;feedback("The hidden turn is open.","จุดเลี้ยวลับเปิดแล้ว")elseif code=="TrySequenceAgain"then feedback("Start again: 2 → 1 → 3.","เริ่มใหม่: 2 → 1 → 3")end
   end,{"Read / press plaque "..i,"อ่าน / กดป้าย "..i})
   e.markers[#e.markers].active=function()return not e.passageOpen end
  end
  objective("forger_passage","hidden_turn","solve_refuge_passage",function()e.passageTurn=true end)
  e.markers[#e.markers].active=function()return e.passageOpen and not e.passageTurn end
  objective("forger_passage","hidden_exit","solve_refuge_passage")
  e.markers[#e.markers].active=function()return e.passageTurn==true end
  for _,choice in ipairs({"testify","guarded_refuge"})do objective("forger_passage",choice,"choose_forger_fate",function()observe(player,e,"choose_forger_fate",choice)end,if choice=="testify"then {"Request testimony · preserve life","ขอคำให้การ · รักษาชีวิต"}else {"Offer guarded refuge · preserve life","ให้ที่พักภายใต้การคุ้มกัน · รักษาชีวิต"})end
  escort("name_registry","escort_start","escort_through_inspection","arborist_vaela",function()return route("name_registry",{"escort_start","inspection_left","inspection_center","inspection_right","escort_exit"})end)
  note("name_registry",V(0,12,0),{"disable_name_sorter"},{"Borin's interlock order: 2 → 1 → 3. A wrong press resets only this sequence.","ลำดับปลดล็อกของ Borin: 2 → 1 → 3 กดผิดเริ่มใหม่เฉพาะลำดับนี้"})
  for i=1,3 do objective("name_registry","interlock_"..i,"disable_name_sorter",function()sequence("disable_name_sorter",tostring(i),{"2","1","3"})end,{"Disconnect interlock "..i,"ปลดล็อก "..i})end
  objective("name_registry","backup_evidence","register_backup_evidence")
  for _,point in ipairs({"offer","consequence","return_route"})do checked("invitation_gallery",point,"read_power_offer",point,3)end
  for _,choice in ipairs({"refuse","investigate"})do objective("invitation_gallery",choice.."_offer","choose_offer_response",function()observe(player,e,"choose_offer_response",choice)end,if choice=="refuse"then {"Refuse openly · equal reward","ปฏิเสธตรงไปตรงมา · รางวัลเท่ากัน"}else {"Investigate under cover · equal reward","แสร้งรับเพื่อสืบ · รางวัลเท่ากัน"})end
  for _,point in ipairs({"rest_station","supply_station","route_station"})do checked("invitation_gallery",point,"prepare_final_route",point,3)end

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
     if e.pendingObjective=="complete_borrowed_mastery"then e.trialDelivery="Committed"end
     e.pending=nil;deps.Notify(player);deps.Data.FlushAudit(player.UserId)
    elseif outcome=="Rejected"then e.puzzles[e.pendingObjective]=nil;e.sets[e.pendingObjective]=nil;stopActivity(e);e.pending=nil end
   end
   if entries[player]~=e then continue end
   local data=s.record.data;local id=nextId(data);local th=data.settings.language=="th";local index=if th then 2 else 1
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
   local r=root(player);local inside=r~=nil and math.abs(r.Position.Y-e.art.origin.Y)<30 and math.abs(r.Position.X-e.art.origin.X)<165 and math.abs(r.Position.Z-e.art.origin.Z)<165
   local chapter=deps.Config.Chapters[data.progression.campaign.claimed+1]
   local hallReady=chapter~=nil and data.personalGuild.buildings.guildHall>=(chapter.Hall or 1)and data.character.level>=chapter.Level
   local navigation:any=nil;local nearest=math.huge
   for _,m in ipairs(e.markers)do
    local active=(not m.id or id==m.id)and (not m.active or m.active(data))
    m.part.Transparency=if active then .25 else 1;m.board.Enabled=active
    m.prompt.Enabled=active and current(player,e)~=nil and not e.pending and not e.trial and (not m.id or ready(player,e,m.id))
    local text=m.label[index]
    if m.id and e.message and clock()<(e.messageUntil or 0)then text=text.."\n"..e.message[index]end
    m.text.Text=text;m.prompt.ActionText=(m.action or m.label)[index];m.prompt.ObjectText=if th then "ครอสเฮเวน · บท 5"else "Crosshaven · Chapter 5"
    local wanted=if not inside then m.name=="CourtEntrance"and player:GetAttribute("CurrentZone")=="City"elseif not hallReady then m.name=="CourtExit"else id~=nil and m.id==id and active
    if wanted and r then local distance=(r.Position-m.part.Position).Magnitude;if distance<nearest then nearest=distance;navigation=m end end
   end
   local navText=if navigation then navigation.label[index]elseif inside and not id then (if th then "เปิดเมนูกิลด์เพื่อรับรางวัลบทนี้"else "Open the Guild menu to claim chapter rewards")elseif not inside then (if th then "กลับเมืองรวม · เข้าลานครอสเฮเวนข้างวาปเกาะกิลด์"else "Return to City · enter Crosshaven beside the Guild Zone Warp")else nil
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
