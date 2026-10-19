--!strict
local City=require("../../src/shared/Config/City")
local W=require("../../src/shared/Data/CityWaypoint")
local Route=require("../../src/shared/Data/QuestRoute")(City,{},W)
return function(test:any,eq:any)
 local function context():any
  local route={routeId="city_greenwood_west",fromZone="City",toZone="Greenwood",points={{x=0,y=.55,z=-664},{x=0,y=2,z=1526}}}
  return {authored=true,playerId=7,playerY=7,campaign={ownerId=7,objective="forest",point={x=0,y=2,z=1400,zone="Greenwood"}},
   walking={present=true,transit={routeId=route.routeId,fromZone="City",toZone="Greenwood"},route=route,routes={[route.routeId]=route},nextPoint={x=-120,y=2,z=200}}}
 end
 local q={kind="Campaign",objective="forest",name="Forest objective"}
 test("admitted walking follows actual leg in either direction without final objective",function()
  local c=context()
  for _,direction in ipairs({{"City","Greenwood"},{"Greenwood","City"}})do
   c.walking.transit.fromZone=direction[1];c.walking.transit.toZone=direction[2]
   local result=Route(q,{Journal={}},-120,0,c)
   eq(result.x,-120);eq(result.z,200);eq(result.zone,"WalkingRoute");eq(result.kind,"Walk");eq(result.final,false)
   eq(result.destinationName,direction[2]);eq(result.guidance,"walking");eq(result.anchor,nil)
  end
 end)
 test("walking keeps ready instruction and rejects unknown campaign or lost projection",function()
  local c=context()
  eq(Route({kind="Campaign",ready=true,name="Claim in journal"},{Journal={}},-120,0,c).kind,"Instruction")
  eq(Route({kind="Campaign",objective="unknown",name="Unknown"},{Journal={}},-120,0,c),nil)
  for _,key in ipairs({"route","transit","nextPoint"})do
   local saved=c.walking[key];c.walking[key]=nil
   eq(Route(q,{Journal={}},0,-720,c),nil);c.walking[key]=saved
  end
  eq(Route(nil,{Journal={}},-120,0,c),nil)
  eq(Route({kind="CampaignComplete"},{Journal={}},-120,0,c),nil)
 end)
 test("normal entry uses actual floor endpoint without implying admission",function()
  local c=context();c.authored=false;c.walking.present=false;c.walking.transit=nil
  local result=Route(q,{Journal={}},0,-720,c)
  eq(result.z,-664);eq(result.kind,"Walk");eq(result.zone,"City");eq(result.final,false)
  c.campaign.point.zone="Guild"
  result=Route(q,{Journal={}},0,1505,c)
  eq(result.z,1526);eq(result.zone,"Greenwood");eq(result.kind,"Walk")
  c.walking.route=nil;c.walking.routes={}
  eq(Route(q,{Journal={}},0,1505,c).kind,"Portal")
 end)
 test("Hall return during admitted outward crossing does not invent a quest completion",function()
  local result=Route({kind="Campaign",focus="UpgradeGuildHall",name="Return to Hall"},{Journal={}},-120,0,context())
  eq(result.kind,"Walk");eq(result.final,false);eq(result.destinationName,"Greenwood")
 end)
 local function second():any
  local c=context();c.authored=false
  local route={routeId="greenwood_ironveil_south",fromZone="Greenwood",toZone="Ironveil",points={{x=100,y=2,z=1510},{x=400,y=2,z=1515}}}
  c.walking.routes[route.routeId]=route
  c.walking.route=route;c.walking.transit={routeId=route.routeId,fromZone="Greenwood",toZone="Ironveil"}
  c.walking.nextPoint={x=300,y=2,z=1600}
  return c
 end
 local chapter2={kind="Campaign",objective="enter_ironveil",name="Enter Ironveil"}
 test("Chapter02 Greenwood approach selects second edge before Central City fallback",function()
  local c=second();c.walking.present=false;c.walking.transit=nil;c.walking.route=nil
  local r=Route(chapter2,{Journal={}},0,1505,c)
  eq(r.name,"Ironveil");eq(r.zone,"Greenwood");eq(r.x,100);eq(r.z,1510);eq(r.kind,"Walk");eq(r.final,false)
  c.walking.routes.greenwood_ironveil_south=nil
  r=Route(chapter2,{Journal={}},0,1505,c);eq(r.name,"Central City");eq(r.z,1526)
  c.walking.routes={};eq(Route(chapter2,{Journal={}},0,1505,c).kind,"Portal")
 end)
 test("second edge transit follows exact server direction even when quest asks to return",function()
  local c=second()
  for _,direction in ipairs({{"Greenwood","Ironveil"},{"Ironveil","Greenwood"}})do
   c.walking.transit.fromZone=direction[1];c.walking.transit.toZone=direction[2]
   local r=Route(chapter2,{Journal={}},300,1600,c)
   eq(r.kind,"Walk");eq(r.zone,"WalkingRoute");eq(r.destinationName,direction[2]);eq(r.x,300);eq(r.final,false)
   r=Route({kind="Campaign",focus="UpgradeGuildHall",name="Return"},{Journal={}},300,1600,c)
   eq(r.destinationName,direction[2]);eq(r.final,false)
  end
 end)
 test("Ironveil return chooses Greenwood endpoint while preserved first edge remains separate",function()
  local c=second();c.walking.present=false;c.walking.transit=nil;c.walking.route=nil
  local r=Route(q,{Journal={}},500,1515,c)
  eq(r.name,"Greenwood");eq(r.x,400);eq(r.zone,"Ironveil");eq(r.kind,"Walk")
  r=Route({kind="Campaign",focus="UpgradeGuildHall",name="Hall"},{Journal={}},500,1515,c)
  eq(r.name,"Greenwood");eq(r.x,400)
  r=Route(chapter2,{Journal={}},0,-720,c)
  eq(r.name,"Ironveil");eq(r.kind,"Portal");eq(r.z,City.Regions.Ironveil.CityGateZ)
 end)
 test("second edge never substitutes wrong RouteId or missing streamed geometry in transit",function()
  local c=second();local transit=c.walking.transit
  transit.routeId="city_greenwood_west";eq(Route(chapter2,{Journal={}},300,1600,c),nil)
  transit.routeId="greenwood_ironveil_south";c.walking.route=c.walking.routes.city_greenwood_west
  eq(Route(chapter2,{Journal={}},300,1600,c),nil)
  c.walking.route=c.walking.routes.greenwood_ironveil_south;c.walking.routes.greenwood_ironveil_south=nil
  eq(Route(chapter2,{Journal={}},300,1600,c),nil)
  eq(Route({kind="Campaign",ready=true,name="Claim"},{Journal={}},300,1600,c).kind,"Instruction")
 end)
 test("second approach rejects private mine height and malformed next point retains no beacon",function()
  local c=second();c.walking.present=false;c.playerY=100
  local r=Route(q,{Journal={}},500,1515,c);eq(r.kind,"Portal");eq(r.name,"Central City")
  c.playerY=nil;r=Route(chapter2,{Journal={}},0,1505,c);eq(r.name,"Central City")
  c=second();c.walking.nextPoint.y=0/0;eq(Route(chapter2,{Journal={}},300,1600,c),nil)
  c=second();eq(Route({kind="Campaign",objective="unknown",name="Unknown"},{Journal={}},300,1600,c),nil)
 end)

 local function third():any
  local c=second();c.walking.present=false
  local r={routeId="ironveil_ashen_south",fromZone="Ironveil",toZone="Ashen",points={{x=610,y=2.1,z=1505},{x=900,y=2.1,z=1505}}}
  c.walking.routes[r.routeId]=r;c.walking.route=r;c.walking.transit={routeId=r.routeId,fromZone="Ironveil",toZone="Ashen"}
  c.walking.nextPoint={x=750,y=2.1,z=1505};return c
 end
 local chapter3={kind="Campaign",objective="follow_ashen_supplies",name="Ashen supplies"}
 test("third road presents Chapter03 and tower approaches and Chapter02 return",function()
  for _,objective in ipairs({"follow_ashen_supplies","reach_tower_checkpoint_five"})do
   local c=third();local r=Route({kind="Campaign",objective=objective,name="Ashen"},{Journal={}},500,1505,c)
   eq(r.kind,"Walk");eq(r.zone,"Ironveil");eq(r.name,"Ashen");eq(r.x,610);eq(r.final,false)
  end
  local returns:{any}={chapter2,{kind="Campaign",focus="UpgradeGuildHall",name="Hall"}}
  for _,quest in ipairs(returns)do
   local r=Route(quest,{Journal={}},1000,1505,third())
   eq(r.kind,"Walk");eq(r.zone,"Ashen");eq(r.name,"Ironveil");eq(r.x,900);eq(r.final,false)
  end
 end)
 test("third road rejects private floors unknown heights and low Ashen annex approaches",function()
  for _,height in ipairs({0,36,100,0/0,math.huge})do
   local c=third();c.playerY=height
   eq(Route(chapter3,{Journal={}},500,1505,c).kind,"Portal")
   eq(Route(chapter2,{Journal={}},1000,1505,c).kind,"Portal")
  end
  local c=third();c.playerY=nil;eq(Route(chapter3,{Journal={}},500,1505,c).kind,"Portal")
  c=third();eq(City.region(2000,1400),"Ashen")
  eq(Route(chapter2,{Journal={}},2000,1400,c).kind,"Portal")
  c=third();c.walking.routes.ironveil_ashen_south=nil
  eq(Route(chapter3,{Journal={}},500,1505,c).name,"Central City")
 end)
 test("third transit uses only exact server direction and clears missing route",function()
  local c=third();c.walking.present=true
  for _,pair in ipairs({{"Ironveil","Ashen"},{"Ashen","Ironveil"}})do
   c.walking.transit.fromZone=pair[1];c.walking.transit.toZone=pair[2]
   local r=Route(chapter3,{Journal={}},750,1505,c)
   eq(r.kind,"Walk");eq(r.destinationName,pair[2]);eq(r.x,750);eq(r.final,false)
  end
  c.walking.transit.routeId="greenwood_ironveil_south";eq(Route(chapter3,{Journal={}},750,1505,c),nil)
  c=third();c.walking.present=true;c.walking.routes.ironveil_ashen_south=nil
  eq(Route(chapter3,{Journal={}},750,1505,c),nil)
  eq(Route({kind="Campaign",ready=true,name="Claim"},{Journal={}},750,1505,c).kind,"Instruction")
 end)
 test("owned Ashen court exit keeps priority over third road Hall return",function()
  local c=third();c.playerY=100;c.ashen={ownerId=7,playerY=100,floor={x=1000,y=95,z=1400,width=100,depth=100},anchors={CourtExit={x=1000,y=100,z=1405}}}
  local r=Route({kind="Campaign",focus="UpgradeGuildHall",name="Hall"},{Journal={}},1000,1400,c)
  eq(r.kind,"Portal");eq(r.x,1000);eq(r.y,100);eq(r.z,1405)
 end)

end
