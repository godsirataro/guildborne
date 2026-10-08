--!strict
-- Isolated runtime fixture. No real profile, reward callback, remote or player actor.
return function(): any
	local folder=Instance.new("Folder");folder.Name="UATSkillSlotFixture";folder.Parent=game.ServerStorage
	local module=game.ServerScriptService.Server.Services.CombatService:Clone()
	module.Name="SkillSlotFixtureService"
	-- MCP module cache is separate from Bootstrap's enriched combat configuration.
	module.Source=module.Source:gsub('local Config=require%(script.Parent.Parent.Config.Combat%)',[[local Config=(function()
 local c=table.clone(require(script.Parent.Parent.Config.Combat));c.Abilities=table.clone(c.Abilities)
 for id,definition in pairs(require(game.ReplicatedStorage.Shared.Data.Expansion).Abilities) do c.Abilities[id]=definition end
 return c
end)()]])
	module.Parent=game.ServerScriptService.Server.Services
	local ok,result=xpcall(function()
		local loadFixture:any=require
		local service=loadFixture(module)(folder,function() error("Unexpected reward") end,function() error("Unexpected tower result") end)
		local function model(name: string,position: Vector3): (Model, Part)
			local m=Instance.new("Model");m.Name=name;m.Parent=folder
			local root=Instance.new("Part");root.Anchored=true;root.Position=position;root.Parent=m
			Instance.new("Humanoid",m)
			return m,root
		end
		local am,ar=model("Actor",Vector3.new(0,4,80));local em,er=model("Enemy",Vector3.new(0,4,82))
		local a: any={id="player",class="Warrior",kind="Hero",owner=-1,model=am,root=ar,active=true,health=100,state="Idle",cooldowns={},stats={Attack=10,Defense=1,MaxHealth=100,AttackRange=5,AttackInterval=1}}
		local e: any={id="fixture",kind="Enemy",owner=-1,model=em,root=er,active=true,health=1000,state="Idle",threat={},stats={Defense=3,MaxHealth=1000}}
		local s: any={active=true,origin=Vector3.zero,playerCombat=a,enemies={e},allies={a},playerBuild={tier=3,path="warlord",skills={vitality=true,path_art=true,master_art=true}}}
		local cast,code=service.PlayerAction(s,"Ability1",100);assert(cast,code)
		a.plot=folder
		cast,code=service.PlayerAction(s,"Ability2",101);assert(not cast and tostring(code)=="Cooldown",code)
		cast,code=service.PlayerAction(s,"Ability2",120);assert(cast,code)
		assert(am:GetAttribute("ActionAbilityId")=="cleave","Missing path presentation ID")
		cast,code=service.PlayerAction(s,"Ability3",150);assert(cast,code)
		assert(am:GetAttribute("ActionAbilityId")=="cleave_master","Missing master presentation ID")
		cast,code=service.PlayerAction(s,"Basic",175);assert(cast,code)
		assert(am:GetAttribute("ActionAbilityId")==nil,"Basic retained previous art ID")
		s.playerBuild={tier=1,skills={}}
		cast,code=service.PlayerAction(s,"Ability3",180);assert(not cast and tostring(code)=="SkillNotLearned",code)
		cast,code=service.PlayerAction(s,"Ability4",180);assert(not cast and tostring(code)=="InvalidRequest",code)
		ar.Position=Vector3.new(0,4,0)
		cast,code=service.PlayerAction(s,"Ability1",190);assert(not cast and tostring(code)=="EnterCamp",code)
		return {threeSlotsCast=true,sharedCooldown=true,lockedSlotRejected=true,invalidSlotRejected=true,safeZoneRejected=true,pathPresentationIds=true,basicClearsPresentationId=true}
	end,debug.traceback)
	folder:Destroy();module:Destroy()
	assert(ok,result)
	return result
end
