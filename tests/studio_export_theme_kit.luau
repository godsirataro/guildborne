--!strict
-- Read-only native geometry export; no profile or asset uploads.
return function()
    local A=require(game.ReplicatedStorage.Shared.Presentation.BuildingAppearance)
    local C=require(game.ReplicatedStorage.Shared.Config.BuildingThemes)
    local palette:any={ivory={235,225,202}};local assets={}
    for _,id in ipairs(C.Order) do
        local model=A.preview(id);local parts={}
        for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then
            local rgb={math.round(p.Color.R*255),math.round(p.Color.G*255),math.round(p.Color.B*255)}
            local key=table.concat(rgb,"_");palette[key]=rgb
            local x,y,z=p.CFrame:ToEulerAnglesXYZ()
            table.insert(parts,{name=p.Name,size={p.Size.X,p.Size.Y,p.Size.Z},position={p.Position.X,p.Position.Y,p.Position.Z},
                rotation={math.deg(x),math.deg(y),math.deg(z)},color=key,shape="Block",collide=p.CanCollide})
        end end
        table.insert(assets,{id="theme_"..id,theme=id,parts=parts});model:Destroy()
    end
    return {schema=1,source="Guildborne native BuildingAppearance prototypes",units="stud",palette=palette,assets=assets}
end
