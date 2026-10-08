--!strict
local Civic=require(game.ReplicatedStorage.Shared.Config.CivicCities)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Art=require(game.ReplicatedStorage.Shared.Config.Art)
return function(parent:Instance,select:(string,number,number)->())
 local frame=Instance.new("Frame");frame.Name="CivicMap";frame.BackgroundColor3=Color3.fromRGB(54,68,61);frame.ClipsDescendants=true;frame.Visible=false;frame.Parent=parent
 local city:string?=nil;local nodes={}
 local entries={{name="Civic landmark",x=0,z=-70},{name="Central City",x=-58,z=88},{name="Guild Zone Warp",x=58,z=88},{name="Welcome guide",x=20,z=12},{name="Market",x=-58,z=28},{name="Tavern",x=-58,z=-28}}
 for index,e in ipairs(entries)do
  local b=Instance.new("TextButton");b.Name="CivicGuide_"..index;b.AnchorPoint=Vector2.new(.5,.5);b.Position=UDim2.fromScale((e.x+100)/200,(e.z+125)/250);b.Size=UDim2.new(.30,0,0,52);b.TextWrapped=true;b.Font=Enum.Font.GothamMedium;b.TextSize=14;b.TextScaled=true;local fit=Instance.new("UITextSizeConstraint");fit.MinTextSize=12;fit.MaxTextSize=14;fit.Parent=b;b.BackgroundColor3=Art.UI.Button;b.TextColor3=Art.UI.Text;b.Parent=frame
  b.Activated:Connect(function()if city then local d=(Civic.Definitions :: any)[city];select(e.name,d.X+e.x,d.Z+e.z)end end)
  table.insert(nodes,{button=b,name=e.name,entry=e})
 end
 local marker=Instance.new("TextLabel");marker.Name="CivicPlayerPosition";marker.Text="●";marker.TextSize=22;marker.TextColor3=Color3.fromRGB(255,224,102);marker.BackgroundTransparency=1;marker.Size=UDim2.fromOffset(22,22);marker.AnchorPoint=Vector2.new(.5,.5);marker.ZIndex=3;marker.Parent=frame
 return {frame=frame,update=function(id:string?,language:string,x:number?,z:number?)
  city=id
  for _,node in ipairs(nodes)do
   node.button.Text=Locale.translate(language,node.name)
   local services=id and(Civic.Services :: any)[id];local service=services and services[node.name]
   if service then node.entry.x=service.X;node.entry.z=service.Z;node.button.Position=UDim2.fromScale(math.clamp((service.X+100)/200,.16,.84),(service.Z+125)/250)end
  end
  local d=id and(Civic.Definitions :: any)[id]
  marker.Visible=d~=nil and x~=nil and z~=nil
  if d and x and z then marker.Position=UDim2.fromScale(math.clamp((x-d.X+100)/200,0,1),math.clamp((z-d.Z+125)/250,0,1))end
 end}
end
