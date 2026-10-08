--!strict
-- Isolated UI and captured callbacks, with the real read-only projected catalog.
return function():any
 local player=game.Players.LocalPlayer;local UI=player.PlayerScripts.Client.UI
 local draw=require(UI.SettlementView);local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
 local describe=require(game.ReplicatedStorage.Shared.Data.TavernViewState)
 local snapshot:any=nil;local connection=game.ReplicatedStorage.GuildborneRemotes.State.OnClientEvent:Connect(function(v)snapshot=v end)
 local start=os.clock();repeat task.wait(.1)until snapshot or os.clock()-start>7;connection:Disconnect();assert(snapshot)
 local catalog=snapshot.catalog;local gui=Instance.new("ScreenGui");gui.Name="TavernViewFixture";gui.Parent=player.PlayerGui
 local host=Instance.new("Frame");host.BackgroundTransparency=1;host.Size=UDim2.fromOffset(240,800);host.Parent=gui
 local checked=0;local confirmations=0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640}) do for _,language in ipairs({"en","th"}) do
   host.Size=UDim2.fromOffset(width,800)
   local callbacks:{[Instance]:any}={};local actions:{any}={};local data:any=nil;local busy=false;local render:any=nil;local atGuild=true
   local function T(value:string,params:any?):string return locale.translate(language,value,params) end
   local function text(parent:Instance,value:string,size:number?):TextLabel
    local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,0);l.AutomaticSize=Enum.AutomaticSize.Y;l.Font=Enum.Font.Gotham;l.TextWrapped=true;l.TextSize=size or 18;l.Text=T(value);l.Parent=parent;return l
   end
   local function card(parent:Instance,title:string):Frame
    local f=Instance.new("Frame");f.Size=UDim2.new(1,-4,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
    local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.PaddingRight=UDim.new(0,12);pad.Parent=f
    local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,10);layout.Parent=f;text(f,title,20);return f
   end
   local function button(parent:Instance,value:string,enabled:boolean,callback:any):TextButton
    local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,52);b.Font=Enum.Font.GothamMedium;b.TextSize=17;b.TextWrapped=true;b.Text=T(value);b.Active=enabled;b.Selectable=enabled;b.Parent=parent;callbacks[b]=callback;return b
   end
   local function refresh(tab:string?)host:ClearAllChildren();table.clear(callbacks);render(tab or "Tavern",data,catalog,busy)end
   render=draw({scroll=host,T=T,text=text,card=card,button=button,atGuild=function()return atGuild end,act=function(action,args)table.insert(actions,{action=action,args=args})end,navigate=function()end,render=refresh,now=function()return 0 end})
   local function ready():any return {gold=1000,hallLevel=2,rosterCapacity=5,adventurers={},inventory={stacks={timber=5,stone=3},equipment={}},quests={},expansion={tower={}},settlement={journal={},elixirs=0,tavernLevel=1,nextHero=1,nextOffer=2,offer={id="offer:1",classId="Warrior",rank="F"}}}end
   local function inspect()
    task.wait(.05);local state=describe(data,catalog,busy)
    for name,problem in pairs({ScoutCandidate=state.scoutProblem or false,HireCandidate=state.hireProblem or false,UpgradeTavern=state.upgradeProblem or false}) do
     local b=host:FindFirstChild(name,true)
     if b and b:IsA("TextButton") then assert(b.Active==(not problem and(name~="UpgradeTavern"or atGuild)) and b.Selectable==b.Active,"Readiness mismatch "..name) end
    end
    for _,l in ipairs(host:GetDescendants()) do if l:IsA("TextLabel") or l:IsA("TextButton") then assert(l.TextBounds.X<=l.AbsoluteSize.X+1 and l.TextBounds.Y<=l.AbsoluteSize.Y+1,"Clipped "..l.Name.." "..language.." "..width.." "..l.Text) end end
    checked+=1
   end
   for _,class in ipairs(catalog.AdventurerOrder) do
    data=ready();data.settlement.offer.classId=class;data.settlement.offer.rank="SSS";refresh();inspect()
    local weapon=assert(host:FindFirstChild("CandidateWeapon",true)) :: TextLabel
    assert(weapon.Text:find(T(catalog.Items[catalog.Character.Classes[class].Weapon].Name),1,true))
   end
   for id,template in pairs(catalog.HeroTemplates or {}) do
    data=ready();data.settlement.offer.classId=template.Class;data.settlement.offer.templateId=id;refresh();inspect()
    local candidate=assert(host:FindFirstChild("TavernCandidate",true));local title=candidate:FindFirstChildWhichIsA("TextLabel") :: TextLabel
    assert(title.Text:find(T(template.Name),1,true),"Named candidate title mismatch")
   end
   for _,state in ipairs({"noOffer","poor","full","equipment","quest","tower","busy","max"}) do
    data=ready();busy=state=="busy"
    if state=="noOffer" then data.settlement.offer=nil elseif state=="poor" then data.gold=0 elseif state=="full" then data.rosterCapacity=0
    elseif state=="equipment" then for i=1,catalog.EquipmentLimit do data.inventory.equipment[tostring(i)]={} end
    elseif state=="quest" then data.quests.active={} elseif state=="tower" then data.expansion.tower.active={}
    elseif state=="max" then data.settlement.tavernLevel=catalog.Tavern.MaxLevel end
    refresh();inspect()
   end
   busy=false;data=ready();atGuild=false;refresh();inspect();assert(host:FindFirstChild("TavernLocationReason",true));atGuild=true;refresh()
   local function click(name:string)local b=assert(host:FindFirstChild(name,true)) :: TextButton;assert(b.Active);callbacks[b]()end
   click("ScoutCandidate");inspect();assert(#actions==0 and host:FindFirstChild("CancelReplaceCandidate",true))
   click("CancelReplaceCandidate");assert(#actions==0 and not host:FindFirstChild("CancelReplaceCandidate",true))
   click("ScoutCandidate");data.settlement.offer.id="offer:2";refresh();assert(not host:FindFirstChild("CancelReplaceCandidate",true),"Stale confirmation carried to new offer")
   click("ScoutCandidate");click("ScoutCandidate");assert(#actions==1 and actions[1].action=="ScoutHero")
   click("HireCandidate");assert(#actions==2 and actions[2].action=="HireHero" and actions[2].args.offerId=="offer:2")
   confirmations+=1
  end end
  return {viewChecks=checked,confirmationCases=confirmations,widths={240,640},languages={"en","th"},classes=5,noClipping=true,noProfileWrites=true,synthetic=true}
 end)
 gui:Destroy();assert(ok,tostring(result));return result
end
