--!strict
-- Fake session, prompt callback capture and local marker relocation. No real profile grants.
return function(factory:any):any
 local player=assert(game.Players:GetPlayers()[1]);local character=assert(player.Character)
 local root=assert(character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local server=game.ServerScriptService.Server
 local config=require(server.Config.CampaignSequence)({require(server.Config.ChapterOne),require(server.Config.ChapterTwo),require(server.Config.ChapterThree)})
 local data:any={settings={language="th"},character={classId="Mage",level=50},personalGuild={buildings={guildHall=7}},progression={campaign={claimed=12,objectives={},choices={}}}}
 local session:any={record={data=data},state="Active",epoch=1,token="fixture"}
 local callbacks:{[string]:any}={};local receipts={};local clock=100;local retry=true;local moved=0;local notices=0
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
  end,Notify=function()notices+=1 end})
 local oldZone=player:GetAttribute("CurrentZone");local initial=character:GetPivot()
 local function tick()clock+=1;task.wait(.25)end
 local function click(name:string,near:boolean?,who:any?)
  local entry=assert(callbacks["Ashen_"..name],name);local part=entry.prompt.Parent :: BasePart;local pos=part.Position
  if near then part.Position=root.Position-Vector3.new(0,2,0)end
  entry.callback(who or player);part.Position=pos;tick();tick()
 end
 local function stage(claimed:number,objectives:any?)data.progression.campaign={claimed=claimed,objectives=objectives or {},choices={}};tick()end
 local ok,result=pcall(function():any
  service.Update(player);tick();local count=0;for _ in pairs(callbacks)do count+=1 end;assert(count==37,"Count "..count)
  click("follow_ashen_supplies_supply_trace_1",false);click("follow_ashen_supplies_supply_trace_1",true,{});assert(#receipts==0)
  data.personalGuild.buildings.guildHall=3;click("follow_ashen_supplies_supply_trace_1",true);assert(#receipts==0)
  data.personalGuild.buildings.guildHall=7;service.Update(player);tick()
  for i=1,3 do click("follow_ashen_supplies_supply_trace_"..i,true);assert(not callbacks["Ashen_follow_ashen_supplies_supply_trace_"..i].prompt.Enabled)end
  assert(#receipts==1);click("help_ashen_gatekeeper_gatekeeper",true);assert(#receipts==1,"Distant owner completed gatekeeper escort")
  data.progression.campaign.objectives.help_ashen_gatekeeper=true;tick();click("request_ashen_charter_permit_ledger",true);assert(#receipts==2)
  stage(13)
  for i=1,3 do click("preserve_hearth_traces_memory_"..i,true)end
  click("arrange_hearth_memories_memory_3",true);assert(#receipts==3)
  for i=1,3 do click("arrange_hearth_memories_memory_"..i,true)end
  click("meet_hearth_survivor_survivor",true);assert(#receipts==5)
  stage(14)
  for i=1,3 do click("secure_bridge_supports_support_"..i,true)end
  click("choose_bridge_route_direct_route",true);assert(data.progression.campaign.choices.choose_bridge_route=="direct")
  click("escort_bridgewright_bridgewright",true);assert(#receipts==7)
  stage(15)
  for i=1,3 do click("question_ashen_witness_testimony_"..i,true)end
  click("verify_ashen_testimony_witness",true);click("choose_witness_route_guard_route",true);assert(#receipts==10 and data.progression.campaign.choices.choose_witness_route=="guard")
  stage(16)
  click("tune_ashen_bells_tuning_1",true);assert(#receipts==10)
  for _,i in ipairs({2,3,1})do click("tune_ashen_bells_tuning_"..i,true)end
  player:SetAttribute("CurrentZone","Ashen")
  local ticket:any={owner=player.UserId+1,encounterId="rune_caster",members={"companion"}}
  service.Victory(player,ticket);tick();assert(#receipts==11)
  ticket.owner=player.UserId;ticket.members={"player"};service.Victory(player,ticket);tick();assert(#receipts==11)
  ticket.members={"companion"};actor.health=0;service.Victory(player,ticket);tick();assert(#receipts==11)
  actor.health=30;service.Victory(player,ticket);tick();tick();assert(#receipts==12)
  click("send_ashen_dispatch_courier",true);assert(#receipts==13)
  stage(17)
  for i=1,3 do click("break_ashen_bindings_binding_"..i,true)end
  click("protect_ashen_survivor_civilian",true);assert(#receipts==14)
  data.progression.campaign.objectives.protect_ashen_survivor=true;tick();ticket.encounterId="arcane_warden"
  service.Victory(player,ticket);tick();tick();assert(#receipts==15)
  local model=workspace.GuildborneWorld:FindFirstChild("AshenCourt_"..player.UserId);assert(model)
  session.epoch=2;tick();assert(not model.Parent)
  assert(moved==0 and (character:GetPivot().Position-initial.Position).Magnitude<1)
  return {prompts=count,privateReceipts=#receipts,notifications=notices,profileWrites=0,syntheticOwnerEvidence=true,actualPlayerJourney=false,worldMovementCalls=moved}
 end)
 service.Destroy();player:SetAttribute("CurrentZone",oldZone)
 if not ok then error(result)end;return result
end
