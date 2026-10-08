--!strict
-- Fake profile/session and prompt callbacks. Marker anchors move to the existing
-- avatar only inside this fixture; the avatar and real profile never move/change.
return function(factory:any):any
 local player=assert(game.Players:GetPlayers()[1]);local character=assert(player.Character)
 local root=assert(character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local server=game.ServerScriptService.Server
 local config=require(server.Config.CampaignSequence)({require(server.Config.ChapterOne),require(server.Config.ChapterTwo)})
 local data:any={settings={language="th"},character={classId="Mage",level=35},personalGuild={buildings={guildHall=4}},progression={campaign={claimed=6,objectives={},choices={}}}}
 local session:any={record={data=data},state="Active",epoch=1,token="fixture"}
 local callbacks:{[string]:any}={};local receipts={};local notifications=0;local clock=100;local retry=true;local moved=0
 local actor={health=30,position=root.Position}
 local service=factory({Data={Sessions={[player.UserId]=session},FlushAudit=function()end},Config=config,Now=function()return clock end,
  BindPrompt=function(prompt:ProximityPrompt,callback:any)callbacks[prompt.Name]={prompt=prompt,callback=callback};return {Disconnect=function()end}end,
  World={RefreshCampaignCompanions=function()moved+=1 end,IntentCommitted=function()moved+=1 end,CompanionEvidence=function(_,id)return if id=="companion"then actor else nil end},
  MakeReceipt=function(owner,receipt)
   assert(owner==player.UserId and receipt.owner==owner and receipt.action=="CampaignObjective")
   return function()
    if retry then retry=false;return "Retry","SavePending"end
    table.insert(receipts,receipt);data.progression.campaign.objectives[receipt.args.objective]=true
    if receipt.args.choice then data.progression.campaign.choices[receipt.args.objective]=receipt.args.choice end
    return "Committed","OK"
   end
  end,Notify=function()notifications+=1 end})
 local oldZone=player:GetAttribute("CurrentZone");local initialPivot=character:GetPivot()
 local function tick()clock+=1;task.wait(.25)end
 local function click(name:string,near:boolean?,who:any?)
  local entry=assert(callbacks["Ironveil_"..name],name);local p=entry.prompt.Parent :: BasePart;local old=p.Position
  if near then p.Position=root.Position-Vector3.new(0,2,0)end
  entry.callback(who or player);p.Position=old;tick();tick()
 end
 local function stage(claimed:number,done:any?)data.progression.campaign={claimed=claimed,objectives=done or {},choices={}};tick()end
 local ok,result=pcall(function():any
  service.Update(player);tick()
  local count=0;for _ in pairs(callbacks)do count+=1 end;assert(count==49,"Prompt count "..count)
  click("inspect_ironveil_scales_scale_1",false);assert(#receipts==0,"Accepted distant prompt")
  click("inspect_ironveil_scales_scale_1",true,{});assert(#receipts==0,"Accepted foreign owner")
  data.character.level=1;click("inspect_ironveil_scales_scale_1",true);assert(#receipts==0);data.character.level=35;tick()
  for i=1,3 do click("inspect_ironveil_scales_scale_"..i,true);assert(not callbacks["Ironveil_inspect_ironveil_scales_scale_"..i].prompt.Enabled,"Checked scale remains active")end;tick();assert(#receipts==1)
  click("interview_carrier_carrier",true);click("MineReception",true);assert(#receipts==3)
  stage(7)
  click("read_mine_signal_signal_2",true);assert(#receipts==3)
  for i=1,3 do click("read_mine_signal_signal_"..i,true)end
  click("choose_safe_shaft_signal_1",true);assert(#receipts==4)
  click("choose_safe_shaft_signal_2",true);assert(#receipts==5)
  click("rescue_miner_trapped_miner",true);assert(#receipts==5,"Distant owner completed escort")
  stage(8)
  for i=1,3 do click("inspect_shoring_support_"..i,true);assert(not callbacks["Ironveil_inspect_shoring_support_"..i].prompt.Enabled,"Checked support remains active")end
  click("protect_engineer_engineer",true);tick();assert(#receipts==6,"Distant owner protected NPC")
  data.progression.campaign.objectives.protect_engineer=true;tick()
  for _,i in ipairs({2,1,3})do click("repair_shoring_support_"..i,true)end;assert(#receipts==7)
  stage(9);click("collect_reagent_reagent",true)
  for i=1,2 do click("compare_mine_seals_seal_"..i,true);assert(not callbacks["Ironveil_compare_mine_seals_seal_"..i].prompt.Enabled,"Checked seal remains active")end
  assert(callbacks.Ironveil_Review_workers.prompt.MaxActivationDistance==4 and callbacks.Ironveil_Review_council.prompt.MaxActivationDistance==4)
  click("Review_council",true);assert(#receipts==10 and data.progression.campaign.choices.choose_joint_review=="council")
  stage(10)
  for i=1,3 do click("operate_mine_mechanism_mechanism_"..i,true)end
  data.progression.campaign.objectives.protect_mine_worker=true;tick();player:SetAttribute("CurrentZone","Ironveil")
  local ticket:any={owner=player.UserId+1,encounterId="quarry_guardian",members={"companion"}}
  service.Victory(player,ticket);tick();assert(#receipts==11)
  ticket.owner=player.UserId;ticket.members={"player"};service.Victory(player,ticket);tick();assert(#receipts==11)
  ticket.members={"companion"};actor.health=0;service.Victory(player,ticket);tick();assert(#receipts==11)
  actor.health=30;service.Victory(player,ticket);tick();tick();assert(#receipts==12)
  service.Victory(player,ticket);tick();assert(#receipts==12)
  click("return_mine_key_arena_entry",true);assert(#receipts==13)
  stage(11);click("meet_class_mentor_mentor",true)
  local enabled=0;for name,entry in pairs(callbacks)do if name:find("Borrowed_",1,true)and entry.prompt.Enabled then enabled+=1 end end
  assert(enabled==2,"Wrong borrowed class prompts")
  local first=callbacks.Ironveil_Borrowed_elementalist.prompt;local second=callbacks.Ironveil_Borrowed_spellblade.prompt
  assert(first.MaxActivationDistance==4 and second.MaxActivationDistance==4 and ((first.Parent :: BasePart).Position-(second.Parent :: BasePart).Position).Magnitude==8,"Borrowed choices overlap")
  click("submit_ironveil_evidence_mentor",true);assert(#receipts==14)
  data.progression.campaign.objectives.complete_borrowed_path=true;tick();click("submit_ironveil_evidence_mentor",true);assert(#receipts==15)
  local model=workspace:FindFirstChild("GuildborneWorld"):FindFirstChild("IronveilMine_"..player.UserId);assert(model)
  session.epoch=2;tick();assert(not model.Parent,"Stale mine survived")
  assert(moved==0 and (character:GetPivot().Position-initialPivot.Position).Magnitude<1,"Fixture moved avatar")
  return {prompts=count,privateReceipts=#receipts,notifications=notifications,profileWrites=0,actualPlayerJourney=false,syntheticOwnerEvidence=true,worldMovementCalls=moved,completedMarkersDisabled=8,choiceProximityChecks=2}
 end)
 service.Destroy();player:SetAttribute("CurrentZone",oldZone)
 if not ok then error(result)end;return result
end
