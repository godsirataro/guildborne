--!strict
-- AutomaticCanvasSize may clamp CanvasPosition while a view is rebuilt.
return function(scroll:ScrollingFrame)
 local generation=0
 return function(reset:boolean?,focusName:string?)
  generation+=1;local current=generation
  local retained=if reset then Vector2.zero else scroll.CanvasPosition
  if reset then scroll.CanvasPosition=Vector2.zero end
  task.defer(function()
   game:GetService("RunService").RenderStepped:Wait()
   if current==generation and scroll.Parent then
    local target=if focusName then scroll:FindFirstChild(focusName,true)else nil
    if target and target:IsA("GuiObject")then
     scroll.CanvasPosition=Vector2.new(0,math.max(0,scroll.CanvasPosition.Y+target.AbsolutePosition.Y-scroll.AbsolutePosition.Y-16))
    else scroll.CanvasPosition=retained end
   end
  end)
 end
end
