--!strict
-- Per-entity level-derived budget. Coefficients are an initial offline balance pass.
local S={Order={"STR","DEX","INT","VIT","WIS"},PerLevel=3,HardCap=150}
local function integer(n:any,low:number,high:number):boolean return type(n)=="number" and n==n and n%1==0 and n>=low and n<=high end
function S.budget(level:number):number
    assert(integer(level,1,100),"InvalidLevel");return (level-1)*S.PerLevel
end
function S.effective(n:number):number
    assert(integer(n,0,S.HardCap),"InvalidAllocation")
    return math.min(n,40)+.6*math.min(math.max(n-40,0),40)+.3*math.max(n-80,0)
end
function S.validate(level:number,allocation:any):(boolean,number)
    if not integer(level,1,100) or (allocation~=nil and type(allocation)~="table") then return false,0 end
    local spent=0
    for key,value in pairs(allocation or {}) do
        if not table.find(S.Order,key) or not integer(value,0,S.HardCap) then return false,0 end
        spent+=value
    end
    return spent<=S.budget(level),S.budget(level)-spent
end
function S.bonuses(class:string?,allocation:any):any
    local e={};for _,key in ipairs(S.Order) do e[key]=S.effective((allocation or {})[key] or 0) end
    local attack=if class=="Warrior" or class=="Knight" then e.STR elseif class=="Archer" then e.DEX elseif class=="Mage" or class=="Priest" then e.INT else 0
    return {Health=math.floor(e.VIT*2),Attack=math.floor(attack*.25),Defense=math.floor(e.VIT*.1),
        Speed=math.floor(e.DEX*.015*100+.5)/100,HealPower=math.floor(e.WIS*.5),GuardBonus=e.WIS*.001}
end
return S
