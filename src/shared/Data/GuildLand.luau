--!strict
-- Deterministic land state. No Marketplace calls and no client-side grants.
-- Configure the catalog server-side; payment confirmation belongs to a trusted adapter.
return function(catalog: any)
    local L: any={}
    local function integer(v: any,min: number,max: number): boolean
        return type(v)=="number" and v==v and v%1==0 and v>=min and v<=max
    end
    local function id(v: any): boolean return type(v)=="string" and #v>0 and #v<=128 end
    local products={};local plotCount=0
    for key,def in pairs(catalog) do
        plotCount+=1;assert(plotCount<=64 and id(key) and type(def)=="table","Invalid land catalog")
        assert(integer(def.productId,0,9007199254740991) and type(def.quests)=="table" and #def.quests>0,"Invalid land gate")
        if def.productId>0 then assert(not products[def.productId],"Ambiguous land product");products[def.productId]=true end
        local quests={};local questCount=0
        for index,quest in pairs(def.quests) do
            questCount+=1;assert(integer(index,1,#def.quests) and id(quest) and not quests[quest],"Invalid quest list");quests[quest]=true
        end
        assert(questCount==#def.quests and questCount<=16,"Invalid quest list")
        local materials=0
        for item,n in pairs(def.materials) do materials+=1;assert(id(item) and integer(n,1,1000000),"Invalid land material") end
        assert(materials>0 and materials<=16,"Invalid land materials")
    end
    function L.new(): any return {version=1,plots={}} end
    function L.validate(state: any): boolean
        local ok=pcall(function()
            assert(type(state)=="table" and state.version==1 and type(state.plots)=="table")
            assert(state.accessMode==nil or ({Private=true,Friends=true,Public=true})[state.accessMode]==true)
            local references={}
            for key,plot in pairs(state.plots) do
                local def=catalog[key];assert(def and type(plot)=="table")
                assert(type(plot.questUnlocked)=="boolean" and type(plot.delivered)=="table")
                if plot.entitlement then
                    assert(id(plot.entitlement.reference) and integer(plot.entitlement.productId,1,9007199254740991))
                    assert(not references[plot.entitlement.reference]);references[plot.entitlement.reference]=true
                end
                for item,n in pairs(plot.delivered) do assert(def.materials[item] and integer(n,0,def.materials[item])) end
                assert(plot.opened==nil or plot.opened==true)
                if plot.opened then
                    assert(plot.questUnlocked and plot.entitlement)
                    for item,n in pairs(def.materials) do assert((plot.delivered[item] or 0)==n) end
                end
            end
        end)
        return ok
    end
    function L.describe(state: any,key: string): any
        local def=catalog[key];if not def then return {status="UnknownPlot",canPurchase=false} end
        local plot=state.plots[key]
        if not plot or not plot.questUnlocked then return {status="QuestLocked",canPurchase=false} end
        if not plot.entitlement then
            return {status="PurchaseRequired",canPurchase=integer(def.productId,1,9007199254740991)}
        end
        local remaining={};local complete=true
        for item,n in pairs(def.materials) do remaining[item]=math.max(0,n-(plot.delivered[item] or 0));if remaining[item]>0 then complete=false end end
        return {status=if plot.opened then "Buildable" elseif complete then "ReadyToOpen" else "MaterialsRequired",canPurchase=false,remaining=remaining}
    end
    function L.setAccess(state:any,mode:string):string
        if not ({Private=true,Friends=true,Public=true})[mode] then return "InvalidAccessMode" end
        state.accessMode=mode;return "OK"
    end
    -- Invoke only from authoritative quest completion; milestone remains earned.
    function L.unlock(state: any,key: string,completedQuests: any): string
        local def=catalog[key];if not def then return "UnknownPlot" end
        if state.plots[key] and state.plots[key].questUnlocked then return "AlreadyUnlocked" end
        for _,quest in ipairs(def.quests) do if completedQuests[quest]~=true then return "QuestLocked" end end
        local plot=state.plots[key] or {questUnlocked=false,delivered={}}
        plot.questUnlocked=true;state.plots[key]=plot;return "OK"
    end
    -- This is NOT proof of payment. Only a server payment verifier may call this.
    -- A valid paid entitlement is retained even if quest state is not available yet.
    function L.recordVerifiedEntitlement(state: any,key: string,productId: number,reference: string): string
        local def=catalog[key];if not def then return "UnknownPlot" end
        if not integer(productId,1,9007199254740991) or productId~=def.productId or not id(reference) then return "InvalidEntitlement" end
        for other,plot in pairs(state.plots) do
            if plot.entitlement and plot.entitlement.reference==reference then
                return if other==key and plot.entitlement.productId==productId then "AlreadyCommitted" else "EntitlementConflict"
            end
        end
        local plot=state.plots[key] or {questUnlocked=false,delivered={}}
        if plot.entitlement then return "AlreadyOwned" end
        plot.entitlement={productId=productId,reference=reference};state.plots[key]=plot;return "OK"
    end
    -- Called on a disposable profile copy inside the existing commit transaction.
    function L.contribute(state: any,key: string,inventory: any,item: string,amount: number): string
        local def=catalog[key];if not def then return "UnknownPlot" end
        local plot=state.plots[key]
        if not plot or not plot.questUnlocked then return "QuestLocked" end
        if not plot.entitlement then return "PurchaseRequired" end
        if plot.opened then return "AlreadyOpen" end
        local need=def.materials[item]
        if not need or not integer(amount,1,need) then return "InvalidContribution" end
        if amount>need-(plot.delivered[item] or 0) then return "ContributionExceedsRemaining" end
        local have=inventory[item] or 0
        if not integer(have,0,9007199254740991) or have<amount then return "MissingMaterials" end
        inventory[item]=if have>amount then have-amount else nil;plot.delivered[item]=(plot.delivered[item] or 0)+amount
        return "OK"
    end
    function L.open(state: any,key: string): string
        local status=L.describe(state,key).status
        if status=="Buildable" then return "AlreadyOpen" end
        if status~="ReadyToOpen" then return status end
        state.plots[key].opened=true;return "OK"
    end
    return L
end
