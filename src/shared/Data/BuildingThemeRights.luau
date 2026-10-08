--!strict
-- Trusted state rules only; no Marketplace adapter or client grant path.
return function(catalog:any)
    local T={};local themes=catalog.Themes;local products={}
    local function integer(v:any,lo:number,hi:number):boolean return type(v)=="number" and v==v and v%1==0 and v>=lo and v<=hi end
    for _,def in pairs(themes) do
        assert(def.Mode=="Free" or def.Mode=="Quest" or def.Mode=="Purchase")
        if def.Mode=="Quest" then assert(type(def.Quest)=="string" and #def.Quest>0) end
        if def.Mode=="Purchase" then
            assert(integer(def.ProductId,0,9007199254740991))
            if def.ProductId>0 then assert(not products[def.ProductId]);products[def.ProductId]=true end
        end
    end
    function T.owned(expansion:any,id:string):boolean
        local def=themes[id];return def~=nil and (def.Mode=="Free" or (expansion.themeRights~=nil and expansion.themeRights[id]~=nil))
    end
    function T.validate(expansion:any):boolean
        return pcall(function()
            assert(expansion.themeRights==nil or type(expansion.themeRights)=="table")
            local references={}
            assert(expansion.hallTheme==nil or (type(expansion.hallTheme)=="string" and T.owned(expansion,expansion.hallTheme)))
            for id,right in pairs(expansion.themeRights or {}) do
                local def=themes[id];assert(def and type(right)=="table" and right.source==def.Mode)
                if right.source=="Quest" then assert(right.quest==def.Quest)
                elseif right.source=="Purchase" then
                    assert(integer(right.productId,1,9007199254740991) and type(right.reference)=="string" and #right.reference>0 and #right.reference<=128)
                    assert(not references[right.reference]);references[right.reference]=true
                else error("Unexpected stored free theme") end
            end
            for _,group in ipairs({expansion.buildings,expansion.storage or {},expansion.furniture or {}}) do
                for _,b in pairs(group) do assert(b.theme==nil or (type(b.theme)=="string" and T.owned(expansion,b.theme))) end
            end
        end)
    end
    function T.unlock(data:any,id:string):string
        local def=themes[id];if not def then return "UnknownTheme" end
        if T.owned(data.expansion,id) then return "ThemeAlreadyOwned" end
        if def.Mode~="Quest" then return "ThemePurchaseUnavailable" end
        local quest=data.settlement.journal[def.Quest]
        if not quest or quest.state~="Claimed" then return "ThemeQuestRequired" end
        local e=data.expansion;e.themeRights=e.themeRights or {};e.themeRights[id]={source="Quest",quest=def.Quest}
        return "OK"
    end
    function T.apply(data:any,id:string,buildingId:string):string
        local e=data.expansion;local b=e.buildings[buildingId] or (e.storage and e.storage[buildingId]) or (e.furniture and e.furniture[buildingId])
        if not b and buildingId~="guildHall" then return "InvalidBuilding" end
        if not T.owned(e,id) then return "ThemeNotOwned" end
        if buildingId=="guildHall" then e.hallTheme=id;return "OK" end
        b.theme=id;return "OK"
    end
    -- This function is not payment proof. A future trusted verifier must persist its candidate.
    function T.recordVerified(expansion:any,id:string,productId:number,reference:string):string
        local def=themes[id]
        if not def or def.Mode~="Purchase" or not integer(productId,1,9007199254740991) or productId~=def.ProductId
            or type(reference)~="string" or #reference==0 or #reference>128 then return "InvalidEntitlement" end
        for other,right in pairs(expansion.themeRights or {}) do
            if right.reference==reference then return if other==id and right.productId==productId then "AlreadyCommitted" else "EntitlementConflict" end
        end
        if T.owned(expansion,id) then return "ThemeAlreadyOwned" end
        expansion.themeRights=expansion.themeRights or {};expansion.themeRights[id]={source="Purchase",productId=productId,reference=reference}
        return "OK"
    end
    return T
end
