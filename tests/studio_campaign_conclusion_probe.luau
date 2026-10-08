--!strict
-- Presentation-only native fixture; no profile grants or server requests.
return function(config:any):any
 local player=game.Players.LocalPlayer
 local draw=require(player.PlayerScripts.Client.UI.CampaignView)
 local gui=Instance.new("ScreenGui");gui.Name="CampaignConclusionFixture";gui.Parent=player.PlayerGui
 local host=Instance.new("ScrollingFrame");host.AutomaticCanvasSize=Enum.AutomaticSize.Y;host.CanvasSize=UDim2.new();host.Parent=gui
 local views=0;local bounds=0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640,704})do for _,language in ipairs({"en","th"})do
   host.Size=UDim2.fromOffset(width,300)
   local function text(parent:Instance,s:string,size:number?):TextLabel
    local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,0);l.AutomaticSize=Enum.AutomaticSize.Y;l.TextWrapped=true;l.Font=Enum.Font.Gotham;l.TextSize=size or 18;l.Text=s;l.Parent=parent;return l
   end
   local function card(parent:Instance,title:string):Frame
    local f=Instance.new("Frame");f.Size=UDim2.new(1,-12,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
    local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.PaddingRight=UDim.new(0,12);pad.Parent=f
    local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,10);layout.Parent=f;text(f,title,20);return f
   end
   local render=draw({scroll=host,text=text,card=card,T=function(s)return s end,button=function(parent:Instance,title:string)
    assert(title=="Replay ending"or title=="ดูฉากจบอีกครั้ง","Completion must not offer a duplicate claim")
    local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,52);b.TextWrapped=true;b.Font=Enum.Font.GothamMedium;b.TextSize=17;b.Text=title;b.Parent=parent;return b
   end})
   for _,ending in ipairs({"preserve","transform","dismantle","unknown"})do
    for _,count in ipairs({6,12,18,24,30,36})do
     host:ClearAllChildren()
     local chapters={};for i=1,count do table.insert(chapters,config.Chapters[i])end
     local data:any={language=language,hallLevel=17,progression={novice={claimed=6},campaign={claimed=count,objectives={},choices={choose_tower_future=ending,choose_motto="together",choose_crest="compass"}}}}
     render(data,{CampaignChapter={Chapters=chapters}},false);task.wait(.04)
     local endingLabel=host:FindFirstChild("CampaignEnding",true)
     assert((endingLabel~=nil)==(count==36 and ending~="unknown"),"Inferred an unavailable ending")
     for _,l in ipairs(host:GetDescendants())do if l:IsA("TextLabel")or l:IsA("TextButton")then
      assert(l.TextBounds.X<=l.AbsoluteSize.X+1 and l.TextBounds.Y<=l.AbsoluteSize.Y+1,"Clipped "..language.." "..l.Text);bounds+=1
     end end
     local preview=host:FindFirstChild("CampaignEndingPreview",true)
     assert((preview~=nil)==(count==36 and ending~="unknown"))
     if preview then
      local viewport=preview :: ViewportFrame;local camera=assert(viewport.CurrentCamera)
      local aspect=viewport.AbsoluteSize.X/viewport.AbsoluteSize.Y;local tan=math.tan(math.rad(camera.FieldOfView/2))
      for _,p in ipairs(viewport:GetDescendants())do if p:IsA("BasePart")then
       assert(not p.CanCollide and not p.CanQuery and not p.CanTouch)
       for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,z in ipairs({-1,1})do
        local v=camera.CFrame:PointToObjectSpace(p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2))
        assert(v.Z<0 and math.abs(v.Y)/(-v.Z*tan)<.98 and math.abs(v.X)/(-v.Z*tan*aspect)<.98,"Ending outside camera frame")
       end end end
      end end
     end
     views+=1
    end
   end
  end end
  return {views=views,textBoundsChecks=bounds,profileWrites=0,serverRequests=0}
 end)
 gui:Destroy();if not ok then error(result)end;return result
end
