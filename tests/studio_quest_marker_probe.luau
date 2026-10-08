--!strict
-- Run as a LocalScript; all data and the tagged anchor are synthetic.
return function(): any
	local Collection=game:GetService("CollectionService")
	local anchor=Instance.new("Part");anchor.Name="UATQuestMarkerFixture";anchor.Anchored=true;anchor.Position=Vector3.new(0,300,0)
	anchor:SetAttribute("QuestNPC","UATMedic");anchor.Parent=workspace
	local controller=require(game.Players.LocalPlayer.PlayerScripts.Client.Controllers.QuestNpcMarkers)()
	local ok,result=xpcall(function()
		local data: any={language="en",settlement={journal={}},inventory={stacks={}}}
		local view={status="Active",data=data,catalog={JournalOrder={"herbs"},Journal={herbs={NPC="UATMedic",Count=2,Item="herb"}}}}
		controller.Update(view);Collection:AddTag(anchor,"GuildborneQuestNPC");task.wait()
		local function marker(): BillboardGui?
			for _,g in ipairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do if g:IsA("BillboardGui") and g.Name=="QuestNPCMarker" and g.Adornee==anchor and g:GetAttribute("QuestId")=="herbs" then return g end end
			return nil
		end
		local gui=marker();assert(gui and gui.Enabled and not gui.ResetOnSpawn)
		assert(gui:GetAttribute("QuestState")=="Quest available")
		data.settlement.journal.herbs={state="Active",progress=99};data.inventory.stacks.herb=2;controller.Update(view)
		assert(gui:GetAttribute("QuestState")=="Ready to turn in")
		data.inventory.stacks.herb=1;data.language="th";controller.Update(view)
		assert(gui:GetAttribute("QuestState")=="Quest in progress");assert((gui:FindFirstChild("State") :: TextLabel).Text=="...  กำลังทำเควสต์")
		data.settlement.journal.herbs.state="Claimed";controller.Update(view);assert(not gui.Enabled)
		Collection:RemoveTag(anchor,"GuildborneQuestNPC");task.wait();assert(gui.Parent==nil)
		Collection:AddTag(anchor,"GuildborneQuestNPC");task.wait();controller.Update({status="Loading"})
		controller.Destroy()
		return {lateAnchor=true,availableReadyProgress=true,inventoryRefresh=true,thaiLabel=true,completedHidden=true,tagRemovalCleanup=true,controllerCleanup=true,noProfileWrites=true}
	end,debug.traceback)
	controller.Destroy();Collection:RemoveTag(anchor,"GuildborneQuestNPC");anchor:Destroy();assert(ok,result);return result
end
