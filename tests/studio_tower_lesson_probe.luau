--!strict
-- Synthetic prompt callbacks and clock. Does not move the player or grant progression.
return function(factory:any,create:any,config:any):any
 local player=assert(game.Players:GetPlayers()[1]);local root=assert(player.Character and player.Character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local initial=root.CFrame;local beat=Instance.new("BindableEvent");local callbacks={};local time=100;local completions=0
 local eligible:any={current=true,alive=true,near=true,language="en"}
 local service=factory({CreateLesson=create,Config=config,Now=function()return time end,Heartbeat=beat.Event,
  BindPrompt=function(prompt,callback)callbacks[prompt.Name]={prompt=prompt,callback=callback};return {Disconnect=function()end}end})
 local phases=0;local ownerChecks=0;local distanceChecks=0
 local function tick(t:number)time=t;beat:Fire();task.wait(.04)end
 local function press(action:string,target:string,near:boolean?,who:any?)
  local e=assert(callbacks[action.."_"..target]);local p=e.prompt.Parent :: BasePart;local original=p.Position
  if near then p.Position=root.Position-Vector3.new(0,1,0)end;e.callback(who or player);p.Position=original
 end
 local ok,result=pcall(function():any
  for _,role in ipairs({"Guard","Mend","Combined"})do
   callbacks={};time=100;eligible={current=true,alive=true,near=true,language="en"}
   local passed,reason=service.Start(player,root.Position+Vector3.new(200,0,0),role,function()return eligible end,function(who,mode)assert(who==player and mode==role);completions+=1 end)
   assert(passed and reason=="Started");local model=assert(workspace:FindFirstChild("TowerLesson_"..player.UserId));local count=0;for _ in pairs(callbacks)do count+=1 end;assert(count==6)
   assert(not service.Start(player,root.Position,role,function()return eligible end,function()end))
   local now=101
   for i=1,3 do
    tick(now);local v=service.Snapshot();local cue=v.cue;assert(cue)
    press(cue.role,cue.target,true,{});assert(not service.Snapshot().cue.acted);ownerChecks+=1
    press(cue.role,cue.target,false);assert(not service.Snapshot().cue.acted);distanceChecks+=1
    if cue.role=="Guard"then time=now+.1;press("Guard",cue.target,true);assert(service.Snapshot().cue.acted);tick(cue.impactAt);now=cue.impactAt
    else
     press("Mend",cue.target,true);assert(service.Snapshot().phase=="Warning")
     tick(cue.impactAt);assert(service.Snapshot().health[cue.target]==65);time=cue.impactAt+.1;press("Mend",cue.target,true);now=time
    end
    phases+=1;now+=1
   end
   tick(now);assert(service.Snapshot().status=="Completed");assert(completions==if role=="Guard"then 1 elseif role=="Mend"then 2 else 3)
   for _,e in pairs(callbacks)do assert(not e.prompt.Enabled)end
   tick(now+1);assert(model:GetAttribute("LessonStatus")=="Completed")
   eligible.language="th";tick(now+2);local label=model:FindFirstChild("Instructions",true) :: TextLabel;assert(label.Text:find("ผ่านบทฝึก",1,true))
   service.Stop();assert(not model.Parent and service.Snapshot()==nil)
  end
  time=200;eligible={current=true,alive=true,near=true,language="en"}
  assert(service.Start(player,root.Position+Vector3.new(200,0,0),"Guard",function()return eligible end,function()error("Unexpected completion")end))
  local cancelled=assert(workspace:FindFirstChild("TowerLesson_"..player.UserId));eligible.current=false;tick(201);assert(not cancelled.Parent and service.Snapshot()==nil)
  assert(not service.Start(player,root.Position,"Guard",function()return eligible end,function()end))
  assert((root.Position-initial.Position).Magnitude<1,"Moved actual character")
  return {roles=3,completedLessons=completions,cues=phases,ownerRejections=ownerChecks,distanceRejections=distanceChecks,promptsPerLesson=6,languageStates=2,staleCleanup=true,profileWrites=0,actualPlayerJourney=false}
 end)
 service.Destroy();beat:Destroy();if not ok then error(result)end;return result
end
