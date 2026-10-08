--!strict
return function(): any
	local player=game.Players.LocalPlayer
	local folder=Instance.new("ScreenGui");folder.Name="UATItemViewportFixture";folder.Enabled=false;folder.Parent=player.PlayerGui
	local ok,result=xpcall(function()
		local build=require(game.ReplicatedStorage.Shared.Data.ItemVisuals)
		local assets=require(game.ReplicatedStorage.Shared.Config.VisualAssets)
		local item=require(player.PlayerScripts.Client.UI.AssetImage)
		local count,parts=0,0
		for _,ids in ipairs({assets.ItemOrder,assets.EquipmentOrder}) do for _,id in ipairs(ids) do
			local holder=item.item(folder,id);assert(holder,id)
			local view=holder:FindFirstChildOfClass("ViewportFrame");assert(view and view.CurrentCamera and view.Visible,id)
			local world=view:FindFirstChildOfClass("WorldModel");assert(world)
			local model=world:FindFirstChildOfClass("Model");assert(model)
			local camera=view.CurrentCamera;local limit=math.tan(math.rad(camera.FieldOfView/2))
			local n=0
			for _,p in ipairs(model:GetChildren()) do
				assert(p:IsA("BasePart"));assert(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery)
				for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
					local point=camera.CFrame:PointToObjectSpace(p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2))
					assert(point.Z<0 and math.abs(point.X/-point.Z)<limit and math.abs(point.Y/-point.Z)<limit,id.." clipped")
				end end end
				n+=1
			end
			assert(n<=16 and n>0);parts+=n;count+=1
		end end
		assert(count==30);assert(build("unknown")==nil);assert(item.item(folder,"unknown")==nil)
		return {items=count,parts=parts,cameraContainsAllCorners=true,noninteractive=true,noImportedIdsRequired=true,unknownReturnsNil=true}
	end,debug.traceback)
	folder:Destroy();assert(ok,result);return result
end
