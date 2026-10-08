--!strict
-- Static by default, with optional viewport replay. No gameplay camera or reward path.
local kit=require(game.ReplicatedStorage.Shared.Presentation.ArchiveEndingKit)
local copy=require(game.ReplicatedStorage.Shared.Config.ArchiveEndings)
return function(ui:any,parent:Instance,id:string,language:string)
 local def=copy[id];if not def then return end
 local model=kit(id);if not model then return end
 local preview=Instance.new("ViewportFrame");preview.Name="CampaignEndingPreview";preview.Size=UDim2.new(1,0,0,180)
 preview.BackgroundColor3=Color3.fromRGB(24,34,47);preview.Ambient=Color3.fromRGB(190,186,175);preview.LightColor=Color3.fromRGB(255,236,203);preview.LightDirection=Vector3.new(-1,-1,-1);preview.Parent=parent
 model.Parent=preview
 local camera=Instance.new("Camera");camera.FieldOfView=40;camera.Parent=preview;preview.CurrentCamera=camera
 local function frame(orbit:number?)
  local aspect=math.max(.25,preview.AbsoluteSize.X/math.max(1,preview.AbsoluteSize.Y))
  local target=Vector3.new(0,4.5,0);local direction=CFrame.Angles(0,orbit or 0,0):VectorToWorldSpace(Vector3.new(.65,.65,1).Unit)
  local orientation=CFrame.lookAt(direction,Vector3.zero);local box,size=model:GetBoundingBox()
  local tan=math.tan(math.rad(camera.FieldOfView/2));local distance=1
  for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,z in ipairs({-1,1})do
   local corner=box:PointToWorldSpace(size*Vector3.new(x,y,z)/2)
   local q=orientation:VectorToObjectSpace(corner-target)
   distance=math.max(distance,q.Z+math.abs(q.X)*1.12/(tan*aspect),q.Z+math.abs(q.Y)*1.12/tan)
  end end end
  camera.CFrame=CFrame.lookAt(target+direction*distance,target)
 end
 local resize=preview:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()frame(0)end);preview.Destroying:Connect(function()resize:Disconnect()end);frame(0)
 local index=if language=="th"then 2 else 1
 ui.text(parent,def.Title[index],18).Name="CampaignEnding"
 ui.text(parent,def.Body[index],16).Name="CampaignEndingDescription"
 local control:TextButton?=nil
 local function caption(active:boolean):string
  return if active then (if index==2 then "หยุดฉากจบ"else "Stop ending replay")else (if index==2 then "ดูฉากจบอีกครั้ง"else "Replay ending")
 end
 local playback=require(script.Parent.ArchiveEndingPlayback)(preview,model,frame,function(active:boolean)if control then control.Text=caption(active)end end)
 local replay:TextButton=ui.button(parent,caption(false),true,function()if playback.IsPlaying()then playback.Stop()else playback.Play()end end);replay.Name="ReplayCampaignEnding";control=replay
 ui.text(parent,if index==2 then "ฉากจบ 8 วินาที หยุดได้ทุกเมื่อ หากลดการเคลื่อนไหวจะแสดงภาพนิ่ง"else "Eight-second replay. Stop at any time. Reduced motion keeps the scene still.",14).Name="CampaignEndingPlaybackHint"
 return playback
end
