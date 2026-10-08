--!strict
local Patterns=require(script.Parent.Parent.Systems.AdventurePatterns)
local Choose=require(script.Parent.Parent.Systems.AdventureEvasion)(Patterns)
local City=require(game.ReplicatedStorage.Shared.Config.City)
local Move=require(script.Parent.AdventureLocomotion)
local V=Vector3.new
return function(geometry:Model,region:string):any
    local ground=Move(geometry)
    local function reachable(from:any,to:any):any
        if not City.regionCombat(region,to.x,to.y+3,to.z) then return nil end
        local current=V(from.x,from.y,from.z);local goal=V(to.x,to.y,to.z)
        -- Query only: sample the whole straight escape corridor before requesting a walk.
        for _=1,2 do
            local nextPosition,clear=ground.advance(current,goal,40,.25)
            if not clear then return nil end
            current=nextPosition
            if (V(current.X,0,current.Z)-V(goal.X,0,goal.Z)).Magnitude<.1 then
                return {x=current.X,y=current.Y,z=current.Z}
            end
        end
        return nil
    end
    return function(actor:any,enemies:{any},now:number):Vector3?
        local hazards={}
        for _,enemy in ipairs(enemies) do
            if enemy.active and enemy.health>0 and enemy.owner==actor.owner and enemy.pendingPattern then
                table.insert(hazards,{id=enemy.id,pattern=enemy.pendingPattern})
            end
        end
        local p=actor.root.Position-V(0,3,0)
        actor.evasion=Choose({x=p.X,y=p.Y,z=p.Z},hazards,now,actor.evasion,reachable)
        local target=actor.evasion and actor.evasion.position
        return if target then V(target.x,target.y+3,target.z) else nil
    end
end
