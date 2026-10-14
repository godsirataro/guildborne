--!strict
-- Server fixture for the isolated candidate only. Does not grant rewards or write profiles.
-- Successful Parts/structure checks never certify imported mesh/clothing/animation fit.
return function(view: any?): any
	local RunService=game:GetService("RunService")
	assert(RunService:IsStudio() and game.PlaceId==0 and game.GameId==0,"Local Studio only")
	if RunService:IsClient() then
		assert(view and view.catalog.AppearanceAvailable==true,"Isolated appearance candidate required")
		local http=game:GetService("HttpService")
		local function copy(value:any):any return http:JSONDecode(http:JSONEncode(value)) end
		local fixture=copy(view);fixture.data.character.appearanceEnabled=false
		local gui=Instance.new("ScreenGui");gui.Name="AppearanceUiFixture";gui.Parent=game.Players.LocalPlayer.PlayerGui
		local make=require(game.Players.LocalPlayer.PlayerScripts.Client.UI.CharacterCustomizationUI)
		local ui:any=nil;local sent=0
		local ok,result=xpcall(function()
			ui=make(gui,function():string sent+=1;return "ui-probe-"..sent end,function() end)
			ui.Open(fixture);ui.Apply()
			local panel=gui:FindFirstChild("CharacterCustomization") :: GuiObject;assert(panel)
			assert(panel:GetAttribute("AppearancePending")==true)
			ui.SetBusy(false)
			local response=copy(fixture);response.requestId="ui-probe-1";response.code="SavePending"
			ui.Update(response);assert(panel:GetAttribute("AppearancePending")==true,"Uncertain save must remain tracked")
			response.requestId="unrelated-poll";response.code="StaleRevision";ui.Update(response)
			assert(panel:GetAttribute("AppearancePending")==true,"Unrelated rejection must not release pending")
			response.requestId="ui-probe-1";ui.Update(response)
			assert(panel:GetAttribute("AppearancePending")==false,"Matched terminal denial must release pending")
			ui.Apply();assert(sent==2)
			response=copy(fixture);response.requestId="retry-save-other-request";response.code="OK"
			response.revision+=1;response.data.character.appearanceRevision+=1;response.data.character.appearanceEnabled=true
			ui.Update(response);assert(panel:GetAttribute("AppearancePending")==false,"Authoritative selection must confirm late save")
			return {nativeUiFixtureCases=4,uncertainSaveTracked=true,unrelatedResponseIgnored=true,terminalDenialCorrelated=true,lateSaveConfirmed=true,networkWrites=0}
		end,debug.traceback)
		if ui then ui.Destroy() end;gui:Destroy();assert(ok,result);return result
	end
	local runtime=require(game.ServerScriptService.Server.Config.Runtime)
	assert(runtime.StudioPersistence=="Memory" and next(runtime.AllowedDataStoreUniverses)==nil,"Cloud-free Memory only")
	local Shared=game.ReplicatedStorage.Shared
	local Renderer=require(Shared.Presentation.ModularAppearance.Renderer)
	local legacyRig=require(game.ServerScriptService.Server.Services.HeroRig)
	local Skeleton=require(Shared.Presentation.ModularAppearance.Skeleton)
	local registry=require(game.ServerScriptService.Server.Services.CharacterAppearance.AppearanceAssetRegistry)
	local rules=require(Shared.Data.AppearanceRules)
	local catalog=require(Shared.Data.AppearanceCatalog)
	local policy=require(game.ServerScriptService.Server.Services.CharacterAppearance.PreviewPolicy)
	local service=require(game.ServerScriptService.Server.Services.CharacterAppearance.AppearanceService)(catalog,rules,policy)
	local selection=service.default({raceId="Human"})
	local cases=0
	local holder=Instance.new("Folder");holder.Name="ModularCharacterFixture";holder.Parent=game.ServerStorage
	local ok,result=xpcall(function()
		for _,body in ipairs({"HUMAN_STANDARD","HUMAN_HEAVY"}) do
			for _,palette in ipairs({"SKIN_HUMAN_01","SKIN_HUMAN_02","SKIN_HUMAN_03","SKIN_HUMAN_04","SKIN_HUMAN_05"}) do
				local chosen=rules.copy(selection);chosen.bodyPresetId=body;chosen.skinPaletteId=palette
				local model=Renderer.Build(chosen);model.Parent=holder
				local limbs=0;local joints=0
				for _,name in ipairs(Skeleton.Names) do
					local p=model:FindFirstChild(name);assert(p and p:IsA("Part") and p:GetAttribute("CoreBodyPart")==true)
					assert(not p.CanCollide and not p.CanTouch and not p.CanQuery and p.Massless)
					if p:GetAttribute("SkinTintable") then assert(p.Color==Color3.fromHex(catalog.SkinPalettes[palette].colorHex)) end
					limbs+=1
				end
				for _,p in ipairs(model:GetDescendants()) do if p:IsA("Motor6D") then joints+=1;assert(p.Part0 and p.Part1) end end
				assert(limbs==15 and joints==15,"15 core Parts and 15 joints required")
				local covering=model:FindFirstChild("AlwaysOnModesty");assert(covering)
				for _,p in ipairs(covering:GetChildren()) do assert(p:IsA("BasePart") and p.Transparency==0) end
				model:Destroy();cases+=1
			end
		end
		local source=Renderer.Build(selection);source.Name="PlaceholderR15Proxy";source.Parent=holder
		local root=source.PrimaryPart :: BasePart;root.Anchored=true;root.CanCollide=true;root.Massless=false
		local head=source:FindFirstChild("Head") :: BasePart
		local originalColor=head.Color;local originalSize=root.Size
		local gear=Instance.new("Model");gear.Name="EquippedWeapon";gear.Parent=source
		local grip=Instance.new("Part");grip.Name="Grip";grip.CanCollide=false;grip.Parent=gear
		local removed=rules.copy(selection);removed.outfitSlots={};removed.hairAssetId=nil
		for _=1,4 do
			assert(Renderer.apply(source,removed));assert(Renderer.apply(source,removed))
			source:SetAttribute("RaceId","Elf")
			legacyRig.Race(source,"Elf")
			assert(source:FindFirstChild("AncestryVisual")==nil and source:GetAttribute("RaceId")=="Elf","Cosmetic overlay must preserve ancestry data without new legacy visuals")
			assert(source:FindFirstChild("EquippedWeapon")==gear and root.Size==originalSize and root.CanCollide)
			local overlay=source:FindFirstChild("GuildborneModularAppearance") :: Model;assert(overlay and overlay:FindFirstChild("AlwaysOnModesty"))
			local count=0;for _,p in ipairs(source:GetChildren()) do if p.Name=="GuildborneModularAppearance" then count+=1 end end;assert(count==1)
			Renderer.clear(source);assert(head.Transparency==0 and head.Color==originalColor)
			cases+=1
		end
		local invalid=rules.copy(selection);invalid.outfitSlots.INNER_TOP="rbxassetid://1"
		-- Exercise the real CentralCityWorld builder/role-cue modules without replacing a live NPC.
		local npc=legacyRig.Build("Warrior");npc.Name="NpcAppearanceFixture";npc.Parent=holder
		require(game.ServerScriptService.Server.Services.CityNpcAppearance)(npc,"Craftsperson")
		local npcRoot=npc.PrimaryPart :: BasePart;local npcHumanoid=npc:FindFirstChildOfClass("Humanoid")
		local npcRole=npc:FindFirstChild("CityRoleVisual");assert(npcRole)
		local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Talk";prompt.Parent=npcRoot
		local props={}
		for _,p in ipairs(npcRole:GetDescendants()) do
			if p:IsA("BasePart") then table.insert(props,{part=p,transparency=p.Transparency,weld=p:FindFirstChildOfClass("WeldConstraint")}) end
		end
		assert(#props>0)
		for _,body in ipairs({"HUMAN_STANDARD","HUMAN_HEAVY"}) do
			local chosen=rules.copy(selection);chosen.bodyPresetId=body
			assert(Renderer.apply(npc,chosen));assert(Renderer.apply(npc,chosen))
			assert(npc.PrimaryPart==npcRoot and npc:FindFirstChildOfClass("Humanoid")==npcHumanoid)
			assert(prompt.Parent==npcRoot and prompt.ActionText=="Talk" and npc:GetAttribute("CityRole")=="Craftsperson")
			for _,entry in ipairs(props) do
				assert(entry.part.Transparency==entry.transparency and entry.part:GetAttribute("ModularPreviousTransparency")==nil,"NPC profession prop must remain visible")
				assert(entry.part:FindFirstChildOfClass("WeldConstraint")==entry.weld,"NPC prop attachment must remain intact")
			end
			Renderer.clear(npc);cases+=1
		end
		local civicFolder=require(game.ServerScriptService.Server.Services.CityCharacterKit)(true,"marshal_elian")
		civicFolder.Parent=holder
		local civic=civicFolder:FindFirstChild("marshal_elian") :: Model;assert(civic)
		local civicRoot=civic.PrimaryPart;local civicCount=#civic:GetDescendants()
		local accepted,reason=Renderer.apply(civic,selection)
		assert(not accepted and reason=="RIG_ROOT_MISSING","Unadapted civic skeleton must fail before mutation")
		assert(civic.PrimaryPart==civicRoot and #civic:GetDescendants()==civicCount and not civic:GetAttribute("ModularAppearanceActive"))
		cases+=1
		assert(not rules.validateSelection(invalid,catalog,policy,{},"player"))
		local fakeGarment=Instance.new("Accessory");local handle=Instance.new("Part");handle.Name="Handle";handle.Parent=fakeGarment
		assert(not registry.ValidateLayeredTemplate(source,fakeGarment));fakeGarment:Destroy()
		for _,entry in pairs(registry.Entries) do assert(entry.robloxAssetId==nil and entry.template==nil and entry.status=="PLANNED") end
		return {fixtureCases=cases,bodyPresets={"HUMAN_STANDARD","HUMAN_HEAVY"},skinPalettes=5,coreParts=15,r15Joints=15,
			geometry="PLACEHOLDER_PARTS",idempotentRebuild=true,modestyRetained=true,weaponPreserved=true,ancestryVisualIsolation=true,
			layeredMissingMeshRejected=true,robloxAssetIdsRemainNull=true,npcRolePropsPreserved=true,npcPromptIdentityPreserved=true,
			unadaptedCivicSkeletonRejected=true,npcWorldIntegrationAcceptance=false,productionMeshAcceptance=false,animationFitAcceptance=false}
	end,debug.traceback)
	holder:Destroy();assert(ok,result);return result
end
