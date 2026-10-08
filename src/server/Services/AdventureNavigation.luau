--!strict
-- Bounded asynchronous detours; every step still passes grounded collision checks.
local Pathfinding=game:GetService("PathfindingService")
local V=Vector3.new
return function(geometry:Instance):any
    local locomotion=require(script.Parent.AdventureLocomotion)(geometry)
    local states:{[any]:any}={};local alive=true;local count=0
    local S={}
    local function flat(a:Vector3,b:Vector3):number return V(a.X-b.X,0,a.Z-b.Z).Magnitude end
    function S.move(key:any,position:Vector3,goal:Vector3,speed:number,dt:number,now:number):Vector3
        if not alive or now~=now or math.abs(now)==math.huge then return position end
        local s=states[key]
        if not s then
            if count>=4 then return position end
            s={nextPlan=0,generation=0,index=2};states[key]=s;count+=1
        end
        if s.goal and flat(s.goal,goal)>6 then s.path=nil;s.generation+=1 end
        local target=goal
        if s.path then
            local waypoint=s.path[s.index]
            if waypoint and flat(position,waypoint.Position)<1 then s.index+=1;waypoint=s.path[s.index] end
            if waypoint then target=waypoint.Position else s.path=nil end
        end
        local nextPosition,clear=locomotion.advance(position,target,speed,dt)
        if clear then return nextPosition end
        s.path=nil
        if s.computing or now<s.nextPlan then return nextPosition end
        s.nextPlan=now+1.5;s.computing=true;s.goal=goal;s.generation+=1
        local generation=s.generation
        task.spawn(function()
            local path=Pathfinding:CreatePath({AgentRadius=1.2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=2})
            local ok=pcall(function()path:ComputeAsync(nextPosition+V(0,2,0),goal+V(0,2,0))end)
            if alive and states[key]==s then
                s.computing=false
                if ok and generation==s.generation and path.Status==Enum.PathStatus.Success then s.path=path:GetWaypoints();s.index=2 end
            end
        end)
        return nextPosition
    end
    function S.remove(key:any)
        if states[key] then states[key]=nil;count-=1 end
    end
    function S.destroy()alive=false;table.clear(states);count=0 end
    function S.count():number return count end
    return S
end
