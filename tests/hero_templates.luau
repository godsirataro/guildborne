--!strict
return function(test:any,eq:any)
    local choose=require("../src/server/Systems/HeroTemplateChoice")
    test("fifteen named templates validate and explicitly select only matching class visuals",function()
        local content=require("../src/server/Config/Content");local util=require("../src/shared/Util/TableUtil")
        local validate=require("../src/server/Systems/ContentValidator");eq(validate(content,util),true)
        for _,id in ipairs(content.HeroTemplateOrder) do
            local template=content.HeroTemplates[id];eq(choose(template.Class,"h:789",id),id)
            assert(require("../src/shared/Config/Localization").Thai[template.Name])
        end
        eq(choose("Warrior","h:1","mage_01"),choose("Warrior","h:1"))
        eq(choose("Warrior","h:1","warrior_04"),choose("Warrior","h:1"))
        local bad=util.copy(content);bad.HeroTemplatePools.Warrior[1]="mage_01";eq(pcall(validate,bad,util),false)
        bad=util.copy(content);bad.HeroTemplates.warrior_01.Name=bad.HeroTemplates.warrior_02.Name;eq(pcall(validate,bad,util),false)
    end)
    test("hero appearance choice is stable class bound and covers three variants",function()
        for _,class in ipairs({"Knight","Warrior","Archer","Mage","Priest"}) do
            local seen={}
            for index=1,30 do
                local id="h:"..index;local chosen=choose(class,id);assert(chosen)
                eq(chosen,choose(class,id));assert(string.sub(chosen,1,#class)==string.lower(class));seen[chosen]=true
            end
            local count=0;for _ in pairs(seen) do count+=1 end;eq(count,3)
        end
        eq(choose("Unknown","h:1"),nil)
    end)
end
