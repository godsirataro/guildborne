--!strict
return function(test:any,eq:any)
    local A=require("../src/server/Systems/AdventurePatterns")
    local function actor(id:string):any return {templateId=id,health=100,maxHealth=100,position={x=0,y=2,z=0}} end
    test("regional patterns lock target and release once after windup",function()
        local a=actor("quarry_guardian");local target={x=10,y=2,z=0};local p=A.begin(a,target,0);assert(p)
        target.x=80;p.x=99
        eq(a.pendingPattern.x,10);eq(A.take(a,1),nil)
        local hit=A.take(a,1.4);assert(hit);eq(hit.x,10);eq(A.take(a,1.4),nil);eq(A.begin(a,target,2),nil)
        assert(A.begin(a,target,3.21))
    end)
    test("regional phases alternate only at half health and have distinct shapes",function()
        for _,id in ipairs({"forest_captain","quarry_guardian","arcane_warden"}) do
            local a=actor(id);local target={x=10,y=2,z=0}
            local first=A.begin(a,target,0);assert(first);eq(first.phase,1)
            A.take(a,first.due);a.health=50
            local second=A.begin(a,target,10);assert(second);eq(second.phase,2);assert(second.shape~=first.shape)
            A.take(a,second.due);local third=A.begin(a,target,20);assert(third);eq(third.name,first.name)
        end
    end)
    test("regional footprints enforce facing side range height and ring safe center",function()
        local line={shape="Line",x=0,y=2,z=0,dx=1,dz=0,length=20,width=4}
        eq(A.contains(line,{x=10,y=2,z=2}),true);eq(A.contains(line,{x=10,y=2,z=2.01}),false)
        eq(A.contains(line,{x=-.01,y=2,z=0}),false);eq(A.contains(line,{x=20.01,y=2,z=0}),false);eq(A.contains(line,{x=10,y=8.01,z=0}),false)
        local ring={shape="Ring",x=0,y=2,z=0,innerRadius=5,radius=13}
        eq(A.contains(ring,{x=0,y=2,z=0}),false);eq(A.contains(ring,{x=5,y=2,z=0}),true);eq(A.contains(ring,{x=13,y=2,z=0}),true)
        eq(A.contains(ring,{x=13.01,y=2,z=0}),false)
        local cone={shape="Cone",x=0,y=2,z=0,dx=1,dz=0,radius=10,halfAngle=55}
        eq(A.contains(cone,{x=5,y=2,z=0}),true);eq(A.contains(cone,{x=-5,y=2,z=0}),false);eq(A.contains(cone,{x=0,y=2,z=5}),false)
    end)
    test("regional death cancellation and stalled server never release stale damage",function()
        local a=actor("forest_captain");local p=A.begin(a,{x=5,y=2,z=0},0);assert(p)
        A.cancel(a,.4);eq(A.take(a,2),nil);eq(A.begin(a,{x=5,y=2,z=0},1),nil)
        p=A.begin(a,{x=5,y=2,z=0},5);assert(p);eq(A.take(a,p.expires+.01),nil)
        a.nextPattern=0;p=A.begin(a,{x=5,y=2,z=0},10);assert(p);a.health=0;eq(A.take(a,p.due),nil)
    end)
    test("regional patterns reject invalid geometry time and unsupported templates",function()
        local a=actor("greenwood_boar")
        eq(A.begin(a,{x=0/0,y=2,z=0},0),nil);eq(A.begin(a,{x=0,y=2,z=0},math.huge),nil)
        a.position.x=0/0;eq(A.begin(a,{x=0,y=2,z=0},0),nil)
        eq(A.begin(actor("unknown"),{x=0,y=2,z=0},0),nil)
        eq(A.contains({shape="Circle",x=0,y=2,z=0,radius=5},{x=0/0,y=2,z=0}),false)
    end)
end
