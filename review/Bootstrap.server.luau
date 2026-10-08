--!strict
-- This script is included ONLY in art-review.project.json, never the main game build.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local world=require(script.Parent.ReviewWorld)()
local cooldown:{[Player]:number}={}
local function travel(player:Player,target:Vector3)
    local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
    if c and root and h and h.Health>0 then c:PivotTo(CFrame.new(target));root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero end
end
local function playerAdded(player:Player)
    player.RespawnLocation=world.spawn
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart");travel(player,world.spawn.Position+Vector3.new(0,4,0))
    end)
    if player.Character then travel(player,world.spawn.Position+Vector3.new(0,4,0)) end
end
Players.PlayerAdded:Connect(playerAdded);for _,player in ipairs(Players:GetPlayers()) do playerAdded(player) end
Players.PlayerRemoving:Connect(function(player) cooldown[player]=nil end)
for _,link in ipairs(world.links) do
    link.prompt.Triggered:Connect(function(player:Player)
        local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
        local h=c and c:FindFirstChildOfClass("Humanoid");local now=os.clock()
        if not root or not h or h.Health<=0 or (root.Position-link.part.Position).Magnitude>12 or now<(cooldown[player] or 0) then return end
        cooldown[player]=now+2
        if link.demo then world.StartDemo(link.demo,now) else travel(player,link.target) end
    end)
end
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
    elapsed+=dt;if elapsed<.2 then return end
    world.Step(os.clock(),math.min(elapsed,.25));elapsed=0
    for _,player in ipairs(Players:GetPlayers()) do
        local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
        if root and root.Position.Y< -15 then travel(player,world.spawn.Position+Vector3.new(0,4,0)) end
    end
end)
