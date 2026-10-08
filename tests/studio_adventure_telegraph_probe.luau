--!strict
return function():any
    local draw=require(game.ReplicatedStorage.Shared.Data.AdventureTelegraph)
    local parent=Instance.new("Folder");local report={}
    local ok,result=pcall(function():any
        for _,entry in ipairs({{shape="Circle",count=32},{shape="Ring",count=64},{shape="Line",count=4},{shape="Cone",count=26}}) do
            local folder=draw(parent,{name="Review",shape=entry.shape,x=10,y=3,z=-5,dx=1,dz=0,radius=10,innerRadius=4,width=5,length=20,halfAngle=55})
            assert(#folder:GetChildren()==entry.count)
            for _,p in ipairs(folder:GetChildren()) do
                assert(p:IsA("BasePart"));assert(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery and not p.CastShadow)
                assert(math.abs(p.Position.Y-3.09)<.001)
            end
            table.insert(report,{shape=entry.shape,parts=#folder:GetChildren()});folder:Destroy()
        end
        assert(#parent:GetChildren()==0);return report
    end)
    parent:Destroy();assert(ok,tostring(result));return result
end
