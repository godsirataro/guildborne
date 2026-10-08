--!strict
-- Adapter keeps legacy 8-stud building coordinates and validates new land at 2 studs.
return function(legacy:any,makePlacement:any,layout:any)
    local plots:any={access={x=32,z=0,w=6,d=80}}
    for id,def in pairs(layout.Plots) do
        plots[id]={x=(def.x-def.width/2+104)/2,z=(def.z-def.depth/2+40)/2,w=def.width/2,d=def.depth/2}
    end
    local buildings={};for id,def in pairs(legacy.Buildings) do buildings[id]={w=def.Width*4,d=def.Depth*4} end
    for id,def in pairs(legacy.Furniture or {}) do buildings[id]={w=def.Width*4,d=def.Depth*4,noEntrance=true} end
    buildings.guildHall={w=legacy.HallFootprint.Width*4,d=legacy.HallFootprint.Depth*4}
    local placement=makePlacement({width=38,height=80,clearance=1,maxBuildings=9+(legacy.FurnitureLimit or 0),plots=plots,buildings=buildings,
        spawn={x=33,z=21},reserved={{x=32,z=0,w=6,d=80}}})
    local eastPlacement=makePlacement({width=32,height=40,clearance=1,maxBuildings=9+(legacy.FurnitureLimit or 0),
        plots={starter={x=0,z=0,w=32,d=40}},buildings=buildings,spawn={x=16,z=22},reserved={{x=0,z=20,w=32,d=4}}})
    local function convert(b:any):any
        return {kind=b.kind,x=b.x*4+52,z=b.z*4+20,rotation=(2-b.rotation)%4}
    end
    return function(data:any,kind:string,x:number,z:number,rotation:number,ignore:string?,preserveLegacyRoutes:boolean?):(boolean,string)
        local existing={};for id,b in pairs(data.expansion.buildings) do existing[id]=b end
        for id,b in pairs(data.expansion.furniture or {}) do if not b.stored then existing[id]=b end end
        local hall=data.expansion.hallPosition
        if hall and not (hall.x==-2 and hall.z==-4.5 and hall.rotation==0) then existing.__hall={kind="guildHall",x=hall.x,z=hall.z,rotation=hall.rotation} end
        if kind=="guildHall" then
            if x==-2 and z==-4.5 and rotation==0 then return true,"OK" end -- permanently reserved original site
            ignore=if existing.__hall then "__hall" else nil
        end
        if ignore and not existing[ignore] then return false,"BuildingNotOwned" end
        if legacy.placement(existing,kind,x,z,rotation,ignore) then
            -- Existing saves retain their historical geometry; every new edit uses full route checks.
            if preserveLegacyRoutes then return true,"OK" end
            local function east(b:any):any return {kind=b.kind,x=b.x*4-16,z=b.z*4+20,rotation=(2-b.rotation)%4} end
            local converted={};for id,b in pairs(existing) do if b.x>=0 then converted[id]=east(b) end end
            local moving=if ignore and converted[ignore] then ignore else nil
            local ok,reason=eastPlacement.validate({starter=true},converted,east({kind=kind,x=x,z=z,rotation=rotation}),moving)
            return ok,reason
        end
        if type(x)~="number" or type(z)~="number" or type(rotation)~="number" or x~=x or z~=z or rotation~=rotation
            or not legacy.gridCoordinate(x) or not legacy.gridCoordinate(z) or rotation%1~=0 or rotation<0 or rotation>3 or x>=0 then return false,"InvalidPlacement" end
        local owned:any={access=true}
        local states=data.guildLand and data.guildLand.plots or {}
        for id in pairs(layout.Plots) do
            local state=states[id];owned[id]=state~=nil and (state.opened==true or state.status=="Buildable")
        end
        local converted={}
        for id,b in pairs(existing) do if b.x<0 then converted[id]=convert(b) end end
        local moving=if ignore and converted[ignore] then ignore else nil
        -- Moving an old building into new land excludes its old footprint automatically.
        local ok,problem=placement.validate(owned,converted,convert({kind=kind,x=x,z=z,rotation=rotation}),moving)
        return ok,problem
    end
end
