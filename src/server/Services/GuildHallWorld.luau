--!strict
-- Render committed Hall state only. Placement authority lives in the data service.
local V=Vector3.new
local Appearance=require(game.ReplicatedStorage.Shared.Presentation.HallAppearance)
return function(plot:any,templates:Instance,level:number,position:any?,themeId:string?)
    local theme=themeId or "human"
    if plot.level~=level or plot.hall:GetAttribute("BuildingTheme")~=theme then
        local template=templates:FindFirstChild(if level>=2 then "GuildHallLv2" else "GuildHallLv1") :: Model
        local hall=template:Clone();Appearance.apply(hall,theme);hall.Parent=plot.buildings
        plot.hall:Destroy();plot.hall=hall;plot.level=level
    end
    local cf=CFrame.new(plot.origin+V(0,0,-24))
    if position then
        local w,d=4,3;if position.rotation%2==1 then w,d=d,w end
        cf=CFrame.new(plot.origin+V((position.x+w/2)*8,0,(position.z+d/2)*8))*CFrame.Angles(0,position.rotation*math.pi/2,0)
    end
    if plot.hall:GetPivot()~=cf then plot.hall:PivotTo(cf) end
    local sign=plot.hall:FindFirstChild("HallSign")
    local label=sign and sign:FindFirstChildWhichIsA("TextLabel",true)
    if label then label.Text="Guild Hall · Lv"..level.."\nหอกิลด์ · ระดับ "..level end
    plot.hallStation.CFrame=cf*CFrame.new(0,3,if position then 13 else 11)
end
