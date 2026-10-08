--!strict
local C=require("../src/shared/Config/CivicCities")
local City=require("../src/shared/Config/City")
return function(test:any,eq:any,harness:any,Content:any,Util:any,Locale:any)
 test("each city has a bilingual nonreward welcome guide within its bounds",function()
  local speakers=require("../src/shared/Config/FriendlyNpcs");local names={}
  for _,id in ipairs(C.Order)do local s=speakers["host_"..string.lower(id)];assert(s and #s.en>140 and #s.th>140 and s.nameTh~=s.name)
   assert(C.contains(id,s.x,s.z));assert(not names[s.name]);names[s.name]=true;eq(s.homeCity,nil)
   for _,q in pairs(Content.Journal)do assert(q.NPC~=s.name)end
  end
 end)
 test("six civic routes require their own claimed envoy charter and preserve earned state",function()
  for _,id in ipairs(C.Order)do
   local d=(C.Definitions :: any)[id];eq(Content.CivicTravel[id],d.Quest);assert(Content.Journal[d.Quest])
   local h=harness();h.setup();local before=Util.copy(h.data())
   eq(h.send("TravelZone",{zone=id}),"CivicRouteLocked");eq(h.data(),before)
   h.data().settlement.journal[d.Quest]={state="Active",progress=1}
   eq(h.send("TravelZone",{zone=id}),"CivicRouteLocked")
   h.data().settlement.journal[d.Quest]={state="Claimed",progress=Content.Journal[d.Quest].Count}
   before=Util.copy(h.data());eq(h.send("TravelZone",{zone=id}),"OK");eq(h.data(),before)
   assert(Locale.Thai[id]);eq(Locale.Thai[id],d.Thai)
  end
 end)
 test("civic arrival fallbacks are distinct safe-city bounds separated from combat regions",function()
  for _,id in ipairs(C.Order)do local d=(City.Destinations :: any)[id]
   assert(C.contains(id,d.X,d.Z)and C.contains(id,d.FallbackX,d.FallbackZ));assert(d.Z~=d.FallbackZ)
   eq(City.region(d.X,d.Z),nil);eq(City.allowsCombat(d.X,d.Y,d.Z,d.X,0),false)
   for _,other in ipairs(C.Order)do if other~=id then eq(C.contains(other,d.X,d.Z),false)end end
   for _,n in ipairs({0/0,math.huge,-math.huge})do eq(C.contains(id,n,d.Z),false);eq(C.contains(id,d.X,n),false)end
  end
  eq(C.contains("unknown",0,0),false)
 end)
end
