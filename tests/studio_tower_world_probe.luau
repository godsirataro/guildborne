--!strict
-- Fake session and relocated prompt fixtures only. No real player progression.
return function(factory:any,config:any):any
 local player=assert(game.Players:GetPlayers()[1]);local character=assert(player.Character)
 local root=assert(character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local data:any={settings={language="th"},character={classId="Mage",level=70},personalGuild={buildings={guildHall=10}},progression={novice={branch="rescue"},campaign={claimed=18,objectives={},choices={allocate_timber="workers",choose_motto="courage"}}}}
 local session:any={record={data=data},state="Active",epoch=1,token="fixture"}
 local callbacks:{[string]:any}={};local receipts={};local clock=100;local retry=true;local moved=0;local notices=0
 local beat=Instance.new("BindableEvent")
 local service=factory({Data={Sessions={[player.UserId]=session},FlushAudit=function()end},Config=config,Now=function()return clock end,Heartbeat=beat.Event,
  BindPrompt=function(prompt:ProximityPrompt,callback:any)callbacks[prompt.Name]={prompt=prompt,callback=callback};return {Disconnect=function()end}end,
  World={RefreshCampaignCompanions=function()moved+=1 end,IntentCommitted=function()moved+=1 end},
  MakeReceipt=function(owner,receipt)
   assert(owner==player.UserId and receipt.owner==owner and receipt.action=="CampaignObjective")
   return function()
    if retry then retry=false;return "Retry","SavePending"end
    table.insert(receipts,receipt);data.progression.campaign.objectives[receipt.args.objective]=true
    if receipt.args.choice then data.progression.campaign.choices[receipt.args.objective]=receipt.args.choice end
    return "Committed","OK"
   end
  end,Notify=function()notices+=1 end})
 local initial=character:GetPivot()
 local function tick()clock+=1;beat:Fire(.25);task.wait(.03)end
 local function click(name:string,near:boolean?,who:any?)
  local entry=assert(callbacks["Tower_"..name],name);local part=entry.prompt.Parent :: BasePart;local pos=part.Position
  if near then part.Position=root.Position-Vector3.new(0,2,0)end
  entry.callback(who or player);part.Position=pos;tick();tick()
 end
 local function stage(claimed:number,objectives:any?)data.progression.campaign.claimed=claimed;data.progression.campaign.objectives=objectives or {};tick()end
 local ok,result=pcall(function():any
  service.Update(player);tick();local count=0;for _ in pairs(callbacks)do count+=1 end;assert(count==44,"Count "..count)
  click("reach_tower_checkpoint_five_checkpoint_1",false);click("reach_tower_checkpoint_five_checkpoint_1",true,{});assert(#receipts==0)
  session.busy=true;click("reach_tower_checkpoint_five_checkpoint_1",true);session.busy=false;tick();assert(#receipts==0)
  click("reach_tower_checkpoint_five_checkpoint_5",true);assert(#receipts==0)
  for i=1,5 do click("reach_tower_checkpoint_five_checkpoint_"..i,true)end;assert(#receipts==1)
  -- Rebuild the scene using the fake committed objective: first half remains done.
  local stale=callbacks.Tower_reach_tower_checkpoint_five_checkpoint_1
  service.Remove(player);callbacks={};service.Update(player);tick();stale.callback(player);tick();assert(#receipts==1)
  assert(not callbacks.Tower_reach_tower_checkpoint_five_checkpoint_1.prompt.Enabled)
  assert(callbacks.Tower_finish_tower_orientation_checkpoint_6.prompt.Enabled)
  click("finish_tower_orientation_checkpoint_10",true);assert(#receipts==1)
  for i=6,10 do click("finish_tower_orientation_checkpoint_"..i,true)end
  click("collect_tower_chart_route_chart",true);click("confirm_tower_charter_council",true);assert(#receipts==4)
  stage(19)
  click("try_guardian_guard_guard_trial",true);assert(#receipts==4,"Distant owner entered lesson")
  -- Support and guardian combat are covered separately; no fabricated completion callback.
  data.progression.campaign.objectives.try_guardian_guard=true;data.progression.campaign.objectives.try_guardian_roles=true;tick()
  for i=1,3 do click("read_guardian_rules_rule_"..i,true)end;assert(#receipts==5)
  stage(20);click("find_hidden_archive_hidden_exit",true)
  click("solve_archive_sequence_sequence_2",true);assert(#receipts==6)
  for _,i in ipairs({3,1,2})do click("solve_archive_sequence_sequence_"..i,true)end
  click("recover_archive_chart_archive_record",true);assert(#receipts==8)
  stage(21)
  local parent=workspace:FindFirstChild("GuildborneWorld")or workspace
  local court=assert(parent:FindFirstChild("TowerCourt_"..player.UserId))
  assert(court:FindFirstChild("memory_chamber"))
  local checkedMemories=0
  for _,language in ipairs({"en","th"})do for _,branch in ipairs({"rescue","supplies"})do for _,motto in ipairs({"courage","together","discovery"})do
   data.settings.language=language;data.progression.novice.branch=branch;data.progression.campaign.choices.choose_motto=motto;tick()
   local words={courage={"courage","ความกล้า"},together={"togetherness","การร่วมแรง"},discovery={"discovery","การค้นพบ"}}
   local found=false
   for _,v in ipairs(court:GetDescendants())do if v:IsA("TextLabel")and v.Text:find(words[motto][if language=="th"then 2 else 1],1,true)and v.Text:find(if language=="th"then "คำมั่นก่อตั้ง"else "Founding oath",1,true)then found=true end end
   assert(found,"Missing saved memory "..language.." "..motto);checkedMemories+=1
  end end end
  data.settings.language="th";data.progression.novice.branch="rescue";data.progression.campaign.choices.choose_motto="courage";tick()
  for i,point in ipairs({"caravan_memory","timber_memory","guild_memory"})do click("read_guild_memories_"..point,true)end
  click("rescue_memory_echo_help_memory",true);assert(#receipts==9,"Distant owner completed escort")
  data.progression.campaign.objectives.rescue_memory_echo=true;tick();click("renew_tower_oath_oath_compassion",true)
  assert(data.progression.campaign.choices.choose_motto=="courage"and data.progression.campaign.choices.renew_tower_oath=="compassion")
  stage(22)
  for i=1,3 do click("read_twin_door_clues_door_clue_"..i,true)end
  click("choose_tower_door_moon_door",true)
  click("follow_tower_bypass_bypass_record",true);click("follow_tower_bypass_bypass_left",true);click("follow_tower_bypass_bypass_record",true);assert(#receipts==12)
  click("follow_tower_bypass_bypass_right",true);click("follow_tower_bypass_bypass_record",true);assert(#receipts==13)
  stage(23,{complete_records_guardian=true});click("copy_first_ledger_copy_ledger",true)
  for i=1,3 do click("earn_three_city_seals_city_seal_"..i,true)end;assert(#receipts==15)
  local model=assert(parent:FindFirstChild("TowerCourt_"..player.UserId))
  session.epoch=2;tick();assert(not model.Parent)
  assert(moved==0 and (character:GetPivot().Position-initial.Position).Magnitude<1)
  return {prompts=count,privateReceipts=#receipts,notifications=notices,syntheticCheckpointRebuilds=1,bilingualMemoryCombinations=checkedMemories,profileWrites=0,actualPlayerJourney=false,worldMovementCalls=moved}
 end)
 service.Destroy();beat:Destroy();if not ok then error(result)end;return result
end
