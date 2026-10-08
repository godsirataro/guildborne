--!strict
-- Uses a blank Roblox description, never a player's avatar or inventory.
return function(): any
	local description=Instance.new("HumanoidDescription")
	local model=game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
	description:Destroy();model.Name="UATNeutralR15";model.Parent=game.ServerStorage
	local ok,result=xpcall(function()
		local humanoid=model:FindFirstChildOfClass("Humanoid");assert(humanoid and humanoid.RigType==Enum.HumanoidRigType.R15);humanoid.EvaluateStateMachine=false
		local wardrobe=require(game.ServerScriptService.Server.Services.WardrobeVisuals)
		local torso=model:FindFirstChild("UpperTorso");assert(torso and torso:IsA("BasePart"))
		local cases=0
		for _,id in ipairs({"leather_vest","guardian_plate","woven_robes","scout_coat","runewoven_mantle","harbor_mail","vanguard_harness","pilgrim_robes"}) do
			wardrobe(model,id,"bronze_ring")
			local armor=model:FindFirstChild("EquippedArmor");local ring=model:FindFirstChild("EquippedAccessory");assert(armor and ring)
			for _,part in ipairs(armor:GetChildren()) do
				assert(part:IsA("BasePart"));local weld=part:FindFirstChildOfClass("WeldConstraint");assert(weld and weld.Part0)
				assert((part.Position-torso.Position).Magnitude<4,"Outfit detached from body")
				if part.Name=="Shoulder" then assert(weld.Part0.Name=="LeftUpperArm" or weld.Part0.Name=="RightUpperArm") end
			end
			for _,part in ipairs(ring:GetChildren()) do local weld=part:FindFirstChildOfClass("WeldConstraint");assert(weld and weld.Part0 and weld.Part0.Name=="RightHand") end
			cases+=1
		end
		return {standardR15=true,armorCases=cases,blankDescription=true,detachmentCheck=true,upperArmAnchors=true,handAnchor=true,noPlayerAvatarMutation=true}
	end,debug.traceback)
	model:Destroy();assert(ok,result);return result
end
