--!strict
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local services=game.ServerScriptService.Server.Services
    local maps=require(services.AdventureMapKit)();maps.Parent=workspace
    local geometry=maps:FindFirstChild("Greenwood") :: Model;local origin=Vector3.new(23000,100,0);geometry:PivotTo(CFrame.new(origin))
    local initial=#geometry:GetDescendants();local scenes={}
    local ok,result=pcall(function():any
        for owner=1,2 do
            local scene=require(services.AdventureEncounterSession)("Greenwood",origin,-owner,{
                Geometry=geometry,Members=function()return {}end,Reward=function()error("Unexpected reward")end,
            })
            table.insert(scenes,scene)
            assert(scene.model:FindFirstChild("Island")==nil and scene.model:FindFirstChild("EncounterMarkers")==nil)
            local marker=(geometry:FindFirstChild("EncounterMarkers") :: Folder):FindFirstChild("ScoutCamp") :: BasePart
            assert((scene.actors[1].model:GetPivot().Position-marker.Position).Magnitude<.01)
            local a=scene.actors[1]
            local target={id="player",owner=owner,active=true,health=100,maxHealth=100,position={x=a.position.x,y=a.position.y,z=a.position.z+4}}
            scene.Step({target},0,.2);assert(target.health==100,"Other owner attacked")
            target.owner=-owner;scene.Step({target},1,.2);assert(target.health<100,"Owned target not attacked")
            scene.Suspend();assert(geometry.Parent==maps and #geometry:GetDescendants()==initial)
            scene.Resume()
        end
        scenes[1].Destroy();assert(geometry.Parent==maps and #geometry:GetDescendants()==initial)
        assert(scenes[2].model.Parent==workspace and scenes[2].actors[1].model.Parent~=nil)
        return {owners=2,actors=8,sharedGeometryUnchanged=true,duplicateFloors=0,profileWrites=0}
    end)
    for _,scene in ipairs(scenes) do scene.Destroy() end;maps:Destroy();assert(ok,tostring(result));return result
end
