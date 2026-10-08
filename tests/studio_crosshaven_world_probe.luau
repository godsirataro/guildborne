--!strict
-- Fake session and relocated prompt fixtures only. No real player progression.
return function(factory:any,config:any):any
 local player=assert(game.Players:GetPlayers()[1]);local character=assert(player.Character)
 local root=assert(character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local data:any={settings={language="th"},character={classId="Mage",level=85},personalGuild={buildings={guildHall=14}},progression={novice={branch="rescue"},campaign={claimed=24,objectives={},choices={allocate_timber="workers",choose_motto="courage"}}}}
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
  local entry=assert(callbacks["Crosshaven_"..name],name);local part=entry.prompt.Parent :: BasePart;local pos=part.Position
  if near then part.Position=root.Position-Vector3.new(0,2,0)end
  entry.callback(who or player);part.Position=pos;tick();tick()
 end
 local function stage(claimed:number,objectives:any?)data.progression.campaign.claimed=claimed;data.progression.campaign.objectives=objectives or {};tick()end
 local ok,result=pcall(function():any
  service.Update(player);tick();local count=0;for _ in pairs(callbacks)do count+=1 end;assert(count==44,"Count "..count)
  click("meet_crosshaven_mentor_mentor",false);click("meet_crosshaven_mentor_mentor",true,{});assert(#receipts==0)
  session.busy=true;click("meet_crosshaven_mentor_mentor",true);session.busy=false;tick();assert(#receipts==0)
  data.character.level=69;tick();click("meet_crosshaven_mentor_mentor",true);assert(#receipts==0);data.character.level=85;tick()
  click("meet_crosshaven_mentor_mentor",true);assert(#receipts==1)
  local stale=callbacks.Crosshaven_meet_crosshaven_mentor_mentor
  service.Remove(player);callbacks={};service.Update(player);tick();stale.callback(player);tick();assert(#receipts==1)
  assert(not callbacks.Crosshaven_meet_crosshaven_mentor_mentor.prompt.Enabled)
  -- Combat and escorts have separate evidence, never fabricate their callbacks here.
  data.progression.campaign.objectives.complete_borrowed_mastery=true;data.progression.campaign.objectives.rescue_former_rival=true;tick()
  click("claim_crosshaven_charter_charter",true);assert(#receipts==2)
  stage(25)
  click("collect_both_testimonies_human_record_1",true);click("collect_both_testimonies_human_record_1",true);assert(#receipts==2)
  for _,side in ipairs({"human","orc"})do for i=1,3 do click("collect_both_testimonies_"..side.."_record_"..i,true)end end
  assert(#receipts==3)
  click("hold_crosshaven_hearing_speaker_human",true);assert(#receipts==3);click("hold_crosshaven_hearing_speaker_orc",true)
  click("choose_reconciliation_shared_table",true);click("choose_reconciliation_joint_work",true);assert(#receipts==5);assert(data.progression.campaign.choices.choose_reconciliation=="shared_table")
  stage(26)
  for _,point in ipairs({"sleeping_space","water_space","care_space"})do click("prepare_refuge_spaces_"..point,true)end
  for i=1,3 do click("prepare_certain_supplies_supply_bundle_"..i,true)end
  assert(#receipts==7);click("defend_refuge_camp_camp_steward",true);assert(#receipts==7,"Distant owner entered defense")
  stage(27)
  click("interview_crest_witness_witness",true)
  click("solve_refuge_passage_hidden_exit",true);assert(#receipts==8)
  for i=1,3 do click("solve_refuge_passage_passage_clue_"..i,true)end
  click("solve_refuge_passage_passage_clue_3",true);assert(#receipts==8)
  for _,i in ipairs({2,1,3})do click("solve_refuge_passage_passage_clue_"..i,true)end
  click("solve_refuge_passage_hidden_exit",true);assert(#receipts==8)
  click("solve_refuge_passage_hidden_turn",true);click("solve_refuge_passage_hidden_exit",true)
  click("choose_forger_fate_guarded_refuge",true);click("choose_forger_fate_testify",true);assert(#receipts==10)
  assert(data.progression.campaign.choices.choose_forger_fate=="guarded_refuge")
  stage(28,{escort_through_inspection=true})
  click("disable_name_sorter_interlock_3",true);assert(#receipts==10)
  for _,i in ipairs({2,1,3})do click("disable_name_sorter_interlock_"..i,true)end
  click("register_backup_evidence_backup_evidence",true);assert(#receipts==12)
  stage(29)
  for _,point in ipairs({"offer","consequence","return_route"})do click("read_power_offer_"..point,true)end
  click("choose_offer_response_investigate_offer",true);click("choose_offer_response_refuse_offer",true)
  for _,point in ipairs({"rest_station","supply_station","route_station"})do click("prepare_final_route_"..point,true)end
  assert(#receipts==15 and data.progression.campaign.choices.choose_offer_response=="investigate")
  local parent=workspace:FindFirstChild("GuildborneWorld")or workspace
  local model=assert(parent:FindFirstChild("CrosshavenCourt_"..player.UserId));session.epoch=2;tick();assert(not model.Parent)
  assert(moved==0 and (character:GetPivot().Position-initial.Position).Magnitude<1)
  return {prompts=count,privateReceipts=#receipts,notifications=notices,syntheticCheckpointRebuilds=1,profileWrites=0,actualPlayerJourney=false,worldMovementCalls=moved}
 end)
 service.Destroy();beat:Destroy();if not ok then error(result)end;return result
end
