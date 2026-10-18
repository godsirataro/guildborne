--!strict
local W=require("../src/shared/Data/CityWaypoint")
return function(test: any,eq: any)
 local function laterFixture(tower:boolean):any
  local x=if tower then 2000 else 1000
  return {ownerId=7,playerY=103,floor={x=x,y=100,z=1400,width=if tower then 330 else 230,depth=if tower then 330 else 230},anchors={
   CourtEntrance={x=1000,y=2.3,z=1498,zone="Ashen"},CourtExit={x=x,y=100.3,z=1502,zone="Ashen"}}}
 end
 local laterRoute=require("../src/shared/Data/QuestRoute")(require("../src/shared/Config/City"),{},W)
 local catalog={Journal={}}
 test("later campaign public legs survive unstreamed courts and ready claims never travel",function()
  for _,id in ipairs({"follow_ashen_supplies","collect_tower_chart"})do
   local q:any={kind="Campaign",objective=id,name=id}
   eq(laterRoute(q,catalog,0,-1100).name,"Ashen")
   eq(laterRoute(q,catalog,0,1505).name,"Central City")
   eq(laterRoute(q,catalog,1000,1505),nil)
   local context={playerId=7,inGuild=true,island={ownerId=7,exit={x=-44,z=-65}}}
   eq(laterRoute(q,catalog,0,23,context).name,"Central City")
   q.ready=true;local target=laterRoute(q,catalog,9000,9000);eq(target.kind,"Instruction");eq(target.x,nil)
  end
 end)
 test("later courts require owner floor enabled anchors and correct vertical slot",function()
  for _,tower in ipairs({false,true})do
   local c=laterFixture(tower);local x=c.floor.x;local context:any={playerId=7,ashen=if not tower then c else nil,tower=if tower then c else nil}
   local id=if tower then "collect_tower_chart"else "request_ashen_charter"
   local name=id..(if tower then "_route_chart"else "_permit_ledger")
   local q={kind="Campaign",objective=id,name=id}
   c.anchors[name]={x=x+15,y=100.3,z=1450,zone="Ashen"}
   eq(laterRoute(q,catalog,x,1450,context).x,x+15)
   c.playerY=4;eq(laterRoute(q,catalog,1000,1505,context).z,1498)
   if tower then eq(laterRoute(q,catalog,2000,1450,context),nil)end -- Annex is not surface.
   c.playerY=183;eq(laterRoute(q,catalog,x,1450,context),nil)
   c.playerY=103;c.ownerId=8;eq(laterRoute(q,catalog,x,1450,context),nil)
   c.ownerId=7;c.anchors[name].y=180;eq(laterRoute(q,catalog,x,1450,context),nil)
   c.anchors[name]=nil;eq(laterRoute(q,catalog,x,1450,context),nil)
   c.playerY=4;c.anchors.CourtEntrance=nil;eq(laterRoute(q,catalog,1000,1505,context),nil)
   c.playerY=0/0;eq(laterRoute(q,catalog,x,1450,context),nil)
   c.floor=nil;eq(laterRoute(q,catalog,x,1450,context),nil)
  end
 end)
 test("all Chapter03 and04 prompt objectives map only to authored action names",function()
  local cases:{{tower:boolean,config:any,markers:{[string]:string}}}={
   {tower=false,config=require("../src/server/Config/ChapterThree"),markers={
    follow_ashen_supplies="supply_trace_2",help_ashen_gatekeeper="gatekeeper",request_ashen_charter="permit_ledger",preserve_hearth_traces="memory_2",arrange_hearth_memories="memory_3",meet_hearth_survivor="survivor",
    secure_bridge_supports="support_1",choose_bridge_route="direct_route",escort_bridgewright="bridgewright",question_ashen_witness="testimony_3",verify_ashen_testimony="witness",choose_witness_route="guard_route",tune_ashen_bells="tuning_2",send_ashen_dispatch="courier",break_ashen_bindings="binding_1",protect_ashen_survivor="civilian"}},
   {tower=true,config=require("../src/server/Config/ChapterFour"),markers={
    reach_tower_checkpoint_five="checkpoint_5",finish_tower_orientation="checkpoint_10",collect_tower_chart="route_chart",confirm_tower_charter="council",try_guardian_guard="guard_trial",try_guardian_roles="mend_trial",read_guardian_rules="rule_2",complete_guardian_defense="defense_trial",find_hidden_archive="hidden_exit",solve_archive_sequence="sequence_3",recover_archive_chart="archive_record",read_guild_memories="guild_memory",rescue_memory_echo="help_memory",renew_tower_oath="oath_compassion",read_twin_door_clues="door_clue_2",choose_tower_door="moon_door",follow_tower_bypass="bypass_record",complete_records_guardian="records_guardian",copy_first_ledger="copy_ledger",earn_three_city_seals="city_seal_3"}},
  }
  local count=0
  for _,case in ipairs(cases)do
   local c=laterFixture(case.tower);local x=c.floor.x;local context:any={playerId=7,ashen=if not case.tower then c else nil,tower=if case.tower then c else nil}
   for _,chapter in ipairs(case.config.Chapters)do for _,id in ipairs(chapter.Objectives)do
    if id=="survive_bell_wave" or id=="defeat_ashen_warden"then continue end
    local suffix=assert(case.markers[id],"uncovered canonical objective "..id)
    c.anchors={[id.."_"..suffix]={x=x+10,y=100.3,z=1450,zone="Ashen"}}
    local target=laterRoute({kind="Campaign",objective=id,name=id},catalog,x,1450,context)
    eq(target.x,x+10);eq(target.name,id);count+=1
    c.anchors={};eq(laterRoute({kind="Campaign",objective=id,name=id},catalog,x,1450,context),nil)
   end end
  end
  eq(count,36)
 end)
 test("later choices and sequences are nonfinal areas never selected answers",function()
  local choices:any={{tower=false,objective="choose_bridge_route",suffix="sheltered_route"},{tower=false,objective="choose_witness_route",suffix="trust_route"},{tower=false,objective="arrange_hearth_memories",suffix="memory_1"},{tower=false,objective="tune_ashen_bells",suffix="tuning_2"},{tower=true,objective="renew_tower_oath",suffix="oath_courage"},{tower=true,objective="choose_tower_door",suffix="sun_door"},{tower=true,objective="solve_archive_sequence",suffix="sequence_3"},{tower=true,objective="reach_tower_checkpoint_five",suffix="checkpoint_1"}}
  for _,case in ipairs(choices)do
   local c=laterFixture(case.tower);local context:any={playerId=7,ashen=if not case.tower then c else nil,tower=if case.tower then c else nil}
   c.anchors[case.objective.."_"..case.suffix]={x=c.floor.x+10,y=100.3,z=1450,zone="Ashen"}
   local target=laterRoute({kind="Campaign",objective=case.objective,name="Read the choices"},catalog,c.floor.x,1450,context)
   eq(target.kind,"ObjectiveArea");eq(target.final,false);eq(target.name,"Read the choices")
  end
 end)
 test("Tower bypass follows only supplied enabled branch then the record",function()
  local c=laterFixture(true);local context={playerId=7,tower=c};local q={kind="Campaign",objective="follow_tower_bypass",name="Bypass"}
  for i,suffix in ipairs({"left","right","record"})do
   c.anchors={["follow_tower_bypass_bypass_"..suffix]={x=2000+i,y=100.3,z=1450,zone="Ashen"}}
   local target=laterRoute(q,catalog,2000,1450,context);eq(target.x,2000+i);eq(target.final,false)
  end
  c.anchors={unrelated={x=2000,y=100.3,z=1450,zone="Ashen"}};eq(laterRoute(q,catalog,2000,1450,context),nil)
 end)
 test("Ashen combat exits court then requires real owned living surface encounter",function()
  local c=laterFixture(false);local context={playerId=7,ashen=c}
  for _,case in ipairs({{"survive_bell_wave","rune_caster","CasterCourt"},{"defeat_ashen_warden","arcane_warden","ArcaneWarden"}})do
   local q={kind="Campaign",objective=case[1],name="Battle"};c.playerY=103
   eq(laterRoute(q,catalog,1000,1450,context).z,1502)
   c.playerY=4;eq(laterRoute(q,catalog,1000,1450,context),nil)
   local enemy:any={ownerId=7,alive=true,marker=case[3],point={x=1010,y=3,z=1400,zone="Ashen"}}
   c.encounters={[case[2]]=enemy};eq(laterRoute(q,catalog,1000,1450,context).kind,"Enemy")
   enemy.ownerId=8;eq(laterRoute(q,catalog,1000,1450,context),nil)
   enemy.ownerId=7;enemy.alive=false;eq(laterRoute(q,catalog,1000,1450,context),nil)
   enemy.alive=true;enemy.marker="Wrong";eq(laterRoute(q,catalog,1000,1450,context),nil)
   enemy.marker=case[3];enemy.point.y=103;eq(laterRoute(q,catalog,1000,1450,context),nil)
   c.playerY=183;eq(laterRoute(q,catalog,1000,1450,context),nil)
  end
 end)
 test("Ashen escorts and protection use current replicated positions and warning lifetime",function()
  local c=laterFixture(false);local context={playerId=7,ashen=c}
  local q:any={kind="Campaign",objective="escort_bridgewright",name="Escort"}
  c.escortStatus="Active";eq(laterRoute(q,catalog,1000,1450,context).kind,"Instruction")
  c.escortPosition={x=1020,y=100,z=1460,zone="Ashen"};c.escortExit={x=1030,y=100,z=1460,zone="Ashen"}
  c.escortReasons={gatekeeper="MeetAtExit"};eq(laterRoute(q,catalog,1000,1450,context).x,1020)
  c.escortReasons.bridgewright="MeetAtExit";eq(laterRoute(q,catalog,1000,1450,context).x,1030)
  c.escortExit.y=180;eq(laterRoute(q,catalog,1000,1450,context).kind,"Instruction")
  c.escortStatus="Failed";eq(laterRoute(q,catalog,1000,1450,context),nil)
  q.objective="protect_ashen_survivor";c.protectionStatus="Active";eq(laterRoute(q,catalog,1000,1450,context).kind,"Instruction")
  c.warning={x=1030,y=100.3,z=1460,zone="Ashen"};c.warningLive=true;eq(laterRoute(q,catalog,1000,1450,context).kind,"Warning")
  c.warningLive=false;eq(laterRoute(q,catalog,1000,1450,context).kind,"Instruction")
 end)
 test("Tower activities remain instruction only and failed lessons permit retry",function()
  local c=laterFixture(true);local context={playerId=7,tower=c};local q:any={kind="Campaign",objective="rescue_memory_echo",name="Help echo"}
  c.escortStatus="Active";eq(laterRoute(q,catalog,2000,1450,context).kind,"Instruction")
  c.escortStatus="Cancelled";eq(laterRoute(q,catalog,2000,1450,context),nil)
  for _,case in ipairs({{"try_guardian_guard","Guard","guard_trial"},{"try_guardian_roles","Mend","mend_trial"},{"complete_guardian_defense","Combined","defense_trial"}})do
   q.objective=case[1];c.lessonStatus="Active";c.lessonRole=case[2];eq(laterRoute(q,catalog,2000,1450,context).kind,"Instruction")
   c.lessonStatus="Failed";c.anchors={[case[1].."_"..case[3]]={x=2010,y=100.3,z=1450,zone="Ashen"}}
   eq(laterRoute(q,catalog,2000,1450,context).kind,"Objective")
  end
  q.objective="complete_records_guardian";c.trial=true;c.playerY=135
  eq(laterRoute(q,catalog,2000,1300,context).kind,"Instruction")
  c.trial=false;eq(laterRoute(q,catalog,2000,1300,context),nil)
  q.objective="unknown_later_objective";c.playerY=103;eq(laterRoute(q,catalog,2000,1450,context),nil)
 end)
 test("authored later court guidance is bearing only without a fabricated safe path",function()
  local c=laterFixture(true);c.anchors.collect_tower_chart_route_chart={x=2010,y=100.3,z=1450,zone="Ashen",anchor="synthetic"}
  local target=laterRoute({kind="Campaign",objective="collect_tower_chart",name="Chart"},catalog,2000,1450,{playerId=7,tower=c,authored=true})
  eq(target.guidance,"destination");eq(target.anchor,nil);eq(target.destinationName,"Chart")
 end)
 test("earned Hall directions exit owned courts before returning from Ashen surface",function()
  local q={kind="Campaign",focus="UpgradeGuildHall",name="Upgrade Hall"}
  eq(laterRoute(q,catalog,1000,1450,{playerId=7,playerY=103}),nil)
  eq(laterRoute(q,catalog,2000,1450,{playerId=7,playerY=103}),nil)
  for _,tower in ipairs({false,true})do
   local c=laterFixture(tower);local context:any={playerId=7,playerY=103,ashen=if not tower then c else nil,tower=if tower then c else nil}
   local target=laterRoute(q,catalog,c.floor.x,1450,context);eq(target.name,"Ashen");eq(target.x,c.floor.x);eq(target.y,100.3)
   c.anchors.CourtExit=nil;eq(laterRoute(q,catalog,c.floor.x,1450,context),nil)
   c.ownerId=8;eq(laterRoute(q,catalog,c.floor.x,1450,context),nil)
   c.playerY=4;context.playerY=4;eq(laterRoute(q,catalog,1000,1505,context).name,"Central City")
   eq(laterRoute(q,catalog,2000,1450,context),nil)
  end
 end)
 test("remaining mine objectives respect activities and never invent puzzle progress",function()
  local city=require("../src/shared/Config/City");local rules=require("../src/shared/Data/Expansion")
  local route=require("../src/shared/Data/QuestRoute")(city,rules,W)
  local mine:any={ownerId=7,playerY=103,floor={x=500,y=100,z=1400,width=230,depth=230},anchors={}}
  local context:any={playerId=7,ironveil=mine};local catalog={Journal={}}
  local mappings={read_mine_signal="read_mine_signal_signal_2",choose_safe_shaft="choose_safe_shaft_signal_3",rescue_miner="rescue_miner_trapped_miner",
   inspect_shoring="inspect_shoring_support_2",protect_engineer="protect_engineer_engineer",repair_shoring="repair_shoring_support_3",collect_reagent="collect_reagent_reagent",
   compare_mine_seals="compare_mine_seals_seal_2",choose_joint_review="Review_council",operate_mine_mechanism="operate_mine_mechanism_mechanism_2",
   protect_mine_worker="protect_mine_worker_protected_worker",return_mine_key="return_mine_key_arena_entry",meet_class_mentor="meet_class_mentor_mentor",
   complete_borrowed_path="Borrowed_berserker",submit_ironveil_evidence="submit_ironveil_evidence_mentor"}
  for objective,marker in pairs(mappings)do
   mine.anchors={[marker]={x=510,y=100.3,z=1450,zone="Ironveil"}}
   local target=route({kind="Campaign",objective=objective,name=objective},catalog,500,1500,context)
   eq(target.x,510);eq(target.name,objective)
   if objective=="read_mine_signal" or objective=="repair_shoring" or objective=="choose_joint_review" then eq(target.kind,"ObjectiveArea");eq(target.final,false)end
  end
  local quest:any={kind="Campaign",objective="rescue_miner",name="Escort"}
  mine.escortStatus="Active";mine.escortPosition={x=520,y=103,z=1460,zone="Ironveil"}
  eq(route(quest,catalog,500,1500,context).x,520)
  mine.escortReason="MeetAtExit";mine.escortExit={x=530,y=100,z=1470,zone="Ironveil"};eq(route(quest,catalog,500,1500,context).x,530)
  mine.escortStatus="Failed";eq(route(quest,catalog,500,1500,context),nil)
  quest.objective="protect_engineer";mine.protectionStatus="Active"
  eq(route(quest,catalog,500,1500,context).kind,"Instruction")
  mine.warning={x=540,y=100,z=1460,zone="Ironveil"};mine.warningLive=true;eq(route(quest,catalog,500,1500,context).kind,"Warning")
  mine.warningLive=false;eq(route(quest,catalog,500,1500,context).kind,"Instruction")
  quest.objective="complete_borrowed_path";mine.trial=true;mine.playerY=128;eq(route(quest,catalog,500,1400,context).kind,"Instruction")
  mine.trial=false;eq(route(quest,catalog,500,1400,context),nil)
  quest.objective="defeat_mine_warden";mine.playerY=103;mine.anchors.MineExit={x=500,y=100.3,z=1502,zone="Ironveil"}
  eq(route(quest,catalog,500,1500,context).kind,"Portal")
  mine.playerY=4;eq(route(quest,catalog,500,1500,context),nil)
  mine.guardian={ownerId=7,alive=true,marker="QuarryGuardian",point={x=540,y=3,z=1350,zone="Ironveil"}}
  eq(route(quest,catalog,500,1500,context).kind,"Enemy")
  mine.guardian.ownerId=8;eq(route(quest,catalog,500,1500,context),nil)
  mine.guardian.ownerId=7;mine.guardian.alive=false;eq(route(quest,catalog,500,1500,context),nil)
  quest.objective="unknown";eq(route(quest,catalog,500,1500,context),nil)
 end)
 test("ready campaign has instruction without fabricated travel coordinates",function()
  local route=require("../src/shared/Data/QuestRoute")(require("../src/shared/Config/City"),{},W)
  local result=route({kind="Campaign",ready=true,name="รับรางวัลบทนี้ในเมนูกิลด์"},{Journal={}},9000,9000)
  eq(result.kind,"Instruction");eq(result.name,"รับรางวัลบทนี้ในเมนูกิลด์");eq(result.x,nil);eq(result.anchor,nil)
 end)
 test("Ironveil chapter7 routes through own surface entrance before enabled interior objectives",function()
  local city=require("../src/shared/Config/City");local route=require("../src/shared/Data/QuestRoute")(city,{},W)
  local anchors:any={MineEntrance={x=500,y=2.3,z=1498,zone="Ironveil"},MineExit={x=500,y=100.3,z=1502,zone="Ironveil"},
   inspect_ironveil_scales_scale_1={x=431,y=100.3,z=1464,zone="Ironveil"},inspect_ironveil_scales_scale_2={x=445,y=100.3,z=1464,zone="Ironveil"},
   interview_carrier_carrier={x=431,y=100.3,z=1473,zone="Ironveil"},MineReception={x=500,y=100.3,z=1492,zone="Ironveil"}}
  local context:any={playerId=7,inGuild=true,island={ownerId=7,exit={x=-44,z=-65}},ironveil={ownerId=7,playerY=4,anchors=anchors,floor={x=500,y=100,z=1400,width=230,depth=230}}}
  local quest:any={kind="Campaign",objective="inspect_ironveil_scales",name="Inspect scales"};local catalog={Journal={}}
  eq(route(quest,catalog,0,23,context).name,"Central City")
  context.inGuild=false;eq(route(quest,catalog,0,-1100,context).name,"Ironveil")
  eq(route(quest,catalog,0,1505,context).name,"Central City")
  local target=route(quest,catalog,500,1505,context);eq(target.name,"Ironveil");eq(target.final,false);eq(target.z,1498)
  context.ironveil.playerY=103;target=route(quest,catalog,432,1464,context);eq(target.x,431);eq(target.final,true)
  anchors.inspect_ironveil_scales_scale_1=nil;eq(route(quest,catalog,432,1464,context).x,445)
  anchors.inspect_ironveil_scales_scale_2=nil;eq(route(quest,catalog,432,1464,context),nil) -- Exit stays enabled, never selected.
  quest.objective="interview_carrier";eq(route(quest,catalog,432,1464,context).z,1473)
  quest.objective="enter_ironveil";eq(route(quest,catalog,500,1502,context).z,1492)
  context.ironveil.playerY=183;eq(route(quest,catalog,500,1502,context),nil) -- Another owner's vertical slot.
  context.ironveil.playerY=4;anchors.MineEntrance=nil;eq(route(quest,catalog,500,1505,context),nil)
  context.ironveil.ownerId=8;eq(route(quest,catalog,500,1505,context),nil)
  context.ironveil=nil;eq(route(quest,catalog,500,1505,context),nil)
  eq(route(quest,catalog,0,-1100,context).name,"Ironveil")
  eq(route(quest,catalog,0,1505,context).name,"Central City")
  context.inGuild=true;eq(route(quest,catalog,0,23,context).name,"Central City")
 end)
 test("forest evidence return keeps city guild portal route when island Registrar is not streamed",function()
  local city=require("../src/shared/Config/City");local route=require("../src/shared/Data/QuestRoute")(city,{},W)
  local arrival=city.Destinations.City;local gate=city.GuildPortalStops.Arrival
  local context:any={authored=true,roads={{a={x=gate.X,z=gate.Z},b={x=arrival.X,z=arrival.Z},width=32,y=.55,anchor="GrandAvenue"}}}
  local quest={kind="Campaign",objective="return_forest_evidence",name="Return evidence"}
  local forest=city.Destinations.Greenwood
  local target=route(quest,{Journal={}},forest.X,forest.Z,context)
  eq(target.name,"Central City");eq(target.guidance,"destination")
  target=route(quest,{Journal={}},arrival.X,arrival.Z,context)
  eq(target.name,gate.Name);eq(target.x,gate.X);eq(target.z,gate.Z);eq(target.guidance,nil)
  context.roads={};eq(route(quest,{Journal={}},arrival.X,arrival.Z,context),nil)
  context.playerId=9;context.inGuild=true;context.island={ownerId=9}
  eq(route(quest,{Journal={}},280,23,context),nil)
 end)
 test("chapter one combat objectives use only matching living owned streamed encounter markers",function()
  local city=require("../src/shared/Config/City");local route=require("../src/shared/Data/QuestRoute")(city,{},W)
  local config=require("../src/server/Config/ChapterOne")
  local chapter=config.Chapters[5];eq(chapter.Objectives[2],"protect_companion");eq(chapter.Objectives[3],"defeat_forest_guardian")
  for _,binding in ipairs({{objective="protect_companion",id="greenwood_archer",marker="ArcherCamp"},{objective="defeat_forest_guardian",id="forest_captain",marker="ForestCaptain"}})do
   local entry:any={ownerId=19,marker=binding.marker,region="Greenwood",alive=true,point={x=61,z=1409,zone="Greenwood"}}
   local context:any={authored=true,playerId=19,campaign={ownerId=19,objective=binding.objective},encounters={[binding.id]=entry}}
   local quest={kind="Campaign",objective=binding.objective,name="Combat objective"}
   local target=route(quest,{Journal={}},0,1505,context)
   eq(target.x,61);eq(target.guidance,"destination");eq(target.anchor,nil)
   entry.point={x=17,z=1335,zone="Greenwood"};eq(route(quest,{Journal={}},0,1505,context).x,17)
   entry.alive=false;eq(route(quest,{Journal={}},0,1505,context),nil);entry.alive=true
   entry.ownerId=20;eq(route(quest,{Journal={}},0,1505,context),nil);entry.ownerId=19
   entry.marker="WrongCamp";eq(route(quest,{Journal={}},0,1505,context),nil);entry.marker=binding.marker
   context.campaign.objective="disable_false_crest";eq(route(quest,{Journal={}},0,1505,context),nil);context.campaign.objective=binding.objective
   context.encounters={};eq(route(quest,{Journal={}},0,1505,context),nil)
  end
 end)
 test("authored mode retains explicitly labeled regional island and civic destination hints",function()
  local city=require("../src/shared/Config/City");local loaded=true
  local route=require("../src/shared/Data/QuestRoute")(city,{},W,function()return if loaded then {x=20,z=1400}else nil end)
  local context:any={authored=true}
  local catalog:any={Journal={enemy={Event="Defeat:scout"}},RegionalCombatAvailable=true,Bestiary={Regions={{Id="Greenwood",Entries={{Id="scout",Name="Scout",Marker="Scout",QuestEvent="Defeat:scout"}}}}}}
  local quest:any={kind="Active",id="enemy",npc="Mira",ready=false}
  local hint=route(quest,catalog,0,1505,context)
  eq(hint.kind,"Enemy");eq(hint.x,20);eq(hint.guidance,"destination");eq(hint.anchor,nil)
  eq(hint.stepLabel,"Destination direction — follow paths")
  loaded=false;eq(route(quest,catalog,0,1505,context),nil);loaded=true
  quest.ready=true;hint=route(quest,catalog,0,1505,context);eq(hint.name,"Central City");eq(hint.guidance,"destination")
  context.playerId=9;context.inGuild=true;context.island={ownerId=9,hall={x=281,z=-13,anchor="RealHall"}}
  local hall={kind="Campaign",focus="UpgradeGuildHall"}
  hint=route(hall,catalog,280,23,context);eq(hint.name,"Guild Hall");eq(hint.guidance,"destination");eq(hint.anchor,nil)
  context.island.hall=nil;eq(route(hall,catalog,280,23,context),nil)
  context.civic={id="Aurenvale",exit={x=1700,z=88}}
  hint=route(quest,catalog,1700,108,context);eq(hint.zone,"Aurenvale");eq(hint.guidance,"destination");eq(hint.anchor,nil)
  context.civic.exit=nil;eq(route(quest,catalog,1700,108,context),nil)
  context.civic.exit={x=math.huge,z=88};eq(route(quest,catalog,1700,108,context),nil)
 end)
 test("authored city route follows connected streets and courtyard instead of diagonal NPC heading",function()
  local city=require("../src/shared/Config/City");local route=require("../src/shared/Data/QuestRoute")(city,{},W)
  local function road(name:string,x1:number,z1:number,x2:number,z2:number,width:number):any
   return {a={x=x1,z=z1,y=.55,anchor=name},b={x=x2,z=z2,y=.55,anchor=name},width=width,y=.55,anchor=name}
  end
  local context:any={authored=true,roads={road("GrandAvenue",0,-680,0,-1530,32),road("TavernApproach",0,-820,-205,-820,32),road("GuildMarketAvenue",-350,-1100,350,-1100,32),road("Courtyard",0,-1010,0,-1190,180)}}
  local quest={kind="Active",npc="City Herald",ready=true};local catalog={Journal={}}
  local point=route(quest,catalog,-140,-820,context)
  eq(point.x,0);eq(point.z,-820);eq(point.final,false);eq(point.stepLabel,"Follow the city road")
  local x,z=-140,-820;local arrived=false
  for _=1,12 do
   point=route(quest,catalog,x,z,context);assert(point,"connected authored route disappeared")
   if point.final then eq(point.x,W.NPCs["City Herald"].X);eq(point.z,W.NPCs["City Herald"].Z);arrived=true;break end
   assert(point.x~=x or point.z~=z,"route failed to advance");x,z=point.x,point.z
  end
  eq(arrived,true)
  context.roads={context.roads[2],context.roads[3]};eq(route(quest,catalog,-140,-820,context),nil)
  context.roads={};eq(route(quest,catalog,0,-1100,context),nil)
 end)
 test("authored island exit respects rotated Hall egress bridge stages missing anchors and blocked legs",function()
  local city=require("../src/shared/Config/City");local route=require("../src/shared/Data/QuestRoute")(city,{},W)
  local quest={kind="Active",id="q",npc="City Herald",ready=true};local catalog={Journal={q={NPC="City Herald"}}}
  local island:any={ownerId=9,supported=true,insideHall=true,hallApproach={x=325,z=14,anchor="MovedHallThreshold"},threshold={x=338,z=14,anchor="MovedHallThreshold"},exit={x=-44,z=-65},legs={
   {point={x=280,z=4,anchor="MainPath"},reached=false,label="Follow the island path"},
   {point={x=344,z=4,anchor="ReservedAccess"},reached=false,label="Reach your island bridge"},
   {point={x=344,z=-36,anchor="IslandBridge"},reached=false,label="Reach your island bridge"},
   {point={x=344,z=-65,anchor="IslandPromenade"},reached=false,label="Cross the bridge"},
  }}
  local context:any={authored=true,playerId=9,inGuild=true,island=island}
  local point=route(quest,catalog,325,9,context);eq(point.x,325);eq(point.z,14);eq(point.stepLabel,"Leave the Hall")
  island.hallApproach=nil;point=route(quest,catalog,325,14,context);eq(point.x,338);eq(point.z,14)
  island.threshold=nil;eq(route(quest,catalog,325,14,context),nil)
  island.insideHall=false
  for i,leg in ipairs(island.legs)do
   point=route(quest,catalog,280,23,context);eq(point.anchor,leg.point.anchor);eq(point.final,false)
   island.legs[i].reached=true
  end
  point=route(quest,catalog,344,-65,context);eq(point.x,-44);eq(point.stepLabel,"Follow the promenade")
  context.clearSegment=function()return false end;eq(route(quest,catalog,344,-65,context),nil)
  context.clearSegment=nil;island.legs=nil;eq(route(quest,catalog,280,23,context),nil)
  island.supported=false;eq(route(quest,catalog,280,23,context),nil)
 end)
 test("owned island route follows live Hall and exit anchors without routing to a foreign owner",function()
  local city=require("../src/shared/Config/City");local route=require("../src/shared/Data/QuestRoute")(city,{},W)
  local context:any={playerId=7,inGuild=true,island={ownerId=7,hall={x=293,z=-14},exit={x=-44,z=-65}}}
  local quest={kind="Campaign",focus="UpgradeGuildHall"};local catalog={Journal={}}
  local target=route(quest,catalog,280,23,context)
  eq(target.x,293);eq(target.zone,"Guild");eq(target.final,true)
  context.island.hall={x=311,z=17};eq(route(quest,catalog,280,23,context).x,311)
  context.island.hall=nil;eq(route(quest,catalog,280,23,context),nil)
  context.island.ownerId=8;eq(route(quest,catalog,280,23,context),nil)
  context.island.ownerId=7
  local journal={id="return_task",kind="Active",npc="Mira",ready=true};catalog.Journal.return_task={NPC="Mira"}
  eq(route(journal,catalog,280,23,context).x,-44)
  context.island.exit=nil;eq(route(journal,catalog,280,23,context),nil)
  eq(route({kind="CampaignComplete"},catalog,280,23,context),nil)
 end)
 test("island exit is offered only for a resolved world objective and scoped quest labels stay distinct",function()
  local city=require("../src/shared/Config/City")
  local route=require("../src/shared/Data/QuestRoute")(city,{Nodes={timber={Region="Greenwood"}}},W)
  local context={playerId=7,inGuild=true,island={ownerId=7,exit={x=-44,z=-65}}}
  local catalog={Journal={gather={Event="Gather:timber"},menu={},unknown={NPC="Missing"}}}
  eq(route(nil,catalog,280,23,context),nil)
  local unresolved:{any}={{kind="Tutorial",tab="Inventory"},{kind="Novice",tab="Guild"},{kind="Active",id="menu"},{kind="Available",id="unknown",npc="Missing"},{kind="Active",id="missing",npc="Mira"}}
  for _,quest in ipairs(unresolved)do
   eq(route(quest,catalog,280,23,context),nil)
  end
  eq(route({kind="Active",id="gather",ready=false},catalog,280,23,context).name,"Central City")
  eq(route({kind="Active",id="gather",ready=true},catalog,280,23,context),nil)
  local locale=require("../src/shared/Config/Localization")
  eq(locale.translate("th","Main quests"),"เควสหลัก");eq(locale.translate("th","Side quests"),"เควสรอง");eq(locale.translate("th","NPC quests"),"เควส NPC")
  eq(locale.translate("en","Side quests"),"Side quests")
 end)
 test("campaign objective route advances island city Greenwood and keeps unavailable targets unset",function()
  local city=require("../src/shared/Config/City");local route=require("../src/shared/Data/QuestRoute")(city,{},W)
  local context:any={playerId=7,inGuild=true,island={ownerId=7,exit={x=-44,z=-65}},campaign={ownerId=7,objective="inspect_tracks",point={x=-30,z=1450,zone="Greenwood"}}}
  local quest:any={kind="Campaign",objective="inspect_tracks",name="Inspect tracks"};local catalog={Journal={}}
  eq(route(quest,catalog,280,23,context).name,"Central City")
  context.inGuild=false
  local target=route(quest,catalog,0,-1100,context);eq(target.name,"Greenwood");eq(target.z,city.Regions.Greenwood.CityGateZ)
  target=route(quest,catalog,0,1505,context);eq(target.x,-30);eq(target.final,true)
  context.campaign.point={x=-5,z=1480,zone="Greenwood"};eq(route(quest,catalog,0,1505,context).x,-5)
  context.campaign.ownerId=8;eq(route(quest,catalog,0,1505,context),nil)
  context.campaign.ownerId=7;context.campaign.objective="old";eq(route(quest,catalog,0,1505,context),nil)
  context.campaign.objective="inspect_tracks";context.campaign.point=nil;eq(route(quest,catalog,0,1505,context),nil)
  quest.objective="return_forest_evidence";context.campaign.objective=quest.objective;context.campaign.point={x=280,z=-9,zone="Guild"}
  eq(route(quest,catalog,0,1505,context).name,"Central City")
  eq(route(quest,catalog,0,-1100,context).kind,"Portal")
  context.inGuild=true;eq(route(quest,catalog,280,23,context).x,280)
 end)
 test("earned Hall directions choose the nearest city guild portal and completed campaigns invent no NPC",function()
  local city=require("../src/shared/Config/City")
  local route=require("../src/shared/Data/QuestRoute")(city,{},W)
  local quest={kind="Campaign",focus="UpgradeGuildHall"}
  for _,stop in pairs(city.GuildPortalStops)do
   local target=route(quest,{Journal={}},stop.ReturnX,stop.ReturnZ)
   eq(target.kind,"Portal");eq(target.x,stop.X);eq(target.z,stop.Z);eq(target.name,stop.Name)
  end
  eq(route(quest,{Journal={}},500,1500).name,"Central City")
  eq(route({kind="CampaignComplete"},{Journal={}},0,-1100),nil)
 end)
	test("combat quest routes use catalog events and loaded markers, then return for turn-in",function()
		local city=require("../src/shared/Config/City");local rules=require("../src/shared/Data/Expansion")
		local util=require("../src/shared/Util/TableUtil");local content=util.copy(require("../src/server/Config/Content"));content.RegionalCombatAvailable=true
		content.Bestiary={Regions=require("../src/server/Systems/AdventureFieldGuide")(require("../src/server/Config/AdventureEncounters"),require("../src/server/Config/AdventureEnemyProfiles"),require("../src/server/Config/AdventureRewards"),require("../src/server/Systems/AdventureStats"),city.RegionOrder)}
		local loaded=true;local requested=nil
		local route=require("../src/shared/Data/QuestRoute")(city,rules,W,function(region,marker)requested={region,marker};return if loaded then {x=city.Regions[region].X+17,z=city.Regions[region].Z-23} else nil end)
		local count=0
		for id,def in pairs(content.Journal) do
			if def.RequiresRegionalCombat and not def.Event:match("^Gather:") then
				count+=1;local area,enemy
				for _,a in ipairs(content.Bestiary.Regions) do for _,e in ipairs(a.Entries) do if e.QuestEvent==def.Event then area=a;enemy=e end end end
				assert(area and enemy);local quest={id=id,kind="Active",ready=false,npc=def.NPC};local before=util.copy(quest)
				local target=route(quest,content,0,-1100);eq(target.kind,"Portal");eq(target.name,area.Id);eq(target.z,city.Regions[area.Id].CityGateZ)
				for _,region in ipairs(city.RegionOrder) do
					local at=city.Destinations[region];target=route(quest,content,at.X,at.Z)
					if region==area.Id then eq(target.kind,"Enemy");eq(target.enemyId,enemy.Id);eq(target.x,city.Regions[region].X+17);eq(target.z,city.Regions[region].Z-23);eq(requested,{region,enemy.Marker})
					else eq(target.kind,"Portal");eq(target.name,"Central City") end
				end
				eq(quest,before);local at=city.Destinations[area.Id]
				loaded=false;eq(route(quest,content,at.X,at.Z),nil);loaded=true
				quest.ready=true;eq(route(quest,content,at.X,at.Z).name,"Central City");eq(route(quest,content,0,-1100).name,"Ghar")
				quest.ready=false;quest.kind="Available";eq(route(quest,content,0,-1100).kind,"NPC")
				quest.kind="Active";content.RegionalCombatAvailable=false;eq(route(quest,content,0,-1100).kind,"NPC");content.RegionalCombatAvailable=true
			end
		end
		eq(count,6)
	end)
	test("regional quest guidance routes eight quests through portals then back to the NPC",function()
		local city=require("../src/shared/Config/City");local rules=require("../src/shared/Data/Expansion")
		local content=require("../src/server/Config/Content");local util=require("../src/shared/Util/TableUtil")
		local route=require("../src/shared/Data/QuestRoute")(city,rules,W);local count=0
		for id,def in pairs(content.Journal) do
			local nodeId=def.Event and def.Event:match("^Gather:(.+)$");local node=nodeId and rules.Nodes[nodeId]
			if node and node.Region then
				count+=1;local quest={id=id,kind="Active",ready=false,npc=def.NPC};local before=util.copy(quest)
				local r=route(quest,content,0,-1100);eq(r.kind,"Portal");eq(r.name,node.Region);eq(r.z,city.Regions[node.Region].CityGateZ);eq(r.final,false)
				for _,region in ipairs(city.RegionOrder) do
					local at=city.Destinations[region];r=route(quest,content,at.X,at.Z)
					if region==node.Region then eq(r.kind,"Resource");eq(r.nodeId,nodeId);eq(r.x,city.Regions[region].X+node.X);eq(r.z,city.Regions[region].Z+node.Z);eq(r.final,true)
					else eq(r.kind,"Portal");eq(r.name,"Central City");eq(r.z,at.Z+12) end
				end
				eq(quest,before);quest.ready=true
				local at=city.Destinations[node.Region];r=route(quest,content,at.X,at.Z);eq(r.name,"Central City")
				r=route(quest,content,0,-1100);eq(r.kind,"NPC");eq(r.name,def.NPC);eq(r.x,W.NPCs[def.NPC].X)
				quest.ready=false;quest.kind="Available";eq(route(quest,content,0,-1100).kind,"NPC")
			end
		end
		eq(count,8);eq(route(nil,content,0,0),nil);eq(route(nil,content,0,-1100).name,"City Herald")
		eq(route({npc="Unknown"},content,0,-1100),nil)
	end)
	test("city waypoint uses planar arrival threshold and rounded distance",function()
		local d,a=W.progress(0,0,6,8);eq(d,10);eq(a,true)
		d,a=W.progress(0,0,0,10.1);eq(d,10);eq(a,false)
		d,a=W.progress(100,-100,100,-100);eq(d,0);eq(a,true)
	end)
	test("city waypoint arrow matches camera-local cardinal directions",function()
		eq(W.heading(0,-1),0);eq(W.heading(1,0),90);eq(W.heading(-1,0),-90);eq(math.abs(W.heading(0,1)),180)
	end)
	test("city quest navigation names resolve to current NPC stations",function()
		eq(W.NPCs.Mira.X,250);eq(W.NPCs.Mira.Z,-1030)
		eq(W.NPCs["City Herald"].X,-45);eq(W.NPCs["Expedition Master"].Z,-840)
		eq(W.NPCs["Unknown"],nil)
		for id,npc in pairs(require("../src/shared/Config/FriendlyNpcs")) do
			if string.sub(id,1,5)=="host_"then continue end -- Civic hosts are indexed on their local city map.
			eq(W.NPCs[npc.name].X,npc.x);eq(W.NPCs[npc.name].Z,npc.z)
		end
	end)
end
