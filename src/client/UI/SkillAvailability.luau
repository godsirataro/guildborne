--!strict
local Rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
-- Presentation only. Server still derives the actor and verifies its current build.
return function(build: any,level: number,id: string,blocked: boolean): (string,boolean)
    local problem=Rules.learnProblem(build,level,id)
    if problem=="AlreadyLearned" then return "Learned",false end
    if blocked then return "Unavailable",false end
    if problem=="SkillPrerequisite" then
        return if (Rules.Skills[id].Tier or 1)>build.tier then "Class tier locked" else "Requires previous skill",false
    end
    if problem=="NoSkillPoints" then return "Not enough skill points",false end
    if problem=="SkillBranchConflict" then return "Other branch selected",false end
    if problem then return "Unavailable",false end
    return "Learn skill",true
end
