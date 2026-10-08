--!strict
-- Synthetic isolated data/evidence adapter, never the active profile service.
return function(factoryOverride:any?):any
 local player=game.Players:GetPlayers()[1];assert(player and player.Character)
 local r=player.Character:FindFirstChild("HumanoidRootPart") :: BasePart;assert(r)
 local Services=game.ServerScriptService.Server.Services;local Config=require(game.ServerScriptService.Server.Config.ChapterOne)
 local data:any={settings={language="th"},party={adventurerIds={"founder"}},inventory={equipment={starter={}}},adventurers={founder={equipmentSlots={weapon="starter"}}},progression={novice={claimed=6,founderHero="founder"},campaign={claimed=0,objectives={},choices={}}}}
 local record={data=data};local profile:any={record=record,state="Active",epoch=1,token="fixture"}
 local context=Instance.new("Model");context.Name="CampaignContextFixture";context:SetAttribute("InCombat",true);context.Parent=workspace
 local actor:any={id="founder",health=50,position=r.Position,order="Regroup",focus="scout"}
 local receipts={};local notifications=0;local retries=1
 local service=(factoryOverride or require(Services.CampaignWorld))({Data={Sessions={[player.UserId]=profile},FlushAudit=function()end},Config=Config,
  World={CampaignContext=function()return {origin=Vector3.new(9000,0,0),model=context}end,CompanionEvidence=function(_,id)return if id=="founder"then actor else nil end},
  MakeReceipt=function(owner,receipt)
   assert(owner==player.UserId and receipt.owner==owner and receipt.action=="CampaignObjective")
   return function()
    if retries>0 then retries-=1;return "Retry","Busy"end
    table.insert(receipts,receipt);data.progression.campaign.objectives[receipt.args.objective]=true;return "Committed","OK"
   end
  end,Notify=function()notifications+=1 end})
 local previousZone=player:GetAttribute("CurrentZone")
 local ok,result=pcall(function():any
  service.Update(player);task.wait(.25)
  local model=assert(workspace:FindFirstChild("GuildCampaign_"..player.UserId));local promptCount=0
  for _,v in ipairs(model:GetDescendants())do if v:IsA("ProximityPrompt")then promptCount+=1 end end
  assert(promptCount==24,"Unexpected marker count "..promptCount)
  data.progression.campaign.objectives.meet_founder=true
  actor.health=0;service.Command(player,"UpdateParty",{});task.wait(.25);assert(#receipts==0)
  actor.health=50;actor.position=r.Position+Vector3.new(100,0,0);service.Command(player,"UpdateParty",{});task.wait(.25);assert(#receipts==0)
  actor.position=r.Position;data.adventurers.founder.equipmentSlots.weapon=nil;service.Command(player,"UpdateParty",{});task.wait(.25);assert(#receipts==0)
  data.adventurers.founder.equipmentSlots.weapon="starter";service.Command(player,"UpdateParty",{});task.wait(.3);assert(#receipts==0,"Retry wrote early");task.wait(.6)
  assert(#receipts==1 and receipts[1].args.objective=="configure_companion")
  service.Order(player,"Regroup","foreign");task.wait(.25);assert(#receipts==1)
  service.Order(player,"Regroup","founder");task.wait(.6);assert(#receipts==2)
  data.progression.campaign={claimed=2,objectives={inspect_tracks=true},choices={}};task.wait(.25)
  player:SetAttribute("CurrentZone","Greenwood");actor.order="Focus";actor.focus=nil
  service.Order(player,"Focus","founder");task.wait(.25);assert(#receipts==2)
  actor.focus="scout";service.Order(player,"Focus","founder");task.wait(.6);assert(#receipts==3)
  actor.order="Regroup";context:SetAttribute("InCombat",false);service.Order(player,"Regroup","founder");task.wait(.25);assert(#receipts==3)
  context:SetAttribute("InCombat",true);service.Order(player,"Regroup","founder");task.wait(.6);assert(#receipts==4)
  data.progression.campaign={claimed=4,objectives={disable_false_crest=true},choices={}};task.wait(.25)
  local ticket={owner=player.UserId+1,deathId="fixture:1",encounterId="greenwood_archer",members={"founder"}}
  service.Victory(player,ticket);task.wait(.25);assert(#receipts==4)
  ticket.owner=player.UserId;ticket.members={"player"};service.Victory(player,ticket);task.wait(.25);assert(#receipts==4)
  ticket.members={"founder"};actor.health=0;service.Victory(player,ticket);task.wait(.25);assert(#receipts==4)
  actor.health=50;service.Victory(player,ticket);task.wait(.6);assert(#receipts==5)
  service.Victory(player,ticket);task.wait(.25);assert(#receipts==5)
  ticket.encounterId="forest_captain";ticket.deathId="fixture:2";service.Victory(player,ticket);task.wait(.6);assert(#receipts==6)
  data.progression.campaign={claimed=3,objectives={inspect_timber=true,allocate_timber=true},choices={allocate_timber="workers"}};task.wait(.25)
  local cargo=assert(model:FindFirstChild("CampaignCargo"));local cargoParts=0
  for _,part in ipairs(cargo:GetDescendants())do if part:IsA("BasePart")then
   assert(not part.Anchored and part.Massless and not part.CanCollide and not part.CanTouch and not part.CanQuery)
   local weld=assert(part:FindFirstChildOfClass("WeldConstraint"));assert(weld.Part0==r and weld.Part1==part);cargoParts+=1
  end end
  assert(cargoParts>0 and player.Character:GetAttribute("CampaignCarrying")=="TimberLogs")
  profile.epoch=2;task.wait(.25);assert(not model.Parent,"Old session world survived");assert(not cargo.Parent and player.Character:GetAttribute("CampaignCarrying")==nil,"Cargo leaked")
  return {markers=promptCount,cargoParts=cargoParts,receipts=#receipts,notifications=notifications,profileWrites=0,synthetic=true,checks={"living nearby equipped companion","owned orders","focus target required","active fight required for escort regroup","owner and participating companion victory","duplicate death","receipt retry","session cleanup"}}
 end)
 service.Destroy();context:Destroy();player:SetAttribute("CurrentZone",previousZone)
 assert(ok,tostring(result));return result
end
