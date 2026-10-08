--!strict
-- Cosmetics preserve the authored Hall collision and ground footprint.
local Catalog=require(script.Parent.Parent.Config.BuildingThemes)
local V=Vector3.new
local A={}
function A.apply(model:Model,id:string)
    local def=Catalog.Themes[id];assert(def,"Unknown Hall theme")
    local old=model:FindFirstChild("HallThemeDetails");if old then old:Destroy() end
    local body=Color3.fromRGB(table.unpack(def.Body));local roof=Color3.fromRGB(table.unpack(def.Roof));local accent=Color3.fromRGB(table.unpack(def.Accent))
    for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then
        local n=p.Name
        if n=="WindowRecess" then continue end
        p.Color=if n:find("Roof") or n=="PorchCanopy" or n=="Burgundy" then roof
            elseif n=="Ridge" or n=="DoorFrame" or n=="GuildDiamond" or n=="WindowMullion" or n=="Crossbar" then accent
            elseif n=="Foundation" or n=="Threshold" or n=="StoneButtress" then body:Lerp(Color3.new(.2,.2,.2),.35)
            else body
    end end
    local details=Instance.new("Folder");details.Name="HallThemeDetails";details.Parent=model
    local pivot=model:GetPivot()
    local function part(name:string,size:Vector3,pos:Vector3,tint:Color3,angles:Vector3?,material:Enum.Material?)
        local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=pivot*CFrame.new(pos)
        if angles then p.CFrame*=CFrame.Angles(math.rad(angles.X),math.rad(angles.Y),math.rad(angles.Z)) end
        p.Color=tint;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true
        p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Parent=details
    end
    if def.Style=="Timber" then
        for _,x in ipairs({-7,7}) do part("TimberBrace",V(.45,5,.4),V(x,6,8),accent,V(0,0,if x<0 then 35 else -35)) end
    elseif def.Style=="Canopy" then
        for _,x in ipairs({-9,9}) do
            for y=4,9,2.5 do part("LivingLeaf",V(.7,2,.4),V(x,y,8),roof,V(0,0,if x<0 then 35 else -35)) end
            part("LeafFinial",V(1.4,4,1.4),V(x,14.5,-5),accent,V(0,0,if x<0 then 15 else -15))
        end
        for _,x in ipairs({-4,4}) do part("CanopyCrown",V(9,.5,17),V(x,15,0),roof,V(0,0,if x<0 then 12 else -12)) end
    elseif def.Style=="Forge" then
        for _,x in ipairs({-7,0,7}) do
            part("RoofVent",V(2.8,2,3),V(x,15,0),body)
            part("CopperVentCap",V(3.4,.4,3.6),V(x,16.2,0),accent,nil,Enum.Material.Metal)
        end
        for _,x in ipairs({-9,9}) do for y=3,9,2 do part("WallRivet",V(.45,.45,.3),V(x,y,8),accent) end end
    elseif def.Style=="Canvas" then
        for _,x in ipairs({-9,9}) do for y=3,8,.8 do part("RopeBand",V(1.5,.18,.6),V(x,y,8),accent) end end
        part("WelcomeCloth",V(5,1.5,.2),V(0,11,8.8),roof,nil,Enum.Material.Fabric)
        part("WelcomeMark",V(.75,.75,.25),V(0,11,9),accent,V(0,0,45))
        for _,x in ipairs({-5,5}) do part("CanvasCrown",V(10.5,.4,17),V(x,15.2,0),roof,V(0,0,if x<0 then 12 else -12),Enum.Material.Fabric) end
    elseif def.Style=="Crystal" then
        for _,x in ipairs({-9,9}) do for _,z in ipairs({-6,6}) do
            part("CrystalStand",V(1.8,1,1.8),V(x,14,z),body)
            part("CrystalFinial",V(1,2.4,1),V(x,15.7,z),accent,V(0,45,15),Enum.Material.Neon)
        end end
        for i=0,7 do
            local angle=i*math.pi/4
            part("AstralCrown",V(3,.3,.35),V(math.cos(angle)*3.5,17,math.sin(angle)*3.5),accent,V(0,-math.deg(angle)+90,0),Enum.Material.Metal)
        end
    elseif def.Style=="Civic" then
        part("Cupola",V(4,3,4),V(0,16.5,0),body)
        part("CupolaCap",V(4.8,.5,4.8),V(0,18.2,0),roof)
        for i=-4,4 do part("FestivalBunting",V(.8,.8,.2),V(i*2,10.4,8.5),if i%2==0 then roof else accent,V(0,0,45),Enum.Material.Fabric) end
    end
    model:SetAttribute("BuildingTheme",id)
end
return A
