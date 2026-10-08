--!strict
-- Samples real viewport replay geometry. No player-camera or server writes.
return function():any
 local player=game.Players.LocalPlayer;local draw=require(player.PlayerScripts.Client.UI.ArchiveEndingView)
 local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig);local old=workspace:GetAttribute(config.ReducedMotionAttribute)
 workspace:SetAttribute(config.ReducedMotionAttribute,false)
 local gui=Instance.new("ScreenGui");gui.Parent=player.PlayerGui
 local host=Instance.new("Frame");host.Parent=gui
 local api:any=nil;local corners=0;local samples=0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640,704})do for _,id in ipairs({"preserve","transform","dismantle"})do
   host:ClearAllChildren();host.Size=UDim2.fromOffset(width,300)
   api=draw({text=function(parent:Instance,s:string)local l=Instance.new("TextLabel");l.Text=s;l.Parent=parent;return l end,
    button=function(parent:Instance,s:string)local b=Instance.new("TextButton");b.Text=s;b.Parent=parent;return b end},host,id,"en")
   task.wait(.04)
   local viewport=host:FindFirstChild("CampaignEndingPreview") :: ViewportFrame;local camera=assert(viewport.CurrentCamera);local model=viewport:FindFirstChildOfClass("Model") :: Model
   assert(api.Play())
   for _=1,81 do
    local cf,size=model:GetBoundingBox();local tan=math.tan(math.rad(camera.FieldOfView/2));local aspect=viewport.AbsoluteSize.X/viewport.AbsoluteSize.Y
    for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,z in ipairs({-1,1})do
     local p=camera.CFrame:PointToObjectSpace(cf:PointToWorldSpace(size*Vector3.new(x,y,z)/2))
     assert(p.Z<0 and math.abs(p.Y)/(-p.Z*tan)<.98 and math.abs(p.X)/(-p.Z*tan*aspect)<.98,"Replay cropped "..id)
     corners+=1
    end end end
    api.Step(.1);samples+=1
   end
   assert(not api.IsPlaying());api.Destroy();api=nil
  end end
  return {scenes=3,widths=3,samples=samples,boundingCorners=corners,profileWrites=0,worldCameraWrites=0}
 end)
 if api then api.Destroy()end;gui:Destroy();workspace:SetAttribute(config.ReducedMotionAttribute,old)
 if not ok then error(result)end;return result
end
