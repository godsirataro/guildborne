--!strict
-- Runtime-only synthetic actors. No real profile, player remote or reward write.
-- Run through a temporary server Script after bootstrap, not directly in the MCP
-- command VM: that separate require cache has only the five base ability definitions.
return function(): any
	local folder=Instance.new("Folder");folder.Name="UATCompanionFixture";folder.Parent=game.ServerStorage
	local ok,result=xpcall(function()
		local service=require(game.ServerScriptService.Server.Services.CombatService)(folder,function() error("Unexpected reward") end,function() error("Unexpected tower result") end)
		local function actor(id: string,kind: string,z: number): any
			local m=Instance.new("Model");m.Name=id;m.Parent=folder
			local root=Instance.new("Part");root.Anchored=true;root.Position=Vector3.new(0,4,z);root.Parent=m;Instance.new("Humanoid",m)
			return {id=id,kind=kind,class=if kind=="Hero" then "Warrior" else nil,owner=-1,model=m,root=root,
				active=true,health=1000,state="Idle",cooldowns={},threat={},stats={Attack=10,Defense=1,MaxHealth=1000,AttackRange=5,AttackInterval=1}}
		end
		local player=actor("player","Hero",80);local hero=actor("h:1","Hero",81);local enemy=actor("g:1","Enemy",83)
		hero.build={tier=3,path="warlord",skills={vitality=true,path_art=true,master_art=true}}
		local s: any={active=true,origin=Vector3.zero,playerCombat=player,playerBuild={tier=1,skills={}},
			heroes={["h:1"]={state="Following",combat=hero}},enemies={enemy},allies={player,hero}}
		hero.session=s
		local cast,code=service.PlayerAction(s,"Ability2",100,"h:1");assert(cast,code)
		assert(hero.cooldowns.cleave and not next(player.cooldowns));assert(table.find(enemy.participants,"h:1"))
		cast,code=service.PlayerAction(s,"Ability3",101,"h:1");assert(not cast and tostring(code)=="Cooldown",code)
		cast,code=service.PlayerAction(s,"Ability3",150,"h:1");assert(cast,code)
		cast,code=service.PlayerAction(s,"Ability1",180,"h:foreign");assert(not cast and tostring(code)=="CompanionUnavailable",code)
		hero.owner=-2;cast,code=service.PlayerAction(s,"Ability1",180,"h:1");assert(not cast and tostring(code)=="CompanionUnavailable",code);hero.owner=-1
		s.heroes["h:1"].state="Resting at guild";cast,code=service.PlayerAction(s,"Ability1",180,"h:1");assert(not cast,code);s.heroes["h:1"].state="Following"
		hero.health=0;cast,code=service.PlayerAction(s,"Ability1",180,"h:1");assert(not cast,code);hero.health=1000
		player.root.Position=Vector3.new(0,4,47);hero.root.Position=Vector3.new(0,4,49)
		cast,code=service.PlayerAction(s,"Ability1",180,"h:1");assert(not cast and tostring(code)=="EnterCamp",code)
		player.root.Position=Vector3.new(0,4,80);hero.root.Position=Vector3.new(0,4,81)
		hero.build={tier=1,skills={}};cast,code=service.PlayerAction(s,"Ability3",180,"h:1");assert(not cast and tostring(code)=="SkillNotLearned",code)
		assert(player.health==1000 and next(player.cooldowns)==nil)
		return {ownedCompanionCast=true,independentPlayerCooldown=true,sharedHeroCooldown=true,
			unknownAndForeignRejected=true,restingAndDownedRejected=true,leaderSafeZoneRejected=true,lockedArtRejected=true,participationCaptured=true}
	end,debug.traceback)
	folder:Destroy();assert(ok,result);return result
end
