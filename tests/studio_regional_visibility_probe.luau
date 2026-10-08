--!strict
-- Run on the actual client after ClientBootstrap. Cosmetic fixture only.
return function():any
    assert(game.PlaceId==0 and game.GameId==0 and game:GetService("RunService"):IsClient())
    local fixture=Instance.new("Folder");fixture.Name="RegionalVisibilityReview";fixture.Parent=workspace
    local function scene(owner:number):Model
        local m=Instance.new("Model");m:SetAttribute("AdventureSceneOwner",owner)
        local p=Instance.new("Part");p.Name="Body";p.Anchored=true;p.CanCollide=false;p.Position=Vector3.new(27000,100,0);p.Transparency=.2;p.Parent=m
        m.Parent=fixture;return m
    end
    local ok,result=pcall(function():any
        local own=scene(game.Players.LocalPlayer.UserId);local foreign=scene(game.Players.LocalPlayer.UserId+1)
        local ownBody=own:FindFirstChild("Body") :: BasePart;local foreignBody=foreign:FindFirstChild("Body") :: BasePart
        task.wait(.1)
        assert(ownBody.LocalTransparencyModifier==0)
        assert(foreignBody.LocalTransparencyModifier==1)
        assert(math.abs(foreignBody.Transparency-.2)<.00001)
        local warning=Instance.new("Part");warning.Anchored=true;warning.CanCollide=false;warning.Position=Vector3.new(27000,101,0);warning.Parent=foreign
        task.wait(.1);assert(warning.LocalTransparencyModifier==1,"Late telegraph visible to foreign owner")
        foreign.Parent=nil;foreign.Parent=fixture;task.wait(.1)
        assert(warning.LocalTransparencyModifier==1 and ownBody.LocalTransparencyModifier==0)
        return {ownVisible=true,foreignHidden=true,lateEffectsHidden=true,reparentPreserved=true,profileWrites=0}
    end)
    fixture:Destroy();assert(ok,tostring(result));return result
end
