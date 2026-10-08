--!strict
-- Synthetic rigs only, no inventory/profile mutation.
return function(): any
	local folder=Instance.new("Folder");folder.Name="UATWeaponGripFixture";folder.Parent=game.ServerStorage
	local ok,result=xpcall(function()
		local rig=require(game.ServerScriptService.Server.Services.HeroRig)
		local kit=require(game.ServerScriptService.Server.Services.ArtKit).Build();kit.Parent=folder
		local count,parts=0,0
		for _,limb in ipairs({"Right Arm","RightHand"}) do
			local model=Instance.new("Model");model.Parent=folder
			local arm=Instance.new("Part");arm.Name=limb;arm.Size=Vector3.new(.8,if limb=="RightHand" then .5 else 2,.8)
			arm.CFrame=CFrame.new(50,10,40)*CFrame.Angles(.3,.7,.1);arm.Anchored=true;arm.Parent=model
			for _,id in ipairs({"training_sword","short_bow","apprentice_staff","iron_sword","knight_sword","mage_staff","watchblade","oathblade","yew_longbow","tide_staff","dawn_crozier"}) do
				local old=model:FindFirstChild("EquippedWeapon");rig.Equip(model,id,kit)
				if old then assert(old.Parent==nil,"Replacement leaked") end
				local gear=model:FindFirstChild("EquippedWeapon") :: Model;assert(gear and gear.PrimaryPart)
				local relative=arm.CFrame:ToObjectSpace(gear.PrimaryPart.CFrame)
				assert((relative.Position-Vector3.new(0,-arm.Size.Y*.35,-.3)).Magnitude<.0001,id.." grip")
				assert(relative.LookVector:Dot(Vector3.new(0,0,-1))>.99999,id.." rotation")
				for _,p in ipairs(gear:GetChildren()) do
					if p:IsA("BasePart") then
						assert(not p.Anchored and p.Massless and not p.CanCollide and not p.CanTouch and not p.CanQuery,id)
						local weld=p:FindFirstChildOfClass("WeldConstraint");assert(weld and weld.Part0==arm and weld.Part1==p,id.." weld")
						parts+=1
					end
				end
				count+=1
			end
			rig.Equip(model,nil,kit);assert(not model:FindFirstChild("EquippedWeapon") and model:GetAttribute("WeaponId")==nil)
			arm:Destroy();rig.Equip(model,"watchblade",kit);assert(not model:FindFirstChild("EquippedWeapon"))
		end
		return {equipCases=count,weldedParts=parts,r6AndR15=true,gripAlignment=true,replacementCleanup=true,unequipCleanup=true,noProfileWrites=true}
	end,debug.traceback)
	folder:Destroy();assert(ok,result);return result
end
