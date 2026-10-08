--!strict
return function():any
    assert(game.PlaceId==0 and game.GameId==0 and game:GetService("RunService"):IsClient())
    local fixture=workspace:WaitForChild("RigMotionReview",5) :: Model;assert(fixture)
    local camera=workspace.CurrentCamera :: Camera;local previous=camera.CFrame;local kind=camera.CameraType
    local ok,result=pcall(function():any
        camera.CameraType=Enum.CameraType.Scriptable
        camera.CFrame=CFrame.lookAt(Vector3.new(30970,112,40),Vector3.new(30970,104,10))
        task.wait(.3)
        local reports={};local actors=fixture:FindFirstChild("EncounterArt") :: Folder
        for _,id in ipairs({"greenwood_scout","greenwood_boar"}) do
            local model=actors:FindFirstChild(id) :: Model;local root=model.PrimaryPart :: BasePart
            local joints=model:FindFirstChild("EnemyJoints") :: Folder;local joint=joints:FindFirstChild("Left Shoulder") :: Motor6D
            local position=root.Position;local before=joint.Transform;task.wait(.2);local after=joint.Transform
            assert(before~=after and after~=CFrame.identity,"Regional rig did not animate: "..id)
            assert(root.Position:FuzzyEq(position,.001),"Cosmetic animation moved authoritative root")
            table.insert(reports,{id=id,animated=true,rootUnchanged=true})
        end
        return {actors=reports,profileWrites=0,realClientAnimator=true}
    end)
    camera.CameraType=kind;camera.CFrame=previous;assert(ok,tostring(result));return result
end
