--!strict
-- Check native hit testing, not logical bounds of clipped/hidden controls.
-- An outside click remains a world click; it is not an activation of that control.
return function(playerGui:PlayerGui,input:InputObject,processed:boolean):boolean
 if processed then return true end
 if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return false end
 for _,object in ipairs(playerGui:GetGuiObjectsAtPosition(input.Position.X,input.Position.Y)) do
  if object.Active then return true end
 end
 return false
end
