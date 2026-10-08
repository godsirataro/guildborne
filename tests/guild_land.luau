--!strict
local make=require("../src/shared/Data/GuildLand")
return function(test: any,eq: any)
    local function fixture()
        local rules=make({grove={quests={"q1","q2"},productId=123,materials={timber=6,stone=4}},ridge={quests={"q3"},productId=456,materials={stone=8}},unbound={quests={"q1"},productId=0,materials={timber=2}}})
        return rules,rules.new()
    end
    test("land requires quest then payment then materials; opening is stable",function()
        local l,s=fixture();local bag={timber=10,stone=4}
        eq(l.describe(s,"grove").status,"QuestLocked");eq(l.unlock(s,"grove",{q1=true}),"QuestLocked")
        eq(next(s.plots),nil);eq(l.unlock(s,"grove",{q1=true,q2=true}),"OK")
        eq(l.contribute(s,"grove",bag,"timber",6),"PurchaseRequired");eq(bag.timber,10)
        eq(l.describe(s,"grove").canPurchase,true)
        eq(l.recordVerifiedEntitlement(s,"grove",123,"receipt1"),"OK")
        eq(l.describe(s,"grove").canPurchase,false);eq(l.open(s,"grove"),"MaterialsRequired")
        eq(l.contribute(s,"grove",bag,"timber",2),"OK");eq(l.describe(s,"grove").remaining.timber,4)
        eq(l.contribute(s,"grove",bag,"timber",4),"OK");eq(l.contribute(s,"grove",bag,"stone",4),"OK")
        eq(l.open(s,"grove"),"OK");eq(l.open(s,"grove"),"AlreadyOpen");eq(bag.timber,4);eq(bag.stone,nil)
        eq(l.validate(s),true)
    end)
    test("verified payment is retained while quest eligibility is unavailable",function()
        local l,s=fixture();eq(l.recordVerifiedEntitlement(s,"grove",123,"receipt1"),"OK")
        eq(l.describe(s,"grove").status,"QuestLocked");eq(l.open(s,"grove"),"QuestLocked");eq(l.validate(s),true)
        eq(l.unlock(s,"grove",{q1=true,q2=true}),"OK");eq(l.describe(s,"grove").status,"MaterialsRequired")
        eq(l.recordVerifiedEntitlement(s,"grove",123,"receipt1"),"AlreadyCommitted")
        eq(l.recordVerifiedEntitlement(s,"grove",123,"receipt2"),"AlreadyOwned")
        eq(l.recordVerifiedEntitlement(s,"ridge",456,"receipt1"),"EntitlementConflict")
        eq(s.plots.grove.entitlement.reference,"receipt1")
    end)
    test("land rejects malformed and excess contributions without spending",function()
        local l,s=fixture();l.unlock(s,"grove",{q1=true,q2=true});l.recordVerifiedEntitlement(s,"grove",123,"paid")
        local bag={timber=5,stone=4}
        for _,n in ipairs({0,-1,1.5,0/0,math.huge,7}) do eq(l.contribute(s,"grove",bag,"timber",n),"InvalidContribution") end
        eq(l.contribute(s,"grove",bag,"timber",6),"MissingMaterials");eq(bag.timber,5)
        eq(l.contribute(s,"grove",bag,"timber",4),"OK")
        eq(l.contribute(s,"grove",bag,"timber",3),"ContributionExceedsRemaining");eq(bag.timber,1)
        eq(l.contribute(s,"grove",bag,"gold",1),"InvalidContribution");eq(l.validate(s),true)
    end)
    test("unconfigured purchases stay disabled and invalid state fails validation",function()
        local l,s=fixture();l.unlock(s,"unbound",{q1=true});eq(l.describe(s,"unbound").canPurchase,false)
        eq(l.recordVerifiedEntitlement(s,"unbound",0,"x"),"InvalidEntitlement")
        eq(l.recordVerifiedEntitlement(s,"grove",456,"x"),"InvalidEntitlement")
        s.plots.unbound.opened=true;eq(l.validate(s),false)
        eq(l.describe(s,"unknown").status,"UnknownPlot")
    end)
    test("land catalog rejects ambiguous products and vacuous unlock conditions",function()
        for _,catalog in ipairs({
            {a={quests={},productId=1,materials={wood=1}}},
            {a={quests={"q"},productId=1,materials={wood=-1}}},
            {a={quests={"q","q"},productId=1,materials={wood=1}}},
            {a={quests={"q"},productId=1,materials={wood=1}},b={quests={"r"},productId=1,materials={wood=1}}},
        }) do local ok=pcall(make,catalog);eq(ok,false) end
        local l,s=fixture();l.recordVerifiedEntitlement(s,"grove",123,"one");l.recordVerifiedEntitlement(s,"ridge",456,"two")
        s.plots.ridge.entitlement.reference="one";eq(l.validate(s),false)
    end)
end
