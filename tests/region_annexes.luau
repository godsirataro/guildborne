--!strict
return function(test:any,eq:any)
 local city=require("../src/shared/Config/City");local layout=require("../src/server/Config/TowerCourtLayout")
 test("Tower private court fits Ashen navigation without extending surface combat",function()
  for _,x in ipairs({-layout.Width/2,0,layout.Width/2})do for _,z in ipairs({-layout.Depth/2,0,layout.Depth/2})do
   local px,pz=layout.BaseX+x,layout.BaseZ+z;eq(city.region(px,pz),"Ashen")
   eq(city.regionCombat("Ashen",px,5,pz),false);eq(city.regionCombat("Ashen",px,layout.BaseY+3,pz),false)
  end end
  for _,scene in ipairs(layout.Scenes)do eq(city.region(layout.BaseX+scene.X,layout.BaseZ+scene.Z),"Ashen")end
  eq(city.region(layout.BaseX+layout.Entry[1],layout.BaseZ+layout.Entry[3]),"Ashen")
 end)
 test("Court annex does not connect the void or alter original regions and city bounds",function()
  for _,p in ipairs({{1834,1400},{2166,1400},{2000,1234},{2000,1566},{1500,1400},{2000,-720}})do eq(city.region(p[1],p[2]),nil)end
  for _,id in ipairs(city.RegionOrder)do local r=city.Regions[id];eq(city.region(r.X,r.Z),id);eq(city.regionCombat(id,r.X,5,r.Z),true)end
  eq(city.contains(2000,1400),false);eq(city.contains(0,-720),true)
  eq(city.region(0/0,1400),nil);eq(city.region(math.huge,1400),nil)
 end)
end
