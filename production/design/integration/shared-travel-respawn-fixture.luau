assert(game.PlaceId==0 and game.GameId==0)
local Service=require(game.ServerScriptService.Server.Services.TravelService)
local folder=Instance.new("Folder");folder.Name="TravelRespawnFixture";folder.Parent=workspace
local home=Instance.new("Model");home.Name="Home";home.Parent=folder
local lab=Instance.new("Model");lab.Name="Lab";lab.Parent=folder
local function part(parent,name,pos,size)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Size=size;p.Position=pos;p.Parent=parent;return p
end
part(home,"Floor",Vector3.new(9000,0,9000),Vector3.new(80,1,80))
part(lab,"Floor",Vector3.new(9200,0,9200),Vector3.new(80,1,80))
local function actor(pos)
 local m=Instance.new("Model");m.Name="SyntheticCharacter";m.Parent=folder
 local r=part(m,"HumanoidRootPart",pos,Vector3.new(2,2,1));m.PrimaryPart=r
 local h=Instance.new("Humanoid");h.Parent=m
 return m
end
local p={Character=actor(Vector3.new(9005,4,9006)),RespawnLocation=nil,attributes={}}
function p:SetAttribute(k,v)self.attributes[k]=v end
local session={state="Active",record={},busy=false,closing=false,epoch=1,token="fixture"}
local entry=part(folder,"Entry",Vector3.new(9005,4,9006),Vector3.one)
local exit=part(folder,"Exit",Vector3.new(9200,4,9200),Vector3.one)
local plots={[p]={model=home,origin=Vector3.new(9000,0,9000),spawn=nil}}
local s=Service({town=home,regions={},guildAccessPortals={}},plots,{Travel=function()end},{
 Session=function()return session end,Gate=function()return nil end,Entry=entry,Exit=exit,Geometry=lab,
 Landing=Vector3.new(9200,4,9200),Fallback=Vector3.new(9208,4,9200),
 Contains=function(v)return math.abs(v.X-9200)<40 and math.abs(v.Z-9200)<40 end})
local expected=p.Character:GetPivot();assert(s.EnterLocal(p))
p.Character:Destroy();p.Character=actor(Vector3.new(9000,4,9000))
task.wait(.65)
local held=s.IsLocal(p);local early=p.Character:GetPivot().Position
p.Character:PivotTo(CFrame.new(9000,4,9000));s.Respawn(p);task.wait(.6)
local first={heldBeforeCallback=held,early=tostring(early),error=(p.Character:GetPivot().Position-expected.Position).Magnitude,isLocal=s.IsLocal(p)}
task.wait(2.1);assert(s.EnterLocal(p));p.Character:Destroy();p.Character=actor(Vector3.new(9000,4,9000))
session.state="Saving";task.wait(.6);s.Respawn(p);task.wait(.6)
local savingHeld=s.IsLocal(p);session.state="Active";task.wait(.65)
local second={heldDuringSaving=savingHeld,error=(p.Character:GetPivot().Position-expected.Position).Magnitude,isLocal=s.IsLocal(p)}
s.Remove(p);plots[p]=nil;folder:Destroy()
return {scope="Synthetic owner and anchored rigs; real TravelService/Heartbeat/raycast, explicitly ordered engine-pivot simulation; no actual Player LoadCharacter",first=first,second=second,cleanup=workspace:FindFirstChild("TravelRespawnFixture")==nil}
