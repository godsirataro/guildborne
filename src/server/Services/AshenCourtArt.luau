--!strict
-- Original native interior assembly. Does not teleport players or bind quests.
local layout=require(script.Parent.Parent.Config.AshenCourtLayout)
local build=require(script.Parent.AshenStoryKit)
return function(owner:number,slot:number):any
 assert(slot%1==0 and slot>=1 and slot<=layout.MaxSlots,"Invalid mine slot")
 local origin=Vector3.new(layout.BaseX,layout.BaseY+(slot-1)*layout.SlotHeight,layout.BaseZ)
 local model=Instance.new("Model");model.Name="AshenCourt_"..owner;model:SetAttribute("CampaignOwner",owner);model:SetAttribute("CourtSlot",slot)
 local floor=Instance.new("Part");floor.Name="CourtWalkableFloor";floor.Size=Vector3.new(layout.Width,1.5,layout.Depth);floor.Position=origin-Vector3.new(0,.75,0)
 floor.Anchored=true;floor.Color=Color3.fromRGB(82,77,94);floor.Material=Enum.Material.Slate;floor.CanTouch=false;floor.Parent=model
 local function part(name:string,size:Vector3,position:Vector3,color:Color3,solid:boolean)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=origin+position;p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=solid;p.CanQuery=solid;p.CanTouch=false;p.Parent=model;return p
 end
 for _,x in ipairs({-114,114})do part("CourtBoundary",Vector3.new(1,7,230),Vector3.new(x,3.5,0),Color3.fromRGB(44,42,58),true)end
 for _,z in ipairs({-114,114})do part("CourtBoundary",Vector3.new(230,7,1),Vector3.new(0,3.5,z),Color3.fromRGB(44,42,58),true)end
 part("MainAisle",Vector3.new(12,.1,214),Vector3.new(0,.08,0),Color3.fromRGB(185,121,73),false)
 for _,z in ipairs({-39,26,91})do part("CrossAisle",Vector3.new(140,.1,8),Vector3.new(0,.08,z),Color3.fromRGB(151,121,78),false)end
 local folder=build();local scenes={};local markers={}
 for _,def in ipairs(layout.Scenes)do
  local scene=assert(folder:FindFirstChild(def.Id)) :: Model;scene:PivotTo(CFrame.new(origin+Vector3.new(def.X,0,def.Z)));scene.Parent=model;scenes[def.Id]=scene
  for _,p in ipairs(scene:GetChildren())do if p:IsA("BasePart")and p:GetAttribute("StoryMarker")then markers[def.Id.."/"..p.Name]=p end end
 end
 folder:Destroy()
 local exit=part("CourtExit",Vector3.new(3,.15,3),Vector3.new(table.unpack(layout.Exit)),Color3.fromRGB(73,184,186),false)
 return {model=model,origin=origin,scenes=scenes,markers=markers,entry=origin+Vector3.new(table.unpack(layout.Entry)),exit=exit}
end
