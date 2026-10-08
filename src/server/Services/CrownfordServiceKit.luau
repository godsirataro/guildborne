--!strict
-- Architecture only; preserve existing service markers and server-side rules.
local data=require(game.ReplicatedStorage.Shared.Presentation.CrownfordArchitecture)
return function(parent:Instance,kind:string,center:Vector3):Model
 local building=(data :: any)[kind];assert(building,"Unknown Crownford building")
 local model=Instance.new("Model");model.Name=kind.."Architecture";model:SetAttribute("ArtVersion","CrownfordServicesV1")
 for _,definition in ipairs(building.parts)do
  local p=Instance.new("Part");p.Name=definition.name
  p.Size=Vector3.new(table.unpack(definition.size));p.Color=Color3.fromRGB(table.unpack(definition.color))
  p.CFrame=CFrame.new(center+Vector3.new(table.unpack(definition.position)))*CFrame.Angles(math.rad(definition.rotation[1]),math.rad(definition.rotation[2]),math.rad(definition.rotation[3]))
  p.Shape=if definition.shape=="Ball"then Enum.PartType.Ball else Enum.PartType.Block
  p.Anchored=true;p.CanCollide=definition.collision;p.CanQuery=definition.collision;p.CanTouch=false
  p.Material=Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model
  if p.Name=="LanternGlass"then
   p.Material=Enum.Material.Neon
   local light=Instance.new("PointLight");light.Color=p.Color;light.Brightness=.5;light.Range=12;light.Shadows=false;light.Parent=p
  elseif p.Name=="HearthEmber"then p.Material=Enum.Material.Neon end
 end
 model.WorldPivot=CFrame.new(center);model.Parent=parent;return model
end
