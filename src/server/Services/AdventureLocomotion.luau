--!strict
-- Grounded movement for anchored encounter actors. Never tunnels or snaps across missing ground.
local V=Vector3.new
return function(geometry:Instance):any
    local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include
    ray.FilterDescendantsInstances={geometry};ray.RespectCanCollide=true
    local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
    overlap.FilterDescendantsInstances={geometry};overlap.RespectCanCollide=true
    local function finite(n:number):boolean return n==n and math.abs(n)<1e7 end
    local function vector(p:Vector3):boolean return finite(p.X) and finite(p.Y) and finite(p.Z) end
    local function ground(p:Vector3):Vector3?
        local hit=workspace:Raycast(p+V(0,2,0),V(0,-4,0),ray)
        if not hit or hit.Normal.Y<.85 or math.abs(hit.Position.Y-p.Y)>.8 then return nil end
        local surface=hit.Position
        -- Four support points keep the collision footprint off cliff edges and small gaps.
        for _,offset in ipairs({V(-1,0,0),V(1,0,0),V(0,0,-1),V(0,0,1)}) do
            local support=workspace:Raycast(surface+offset+V(0,1,0),V(0,-2,0),ray)
            if not support or support.Normal.Y<.85 or math.abs(support.Position.Y-surface.Y)>.8 then return nil end
        end
        for _,obstacle in ipairs(workspace:GetPartBoundsInBox(CFrame.new(surface+V(0,3,0)),V(2,4,2),overlap)) do
            -- Wedge bounding boxes contain empty air; the exact swept shape below checks ramps.
            if not obstacle:IsA("WedgePart") then return nil end
        end
        return surface
    end
    local S={}
    function S.advance(position:Vector3,goal:Vector3,speed:number,dt:number):(Vector3,boolean)
        if not vector(position) or not vector(goal) or not finite(speed) or speed<=0 or speed>40 or not finite(dt) or dt<=0 then return position,false end
        local delta=V(goal.X-position.X,0,goal.Z-position.Z)
        if delta.Magnitude<.001 then return position,true end
        local length=math.min(delta.Magnitude,speed*math.min(dt,.25))
        local steps=math.max(1,math.ceil(length/.4));local increment=delta.Unit*(length/steps)
        local result=position
        for _=1,steps do
            local nextPosition=ground(result+increment)
            if not nextPosition then return result,false end
            local direction=nextPosition-result
            -- A swept volume catches thin walls even when neither endpoint overlaps them.
            if direction.Magnitude>.001 and workspace:Blockcast(CFrame.new(result+V(0,3,0)),V(2,4,2),direction,ray) then return result,false end
            result=nextPosition
        end
        return result,true
    end
    return S
end
