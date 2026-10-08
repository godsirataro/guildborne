--!strict
-- Theme finishes preserve the authored shape, collision, pivot and plant/book colors.
local Catalog=require(script.Parent.Parent.Config.BuildingThemes)
local A={}
local materials:{[string]:Enum.Material}={}
for _,material in ipairs(Enum.Material:GetEnumItems()) do materials[material.Name]=material end
local accent={BrassInlay=true,Crest=true,WelcomeDiamond=true,Edge=true,East=true,Crossbar=true}
local cloth={Runner=true,BackRest=true,Rug=true,Cloth=true,Blanket=true,Pillow=true,Cushion=true}
local keep={Soil=true,Stem=true,Leaf=true,Flower=true,Book=true,North=true,Mattress=true}
local dark={Leg=true,BackPost=true,Back=true,Pole=true}
local function color(rgb:{number}):Color3 return Color3.fromRGB(rgb[1],rgb[2],rgb[3]) end
function A.apply(model:Model,id:string)
    local def=Catalog.Themes[id];if not def then return end
    for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") and p.Name~="CollisionProxy" then
        local original=p:GetAttribute("FurnitureOriginalColor")
        if typeof(original)~="Color3" then original=p.Color;p:SetAttribute("FurnitureOriginalColor",original) end
        local material=p:GetAttribute("FurnitureOriginalMaterial")
        if type(material)~="string" then material=p.Material.Name;p:SetAttribute("FurnitureOriginalMaterial",material) end
        p.Material=materials[material :: string] or Enum.Material.SmoothPlastic
        if id=="human" or keep[p.Name] then p.Color=original :: Color3
        elseif accent[p.Name] or p.Name=="Glow" then
            p.Color=color(def.Accent)
            if id=="mage" and p.Name=="Glow" then p.Material=Enum.Material.Neon end
        elseif cloth[p.Name] then p.Color=color(def.Roof);p.Material=Enum.Material.Fabric
        else
            p.Color=if dark[p.Name] then color(def.Body):Lerp(Color3.new(0,0,0),.4) else color(def.Body)
            if id=="dwarf" then p.Material=Enum.Material.Metal end
        end
    end end
    model:SetAttribute("BuildingTheme",id)
end
return A
