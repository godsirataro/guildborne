--!strict
local build=require(game.ReplicatedStorage.Shared.Data.ItemVisuals)
return function(model: Model,armor: string?,accessory: string?)
	local torso=(model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")) :: BasePart?
	if not torso then return end
	for _,entry in ipairs({{slot="Armor",id=armor},{slot="Accessory",id=accessory}}) do
		local key=entry.slot.."Id";local name="Equipped"..entry.slot;local old=model:FindFirstChild(name)
		if model:GetAttribute(key)==entry.id and (not entry.id or old) then continue end
		if old then old:Destroy() end;model:SetAttribute(key,entry.id)
		if not entry.id then continue end
		local gear=build(entry.id);if not gear then continue end
		gear.Name=name;local target=torso;local transform: CFrame
		if entry.slot=="Armor" then
			gear:ScaleTo(torso.Size.X/2)
			transform=torso.CFrame*CFrame.new(0,0,-torso.Size.Z/2-.12)
		elseif entry.id=="bronze_ring" then
			target=(model:FindFirstChild("RightHand") or model:FindFirstChild("Right Arm") or torso) :: BasePart
			gear:ScaleTo(math.max(target.Size.X,target.Size.Z)*.75)
			transform=target.CFrame*CFrame.new(0,-target.Size.Y*.35,0)*CFrame.Angles(-math.pi/2,0,0)
		else
			gear:ScaleTo(.32*torso.Size.X/2)
			transform=torso.CFrame*CFrame.new(0,torso.Size.Y*.22,-torso.Size.Z/2-.26)
		end
		gear:PivotTo(transform)
		for _,part in ipairs(gear:GetChildren()) do
			if not part:IsA("BasePart") then continue end
			local anchor=target
			if entry.slot=="Armor" and part.Name=="Shoulder" then
				local left=torso.CFrame:PointToObjectSpace(part.Position).X<0
				anchor=(model:FindFirstChild(if left then "LeftUpperArm" else "RightUpperArm") or model:FindFirstChild(if left then "Left Arm" else "Right Arm") or torso) :: BasePart
			end
			part.Anchored=false;part.Massless=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
			part.CollisionGroup="GuildborneHeroes";part.CastShadow=true
			local weld=Instance.new("WeldConstraint");weld.Part0=anchor;weld.Part1=part;weld.Parent=part
		end
		gear.Parent=model
	end
end
