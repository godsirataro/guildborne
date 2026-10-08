--!strict
return function(): any
	local folder=Instance.new("Folder");folder.Name="UATWardrobeFixture";folder.Parent=game.ServerStorage
	local ok,result=xpcall(function()
		local outfit=require(game.ServerScriptService.Server.Services.WardrobeVisuals)
		local rigs={"R6","R15"};local cases,parts=0,0
		for _,kind in ipairs(rigs) do
			local m=Instance.new("Model");m.Parent=folder
			local torso=Instance.new("Part");torso.Name=if kind=="R6" then "Torso" else "UpperTorso";torso.Size=Vector3.new(2,if kind=="R6" then 2 else 1.6,1);torso.CFrame=CFrame.new(10,5,20)*CFrame.Angles(.2,.7,.1);torso.Anchored=true;torso.Parent=m
			for _,side in ipairs({"Left","Right"}) do local arm=torso:Clone();arm.Name=side..(if kind=="R6" then " Arm" else "UpperArm");arm.Size=Vector3.new(.7,1.8,.8);arm.CFrame=torso.CFrame*CFrame.new(if side=="Left" then -1.4 else 1.4,0,0);arm.Parent=m end
			if kind=="R15" then local hand=Instance.new("Part");hand.Name="RightHand";hand.Size=Vector3.new(.6,.5,.7);hand.CFrame=torso.CFrame*CFrame.new(1.4,-1,0);hand.Anchored=true;hand.Parent=m end
			for _,slot in ipairs({"Armor","Accessory"}) do
				local ids=if slot=="Armor" then {"leather_vest","guardian_plate","woven_robes","scout_coat","runewoven_mantle","harbor_mail","vanguard_harness","pilgrim_robes"} else {"bronze_ring","vitality_charm","sentinel_seal","hunters_token","focus_prism","wardstone"}
				for _,id in ipairs(ids) do
					outfit(m,if slot=="Armor" then id else nil,if slot=="Accessory" then id else nil)
					local gear=m:FindFirstChild("Equipped"..slot);assert(gear and gear:IsA("Model"));assert(m:GetAttribute(slot.."Id")==id)
					for _,part in ipairs(gear:GetChildren()) do
						assert(part:IsA("BasePart"));assert(not part.Anchored and part.Massless and not part.CanCollide and not part.CanTouch and not part.CanQuery)
						local w=part:FindFirstChildOfClass("WeldConstraint");assert(w and w.Part1==part and w.Part0 and w.Part0.Parent==m)
						if part.Name=="Shoulder" then assert(w.Part0.Name~=torso.Name,"Shoulder must follow its arm") end
						if id=="bronze_ring" then assert(w.Part0.Name==(if kind=="R6" then "Right Arm" else "RightHand")) end
						parts+=1
					end
					outfit(m,if slot=="Armor" then id else nil,if slot=="Accessory" then id else nil);assert(m:FindFirstChild("Equipped"..slot)==gear,"Unchanged gear rebuilt")
					gear:Destroy();outfit(m,if slot=="Armor" then id else nil,if slot=="Accessory" then id else nil);assert(m:FindFirstChild("Equipped"..slot),"Missing geometry not repaired")
					cases+=1
				end
			end
			outfit(m,nil,nil);assert(not m:FindFirstChild("EquippedArmor") and not m:FindFirstChild("EquippedAccessory"))
		end
		return {outfitCases=cases,weldedParts=parts,shouldersFollowArms=true,ringsFollowHands=true,reusesUnchanged=true,repairsMissingVisual=true,unequipCleanup=true,noProfileWrites=true}
	end,debug.traceback)
	folder:Destroy();assert(ok,result);return result
end
