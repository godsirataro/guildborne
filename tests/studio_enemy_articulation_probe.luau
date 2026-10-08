--!strict
-- Isolated server models; no combat loop, Players or profile writes.
return function()
    local services=game.ServerScriptService.Server.Services
    local templates=require(services.ArtKit).Build()
    local factory=require(services.EnemyService)(templates)
    local folder=Instance.new("Folder");folder.Name="EnemyArticulationFixture";folder.Parent=workspace
    local ok,result=pcall(function()
        local count,joints,welds=0,0,0
        for i,floor in ipairs({0,1,2,5}) do
            local origin=Vector3.new(i*100,30,3000)
            local actors=factory.create(folder,origin,-999,if floor==0 then nil else floor)
            for _,actor in ipairs(actors) do
                local m=actor.model;local root=m.PrimaryPart;local motors,anchors=0,0
                local before=#m:GetDescendants();require(services.EnemyArticulation)(m,floor==0);assert(#m:GetDescendants()==before,"Not idempotent")
                for _,v in ipairs(m:GetDescendants()) do
                    if v:IsA("Motor6D") then motors+=1;assert(v.Part0 and v.Part1)
                    elseif v:IsA("WeldConstraint") and v.Name=="EnemyArtWeld" then welds+=1;assert(v.Part0 and v.Part1)
                    elseif v:IsA("BasePart") then
                        assert(not v.CanCollide and not v.CanQuery and not v.CanTouch)
                        if v.Anchored then anchors+=1;assert(v==root) end
                        if v.Transparency<1 then
                            assert(v:FindFirstChild("EnemyArtWeld"));assert(v:GetAttribute("EnemyLimb"))
                            local p=root.CFrame:PointToObjectSpace(v.Position)
                            if v.Name=="Eye" then assert(p.Z<0,"Enemy faces backwards") end
                        end
                    end
                end
                assert(motors==6 and anchors==1);joints+=motors;count+=1
                local at=root.CFrame;task.wait(.1);assert((root.Position-at.Position).Magnitude<.001,"Root drift")
                local _,size=m:GetBoundingBox();assert(size.Y<10,"Exploded rig")
                local lowest=math.huge
                for _,v in ipairs(m:GetDescendants()) do if v:IsA("BasePart") and (v.Name=="Boot") then lowest=math.min(lowest,v.Position.Y-v.Size.Y/2) end end
                assert(lowest>=origin.Y-.05,"Boots below ground")
                assert(lowest<=origin.Y+.1,"Boots floating")
                actor.plot=folder;actor.health=0;factory.reset(actor);assert(actor.health==actor.stats.MaxHealth)
                assert(actor.root.Position==actor.home)
            end
        end
        return {actors=count,joints=joints,artWelds=welds,idempotent=true,oneAnchoredRoot=true,forwardFaces=true,groundedBoots=true,noRootDrift=true,respawnPassed=true}
    end)
    folder:Destroy();templates:Destroy();assert(ok,tostring(result));return result
end
