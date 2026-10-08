--!strict
local Symbol=require(script.Parent.SymbolIcon)
local Colors=require(game.ReplicatedStorage.Shared.Config.Art).UI
-- Native class mark beside wrapped text. A badge never changes class selection.
return function(parent: Instance,classId: string,T: (string)->string): Frame?
    local id="ui.classes."..string.lower(classId)
    local frame=Instance.new("Frame");frame.Name="ClassBadge";frame.BackgroundTransparency=1
    frame.Size=UDim2.new(1,0,0,28);frame.Parent=parent
    local icon=Symbol(frame,id,24,Colors.Accent)
    if not icon then frame:Destroy();return nil end
    icon.Position=UDim2.fromOffset(0,2)
    local label=Instance.new("TextLabel");label.Name="ClassName";label.BackgroundTransparency=1
    label.Position=UDim2.fromOffset(34,0);label.Size=UDim2.new(1,-34,1,0);label.Text=T(classId)
    label.TextXAlignment=Enum.TextXAlignment.Left;label.TextSize=16;label.TextWrapped=true
    label.Font=Enum.Font.GothamMedium;label.TextColor3=Colors.Accent;label.Parent=frame
    return frame
end
