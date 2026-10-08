--!strict
-- Generated from review/NoviceRoadKit.luau; optional course art, no reward authority.
local V=Vector3.new
local sand=Color3.fromRGB(190,173,133);local stone=Color3.fromRGB(214,203,174)
local navy=Color3.fromRGB(32,57,83);local gold=Color3.fromRGB(212,165,65);local wood=Color3.fromRGB(105,70,46)
return function():Model
 local model=Instance.new("Model");model.Name="CrownRoad";model:SetAttribute("CoursePrototype",true);model:SetAttribute("Width",300);model:SetAttribute("Depth",450)
 model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local stage="Landscape"
 local function part(name:string,pos:Vector3,size:Vector3,color:Color3,collide:boolean?):Part
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Anchored=true;p.CanCollide=collide~=false;p.CanQuery=p.CanCollide;p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p:SetAttribute("Stage",stage);p.Parent=model;return p
 end
 local function marker(name:string,pos:Vector3,title:string)
  local p=part(name,pos,V(1,.1,1),gold,false);p.Transparency=1;p:SetAttribute("RouteDestination",true)
  local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(220,50);gui.StudsOffset=V(0,4,0);gui.MaxDistance=70;gui.Parent=p
  local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.Text=title;t.TextWrapped=true;t.Font=Enum.Font.GothamMedium;t.TextSize=15;t.TextColor3=Color3.fromRGB(251,239,208);t.BackgroundColor3=navy;t.BackgroundTransparency=.1;t.Parent=gui
 end
 part("Island",V(0,-3,0),V(300,6,450),Color3.fromRGB(83,119,79))
 part("MainRoad",V(0,.025,10),V(20,.05,408),sand,false)
 for _,z in ipairs({150,90,25,-40,-105})do part("CrossPath",V(0,.03,z),V(160,.06,14),sand,false)end
 for _,x in ipairs({-145,145})do part("CoastEdge",V(x,-1,0),V(10,4,450),stone)end
 for _,pos in ipairs({V(-120,0,180),V(120,0,170),V(-115,0,100),V(120,0,35),V(-120,0,-35),V(120,0,-115),V(-100,0,-190),V(100,0,-190)})do
  part("TreeTrunk",pos+V(0,5,0),V(3,10,3),wood)
  part("TreeCanopy",pos+V(0,12,0),V(16,12,16),Color3.fromRGB(47,105,72),false)
  part("TreeCrown",pos+V(0,20,0),V(11,8,11),Color3.fromRGB(65,134,82),false)
 end
 stage="CourierCamp"
 for _,x in ipairs({-15,15})do
  part("CityGateTower",V(x,12,195),V(10,24,12),stone)
  part("GateBanner",V(x,12,201.1),V(4,9,.2),navy,false)
  part("BannerCrest",V(x,14,201.3),V(2,2,.2),gold,false)
 end
 part("GateLintel",V(0,22,195),V(22,4,12),stone)
 part("CourierPlaza",V(-65,.04,150),V(48,.08,36),sand,false)
 for _,x in ipairs({-79,-51})do for _,z in ipairs({140,160})do part("CanopyPost",V(x,5,z),V(1,10,1),wood)end end
 part("CourierCanopy",V(-65,10.5,150),V(32,1,24),navy)
 part("CourierTable",V(-65,2,142),V(14,4,3),wood)
 for i=1,3 do part("SupplyCrate",V(-83,2,141+i*6),V(4,4,4),wood)end
 marker("Arrival",V(0,3,214),"Crown Road · Chapter 00")
 marker("CourierCamp",V(-65,3,153),"01 · Courier camp")
 stage="TrainingYard"
 part("TrainingCourt",V(65,.04,90),V(56,.08,42),sand,false)
 for _,x in ipairs({50,65,80})do
  part("DummyPost",V(x,3,80),V(1,6,1),wood)
  part("DummyArms",V(x,4,80),V(6,1,1),wood)
  part("DummyHead",V(x,7,80),V(2,2,2),gold)
 end
 part("DodgeWarning",V(65,.1,99),V(12,.1,12),Color3.fromRGB(207,95,55),false)
 marker("TrainingYard",V(65,3,90),"02 · Practice and dodge")
 stage="CaravanBend"
 part("CaravanCourt",V(-65,.04,25),V(60,.08,48),sand,false)
 part("CartBed",V(-65,2,16),V(9,1,14),wood)
 for _,x in ipairs({-71,-59})do for _,z in ipairs({11,21})do part("CartWheel",V(x,2,z),V(1,4,4),Color3.fromRGB(58,58,56))end end
 part("CartCrates",V(-65,4,16),V(6,3,10),gold)
 -- Two equal-width rescue approaches reconnect at the north cross path.
 for _,x in ipairs({-84,-46})do part("RescuePath",V(x,.08,25),V(10,.08,40),Color3.fromRGB(206,191,147),false)end
 part("RescueRejoin",V(-65,.12,4),V(48,.08,10),sand,false)
 marker("CaravanRescue",V(-84,3,25),"03 · Rescue people")
 marker("CaravanSupplies",V(-46,3,25),"03 · Recover supplies")
 marker("CaravanRejoin",V(-65,3,4),"Caravan routes reconnect")
 stage="CrossroadsKeeper"
 part("KeeperCourt",V(65,.05,-40),V(56,.1,50),sand,false)
 for _,x in ipairs({43,87})do
  part("BrokenPillar",V(x,6,-56),V(4,12,4),stone)
  part("BrokenArch",V(x+(if x<65 then 4 else -4),12,-56),V(12,2,4),stone)
 end
 part("KeeperWarning",V(65,.13,-40),V(18,.06,9),Color3.fromRGB(206,102,64),false)
 part("CrestPlinth",V(86,1.5,-30),V(6,3,6),stone)
 marker("CrossroadsKeeper",V(65,3,-40),"04 · Crossroads Keeper")
 stage="FiveDisciplines"
 part("DisciplineCourt",V(-65,.05,-105),V(80,.1,40),sand,false)
 local names={"Warrior","Knight","Archer","Mage","Priest"}
 local colors={Color3.fromRGB(194,66,61),gold,Color3.fromRGB(54,146,91),Color3.fromRGB(145,91,190),Color3.fromRGB(232,227,209)}
 for i,name in ipairs(names)do
  local x=-97+(i-1)*16
  part(name.."TrainingPad",V(x,.2,-113),V(12,.4,12),colors[i])
  part(name.."Standard",V(x,5,-122),V(1,10,1),wood)
  part(name.."Pennant",V(x+2,8,-122),V(4,4,.2),colors[i],false)
  marker("Discipline_"..name,V(x,3,-113),name.." · Trial station")
 end
 marker("FiveDisciplines",V(-65,3,-98),"05 · Five disciplines")
 stage="AbandonedHall"
 part("HallForecourt",V(0,.04,-168),V(74,.08,74),sand,false)
 part("HallFloor",V(0,.2,-191),V(44,.4,34),stone)
 part("HallRear",V(0,8,-207),V(44,16,2),stone)
 for _,x in ipairs({-21,21})do part("HallSide",V(x,8,-191),V(2,16,34),stone)end
 for _,x in ipairs({-14,14})do part("HallFront",V(x,8,-175),V(16,16,2),stone)end
 part("HallDoorLintel",V(0,14,-175),V(12,4,2),stone)
 part("HallRoof",V(0,17,-191),V(48,2,38),navy)
 part("HallBanner",V(0,12,-173.8),V(4,3,.2),gold,false)
 marker("HallForecourt",V(0,3,-157),"06 · Clear and restore the Hall")
 marker("HallInterior",V(0,3,-192),"Future guild registration")
 model.WorldPivot=CFrame.identity;return model
end
