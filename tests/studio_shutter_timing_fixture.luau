--!strict
-- Isolated timing/walking fixture. Identical 54-stud first-shutter displacement;
-- uses production state machine and real prompts, never real profile receipts.
return function():any
 local player=assert(game.Players:GetPlayers()[1]);local root=assert(player.Character):WaitForChild("HumanoidRootPart") :: BasePart
 local make=require(game.ServerScriptService.Server.Systems.IronveilProtection)
 local config=require(game.ServerScriptService.Server.Config.IronveilTasks).Protection
 local model=Instance.new("Model");model.Name="ShutterTimingFixture";model.Parent=workspace
 local origin=root.Position-Vector3.new(0,3,0);local run:any=nil;local started=0
 local floor=Instance.new("Part");floor.Name="FixtureFloor";floor.Size=Vector3.new(130,1,110);floor.Position=origin+Vector3.new(-15,-.5,-12);floor.Anchored=true;floor.Parent=model
 local connections={}
 local function prompt(name:string,offset:Vector3,callback:any)
  local p=Instance.new("Part");p.Name=name;p.Size=Vector3.new(2,.15,2);p.Position=origin+offset;p.Anchored=true;p.CanCollide=false;p.Color=Color3.fromRGB(230,179,65);p.Material=Enum.Material.Neon;p.Parent=model
  local key=Instance.new("ProximityPrompt");key.ActionText=name;key.ObjectText="Timing fixture - no rewards";key.KeyboardKeyCode=Enum.KeyCode.R;key.RequiresLineOfSight=false;key.MaxActivationDistance=7;key.Parent=p
  table.insert(connections,key.Triggered:Connect(function(who)if who==player and(root.Position-p.Position).Magnitude<=9 then callback()end end))
 end
 prompt("Start",Vector3.zero,function()if not run or run.snapshot().status~="Active"then started=os.clock();run=make(config,started)end end)
 for i,lane in ipairs(config.Lanes)do prompt(lane,Vector3.new(-43+(i-1)*12,0,-33),function()if run then local ok=run.block(lane,os.clock());if ok then model:SetAttribute("LastBlockSeconds",os.clock()-started)end end end)end
 table.insert(connections,game:GetService("RunService").Heartbeat:Connect(function()
  if not run then return end
  run.step(os.clock(),root.Parent~=nil,true);local s=run.snapshot()
  model:SetAttribute("Status",s.status);model:SetAttribute("Blocks",s.blocks);model:SetAttribute("Health",s.health);model:SetAttribute("Warning",s.warning and s.warning.lane);model:SetAttribute("Blocked",s.warning and s.warning.blocked);model:SetAttribute("Seconds",os.clock()-started)
 end))
 model.Destroying:Connect(function()for _,c in ipairs(connections)do c:Disconnect()end end)
 return {origin={origin.X,origin.Y,origin.Z},first={origin.X-43,origin.Y+3,origin.Z-33},profileWrites=0}
end
