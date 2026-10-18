--!strict
-- Disposable native presentation fixture. No remotes, profile mutation or rewards.
local player=game:GetService("Players").LocalPlayer
local Draw=require(script.Parent.Client.UI.Components.NoviceChapterCard)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Config=require(game.ReplicatedStorage.PreviewNoviceConfig)
local Theme=require(script.Parent.Client.UI.DesignSystem.Theme)
local gui=Instance.new("ScreenGui");gui.Name="NoviceChapterReview";gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local host=Instance.new("Frame");host.Size=UDim2.fromScale(1,1);host.BackgroundColor3=Theme.Colors.Background;host.Parent=gui
local sizes={Vector2.new(728,490),Vector2.new(390,640),Vector2.new(240,500)}
local modes={"Incomplete","Ready","Busy","Underlevel","Trial","Class","FullEquipment","Foundation","Complete","Unavailable"}
local widthIndex,modeIndex,chapter=1,1,3
local language="en";local longCopy=false;local fit=true;local alive=true
local generation=0
local data:any;local catalog:any
local notice=Instance.new("TextLabel");notice.Name="FixtureState";notice.Size=UDim2.new(1,-12,0,40);notice.Position=UDim2.fromOffset(6,94);notice.BackgroundTransparency=1;notice.TextColor3=Theme.Colors.Text;notice.TextSize=12;notice.TextWrapped=true;notice.Font=Theme.Fonts.Body;notice.Parent=host
local canvas=Instance.new("Frame");canvas.Name="SimulatedManagementContent";canvas.Position=UDim2.fromOffset(0,140);canvas.BackgroundColor3=Theme.Colors.Background;canvas.ClipsDescendants=true;canvas.Parent=host
local scale=Instance.new("UIScale");scale.Parent=canvas
local scroll=Instance.new("ScrollingFrame");scroll.Name="Content";scroll.Size=UDim2.fromScale(1,1);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.Active=true;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.ScrollBarThickness=5;scroll.ScrollingDirection=Enum.ScrollingDirection.Y;scroll.Parent=canvas
local back=Instance.new("TextButton");back.Name="ReturnToGuildMenu";back.Size=UDim2.new(1,-16,0,52);back.Position=UDim2.fromOffset(8,12);back.Text="Guild menu / เมนูกิลด์";back.TextSize=17;back.TextColor3=Theme.Colors.Text;back.BackgroundColor3=Theme.Colors.Primary;back.Visible=false;back.Parent=canvas
back.Activated:Connect(function()back.Visible=false;scroll.Visible=true end)
local redraw:()->()
local draw=Draw({scroll=scroll,T=function(s:string,p:any?)return Locale.translate(language,s,p)end,
 render=function()redraw()end,
 explore=function()scroll.Visible=false;back.Visible=true;print("SYNTHETIC_EXPLORE",modes[modeIndex])end,
 act=function(action:string,args:any)
  gui:SetAttribute("CapturedAction",action);gui:SetAttribute("CapturedId",args.chapterId or args.classId or args.heroClass)
  print("SYNTHETIC_NOVICE_INTENT",action,args.chapterId or args.classId or args.heroClass)
 end})
local function clone(value:any):any
 if type(value)~="table" then return value end
 local result={};for key,item in pairs(value)do result[key]=clone(item)end;return result
