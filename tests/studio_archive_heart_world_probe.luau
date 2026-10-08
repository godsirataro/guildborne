--!strict
-- Synthetic session and relocated prompt checks. No actual player progression.
return function(factory:any,config:any):any
 local player=assert(game.Players:GetPlayers()[1]);local character=assert(player.Character);local root=assert(character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local data:any={settings={language="th"},character={classId="Mage",level=100},personalGuild={buildings={guildHall=17}},progression={novice={branch="rescue"},campaign={claimed=30,objectives={},choices={}}},quests={},expansion={tower={}}}
 local session:any={record={data=data},state="Active",epoch=1,token="archive_fixture"}
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
  local entry=assert(callbacks["ArchiveHeart_"..name],name);local part=entry.prompt.Parent :: BasePart;local pos=part.Position
  if near then part.Position=root.Position-Vector3.new(0,2,0)end
  entry.callback(who or player);part.Position=pos;tick();tick()
 end
 local function stage(claimed:number,objectives:any?)data.progression.campaign.claimed=claimed;data.progression.campaign.objectives=objectives or {};tick()end
 local ok,result=pcall(function():any
  service.Update(player);tick();local count=0;for _ in pairs(callbacks)do count+=1 end;assert(count==42,"Count "..count)
  click("choose_citadel_approach_choose_puzzle",false);click("choose_citadel_approach_choose_puzzle",true,{});assert(#receipts==0)
  session.busy=true;click("choose_citadel_approach_choose_puzzle",true);session.busy=false;tick();assert(#receipts==0)
  data.character.level=84;tick();click("choose_citadel_approach_choose_puzzle",true);assert(#receipts==0);data.character.level=100;tick()
  click("choose_citadel_approach_choose_puzzle",true);click("choose_citadel_approach_choose_guard",true);assert(#receipts==1 and data.progression.campaign.choices.choose_citadel_approach=="puzzle")
  local stale=callbacks.ArchiveHeart_choose_citadel_approach_choose_puzzle
  service.Remove(player);callbacks={};service.Update(player);tick();stale.callback(player);tick();assert(#receipts==1)
  assert(not callbacks.ArchiveHeart_complete_alliance_entry_guard_step_1.prompt.Enabled and not callbacks.ArchiveHeart_complete_alliance_entry_stealth_step_1.prompt.Enabled)
  click("complete_alliance_entry_puzzle_step_3",true);assert(#receipts==1)
  for _,i in ipairs({2,1,3})do click("complete_alliance_entry_puzzle_step_"..i,true)end
  click("establish_heart_command_command_post",true);assert(#receipts==3)
  stage(31)
  local function hasText(fragment:string):boolean
   for _,v in ipairs((workspace:FindFirstChild("GuildborneWorld")or workspace):GetDescendants())do
    if v:IsA("TextLabel")and string.find(v.Text,fragment,1,true)then return true end
   end
   return false
  end
  data.settings.language="en";data.progression.campaign.choices.allocate_timber="workers";tick()
  assert(hasText("You pulled our people") and hasText("workers you supported"))
  data.progression.novice.branch="supplies";data.progression.campaign.choices.allocate_timber="town";tick()
  assert(hasText("You saved the caravan's food")and hasText("town you supplied"))
  data.settings.language="th";tick();assert(hasText("เจ้าเคยกู้เสบียง"))
  click("greet_returning_caravan_caravan_greeting",true);assert(#receipts==4)
  -- Combat, support and physical escorts are separate native fixtures, never fabricated here.
  stage(32)
  for i=1,3 do click("read_last_warden_patterns_warning_"..i,true)end;assert(#receipts==5)
  data.progression.campaign.objectives.break_warden_seals=true;tick();click("choose_warden_release_renew_oath",true);assert(#receipts==6)
  stage(33)
  click("recover_named_ledgers_recover_1",true);assert(#receipts==6)
  click("recover_named_ledgers_recovery_start",true);click("recover_named_ledgers_recover_1",true)
  clock+=91;tick();click("recover_named_ledgers_recover_2",true);assert(#receipts==6)
  click("recover_named_ledgers_recovery_start",true)
  for _,i in ipairs({2,3})do click("recover_named_ledgers_recover_"..i,true)end;assert(#receipts==6,"Expired partial ledger survived restart")
  click("recover_named_ledgers_recover_1",true);assert(#receipts==7)
  click("disconnect_ledger_engine_interlock_2",true);assert(#receipts==7,"Missing backups accepted")
  for i=1,3 do click("duplicate_named_ledgers_backup_"..i,true)end;assert(#receipts==8)
  click("disconnect_ledger_engine_interlock_3",true);assert(#receipts==8)
  for _,i in ipairs({2,1,3})do click("disconnect_ledger_engine_interlock_"..i,true)end;assert(#receipts==9)
  stage(34)
  click("gather_voluntary_oaths_pledge_1",true);click("gather_voluntary_oaths_pledge_1",true);assert(#receipts==9)
  for i=2,5 do click("gather_voluntary_oaths_pledge_"..i,true)end;assert(#receipts==10)
  data.progression.campaign.objectives.protect_evacuation_gate=true;tick();click("open_archive_heart_heart_gate",true);assert(#receipts==11)
  stage(35,{complete_keeper_of_names=true});click("choose_tower_future_ending_transform",true);click("choose_tower_future_ending_preserve",true)
  click("record_alliance_epilogue_epilogue_record",true);assert(#receipts==13 and data.progression.campaign.choices.choose_tower_future=="transform")
  local parent=workspace:FindFirstChild("GuildborneWorld")or workspace;local model=assert(parent:FindFirstChild("ArchiveHeartCourt_"..player.UserId))
  assert(model:GetAttribute("EndingChoice")=="transform" and model:FindFirstChild("ArchiveEnding_transform"))
  local display=model:FindFirstChild("ArchiveEnding_transform");tick();assert(display==model:FindFirstChild("ArchiveEnding_transform"),"Rebuilt unchanged display")
  for _,ending in ipairs({"preserve","dismantle"})do
   data.progression.campaign.choices.choose_tower_future=ending;tick()
   assert(model:FindFirstChild("ArchiveEnding_"..ending) and not display.Parent);display=model:FindFirstChild("ArchiveEnding_"..ending)
  end
  data.progression.campaign.objectives.choose_tower_future=nil;tick();assert(not display.Parent and model:GetAttribute("EndingChoice")==nil,"Uncommitted ending displayed")
  data.progression.campaign.objectives.choose_tower_future=true;tick();assert(model:FindFirstChild("ArchiveEnding_dismantle"))
  session.epoch=2;tick();assert(not model.Parent)
  assert(moved==0 and (character:GetPivot().Position-initial.Position).Magnitude<1)
  return {prompts=count,privateReceipts=#receipts,notifications=notices,historyBindingChecks=5,endingDisplays=3,uncommittedEndingHidden=true,syntheticCheckpointRebuilds=1,recoveryExpiryResets=true,mandatoryBackups=true,profileWrites=0,actualPlayerJourney=false,worldMovementCalls=moved}
 end)
 service.Destroy();beat:Destroy();if not ok then error(result)end;return result
end
