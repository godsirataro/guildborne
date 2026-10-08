--!strict
-- Optional Chapter03 adapter. Server measurements produce private, retryable receipts.
local Players=game:GetService("Players");local Run=game:GetService("RunService");local Http=game:GetService("HttpService")
local V=Vector3.new
local makeArt=require(script.Parent.AshenCourtArt)
local makeCast=require(script.Parent.AshenCharacterKit)
local tasks=require(script.Parent.Parent.Config.IronveilTasks)
local makePuzzle=require(script.Parent.Parent.Systems.IronveilPuzzle)
local makeProtection=require(script.Parent.Parent.Systems.IronveilProtection)
local makeEscort=require(script.Parent.EscortActor)
return function(deps:any)
 local S={};local entries:{[Player]:any}={};local occupied={}
 local function session(player:Player):any?
  local s=deps.Data.Sessions[player.UserId];local d=s and s.record and s.record.data
  if not s or s.closing or not d or not d.progression.campaign then return nil end
  local claimed=d.progression.campaign.claimed
  return if claimed>=12 and claimed<18 and d.personalGuild.buildings.guildHall>=4 then s else nil
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
  e.pending=deps.MakeReceipt(player.UserId,receipt or {owner=player.UserId,requestId="ashen:"..Http:GenerateGUID(false),action="CampaignObjective",args={objective=id,choice=choice}})
  e.pendingObjective=id
 end
 local function stopActivity(e:any)
  if e.escort then e.escort.Destroy();e.escort=nil end
  if e.protection then e.protection.cancel();e.protection=nil end
 end
 function S.Remove(player:Player)
  local e=entries[player];if not e then return end
  entries[player]=nil;occupied[e.slot]=nil;stopActivity(e)
  local r=root(player)
  if r and math.abs(r.Position.Y-e.art.origin.Y)<45 and (Vector2.new(r.Position.X,r.Position.Z)-Vector2.new(1000,1400)).Magnitude<165 then deps.World.IntentCommitted(player,"TravelZone",{zone="Ashen"})end
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
  local offsets={gatekeeper=V(-67,0,57),survivor=V(68,0,73),bridgewright=V(-55,0,14),witness=V(55,0,4)}
  for _,actor in ipairs(actors:GetChildren())do if actor:IsA("Model")then
   actor:PivotTo(CFrame.new(art.origin+offsets[actor.Name])*CFrame.Angles(0,math.pi,0));e.actors[actor.Name]=actor
   game:GetService("CollectionService"):AddTag(actor,"GuildborneFriendlyNPC")
  end end
  local worker=e.actors.survivor:Clone();worker.Name="guarded_worker";worker:PivotTo(CFrame.new(art.origin+V(77,0,-47)));worker.Parent=actors;e.actors.guarded_worker=worker
  game:GetService("CollectionService"):AddTag(worker,"GuildborneFriendlyNPC")
  local function feedback(en:string,th:string)e.message={en,th};e.messageUntil=os.clock()+2.5 end
  local function marker(name:string,id:string?,position:Vector3,label:any,callback:any,active:any?)
   local p=Instance.new("Part");p.Name=name;p.Size=V(2,.15,2);p.Position=position;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(214,174,78);p.Parent=art.model
   local prompt=Instance.new("ProximityPrompt");prompt.Name="Ashen_"..name;prompt.MaxActivationDistance=7;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.R;prompt.GamepadKeyCode=Enum.KeyCode.ButtonY;prompt.Enabled=false;prompt.Parent=p
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
  marker("CourtEntrance",nil,V(1000,2.15,1498),{"Enter the lost city","เข้าเขตเมืองที่สาบสูญ"},function()
   if player:GetAttribute("CurrentZone")~="Ashen"then return end
   local c=player.Character;local r=root(player)
   if c and r then c:PivotTo(CFrame.new(art.entry));r.AssemblyLinearVelocity=V(0,0,0);deps.World.RefreshCampaignCompanions(player)end
  end)
  marker("CourtExit",nil,art.exit.Position,{"Return to Ashen surface","กลับสู่แอชเชนด้านนอก"},function()stopActivity(e);deps.World.IntentCommitted(player,"TravelZone",{zone="Ashen"})end)
  for i=1,3 do checked("caravan_checkpoint","supply_trace_"..i,"follow_ashen_supplies",tostring(i),3)end
  escort("caravan_checkpoint","gatekeeper","help_ashen_gatekeeper","gatekeeper",function()
   local o=art.scenes.caravan_checkpoint:GetPivot().Position
   return {o+V(-12,0,-8),o+V(-12,0,0),o}
  end)
  objective("caravan_checkpoint","permit_ledger","request_ashen_charter")
  for i=1,3 do checked("memory_hearth","memory_"..i,"preserve_hearth_traces",tostring(i),3)end
  note("memory_hearth",V(0,13,-13),{"arrange_hearth_memories"},{"Read the memories: TRIANGLE → DIAMOND → CROSS. The plaques stay in place.","เรียงความทรงจำ: สามเหลี่ยม → ข้าวหลามตัด → กากบาท ป้ายยังคงอยู่ในฉาก"})
  for i,symbol in ipairs(tasks.Signal.Sequence)do objective("memory_hearth","memory_"..i,"arrange_hearth_memories",function()sequence("arrange_hearth_memories",symbol,tasks.Signal.Sequence)end,{"Memory "..tasks.Signal.Symbols[symbol],"ความทรงจำ "..tasks.Signal.Symbols[symbol]})end
  objective("memory_hearth","survivor","meet_hearth_survivor",function()e.actors.survivor:SetAttribute("GreetingAt",workspace:GetServerTimeNow());observe(player,e,"meet_hearth_survivor")end)
  for i=1,3 do checked("ash_bridge","support_"..i,"secure_bridge_supports",tostring(i),3)end
  for _,choice in ipairs({"sheltered","direct"})do
   objective("ash_bridge",choice.."_route","choose_bridge_route",function()observe(player,e,"choose_bridge_route",choice)end,if choice=="sheltered"then {"Use the sheltered route · same reward","ใช้ทางมีที่กำบัง · รางวัลเท่ากัน"}else {"Use the direct route · same reward","ใช้ทางตรง · รางวัลเท่ากัน"})
  end
  escort("ash_bridge","bridgewright","escort_bridgewright","bridgewright",function(data)
   local o=art.scenes.ash_bridge:GetPivot().Position;local x=if data.progression.campaign.choices.choose_bridge_route=="sheltered"then -20 else 20
   return {o+V(0,0,14),o+V(0,0,19),o+V(x,0,19),o+V(x,0,13)}
  end)
  local questions={
   {{"Ask about the crest","ถามเรื่องตรา"},{"The false crest was stamped at the bell tower.","ตราปลอมถูกประทับที่หอระฆัง"}},
   {{"Ask about the cargo","ถามเรื่องเสบียง"},{"The cargo was meant for survivors, not the warden.","เสบียงส่งถึงผู้รอดชีวิต ไม่ใช่ผู้พิทักษ์"}},
   {{"Ask about the witness","ถามเรื่องพยาน"},{"I stayed to guide the missing caravan home.","ข้าอยู่ต่อเพื่อนำขบวนที่หายไปกลับบ้าน"}},
  }
  note("witness_court",V(0,10,-10),{"question_ashen_witness","verify_ashen_testimony"},{"Witness record: the false crest came from the bell tower. The supplies belong to survivors. The witness stayed to guide the caravan home.","บันทึกพยาน: ตราปลอมมาจากหอระฆัง เสบียงเป็นของผู้รอดชีวิต พยานอยู่ต่อเพื่อนำขบวนกลับบ้าน"})
  for i,q in ipairs(questions)do
   objective("witness_court","testimony_"..i,"question_ashen_witness",function()
    set("question_ashen_witness",tostring(i),3);feedback(q[2][1],q[2][2]);e.actors.witness:SetAttribute("GreetingAt",workspace:GetServerTimeNow())
   end,q[1])
   e.markers[#e.markers].active=function()return not (e.sets.question_ashen_witness or {})[tostring(i)]end
  end
  objective("witness_court","witness","verify_ashen_testimony")
  for _,choice in ipairs({"trust","guard"})do
   objective("witness_court",choice.."_route","choose_witness_route",function()observe(player,e,"choose_witness_route",choice)end,if choice=="trust"then {"Trust the witness · same reward","เชื่อใจพยาน · รางวัลเท่ากัน"}else {"Continue the escort · same reward","คุ้มกันต่อ · รางวัลเท่ากัน"})
  end
  note("bell_tower",V(0,18,-9),{"tune_ashen_bells"},{"Tune the bell: DIAMOND → CROSS → TRIANGLE.","ปรับระฆัง: ข้าวหลามตัด → กากบาท → สามเหลี่ยม"})
  for i,symbol in ipairs(tasks.Signal.Sequence)do objective("bell_tower","tuning_"..i,"tune_ashen_bells",function()sequence("tune_ashen_bells",symbol,{"diamond","cross","triangle"})end,{"Tune "..tasks.Signal.Symbols[symbol],"ปรับ "..tasks.Signal.Symbols[symbol]})end
  objective("bell_tower","courier","send_ashen_dispatch")
  for i=1,3 do checked("warden_seals","binding_"..i,"break_ashen_bindings",tostring(i),3)end
  objective("warden_seals","civilian","protect_ashen_survivor",function()
   if e.protection and e.protection.snapshot().status=="Active"then return end
   e.protection=makeProtection(tasks.Protection,os.clock())
  end,{"Start / retry survivor safety wards","เริ่ม / ลองเปิดเกราะคุ้มครองผู้รอดชีวิต"})
  for i,lane in ipairs(tasks.Protection.Lanes)do
   objective("warden_seals","binding_"..i,"protect_ashen_survivor",function()
    if not e.protection then return end
    local ok=e.protection.block(lane,os.clock());if not ok then feedback("Use the ward with the warning.","ใช้เกราะช่องที่มีสัญญาณเตือน")end
   end,{"Safety ward "..i,"เกราะคุ้มครอง "..i})
   e.markers[#e.markers].lane=lane
  end
  art.model.Parent=workspace:FindFirstChild("GuildborneWorld")or workspace
  game:GetService("CollectionService"):AddTag(art.model,"GuildborneMineActivity")
 end
 function S.Victory(player:Player,ticket:any)
  local e=entries[player];if not e or ticket.owner~=player.UserId or player:GetAttribute("CurrentZone")~="Ashen"then return end
  local id=if ticket.encounterId=="rune_caster"then "survive_bell_wave"elseif ticket.encounterId=="arcane_warden"then "defeat_ashen_warden"else nil
  if not id or not ready(player,e,id)then return end
  local r=root(player);if not r or r.Position.Y>35 then return end
  local participating=false;local living=false;local nearest:number?=nil
  for _,member in ipairs(ticket.members)do if member~="player"then
   participating=true
   local actor=deps.World.CompanionEvidence(player,member)
   if actor and actor.health>0 then
    living=true;local distance=(actor.position-r.Position).Magnitude
    nearest=math.min(nearest or math.huge,distance)
    if distance<=30 then
     e.art.model:SetAttribute("LastVictoryProblem",nil);e.art.model:SetAttribute("LastVictoryCompanionDistance",distance)
     observe(player,e,id);return
    end
   end
  end end
  -- Keep one diagnostic, not a growing death log. These measurements never grant credit.
  local problem=if not participating then "CampaignCompanionParticipation"elseif not living then "CampaignCompanionUnavailable"else "CampaignCompanionTooFar"
  e.art.model:SetAttribute("LastVictoryProblem",problem)
  e.art.model:SetAttribute("LastVictoryCompanionDistance",nearest)
  deps.Notify(player,problem)
 end
 local elapsed=0
 local heartbeat=Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  for player,e in pairs(entries)do
   local s=session(player)
   if not s or s.epoch~=e.epoch or s.token~=e.token or player.Parent~=Players then S.Remove(player);continue end
   if e.pending and os.clock()>=(e.deliveryAt or 0)then
    e.deliveryAt=os.clock()+.5;local outcome,problem=e.pending();e.art.model:SetAttribute("DeliveryProblem",problem)
    if outcome=="Committed"then e.pending=nil;deps.Notify(player);deps.Data.FlushAudit(player.UserId)
    elseif outcome=="Rejected"then e.puzzles[e.pendingObjective]=nil;e.sets[e.pendingObjective]=nil;stopActivity(e);e.pending=nil end
   end
   if entries[player]~=e then continue end
   local data=s.record.data;local id=nextId(data);local th=data.settings.language=="th";local index=if th then 2 else 1
   if e.objective~=id then stopActivity(e);e.objective=id;e.message=nil end
   e.art.model:SetAttribute("EscortStatus",if e.escort then e.escort.Snapshot().status else nil)
   e.art.model:SetAttribute("EscortPosition",if e.escort then e.escortActor:GetPivot().Position else nil)
   e.art.model:SetAttribute("EscortExit",if e.escort then e.escortExit else nil)
   if e.escort then
    local state=e.escort.Snapshot()
    if state.reason=="MeetAtExit"then e.message={"Meet your companion at the safe point.","ไปพบผู้ร่วมทางที่จุดปลอดภัย"};e.messageUntil=os.clock()+.3
    elseif state.reason=="WaitForOwner"then e.message={"Your companion is waiting. Move closer.","ผู้ร่วมทางกำลังรอ เดินเข้าไปใกล้"};e.messageUntil=os.clock()+.3
    elseif state.status=="Failed"or state.status=="Cancelled"then e.message={"Return to the start marker to retry.","กลับจุดเริ่มต้นเพื่อลองใหม่"};e.messageUntil=os.clock()+.3 end
   end
   if e.protection then
    local r=root(player);local near=r and math.abs(r.Position.Y-e.art.origin.Y)<10 and (r.Position-e.art.origin).Magnitude<165
    local state=e.protection.step(os.clock(),near~=nil and near~=false,current(player,e)~=nil)
    local snapshot=e.protection.snapshot();local warning=snapshot.warning;local position=nil
    if warning then for _,m in ipairs(e.markers)do if m.lane==warning.lane then position=m.part.Position;break end end end
    e.art.model:SetAttribute("ProtectionStatus",state);e.art.model:SetAttribute("ProtectionWarningPosition",position)
    e.art.model:SetAttribute("ProtectionWarningBlocked",warning and warning.blocked or false)
    e.art.model:SetAttribute("ProtectionImpactAt",if warning then workspace:GetServerTimeNow()+math.max(0,warning.impactAt-os.clock())else nil)
    e.actors.guarded_worker:SetAttribute("ProtectedHealth",snapshot.health)
    if state=="Completed"then observe(player,e,"protect_ashen_survivor")
    elseif state=="Failed"then e.message={"Safety wards failed. Retry at the survivor.","เกราะป้องกันไม่สำเร็จ ลองใหม่ที่ผู้รอดชีวิต"};e.messageUntil=os.clock()+.3
    elseif state=="Active"then e.message={"Protect the marked ward · "..snapshot.blocks.."/3","เปิดเกราะช่องที่เตือน · "..snapshot.blocks.."/3"};e.messageUntil=os.clock()+.3 end
   else for _,attribute in ipairs({"ProtectionStatus","ProtectionWarningPosition","ProtectionWarningBlocked","ProtectionImpactAt"})do e.art.model:SetAttribute(attribute,nil)end end
   for _,m in ipairs(e.markers)do
    local active=(not m.id or id==m.id)and (not m.active or m.active(data))
    m.part.Transparency=if active then .25 else 1;m.board.Enabled=active
    m.prompt.Enabled=active and current(player,e)~=nil and not e.pending and (not m.id or ready(player,e,m.id))
    local text=m.label[index];local warning=e.protection and e.protection.snapshot().warning
    local urgent=m.lane and warning and warning.lane==m.lane and not warning.blocked
    m.part.Color=if urgent then Color3.fromRGB(242,107,67)else Color3.fromRGB(157,124,201)
    if urgent then text=text..(if th then " · เปิดตอนนี้"else " · ACTIVATE NOW")end
    if m.id and not m.lane and e.message and os.clock()<(e.messageUntil or 0)then text=text.."\n"..e.message[index]end
    m.text.Text=text;m.prompt.ActionText=m.label[index];m.prompt.ObjectText=if th then "แอชเชน · บท 3"else "Ashen · Chapter 3"
   end
   for _,n in ipairs(e.notes)do n.board.Enabled=id~=nil and table.find(n.ids,id)~=nil;n.label.Text=n.copy[index]end
  end
 end)
 function S.Destroy()heartbeat:Disconnect();for player in pairs(entries)do S.Remove(player)end end
 return S
end
