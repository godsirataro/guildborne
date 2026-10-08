--!strict
-- Staged Chapter04 adapter. Server measurements produce private, retryable receipts.
local Players=game:GetService("Players");local Run=game:GetService("RunService");local Http=game:GetService("HttpService")
local V=Vector3.new
local makeArt=require(script.Parent.TowerCourtArt)
local makeCast=require(script.Parent.TowerCharacterKit)
local tasks=require(script.Parent.Parent.Config.IronveilTasks)
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
  return if claimed>=18 and claimed<24 and d.personalGuild.buildings.guildHall>=7 then s else nil
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
  e.pending=deps.MakeReceipt(player.UserId,receipt or {owner=player.UserId,requestId="tower:"..Http:GenerateGUID(false),action="CampaignObjective",args={objective=id,choice=choice}})
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
  if r and math.abs(r.Position.Y-e.art.origin.Y)<45 and (Vector2.new(r.Position.X,r.Position.Z)-Vector2.new(2000,1400)).Magnitude<240 then deps.World.IntentCommitted(player,"TravelZone",{zone="Ashen"})end
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
  local offsets={charter_warden=V(-80,0,90),archivist=V(-56,0,12),council_clerk=V(-56,0,93),bookbinder=V(106,0,-92)}
  for _,actor in ipairs(actors:GetChildren())do if actor:IsA("Model")then
   actor:PivotTo(CFrame.new(art.origin+offsets[actor.Name])*CFrame.Angles(0,math.pi,0));e.actors[actor.Name]=actor
   game:GetService("CollectionService"):AddTag(actor,"GuildborneFriendlyNPC")
  end end
  local echo=e.actors.bookbinder:Clone();echo.Name="memory_echo";echo:PivotTo(CFrame.new(art.origin+V(96,0,12)));echo.Parent=actors;e.actors.memory_echo=echo
  game:GetService("CollectionService"):AddTag(echo,"GuildborneFriendlyNPC")
  local function feedback(en:string,th:string)e.message={en,th};e.messageUntil=clock()+2.5 end
  local function marker(name:string,id:string?,position:Vector3,label:any,callback:any,active:any?)
   local p=Instance.new("Part");p.Name=name;p.Size=V(2,.15,2);p.Position=position;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(214,174,78);p.Parent=art.model
   local prompt=Instance.new("ProximityPrompt");prompt.Name="Tower_"..name;prompt.MaxActivationDistance=7;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.R;prompt.GamepadKeyCode=Enum.KeyCode.ButtonY;prompt.Enabled=false;prompt.Parent=p
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

  marker("CourtEntrance",nil,V(1000,2.15,1498),{"Enter the charter court","เข้าลานรับรองหอคอย"},function()
   if player:GetAttribute("CurrentZone")~="Ashen"or e.trial then return end
   local c=player.Character;local r=root(player)
   if c and r then c:PivotTo(CFrame.new(art.entry));r.AssemblyLinearVelocity=V(0,0,0);deps.World.RefreshCampaignCompanions(player)end
  end)
  marker("CourtExit",nil,art.exit.Position,{"Return to Ashen surface","กลับสู่แอชเชนด้านนอก"},function()stopActivity(e);deps.World.IntentCommitted(player,"TravelZone",{zone="Ashen"})end)
  local lessons={
   {"Read the current quest before setting out.","อ่านภารกิจปัจจุบันก่อนออกเดินทาง"},
   {"Follow the marked route; every station is reachable on foot.","ตามเส้นทางที่ทำเครื่องหมาย ทุกสถานีเดินถึงได้"},
   {"Guild Hall upgrades raise the level cap.","อัปเกรด Hall เพื่อเพิ่มเพดานเลเวล"},
   {"Permits require story progress plus materials and Gold.","สิทธิ์อัปเกรดต้องผ่านเนื้อเรื่อง พร้อมวัสดุและ Gold"},
   {"Checkpoint five records the first half after saving succeeds.","จุดที่ห้าเก็บผลครึ่งแรกเมื่อบันทึกสำเร็จ"},
   {"Shield before an impact; recover after it.","กางโล่ก่อนโดนโจมตี ฟื้นฟูหลังโดนโจมตี"},
   {"Warning shapes and words accompany their colors.","สัญญาณมีรูปทรงและข้อความกำกับสี"},
   {"An escort waits when you move too far away.","ผู้ร่วมทางจะรอเมื่อเจ้าเดินห่างเกินไป"},
   {"Past choices stay in your guild's history.","ตัวเลือกที่ผ่านมาเก็บอยู่ในประวัติกิลด์"},
   {"These stations prepare you; combat Tower floors are a separate run.","สถานีเหล่านี้เตรียมความพร้อม ชั้นหอคอยต่อสู้เป็นอีกรอบหนึ่ง"},
  }
  for i=1,10 do
   local id=if i<=5 then "reach_tower_checkpoint_five"else "finish_tower_orientation"
   local first=if i<=5 then 1 else 6;local order={};for n=first,first+4 do table.insert(order,tostring(n))end
   objective("charter_gate","checkpoint_"..i,id,function()sequence(id,tostring(i),order)end,{"Station "..i.." · "..lessons[i][1],"สถานี "..i.." · "..lessons[i][2]})
   e.markers[#e.markers].action={"Read station "..i,"อ่านสถานี "..i}
  end
  objective("charter_gate","route_chart","collect_tower_chart")
  objective("charter_gate","council","confirm_tower_charter")
  local function lesson(point:string,id:string,role:string)
   objective("guardian_school",point,id,function()
    if e.lesson then local state=e.lesson.Snapshot();if state and state.status=="Active"then return end;e.lesson.Destroy()end
    e.lesson=makeLesson({Parent=art.model})
    local origin=art.scenes.guardian_school:GetPivot().Position
    local ok=e.lesson.Start(player,origin,role,function():any
     local live=current(player,e);local r=root(player)
     return {current=live~=nil and nextId(live.record.data)==id,alive=r~=nil,near=r~=nil and (r.Position-origin).Magnitude<40,language=live and live.record.data.settings.language}
    end,function()observe(player,e,id)end)
    if not ok then e.lesson.Destroy();e.lesson=nil end
   end,{"Start / retry "..role.." lesson","เริ่ม / ลองบทฝึก"..(if role=="Guard"then "ป้องกัน"elseif role=="Mend"then "ฟื้นฟู"else "สลับบทบาท")})
  end
  lesson("guard_trial","try_guardian_guard","Guard");lesson("mend_trial","try_guardian_roles","Mend")
  local rules={{"Shield before impact","โล่ก่อนโดนโจมตี"},{"Heal after impact","ฟื้นฟูหลังโดนโจมตี"},{"Follow the marked trainee","ตามหุ่นที่มีสัญญาณ"}}
  for i=1,3 do checked("guardian_school","rule_"..i,"read_guardian_rules",tostring(i),3);e.markers[#e.markers].label=rules[i]end
  lesson("defense_trial","complete_guardian_defense","Combined")
  objective("hidden_archive","hidden_exit","find_hidden_archive")
  note("hidden_archive",V(0,13,10),{"solve_archive_sequence"},{"Archive order: CROSS → TRIANGLE → DIAMOND.","ลำดับหอจดหมายเหตุ: กากบาท → สามเหลี่ยม → ข้าวหลามตัด"})
  for i,symbol in ipairs(tasks.Signal.Sequence)do objective("hidden_archive","sequence_"..i,"solve_archive_sequence",function()sequence("solve_archive_sequence",symbol,{"cross","triangle","diamond"})end,{"Read "..tasks.Signal.Symbols[symbol],"อ่าน "..tasks.Signal.Symbols[symbol]})end
  objective("hidden_archive","archive_record","recover_archive_chart")
  local memories={"caravan_memory","timber_memory","guild_memory"}
  for i,point in ipairs(memories)do checked("memory_chamber",point,"read_guild_memories",tostring(i),3)end
  note("memory_chamber",V(0,16,0),{"read_guild_memories"},function(data:any):any
   local novice=data.progression.novice;local choices=data.progression.campaign.choices
   local caravan=novice and novice.branch
   local enCaravan=if caravan=="rescue"then "You rescued the caravan's people."elseif caravan=="supplies"then "You recovered the caravan's supplies."else "The caravan record is unavailable."
   local thCaravan=if caravan=="rescue"then "เจ้าเลือกช่วยผู้คนในขบวน"elseif caravan=="supplies"then "เจ้าเลือกกู้เสบียงของขบวน"else "ไม่มีบันทึกตัวเลือกขบวน"
   local enTimber=if choices.allocate_timber=="workers"then "You supported the workers."else "You supplied the town."
   local thTimber=if choices.allocate_timber=="workers"then "เจ้าจัดไม้ให้คนงาน"else "เจ้าจัดไม้ให้เมือง"
   local names={courage={"courage","ความกล้า"},together={"togetherness","การร่วมแรง"},discovery={"discovery","การค้นพบ"}}
   local motto=names[choices.choose_motto]or {"unrecorded","ไม่มีบันทึก"}
   return {enCaravan.."\n"..enTimber.."\nFounding oath: "..motto[1],thCaravan.."\n"..thTimber.."\nคำมั่นก่อตั้ง: "..motto[2]}
  end)
  escort("memory_chamber","help_memory","rescue_memory_echo","memory_echo",function()
   local o=art.scenes.memory_chamber:GetPivot().Position;return {o+V(16,0,12),o+V(0,0,12),o+V(0,0,6)}
  end)
  for _,choice in ipairs({"courage","compassion"})do objective("memory_chamber","oath_"..choice,"renew_tower_oath",function()observe(player,e,"renew_tower_oath",choice)end,if choice=="courage"then {"Choose courage · same reward","เลือกความกล้า · รางวัลเท่ากัน"}else {"Choose compassion · same reward","เลือกเมตตา · รางวัลเท่ากัน"})end
  local clues={{"Both doors lead to the same record.","ทั้งสองประตูไปยังบันทึกเดียวกัน"},{"The sun door leaves the west bypass open.","ประตูดวงอาทิตย์เปิดทางอ้อมตะวันตกไว้"},{"The moon door leaves the east bypass open.","ประตูดวงจันทร์เปิดทางอ้อมตะวันออกไว้"}}
  for i=1,3 do checked("twin_doors","door_clue_"..i,"read_twin_door_clues",tostring(i),3);e.markers[#e.markers].label=clues[i]end
  for _,choice in ipairs({"sun","moon"})do objective("twin_doors",choice.."_door","choose_tower_door",function()observe(player,e,"choose_tower_door",choice)end,if choice=="sun"then {"Open the sun door first","เปิดประตูดวงอาทิตย์ก่อน"}else {"Open the moon door first","เปิดประตูดวงจันทร์ก่อน"})end
  for _,side in ipairs({"left","right"})do
   objective("twin_doors","bypass_"..side,"follow_tower_bypass",function()e.bypass=true;feedback("Now reach the record behind the doors.","ไปถึงบันทึกด้านหลังประตู")end,{"Follow the side passage","ตามทางเดินด้านข้าง"})
   e.markers[#e.markers].active=function(data:any)return not e.bypass and (if data.progression.campaign.choices.choose_tower_door=="sun"then side=="left"else side=="right")end
  end
  objective("twin_doors","bypass_record","follow_tower_bypass");e.markers[#e.markers].active=function()return e.bypass==true end
  objective("first_ledger","records_guardian","complete_records_guardian",function(data:any)
   if e.trial then return end;e.trialDelivery=nil
   e.trial=require(script.Parent.NoviceTrialArena)(player,data,data.character.classId,Http:GenerateGUID(false),art.origin+V(0,32,-100),function(receipt:any)
    if e.trialDelivery=="Committed"then return true end
    observe(player,e,"complete_records_guardian",nil,receipt);return false
   end,function()if e.trial then e.trial.Destroy();e.trial=nil end end,require(script.Parent.TowerGuardianFactory)())
  end)
  objective("first_ledger","copy_ledger","copy_first_ledger")
  local seals={{"Human council certification","ตรารับรองสภามนุษย์"},{"Dwarf records certification","ตรารับรองจดหมายเหตุคนแคระ"},{"Elf archive certification","ตรารับรองหอสมุดเอลฟ์"}}
  for i=1,3 do checked("first_ledger","city_seal_"..i,"earn_three_city_seals",tostring(i),3);e.markers[#e.markers].label=seals[i]end
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
     if e.pendingObjective=="complete_records_guardian"then e.trialDelivery="Committed"end
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
    if state.reason=="MeetAtExit"then e.message={"Meet the echo at the oath circle.","ไปพบภาพความทรงจำที่วงคำมั่น"};e.messageUntil=clock()+.3
    elseif state.reason=="WaitForOwner"then e.message={"The echo is waiting. Move closer.","ภาพความทรงจำกำลังรอ เดินเข้าไปใกล้"};e.messageUntil=clock()+.3
    elseif state.status=="Failed"or state.status=="Cancelled"then e.message={"Return to the echo's start to retry.","กลับจุดเริ่มภาพความทรงจำเพื่อลองใหม่"};e.messageUntil=clock()+.3 end
   end
   for _,m in ipairs(e.markers)do
    local active=(not m.id or id==m.id)and (not m.active or m.active(data))
    m.part.Transparency=if active then .25 else 1;m.board.Enabled=active
    m.prompt.Enabled=active and current(player,e)~=nil and not e.pending and not e.trial and (not m.id or ready(player,e,m.id))
    local text=m.label[index]
    if m.id and e.message and clock()<(e.messageUntil or 0)then text=text.."\n"..e.message[index]end
    m.text.Text=text;m.prompt.ActionText=(m.action or m.label)[index];m.prompt.ObjectText=if th then "หอคอย · บท 4"else "Tower · Chapter 4"
   end
   for _,n in ipairs(e.notes)do local copy=if type(n.copy)=="function"then n.copy(data)else n.copy;n.board.Enabled=id~=nil and table.find(n.ids,id)~=nil;n.label.Text=copy[index]end
  end
 end)
 function S.Destroy()heartbeat:Disconnect();for player in pairs(entries)do S.Remove(player)end end
 return S
end
