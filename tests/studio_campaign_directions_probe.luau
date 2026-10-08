--!strict
-- Synthetic read-only navigation models. No gameplay requests or player movement.
return function(make:any):any
 local player=game.Players.LocalPlayer;local scope=Instance.new("Folder");scope.Name="DirectionsFixture";scope.Parent=workspace
 local other=Instance.new("Model");other.Name="CrosshavenCourt_"..player.UserId;other:SetAttribute("CampaignOwner",player.UserId+1);other:SetAttribute("NavigationText","Foreign target");other:SetAttribute("NavigationVisible",true);other.Parent=scope
 local api=make(scope,true);local gui=player.PlayerGui:FindFirstChild("CampaignDirections") :: ScreenGui
 local ok,result=pcall(function():any
  api.Step(Vector3.zero,Vector3.new(0,0,-1),false);assert(not gui.Enabled);other:Destroy()
  local m=Instance.new("Model");m.Name="CrosshavenCourt_"..player.UserId;m:SetAttribute("CampaignOwner",player.UserId);m:SetAttribute("NavigationVisible",true);m.Parent=scope
  local panel=gui:FindFirstChild("DirectionPanel") :: Frame;local label=panel:FindFirstChild("Destination") :: TextLabel;local arrow=panel:FindFirstChild("Heading") :: TextLabel
  local holder=Instance.new("Frame");holder.BackgroundTransparency=1;holder.Position=UDim2.fromOffset(0,0);holder.Size=UDim2.fromOffset(240,340);holder.Parent=gui;panel.Parent=holder
  local states=0
  for _,width in ipairs({240,360,750})do holder.Size=UDim2.fromOffset(width,340);task.wait(.05)
   for _,th in ipairs({false,true})do for _,target in ipairs({false,true})do
    m:SetAttribute("NavigationThai",th);m:SetAttribute("NavigationPosition",if target then Vector3.new(100,3,-100)else nil)
    m:SetAttribute("NavigationText",if target then (if th then "อ่านข้อเสนอและผลที่จะตามมา"else "Read the offer and its consequences")else (if th then "กลับเมืองรวม · เข้าลานครอสเฮเวนข้างวาปเกาะกิลด์"else "Return to City · enter Crosshaven beside the Guild Zone Warp"))
    api.Step(Vector3.zero,Vector3.new(0,0,-1),false);task.wait(.05);api.Step(Vector3.zero,Vector3.new(0,0,-1),false);task.wait(.05)
    assert(gui.Enabled and arrow.Visible==target);assert(label.TextBounds.Y<=label.AbsoluteSize.Y+1,"Navigation text overflow");assert(panel.AbsoluteSize.X<=width)
    if target then assert(math.abs(arrow.Rotation-45)<.1)end;states+=1
   end end
  end
  api.Step(Vector3.zero,Vector3.new(0,0,-1),true);assert(not gui.Enabled)
  m:SetAttribute("NavigationVisible",false);api.Step(Vector3.zero,Vector3.new(0,0,-1),false);assert(not gui.Enabled)
  m:Destroy();api.Step(Vector3.zero,Vector3.new(0,0,-1),false);assert(not gui.Enabled)
  return {languageWidthStates=states,foreignOwnerHidden=true,blockedHidden=true,inactiveHidden=true,removedHidden=true,profileWrites=0,gameplayInputs=0}
 end)
 api.Destroy();scope:Destroy();if not ok then error(result)end;return result
end
