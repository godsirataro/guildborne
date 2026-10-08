--!strict
-- Stable appearance only. Neither rank nor spending participates in the selection.
return function(class:string,id:string,templateId:string?):string?
    if not ({Knight=true,Warrior=true,Archer=true,Mage=true,Priest=true})[class] then return nil end
    if templateId and templateId:match("^"..string.lower(class).."_0[123]$") then return templateId end
    local hash=0
    for index=1,#id do hash=(hash*31+string.byte(id,index))%65521 end
    return string.lower(class).."_0"..tostring(hash%3+1)
end
