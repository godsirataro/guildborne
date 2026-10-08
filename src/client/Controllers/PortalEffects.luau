--!strict
-- Local ambient geometry only. Does not change prompts, travel state or collision.
local Collection=game:GetService("CollectionService")
local Run=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local V=Vector3.new
local palette={Guild=Color3.fromRGB(120,171,245),City=Color3.fromRGB(225,188,105),Greenwood=Color3.fromRGB(115,202,135),Ironveil=Color3.fromRGB(222,151,91),Ashen=Color3.fromRGB(170,139,238)}
type Entry={anchor:BasePart,serial:number,model:Model?,parts:{Part},low:boolean?}
return function(scope:Instance?,manual:boolean?):any
 local root=scope or workspace;local entries:{[Instance]:Entry}={};local serial=0;local closed=false
 local connections:{RBXScriptConnection}={};local output=Instance.new("Folder");output.Name="GuildbornePortalEffects";output.Parent=workspace
 local api:any={}
 local function clear(entry:Entry)
  if entry.model then entry.model:Destroy();entry.model=nil end;table.clear(entry.parts);entry.low=nil
 end
 local function remove(value:Instance)local entry=entries[value];if entry then clear(entry);entries[value]=nil end end
 local function add(value:Instance)
  if closed or entries[value] or not value:IsA("BasePart") or not value:IsDescendantOf(root) then return end
  serial+=1;entries[value]={anchor=value,serial=serial,parts={}}
 end
 local function make(entry:Entry,low:boolean)
  clear(entry);local model=Instance.new("Model");model.Name="PortalAura";model:SetAttribute("Destination",entry.anchor:GetAttribute("TravelDestination"));model.Parent=output;entry.model=model;entry.low=low
  for i=1,(if low then 8 else 12) do
   local p=Instance.new("Part");p.Name=if i<=(if low then 6 else 10) then "Arc" else "Rune"
   p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Material=Enum.Material.Neon
   p.Color=palette[entry.anchor:GetAttribute("TravelDestination") :: string];p.Transparency=.3;p.Parent=model;table.insert(entry.parts,p)
  end
 end
 function api.Step(position:Vector3,now:number,low:boolean,reduced:boolean,touch:boolean)
  if closed then return end
  local nearest={};local wanted:{[Entry]:boolean}={}
  for value,entry in pairs(entries) do
   if not value:IsDescendantOf(root) then remove(value);continue end
   local destination=entry.anchor:GetAttribute("TravelDestination")
   if type(destination)~="string" or not palette[destination] then clear(entry);continue end
   local distance=(entry.anchor.Position-position).Magnitude
   if distance<=100 then table.insert(nearest,{entry=entry,distance=distance}) end
  end
  table.sort(nearest,function(a,b)return if a.distance==b.distance then a.entry.serial<b.entry.serial else a.distance<b.distance end)
  local budget=if touch or low then 2 else 3
  for i=1,math.min(budget,#nearest) do wanted[nearest[i].entry]=true end
  for _,entry in pairs(entries) do
   if not wanted[entry] then clear(entry);continue end
   if not entry.model or entry.low~=low or entry.model:GetAttribute("Destination")~=entry.anchor:GetAttribute("TravelDestination") then make(entry,low) end
   local count=if low then 6 else 10;local phase=if reduced then 0 else now*.22
   local rx=math.max(1,entry.anchor.Size.X/2-.3);local ry=math.max(1,entry.anchor.Size.Y/2-.3)
   local face=if entry.anchor.CFrame:PointToObjectSpace(position).Z>=0 then 1 else -1
   for i,p in ipairs(entry.parts) do
    local rune=i>count;local angle=if rune then (i-count-1)*math.pi+phase else (i-1)*math.pi*2/count+phase
    local scale=if rune then .65 else 1;local x,y=rx*math.sin(angle)*scale,ry*math.cos(angle)*scale
    p.Size=if rune then V(.45,.45,.15) else V(math.min(1.7,rx*math.pi/count),.12,.12)
    p.CFrame=entry.anchor.CFrame*CFrame.new(x,y,face*(entry.anchor.Size.Z/2+.25))*CFrame.Angles(0,0,if rune then math.pi/4 else math.atan2(-ry*math.sin(angle),rx*math.cos(angle)))
    p.Transparency=if reduced then .35 else .32+.06*math.sin(now*1.4+i*.4)
   end
  end
 end
 function api.Stats():any
  local tracked,active,parts=0,0,0;for _,entry in pairs(entries) do tracked+=1;if entry.model then active+=1;parts+=#entry.parts end end
  return {tracked=tracked,active=active,parts=parts,closed=closed}
 end
 function api.Destroy()
  if closed then return end;closed=true;for _,c in ipairs(connections) do c:Disconnect() end;table.clear(connections)
  for _,entry in pairs(entries) do clear(entry) end;table.clear(entries);output:Destroy()
 end
 for _,value in ipairs(Collection:GetTagged("GuildborneTravelPortal")) do add(value) end
 table.insert(connections,Collection:GetInstanceAddedSignal("GuildborneTravelPortal"):Connect(add))
 table.insert(connections,Collection:GetInstanceRemovedSignal("GuildborneTravelPortal"):Connect(remove))
 table.insert(connections,root.Destroying:Connect(api.Destroy))
 if not manual then
  local elapsed=0;table.insert(connections,Run.RenderStepped:Connect(function(dt)
   elapsed+=dt;if elapsed<1/30 then return end;elapsed=0
   local camera=workspace.CurrentCamera;if not camera then return end
   local low=workspace:GetAttribute(Config.QualityAttribute)=="Low" or (Input.TouchEnabled and workspace:GetAttribute(Config.QualityAttribute)~="High")
   api.Step(camera.CFrame.Position,workspace:GetServerTimeNow(),low,workspace:GetAttribute(Config.ReducedMotionAttribute)==true,Input.TouchEnabled)
  end))
 end
 return api
end
