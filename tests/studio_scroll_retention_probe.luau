--!strict
return function(factory:any):any
 local gui=Instance.new("ScreenGui");gui.Name="ScrollRetentionFixture";gui.Parent=game.Players.LocalPlayer.PlayerGui
 local frames=0
 local ok,result=pcall(function():any
  for _,width in ipairs({240,640,704})do
   local scroll=Instance.new("ScrollingFrame");scroll.Size=UDim2.fromOffset(width,150);scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=gui
   local function fill(height:number)
    scroll:ClearAllChildren();local content=Instance.new("Frame");content.Size=UDim2.new(1,0,0,height);content.Parent=scroll
   end
   local retain=factory(scroll);fill(2000);task.wait(.1);scroll.CanvasPosition=Vector2.new(0,1200);task.wait(.1)
   for _=1,4 do
    retain(false);fill(0);fill(2000);task.wait(.1)
    assert(math.abs(scroll.CanvasPosition.Y-1200)<=1,"Rebuild lost scroll offset");frames+=1
   end
   retain(false);fill(2000);retain(true);fill(2000);task.wait(.1)
   assert(scroll.CanvasPosition.Y==0,"Stale render overrode navigation reset")
   scroll.CanvasPosition=Vector2.new(0,1200);retain(false);fill(300);task.wait(.1)
   assert(scroll.CanvasPosition.Y<=150,"Shorter page failed to clamp")
   retain(false);scroll:Destroy();task.wait(.1)
  end
  return {retainedRebuilds=frames,widths={240,640,704},checks={"automatic canvas rebuild","latest render wins","explicit navigation reset","short content clamp","destroy before callback"},profileWrites=0}
 end)
 gui:Destroy();assert(ok,tostring(result));return result
end
