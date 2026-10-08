--!strict
-- Optional memory-preview campaign. Only measured server interactions create receipts.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Templates=game:GetService("ServerStorage"):WaitForChild("GuildborneArtKit")
local V=Vector3.new
return function(deps:any)
 local S={};local entries:{[Player]:any}={}
 local function session(player:Player):any?
  local s=deps.Data.Sessions[player.UserId];local d=s and s.record and s.record.data
  if not s or s.closing or not d or not d.progression.campaign or not d.progression.novice or d.progression.novice.claimed~=6 then return nil end
  return s
 end
 local function nextId(data:any):string?
  local state=data.progression.campaign;local def=deps.Config.Chapters[state.claimed+1]
  if def then for _,id in ipairs(def.Objectives)do if not state.objectives[id]then return id end end end
  return nil
 end
 local function root(player:Player):BasePart?
  local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local r=c and c:FindFirstChild("HumanoidRootPart")
  return if c and h and h.Health>0 and (c:GetAttribute("CombatHealth")or 1)>0 and r and r:IsA("BasePart")then r else nil
 end
 local function companion(player:Player,data:any,id:string?):any?
  local r=root(player);if not r then return nil end
  for _,actorId in ipairs(data.party.adventurerIds)do if not id or id==actorId then
   local evidence=deps.World.CompanionEvidence(player,actorId)
   if evidence and evidence.health>0 and (evidence.position-r.Position).Magnitude<=30 then return evidence end
  end end
  return nil
 end
 local function observe(player:Player,e:any,id:string,choice:string?)
  local s=session(player)
  if not s or s.state~="Active"or s.busy or e.pending or s.epoch~=e.epoch or s.token~=e.token or nextId(s.record.data)~=id then return end
  e.pending=deps.MakeReceipt(player.UserId,{owner=player.UserId,requestId="campaign:"..Http:GenerateGUID(false),action="CampaignObjective",args={objective=id,choice=choice}})
 end
 function S.Remove(player:Player)
  local e=entries[player];if not e then return end;entries[player]=nil
  for _,c in ipairs(e.connections)do c:Disconnect()end;if e.cargo then e.cargo:Destroy()end
  if player.Character then player.Character:SetAttribute("CampaignCarrying",nil)end;e.model:Destroy()
 end
 function S.Update(player:Player)
  local s=session(player);if not s or s.record.data.progression.campaign.claimed>=6 then S.Remove(player);return end
  if entries[player]then return end
  local context=deps.World.CampaignContext(player);if not context then return end
  local model=Instance.new("Model");model.Name="GuildCampaign_"..player.UserId;model:SetAttribute("CampaignOwner",player.UserId)
  local e:any={model=model,origin=context.origin,epoch=s.epoch,token=s.token,connections={},markers={},tour={},tracks={},wins={},deaths={}}
  entries[player]=e
  local function marker(name:string,id:string,pos:Vector3,kind:string?,choice:string?)
   local p=Instance.new("Part");p.Name=name;p.Size=V(2,.15,2);p.Position=pos;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Color=Color3.fromRGB(214,174,78);p.Material=Enum.Material.Neon;p.Parent=model
   local prompt=Instance.new("ProximityPrompt");prompt.Name="Campaign_"..name;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.R;prompt.GamepadKeyCode=Enum.KeyCode.ButtonY;prompt.Enabled=false;prompt.Parent=p
   local board=Instance.new("BillboardGui");board.Size=UDim2.fromOffset(240,64);board.StudsOffset=V(0,4,0);board.MaxDistance=80;board.AlwaysOnTop=true;board.Enabled=false;board.Parent=p
   local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.TextWrapped=true;label.Font=Enum.Font.GothamMedium;label.TextSize=15;label.BackgroundColor3=Color3.fromRGB(22,29,38);label.TextColor3=Color3.fromRGB(244,233,208);label.Parent=board
   local m={part=p,prompt=prompt,board=board,label=label,id=id,kind=kind,choice=choice,name=name};table.insert(e.markers,m)
   table.insert(e.connections,prompt.Triggered:Connect(function(who)
    local current=session(player);local r=root(player)
    if who~=player or not current or current.state~="Active"or current.busy or e.pending or not r or not prompt.Enabled or (r.Position-p.Position).Magnitude>12 then return end
    local data=current.record.data;if nextId(data)~=id or not companion(player,data)then return end
    if id=="meet_founder"and not companion(player,data,data.progression.novice.founderHero)then return end
    if kind=="Tour"then e.tour[name]=true;local n=0;for _ in pairs(e.tour)do n+=1 end;if n<3 then return end
    elseif kind=="Tracks"then e.tracks[name]=true;if not e.tracks.TrackOne or not e.tracks.TrackTwo then return end
    elseif kind=="Pickup"then e.supplies=true;return
    elseif kind=="Delivery"and not e.supplies then return
    elseif kind=="Escort"and not e.wins.greenwood_scout then return
    elseif kind=="Timber"and data.progression.campaign.choices.allocate_timber~=choice then return end
    observe(player,e,id,if kind=="Choice"then choice else nil)
   end))
  end
  local o=e.origin
  marker("FounderTable","meet_founder",o+V(-23,1,-12))
  marker("HallTour","tour_guild",o+V(0,1,-9),"Tour")
  marker("WorkshopTour","tour_guild",o+V(20,1,17),"Tour")
  marker("TavernTour","tour_guild",o+V(-23,1,-6),"Tour")
  marker("SupplyPickup","help_city",V(-100,1.2,-790),"Pickup")
  marker("SupplyDelivery","help_city",V(-100,1.2,-835),"Delivery")
  marker("TeamTable","prepare_team",o+V(-23,1,-12))
  marker("TrackOne","inspect_tracks",V(-5,2.2,1480),"Tracks")
  marker("TrackTwo","inspect_tracks",V(-30,2.2,1450),"Tracks")
  marker("EscortFinish","finish_escort",V(-55,2.2,1430),"Escort")
  marker("CutTimber","inspect_timber",V(-30,2.2,1465))
  marker("TimberWorkers","allocate_timber",V(-38,2.2,1470),"Choice","workers")
  marker("TimberTown","allocate_timber",V(-22,2.2,1470),"Choice","town")
  marker("DeliverWorkers","deliver_timber",V(-50,2.2,1440),"Timber","workers")
  marker("DeliverTown","deliver_timber",V(-100,1.2,-835),"Timber","town")
  marker("FalseCrest","disable_false_crest",V(30,2.2,1460))
  marker("Registrar","return_forest_evidence",o+V(0,1,-9))
  for i,choice in ipairs({"together","courage","discovery"})do marker("Motto_"..choice,"choose_motto",o+V(-6+(i-1)*6,1,-3),"Choice",choice)end
  for i,choice in ipairs({"sun","oak","compass"})do marker("Crest_"..choice,"choose_crest",o+V(-6+(i-1)*6,1,3),"Choice",choice)end
  marker("Recognition","register_recognition",o+V(0,1,-9))
  for _,m in ipairs(e.markers)do
   local asset=if m.name=="SupplyPickup"or m.name=="SupplyDelivery"then "SupplyCrate"elseif m.name=="CutTimber"or m.name=="DeliverWorkers"then "TimberLogs"else nil
   if asset then
    local visual=(Templates:FindFirstChild(asset) :: Model):Clone();visual.Name=m.name.."Prop"
    for _,p in ipairs(visual:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false;p.CanTouch=false;p.CanQuery=false end end
    visual:PivotTo(CFrame.new(m.part.Position+V(4,-.5,0)));visual.Parent=model
   end
  end
  model.Parent=workspace
 end
 function S.Command(player:Player,action:string,_args:any)
  local s=session(player);local e=entries[player];if not s or not e or action~="UpdateParty"or nextId(s.record.data)~="configure_companion"then return end
  local d=s.record.data;local founder=d.progression.novice.founderHero;local hero=d.adventurers[founder]
  if hero and hero.equipmentSlots.weapon and d.inventory.equipment[hero.equipmentSlots.weapon]and companion(player,d,founder)then observe(player,e,"configure_companion")end
 end
 function S.Order(player:Player,action:string,actorId:string?)
  local s=session(player);local e=entries[player];if not s or not e or not actorId then return end
  local d=s.record.data;local actor=companion(player,d,actorId);if not actor or actor.order~=action then return end
  local id=nextId(d)
  if id=="regroup_companion"and action=="Regroup"and actorId==d.progression.novice.founderHero then observe(player,e,id)
  elseif player:GetAttribute("CurrentZone")=="Greenwood"then
   if id=="focus_escort"and action=="Focus"and actor.focus then observe(player,e,id)
   elseif id=="regroup_escort"and action=="Regroup"then
    local context=deps.World.CampaignContext(player)
    if context and context.model:GetAttribute("InCombat")==true then observe(player,e,id)end
   end
  end
 end
 function S.Victory(player:Player,ticket:any)
  local s=session(player);local e=entries[player]
  if not s or not e or ticket.owner~=player.UserId or player:GetAttribute("CurrentZone")~="Greenwood"or e.deaths[ticket.deathId]then return end
  -- A bounded set of only campaign-relevant deaths; reset when the chapter changes.
  local id=nextId(s.record.data)
  local wanted=if id=="finish_escort"then "greenwood_scout"elseif id=="protect_companion"then "greenwood_archer"elseif id=="defeat_forest_guardian"then "forest_captain"else nil
  if ticket.encounterId~=wanted or e.wins[ticket.encounterId]then return end
  local participant=false
  for _,actorId in ipairs(ticket.members)do if actorId~="player"and companion(player,s.record.data,actorId)then participant=true;break end end
  if not participant then return end
  e.deaths[ticket.deathId]=true;e.wins[ticket.encounterId]=true
  if id~="finish_escort"then observe(player,e,id :: string)end
 end
 local elapsed=0
 local connection=Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  for player,e in pairs(entries)do
   local s=session(player)
   if not s or player.Parent~=Players or s.epoch~=e.epoch or s.token~=e.token then S.Remove(player);continue end
   if e.pending and os.clock()>=(e.nextDelivery or 0)then
    e.nextDelivery=os.clock()+.5;local outcome,problem=e.pending();e.model:SetAttribute("DeliveryProblem",problem)
    if outcome=="Committed"then e.pending=nil;deps.Notify(player);deps.Data.FlushAudit(player.UserId)
    elseif outcome=="Rejected"then e.pending=nil end
   end
   if entries[player]~=e then continue end
   local d=s.record.data;local state=d.progression.campaign;local id=nextId(d);local th=d.settings.language=="th"
   if e.chapter~=state.claimed then e.chapter=state.claimed;e.tour={};e.tracks={};e.wins={};e.deaths={};e.supplies=nil end
   local text=if id then deps.Config.ObjectiveLabels[id][if th then 2 else 1]else (if th then "รับรางวัลบทนี้ในเมนูกิลด์"else "Claim chapter rewards in the Guild menu.")
   e.model:SetAttribute("Objective",id);e.model:SetAttribute("ObjectiveText",text)
   local r=root(player)
   local cargo=if r and id=="help_city"and e.supplies then "SupplyCrate"elseif r and id=="deliver_timber"then "TimberLogs"else nil
   if e.cargo and (e.cargoKind~=cargo or e.cargoRoot~=r)then e.cargo:Destroy();e.cargo=nil end
   if cargo and not e.cargo and r then
    local pack=(Templates:FindFirstChild(cargo) :: Model):Clone();pack.Name="CampaignCargo";pack:SetAttribute("CampaignOwner",player.UserId);pack:ScaleTo(.35)
    pack:PivotTo(r.CFrame*CFrame.new(0,-.4,1.4))
    for _,part in ipairs(pack:GetDescendants())do if part:IsA("BasePart")then
     part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Massless=true;part.Anchored=false
     local weld=Instance.new("WeldConstraint");weld.Part0=r;weld.Part1=part;weld.Parent=part
    end end
    pack.Parent=e.model;e.cargo=pack;e.cargoKind=cargo;e.cargoRoot=r
   end
   if player.Character then player.Character:SetAttribute("CampaignCarrying",cargo)end
   for _,m in ipairs(e.markers)do
    local active=id==m.id
    if m.kind=="Tour"then active=active and not e.tour[m.name]end
    if m.kind=="Tracks"then active=active and not e.tracks[m.name]end
    if m.kind=="Pickup"then active=active and not e.supplies end
    if m.kind=="Delivery"then active=active and e.supplies==true end
    if m.kind=="Timber"then active=active and state.choices.allocate_timber==m.choice end
    m.part.Transparency=if active then .25 else 1;m.board.Enabled=active
    m.prompt.Enabled=active and s.state=="Active"and not s.busy and not e.pending
    local names={workers={"Workers","คนงาน"},town={"Town","เมือง"},together={"Together","เคียงข้างกัน"},courage={"Courage","ความกล้า"},discovery={"Discovery","การค้นพบ"},sun={"Sun","ดวงอาทิตย์"},oak={"Oak","ต้นโอ๊ก"},compass={"Compass","เข็มทิศ"}}
    local suffix=if m.choice then " · "..names[m.choice][if th then 2 else 1]else ""
    local action=if m.kind=="Pickup"then (if th then "รับลังเสบียง"else "Collect supply crate")elseif m.kind=="Delivery"then (if th then "ส่งลังเสบียง"else "Deliver supply crate")else text
    m.label.Text=action..suffix;m.prompt.ActionText=action..suffix;m.prompt.ObjectText=if th then "กิลด์ · บท 1"else "Guild · Chapter 1"
   end
  end
 end)
 function S.Destroy()connection:Disconnect();for player in pairs(entries)do S.Remove(player)end end
 return S
end
