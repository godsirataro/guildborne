--!strict
-- Clone presentation controls only; no profile writes or controller callbacks.
return function():any
 local player=game.Players.LocalPlayer
 local source=player.PlayerGui.CityNavigation.CityMap.MapScroll.RegionalMap
 local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
 local rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
 local city=require(game.ReplicatedStorage.Shared.Config.City)
 local gui=Instance.new("ScreenGui");gui.Name="RegionalMapFixture";gui.Parent=player.PlayerGui
 local checks=0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640}) do for _,language in ipairs({"en","th"}) do for _,region in ipairs(city.RegionOrder) do
   local map=source:Clone();map.Visible=true;map.Size=UDim2.fromOffset(width,260);map.Parent=gui
   local visible:{TextButton}={}
   for _,child in ipairs(map:GetChildren())do if child:IsA("TextButton")then
    local id=child.Name:gsub("^GuideResource_","");local node=rules.Nodes[id]
    child.Visible=(node and node.Region==region) or id=="return_"..region
    if child.Visible then
     child.Text=locale.translate(language,if node then ({timber="Timber",stone="Stone",iron_ore="Iron Ore",herb="Herb"})[node.Item] else "Central City")
     table.insert(visible,child)
    end
   end end
   task.wait(.06);assert(#visible==3)
   for i,b in ipairs(visible)do
    local p=b.AbsolutePosition-map.AbsolutePosition;local size=b.AbsoluteSize
    assert(p.X>=0 and p.Y>=0 and p.X+size.X<=width and p.Y+size.Y<=260,"Marker clipped")
    assert(size.X>=44 and size.Y>=44,"Touch target too small")
    local viewport=151.84;local canvas=260*.71-viewport*.5
    assert(p.Y-canvas>=0 and p.Y-canvas+size.Y<=viewport,"Initial compact map choice hidden")
    assert(b.TextBounds.X<=size.X and b.TextBounds.Y<=size.Y,"Regional label clipped: "..language.." "..b.Text)
    for j=i+1,#visible do local other=visible[j];local q=other.AbsolutePosition-map.AbsolutePosition;local s=other.AbsoluteSize
     assert(not (p.X<q.X+s.X and p.X+size.X>q.X and p.Y<q.Y+s.Y and p.Y+size.Y>q.Y),"Regional buttons overlap")
    end
    checks+=1
   end
   map:Destroy()
  end end end
  return {buttonChecks=checks,regions=3,widths={240,640},languages={"en","th"},noOverlap=true,noClipping=true,minimumTouchSize=44,synthetic=true,profileWrites=0}
 end)
 gui:Destroy();assert(ok,tostring(result));return result
end
