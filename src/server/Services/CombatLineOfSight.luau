--!strict
-- Geometry-only queries ignore noncolliding effects and character collision groups.
return function(geometry:Instance):any
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances={geometry};params.RespectCanCollide=true;params.CollisionGroup="GuildborneHeroes"
    return function(a:any,b:any):boolean
        if not a or not b or not a.root or not b.root then return false end
        local start=a.root.Position+Vector3.new(0,1,0);local goal=b.root.Position+Vector3.new(0,1,0)
        local delta=goal-start
        if delta.Magnitude<.01 then return true end
        return workspace:Raycast(start,delta,params)==nil
    end
end
