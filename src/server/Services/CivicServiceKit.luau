--!strict
-- Native service architecture; no gameplay or commerce authority.
local presentation=game.ReplicatedStorage.Shared.Presentation
local crownford=require(presentation.CrownfordArchitecture)
local variants=require(presentation.CivicServiceArchitecture)
local institutions=require(presentation.CivicInstitutionArchitecture)
return function(parent:Instance,kind:string,center:Vector3,city:string):Model
 local cityData=if kind=="Forge"or kind=="QuestHall"then(institutions :: any)[city]elseif city=="Crownford"then crownford else(variants :: any)[city]
 local building=(cityData :: any)[kind];assert(building,"Unknown civic building")
 local model=Instance.new("Model");model.Name=kind.."Architecture";model:SetAttribute("ArtVersion",city.."ServicesV1")
 for _,definition in ipairs(building.parts)do
  local p=Instance.new("Part");p.Name=definition.name
  p.Size=Vector3.new(table.unpack(definition.size));p.Color=Color3.fromRGB(table.unpack(definition.color))
  p.CFrame=CFrame.new(center+Vector3.new(table.unpack(definition.position)))*CFrame.Angles(math.rad(definition.rotation[1]),math.rad(definition.rotation[2]),math.rad(definition.rotation[3]))
  p.Shape=if definition.shape=="Ball"then Enum.PartType.Ball elseif definition.shape=="Cylinder"then Enum.PartType.Cylinder else Enum.PartType.Block
  p.Anchored=true;p.CanCollide=definition.collision;p.CanQuery=definition.collision;p.CanTouch=false
  p.Material=Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model
  if p.Name=="LanternGlass"then
   p.Material=Enum.Material.Neon
   local light=Instance.new("PointLight");light.Color=p.Color;light.Brightness=.5;light.Range=12;light.Shadows=false;light.Parent=p
  elseif p.Name=="HearthEmber"or p.Name=="StarCore"or p.Name=="ForgeEmber"then p.Material=Enum.Material.Neon end
 end
 model.WorldPivot=CFrame.new(center);model.Parent=parent;return model
end
