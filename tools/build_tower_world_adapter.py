"""Build the staged Chapter04 adapter from the established court lifecycle."""
from pathlib import Path
r=Path(__file__).resolve().parents[1]
s=(r/'src/server/Services/AshenWorld.luau').read_text(encoding='utf-8')
s=s[:s.index('  marker("CourtEntrance"')]
s=s.replace('Optional Chapter03','Staged Chapter04').replace('AshenCourtArt','TowerCourtArt').replace('AshenCharacterKit','TowerCharacterKit')
s=s.replace('local makeProtection=require(script.Parent.Parent.Systems.IronveilProtection)','local makeLesson=require(script.Parent.TowerLessonArena)')
s=s.replace('local S={};local entries', 'local clock=deps.Now or os.clock;local heartbeatSource=deps.Heartbeat or Run.Heartbeat\n local S={};local entries')
s=s.replace('claimed>=12 and claimed<18','claimed>=18 and claimed<24').replace('guildHall>=4','guildHall>=7')
s=s.replace('"ashen:"','"tower:"').replace('"Ashen_"','"Tower_"')
s=s.replace('  if e.protection then e.protection.cancel();e.protection=nil end','  if e.lesson then e.lesson.Destroy();e.lesson=nil end\n  if e.trial then e.trial.Destroy();e.trial=nil end')
s=s.replace('Vector2.new(1000,1400)).Magnitude<165','Vector2.new(2000,1400)).Magnitude<240')
start=s.index('  local offsets=');end=s.index('  local function feedback',start)
s=s[:start]+'''  local offsets={charter_warden=V(-80,0,90),archivist=V(-56,0,12),council_clerk=V(-56,0,93),bookbinder=V(106,0,-92)}
  for _,actor in ipairs(actors:GetChildren())do if actor:IsA("Model")then
   actor:PivotTo(CFrame.new(art.origin+offsets[actor.Name])*CFrame.Angles(0,math.pi,0));e.actors[actor.Name]=actor
   game:GetService("CollectionService"):AddTag(actor,"GuildborneFriendlyNPC")
  end end
  local echo=e.actors.bookbinder:Clone();echo.Name="memory_echo";echo:PivotTo(CFrame.new(art.origin+V(96,0,12)));echo.Parent=actors;e.actors.memory_echo=echo
  game:GetService("CollectionService"):AddTag(echo,"GuildborneFriendlyNPC")
''' + s[end:]
s=s.replace('table.insert(e.connections,prompt.Triggered:Connect(function(who)','local function trigger(who:Player)')
s=s.replace('    callback(live.record.data)\n   end))','    callback(live.record.data)\n   end\n   table.insert(e.connections,if deps.BindPrompt then deps.BindPrompt(prompt,trigger)else prompt.Triggered:Connect(trigger))')
s=s.replace('"MineInstructions"','"TowerInstructions"')
s+=r'''
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
    if state.reason=="MeetAtExit"then feedbackForEscort=true end
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
'''
s=s.replace('    if state.reason=="MeetAtExit"then feedbackForEscort=true end\n','')
s=s.replace('os.clock()', 'clock()')
(r/'src/server/Services/TowerWorld.luau').write_text(s,encoding='utf-8')
print('TowerWorld staged adapter generated')
