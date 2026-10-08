--!strict
-- Manual CLIENT probe after studio_client_probe passes. Memory or isolated QA DataStore only.
local RunService=game:GetService("RunService")
assert(RunService:IsStudio() and RunService:IsClient())
local Http=game:GetService("HttpService")
local r=game.ReplicatedStorage:WaitForChild("GuildborneRemotes")
local latest: any=nil
local response: any=nil
local waiting: string?=nil
local connection=(r.State :: RemoteEvent).OnClientEvent:Connect(function(v)
	latest=v; _G.GBHeroesView=v
	if waiting and (v.requestId==waiting or (v.code=="InvalidRequest" and v.requestId==nil)) then response=v end
end)
local function send(action: string,args: any?,code: string?): any
	task.wait(.8)
	local packet={version=1,requestId=Http:GenerateGUID(false),revision=if latest then latest.revision else 0,action=action,args=args or {}}
	for _=1,8 do
		response=nil; waiting=packet.requestId; (r.Command :: RemoteEvent):FireServer(packet)
		local untilTime=os.clock()+30
		repeat task.wait(.05) until response or os.clock()>untilTime
		assert(response,"No reply "..action)
		if response.code~="Busy" then break end
		task.wait(1)
	end
	assert(response.code==code,action..": "..tostring(response.code))
	print("GBHERO PASS",action,code,latest.revision)
	return response
end
local function heroes(): Folder return workspace.GuildborneWorld.PersonalGuild.Heroes end
_G.GBHeroesSend=function(action: string,args: any?) return send(action,args,"OK") end
_G.GBHeroesDone=false; _G.GBHeroesError=nil
-- Keep observer for subsequent movement/respawn/rejoin probes; explicit cleanup at Stop.
_G.GBHeroesConnection=connection
task.spawn(function()
	local ok,err=pcall(function()
		send("GetState",{},nil)
		assert(latest.data.hallLevel==2 and not latest.data.quests.active,"Complete baseline loop first")
		assert(#heroes():GetChildren()==5,"Expected five class representations")
		local needed=0
		for _,class in ipairs({"Knight","Mage"}) do if not latest.data.adventurers["a:"..class] then needed+=20 end end
		while latest.data.gold<needed do
			send("StartQuest",{questId="trail_watch"},"OK")
			local run=latest.data.quests.active
			task.wait(math.max(0,run.completeAt-latest.serverTime)+1)
			send("CompleteQuest",{runId=run.runId},"OK")
		end
		for _,class in ipairs({"Knight","Mage"}) do
			if not latest.data.adventurers["a:"..class] then send("Recruit",{classId=class},"OK") end
		end
		for _,pair in ipairs({{"Warrior","q:3:1"},{"Archer","recruit:Archer:1"},{"Priest","recruit:Priest:1"},{"Knight","recruit:Knight:1"},{"Mage","recruit:Mage:1"}}) do
			send("EquipItem",{adventurerId="a:"..pair[1],instanceId=pair[2]},"OK")
			assert((heroes():FindFirstChild(pair[1]) :: Model):FindFirstChild("EquippedWeapon"),"Missing visible equipped weapon")
		end
		local ids={"a:Knight","a:Warrior","a:Archer","a:Mage","a:Priest"}
		send("UpdateParty",{adventurerIds=ids},"OK")
		for _,m in ipairs(heroes():GetChildren()) do assert(m:GetAttribute("HeroState")=="Following") end
		send("UpdateParty",{adventurerIds={"a:Knight","a:Warrior","a:Archer","a:Mage","a:Priest","a:Sixth"}},"InvalidRequest")
		send("UpdateParty",{adventurerIds={"a:Knight","a:Knight"}},"InvalidParty")
		send("StartQuest",{questId="trail_watch"},"OK")
		local run=latest.data.quests.active
		assert(#run.partySnapshot==5,"Snapshot must include five")
		task.wait(.4); assert(#heroes():GetChildren()==0,"Away party must not follow locally")
		task.wait(math.max(0,run.completeAt-latest.serverTime)+1)
		send("CompleteQuest",{runId=run.runId},"OK")
		task.wait(.4); assert(#heroes():GetChildren()==5,"Claim must return party")
		send("UpdateParty",{adventurerIds={"a:Warrior"}},"OK")
		assert((heroes():FindFirstChild("Knight") :: Model):GetAttribute("HeroState")=="Resting at guild")
		send("UpdateParty",{adventurerIds=ids},"OK")
		send("SetLanguage",{language="th"},"OK")
		_G.GBHeroesDone=true
		print("GBHERO FIVE HERO LOOP PASSED",Http:JSONEncode({revision=latest.revision,data=latest.data}))
	end)
	if not ok then _G.GBHeroesError=tostring(err); warn("GBHERO FAILED",err) end
end)
