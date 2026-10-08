--!strict
-- Walkable planning geometry only. No NPC, quest, save or commerce authority.
local V=Vector3.new
local definitions:{{string|Color3}}={
    {"Crownford","crownford_clock_gate",Color3.fromRGB(235,225,202),Color3.fromRGB(135,53,64)},
    {"Sylvaris","sylvaris_council_tree",Color3.fromRGB(235,225,202),Color3.fromRGB(46,119,84)},
    {"Deepforge","deepforge_grand_forge",Color3.fromRGB(65,73,81),Color3.fromRGB(180,113,64)},
    {"Astralis","astralis_observatory",Color3.fromRGB(61,64,123),Color3.fromRGB(88,201,214)},
    {"Crosshaven","crosshaven_charter_pavilion",Color3.fromRGB(204,193,163),Color3.fromRGB(49,130,138)},
    {"Ironroot","ironroot_feast_hall",Color3.fromRGB(114,63,42),Color3.fromRGB(211,156,62)},
}
local plans:{[string]:{style:string,ground:Color3,services:{{string|number}},spine:{{number}}}}={
 Crownford={style="Formal civic avenue",ground=Color3.fromRGB(105,124,96),services={{"Market",-58,28},{"Forge",58,28},{"Tavern",-58,-28},{"QuestHall",58,-28}},spine={{0,108},{0,43},{0,-13},{0,-70}}},
 Sylvaris={style="Garden promenade",ground=Color3.fromRGB(74,113,81),services={{"Market",-60,38},{"Forge",60,12},{"Tavern",-60,-22},{"QuestHall",60,-48}},spine={{0,108},{-12,65},{10,20},{-8,-25},{0,-70}}},
 Deepforge={style="Foundry processional",ground=Color3.fromRGB(92,94,94),services={{"Market",-62,34},{"Forge",62,34},{"Tavern",-62,-24},{"QuestHall",62,-24}},spine={{0,108},{0,60},{0,0},{0,-70}}},
 Astralis={style="Astral diamond walk",ground=Color3.fromRGB(85,88,115),services={{"Market",-60,42},{"Forge",60,18},{"Tavern",-60,-20},{"QuestHall",60,-44}},spine={{0,108},{16,62},{0,18},{-16,-24},{0,-70}}},
 Crosshaven={style="Harbor exchange loop",ground=Color3.fromRGB(147,137,107),services={{"Market",-56,38},{"Forge",56,38},{"Tavern",-70,-22},{"QuestHall",70,-22}},spine={{0,108},{0,62},{-24,20},{0,-28},{0,-70}}},
 Ironroot={style="Shared hearth lanes",ground=Color3.fromRGB(119,102,72),services={{"Market",-64,32},{"Forge",64,32},{"Tavern",-64,-28},{"QuestHall",64,-28}},spine={{0,108},{0,60},{20,22},{0,-18},{0,-70}}},
}
return function(makeLandmarks:any):Folder
    local root=Instance.new("Folder");root.Name="CityDistrictPrototypes"
    local landmarks=makeLandmarks()
    for index,definition in ipairs(definitions) do
        local city=tostring(definition[1]);local wall=definition[3] :: Color3;local accent=definition[4] :: Color3
        local plan=plans[city]
        local model=Instance.new("Model");model.Name=city;model:SetAttribute("ReviewOnly",true);model:SetAttribute("CityIndex",index)
        model:SetAttribute("Width",200);model:SetAttribute("Depth",250);model.Parent=root
        model:SetAttribute("StreetIdentity",plan.style)
        local function part(name:string,pos:Vector3,size:Vector3,color:Color3,collide:boolean):Part
            local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.CanCollide=collide;p.CanQuery=collide;p.CanTouch=false
            p.Size=size;p.Position=pos;p.Color=color;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model;return p
        end
        local function marker(name:string,pos:Vector3,title:string)
            local p=part(name,pos,V(2,.1,2),accent,false);p.Transparency=1;p:SetAttribute("RouteDestination",true)
            local label=Instance.new("BillboardGui");label.Size=UDim2.fromOffset(220,54);label.StudsOffset=V(0,4,0);label.MaxDistance=60;label.Parent=p
            local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.Text=title;text.TextWrapped=true;text.TextSize=14
            text.Font=Enum.Font.GothamMedium;text.TextColor3=Color3.fromRGB(250,239,209);text.BackgroundColor3=Color3.fromRGB(25,35,49);text.BackgroundTransparency=.15;text.Parent=label
        end
        local ground=part("DistrictGround",V(0,-.5,0),V(200,1,250),plan.ground,true);model.PrimaryPart=ground
        local function road(a:Vector3,b:Vector3,width:number,name:string)
            local length=(b-a).Magnitude
            local p=part(name,(a+b)/2,V(width,.04,length),Color3.fromRGB(158,157,142),false)
            p.CFrame=CFrame.lookAt((a+b)/2,b)
        end
        for i=2,#plan.spine do
            local a,b=plan.spine[i-1],plan.spine[i]
            road(V(a[1],.025,a[2]),V(b[1],.025,b[2]),18,"MainAvenue")
        end
        part("CivicPlaza",V(0,.03,-70),V(54,.06,46),Color3.fromRGB(166,165,152),false)
        road(V(-58,.025,88),V(58,.025,88),12,"GateWalk")
        if city=="Crosshaven"then road(V(0,.025,62),V(24,.025,20),14,"HarborLoop");road(V(24,.025,20),V(0,.025,-28),14,"HarborLoop")end
        -- Low boundary curbs have wide entrance/exit gaps; they cannot trap an avatar.
        for _,x in ipairs({-99,99}) do part("DistrictBorder",V(x,.3,0),V(1,.6,250),wall,true) end
        for _,x in ipairs({-57,57}) do part("NorthBorder",V(x,.3,-124),V(84,.6,1),wall,true) end
        local services:{{string|number}}=plan.services
        for _,entry in ipairs(services) do
            local name=tostring(entry[1]);local x=entry[2] :: number;local z=entry[3] :: number
            local center=V(x,0,z)
            road(V(0,.025,z+18),V(x,.025,z+18),12,"ServiceLane")
            part(name.."Floor",center+V(0,.15,0),V(30,.3,24),wall,true)
            part(name.."Rear",center+V(0,6,-11.5),V(30,12,1),wall,true)
            for _,side in ipairs({-1,1}) do
                part(name.."Side",center+V(side*14.5,6,0),V(1,12,24),wall,true)
                part(name.."Front",center+V(side*10.5,6,11.5),V(9,12,1),wall,true)
            end
            part(name.."Lintel",center+V(0,10.5,11.5),V(12,3,1),accent,true)
            part(name.."Roof",center+V(0,12.5,0),V(32,1,26),accent,true)
            part(name.."Counter",center+V(0,1.5,-7),V(16,3,3),accent,true)
            marker(name,center+V(0,3,0),city.." · "..name.."\nService placeholder")
        end
        -- Edge dressing stays outside service doors and the central travel lanes.
        for _,x in ipairs({-88,88})do for _,z in ipairs({-92,-58,-2,58})do
            if city=="Sylvaris"then
                part("GardenBed",V(x,.4,z),V(14,.8,18),accent,true)
                part("GardenTree",V(x,4,z),V(2,7,2),Color3.fromRGB(104,74,48),true)
                part("GardenCanopy",V(x,9,z),V(12,5,12),Color3.fromRGB(78,146,97),false)
            elseif city=="Deepforge"then
                part("OreCrate",V(x,1.5,z),V(8,3,9),wall,true)
                part("CopperRail",V(x,3.2,z),V(8.4,.5,9.4),accent,false)
            elseif city=="Astralis"then
                part("CrystalPlinth",V(x,1,z),V(7,2,7),wall,true)
                local crystal=part("WayfindingCrystal",V(x,5,z),V(2,6,2),accent,false);crystal.Material=Enum.Material.Neon
            elseif city=="Crosshaven"then
                part("CargoStack",V(x,2,z),V(9,4,9),Color3.fromRGB(137,94,60),true)
                part("CargoBinding",V(x,2,z),V(9.2,.6,9.2),accent,false)
            elseif city=="Ironroot"then
                part("SharedBench",V(x,1.5,z),V(8,3,13),wall,true)
                part("HearthBannerPole",V(x,7,z-6),V(1,14,1),wall,true)
                part("HearthBanner",V(x+2.5,10,z-6),V(5,5,.3),accent,false)
            else
                part("CivicPlanter",V(x,1,z),V(10,2,12),wall,true)
                part("CivicHedge",V(x,3,z),V(9,3,11),Color3.fromRGB(70,121,78),false)
            end
        end end
        local landmark=landmarks:FindFirstChild(tostring(definition[2])) :: Model?
        assert(landmark,"Missing landmark for "..city);landmark:PivotTo(CFrame.new(0,0,-70));landmark.Parent=model
        marker("Landmark",V(0,4,-70),city.." · Civic landmark")
        local gates:{{string|number}}={{"GuildIslandPortal",58,"Guild island portal"},{"RegionalGate",-58,"Regional travel gate"}}
        for _,entry in ipairs(gates) do
            local x=entry[2] :: number;local name=tostring(entry[1])
            part(name.."Pad",V(x,.2,88),V(18,.4,18),accent,true)
            for _,side in ipairs({-1,1}) do part(name.."Post",V(x+side*7,6,85),V(2,12,2),wall,true) end
            part(name.."Arch",V(x,12,85),V(16,2,2),accent,true)
            marker(name,V(x,3,88),tostring(entry[3]).."\nPlanning placeholder")
        end
        marker("Arrival",V(0,3,108),city.." · City layout prototype")
        marker("Plaza",V(0,3,12),plan.style.." · 18 studs wide")
        -- Set a ground-level stable pivot before the review world arranges districts.
        model.PrimaryPart=nil;model.WorldPivot=CFrame.identity
    end
    landmarks:Destroy();return root
end
