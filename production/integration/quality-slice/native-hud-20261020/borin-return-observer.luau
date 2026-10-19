assert(_G.GuildborneControllerCullProbe==nil,"probe already active")
local m
for _,x in ipairs(game:GetService("CollectionService"):GetTagged("GuildborneFriendlyNPC")) do if x:GetAttribute("NpcId")=="smith_borin" then m=x end end
assert(m and m.PrimaryPart)
local data={rows={},done=false,frames=0,forbiddenFlashFrames=0}
_G.GuildborneControllerCullProbe=data
local root=m.PrimaryPart local flash=assert(m:FindFirstChild("BorinContactFlash",true))
local start=workspace:GetServerTimeNow() local oldKey local lastSample=0 local connection
connection=game:GetService("RunService").RenderStepped:Connect(function()
 local now=workspace:GetServerTimeNow() local mode=m:GetAttribute("BorinLocalPresentationState")
 local distance=(workspace.CurrentCamera.CFrame.Position-root.Position).Magnitude
 local weight=m:GetAttribute("BorinLocalWorkWeight")
 data.frames+=1
 if flash.Enabled and (mode~="Work" or distance>55) then data.forbiddenFlashFrames+=1 end
 local key=tostring(mode)..":"..tostring(flash.Enabled)..":"..tostring(distance>100)
 if key~=oldKey or now-lastSample>=.25 then table.insert(data.rows,{t=now-start,mode=mode,weight=weight,clock=m:GetAttribute("BorinLocalWorkClock"),distance=distance,flash=flash.Enabled});oldKey=key;lastSample=now end
 if now-start>=42 then connection:Disconnect();data.done=true;data.seconds=now-start end
end)
task.delay(45,function()if not data.done then connection:Disconnect();data.done=true;data.timedOut=true end end)
return "READ_ONLY_OBSERVER_STARTED_42_SECONDS"