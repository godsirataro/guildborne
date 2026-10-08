--!strict
-- Local character only; distance cadence avoids idle, airborne and teleport bursts.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Audio=require(script.Parent.AudioController)
local Router=require(script.Parent.Parent.UI.MenuRouter)
return function()
    local character:Model?=nil
    local previous:Vector3?=nil
    local distance=0
    return RunService.Heartbeat:Connect(function()
        local current=Players.LocalPlayer.Character
        if current~=character then character=current;previous=nil;distance=0 end
        local root=current and current:FindFirstChild("HumanoidRootPart")
        local humanoid=current and current:FindFirstChildWhichIsA("Humanoid")
        if not root or not root:IsA("BasePart") or not humanoid then previous=nil;distance=0;return end
        local position=root.Position;local delta=if previous then (position-previous).Magnitude else 0;previous=position
        local floor=humanoid.FloorMaterial
        if Router.isBlocking() or humanoid.Health<=0 or humanoid.Sit or humanoid.MoveDirection.Magnitude<.1
            or humanoid:GetState()~=Enum.HumanoidStateType.Running or delta>8
            or (floor~=Enum.Material.Grass and floor~=Enum.Material.LeafyGrass) then distance=0;return end
        distance+=delta
        if distance>=3.5 then distance%=3.5;Audio.Play("grass_step",position) end
    end)
end
