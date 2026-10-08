--!strict
-- Shared source for runtime enemy statistics and the read-only field guide.
local S={}
function S.build(profile:any,role:string):any
    return {MaxHealth=profile.maxHealth or profile.health,Attack=profile.power,Defense=if role=="Guard" then 15 else 3,
        MoveSpeed=profile.speed,AttackRange=profile.range,AttackInterval=profile.interval,DetectionRange=profile.detect}
end
function S.title(id:string):string
    local title=id:gsub("_"," "):gsub("%a[%w']*",function(word:string)return word:sub(1,1):upper()..word:sub(2)end)
    return title
end
return S