end
local function prepare()
 local config=clone(Config)
 if longCopy then
  for _,def in ipairs(config.Chapters)do
   def.Title..=" — A promise carried beyond the crossroads"
   def.Thai..=" — คำสัญญาที่จะพาพวกพ้องเดินทางข้ามทางแยกไปด้วยกัน"
  end
  for _,names in pairs(config.ObjectiveLabels)do
   names[1]..=" — take your time and follow the marked path together"
   names[2]..=" — ค่อย ๆ เดินตามเส้นทางที่กำหนดและดูแลผู้ร่วมทางให้ปลอดภัย"
  end
 end
 local mode=modes[modeIndex]
 local special=mode=="Trial" or mode=="Class" or mode=="FullEquipment" or mode=="Foundation" or mode=="Complete"
 local index=if special then 6 else chapter
 data={language=language,hallLevel=0,adventurers={},inventory={equipment={}},character={level=config.Chapters[index].Level},progression={novice={claimed=index-1,objectives={}}}}
 local state=data.progression.novice
 if mode=="Ready" or mode=="Busy" or mode=="Underlevel" or mode=="Foundation" then
  for _,id in ipairs(config.Chapters[index].Objectives)do state.objectives[id]=true end
 elseif mode=="Incomplete" then state.objectives[config.Chapters[index].Objectives[1]]=true end
 if mode=="Underlevel" then data.character.level=math.max(0,config.Chapters[index].Level-1) end
 if mode=="Class" or mode=="FullEquipment" or mode=="Foundation" then state.trialClass="Mage" end
 if mode=="FullEquipment" then for i=1,50 do data.inventory.equipment[tostring(i)]={}end end
 if mode=="Foundation" then data.character.classId="Mage" end
 if mode=="Complete" then state.claimed=6;data.hallLevel=1 end
 if mode=="Unavailable" then data.progression.novice=nil end
 catalog={NoviceChapter=config,EquipmentLimit=50,AdventurerOrder={"Warrior","Knight","Archer","Mage","Priest"}}
end
redraw=function()
 generation+=1;local observationGeneration=generation
 scroll:ClearAllChildren();scroll.Visible=true;back.Visible=false
 draw(data,catalog,modes[modeIndex]=="Busy")
 local size=sizes[widthIndex];canvas.Size=UDim2.fromOffset(size.X,size.Y)
 scale.Scale=if fit then math.max(.01,math.min(1,host.AbsoluteSize.X/size.X,(host.AbsoluteSize.Y-140)/size.Y))else 1
 notice.Text=string.format("SIMULATED • %s • %s • %d×%d • %.0f%% scale\nLong copy: %s • scroll for actions • no server requests",modes[modeIndex],language,size.X,size.Y,scale.Scale*100,tostring(longCopy))
 task.delay(.3,function()
  if not alive or observationGeneration~=generation then return end
  local clipped=0;local count=0
  for _,item in ipairs(scroll:GetDescendants())do
   if item:IsA("TextLabel")or item:IsA("TextButton")then
    count+=1;if not item.TextFits then clipped+=1;print("NOVICE_TEXT_NOT_FIT",item:GetFullName(),item.Text,item.AbsoluteSize,item.TextBounds)end
   end
  end
  print("NOVICE_NATIVE_OBSERVATION",modes[modeIndex],language,size,scale.Scale,"text",count,"notFit",clipped,"canvas",scroll.AbsoluteCanvasSize)
 end)
end
local function control(index:number,text:string,callback:()->())
 local button=Instance.new("TextButton");button.Name="FixtureControl"..index;button.Size=UDim2.new(1/3,-4,0,44);button.Position=UDim2.new(((index-1)%3)/3,2,0,math.floor((index-1)/3)*46)
 button.Text=text;button.TextSize=12;button.TextWrapped=true;button.TextColor3=Theme.Colors.Text;button.BackgroundColor3=Theme.Colors.Primary;button.Parent=host
 button.Activated:Connect(function()callback();prepare();redraw()end)
end
control(1,"EN / ไทย",function()language=if language=="en"then"th"else"en"end)
control(2,"State ▶",function()modeIndex=modeIndex%#modes+1 end)
control(3,"Chapter ▶",function()chapter=chapter%5+1;modeIndex=1 end)
control(4,"Width ▶",function()widthIndex=widthIndex%#sizes+1 end)
control(5,"Long copy",function()longCopy=not longCopy end)
control(6,"1:1 / Fit",function()fit=not fit end)
host:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()if data then redraw()end end)
gui.Destroying:Connect(function()alive=false end)
prepare();redraw()
