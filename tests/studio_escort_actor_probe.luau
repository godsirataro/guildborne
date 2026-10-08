--!strict
-- Synthetic owner evidence and isolated NPC only; no player or profile grants.
return function(makeActor:any,makeScene:any,makeNpc:any):any
 local scene=makeScene();scene.Name="EscortSceneFixture";scene.Parent=workspace
 local shaft=scene:FindFirstChild("signal_shaft") :: Model;assert(shaft)
 local origin=Vector3.new(8000,0,8000);shaft:PivotTo(CFrame.new(origin))
 local folder=makeNpc(true,"dwarf_traveler");folder.Parent=scene
 local template=folder:FindFirstChild("dwarf_traveler") :: Model;assert(template)
 template.Parent=nil;folder:Destroy()
 local active:any=nil;local models={};local checks=0
 local ok,result=pcall(function():any
  local function start(mode:string):(any,Model,()->number)
   local m=template:Clone();m.Name="Escort_"..mode;m.Parent=scene;table.insert(models,m)
   local route={origin+Vector3.new(-13,0,5),origin+Vector3.new(-7,0,5),origin+Vector3.new(-7,0,13),origin+Vector3.new(0,0,13)}
   local calls=0
   local actor=makeActor(m,route,{shaft},function():any
    return {current=mode~="stale",alive=mode~="dead",npcAlive=mode~="npc_dead",position=m:GetPivot().Position+Vector3.new(if mode=="far"then 50 else 1,0,0)}
   end,function()calls+=1 end,true)
   active=actor;return actor,m,function()return calls end
  end
  local actor,m,calls=start("walk")
  for _=1,42 do actor.Step(.1)end
  assert(actor.Snapshot().status=="Completed");assert((m:GetPivot().Position-(origin+Vector3.new(0,0,13))).Magnitude<.001)
  assert(calls()==1);for _=1,5 do actor.Step(.25)end;assert(calls()==1);assert(m:GetAttribute("EscortMoving")==false);checks+=5;actor.Destroy()
  actor,m,calls=start("far");for _=1,120 do actor.Step(.25)end
  assert(actor.Snapshot().reason=="OwnerLeft"and actor.Snapshot().traveled==0 and calls()==0);checks+=3;actor.Destroy()
  for _,mode in ipairs({"stale","dead","npc_dead"})do
   actor,m,calls=start(mode);actor.Step(.25)
   assert(actor.Snapshot().status==(if mode=="stale"then "Cancelled"else "Failed"));assert(calls()==0);checks+=2;actor.Destroy()
  end
  local obstruction=Instance.new("Part");obstruction.Anchored=true;obstruction.Size=Vector3.new(2,6,5);obstruction.Position=origin+Vector3.new(-10.5,3,5);obstruction.Parent=shaft
  actor,m,calls=start("blocked");for _=1,20 do actor.Step(.25)end
  assert(actor.Snapshot().reason=="PathBlocked"and actor.Snapshot().status=="Failed");assert(calls()==0);checks+=2;actor.Destroy();obstruction:Destroy()
  actor,m,calls=start("removed");m:Destroy();actor.Step(.25);assert(actor.Snapshot().reason=="ModelRemoved"and calls()==0);checks+=1;actor.Destroy()
  return {checks=checks,routeStuds=21,completionCallbacks=1,models=#models,actualPlayerJourney=false,profileWrites=0}
 end)
 if active then active.Destroy()end;template:Destroy();scene:Destroy()
 if not ok then error(result)end;return result
end
