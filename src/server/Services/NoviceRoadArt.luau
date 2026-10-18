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
 stage="TrainingYard"
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
 -- Replace the northern grid with one connected settlement road and purposeful
 -- branches. These thin coatings are below the original warning bottom (.05).
 local function settlement(name:string,pos:Vector3,size:Vector3,color:Color3,material:Enum.Material?):Part
  local p=part("Settlement_"..name,pos,size,color,false);p.Material=material or Enum.Material.SmoothPlastic;return p
 end
 for _,p in ipairs(model:GetChildren())do
  if p:IsA("BasePart")then
   if p.Name=="MainRoad"or p.Name=="TrainingCourt"or p.Name=="CaravanCourt"or p.Name=="RescuePath"or p.Name=="RescueRejoin"or (p.Name=="CrossPath"and p.Position.Z>=25)then p.Transparency=1 end
  end
 end
 stage="Landscape"
 settlement("SouthMainRoad",V(0,.025,-99.5),V(20,.05,189),sand,Enum.Material.Plastic)
 -- One simplified polygon, triangulated offline: no overlapping ground top faces.
 -- Recipe and measured footprint changes: production/world/novice-entry/ground-union.
 stage="Landscape"
 local groundWedges={
  {-121.944537226593,9.29159329008897,6.34877306800585,19.1775087278569,-0.306411241759583,1},
  {-127.86341,28,6.34877306800585,20.0672380049848,2.83518141183021,-1},
  {-106.241947453186,2.43683108017793,16.3017473384373,11.1450220487673,-0.73477915646056,1},
  {-121.944537226593,19.815387290089,16.3017473384373,35.6987840106444,2.40681349712923,-1},
  {-88.382783726593,-1.82261120991103,3.18054151654896,19.3828865386721,-0.802728167569974,1},
  {-112.160820226593,21.145237790089,3.18054151654896,46.7357071391167,2.33886448601982,-1},
  {-65,-7.411904,15.5104404959332,26.3947816764676,-1.03951995958542,1},
  {-104.0853735,15.555945,15.5104404959332,64.2735922875845,2.10207269400437,-1},
  {-43.204196,-3.2267675,12.6835851223509,8.80845926249103,-1.17987012832913,1},
  {-88.7780365,15.555945,12.6835851223509,89.7768383589514,1.96172252526066,-1},
  {-31.7511975,9.16176,18.0930870730792,6.35680641670531,-1.36444356768745,1},
  {-82.2895695,19.7410815,18.0930870730792,96.9107894265358,1.77714908590234,-1},
  {-20.3680325,16.53694,0.896856079513905,12.9125832831394,-1.37312845423734,1},
  {-77.325038,27.9444725,0.896856079513905,103.26370127211,1.76846419935245,-1},
  {0,-5,16.6692145723039,22.4974950948431,-0.933121158067874,1},
  {-13.9746995,5.3543645,16.6692145723039,12.2878518382642,2.20847149552192,-1},
  {0.0253005000000002,5.3543645,27.9429160183598,20.7174758512598,-0.000312989404197695,1},
  {0.011895,48.1848865,27.9429160183598,64.9435723445197,3.1412796641856,-1},
  {46.054837,52.894215,6.36601410138512,17.0423935763471,-0.683090540634936,1},
  {37.8572025,62.9676705,6.36601410138512,8.93264960791499,2.45850211295486,-1},
  {45.7045455,58.3675035,1.72402403597871,25.9177662916319,-0.616669386194374,1},
  {33.5941165,75.4510865,1.72402403597871,15.9635564516593,2.52492326739542,-1},
  {65,48.294048,13.1578288732564,17.8750657160107,-0.936250985359268,1},
  {41.791751,65.377631,13.1578288732564,39.7607436307449,2.20534166823053,-1},
  {83.945163,52.894215,14.3900666956021,11.1308263325898,-1.18859283708956,1},
  {52.889571,65.377631,14.3900666956021,55.8105052794873,1.95299981650023,-1},
  {61.0872055,75.4510865,10.4180209668014,63.5086644723584,1.95299981650023,1},
  {92.1427975,62.9676705,10.4180209668014,3.43266713971872,-1.18859283708956,-1},
  {96.3381470771953,72.893207067185,9.43769320509662,7.02551669569617,-1.49836126096908,1},
  {61.0872055,75.4510865,9.43769320509662,63.6617276775755,1.64323139262071,-1},
  {100.521137317127,90.3425211645175,24.7529694751988,7.96506097367579,-1.85612014903172,1},
  {64.9322635771954,79.903334567185,24.7529694751988,66.2116078889986,1.28547250455807,-1},
  {65.2701957399315,92.9004005973325,2.2253368421996,74.1432807441214,-1.82611515119136,1},
  {21.8272555,81.561129,2.2253368421996,15.6535596690765,1.31547750239843,-1},
  {46.9058564035573,101.193041843267,23.0982690621112,74.1010393809103,1.31547750239843,1},
  {90.3487966434888,112.532313440599,23.0982690621112,15.6958010322876,-1.82611515119136,-1},
  {32.328635798911,100.920574475657,14.9618813679308,52.5892205214988,1.01330963197332,1},
  {65.2613032024683,121.452572318923,14.9618813679308,25.0283939161847,-2.12828302161648,-1},
  {23.4906755580899,93.3103866625377,2.87983041897728,31.5287211518133,0.736128609260857,1},
  {41.8461223570009,113.569917138194,2.87983041897728,23.1474529016706,-2.40546404432894,-1},
  {15.2584765,91.9073095,11.4691377925118,19.5187265187298,0.64504145509375,1},
  {24.7759630580899,104.556652162538,11.4691377925118,12.1412431703092,-2.49655119849604,-1},
  {15.2584765,91.9073095,4.97883235427872,22.084678738994,-2.80606475605192,1},
  {0.011895,48.1848865,4.97883235427872,70.5243601379336,0.335527897537874,-1},
  {14.7907615,138.1930635,15.2892596459334,68.4806076776907,-2.97191876397332,1},
  {1.2971825,59.431152,15.2892596459334,91.3382319797549,0.16967388961647,-1},
  {14.2498493862004,190.711946850673,2.88404761338176,34.9238585950064,-2.98996547344391,1},
  {-0.45582,94.4706405,2.88404761338176,159.79281516644,0.151627180145884,-1},
  {13.2652407724009,213.494642701347,5.6572302582558,9.98987976793931,-3.01902321330374,1},
  {0.756270386200442,111.950035350673,5.6572302582558,194.63447481504,0.122569440286052,-1},
  {5.25648575979288,221.314706650211,11.9233812018465,4.27660426662715,-3.07732584738257,1},
  {-1.44042861379956,117.253336350673,11.9233812018465,204.276673825517,0.064266806207228,-1},
  {-15.1390396264076,187.020076299538,11.339424195123,53.9434331186701,0.233511046126801,1},
  {-7.48466675281512,219.201595099076,11.339424195123,12.2151513986241,-2.90808160746299,-1},
  {-65.0035845089403,149.875051405387,19.7718319768651,10.20389121481,1.1792330424833,1},
  {-39.9624515,160.2141225,19.7718319768651,43.9793066779277,-1.9623596111065,-1},
  {-14.9162410089403,148.383785905387,21.2150130021271,6.70791504459525,-1.9623596111065,1},
  {-39.9573740178807,138.044714810775,21.2150130021271,47.4752828481425,1.1792330424833,-1},
  {-14.9162410089403,148.383785905387,5.26948714829968,21.6172478849606,0.153777255391533,1},
  {-8.20994312640756,191.649950799538,5.26948714829968,65.9483950564824,-2.98781539819826,-1},
  {-13.4978720089403,122.956096405387,4.02226436374057,28.4182629962296,0.107826811345235,1},
  {-7.2618681353479,180.565304704925,4.02226436374057,87.4732142609181,-3.03376584224456,-1},
  {-15.093939,55.3964275,3.89180264847974,35.198426177021,0.00226347469748623,1},
  {-15.013789,90.8065265,3.89180264847974,35.6219532405535,-3.13932917889231,-1},
  {-13.107728,73.202954,4.63782093069375,70.6683575432741,0.0677974680363054,1},
  {-6.79157412640756,166.222261299538,4.63782093069375,115.798640397281,-3.07379518555349,-1},
  {-13.5686385,26.750792,0.658350544223244,22.0874423593642,0.064266806207228,1},
  {-6.87172412640756,130.812162299538,0.658350544223244,186.465835732779,-3.07732584738257,-1},
  {-70.525644,38.1583245,21.8036368859654,112.586026352517,1.76846419935245,1},
  {-13.5686385,26.750792,21.8036368859654,3.5902582027324,-1.37312845423734,-1},
  {-78.9163673000777,39.8855757437415,3.34746996351865,97.8747372879527,1.57717021570335,1},
  {-21.5786013000777,39.5201062437415,3.34746996351865,16.8031241819262,-1.56442243788645,-1},
  {-88.624856034041,47.9129178508743,16.5884754750806,78.9689909870879,1.54298196917611,1},
  {-39.6778133341187,49.2746995946158,16.5884754750806,18.9629739392957,-1.59861068441368,-1},
  {-87.0763567339633,52.6238641071327,5.73246000208122,14.9540559973685,1.37176550672978,1},
  {-64.8499732680043,57.106952958007,5.73246000208122,30.3939409868728,-1.76982714686001,-1},
  {-110.8512395,43.429829,1.62475296060978,35.3736155345502,1.33592928723911,1},
  {-71.612685534041,52.8189528508743,1.62475296060978,45.3188813663769,-1.80566336635069,-1},
  {-117.931705,47.011897,10.8074901189343,23.7895940341922,1.29003033649006,1},
  {-100.9195345,51.917932,10.8074901189343,11.6213152759227,-1.85156231709973,-1},
  {-122.045552,45.9652405,3.75418555718297,18.51476388411,0.863610553491565,1},
  {-112.113847,54.4533435,3.75418555718297,7.61465683244123,-2.27798210009823,-1},
 }
 for i,w in ipairs(groundWedges)do
  local p=Instance.new("WedgePart")
  p.Name="Settlement_GroundUnion_"..i
  p.Size=V(.03,w[3],w[4])
  p.CFrame=CFrame.new(w[1],.03,w[2])*CFrame.Angles(0,w[5],0)*CFrame.Angles(0,0,w[6]*math.pi/2)
  p.Color=sand;p.Material=Enum.Material.Sand
  p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p:SetAttribute("Stage",stage);p.Parent=model
 end
 -- Overlapping outer banks form a continuous wooded backdrop rather than six
 -- isolated humps. All higher silhouettes remain on the outer woodland edge.
 stage="Landscape"
 for _,side in ipairs({-1,1})do
  for i=0,5 do
   local z=3+i*25;local height=7+(i%3)*2
   local bank=settlement("ForestScreen",V(side*(138+(i%2)),height/2-1,z),V(20,height,if i==5 then 24 else 36),moss,Enum.Material.Grass)
   bank.Shape=Enum.PartType.Ball
  end
 end
 local function shelter(name:string,x:number,z:number,postWidth:number,postDepth:number,rise:number)
  for _,side in ipairs({-1,1})do for _,endSide in ipairs({-1,1})do
   settlement(name.."Post",V(x+side*postWidth/2,4.75,z+endSide*postDepth/2),V(.9,9.5,.9),darkWood,Enum.Material.Wood)
  end end
  for _,endSide in ipairs({-1,1})do settlement(name.."CrossBeam",V(x,9.5,z+endSide*postDepth/2),V(postWidth+2,1,1),wood,Enum.Material.Wood)end
  local half=postWidth/2+2;local angle=math.atan(rise/half)
  for _,side in ipairs({-1,1})do
   local roofPanel=settlement(name.."Roof",V(x+side*half/2,10+rise/2,z),V(math.sqrt(half*half+rise*rise),.4,postDepth+5),slate,Enum.Material.Slate)
   roofPanel.CFrame=CFrame.new(roofPanel.Position)*CFrame.Angles(0,0,-side*angle)
   settlement(name.."Eave",V(x+side*half,10,z),V(.6,.6,postDepth+5),wood,Enum.Material.Wood)
  end
  settlement(name.."Ridge",V(x,10+rise,z),V(.6,.7,postDepth+6),darkWood,Enum.Material.Wood)
  settlement(name.."Cloth",V(x,8.2,z+postDepth/2+.6),V(5,2,.15),navy,Enum.Material.Fabric)
  settlement(name.."Hem",V(x,7.2,z+postDepth/2+.7),V(5,.2,.12),gold)
 end
 stage="TrainingYard";shelter("TrainingShelter",65,59.5,44,11,4)
 stage="CaravanBend";shelter("WagonWaystation",-111,27,16,24,3)
 model.WorldPivot=CFrame.identity;return model
end
