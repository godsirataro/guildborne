--!strict
-- Presentation fixture only; does not move characters or send gameplay requests.
return function():any
 local gui=Instance.new("ScreenGui");gui.Name="CivicMapFixture";gui.Parent=game.Players.LocalPlayer.PlayerGui
 local make=require(game.Players.LocalPlayer.PlayerScripts.Client.UI.CivicMapView)
 local civic=require(game.ReplicatedStorage.Shared.Config.CivicCities)
 local view=make(gui,function()end);view.frame.Visible=true
 local checks=0;local cases=0
 local ok,result=pcall(function()
  for _,width in ipairs({240,640,704})do for _,lang in ipairs({"en","th"})do for _,id in ipairs(civic.Order)do
   local d=(civic.Definitions :: any)[id];view.frame.Size=UDim2.fromOffset(width,480);view.update(id,lang,d.X,d.Z+108);task.wait(.025)
   local nodes={}
   for _,v in ipairs(view.frame:GetChildren())do if v:IsA("TextButton")then
    assert(v.AbsoluteSize.Y>=44);assert(v.TextBounds.X<=v.AbsoluteSize.X and v.TextBounds.Y<=v.AbsoluteSize.Y,"Clipped "..id.." "..lang.." "..v.Text)
    assert(v.AbsolutePosition.X>=view.frame.AbsolutePosition.X and v.AbsolutePosition.X+v.AbsoluteSize.X<=view.frame.AbsolutePosition.X+width)
    table.insert(nodes,v);checks+=1
   end end
   assert(#nodes==6)
   for i,a in ipairs(nodes)do for j,b in ipairs(nodes)do if i<j then
    local ap,bp=a.AbsolutePosition,b.AbsolutePosition;local as,bs=a.AbsoluteSize,b.AbsoluteSize
    assert(ap.X+as.X<=bp.X or bp.X+bs.X<=ap.X or ap.Y+as.Y<=bp.Y or bp.Y+bs.Y<=ap.Y,"Map buttons overlap")
   end end end
   local marker=view.frame:FindFirstChild("CivicPlayerPosition") :: TextLabel
   assert(marker.Visible and math.abs(marker.Position.X.Scale-.5)<.001 and math.abs(marker.Position.Y.Scale-.932)<.001)
   cases+=1
  end end end
  view.update(nil,"en");assert(not(view.frame:FindFirstChild("CivicPlayerPosition") :: TextLabel).Visible)
  return {cases=cases,textBounds=checks,cityCount=6,widths={240,640,704},languages={"en","th"},overlap=false,profileWrites=0,synthetic=true}
 end)
 gui:Destroy();assert(ok,tostring(result));return result
end
