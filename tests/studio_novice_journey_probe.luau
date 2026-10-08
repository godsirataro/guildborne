--!strict
-- Synthetic GUI states; callbacks are captured locally and never sent to server.
return function(config:any,drawOverride:any?):any
 local player=game.Players.LocalPlayer;local draw=drawOverride or require(player.PlayerScripts.Client.UI.NoviceJourneyView)
 local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
 local describe=require(game.ReplicatedStorage.Shared.Data.NoviceJourneyViewState)
 local gui=Instance.new("ScreenGui");gui.Name="NoviceJourneyFixture";gui.Parent=player.PlayerGui
 local host=Instance.new("ScrollingFrame");host.Size=UDim2.fromOffset(240,300);host.AutomaticCanvasSize=Enum.AutomaticSize.Y;host.CanvasSize=UDim2.new();host.Parent=gui
 local views=0;local calls=0;local textChecks=0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640,704}) do for _,language in ipairs({"en","th"}) do
   host.Size=UDim2.fromOffset(width,300)
   local callbacks:{[Instance]:any}={};local actions:{any}={};local redraw:any
   local function T(s:string,p:any?):string return locale.translate(language,s,p) end
   local function text(parent:Instance,s:string,size:number?):TextLabel
    local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,0);l.AutomaticSize=Enum.AutomaticSize.Y;l.TextWrapped=true;l.Font=Enum.Font.Gotham;l.TextSize=size or 18;l.Text=T(s);l.Parent=parent;return l
   end
   local function card(parent:Instance,title:string):Frame
    local f=Instance.new("Frame");f.Size=UDim2.new(1,-12,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
    local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.PaddingRight=UDim.new(0,12);pad.Parent=f
    local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,10);layout.Parent=f;text(f,title,20);return f
   end
   local function button(parent:Instance,s:string,active:boolean,callback:any):TextButton
    local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,52);b.Font=Enum.Font.GothamMedium;b.TextSize=17;b.TextWrapped=true;b.Text=T(s);b.Active=active;b.Selectable=active;b.Parent=parent;callbacks[b]=callback;return b
   end
   local render=draw({scroll=host,T=T,text=text,card=card,button=button,render=function()redraw()end,act=function(action,args)table.insert(actions,{action=action,args=args});calls+=1 end})
   local catalog={NoviceChapter=config,EquipmentLimit=50,AdventurerOrder={"Warrior","Knight","Archer","Mage","Priest"}}
   for _,mode in ipairs({"unavailable","active","ready","trial","class","full","foundation","busy","complete"}) do
    local data:any={language=language,hallLevel=0,adventurers={},inventory={equipment={}},character={level=10},progression={novice={claimed=0,objectives={}}}}
    local s=data.progression.novice
    if mode=="unavailable"then data.progression.novice=nil
    elseif mode=="ready"then for _,id in ipairs(config.Chapters[1].Objectives)do s.objectives[id]=true end
    elseif mode=="trial"then s.claimed=5
    elseif mode=="class"or mode=="full"then s.claimed=5;s.trialClass="Mage";if mode=="full"then for i=1,50 do data.inventory.equipment[tostring(i)]={}end end
    elseif mode=="foundation"or mode=="busy"then s.claimed=5;s.trialClass="Mage";data.character.classId="Mage";for _,id in ipairs(config.Chapters[6].Objectives)do s.objectives[id]=true end
    elseif mode=="complete"then s.claimed=6;data.hallLevel=1 end
    redraw=function()host:ClearAllChildren();table.clear(callbacks);render(data,catalog,mode=="busy")end
    table.clear(actions);redraw();task.wait(.15)
    local state=describe(data,catalog,mode=="busy")
    for _,l in ipairs(host:GetDescendants())do
     if l:IsA("TextLabel")or l:IsA("TextButton")then assert(l.TextBounds.X<=l.AbsoluteSize.X+1 and l.TextBounds.Y<=l.AbsoluteSize.Y+1,"Clipped "..mode.." "..language.." "..l.Text);textChecks+=1 end
     if l:IsA("TextButton")and l.Parent and (l.Parent.Name=="NoviceHeroChoices"or l.Parent.Name=="CampaignHeroChoices")then
      local f=l.Parent :: Frame;assert(l.AbsolutePosition.X>=f.AbsolutePosition.X-1 and l.AbsolutePosition.Y>=f.AbsolutePosition.Y-1 and l.AbsolutePosition.X+l.AbsoluteSize.X<=f.AbsolutePosition.X+f.AbsoluteSize.X+1 and l.AbsolutePosition.Y+l.AbsoluteSize.Y<=f.AbsolutePosition.Y+f.AbsoluteSize.Y+1,"Choice outside grid")
     end
     if l:IsA("TextButton")then assert(l.Active==l.Selectable);assert(l.AbsoluteSize.Y>=44)end
    end
    local claim=host:FindFirstChild("NoviceClaim",true)
    if claim then assert((claim::TextButton).Active==state.canClaim);callbacks[claim]();assert(#actions==(if state.canClaim then 1 else 0)) end
    local choose=host:FindFirstChild("NoviceSelectClass",true)
    if choose then
     assert((choose::TextButton).Active==state.canSelect);callbacks[choose]();assert(#actions==0)
     if state.canSelect then callbacks[assert(host:FindFirstChild("NoviceSelectClass",true))]();assert(#actions==1 and actions[1].action=="SelectPlayerClass" and actions[1].args.classId=="Mage")end
    end
    local found=host:FindFirstChild("NoviceFound",true)
    if found then
     local choices=assert(host:FindFirstChild("NoviceHeroChoices",true)) :: Frame
     assert(choices.AbsoluteSize.Y==(if width>=640 then 52 else 172),"Unexpected choice height")
     local rows={};for _,id in ipairs(catalog.AdventurerOrder)do
      local b=assert(choices:FindFirstChild("NoviceHero_"..id)) :: TextButton
      assert(b.AbsoluteSize.X>=88,"Choice too narrow");table.insert(rows,b)
     end
     for i,a in ipairs(rows)do for j,b in ipairs(rows)do if i<j then
      local overlapX=math.min(a.AbsolutePosition.X+a.AbsoluteSize.X,b.AbsolutePosition.X+b.AbsoluteSize.X)-math.max(a.AbsolutePosition.X,b.AbsolutePosition.X)
      local overlapY=math.min(a.AbsolutePosition.Y+a.AbsoluteSize.Y,b.AbsolutePosition.Y+b.AbsoluteSize.Y)-math.max(a.AbsolutePosition.Y,b.AbsolutePosition.Y)
      assert(overlapX<=0 or overlapY<=0,"Overlapping hero choices")
     end end end
     assert((found::TextButton).Active==state.canFound);callbacks[found]();assert(#actions==0)
     if state.canFound then
      callbacks[assert(host:FindFirstChild("NoviceHero_Priest",true))]();assert(#actions==0)
      callbacks[assert(host:FindFirstChild("NoviceFound",true))]();assert(#actions==0)
      callbacks[assert(host:FindFirstChild("NoviceFound",true))]();assert(#actions==1 and actions[1].action=="FoundNoviceGuild" and actions[1].args.heroClass=="Priest")
     end
    end
    views+=1
   end
  end end
  return {views=views,capturedActions=calls,textBoundsChecks=textChecks,languages={"en","th"},widths={240,640,704},profileWrites=0,runtimeBinding=false}
 end)
 gui:Destroy();assert(ok,tostring(result));return result
end
