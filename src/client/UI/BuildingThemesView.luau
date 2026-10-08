--!strict
local Shared=game.ReplicatedStorage.Shared
local Catalog=require(Shared.Config.BuildingThemes)
local Appearance=require(Shared.Presentation.BuildingAppearance)
local HallAppearance=require(Shared.Presentation.HallAppearance)
local FurnitureAppearance=require(Shared.Presentation.FurnitureAppearance)
local furnitureTemplates=require(Shared.Presentation.FurnitureKit)()
local Rules=require(Shared.Data.Expansion)
return function(ui:any)
    local selected:string?=nil
    return function(data:any,busy:boolean)
        local e=data.expansion;local ids={"guildHall"};local owned={guildHall={kind="guildHall",theme=e.hallTheme}}
        for id,b in pairs(e.buildings) do table.insert(ids,id);owned[id]=b end
        for id,b in pairs(e.storage or {}) do table.insert(ids,id);owned[id]=b end
        for id,b in pairs(e.furniture or {}) do table.insert(ids,id);owned[id]=b end;table.sort(ids)
        if not selected or not owned[selected] then selected=ids[1] end
        local head=ui.card(ui.scroll,"Building themes")
        ui.button(head,"Back to Base",not busy,function()ui.navigate("Base")end)
        ui.text(head,"Choose a building, then apply an owned theme. Upgrades and placement stay the same.",16)
        ui.text(head,"Themes apply to your Hall, utility buildings and furniture, including stored pieces.",14)
        local building=selected and owned[selected]
        if building then
            ui.button(head,ui.T(Rules.footprint(building.kind).Name).." · "..(selected or ""),not busy,function()
                selected=ids[(table.find(ids,selected or "guildHall") or 0)%#ids+1];ui.render(true)
            end).Name="ThemeBuilding"
        else ui.text(head,"Build a utility building before applying a theme.",16) end
        for _,id in ipairs(Catalog.Order) do
            local def=Catalog.Themes[id];local card=ui.card(ui.scroll,def.Name);card.Name="Theme_"..id
            local preview=Instance.new("ViewportFrame");preview.Name="ThemePreview";preview.Size=UDim2.new(1,0,0,if ui.scroll.AbsoluteSize.Y<180 then 80 else 160)
            preview.BackgroundTransparency=1;preview.Ambient=Color3.fromRGB(185,185,185);preview.LightColor=Color3.new(1,1,1);preview.Parent=card
            local camera=Instance.new("Camera");camera.FieldOfView=40;camera.CFrame=CFrame.lookAt(Vector3.new(22,20,28),Vector3.new(0,5,0));camera.Parent=preview;preview.CurrentCamera=camera
            if selected=="guildHall" then
                local world=workspace:FindFirstChild("GuildborneWorld");local original:Model?=nil
                if world then for _,plot in ipairs(world:GetChildren()) do if plot:GetAttribute("OwnerUserId")==game.Players.LocalPlayer.UserId then
                    for _,m in ipairs(plot:GetDescendants()) do if m:IsA("Model") and m.Name:match("^GuildHallLv%d+$") then original=m;break end end
                end end end
                if original then
                    local m=original:Clone();m:PivotTo(CFrame.identity)
                    for _,child in ipairs(m:GetDescendants()) do if child:IsA("BillboardGui") or child:IsA("ProximityPrompt") then child:Destroy() end end
                    HallAppearance.apply(m,id);m.Parent=preview
                    camera.CFrame=CFrame.lookAt(Vector3.new(34,28,42),Vector3.new(0,8,0))
                else ui.text(card,"Preview unavailable",14) end
            elseif building and Rules.Furniture[building.kind] then
                local m=(furnitureTemplates:FindFirstChild(building.kind) :: Model):Clone()
                FurnitureAppearance.apply(m,id);m.Parent=preview
                camera.CFrame=CFrame.lookAt(Vector3.new(10,9,14),Vector3.new(0,Rules.Furniture[building.kind].Height/2,0))
            else Appearance.preview(id).Parent=preview end
            local has=def.Mode=="Free" or (e.themeRights and e.themeRights[id]==true)
            if has then
                local current=building and (building.theme or "human")==id
                ui.button(card,if current then "Theme applied" else "Apply theme",not busy and building~=nil and not current,function()
                    if selected then ui.act("ApplyBuildingTheme",{buildingId=selected,themeId=id}) end
                end).Name="ApplyTheme_"..id
            elseif def.Mode=="Quest" then
                ui.text(card,"Complete Borga's A Hearth for Everyone quest to earn this theme.",15)
                local quest=data.settlement.journal[def.Quest]
                ui.button(card,"Claim quest theme",not busy and quest~=nil and quest.state=="Claimed",function()ui.act("UnlockBuildingTheme",{themeId=id})end).Name="UnlockTheme_"..id
            elseif data.permanentPassOffers and data.permanentPassOffers.Theme[id] then
                ui.text(card,"One-time cosmetic theme. Review the Robux price in Roblox before confirming.",15)
                ui.button(card,"Review theme purchase",not busy,function()ui.act("RequestPermanentPass",{kind="Theme",key=id})end).Name="PurchaseTheme_"..id
            else ui.text(card,"Robux theme purchase is not available yet. No payment has been taken.",15) end
        end
    end
end
