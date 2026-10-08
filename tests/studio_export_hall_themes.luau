--!strict
-- Read-only geometry export; no upload, entitlement grant or profile mutation.
return function(level:number,theme:string)
    assert(game.PlaceId==0 and game.GameId==0 and (level==1 or level==2))
    local kit=require(game.ServerScriptService.Server.Services.ArtKit).Build()
    local m=(kit:FindFirstChild("GuildHallLv"..level) :: Model):Clone()
    local asset:any={id="hall_"..theme.."_lv"..level,theme=theme,level=level,parts={}}
    local palette:any={ivory={235,225,202}}
    local ok,reason=pcall(function()
        require(game.ReplicatedStorage.Shared.Presentation.HallAppearance).apply(m,theme)
        for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") and p.Transparency<1 then
            local c=p.Color;local rgb={math.floor(c.R*255+.5),math.floor(c.G*255+.5),math.floor(c.B*255+.5)}
            local color=table.concat(rgb,"_");palette[color]=rgb
            local cf=m:GetPivot():ToObjectSpace(p.CFrame);local x,y,z=cf:ToEulerAnglesXYZ()
            table.insert(asset.parts,{name=p.Name,size={p.Size.X,p.Size.Y,p.Size.Z},position={cf.X,cf.Y,cf.Z},rotation={math.deg(x),math.deg(y),math.deg(z)},
                color=color,shape=if p:IsA("WedgePart") then "Wedge" else "Block",collide=p.CanCollide})
        end end
    end)
    m:Destroy();kit:Destroy();assert(ok,reason)
    return {asset=asset,palette=palette}
end
