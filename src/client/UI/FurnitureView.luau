--!strict
local Rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
local templates=require(game.ReplicatedStorage.Shared.Presentation.FurnitureKit)()
return function(ui:any)
    local confirm:string?=nil
    return function(data:any,catalog:any,busy:boolean)
        local owned=data.expansion.furniture or {};local ids={}
        for id in pairs(owned) do table.insert(ids,id) end;table.sort(ids)
        local head=ui.card(ui.scroll,"Furniture")
        ui.button(head,"Back to Base",not busy,function()ui.navigate("Base")end)
        ui.text(head,"Craft furniture, then place it on open outdoor land. Store it to move it later without paying again.",16)
        ui.text(head,ui.T("Furniture owned: {count}/{limit}",{count=#ids,limit=Rules.FurnitureLimit}),16)
        ui.text(head,"New layouts save furniture too. Older building-only layouts keep furniture in place.",14)
        for _,id in ipairs(ids) do
            local b=owned[id];local def=Rules.Furniture[b.kind]
            local card=ui.card(ui.scroll,def.Name);card.Name="OwnedFurniture_"..id
            ui.text(card,id.." · "..ui.T(if b.stored then "Stored" else "Placed"),15)
            ui.button(card,if b.stored then "Place furniture" else "Move furniture",not busy,function()ui.build(data,b.kind,id)end).Name="PlaceFurniture_"..id
            if not b.stored then ui.button(card,"Store furniture",not busy,function()ui.act("StoreFurniture",{furnitureId=id})end).Name="StoreFurniture_"..id end
            ui.button(card,if confirm==id then "Confirm recycle furniture · half materials returned" else "Recycle furniture · half materials returned",not busy,function()
                if confirm==id then confirm=nil;ui.act("DismantleFurniture",{furnitureId=id}) else confirm=id;ui.render() end
            end).Name="RecycleFurniture_"..id
        end
        for _,kind in ipairs(Rules.FurnitureOrder) do
            local def=Rules.Furniture[kind];local card=ui.card(ui.scroll,def.Name);card.Name="CraftFurniture_"..kind
            local preview=Instance.new("ViewportFrame");preview.Size=UDim2.new(1,0,0,if ui.scroll.AbsoluteSize.Y<180 then 80 else 140)
            preview.BackgroundTransparency=1;preview.Ambient=Color3.fromRGB(185,185,185);preview.LightColor=Color3.new(1,1,1);preview.Parent=card
            local model=(templates:FindFirstChild(kind) :: Model):Clone();model.Parent=preview
            local camera=Instance.new("Camera");camera.FieldOfView=40
            camera.CFrame=CFrame.lookAt(Vector3.new(10,9,14),Vector3.new(0,def.Height/2,0));camera.Parent=preview;preview.CurrentCamera=camera
            local materials={};local enough=true;local keys={};for item in pairs(def.Cost) do table.insert(keys,item) end;table.sort(keys)
            for _,item in ipairs(keys) do
                local quantity=def.Cost[item];table.insert(materials,ui.T(catalog.Items[item].Name).." ×"..quantity)
                if (data.inventory.stacks[item] or 0)<quantity then enough=false end
            end
            ui.text(card,table.concat(materials," · "),15)
            ui.button(card,if #ids>=Rules.FurnitureLimit then "Furniture limit reached" elseif not enough then "MissingMaterials" else "Craft furniture",not busy and enough and #ids<Rules.FurnitureLimit,function()ui.act("CraftFurniture",{kind=kind})end).Name="Craft_"..kind
        end
    end
end
