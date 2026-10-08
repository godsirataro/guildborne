--!strict
-- Walkable native assembly; no profile writes, teleports or quest activation.
local layout=require(script.Parent.Parent.Config.TowerCourtLayout)
local build=require(script.Parent.TowerStoryKit)
return function(owner:number,slot:number):any
 assert(owner==owner and math.abs(owner)<1e15 and owner%1==0,"Invalid owner")
 assert(slot%1==0 and slot>=1 and slot<=layout.MaxSlots,"Invalid court slot")
 local V=Vector3.new
 local origin=V(layout.BaseX,layout.BaseY+(slot-1)*layout.SlotHeight,layout.BaseZ)
 local model=Instance.new("Model");model.Name="TowerCourt_"..owner
 model:SetAttribute("CampaignOwner",owner);model:SetAttribute("CourtSlot",slot);model:SetAttribute("Chapter04Court",true)
 local function part(name:string,size:Vector3,position:Vector3,color:Color3,solid:boolean):Part
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=origin+position;p.Color=color
  p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=solid;p.CanQuery=solid;p.CanTouch=false;p.Parent=model;return p
 end
 local navy=Color3.fromRGB(29,37,50);local brass=Color3.fromRGB(188,149,75)
 part("CourtWalkableFloor",V(layout.Width,1.5,layout.Depth),V(0,-.75,0),navy,true)
 for _,x in ipairs({-164,164})do part("CourtBoundary",V(1,7,330),V(x,3.5,0),navy,true)end
 for _,z in ipairs({-164,164})do part("CourtBoundary",V(330,7,1),V(0,3.5,z),navy,true)end
 part("MainAisle",V(16,.1,312),V(0,.08,0),brass,false)
 for _,z in ipairs({155,45,-65})do part("CrossAisle",V(200,.1,8),V(0,.08,z),brass,false)end
 local folder=build();local scenes={};local markers={}
 for _,def in ipairs(layout.Scenes)do
  local scene=assert(folder:FindFirstChild(def.Id)) :: Model
  scene:PivotTo(CFrame.new(origin+V(def.X,0,def.Z)));scene.Parent=model;scenes[def.Id]=scene
  for _,p in ipairs(scene:GetChildren())do
   if p:IsA("BasePart")and p:GetAttribute("StoryMarker")then markers[def.Id.."/"..p.Name]=p end
  end
 end
 folder:Destroy()
 local exit=part("CourtExit",V(3,.15,3),V(table.unpack(layout.Exit)),Color3.fromRGB(64,195,185),false)
 return {model=model,origin=origin,scenes=scenes,markers=markers,entry=origin+V(table.unpack(layout.Entry)),exit=exit}
end
