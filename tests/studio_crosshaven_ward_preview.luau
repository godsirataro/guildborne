--!strict
-- Isolated camp activity fixture. Temporary scene/position, no gameplay profile writes.
return function():any
 assert(game:GetService("RunService"):IsStudio()and game.PlaceId==0 and game.GameId==0)
 local server=game.ServerScriptService.Server;assert(require(server.Config.Runtime).StudioPersistence=="Memory")
 local player=assert(game.Players:GetPlayers()[1]);local character=assert(player.Character);local root=assert(character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local returnTo=character:GetPivot();local art=require(server.Services.CrosshavenCourtArt)(player.UserId,3);art.model.Name="CrosshavenWardFixture";art.model.Parent=workspace
 local origin=art.scenes.refuge_camp:GetPivot().Position
 local service=require(server.Services.TowerLessonArena)({Parent=art.model,Config=require(server.Config.CrosshavenWards),TargetStyle="Ward",Title={"Camp wards · temporary tools","เกราะค่าย · เครื่องมือชั่วคราว"}})
 local start=Instance.new("ProximityPrompt");start.Name="StartWardFixture";start.ActionText="Start / retry camp wards";start.KeyboardKeyCode=Enum.KeyCode.R;start.MaxActivationDistance=8;start.RequiresLineOfSight=false;start.Parent=art.markers["refuge_camp/ward_1"]
 local completed=0;local connection=start.Triggered:Connect(function(who)
  if who~=player or (root.Position-(start.Parent :: BasePart).Position).Magnitude>9 then return end
  service.Stop()
  service.Start(player,origin,"Combined",function()return {current=character==player.Character,alive=(character:FindFirstChildOfClass("Humanoid") :: Humanoid).Health>0,near=(root.Position-origin).Magnitude<40,language="en"}end,function()completed+=1;art.model:SetAttribute("Completions",completed)end)
 end)
 local snapshot=Instance.new("BindableFunction");snapshot.Name="FixtureSnapshot";snapshot.OnInvoke=function()
  local model=art.model:FindFirstChild("TowerLesson_"..player.UserId);local p=model and model:GetAttribute("CuePosition")
  return {state=service.Snapshot(),completions=completed,cuePosition=if typeof(p)=="Vector3"then {x=p.X,y=p.Y,z=p.Z}else nil}
 end;snapshot.Parent=art.model
 local clean=Instance.new("BindableFunction");clean.Name="FixtureCleanup";clean.OnInvoke=function()connection:Disconnect();service.Destroy();art.model:Destroy();character:PivotTo(returnTo);return true end;clean.Parent=art.model
 local p=art.markers["refuge_camp/ward_1"].Position;character:PivotTo(CFrame.new(p+Vector3.new(0,3,3)));root.AssemblyLinearVelocity=Vector3.zero
 return {profileWrites=0,temporaryFixture=true,origin=tostring(origin)}
end
