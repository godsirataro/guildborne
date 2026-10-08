--!strict
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local services=game.ServerScriptService.Server.Services
    local maps=require(services.AdventureMapKit)();maps.Name="LocomotionReview";maps.Parent=workspace
    local checks=0;local traversed=0
    local function check(ok:boolean,message:string?)assert(ok,message or ("Locomotion "..checks));checks+=1 end
    local ok,result=pcall(function():any
        for index,region in ipairs(maps:GetChildren()) do
            local model=region :: Model;local offset=Vector3.new(12000+index*350,100,0);model:PivotTo(CFrame.new(offset))
            local move=require(services.AdventureLocomotion)(model)
            local routes=model:FindFirstChild("ReviewRoutes") :: Folder
            for _,route in ipairs(routes:GetChildren()) do
                local points=route:GetChildren();table.sort(points,function(a,b)return tonumber(a.Name)<tonumber(b.Name)end)
                for _,reverse in ipairs({false,true}) do
                    local ordered=table.clone(points);if reverse then for i=1,math.floor(#ordered/2) do ordered[i],ordered[#ordered-i+1]=ordered[#ordered-i+1],ordered[i] end end
                    local position=(ordered[1] :: Vector3Value).Value+offset
                    for i=2,#ordered do
                        local goal=(ordered[i] :: Vector3Value).Value+offset;local steps=0
                        while (Vector3.new(position.X,0,position.Z)-Vector3.new(goal.X,0,goal.Z)).Magnitude>.05 do
                            local nextPosition,complete=move.advance(position,goal,12,.2)
                            check(complete,model.Name.." "..route.Name.." blocked at "..tostring(position))
                            check((nextPosition-position).Magnitude<=2.6)
                            position=nextPosition;steps+=1;assert(steps<250)
                        end
                        check(math.abs(position.Y-goal.Y)<.15)
                    end
                    traversed+=1
                end
            end
        end
        local fixture=Instance.new("Model");fixture.Name="CollisionFixture";fixture.Parent=maps
        local function part(size:Vector3,pos:Vector3):Part
            local p=Instance.new("Part");p.Size=size;p.Position=pos;p.Anchored=true;p.Parent=fixture;return p
        end
        local base=Vector3.new(15000,100,0)
        part(Vector3.new(30,2,30),base-Vector3.yAxis)
        local wall=part(Vector3.new(.1,8,12),base+Vector3.new(3,4,0));wall.CanQuery=false
        local move=require(services.AdventureLocomotion)(fixture)
        local blocked,complete=move.advance(base,base+Vector3.new(10,0,0),40,.25)
        check(not complete and blocked.X<base.X+2,"Thin nonquery wall must block")
        wall.CanCollide=false
        local open,passed=move.advance(base,base+Vector3.new(10,0,0),40,.25)
        check(passed and math.abs(open.X-base.X-10)<.01,"Noncolliding art must not block")
        local edge,edgePass=move.advance(base+Vector3.new(13,0,0),base+Vector3.new(25,0,0),40,.25)
        check(not edgePass and edge.X<=base.X+14.01,"No cliff walk")
        for _,dt in ipairs({0,-1,0/0,math.huge}) do local p,valid=move.advance(base,base+Vector3.xAxis,12,dt);check(not valid and p==base) end
        local p,valid=move.advance(base,base+Vector3.xAxis,math.huge,.2);check(not valid and p==base)
        return {checks=checks,routes=traversed,profileWrites=0}
    end)
    maps:Destroy();assert(ok,tostring(result));return result
end
