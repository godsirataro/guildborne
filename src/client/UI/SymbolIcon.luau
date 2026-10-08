--!strict
local symbols=require(game.ReplicatedStorage.Shared.Data.UISymbols)
return function(parent:Instance,id:string,size:number?,color:Color3?):Frame?
    local shapes=symbols[id];if not shapes then return nil end
    local px=size or 24;local tint=color or Color3.fromRGB(214,183,111)
    local root=Instance.new("Frame");root.Name="SymbolIcon";root.Size=UDim2.fromOffset(px,px);root.BackgroundTransparency=1;root.Active=false;root:SetAttribute("SymbolId",id);root.Parent=parent
    local scale=px/32;local width=math.max(1,1.8*scale)
    for _,shape in ipairs(shapes) do
        local s=shape.points
        local p=Instance.new("Frame");p.BorderSizePixel=0;p.Active=false;p.Parent=root
        if shape.kind=="line" then
            local a=Vector2.new(s[1],s[2])*scale;local b=Vector2.new(s[3],s[4])*scale;local delta=b-a
            p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale((a.X+b.X)/(2*px),(a.Y+b.Y)/(2*px));p.Size=UDim2.fromScale(delta.Magnitude/px,width/px);p.Rotation=math.deg(math.atan2(delta.Y,delta.X));p.BackgroundColor3=tint
            local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(1,0);corner.Parent=p
        else
            p.BackgroundTransparency=1
            if shape.kind=="circle" then
                p.Position=UDim2.fromScale((s[1]-s[3])/32,(s[2]-s[3])/32);p.Size=UDim2.fromScale(s[3]*2/32,s[3]*2/32)
                local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(1,0);corner.Parent=p
            else p.Position=UDim2.fromScale(s[1]/32,s[2]/32);p.Size=UDim2.fromScale(s[3]/32,s[4]/32) end
            local stroke=Instance.new("UIStroke");stroke.Color=tint;stroke.Thickness=width;stroke.Parent=p
        end
    end
    return root
end
