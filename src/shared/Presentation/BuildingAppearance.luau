--!strict
-- Original native geometry prototypes. Decorative parts never change collision.
local Catalog=require(script.Parent.Parent.Config.BuildingThemes)
local V=Vector3.new
local A={}
local function color(rgb:{number}):Color3 return Color3.fromRGB(rgb[1],rgb[2],rgb[3]) end
function A.apply(model:Model,id:string)
    local def=Catalog.Themes[id];if not def then return end
    local old=model:FindFirstChild("ThemeDetails");if old then old:Destroy() end
    local folder=Instance.new("Folder");folder.Name="ThemeDetails";folder.Parent=model
    local body,roof,accent=color(def.Body),color(def.Roof),color(def.Accent)
    for _,p in ipairs(model:GetChildren()) do if p:IsA("BasePart") then
        p.Color=if p.Name=="Roof" then roof elseif p.Name=="Foundation" then body:Lerp(Color3.new(0,0,0),.25) else body
    end end
    -- Base geometry is authored around zero before the model receives its world pivot.
    local function part(name:string,size:Vector3,pos:Vector3,tint:Color3,angles:Vector3?,material:Enum.Material?):Part
        local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=CFrame.new(pos)
        if angles then p.CFrame*=CFrame.Angles(math.rad(angles.X),math.rad(angles.Y),math.rad(angles.Z)) end
        p.Color=tint;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true
        p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=folder;return p
    end
    for _,x in ipairs({-6,6}) do part("DoorTrim",V(.35,6,.4),V(x,4,6),accent) end
    part("Lintel",V(12.5,.5,.5),V(0,7,6),accent)
    if def.Style=="Timber" then
        for _,x in ipairs({-3.7,3.7}) do part("Gable",V(7.8,.6,15),V(x,9.5,0),roof,V(0,0,if x<0 then 24 else -24)) end
        for _,x in ipairs({-3,3}) do part("TimberBrace",V(.5,5,.5),V(x,4,-6),accent,V(0,0,if x<0 then 35 else -35)) end
        part("Chimney",V(2,4,2),V(4,11,-4),body:Lerp(Color3.new(1,1,1),.3))
    elseif def.Style=="Canopy" then
        for i=-2,2 do part("LeafRoof",V(3.4,.7,15),V(i*2.6,10-math.abs(i)*.6,0),roof:Lerp(accent,math.abs(i)*.06),V(0,0,-i*10)) end
        for _,x in ipairs({-6,6}) do for y=2,6,2 do part("Leaf",V(.8,1.7,.4),V(x,y,6.3),roof,V(0,0,if x<0 then 32 else -32)) end end
    elseif def.Style=="Forge" then
        part("CopperCap",V(13,.7,13),V(0,8.8,0),roof,nil,Enum.Material.Metal)
        for _,x in ipairs({-5,5}) do
            part("Chimney",V(2,4,2),V(x,10.5,-4),body)
            part("ChimneyCap",V(2.5,.5,2.5),V(x,12.6,-4),accent,nil,Enum.Material.Metal)
            for _,z in ipairs({-5,0,5}) do part("Rivet",V(.5,.5,.5),V(x,9.35,z),accent) end
        end
    elseif def.Style=="Canvas" then
        for _,x in ipairs({-3.5,3.5}) do part("CanvasRoof",V(7.6,.35,15),V(x,9,0),roof,V(0,0,if x<0 then 12 else -12),Enum.Material.Fabric) end
        for _,x in ipairs({-6,6}) do for _,z in ipairs({-6,6}) do for y=5.8,6.6,.4 do part("RopeBand",V(1.2,.16,1.2),V(x,y,z),roof) end end end
        part("WelcomeBanner",V(3,2,.15),V(0,6.3,6.2),accent,nil,Enum.Material.Fabric)
        part("BannerEmblem",V(.8,.8,.2),V(0,6.3,6.3),roof,V(0,0,45))
    elseif def.Style=="Crystal" then
        for i=1,3 do part("SteppedRoof",V(15-i*2,.6,15-i*2),V(0,8+i*.65,0),roof) end
        for _,x in ipairs({-5,5}) do for _,z in ipairs({-5,5}) do
            part("FinialBase",V(1.5,1.3,1.5),V(x,9.1,z),body)
            part("Crystal",V(.8,1.6,.8),V(x,10.6,z),accent,V(0,45,20),Enum.Material.Neon)
        end end
    elseif def.Style=="Civic" then
        for _,x in ipairs({-3.7,3.7}) do part("Gable",V(7.8,.6,15),V(x,9.5,0),roof,V(0,0,if x<0 then 24 else -24)) end
        part("Cupola",V(3.5,2.5,3.5),V(0,11,0),body)
        part("CupolaRoof",V(4.2,.5,4.2),V(0,12.5,0),roof)
        for i=-2,2 do part("Bunting",V(.8,.8,.15),V(i*2,6.3,6.3),if i%2==0 then roof else accent,V(0,0,45),Enum.Material.Fabric) end
    end
    model:SetAttribute("BuildingTheme",id)
end
function A.preview(id:string):Model
    local model=Instance.new("Model");model.Name="ThemePreview"
    local function part(name:string,size:Vector3,pos:Vector3)
        local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true;p.Parent=model;return p
    end
    model.PrimaryPart=part("Foundation",V(14,1,14),V(0,.5,0))
    part("Roof",V(15,1,15),V(0,8,0))
    for _,x in ipairs({-6,6}) do for _,z in ipairs({-6,6}) do part("Post",V(1,7,1),V(x,4,z)) end end
    part("Workstation",V(6,2,3),V(0,2,-4));A.apply(model,id);return model
end
return A
