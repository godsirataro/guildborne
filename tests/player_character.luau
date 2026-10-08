--!strict
local Participate=require("../src/server/Systems/PlayerParticipation")
local Input=require("../src/server/Systems/PlayerCombatInput")
return function(test: any,eq: any,harness: any,util: any,content: any,config: any,schema: any)
	test("v1 migration preserves populated heroes inventory active quest receipts and audit",function()
		local h=harness(); h.setup(); h.quest("trail_watch"); h.send("StartQuest",{questId="timber_escort"})
		local old=util.copy(h.service.Sessions[1].record); old.data.settlement=nil;for _,hero in pairs(old.data.adventurers) do hero.rank=nil end;old.data.guildLand=nil;old.data.market=nil;old.schemaVersion=1; old.data.expansion=nil; old.data.character=nil; old.data.inventory.nextEquipmentSequence=nil
		local original=util.copy(old); local migrated,code=schema.migrate(old)
		eq(code,"OK"); eq(old,original); eq(migrated.schemaVersion,schema.Version); eq(schema.validate(migrated,1),true)
		local expected=util.copy(original);expected.schemaVersion=schema.Version;expected.data.guildLand=schema.new(1,0).data.guildLand;expected.data.market=schema.new(1,0).data.market;expected.data.settlement=schema.new(1,0).data.settlement;expected.data.expansion=schema.new(1,0).data.expansion;expected.data.inventory.nextEquipmentSequence=1;expected.data.character=schema.new(1,0).data.character;for _,hero in pairs(expected.data.adventurers) do hero.rank="F" end
		eq(migrated,expected); eq(schema.migrate(migrated),migrated)
	end)
	test("actual load migrates v1 atomically and preserves legacy active snapshot",function()
		local h=harness(); h.setup(); h.send("StartQuest",{questId="trail_watch"}); h.service.Close(1)
		local old=h.records["p:1"]; old.data.settlement=nil;for _,hero in pairs(old.data.adventurers) do hero.rank=nil end;old.data.guildLand=nil;old.data.market=nil;old.schemaVersion=1; old.data.expansion=nil; old.data.character=nil; old.data.inventory.nextEquipmentSequence=nil
		local data=util.copy(old.data); h.service=h.make(); eq(h.service.Load(1,"migration"),"OK")
		data.guildLand=schema.new(1,0).data.guildLand;data.market=schema.new(1,0).data.market;data.settlement=schema.new(1,0).data.settlement;for _,hero in pairs(data.adventurers) do hero.rank="F" end; data.expansion=schema.new(1,0).data.expansion; data.character=schema.new(1,0).data.character; data.inventory.nextEquipmentSequence=1; eq(h.data(),data); eq(h.records["p:1"].schemaVersion,schema.Version)
	end)
	test("corrupt v1 and unexpected character data never get replaced",function()
		for _,bad in ipairs({"gold","character"}) do
			local h=harness(); local old=schema.new(1,1000); old.data.settlement=nil;for _,hero in pairs(old.data.adventurers) do hero.rank=nil end;old.data.guildLand=nil;old.data.market=nil;old.schemaVersion=1; old.data.expansion=nil; old.data.character=nil; old.data.inventory.nextEquipmentSequence=nil
			if bad=="gold" then old.data.currencies.gold=-1 else old.data.character={xp=900} end
			h.records["p:1"]=util.copy(old); assert(h.service.Load(1,"bad")~="OK"); eq(h.records["p:1"],old)
		end
	end)
	test("all five starter choices have matching class path skill and kit references",function()
		for _,class in ipairs(content.AdventurerOrder) do
			local h=harness(); h.setup(); local heroes=util.copy(h.data().adventurers)
			eq(h.send("SelectPlayerClass",{classId=class}),"OK")
			local c=h.data().character; local def=content.Character.Classes[class]
			eq(c.classId,class); eq(c.classPathId,def.PathId); eq(c.skillId,config.Classes[class].Ability)
			eq(content.Items[def.Weapon].Class,class); eq(c.raceId,"Human"); eq(c.level,1); eq(c.xp,0)
			eq(h.data().adventurers,heroes); eq(schema.validate(h.service.Sessions[1].record,1),true)
		end
	end)
	test("class selection idempotent replay and second-choice rejection survive rejoin",function()
		local h=harness(); h.setup(); local command=h.command("SelectPlayerClass",{classId="Warrior"})
		eq(h.service.Execute(1,command),"OK"); eq(h.service.Execute(1,command),"AlreadyCommitted")
		eq(h.send("SelectPlayerClass",{classId="Mage"}),"ClassAlreadySelected")
		eq(h.send("SelectPlayerClass",{classId="Legendary"}),"InvalidClass")
		eq(h.service.Close(1),"OK"); h.service=h.make(); eq(h.service.Load(1,"rejoin"),"OK")
		eq(h.data().character.classId,"Warrior"); eq(h.send("SelectPlayerClass",{classId="Warrior"}),"ClassAlreadySelected")
	end)
	test("failed class save exposes no choice and uncertain commit reconciles exactly",function()
		for _,mode in ipairs({"before","after"}) do
			local h=harness(); h.setup(); h.mode=mode
			local command=h.command("SelectPlayerClass",{classId="Priest"})
			eq(h.service.Execute(1,command),"SavePending"); eq(h.data().character.classId,nil)
			h.mode="ok"; eq(h.service.Refresh(1),"OK"); eq(h.data().character.classId,"Priest")
			eq(h.service.Execute(1,command),"AlreadyCommitted")
		end
	end)
	test("forged character definition tier race XP and skill references fail schema",function()
		local h=harness(); h.setup(); h.send("SelectPlayerClass",{classId="Warrior"})
		for field,value in pairs({definitionVersion=2,tier=3,raceId="Dragon",xp=-1,level=5,skillId="fireball",classPathId="warrior:3"}) do
			local record=util.copy(h.service.Sessions[1].record); record.data.character[field]=value
			eq(schema.validate(record,1),false)
		end
	end)
	test("solo player combat reward levels only player and commits once",function()
		local h=harness(); h.setup(); h.send("SelectPlayerClass",{classId="Mage"})
		local heroes=util.copy(h.data().adventurers)
		for _=1,25 do eq(h.service.CommitCombat(1,h.command("CombatReward"),{"player"}),"OK"); h.service.FlushAudit(1) end
		eq(h.data().character.xp,50); eq(h.data().character.level,2); eq(h.data().adventurers,heroes)
		local command=h.command("CombatReward"); eq(h.service.CommitCombat(1,command,{"player"}),"OK")
		eq(h.service.CommitCombat(1,command,{"player"}),"AlreadyCommitted"); eq(h.data().character.xp,52)
	end)
	test("hero-only reward does not give passive player XP",function()
		local h=harness(); h.setup(); h.send("SelectPlayerClass",{classId="Knight"})
		eq(h.service.CommitCombat(1,h.command("CombatReward"),{"a:Warrior"}),"OK")
		eq(h.data().character.xp,0); eq(h.data().adventurers["a:Warrior"].xp,2)
	end)
	test("player plus five heroes eligible without consuming a party slot",function()
		local h=harness(); h.setup(); h.quest("trail_watch"); h.quest("timber_escort"); h.quest("quarry_patrol")
		local members={"player"}; h.send("SelectPlayerClass",{classId="Warrior"})
		for _,class in ipairs(content.AdventurerOrder) do
			if class~="Warrior" then eq(h.send("Recruit",{classId=class}),"OK") end
			table.insert(members,"a:"..class)
		end
		local before=util.copy(h.data()); eq(h.service.CommitCombat(1,h.command("CombatReward"),members),"OK")
		eq(h.data().character.xp,2)
		for id,hero in pairs(before.adventurers) do eq(h.data().adventurers[id].xp,hero.xp+2) end
	end)
	test("invalid unselected duplicate and overflowing player rewards are atomic",function()
		local h=harness(); h.setup(); eq(h.service.CommitCombat(1,h.command("CombatReward"),{"player"}),"InvalidParty")
		h.send("SelectPlayerClass",{classId="Archer"}); local before=util.copy(h.data())
		eq(h.service.CommitCombat(1,h.command("CombatReward"),{"player","player"}),"InvalidParty"); eq(h.data(),before)
		local c=h.service.Sessions[1].record.data.character; c.xp=content.Limits.XP; c.level=h.data().personalGuild.buildings.guildHall*5
		before=util.copy(h.data()); eq(h.service.CommitCombat(1,h.command("CombatReward"),{"a:Warrior","player"}),"XPCap"); eq(h.data(),before)
	end)
	test("selected player can rest every hero without unlocking empty expeditions",function()
		local h=harness(); h.setup(); eq(h.send("UpdateParty",{adventurerIds={}}),"InvalidParty")
		h.send("SelectPlayerClass",{classId="Warrior"}); eq(h.send("UpdateParty",{adventurerIds={}}),"OK")
		eq(#h.data().party.adventurerIds,0); assert(h.send("StartQuest",{questId="trail_watch"})~="OK")
	end)
	test("player participation requires actual damage or combat healing and matching owner",function()
		local p={id="player",owner=1}; local ally={id="a:Warrior"}
		local e: any={kind="Enemy",owner=1,health=10,threat={}}
		Participate("hero_basic_attack",p,e,1,{e},0); eq(e.playerParticipated,nil)
		Participate("healing_done",p,ally,5,{e},0); eq(e.playerParticipated,nil)
		e.target=ally; Participate("healing_done",p,ally,5,{e},0); eq(e.playerParticipated,true)
		e.playerParticipated=nil; e.health=0; Participate("healing_done",p,ally,5,{e},0); eq(e.playerParticipated,nil)
		Participate("damage_dealt",p,e,5,{e},0); eq(e.playerParticipated,true)
		e.playerParticipated=nil; e.owner=2; Participate("damage_dealt",p,e,5,{e},0); eq(e.playerParticipated,nil)
	end)
	test("expired taunt cannot grant a new player participation credit",function()
		local p={id="player",owner=1}; local e: any={kind="Enemy",owner=1,health=10,tauntTarget=p,tauntUntil=3}
		Participate("hero_ability_used",p,e,"taunt",{e},4); eq(e.playerParticipated,nil)
		e.tauntUntil=7; Participate("hero_ability_used",p,e,"taunt",{e},4); eq(e.playerParticipated,true)
	end)
	test("companion effects never grant player participation",function()
		local h={id="a:Warrior",owner=1}; local e: any={kind="Enemy",owner=1,health=0}
		Participate("damage_dealt",h,e,10,{e},0); eq(e.playerParticipated,nil)
	end)
	test("combat intent rejects client authority fields and bounds spam",function()
		eq(Input.valid({action="Basic"}),true); eq(Input.valid({action="Ability"}),true)
		for _,action in ipairs({"Ability1","Ability2","Ability3"}) do eq(Input.valid({action=action}),true);eq(Input.valid({action=action,skillId="nova_master"}),false) end
		eq(Input.valid({action="Ability4"}),false)
		local malformed: {any}={{action="Damage"},{action="Basic",target="g:1"},{action="Ability",skill="fireball"},{action="Basic",damage=999},{action="Basic",at=0},{action="Basic",reward=999},{},"Basic"}
		for _,packet in ipairs(malformed) do eq(Input.valid(packet),false) end
		local bucket={tokens=4,at=0}; local count=0
		for _=1,100 do if Input.accept(bucket,0) then count+=1 end end
		eq(count,4); eq(Input.accept(bucket,.24),false); eq(Input.accept(bucket,.25),true); eq(Input.accept(bucket,.25),false)
	end)
end
