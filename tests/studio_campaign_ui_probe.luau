--!strict
-- Synthetic GUI only. No server commands, profile grants or gameplay acceptance.
return function(config:any,drawOverride:any?):any
 local player=game.Players.LocalPlayer;local draw=drawOverride or require(player.PlayerScripts.Client.UI.CampaignView)
 local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
 local gui=Instance.new("ScreenGui");gui.Name="CampaignFixture";gui.Parent=player.PlayerGui
 local host=Instance.new("ScrollingFrame");host.AutomaticCanvasSize=Enum.AutomaticSize.Y;host.CanvasSize=UDim2.new();host.Parent=gui
 local views=0;local textChecks=0;local calls=0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640,704})do for _,language in ipairs({"en","th"})do
   host.Size=UDim2.fromOffset(width,300)
   local callbacks:{[Instance]:any}={};local actions:{any}={};local redraw:any
   local function T(s:string):string return locale.translate(language,s)end
   local function text(parent:Instance,s:string,size:number?):TextLabel
    local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,0);l.AutomaticSize=Enum.AutomaticSize.Y;l.TextWrapped=true;l.Font=Enum.Font.Gotham;l.TextSize=size or 18;l.Text=T(s);l.Parent=parent;return l
   end
   local function card(parent:Instance,title:string):Frame
    local f=Instance.new("Frame");f.Size=UDim2.new(1,-12,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
    local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.PaddingRight=UDim.new(0,12);pad.Parent=f
    local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,10);layout.Parent=f;text(f,title,20);return f
   end
   local function button(parent:Instance,s:string,active:boolean,callback:any):TextButton
    local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,52);b.TextWrapped=true;b.Font=Enum.Font.GothamMedium;b.TextSize=17;b.Text=T(s);b.Active=active;b.Selectable=active;b.Parent=parent;callbacks[b]=callback;return b
   end
   local render=draw({scroll=host,T=T,text=text,card=card,button=button,render=function()redraw()end,act=function(action,args)table.insert(actions,{action=action,args=args});calls+=1 end})
   local catalog={CampaignChapter=config,EquipmentLimit=50,AdventurerOrder={"Warrior","Knight","Archer","Mage","Priest"}}
   for _,mode in ipairs({"unavailable","active","ready","recruit","full","roster","busy","traveling","level","chapter3","chapter4","chapter5","chapter6","complete","upgraded"})do
    local data:any={language=language,rosterCapacity=10,adventurers={founder={}},inventory={equipment={}},character={level=20},quests={},expansion={tower={}},progression={novice={claimed=6},campaign={claimed=0,objectives={}}}}
    local s=data.progression.campaign
    if mode=="unavailable"then data.progression.campaign=nil
    elseif mode=="complete"or mode=="upgraded"then s.claimed=6;s.hallPermit=2;s.choices={choose_crest="compass",choose_motto="together"};data.hallLevel=if mode=="upgraded"then 2 else 1
    elseif mode~="active"then
     if mode~="ready"then s.claimed=1 end
     if mode:sub(1,7)=="chapter"then s.claimed=assert(tonumber(mode:sub(8)))-1 end
     for _,id in ipairs(config.Chapters[s.claimed+1].Objectives)do s.objectives[id]=true end
     if mode=="full"then for i=1,50 do data.inventory.equipment[tostring(i)]={}end end
     if mode=="roster"then data.rosterCapacity=1 end
     if mode=="traveling"then data.quests.active={}end
     if mode=="level"then data.character.level=10 end
    end
    redraw=function()host:ClearAllChildren();table.clear(callbacks);render(data,catalog,mode=="busy")end
    table.clear(actions);redraw();task.wait(.15)
    for _,l in ipairs(host:GetDescendants())do
     if l:IsA("TextLabel")or l:IsA("TextButton")then assert(l.TextBounds.X<=l.AbsoluteSize.X+1 and l.TextBounds.Y<=l.AbsoluteSize.Y+1,"Clipped "..mode.." "..language.." "..l.Text);textChecks+=1 end
     if l:IsA("TextButton")and l.Parent and (l.Parent.Name=="NoviceHeroChoices"or l.Parent.Name=="CampaignHeroChoices")then
      local f=l.Parent :: Frame;assert(l.AbsolutePosition.X>=f.AbsolutePosition.X-1 and l.AbsolutePosition.Y>=f.AbsolutePosition.Y-1 and l.AbsolutePosition.X+l.AbsoluteSize.X<=f.AbsolutePosition.X+f.AbsoluteSize.X+1 and l.AbsolutePosition.Y+l.AbsoluteSize.Y<=f.AbsolutePosition.Y+f.AbsoluteSize.Y+1,"Choice outside grid")
     end
     if l:IsA("TextButton")then assert(l.Active==l.Selectable and l.AbsoluteSize.Y>=44)end
    end
    local claim=host:FindFirstChild("CampaignClaim",true)
    if claim then
     local chapterClaim=mode=="ready"or mode:sub(1,7)=="chapter"
     local enabled=chapterClaim or mode=="recruit";assert((claim::TextButton).Active==enabled)
     callbacks[claim]();assert(#actions==(if chapterClaim then 1 else 0))
     if mode=="recruit"then
      callbacks[assert(host:FindFirstChild("CampaignHero_Priest",true))]();assert(#actions==0)
      callbacks[assert(host:FindFirstChild("CampaignClaim",true))]();assert(#actions==0)
      callbacks[assert(host:FindFirstChild("CampaignClaim",true))]();assert(#actions==1 and actions[1].action=="ClaimCampaignRecruit"and actions[1].args.heroClass=="Priest")
     elseif chapterClaim then assert(actions[1].action=="ClaimCampaignChapter")end
    end
    views+=1
   end
  end end
  return {views=views,textBoundsChecks=textChecks,capturedActions=calls,profileWrites=0,runtimeBinding=false}
 end)
 gui:Destroy();assert(ok,tostring(result));return result
end
