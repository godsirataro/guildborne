--!strict
-- Personal encounter visuals on shared terrain; combat ownership is enforced separately by the server.
return function()
    local player=game.Players.LocalPlayer
    local function apply(instance:Instance)
        if not instance:IsA("BasePart") then return end
        local ancestor=instance.Parent
        while ancestor and ancestor~=workspace do
            local owner=ancestor:GetAttribute("AdventureSceneOwner")
            if type(owner)=="number" then instance.LocalTransparencyModifier=if owner==player.UserId then 0 else 1;return end
            ancestor=ancestor.Parent
        end
    end
    for _,instance in ipairs(workspace:GetDescendants()) do apply(instance) end
    workspace.DescendantAdded:Connect(apply)
end
