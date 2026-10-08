--!strict
-- Staged Chapter02 synthetic screens; callback capture never invokes networking.
return function(config:any,draw:any):any
 local gui=Instance.new("ScreenGui");gui.Name="IronveilUIFixture";gui.Parent=game.Players.LocalPlayer.PlayerGui
 local host=Instance.new("ScrollingFrame");host.AutomaticCanvasSize=Enum.AutomaticSize.Y;host.CanvasSize=UDim2.new();host.Parent=gui
 local views=0;local bounds=0;local calls=0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640,704})do for _,language in ipairs({"en","th"})do for index=7,12 do for _,mode in ipairs({"hall_locked","active","ready"})do
   host:ClearAllChildren();host.Size=UDim2.fromOffset(width,300)
   local callbacks:{[Instance]:any}={};local action:any=nil
   local function text(parent:Instance,value:string,size:number?):TextLabel
    local l=Instance.new("TextLabel");l.Text=value;l.TextSize=size or 16;l.Font=Enum.Font.Gotham;l.Size=UDim2.new(1,0,0,0);l.TextWrapped=true;l.AutomaticSize=Enum.AutomaticSize.Y;l.Parent=parent;return l
   end
   local function card(parent:Instance,title:string):Frame
    local f=Instance.new("Frame");f.Size=UDim2.new(1,-24,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
    local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,10);layout.Parent=f;text(f,title,20);return f
   end
   local function button(parent:Instance,label:string,enabled:boolean,callback:any):TextButton
    local b=Instance.new("TextButton");b.Text=label;b.TextSize=17;b.Font=Enum.Font.Gotham;b.TextWrapped=true;b.Size=UDim2.new(1,0,0,52);b.Active=enabled;b.Parent=parent;callbacks[b]=callback;return b
   end
   local chapter=config.Chapters[index]
   local data:any={language=language,hallLevel=if mode=="hall_locked"then chapter.Hall-1 else chapter.Hall,rosterCapacity=10,adventurers={},inventory={equipment={}},character={level=chapter.Level},quests={},expansion={tower={}},progression={novice={claimed=6},campaign={claimed=index-1,objectives={}}}}
   if mode~="active"then for _,id in ipairs(chapter.Objectives)do data.progression.campaign.objectives[id]=true end end
   local render=draw({scroll=host,T=function(s:string)return s end,text=text,card=card,button=button,render=function()end,act=function(kind,args)action={kind=kind,args=args};calls+=1 end})
   render(data,{CampaignChapter=config,EquipmentLimit=50},false);task.wait(.1)
   for _,v in ipairs(host:GetDescendants())do if v:IsA("TextLabel")or v:IsA("TextButton")then assert(v.TextBounds.X<=v.AbsoluteSize.X+1 and v.TextBounds.Y<=v.AbsoluteSize.Y+1,"Clipped "..mode.." "..language.." "..v.Text);bounds+=1 end end
   local claim=host:FindFirstChild("CampaignClaim",true) :: TextButton;assert(claim and claim.Active==(mode=="ready"))
   callbacks[claim]();assert((action~=nil)==(mode=="ready"))
   if action then assert(action.kind=="ClaimCampaignChapter"and action.args.chapterId==chapter.Id)end
   views+=1
  end end end end
  return {views=views,textBoundsChecks=bounds,capturedCallbacks=calls,profileWrites=0,chapter02Activated=false}
 end)
 gui:Destroy();if not ok then error(result)end;return result
end
