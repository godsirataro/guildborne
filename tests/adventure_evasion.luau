--!strict
return function(test:any,eq:any)
    local patterns=require("../src/server/Systems/AdventurePatterns")
    local choose=require("../src/server/Systems/AdventureEvasion")(patterns)
    local function reachable(_from:any,to:any):any return to end
    test("regional companion evasion escapes all authored footprint shapes and holds through windup",function()
        for _,shape in ipairs({"Circle","Line","Cone","Ring"}) do
            local p={shape=shape,x=0,y=2,z=0,radius=8,innerRadius=3,length=18,width=5,dx=1,dz=0,halfAngle=55,due=2}
            local position={x=4,y=2,z=0};local hazards={{id="boss",pattern=p}}
            local result=choose(position,hazards,0,nil,reachable);assert(result,shape)
            eq(patterns.contains(p,result.position),false)
            eq(choose(result.position,hazards,1,result,reachable),result)
            eq(choose(result.position,hazards,2.01,result,reachable),nil)
            eq(choose(position,{},1,result,reachable),nil)
        end
    end)
    test("regional evasion respects blocked terrain overlapping warnings and body margin",function()
        local p={shape="Circle",x=0,y=2,z=0,radius=6,due=2}
        local hazards={{id="one",pattern=p},{id="two",pattern={shape="Circle",x=9,y=2,z=0,radius=4,due=2}}}
        local position={x=0,y=2,z=0};local calls=0
        local result=choose(position,hazards,0,nil,function(_from:any,to:any)calls+=1;return if to.z>0 then to else nil end)
        assert(result);assert(result.position.z>0);eq(patterns.contains(p,result.position),false)
        eq(patterns.contains(hazards[2].pattern,result.position),false);assert(calls<=40)
        eq(choose(position,hazards,0,nil,function()return nil end),nil)
        eq(choose({x=30,y=2,z=0},hazards,0,nil,function()error("Safe actor queried terrain")end),nil)
        local edge=choose({x=6.5,y=2,z=0},{{id="one",pattern=p}},0,nil,reachable)
        assert(edge,"Body margin must escape even with center outside")
    end)
end
