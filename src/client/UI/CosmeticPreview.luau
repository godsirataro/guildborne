--!strict
-- A single bounded local preview. Selection never sends an ownership/equip request.
local make=require(game.ReplicatedStorage.Shared.Data.CosmeticVisuals)
local Colors=require(game.ReplicatedStorage.Shared.Config.Art).UI
local entries={
    {id="founder_cloak",name="Founder cloak"},{id="compass_blade",name="Compass blade"},
    {id="company_banner",name="Company banner"},{id="hearth_decor",name="Hearth decor"},
    {id="ivory_portrait_frame",name="Ivory portrait frame"},{id="friendly_greeting",name="Friendly greeting"},
    {id="rune_portal",name="Rune portal"},{id="pale_spell_trail",name="Pale spell trail"},
}
return function(parent:Instance,T:(string)->string):any
    local viewHeight=math.clamp((if workspace.CurrentCamera then workspace.CurrentCamera.ViewportSize.Y else 600)*.45,130,220)
    local frame=Instance.new("Frame");frame.Name="CosmeticPreview";frame.Size=UDim2.new(1,-8,0,viewHeight+180);frame.BackgroundTransparency=1;frame.Parent=parent
    local function text(name:string,y:number,height:number):TextLabel
        local t=Instance.new("TextLabel");t.Name=name;t.Position=UDim2.fromOffset(0,y);t.Size=UDim2.new(1,0,0,height)
        t.BackgroundTransparency=1;t.TextColor3=Colors.Text;t.Font=Enum.Font.GothamMedium;t.TextSize=15;t.TextWrapped=true;t.Parent=frame;return t
    end
    local title=text("SelectedCosmetic",0,40)
    local view=Instance.new("ViewportFrame");view.Name="CosmeticViewport";view.Position=UDim2.fromOffset(0,42);view.Size=UDim2.new(1,0,0,viewHeight)
    view.BackgroundColor3=Colors.Background;view.Ambient=Color3.fromRGB(190,190,190);view.LightColor=Color3.new(1,1,.94);view.LightDirection=Vector3.new(-1,-2,-3);view.Parent=frame
    local world=Instance.new("WorldModel");world.Parent=view
    local camera=Instance.new("Camera");camera.FieldOfView=35;camera.Parent=view;view.CurrentCamera=camera
    local index=1;local angle=0;local model:Model?=nil
    local function fit()
        if not model then return end
        local cf,size=model:GetBoundingBox();local radius=size.Magnitude/2
        local aspect=math.max(.1,view.AbsoluteSize.X/math.max(1,view.AbsoluteSize.Y))
        local half=math.atan(math.tan(math.rad(17.5))*math.min(1,aspect))
        local direction=(CFrame.Angles(0,angle,0)*Vector3.new(1,.4,-3)).Unit
        camera.CFrame=CFrame.lookAt(cf.Position+direction*(radius/math.sin(half)*1.12),cf.Position)
    end
    local function selectEntry(nextIndex:number)
        index=(nextIndex-1)%#entries+1;angle=0;world:ClearAllChildren()
        local entry=entries[index];local folder=make(entry.id);model=folder:FindFirstChild(entry.id) :: Model
        assert(model);model.Parent=world;folder:Destroy();view:SetAttribute("CosmeticId",entry.id)
        title.Text=T(entry.name).." · "..index.." / "..#entries;fit()
    end
    local function button(name:string,x:number,label:string,callback:()->()):TextButton
        local b=Instance.new("TextButton");b.Name=name;b.Position=UDim2.new(x,0,0,viewHeight+52);b.Size=UDim2.new(.32,0,0,48)
        b.Text=T(label);b.TextWrapped=true;b.Font=Enum.Font.GothamMedium;b.TextSize=14;b.BackgroundColor3=Colors.Card;b.TextColor3=Colors.Text;b.Parent=frame
        local corner=Instance.new("UICorner");corner.Parent=b;b.Activated:Connect(callback);return b
    end
    button("PreviousCosmetic",0,"Previous",function() selectEntry(index-1) end)
    button("RotateCosmetic",.34,"Rotate preview",function() angle+=math.pi/4;fit() end)
    button("NextCosmetic",.68,"Next",function() selectEntry(index+1) end)
    local hint=text("PreviewNotice",viewHeight+108,68);hint.TextColor3=Colors.Muted
    hint.Text=T("Appearance preview only. Collection and equipping are coming later. Emote and spell previews are still poses.")
    local resize=view:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
    frame.Destroying:Connect(function() resize:Disconnect();model=nil end)
    selectEntry(1)
    return {frame=frame,select=selectEntry,view=view,entries=entries}
end
