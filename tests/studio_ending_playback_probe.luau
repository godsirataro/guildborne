--!strict
return function():any
 local player=game.Players.LocalPlayer;local shared=game.ReplicatedStorage.Shared
 local factory=require(player.PlayerScripts.Client.UI.ArchiveEndingPlayback)
 local kit=require(shared.Presentation.ArchiveEndingKit);local config=require(shared.Config.VFXConfig)
 local old=workspace:GetAttribute(config.ReducedMotionAttribute)
 local gui=Instance.new("ScreenGui");gui.Parent=player.PlayerGui
 local checks=0;local controllers={}
 local function check(value:boolean)assert(value,"Playback check "..(checks+1));checks+=1 end
 local ok,result=pcall(function():any
  workspace:SetAttribute(config.ReducedMotionAttribute,false)
  for _,id in ipairs({"preserve","transform","dismantle"})do
   local viewport=Instance.new("ViewportFrame");viewport.Size=UDim2.fromOffset(300,180);viewport.Parent=gui
   local model=assert(kit(id));model.Parent=viewport
   local original:any={};for _,p in ipairs(model:GetDescendants())do if p:IsA("BasePart")then original[p]=p.CFrame end end
   local orbit=0;local events=0
   local api=factory(viewport,model,function(angle:number)orbit=angle end,function()events+=1 end,true);table.insert(controllers,api)
   check(api.Play());api.Step(3);check(api.IsPlaying());check(math.abs(orbit)>0)
   local moved=0;for p,base in pairs(original)do if p.CFrame~=base then moved+=1 end;check(not p.CanCollide and not p.CanQuery and not p.CanTouch)end;check(moved>0)
   api.Stop();check(not api.IsPlaying());check(orbit==0);for p,base in pairs(original)do check(p.CFrame==base)end
   check(api.Play());for _=1,241 do api.Step(1/30)end;check(not api.IsPlaying());for p,base in pairs(original)do check(p.CFrame==base)end
   check(api.Play());api.Step(2);viewport.Visible=false;api.Step(.1);check(not api.IsPlaying());viewport.Visible=true
   check(api.Play());api.Step(2);workspace:SetAttribute(config.ReducedMotionAttribute,true);task.wait();check(not api.IsPlaying());check(not api.Play())
   for p,base in pairs(original)do check(p.CFrame==base)end
   workspace:SetAttribute(config.ReducedMotionAttribute,false);check(api.Play());api.Step(2);viewport:Destroy();check(not api.IsPlaying());check(not api.Play());api.Destroy();check(events>0)
  end
  return {checks=checks,scenes=3,normalCompletion=true,stopRestores=true,hiddenStops=true,reducedMotionStops=true,destroyStops=true,profileWrites=0,serverRequests=0,worldCameraWrites=0}
 end)
 for _,api in ipairs(controllers)do api.Destroy()end
 gui:Destroy();workspace:SetAttribute(config.ReducedMotionAttribute,old)
 if not ok then error(result)end;return result
end
