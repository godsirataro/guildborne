--!strict
local City=require("../../src/shared/Config/City")
local W=require("../../src/shared/Data/CityWaypoint")
local Route=require("../../src/shared/Data/QuestRoute")(City,{},W)
return function(test:any,eq:any)
 local function context():any
  return {authored=true,playerId=7,campaign={ownerId=7,objective="forest",point={x=0,y=2,z=1400,zone="Greenwood"}},
   walking={present=true,transit={fromZone="City",toZone="Greenwood"},route={points={{x=0,y=.55,z=-664},{x=0,y=2,z=1526}}},nextPoint={x=-120,y=2,z=200}}}
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
  c.walking.route=nil
  eq(Route(q,{Journal={}},0,1505,c).kind,"Portal")
 end)
 test("Hall return during admitted outward crossing does not invent a quest completion",function()
  local result=Route({kind="Campaign",focus="UpgradeGuildHall",name="Return to Hall"},{Journal={}},-120,0,context())
  eq(result.kind,"Walk");eq(result.final,false);eq(result.destinationName,"Greenwood")
 end)
end
