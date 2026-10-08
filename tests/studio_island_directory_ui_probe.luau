--!strict
-- Synthetic UI snapshots/callback capture; no travel, friend API or remote calls.
return function(draw:any):any
 local gui=Instance.new("ScreenGui");gui.Name="IslandDirectoryUIProbe";gui.Parent=game.Players.LocalPlayer.PlayerGui
 local host=Instance.new("ScrollingFrame");host.Size=UDim2.fromOffset(240,300);host.AutomaticCanvasSize=Enum.AutomaticSize.Y;host.CanvasSize=UDim2.new();host.Parent=gui
 local localization=require(game.ReplicatedStorage.Shared.Config.Localization)
 local views,bounds,filters=0,0,0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640,704})do for _,language in ipairs({"en","th"})do
   host.Size=UDim2.fromOffset(width,300)
   local callbacks:{[Instance]:any}={};local commands:{any}={};local render:any=nil
   local function activate(name:string)
    local target=host:FindFirstChild(name,true);assert(target and callbacks[target],"Missing callback "..name)
    callbacks[target]()
   end
   local function T(s:string):string return localization.translate(language,s)end
   local function text(parent:Instance,value:string,size:number?):TextLabel
    local v=Instance.new("TextLabel");v.Text=T(value);v.TextSize=size or 16;v.Font=Enum.Font.Gotham;v.TextWrapped=true;v.Size=UDim2.new(1,0,0,0);v.AutomaticSize=Enum.AutomaticSize.Y;v.Parent=parent;return v
   end
   local function card(parent:Instance,title:string):Frame
    local f=Instance.new("Frame");f.Size=UDim2.new(1,-24,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
    local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,8);list.Parent=f;text(f,title,20);return f
   end
   local function button(parent:Instance,value:string,enabled:boolean,callback:any):TextButton
    local b=Instance.new("TextButton");b.Text=T(value);b.Font=Enum.Font.Gotham;b.TextSize=16;b.TextWrapped=true;b.Size=UDim2.new(1,0,0,64);b.Active=enabled;b.Parent=parent;callbacks[b]=callback;return b
   end
   local own=tostring(game.Players.LocalPlayer.UserId)
   local entries={{ownerId=own,name="Owner",displayName="My guild",mode="Private",visitors=8,capacity=8},{ownerId="901",name="PublicOwner",displayName="Public guild",mode="Public",visitors=0,capacity=8},{ownerId="902",name="FriendOwner",displayName="Friends guild",mode="Friends",visitors=8,capacity=8}}
   local busy=false
   for i,entry in ipairs(entries)do entry.hallLevel=11;entry.crestId=({"sun","oak","compass"})[i];entry.mottoId=({"together","courage","discovery"})[i]end
   local view=draw({scroll=host,T=T,card=card,text=text,button=button,navigate=function()end,act=function(action,payload)table.insert(commands,{action=action,payload=payload})end,render=function()render()end})
   render=function()host:ClearAllChildren();table.clear(callbacks);view(entries,busy,{})end
   local function inspect()
    task.wait(.1)
    for _,v in host:GetDescendants()do if v:IsA("TextLabel")or v:IsA("TextButton")then assert(v.TextBounds.X<=v.AbsoluteSize.X+1 and v.TextBounds.Y<=v.AbsoluteSize.Y+1,"Clipped "..language.." "..v.Text);bounds+=1 end end
    views+=1
   end
   render();inspect()
   local mine=host:FindFirstChild("Visit_"..own,true)::TextButton;local full=host:FindFirstChild("Visit_902",true)::TextButton
   assert(mine.Active and not full.Active,"Owner/full access presentation")
   for _,expected in ipairs({"901","902",own})do
    activate("IslandFilter");inspect();filters+=1
    local count=0;for _,v in host:GetChildren()do if v.Name:match("^Island_")then count+=1 end end
    assert(count==1 and host:FindFirstChild("Island_"..expected),"Wrong filter")
   end
   activate("ClearIslandFilters");inspect();assert(host:FindFirstChild("Island_901")and host:FindFirstChild("Island_902"))
   activate("Visit_901");assert(#commands==1 and commands[1].action=="VisitIsland"and commands[1].payload.ownerId=="901")
   busy=true;render();inspect();assert(not (host:FindFirstChild("Visit_901",true)::TextButton).Active)
  end end
  return {views=views,textBounds=bounds,filterTransitions=filters,scope="Synthetic EN/TH callback capture only; no server travel"}
 end)
 gui:Destroy();assert(ok,result);return result
end
