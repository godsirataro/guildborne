--!strict
-- Product telemetry only. Business audit events retain their independent contract.
local Contract={}
local milestones={session_ready=true,class_selected=true,guild_founded=true,first_npc_recruited=true,first_effective_combat=true,first_hero_order=true,first_combat_reward=true,first_campaign_chapter=true}
function Contract.sanitize(name:any,payload:any):any?
 if name~="onboarding_milestone" or type(payload)~="table" or getmetatable(payload)~=nil then return nil end
 for key in pairs(payload)do if key~="version" and key~="milestone" and key~="elapsedSeconds" then return nil end end
 if payload.version~=1 or type(payload.milestone)~="string" or not milestones[payload.milestone]then return nil end
 local elapsed=payload.elapsedSeconds
 if type(elapsed)~="number" or elapsed~=elapsed or elapsed%1~=0 or elapsed<0 or elapsed>86400 then return nil end
 return {version=1,milestone=payload.milestone,elapsedSeconds=elapsed}
end
return Contract
