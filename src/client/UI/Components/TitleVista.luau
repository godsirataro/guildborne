--!strict
-- Original static scenic diorama, not an unlocked destination or imported illustration.
local Theme = require(script.Parent.Parent.DesignSystem.Theme)
local Panel = require(script.Parent.GuildbornePanel)
local Vista = {}
function Vista.create(parent: Instance)
 local frame = Panel.create(parent, {name="CompanyStage",size=UDim2.new(1,0,0,300)})
 local backdrop=Instance.new("Frame")
 backdrop.Name="DuskSky";backdrop.Position=UDim2.fromOffset(10,10);backdrop.Size=UDim2.new(1,-20,1,-20)
 backdrop.BorderSizePixel=0;backdrop.BackgroundColor3=Color3.new(1,1,1);backdrop.ClipsDescendants=true;backdrop.Parent=frame
 local gradient=Instance.new("UIGradient")
 gradient.Color=ColorSequence.new(Color3.fromRGB(76,120,169),Color3.fromRGB(245,202,151));gradient.Rotation=90;gradient.Parent=backdrop
 local sun=Instance.new("Frame")
 sun.Name="SettingSun";sun.Size=UDim2.fromOffset(54,54);sun.Position=UDim2.fromScale(.72,.17)
 sun.BackgroundColor3=Color3.fromRGB(255,233,183);sun.BackgroundTransparency=.12;sun.BorderSizePixel=0;sun.Parent=backdrop
 local round=Instance.new("UICorner");round.CornerRadius=UDim.new(1,0);round.Parent=sun
 for index=1,4 do
  local cloud=Instance.new("Frame");cloud.Name="DuskCloud";cloud.Size=UDim2.new(.26,0,0,10+index*2)
  cloud.Position=UDim2.fromScale(if index%2==0 then .61 else -.03,.07+index*.08)
  cloud.BackgroundColor3=Color3.fromRGB(235,220,211);cloud.BackgroundTransparency=.76;cloud.BorderSizePixel=0;cloud.Parent=backdrop
  local soft=Instance.new("UICorner");soft.CornerRadius=UDim.new(1,0);soft.Parent=cloud
 end
 local sky=Instance.new("ViewportFrame")
 sky.Name="CitadelDiorama";sky.Size=UDim2.fromScale(1,1);sky.BackgroundTransparency=1;sky.BorderSizePixel=0
 sky.Ambient=Color3.fromRGB(193,201,217);sky.LightColor=Color3.fromRGB(255,224,174);sky.LightDirection=Vector3.new(-1,-1,-.7)
 sky.Active=false;sky.Parent=backdrop
 local world=Instance.new("WorldModel");world.Name="DecorativeCitadel";world.Parent=sky
 local camera=Instance.new("Camera");camera.FieldOfView=45;camera.Parent=sky;sky.CurrentCamera=camera
 local stone=Color3.fromRGB(209,199,173);local trim=Color3.fromRGB(239,221,179);local roof=Color3.fromRGB(47,85,117)
 local rock=Color3.fromRGB(104,125,129);local turf=Color3.fromRGB(123,145,109)
 local function block(name:string,size:Vector3,position:Vector3,color:Color3,wedge:boolean?):BasePart
  local part=(if wedge then Instance.new("WedgePart") else Instance.new("Part")) :: BasePart
  part.Name=name;part.Size=size;part.Position=position;part.Color=color
  part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
  part.TopSurface=Enum.SurfaceType.Smooth;part.BottomSurface=Enum.SurfaceType.Smooth
  part.Material=Enum.Material.SmoothPlastic;part.Parent=world;return part
 end
 -- Opposed wedges form real pitched roofs, never a single one-sided wedge cap.
 local function ridge(name:string,x:number,y:number,z:number,width:number,height:number,depth:number,color:Color3)
  local front=block(name,Vector3.new(width,height,depth/2),Vector3.new(x,y,z-depth/4),color,true)
  local back=block(name,Vector3.new(width,height,depth/2),Vector3.new(x,y,z+depth/4),color,true)
  back.CFrame=CFrame.new(back.Position)*CFrame.Angles(0,math.pi,0)
  if name=="DistantMountain" or name=="NearRidge" or name=="ForegroundRock" then
   -- Turn terrain ridges across the view so their silhouette is peaked, not flat-topped.
   local center=CFrame.new(x,y,z)*CFrame.Angles(0,math.pi/2,0)
   front.CFrame=center*CFrame.new(0,0,-depth/4)
   back.CFrame=center*CFrame.new(0,0,depth/4)*CFrame.Angles(0,math.pi,0)
  end
 end
 -- Separated mountain layers and reflective-colored lake establish scenic depth.
 for i=-2,2 do ridge("DistantMountain",i*22,7,-46-(i%2)*6,29,23+(i%3)*7,24,Color3.fromRGB(133,156,173)) end
 for _,x in ipairs({-35,34}) do ridge("NearRidge",x,-1,-22,26,25,22,Color3.fromRGB(97,130,140)) end
 block("Lake",Vector3.new(120,.4,90),Vector3.new(0,-15,0),Color3.fromRGB(91,161,181))
 for i=-2,2 do
  local x=i*9
  block("CliffFace",Vector3.new(10,13+i%2*2,20),Vector3.new(x,-7,-2-math.abs(i)*2),rock:Lerp(stone,(i+2)*.035))
  block("GrassTerrace",Vector3.new(10.5,1,20.5),Vector3.new(x,.1,-2-math.abs(i)*2),turf)
  local buttress=block("CliffButtress",Vector3.new(6,14,12),Vector3.new(x,-8,10-math.abs(i)*2),rock,true)
  buttress.CFrame=CFrame.new(buttress.Position)*CFrame.Angles(0,math.pi,0)
 end
 for _,x in ipairs({-13.5,13.5}) do
  block("Waterfall",Vector3.new(2.7,15,.35),Vector3.new(x,-7,9),Color3.fromRGB(175,221,225))
  block("WaterfallGlint",Vector3.new(.65,15,.45),Vector3.new(x-.6,-7,9.1),Color3.fromRGB(224,240,231))
  block("Foam",Vector3.new(6,.12,5),Vector3.new(x,-14.65,10),Color3.fromRGB(192,226,221))
 end
 block("CastlePlinth",Vector3.new(29,1,16),Vector3.new(0,1,-3),trim)
 block("GreatHall",Vector3.new(14,9,8),Vector3.new(0,5.8,-5),stone)
 ridge("GreatHallRoof",0,12,-5,16,5,10,roof)
 for _,x in ipairs({-5,0,5}) do
  block("HallWindow",Vector3.new(1,3,.1),Vector3.new(x,7,-.94),Color3.fromRGB(255,211,118))
  block("WindowLintel",Vector3.new(1.4,.3,.2),Vector3.new(x,8.65,-.88),trim)
 end
 local function tower(x:number,z:number,height:number)
  block("IvoryTower",Vector3.new(3.8,height,3.8),Vector3.new(x,1.5+height/2,z),stone)
  for _,y in ipairs({2,height*.55,height+1.5}) do block("TowerCornice",Vector3.new(4.25,.4,4.25),Vector3.new(x,y,z),trim) end
  ridge("TowerRoof",x,height+4.2,z,4.6,5,4.6,roof)
  block("GoldFinial",Vector3.new(.2,2,.2),Vector3.new(x,height+7.5,z),Theme.Colors.Gold)
  for level=1,2 do block("TowerWindow",Vector3.new(.6,1.8,.1),Vector3.new(x,2+height*level/3,z+1.95),Color3.fromRGB(255,215,138)) end
 end
 tower(0,-10,23);tower(-9,-6,15);tower(9,-6,17);tower(-13,3,9);tower(13,3,10)
 for _,x in ipairs({-7,7}) do
  block("CurtainWall",Vector3.new(8,4,2),Vector3.new(x,3.4,4),stone)
  block("Parapet",Vector3.new(8.4,.6,2.5),Vector3.new(x,5.7,4),trim)
  for k=-1,1 do block("Merlon",Vector3.new(1,1.1,2.3),Vector3.new(x+k*2.8,6.4,4),stone) end
  block("BurgundyBanner",Vector3.new(1.4,3,.12),Vector3.new(x,3.8,5.08),Theme.Colors.Primary)
 end
 block("GatewayLintel",Vector3.new(5.5,1.3,3),Vector3.new(0,7,4),trim)
 for _,x in ipairs({-2.2,2.2}) do block("GatePillar",Vector3.new(1,5,3),Vector3.new(x,4,4),stone) end
 block("BridgeDeck",Vector3.new(5,.8,27),Vector3.new(0,.9,20),trim)
 for _,x in ipairs({-2.7,2.7}) do block("BridgeRail",Vector3.new(.45,1,27),Vector3.new(x,1.8,20),stone) end
 for _,z in ipairs({14,24,32}) do block("BridgePier",Vector3.new(3,15,2),Vector3.new(0,-7,z),rock) end
 for _,x in ipairs({-31,29}) do
  ridge("ForegroundRock",x,-8,26,18,19,19,Color3.fromRGB(75,105,111))
  block("ForegroundMeadow",Vector3.new(13,1,13),Vector3.new(x,1,26),turf)
 end
 local function compose()
  local aspect=sky.AbsoluteSize.X/math.max(1,sky.AbsoluteSize.Y)
  local distance=math.max(88,80/math.max(.75,aspect));local target=Vector3.new(0,7,-2)
  camera.CFrame=CFrame.lookAt(target+Vector3.new(.23,.23,1)*distance,target)
 end
 local resized=sky:GetPropertyChangedSignal("AbsoluteSize"):Connect(compose)
 sky.Destroying:Connect(function()resized:Disconnect()end);compose()
 local host=Instance.new("Frame");host.Name="HeroStage";host.BackgroundTransparency=1;host.ZIndex=2
 host.Position=UDim2.new(0,10,.28,0);host.Size=UDim2.new(1,-20,.72,-10);host.Parent=frame
 return {frame=frame,heroHost=host}
end
return Vista
