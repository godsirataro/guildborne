--!strict
local make=require("../src/shared/Data/MusicTransition")
local config=require("../src/shared/Config/MusicConfig")
return function(test:any,eq:any)
 local function count(values:any):number local n=0;for _,gain in pairs(values)do n+=1;assert(gain>=0 and gain<=1)end;assert(n<=2);return n end
 test("music starts quietly crossfades and retires the previous voice",function()
  local m=make(2);eq(m.Set("home",0),true);eq(m.Step(0),{home=0});eq(m.Step(1),{home=.5});eq(m.Step(2),{home=1})
  m.Set("city",2);eq(m.Step(3),{home=.5,city=.5});eq(m.Step(4),{city=1})
  m.Set(nil,4);eq(m.Step(5),{city=.5});eq(m.Step(6),{})
 end)
 test("music rapid retargeting never exceeds two voices or unit gain",function()
  local m=make(2)
  for i=0,1000 do local t=i*.017;m.Set("track"..tostring(i%7),t);local values=m.Step(t);count(values);local total=0;for _,gain in pairs(values)do total+=gain end;assert(total<=1+1e-9)end
 end)
 test("music reverses a crossfade without restarting its retained track",function()
  local m=make(2);m.Set("a",0);m.Step(2);m.Set("b",2);m.Step(3);m.Set("a",3)
  eq(m.Step(3),{a=.5,b=.5});eq(m.Step(4),{a=.75,b=.25});eq(m.Step(5),{a=1})
 end)
 test("music same route updates do not restart an in-progress fade",function()
  local m=make(2)
  for i=0,40 do eq(m.Set("a",i*.05),true);m.Step(i*.05)end
  eq(m.Step(2),{a=1});m.Set(nil,2);m.Set(nil,3);eq(m.Step(4),{})
 end)
 test("music rejects malformed and backwards clocks and resets cleanly",function()
  local m=make(2);m.Set("a",10)
  for _,t in ipairs({9,0/0,math.huge,-math.huge})do eq(m.Set("b",t),false);eq(m.Step(t),nil)end
  eq(m.Step(12),{a=1});m.Clear();eq(m.Step(0),{});eq(m.Set("b",0),true)
 end)
 test("music shipped config has no live assets and every mapped motif exists",function()
  eq(next(config.AssetIds),nil);local n=0;for _ in pairs(config.Tracks)do n+=1 end;eq(n,7)
  for _,key in pairs(config.ZoneTracks)do eq(config.Tracks[key],true)end
  eq(config.ZoneTracks.Guild,"guild_haven")
 end)
end
