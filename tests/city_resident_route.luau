--!strict
local M=require("../src/server/Systems/CityResidentRoute")
local function new():any
	return assert(M.new({{x=-110,z=-830},{x=-110,z=-828},{x=-184,z=-828}},0,{x=-190,z=-830}))
end
local function box(x1:number,x2:number,z1:number,z2:number):any
	return {minX=x1,maxX=x2,minY=.7,maxY=5,minZ=z1,maxZ=z2}
end
return function(test:any,eq:any)
	test("station validates finite bounded input and isolates copied actor state",function()
		local bad:{any}={false,"x",0/0,math.huge,-1,0,.99,60.01}
		for _,v in ipairs(bad) do
			eq(M.station({x=1,z=2},0,v,1),nil);eq(M.station({x=1,z=2},0,1,v),nil)
		end
		eq(M.station({x=0/0,z=0},0,1,1),nil);eq(M.station({x=0,z=0},math.huge,1,1),nil)
		local anchor={x=1,z=2};local a=assert(M.station(anchor,1,1,2));local b=assert(M.station(anchor,1,1,2))
		anchor.x=100;a.snapshot().x=200
		a.step(.1,true,true);eq(b.snapshot().clock,0);eq(a.snapshot().x,1);eq(b.snapshot().x,1)
		assert(M.station({x=0,z=0},0,60,60))
	end)
	test("station cycles inspect-rest boundaries without any root movement",function()
		local a=assert(M.station({x=2,z=3},1,1,2));eq(a.snapshot().status,"Inspect")
		for i=1,40 do
			local before=a.snapshot();local p=a.propose(.1);eq(a.snapshot().clock,before.clock)
			local s=a.step(.1,true,true);eq(s.clock,p.clock);eq(s.status,p.status)
			eq(s.x,2);eq(s.z,3);eq(s.yaw,1);eq(s.moving,false)
			if i==9 then eq(s.status,"Inspect") elseif i==10 or i==29 then eq(s.status,"Rest")
			elseif i==30 or i==39 then eq(s.status,"Inspect") elseif i==40 then eq(s.status,"Rest") end
		end
	end)
	test("station blocked and relevance pauses preserve phase and resume exact simulation",function()
		local a=assert(M.station({x=2,z=3},0,1.05,1.15));local b=assert(M.station({x=2,z=3},0,1.05,1.15))
		for _=1,7 do a.step(.1,true,true);b.step(.1,true,true) end
		local before=a.snapshot()
		for _=1,100 do a.step(100,false,true);a.step(100,true,false) end
		eq(a.snapshot().clock,before.clock);eq(a.snapshot().phase,before.phase);eq(a.snapshot().status,"Paused")
		for _=1,100 do local aa=a.step(.1,true,true);local bb=b.step(.1,true,true);eq(aa.clock,bb.clock);eq(aa.phase,bb.phase) end
	end)
	test("station and route clocks clamp accepted dt and freeze invalid paused destroyed ticks",function()
		for _,a in ipairs({new(),assert(M.station({x=1,z=2},0,1,1))}) do
			eq(a.snapshot().clock,0);eq(a.propose(100).clock,.1);eq(a.snapshot().clock,0)
			eq(a.step(100,true,true).clock,.1)
			local bad:{any}={false,"x",0,-1,0/0,math.huge}
			for _,dt in ipairs(bad) do eq(a.propose(dt).clock,.1);eq(a.step(dt,true,true).clock,.1) end
			eq(a.step(.1,false,true).clock,.1);eq(a.step(.1,true,false).clock,.1)
			a.destroy();eq(a.step(.1,true,true).clock,.1);eq(a.propose(.1).clock,.1);eq(a.snapshot().status,"Destroyed")
		end
	end)
	test("market resident route clears stall counter and returns exact origin",function()
		local points={{x=340,z=-1080},{x=340,z=-1070},{x=330,z=-1070}}
		local counter={minX=324,maxX=336,minY=.7,maxY=6,minZ=-1062.5,maxZ=-1057.5}
		local a=assert(M.new(points,math.pi,{x=330,z=-1060}));local reached=false;local returned=false
		for _=1,1200 do
			local before=a.snapshot();local proposed=a.propose(.1)
			eq(M.sweptBlocked(before,proposed,3,.7,6,{counter}),false)
			local s=a.step(.1,true,true)
			if s.status=="Waiting" then reached=true;eq(s.x,330);eq(s.z,-1070) end
			if reached and s.status=="Rest" then returned=true;eq(s.x,340);eq(s.z,-1080);eq(s.yaw,-math.pi);break end
		end
		assert(reached and returned)
		eq(M.sweptBlocked({x=330,z=-1070},{x=330,z=-1060},3,.7,6,{counter}),true)
	end)
	test("each of six supplied party bounds blocks the sweep and removal or vertical clearance restores it",function()
		-- Pure supplied AABBs only: this does not validate runtime actor collection/query eligibility.
		local from,to={x=0,z=0},{x=10,z=0}
		for selected=1,6 do
			local actors={}
			for actor=1,6 do
				actors[actor]=box(actor,actor+.5,20,21)
			end
			actors[selected]=box(selected,selected+.5,-.5,.5)
			eq(M.sweptBlocked(from,to,1,1,5,actors),true)
			local blocker:any=assert(table.remove(actors,selected))
			eq(M.sweptBlocked(from,to,1,1,5,actors),false)
			blocker.minY=6;blocker.maxY=10;table.insert(actors,blocker)
			eq(M.sweptBlocked(from,to,1,1,5,actors),false)
		end
	end)
	test("resident route rejects malformed routes and copies all input points",function()
		local bad:any={ {},{{x=0,z=0}},{{x=0,z=0},{x=0,z=0}},{{x=0,z=0},{x=101,z=0}},
			{{x=0/0,z=0},{x=1,z=0}},{{x=0,z=0},{x=1,z=math.huge}},
			{{x=0,z=0},{x=100,z=0},{x=200,z=0},{x=300,z=0}},
			{[1]={x=0,z=0},[3]={x=1,z=0}},{{x=0,z=0},{x=1,z=0},extra=true}}
		for _,p in ipairs(bad) do eq(M.new(p,0,{x=0,z=0}),nil) end
		local p={{x=0,z=0},{x=1,z=0}};local look={x=2,z=0}
		local a=assert(M.new(p,0,look));p[1].x=999;p[2].x=999;look.x=999
		eq(a.snapshot().x,0)
		local snapshot=a.snapshot();snapshot.x=888;eq(a.snapshot().x,0)
		local b=assert(M.new({{x=0,z=0},{x=1,z=0}},0,{x=2,z=0}))
		for _=1,300 do local aa=a.step(.1,true,true);local bb=b.step(.1,true,true);eq(aa.x,bb.x);eq(aa.yaw,bb.yaw) end
	end)
	test("resident corrected corridor avoids query-false furniture and board; old corridor blocks",function()
		local obstacles={box(-112.5,-107.5,-821.5,-818.5),box(-177.5,-172.5,-821.5,-818.5),box(-190.8,-189.2,-834,-826)}
		eq(M.sweptBlocked({x=-110,z=-830},{x=-110,z=-808},3,.7,6,obstacles),true)
		eq(M.sweptBlocked({x=-110,z=-830},{x=-110,z=-828},3,.7,6,obstacles),false)
		eq(M.sweptBlocked({x=-110,z=-828},{x=-184,z=-828},3,.7,6,obstacles),false)
		eq(M.sweptBlocked({x=-184,z=-828},{x=-110,z=-828},3,.7,6,obstacles),false)
	end)
	test("resident swept bounds catch between-endpoint and in-place turning blockers",function()
		eq(M.sweptBlocked({x=0,z=0},{x=10,z=0},1,1,5,{box(4,5,-.1,.1)}),true)
		eq(M.sweptBlocked({x=0,z=0},{x=0,z=0},3,1,5,{box(2,2.5,0,1)}),true)
		eq(M.sweptBlocked({x=0,z=0},{x=0,z=0},3,6,8,{box(2,2.5,0,1)}),false)
		eq(M.sweptBlocked({x=0,z=0},{x=0,z=0},3,1,5,{box(3,4,0,1)}),true)
	end)
	test("resident malformed collision data fails closed with bounded array checks",function()
		local p={x=0,z=0}
		local invalid:{any}={false,{}, {minX=0,maxX=-1,minY=0,maxY=1,minZ=0,maxZ=1},
			{minX=0,maxX=1,minY=0,maxY=0/0,minZ=0,maxZ=1}}
		for _,b in ipairs(invalid) do local blocked,reason=M.sweptBlocked(p,p,3,1,5,{b});eq(blocked,true);eq(reason,"InvalidGeometry") end
		for _,r in ipairs({0,-1,11,math.huge,0/0}) do eq(M.sweptBlocked(p,p,r,1,5,{}),true) end
		eq(M.sweptBlocked(p,p,3,1,22,{}),true)
		eq(M.sweptBlocked(p,p,3,2,1,{}),true)
		eq(M.sweptBlocked(p,p,3,1,5,{extra=true}),true)
		local many={};for _=1,513 do table.insert(many,box(100,101,100,101)) end
		eq(M.sweptBlocked(p,p,3,1,5,many),true)
		eq(M.sweptBlocked(p,p,3,1,5,{[2]=box(100,101,100,101)}),true)
	end)
	test("resident blocked and irrelevant ticks freeze route clock and resume without catch-up",function()
		local a,b=new(),new()
		for _=1,100 do a.step(.1,true,true);b.step(.1,true,true) end
		local before=a.snapshot()
		for _=1,200 do a.step(100,true,false);a.step(100,false,true) end
		local paused=a.snapshot();eq(paused.x,before.x);eq(paused.z,before.z);eq(paused.yaw,before.yaw);eq(paused.status,"Paused")
		for _=1,500 do local aa=a.step(.1,true,true);local bb=b.step(.1,true,true);eq(aa.x,bb.x);eq(aa.z,bb.z);eq(aa.yaw,bb.yaw);eq(aa.status,bb.status) end
	end)
	test("resident proposals do not mutate and huge dt clamps exactly to one bounded tick",function()
		local a,b=new(),new()
		for _=1,2000 do
			local before=a.snapshot();local proposal=a.propose(99)
			eq(a.snapshot().x,before.x);eq(a.snapshot().yaw,before.yaw)
			local aa=a.step(99,true,true);local bb=b.step(.1,true,true)
			eq(aa.x,proposal.x);eq(aa.z,proposal.z);eq(aa.yaw,proposal.yaw)
			eq(aa.x,bb.x);eq(aa.z,bb.z);eq(aa.yaw,bb.yaw);eq(aa.status,bb.status)
		end
	end)
	test("resident route reverses exact endpoints and bounds translation and shortest-arc turns",function()
		local a=new();local reached=false;local returned=false;local rested=false;local waitingTicks=0
		for _=1,2000 do
			local prev=a.snapshot();local s=a.step(.1,true,true)
			local d=math.sqrt((s.x-prev.x)^2+(s.z-prev.z)^2)
			local turn=math.abs((s.yaw-prev.yaw+math.pi)%(2*math.pi)-math.pi)
			assert(d<=.30000001 and turn<=math.pi/20+1e-9)
			assert(d<1e-9 or turn<1e-9,"must stop before turn")
			assert(s.x>=-184 and s.x<=-110 and s.z>=-830 and s.z<=-828)
			if s.status=="Waiting" then reached=true;waitingTicks+=1;eq(s.x,-184);eq(s.z,-828) end
			if reached and s.x==-110 and s.z==-830 then returned=true end
			if returned and s.status=="Rest" then rested=true;eq(s.yaw,0);break end
		end
		assert(reached and returned and rested);assert(waitingTicks>=60)
	end)
	test("resident invalid dt and destroy hold finite pose without throwing",function()
		local a=new();for _=1,150 do a.step(.1,true,true) end
		local before=a.snapshot();local bad:{any}={false,"x",0,-1,0/0,math.huge}
		for _,dt in ipairs(bad) do
			local p=a.propose(dt);eq(p.x,before.x);eq(p.yaw,before.yaw)
			local s=a.step(dt,true,true);eq(s.x,before.x);eq(s.yaw,before.yaw);eq(s.reason,"InvalidDt")
		end
		a.destroy();for _=1,100 do local s=a.step(.1,true,true);eq(s.x,before.x);eq(s.yaw,before.yaw);eq(s.status,"Destroyed");eq(s.moving,false) end
		eq(a.propose(.1).status,"Destroyed")
	end)
end
