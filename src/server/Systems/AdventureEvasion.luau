--!strict
-- Bounded, deterministic escape selection. Reachability is supplied by server geometry.
return function(patterns:any)
    return function(position:any,hazards:{any},now:number,previous:any,reachable:any):any
        local active={};local stamp={};local deadline=now
        for _,hazard in ipairs(hazards) do
            local p=hazard.pattern
            if p and now<=p.due then table.insert(active,p);table.insert(stamp,hazard.id..":"..tostring(p.due));deadline=math.max(deadline,p.due) end
        end
        if #active==0 then return nil end
        local key=table.concat(stamp,"|")
        local function safe(p:any):boolean
            for _,pattern in ipairs(active) do
                for _,offset in ipairs({{0,0},{1.25,0},{-1.25,0},{0,1.25},{0,-1.25}}) do
                    if patterns.contains(pattern,{x=p.x+offset[1],y=p.y,z=p.z+offset[2]}) then return false end
                end
            end
            return true
        end
        if previous and previous.stamp==key and safe(previous.position) then return previous end
        if safe(position) then return nil end
        -- Closest valid exit first. No random jitter, teleport or immunity.
        for _,radius in ipairs({3,6,9,12,16}) do
            for index=0,7 do
                local angle=index*math.pi/4
                local target={x=position.x+math.cos(angle)*radius,y=position.y,z=position.z+math.sin(angle)*radius}
                if not safe(target) then continue end
                local adjusted=reachable(position,target)
                if adjusted and safe(adjusted) then return {position=adjusted,stamp=key,untilTime=deadline} end
            end
        end
        return nil
    end
end
