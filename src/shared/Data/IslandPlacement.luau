--!strict
-- Bounded fine-grid validator. Coordinates are cells, translated to studs by callers.
-- A path is required from the portal to every entrance after each proposed edit.
return function(config: any)
    local function int(n: any,low: number,high: number): boolean
        return type(n)=="number" and n==n and n%1==0 and n>=low and n<=high
    end
    local width,height=config.width,config.height
    assert(int(width,1,128) and int(height,1,128),"Island grid exceeds bounded search")
    local clearance=config.clearance or 0;assert(int(clearance,0,4),"Invalid walk clearance")
    local function inside(x: number,z: number): boolean return x>=0 and x<width and z>=0 and z<height end
    local function key(x: number,z: number): number return z*width+x+1 end
    local function rect(r: any): boolean
        return type(r)=="table" and int(r.x,0,width-1) and int(r.z,0,height-1) and int(r.w,1,width) and int(r.d,1,height) and r.x+r.w<=width and r.z+r.d<=height
    end
    assert(type(config.plots)=="table" and type(config.buildings)=="table" and type(config.reserved)=="table")
    assert(int(config.spawn.x,0,width-1) and int(config.spawn.z,0,height-1))
    for _,r in pairs(config.plots) do assert(rect(r),"Invalid plot bounds") end
    for _,r in ipairs(config.reserved) do assert(rect(r),"Invalid reserved bounds") end
    for _,b in pairs(config.buildings) do assert(int(b.w,1,width) and int(b.d,1,height),"Invalid footprint") end
    local maxBuildings=config.maxBuildings or 128;assert(int(maxBuildings,1,256))
    local P={}
    local neighbors={{-1,0},{1,0},{0,-1},{0,1}}
    function P.validate(owned: any,buildings: any,candidate: any,ignore: string?): (boolean,string,any?)
        if type(owned)~="table" or type(buildings)~="table" or type(candidate)~="table" then return false,"InvalidPlacement",nil end
        if ignore and not buildings[ignore] then return false,"BuildingNotOwned",nil end
        local ground={};local reserved={};local blocked={};local targets={}
        for id,r in pairs(config.plots) do if owned[id]==true then
            for z=r.z,r.z+r.d-1 do for x=r.x,r.x+r.w-1 do ground[key(x,z)]=true end end
        end end
        for _,r in ipairs(config.reserved) do for z=r.z,r.z+r.d-1 do for x=r.x,r.x+r.w-1 do reserved[key(x,z)]=true end end end
        local function insert(b: any): string?
            if type(b)~="table" or not int(b.x,0,width-1) or not int(b.z,0,height-1) or not int(b.rotation,0,3) then return "InvalidPlacement" end
            local def=config.buildings[b.kind];if not def then return "InvalidBuilding" end
            local w,d=def.w,def.d;if b.rotation%2==1 then w,d=d,w end
            if b.x+w>width or b.z+d>height then return "OutsideIsland" end
            for z=b.z,b.z+d-1 do for x=b.x,b.x+w-1 do
                local k=key(x,z)
                if not ground[k] then return "PlotLocked" end
                if reserved[k] then return "ReservedAccess" end
                if blocked[k] then return "BuildingOverlap" end
                blocked[k]=true
            end end
            if def.noEntrance then return nil end
            -- Entrance faces north, east, south or west after clockwise rotation.
            local x,z=b.x+math.floor(w/2),b.z-1-clearance
            if b.rotation==1 then x,z=b.x+w+clearance,b.z+math.floor(d/2)
            elseif b.rotation==2 then x,z=b.x+math.floor(w/2),b.z+d+clearance
            elseif b.rotation==3 then x,z=b.x-1-clearance,b.z+math.floor(d/2) end
            if not inside(x,z) or not ground[key(x,z)] then return "EntranceBlocked" end
            table.insert(targets,key(x,z));return nil
        end
        local count=0
        for id,b in pairs(buildings) do
            count+=1;if count>maxBuildings then return false,"BuildingLimit",nil end
            if id~=ignore then local problem=insert(b);if problem then return false,problem,nil end end
        end
        if not ignore and count>=maxBuildings then return false,"BuildingLimit",nil end
        local problem=insert(candidate);if problem then return false,problem,nil end
        local start=key(config.spawn.x,config.spawn.z)
        local walkable={}
        for z=0,height-1 do for x=0,width-1 do
            local free=true
            for dz=-clearance,clearance do for dx=-clearance,clearance do
                if not inside(x+dx,z+dz) or not ground[key(x+dx,z+dz)] or blocked[key(x+dx,z+dz)] then free=false;break end
            end;if not free then break end end
            if free then walkable[key(x,z)]=true end
        end end
        if not walkable[start] then return false,"PortalBlocked",nil end
        local visited={[start]=true};local queue={start};local cursor=1
        while cursor<=#queue do
            local current=queue[cursor];cursor+=1
            local z=math.floor((current-1)/width);local x=(current-1)%width
            for _,offset in ipairs(neighbors) do
                local nx,nz=x+offset[1],z+offset[2]
                if inside(nx,nz) then local k=key(nx,nz)
                    if walkable[k] and not visited[k] then visited[k]=true;table.insert(queue,k) end
                end
            end
        end
        for _,target in ipairs(targets) do if not visited[target] then return false,"AccessBlocked",nil end end
        return true,"OK",{reachableCells=#queue,buildings=if ignore then count else count+1}
    end
    return P
end
