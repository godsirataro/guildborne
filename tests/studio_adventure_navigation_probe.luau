--!strict
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local model=Instance.new("Model");model.Name="NavigationReview";model.Parent=workspace
    local origin=Vector3.new(17000,100,0)
    local function part(name:string,size:Vector3,position:Vector3)
        local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=position;p.Anchored=true;p.Parent=model
    end
    part("Floor",Vector3.new(50,2,50),origin-Vector3.yAxis)
    part("Wall",Vector3.new(2,9,16),origin+Vector3.new(0,4.5,0))
    local navigation=require(game.ServerScriptService.Server.Services.AdventureNavigation)(model)
    local ok,result=pcall(function():any
        local position=origin+Vector3.new(-12,0,0);local goal=origin+Vector3.new(12,0,0)
        local maximumZ=0;local ticks=0
        repeat
            local previous=position;position=navigation.move("actor",position,goal,12,.2,ticks*.2)
            assert((position-previous).Magnitude<=2.5,"Navigation teleported")
            assert(math.abs(position.Y-origin.Y)<.01,"Navigation left ground")
            assert(not (math.abs(position.X-origin.X)<2 and math.abs(position.Z-origin.Z)<9),"Navigation crossed wall")
            maximumZ=math.max(maximumZ,math.abs(position.Z-origin.Z));ticks+=1;task.wait(.03)
        until (position-goal).Magnitude<.1 or ticks>=200
        assert((position-goal).Magnitude<.1,"No detour reached goal")
        assert(maximumZ>9,"Detour did not clear wall")
        for index=2,4 do navigation.move(index,origin+Vector3.new(-12,0,0),goal,12,.2,100) end
        assert(navigation.count()==4)
        local denied=origin+Vector3.new(-12,0,0)
        assert(navigation.move("fifth",denied,goal,12,.2,100)==denied and navigation.count()==4)
        navigation.remove(2);assert(navigation.count()==3)
        navigation.move("replacement",denied,goal,12,.2,101);assert(navigation.count()==4)
        navigation.destroy();navigation.destroy();task.wait(.1)
        assert(navigation.count()==0 and navigation.move("actor",denied,goal,12,.2,200)==denied)
        return {ticks=ticks,detourWidth=maximumZ,goalReached=true,actorBound=4,profileWrites=0}
    end)
    navigation.destroy();model:Destroy();assert(ok,tostring(result));return result
end
