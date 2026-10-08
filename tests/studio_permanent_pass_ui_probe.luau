--!strict
-- Presentation/callback capture only. Never calls MarketplaceService or a Remote.
return function():any
 local player=game.Players.LocalPlayer;local uiFolder=player.PlayerScripts.Client.UI
 local landDraw=require(uiFolder.GuildLandView);local themeFactory=require(uiFolder.BuildingThemesView)
 local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
 local gui=Instance.new("ScreenGui");gui.Name="PermanentPassUIFixture";gui.Parent=player.PlayerGui
 local host=Instance.new("ScrollingFrame");host.AutomaticCanvasSize=Enum.AutomaticSize.Y;host.CanvasSize=UDim2.new();host.Parent=gui
 local views=0;local bounds=0;local callbacks=0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640,704})do for _,language in ipairs({"en","th"})do for _,mode in ipairs({"Disabled","Available","LockedOwned","Busy"})do
   host.Size=UDim2.fromOffset(width,300)
   local function T(s:string):string return locale.translate(language,s)end
   local function text(parent:Instance,s:string,size:number?):TextLabel
    local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,0);l.AutomaticSize=Enum.AutomaticSize.Y;l.TextWrapped=true;l.Font=Enum.Font.Gotham;l.TextSize=size or 18;l.Text=T(s);l.Parent=parent;return l
   end
   local function card(parent:Instance,title:string):Frame
    local f=Instance.new("Frame");f.Size=UDim2.new(1,-4,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
    local p=Instance.new("UIPadding");p.PaddingLeft=UDim.new(0,12);p.PaddingRight=UDim.new(0,12);p.PaddingTop=UDim.new(0,12);p.PaddingBottom=UDim.new(0,12);p.Parent=f
    local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,10);list.Parent=f;text(f,title,20);return f
   end
   local buttons:any={};local captured:any=nil
   local function button(parent:Instance,label:string,enabled:boolean,callback:()->()):TextButton
    local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,52);b.Font=Enum.Font.GothamMedium;b.TextSize=17;b.TextWrapped=true;b.Text=T(label);b.Active=enabled;b.Parent=parent
    table.insert(buttons,{button=b,enabled=enabled,callback=callback});return b
   end
   local ui={scroll=host,T=T,text=text,card=card,button=button,navigate=function()end,render=function()end,act=function(action:string,args:any)captured={action=action,args=args};callbacks+=1 end}
   local available=mode=="Available" or mode=="Busy"
   local data:any={inventory={stacks={}},guildLand={plots={grove={name="Grove",status=if mode=="LockedOwned"then "QuestLocked"else "PurchaseRequired",purchased=mode=="LockedOwned",purchaseAvailable=available,questEligible=false,quests={trail_watch=false},materials={timber=24},delivered={}}}},expansion={buildings={},storage={},furniture={},themeRights={}},settlement={journal={}},permanentPassOffers={Theme={elf=available}}}
   if mode=="LockedOwned"then data.expansion.themeRights.elf=true end
   for _,screen in ipairs({"Land","Theme"})do
    host:ClearAllChildren();buttons={};captured=nil
    if screen=="Land"then landDraw(ui,data,{Quests={trail_watch={Name="Trail Watch"}},Items={timber={Name="Timber"}}},mode=="Busy")else themeFactory(ui)(data,mode=="Busy")end
    task.wait(.06)
    local purchase=host:FindFirstChild(if screen=="Land"then "PurchasePlot_grove"else "PurchaseTheme_elf",true)
    assert((purchase~=nil)==available,"Unexpected purchase offer "..mode)
    for _,entry in ipairs(buttons)do if entry.button==purchase then
     assert(entry.enabled==(mode=="Available"))
     if entry.enabled then entry.callback();assert(captured.action=="RequestPermanentPass" and captured.args.kind==screen and captured.args.key==(if screen=="Land"then "grove"else "elf"))end
    end end
    for _,label in ipairs(host:GetDescendants())do if label:IsA("TextLabel")or label:IsA("TextButton")then
     assert(label.TextBounds.X<=label.AbsoluteSize.X+1 and label.TextBounds.Y<=label.AbsoluteSize.Y+1,"Clipped "..language.." "..label.Text);bounds+=1
    end end
    views+=1
   end
  end end end
  return {views=views,textBoundsChecks=bounds,capturedCallbacks=callbacks,platformCalls=0,profileWrites=0,serverRequests=0}
 end)
 gui:Destroy();if not ok then error(result)end;return result
end
