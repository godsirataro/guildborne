--!strict
local B=require("../src/shared/Config/CombatBindings")
return function(test: any,eq: any)
	test("keyboard and gamepad map to the same bounded combat intents",function()
		for _,pair in ipairs({{"T","ButtonL1","Cycle"},{"F","ButtonR2","Basic"},{"Q","ButtonR1","Ability1"},{"Z","ButtonX","Ability2"},{"X","ButtonY","Ability3"}}) do
			eq(B.action(pair[1],"Keyboard"),pair[3]);eq(B.action(pair[2],"Gamepad1"),pair[3])
		end
		eq(B.action("Unknown","MouseButton1"),"Basic");eq(B.action("Space","Keyboard"),nil);eq(B.action("ButtonA","Gamepad1"),nil)
		for _,pair in ipairs({{"R","DPadUp","Focus"},{"G","DPadLeft","Regroup"},{"H","DPadDown","Retreat"}}) do
			eq(B.action(pair[1],"Keyboard"),pair[3]);eq(B.action(pair[2],"Gamepad1"),pair[3])
		end
	end)
	test("companion orders accept only action and owned actor selector fields",function()
		local Input=require("../src/server/Systems/PlayerCombatInput")
		for _,action in ipairs({"Focus","Regroup","Retreat"}) do
			eq(Input.valid({action=action,actorId="h:1"}),true)
			eq(Input.valid({action=action,actorId="h:1",target="enemy"}),false)
			eq(Input.valid({action=action,actorId="h:1",position={0,0,0}}),false)
		end
		eq(Input.valid({action="Teleport",actorId="h:1"}),false)
	end)
	test("combat hints follow current input and touch remains uncluttered",function()
		eq(B.mode("Gamepad1"),"Gamepad");eq(B.mode("Gamepad8"),"Gamepad");eq(B.mode("Touch"),"Touch")
		eq(B.mode("MouseMovement"),"Keyboard");eq(B.hint("Ability1","Gamepad")," [R1]")
		eq(B.hint("Ability1","Keyboard")," [Q]");eq(B.hint("Ability1","Touch"),"");eq(B.hint("Unknown","Keyboard"),"")
	end)
end
