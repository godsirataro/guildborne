--!strict
return function(test:any,eq:any)
 local create=require("../src/server/Systems/TowerLesson");local config=require("../src/server/Config/TowerLessons");local util=require("../src/shared/Util/TableUtil")
 local function tick(s:any,t:number):string return s.step(t,true,true,true)end
 test("Tower guard mend and combined training complete through correctly timed distinct actions",function()
  for _,role in ipairs({"Guard","Mend","Combined"})do
   local s=create(config,role,100);local now=101
   for i=1,3 do
    eq(tick(s,now),"Active");local cue=s.snapshot().cue;eq(cue.target,config.Targets[i])
    if cue.role=="Guard"then local ok,code=s.act("Guard",cue.target,now+.1);eq(ok,true);eq(code,"ShieldReady");now=cue.impactAt;tick(s,now)
    else eq(s.act("Mend",cue.target,now+.1),false);now=cue.impactAt;tick(s,now);eq(s.snapshot().health[cue.target],65);eq(s.act("Mend",cue.target,now+.1),true);now+=.1 end
    now+=1
   end
   eq(s.snapshot().status,"Completed");eq(s.snapshot().successes,3);eq(s.snapshot().health,{left=100,centre=100,right=100});eq(tick(s,now+100),"Completed")
  end
 end)
 test("Tower training rejects wrong role target duplicate and expired actions",function()
  local s=create(config,"Guard",100);tick(s,101);local before=s.snapshot()
  eq(s.act("Mend","left",101.1),false);eq(s.act("Guard","right",101.1),false);eq(s.act("Guard","outsider",101.1),false);eq(s.snapshot(),before)
  eq(s.act("Guard","left",101.2),true);eq(s.act("Guard","left",101.3),false);tick(s,104);tick(s,105)
  eq(s.act("Guard","centre",108),false);tick(s,108);eq(s.snapshot().mistakes,1);eq(s.snapshot().health.centre,65)
  local m=create(config,"Mend",100);tick(m,101);tick(m,104);eq(m.act("Mend","left",108),false);tick(m,108);eq(m.snapshot().mistakes,1)
  m=create(config,"Mend",100);tick(m,136);tick(m,139);local expired=m.snapshot()
  local ok,reason=m.act("Mend","left",140);eq(ok,false);eq(reason,"TimeExpired");eq(m.snapshot(),expired)
 end)
 test("Tower training cannot win by fast-forwarding or leaving and respects defeat and stale sessions",function()
  for _,role in ipairs({"Guard","Mend","Combined"})do
   local s=create(config,role,100);tick(s,101);tick(s,139);eq(s.snapshot().successes,0);eq(tick(s,140),"Failed");eq(s.snapshot().reason,"TimeExpired")
  end
  local s=create(config,"Guard",100);eq(s.step(101,false,true,true),"Cancelled");eq(s.act("Guard","left",102),false)
  s=create(config,"Guard",100);eq(s.step(101,true,false,true),"Failed");eq(s.snapshot().reason,"OwnerDefeated")
  s=create(config,"Mend",100);eq(s.step(101,true,true,false),"Cancelled");eq(s.snapshot().reason,"LeftLesson")
  s=create(config,"Mend",100);s.cancel();eq(tick(s,101),"Cancelled");eq(s.snapshot().cue,nil)
 end)
 test("Tower training snapshots config and invalid clocks cannot change private state",function()
  local c=util.copy(config);local s=create(c,"Guard",100);c.Warning=100;c.Targets[1]="changed";tick(s,101)
  local before=s.snapshot();eq(before.cue.target,"left");eq(before.cue.impactAt,104)
  local snap=s.snapshot();snap.health.left=0;snap.cue.target="right";eq(s.snapshot(),before)
  for _,t in ipairs({0/0,math.huge,-math.huge,100})do eq(tick(s,t),"InvalidTime");eq(s.act("Guard","left",t),false);eq(s.snapshot(),before)end
  assert(not pcall(create,config,"Damage",100));assert(not pcall(create,config,"Guard",0/0))
 end)
 test("Tower training two missed cues fail once without granting successes",function()
  local s=create(config,"Guard",100);tick(s,101);tick(s,104);tick(s,105);eq(tick(s,108),"Failed")
  eq(s.snapshot().mistakes,2);eq(s.snapshot().successes,0);eq(s.snapshot().cue,nil);eq(s.act("Guard","centre",109),false)
 end)
end
