local H=game:GetService('HttpService');local E=game:GetService('EncodingService')
local f=assert(game.ReplicatedStorage:FindFirstChild('GoblinSwordReviewRunner'))
local K=require(f.KitTransport);local kit=K.Destroy()
local M=require(f.ReviewTransport)
local first=M.Destroy();local second=M.Destroy()
f:Destroy()
local c=workspace.CurrentCamera
c.CFrame=CFrame.new(0,20,20,1,0,0,0,0.7808688282966614,0.6246950626373291,0,-0.6246950626373291,0.7808688282966614)
c.Focus=CFrame.new(0,0,-5);c.FieldOfView=70;c.CameraType=Enum.CameraType.Fixed
local expected={
 {node=game.ServerScriptService.Server.Services.HeroRig,hash='6863dfc6279df9e5f05e10c33f03e43c9b12dc48ea462cb6ef6bbc9b16449cc0'},
 {node=game.StarterPlayer.StarterPlayerScripts.Client.Controllers.ActionPose,hash='65381f67b0d36ae4c91230743526bd299ed820749e81a60449ad4c30148e498a'},
 {node=game.ReplicatedStorage.Shared.Presentation.ActionTimeline,hash='f14291c081c8b1650310f459daa661e36c5d000ee65cb9b423d2894e3f451131'}}
local hashes={}
for _,r in expected do
 local raw=E:ComputeBufferHash(buffer.fromstring(r.node.Source),Enum.HashAlgorithm.Sha256)
 local sha=(buffer.tostring(raw):gsub('.',function(x)return string.format('%02x',string.byte(x))end))
 table.insert(hashes,{path=r.node:GetFullName(),sha256=sha,unchanged=sha==r.hash})
end
local scripts={}
for _,p in game:GetDescendants() do if p:IsA('BaseScript') then table.insert(scripts,{path=p:GetFullName(),disabled=p.Disabled}) end end
return H:JSONEncode({kit=kit,first=first,second=second,fixturePresent=workspace:FindFirstChild('GoblinSwordNativeReview')~=nil,runnerPresent=game.ReplicatedStorage:FindFirstChild('GoblinSwordReviewRunner')~=nil,workspaceChildren=#workspace:GetChildren(),groups=game:GetService('PhysicsService'):GetRegisteredCollisionGroups(),http=H.HttpEnabled,mode=if game:GetService('RunService'):IsRunning() then 'Running' else 'Edit',placeId=game.PlaceId,gameId=game.GameId,camera={cframe={c.CFrame:GetComponents()},focus={c.Focus:GetComponents()},fov=c.FieldOfView,type=c.CameraType.Name},lighting={clock=game.Lighting.ClockTime,brightness=game.Lighting.Brightness,ambient={game.Lighting.Ambient.R,game.Lighting.Ambient.G,game.Lighting.Ambient.B}},sourceHashes=hashes,scripts=scripts})