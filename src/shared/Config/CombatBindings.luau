--!strict
-- Input names only. The server still resolves actors, skills, targets and cooldowns.
local C={}
local keys={T="Cycle",F="Basic",Q="Ability1",Z="Ability2",X="Ability3",R="Focus",G="Regroup",H="Retreat",
	ButtonL1="Cycle",ButtonR2="Basic",ButtonR1="Ability1",ButtonX="Ability2",ButtonY="Ability3",DPadUp="Focus",DPadLeft="Regroup",DPadDown="Retreat"}
function C.action(key: string,input: string): string?
	if input=="MouseButton1" then return "Basic" end
	return keys[key]
end
function C.mode(input: string): string
	return if string.sub(input,1,7)=="Gamepad" then "Gamepad" elseif input=="Touch" then "Touch" else "Keyboard"
end
function C.hint(action: string,mode: string): string
	if mode=="Touch" then return "" end
	local bindings=if mode=="Gamepad" then {Cycle="L1",Basic="R2",Ability1="R1",Ability2="X",Ability3="Y",Focus="↑",Regroup="←",Retreat="↓"}
		else {Cycle="T",Basic="F",Ability1="Q",Ability2="Z",Ability3="X",Focus="R",Regroup="G",Retreat="H"}
	local value=bindings[action]
	return if value then " ["..value.."]" else ""
end
return C
