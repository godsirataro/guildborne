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
 -- Preserve every native collision proxy. Entry art changes visibility only.
 local hidden={CityGateTower=true,GateLintel=true,GateBanner=true,BannerCrest=true,CourierPlaza=true,CourierCanopy=true,CanopyPost=true,CourierTable=true,SupplyCrate=true,TreeCanopy=true,TreeCrown=true}
 for _,p in ipairs(model:GetChildren())do
  if p:IsA("BasePart")and hidden[p.Name]then p.Transparency=1 end
 end
 local slate=Color3.fromRGB(48,67,83)
 local pale=Color3.fromRGB(172,166,143)
 local darkWood=Color3.fromRGB(66,47,35)
 local function decor(name:string,pos:Vector3,size:Vector3,color:Color3,material:Enum.Material?):Part
  local p=part("Entry_"..name,pos,size,color,false)
  p.Material=material or Enum.Material.SmoothPlastic
  return p
 end
 local function roof(name:string,x:number,z:number,width:number,depth:number,eave:number,rise:number)
  local angle=math.atan(rise/(width/2))
  local length=math.sqrt(width*width/4+rise*rise)
  for _,side in ipairs({-1,1})do
   local p=decor(name,V(x+side*width/4,eave+rise/2,z),V(length,.55,depth),slate,Enum.Material.Slate)
   p.CFrame=CFrame.new(p.Position)*CFrame.Angles(0,0,-side*angle)
   -- Three offset rows give the roof a restrained layered silhouette.
   for row=0,2 do
    local fraction=(row+.5)/3
    local tile=decor(name.."Course",V(x+side*(width/2*fraction+.45*math.sin(angle)),eave+rise*(1-fraction)+.45*math.cos(angle),z),V(length/3+.12,.18,depth+.15),slate,Enum.Material.Slate)
    tile.CFrame=CFrame.new(tile.Position)*CFrame.Angles(0,0,-side*angle)
   end
  end
  decor(name.."Ridge",V(x,eave+rise+.4,z),V(.7,.65,depth+.5),darkWood,Enum.Material.Wood)
 end
 local function gable(x:number,z:number,width:number,base:number,rise:number)
  -- Local WedgePart rises toward +Z. Rotate that high edge toward the ridge.
  for _,side in ipairs({-1,1})do
   local p=Instance.new("WedgePart");p.Name="Entry_GableInfill"
   p.Size=V(.35,rise,width/2);p.CFrame=CFrame.new(x+side*width/4,base+rise/2,z)*CFrame.Angles(0,-side*math.pi/2,0)
   p.Color=pale;p.Material=Enum.Material.Plaster;p.Anchored=true
   p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
   p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
   p:SetAttribute("Stage",stage);p.Parent=model
  end
 end
 -- The gate opening retains its native 20-stud width and 20-stud headroom.
 for _,x in ipairs({-15,15})do
  decor("TowerCore",V(x,12,195),V(9.6,24,11.7),pale,Enum.Material.Slate)
  for row=0,7 do
   for col=0,2 do
    decor("TowerStone",V(x-3.05+col*3.05,1.5+row*3,201),V(2.9,2.82,.35),if (row+col)%3==0 then stone else pale,Enum.Material.Slate)
   end
  end
  for _,z in ipairs({189.1,200.9})do
   for _,side in ipairs({-1,1})do decor("CornerTimber",V(x+side*4.5,13,z),V(.65,22,.65),darkWood,Enum.Material.Wood)end
  end
  decor("TowerBelt",V(x,17,195),V(9.6,.65,12),darkWood,Enum.Material.Wood)
  roof("TowerRoof",x,195,9.6,15,24,5)
  for _,z in ipairs({187.85,202.15})do gable(x,z,9.2,24.05,4.8)end
  decor("TowerKingpost",V(x,26.6,202.3),V(.5,4.8,.5),wood,Enum.Material.Wood)
  for _,side in ipairs({-1,1})do
   local rafter=decor("TowerGableRafter",V(x+side*2.3,26.6,202.3),V(math.sqrt(4.6*4.6+4.6*4.6),.4,.5),wood,Enum.Material.Wood)
   rafter.CFrame=CFrame.new(rafter.Position)*CFrame.Angles(0,0,-side*math.pi/4)
  end
  decor("TowerCloth",V(x,13,201.35),V(3.7,8,.14),navy,Enum.Material.Fabric)
  decor("ClothHem",V(x,9,201.46),V(3.7,.25,.12),gold)
  decor("ClothStem",V(x,13,201.47),V(.18,3.8,.12),gold)
  for j=0,2 do
   local crest=decor("ClothLeaf",V(x,12+j*1.1,201.5),V(.8,.8,.12),gold)
   crest.CFrame=CFrame.new(crest.Position)*CFrame.Angles(0,0,math.pi/4)
  end
 end
 decor("GateBeam",V(0,22,195),V(21.8,3.8,11.8),darkWood,Enum.Material.Wood)
 decor("GateFrontBeam",V(0,22,201),V(21.8,1.3,.45),wood,Enum.Material.Wood)
 decor("GateCrest",V(0,22,201.3),V(3,3,.3),navy,Enum.Material.Fabric)
 local crest=decor("GateStar",V(0,22,201.5),V(1.3,1.3,.15),gold)
 crest.CFrame=CFrame.new(crest.Position)*CFrame.Angles(0,0,math.pi/4)
 roof("GateConnectingRoof",0,195,20,13,24.1,3)
 for _,z in ipairs({188.75,201.25})do gable(0,z,19.2,24.15,2.8)end
 decor("GateKingpost",V(0,25.65,201.55),V(.55,2.9,.55),wood,Enum.Material.Wood)
 for _,side in ipairs({-1,1})do
  local rafter=decor("GateGableTimber",V(side*5,25.6,201.55),V(math.sqrt(109),.5,.55),wood,Enum.Material.Wood)
  rafter.CFrame=CFrame.new(rafter.Position)*CFrame.Angles(0,0,-side*math.atan(.3))
 end
 -- Elliptical ground treatment has no collision and stays below .18 studs.
 local court=decor("CourierCourt",V(-65,.09,150),V(.14,48,36),sand,Enum.Material.Sand)
 court.Shape=Enum.PartType.Cylinder;court.CFrame=CFrame.new(court.Position)*CFrame.Angles(0,0,math.pi/2)
 -- Open-sided courier shelter; no new furniture on the east approach at Z150.
 for _,x in ipairs({-79,-51})do for _,z in ipairs({140,160})do
  decor("ShelterFoot",V(x,.5,z),V(1.6,1,1.6),pale,Enum.Material.Slate)
  decor("ShelterPost",V(x,5,z),V(1.1,10,1.1),darkWood,Enum.Material.Wood)
 end end
 for _,z in ipairs({140,160})do decor("ShelterCrossBeam",V(-65,10,z),V(31,1,1.2),wood,Enum.Material.Wood)end
 for _,x in ipairs({-79,-51})do decor("ShelterSideBeam",V(x,10,150),V(1.2,1,23),wood,Enum.Material.Wood)end
 roof("ShelterRoof",-65,150,34,26,10.6,5)
 for _,z in ipairs({140,160})do for _,side in ipairs({-1,1})do
  local brace=decor("ShelterBrace",V(-65+side*12.5,9.4,z),V(3.4,.55,.6),wood,Enum.Material.Wood)
  brace.CFrame=CFrame.new(brace.Position)*CFrame.Angles(0,0,side*math.pi/5)
 end end
 for _,side in ipairs({-1,1})do
  local rafter=decor("ShelterGable",V(-65+side*8.5,13.1,163),V(math.sqrt(314),.6,.6),wood,Enum.Material.Wood)
  rafter.CFrame=CFrame.new(rafter.Position)*CFrame.Angles(0,0,-side*math.atan(5/17))
 end
 for _,x in ipairs({-77,-53})do
  decor("ShelterCloth",V(x,8.7,161.2),V(3,2.6,.16),navy,Enum.Material.Fabric)
  decor("ShelterHem",V(x,7.4,161.3),V(3,.18,.12),gold)
 end
 decor("CounterBody",V(-65,1.8,142),V(13.9,3.6,2.9),darkWood,Enum.Material.Wood)
 decor("CounterTop",V(-65,3.95,142),V(14,.25,3),wood,Enum.Material.Wood)
 for i=0,2 do
  decor("CourierLetters",V(-68+i*1.6,4.13+i*.06,142),V(1.25,.1,.85),Color3.fromRGB(224,210,170))
  decor("LetterSeal",V(-68+i*1.6,4.2+i*.06,142),V(.2,.04,.2),gold)
 end
 for i=1,3 do
  local z=141+i*6
  decor("SupplyBox",V(-83,2,z),V(3.9,3.9,3.9),wood,Enum.Material.Wood)
  for _,side in ipairs({-1,1})do decor("CrateBand",V(-83+side*1.2,2,z+2),V(.24,4,.15),darkWood,Enum.Material.Wood)end
 end
 -- Low courtyard pavers stay well outside the first dodge exercise envelope.
 for row=0,3 do for col=0,5 do
  decor("CourtPaver",V(-77+col*5,.11,164+row*2.8),V(4.4,.14,2.3),if (row+col)%2==0 then pale else sand,Enum.Material.Slate)
 end end
 stage="Landscape"
 -- Native spherical crowns replace box foliage at the eight original anchors.
 for _,pos in ipairs({V(-120,0,180),V(120,0,170),V(-115,0,100),V(120,0,35),V(-120,0,-35),V(120,0,-115),V(-100,0,-190),V(100,0,-190)})do
  local trunk=decor("TreeBark",pos+V(0,5,0),V(10,3.3,3.3),darkWood,Enum.Material.Wood)
  trunk.Shape=Enum.PartType.Cylinder;trunk.CFrame=CFrame.new(trunk.Position)*CFrame.Angles(0,0,math.pi/2)
  for _,side in ipairs({-1,1})do
   local branch=decor("TreeBranch",pos+V(side*2.3,9.5,0),V(6,.9,.9),darkWood,Enum.Material.Wood)
   branch.CFrame=CFrame.new(branch.Position)*CFrame.Angles(0,0,side*.65)
  end
  for i=0,4 do
   local angle=i*math.pi*2/5
   local crown=decor("LeafCluster",pos+V(math.cos(angle)*4.5,13+i%2*2,math.sin(angle)*4.5),V(11,10,11),if i%2==0 then Color3.fromRGB(56,104,67)else Color3.fromRGB(76,123,74),Enum.Material.Grass)
   crown.Shape=Enum.PartType.Ball
  end
  local top=decor("TreeTop",pos+V(0,20,0),V(10,11,10),Color3.fromRGB(85,132,78),Enum.Material.Grass);top.Shape=Enum.PartType.Ball
 end
 for _,pos in ipairs({V(-38,0,210),V(38,0,210),V(-97,0,169),V(102,0,190)})do
  for i=0,2 do
   local rock=decor("ArrivalRock",pos+V(i*1.5,1+i*.25,math.sin(i*2)*1.8),V(3,2+i*.5,2.6),pale,Enum.Material.Slate)
   rock.Shape=Enum.PartType.Ball
  end
  for i=0,1 do
   local shrub=decor("ArrivalPlant",pos+V(-2-i*2,1.7,2+i),V(4,3.4,3.6),Color3.fromRGB(58,105,70),Enum.Material.Grass)
   shrub.Shape=Enum.PartType.Ball
  end
 end
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
 -- Connected corridor dressing. Native routes, warning surfaces and collision
 -- proxies remain untouched; every addition is presentation-only.
 local function corridor(name:string,pos:Vector3,size:Vector3,color:Color3,material:Enum.Material?):Part
  local p=part("Corridor_"..name,pos,size,color,false)
  p.Material=material or Enum.Material.SmoothPlastic;return p
 end
 local moss=Color3.fromRGB(67,103,64)
 local earth=Color3.fromRGB(120,115,85)
 stage="Landscape"
 -- Repeated woodland shoulders connect the three destinations without filling
 -- their interior maneuver spaces. All silhouettes sit inside the native coast.
 for group,anchor in ipairs({V(-126,0,124),V(127,0,126),V(-129,0,57),V(124,0,71),V(-125,0,1),V(128,0,7)})do
  local x=anchor.X;local z=anchor.Z;local lift=(group%3)*2
  local mound=corridor("WoodlandBank",V(x+ (if x<0 then -8 else 8),1.5,z),V(21,5,28),moss,Enum.Material.Grass)
  mound.Shape=Enum.PartType.Ball
  local rock=corridor("BankStone",V(x,1.4,z+8),V(7,4,6),earth,Enum.Material.Slate);rock.Shape=Enum.PartType.Ball
  local trunk=corridor("WoodlandTrunk",V(x,6+lift/2,z),V(12+lift,2.7,2.7),darkWood,Enum.Material.Wood)
  trunk.Shape=Enum.PartType.Cylinder;trunk.CFrame=CFrame.new(trunk.Position)*CFrame.Angles(0,0,math.pi/2)
  for i=0,2 do
   local theta=i*math.pi*2/3
   local leaves=corridor("WoodlandCrown",V(x+math.cos(theta)*4,15+lift+i,z+math.sin(theta)*4),V(11+group%3,10+lift,11+i%2),if i==1 then Color3.fromRGB(83,125,75)else moss,Enum.Material.Grass)
   leaves.Shape=Enum.PartType.Ball
  end
  for i=0,2 do
   local shrub=corridor("WoodlandUnderstory",V(x+(if x<0 then 9 else -9),1.8,z-8+i*6),V(5.5,4,5.5),moss,Enum.Material.Grass)
   shrub.Shape=Enum.PartType.Ball
  end
  -- A staggered outer ridge sits behind the trees, wholly within native land.
  local side=if x<0 then -1 else 1
  for layer=0,2 do
   local height=5+(group+layer)%4*3
   local bank=corridor("OuterRidge",V(side*(139+layer*1.3),height/2-.5,z-7+layer*5),V(10-layer, height,12+group%3*2),if layer==1 then earth else moss,if layer==1 then Enum.Material.Slate else Enum.Material.Grass)
   bank.Shape=Enum.PartType.Ball
  end
  if group==2 or group==3 or group==5 then
   for sapling=0,1 do
    local sx=side*(135+sapling*4);local sz=z-5+sapling*7
    local stem=corridor("BackgroundSapling",V(sx,4,sz),V(8,1.2,1.2),darkWood,Enum.Material.Wood)
    stem.Shape=Enum.PartType.Cylinder;stem.CFrame=CFrame.new(stem.Position)*CFrame.Angles(0,0,math.pi/2)
    for tier=0,1 do
     local leaf=corridor("SaplingCrown",V(sx,8+tier*3,sz),V(6-tier,6,6-tier),Color3.fromRGB(52,89,62),Enum.Material.Grass)
     leaf.Shape=Enum.PartType.Ball
    end
   end
  end
 end
 -- Shallow irregular shoulders overlap the visual road edge, stop short of
 -- native crossings and add no collision to the central walking corridor.
 for _,z in ipairs({58,67,103,111})do for _,side in ipairs({-1,1})do
  local shoulder=corridor("RoadShoulder",V(side*17,.09,z),V(.16,15,7),Color3.fromRGB(159,151,111),Enum.Material.Sand)
  shoulder.Shape=Enum.PartType.Cylinder;shoulder.CFrame=CFrame.new(shoulder.Position)*CFrame.Angles(0,0,math.pi/2)
 end end
 -- Court edge tones frame the yard without painting over the dodge warning.
 stage="TrainingYard"
 for _,x in ipairs({42,53,65,77,88})do
  local patch=corridor("TrainingApron",V(x,.1,65),V(.16,13,9),sand,Enum.Material.Sand)
  patch.Shape=Enum.PartType.Cylinder;patch.CFrame=CFrame.new(patch.Position)*CFrame.Angles(0,0,math.pi/2)
 end
 for _,x in ipairs({43,87})do
  corridor("TrainingStandard",V(x,6,63),V(.8,12,.8),darkWood,Enum.Material.Wood)
  corridor("TrainingCloth",V(x+2,9,63),V(4,5,.18),navy,Enum.Material.Fabric)
  corridor("TrainingHem",V(x+2,6.6,63.14),V(4,.25,.15),gold)
  local badge=corridor("TrainingBadge",V(x+2,9,63.18),V(1.2,1.2,.12),gold)
  badge.CFrame=CFrame.new(badge.Position)*CFrame.Angles(0,0,math.pi/4)
 end
 for _,x in ipairs({58,72})do corridor("GearRackPost",V(x,3,61),V(.7,6,.8),wood,Enum.Material.Wood)end
 corridor("GearRackBeam",V(65,5.4,61),V(15,.6,.9),wood,Enum.Material.Wood)
 for i=0,3 do
  local shaft=corridor("TrainingSpear",V(60+i*3.2,3.3,61.6),V(.2,6.4,.2),darkWood,Enum.Material.Wood)
  shaft.CFrame=CFrame.new(shaft.Position)*CFrame.Angles(0,0,.08)
  local head=corridor("TrainingSpearTip",V(59.74+i*3.2,6.6,61.6),V(.55,.8,.25),pale,Enum.Material.Metal)
  head.CFrame=CFrame.new(head.Position)*CFrame.Angles(0,0,math.pi/4)
 end
 for _,x in ipairs({52,78})do
  local shield=corridor("PracticeShield",V(x,2,62),V(.5,4,4),wood,Enum.Material.Wood)
  shield.Shape=Enum.PartType.Cylinder;shield.CFrame=CFrame.new(shield.Position)*CFrame.Angles(0,math.pi/2,0)
  corridor("ShieldStripe",V(x,2,62.3),V(.45,3.5,.12),gold)
 end
 -- Weathered covers stay inside the existing cart collision boxes.
 stage="CaravanBend"
 for _,p in ipairs(model:GetChildren())do
  if p:IsA("BasePart")and (p.Name=="CartBed"or p.Name=="CartWheel"or p.Name=="CartCrates")then p.Transparency=1 end
 end
 local cartX=-65;local cartZ=16
 corridor("CartDetailBed",V(cartX,2,cartZ),V(9,1,14),wood,Enum.Material.Wood)
 corridor("CartDetailCargo",V(cartX,4,cartZ),V(5.9,2.9,9.9),wood,Enum.Material.Wood)
 for _,side in ipairs({-1,1})do
  for row=0,3 do corridor("CartDetailSlat",V(cartX+side*2.96,2.9+row*.7,cartZ),V(.08,.5,9.9),darkWood,Enum.Material.Wood)end
  for _,z in ipairs({11,21})do
   local wheel=corridor("CartDetailWheel",V(cartX+side*6,2,z),V(.9,4,4),darkWood,Enum.Material.Wood)
   wheel.Shape=Enum.PartType.Cylinder
   local hub=corridor("CartDetailHub",V(cartX+side*6.44,2,z),V(.1,1,1),pale,Enum.Material.Metal);hub.Shape=Enum.PartType.Cylinder
  end
 end
 -- A small dropped load on the west verge connects woodland and rescue story.
 for i=0,2 do
  corridor("SupplyBundle",V(-112+i*2.2,.9,47+i%2*2),V(1.9,1.8,3),Color3.fromRGB(169,149,106),Enum.Material.Fabric)
  corridor("BundleBinding",V(-112+i*2.2,1.82,47+i%2*2),V(.22,.12,3.05),darkWood)
 end
 corridor("CaravanStandard",V(-101,5.5,55),V(.6,11,.6),wood,Enum.Material.Wood)
 corridor("CaravanCloth",V(-99.3,8,55),V(3.4,4.4,.15),navy,Enum.Material.Fabric)
 corridor("CaravanClothHem",V(-99.3,5.9,55.1),V(3.4,.2,.12),gold)
 for _,z in ipairs({43,50,57})do
  local patch=corridor("CaravanVerge",V(-110,.09,z),V(.16,22,10),Color3.fromRGB(151,139,101),Enum.Material.Sand)
  patch.Shape=Enum.PartType.Cylinder;patch.CFrame=CFrame.new(patch.Position)*CFrame.Angles(0,0,math.pi/2)
 end
 model.WorldPivot=CFrame.identity;return model
end
