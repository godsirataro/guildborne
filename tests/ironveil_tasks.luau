--!strict
return function(test:any,eq:any)
 local config=require("../src/server/Config/IronveilTasks")
 local puzzle=require("../src/server/Systems/IronveilPuzzle")
 local protection=require("../src/server/Systems/IronveilProtection")
 test("Ironveil sequence rejects skips replay spam and backward clocks without granting completion",function()
  local definitions:{any}={config.Signal,config.Repair}
  for _,def in ipairs(definitions)do
   local run=puzzle(def.Sequence)
   eq(select(2,run.press(def.Sequence[2],1)),"TrySequenceAgain");eq(run.snapshot().progress,0)
   eq(select(2,run.press(def.Sequence[1],1.1)),"Cooling")
   eq(select(2,run.press("not_a_symbol",2)),"UnknownSymbol")
   eq(select(2,run.press(def.Sequence[1],2)),"Continue")
   eq(select(2,run.press(def.Sequence[2],1.9)),"InvalidTime")
   for i=2,#def.Sequence do eq(run.press(def.Sequence[i],2+i),true)end
   eq(run.snapshot().complete,true);eq(select(2,run.press(def.Sequence[1],10)),"AlreadyComplete")
  end
 end)
 test("shutter preparation gives the centre start time to reach the first lane without awarding blocks",function()
  local run=protection(config.Protection,100)
  eq(run.step(103.9,true,true),"Active");eq(run.snapshot().warning,nil)
  eq(run.block("left",103.9),false);eq(run.snapshot().blocks,0)
  run.step(104,true,true);eq(run.snapshot().warning.impactAt,106.5)
  -- 54 studs at normal walk speed 16, plus one second to read and interact.
  eq(54/16+1<config.Protection.Preparation+config.Protection.Warning,true)
  eq(config.Protection.Duration>config.Protection.Preparation+3*config.Protection.Warning+2*config.Protection.Interval,true)
 end)
 test("Ironveil protection requires three timely correct shutter blocks",function()
  local run=protection(config.Protection,0)
  local times={4,10.5,17}
  for i,now in ipairs(times)do
   eq(run.step(now,true,true),"Active");local warning=run.snapshot().warning
   eq(warning.lane,config.Protection.Lanes[i])
   eq(select(2,run.block(config.Protection.Lanes[i%3+1],now)),"WrongLane")
   eq(run.block(warning.lane,now+.2),true)
   eq(select(2,run.block(warning.lane,now+.3)),"AlreadyBlocked")
   run.step(warning.impactAt,true,true);eq(run.snapshot().blocks,i)
  end
  eq(run.snapshot().status,"Completed");eq(run.snapshot().health,3)
  eq(run.step(100,true,true),"Completed")
 end)
 test("Ironveil protection cannot credit late input or catch-up skips and clears stale encounters",function()
  local run=protection(config.Protection,0);run.step(4,true,true)
  eq(select(2,run.block("left",6.5)),"NoActiveWarning")
  run.step(6.5,true,true);eq(run.snapshot().health,2);eq(run.snapshot().blocks,0)
  eq(run.step(100,true,true),"Failed");eq(run.snapshot().blocks,0)
  run=protection(config.Protection,0);eq(run.step(1,true,false),"Cancelled");eq(run.block("left",1),false)
  run=protection(config.Protection,0);eq(run.step(1,false,true),"Failed")
  run=protection(config.Protection,0);run.step(4,true,true);eq(run.step(.5,true,true),"InvalidTime")
 end)
end
