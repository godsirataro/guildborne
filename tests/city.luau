--!strict
return function(test: any,eq: any,harness: any,Util: any,Content: any,Schema: any,Locale: any,Protocol: any)
	local City=require("../src/shared/Config/City")
	local Rules=require("../src/server/Systems/TravelRules")(City)
 test("remembered guild portal returns only to fixed city stops and preserves the default fallback",function()
  for id,stop in pairs(City.GuildPortalStops)do
   local x,y,z=Rules.resolve("City",true,id);eq(x,stop.ReturnX);eq(y,5);eq(z,stop.ReturnZ);eq(City.contains(x,z),true)
   x,y,z=Rules.resolve("City",false,id);eq(x,stop.FallbackX);eq(z,stop.FallbackZ);eq(City.contains(x,z),true)
   x,y,z=Rules.resolve("Guild",true,id);eq(x,City.Destinations.Guild.X);eq(z,City.Destinations.Guild.Z)
  end
  local x,y,z=Rules.resolve("City",true,"client_position");eq(x,0);eq(y,5);eq(z,-720)
 end)
 test("district return stop cannot be provided by a client travel request",function()
  eq(Protocol.validate({version=1,requestId="warp",revision=0,action="TravelZone",args={zone="City",returnStop="TowerDistrict"}}),false)
 end)
	test("city destination allowlist accepts city and personal guild",function()
		for _,zone in ipairs({"City","Guild"}) do eq(Rules.validate(zone,true,false,false,false,4),nil) end
	end)
	test("unknown and future travel destinations reject",function()
		for _,zone in ipairs({"Unknown","TowerGateFuture",""}) do eq(Rules.validate(zone,true,false,false,false,4),"InvalidZone") end
	end)
	test("travel protocol rejects arbitrary transforms and foreign identity",function()
		local packets: {any}={{zone="City",CFrame={0,0,0}},{zone="City",userId=2},{zone={1,2,3}}}
		for _,args in ipairs(packets) do
			eq(Protocol.validate({version=1,requestId="warp",revision=0,action="TravelZone",args=args}),false)
		end
	end)
	test("guild to city preserves selected companions and all progression",function()
		local h=harness();h.setup();local before=Util.copy(h.data())
		eq(h.send("TravelZone",{zone="City"}),"OK");eq(h.data(),before)
	end)
	test("city to guild preserves companions and progression",function()
		local h=harness();h.setup();local before=Util.copy(h.data())
		eq(h.send("TravelZone",{zone="Guild"}),"OK");eq(h.data(),before)
	end)
	test("city bounds suppress combat acquisition even with foreign origins",function()
		for _,d in ipairs(City.Districts) do eq(City.allowsCombat(d.X,4,d.Z,d.X,1),false) end
		eq(City.allowsCombat(0,4,75,0,1),true)
		eq(City.allowsCombat(180,4,75,0,1),false)
		eq(City.allowsCombat(0,40,75,0,1),false)
	end)
	test("travel prohibits downed dead combat and tower states",function()
		eq(Rules.validate("City",false,false,false,false,4),"ActorNotReady")
		eq(Rules.validate("City",true,true,false,false,4),"Downed")
		eq(Rules.validate("City",true,false,true,false,4),"ReturnToGuild")
		eq(Rules.validate("City",true,false,false,true,4),"FinishExpedition")
	end)
	test("travel fallback resolves separate supported spawn candidate",function()
		local x,y,z=Rules.resolve("City",false);eq(x,0);eq(y,5);eq(z,-750)
		local gx,gy,gz=Rules.resolve("unknown",false);eq(gx,0);eq(gy,5);eq(gz,14)
	end)
	test("city district IDs unique and bilingual navigation resolves",function()
		local ids={};for _,d in ipairs(City.Districts) do assert(not ids[d.Id]);ids[d.Id]=true
			assert(Locale.Thai[d.Name]);eq(Locale.translate("en",d.Name),d.Name)
			eq(City.district(d.X,d.Z),d.Name)
		end
		for _,key in ipairs({"City Map","Safe zone","Coming in a future phase","Central City"}) do assert(Locale.Thai[key]) end
	end)
	test("warp throttle rejects burst and isolates players",function()
		local a,b={},{};eq(Rules.accept(a,10),true);eq(Rules.accept(a,10.1),false)
		eq(Rules.accept(b,10.1),true);eq(Rules.accept(a,12),true)
	end)
	test("distant and nonfinite portal claims reject",function()
		for _,distance in ipairs({17,math.huge,0/0,-1}) do eq(Rules.validate("City",true,false,false,false,distance),"VisitStation") end
	end)
	test("travel never adds foreign companions",function()
		local h=harness();h.setup();local before=Util.copy(h.data())
		eq(h.send("UpdateParty",{adventurerIds={"a:Warrior","foreign:hero"}}),"InvalidParty")
		eq(h.send("TravelZone",{zone="City"}),"OK");eq(h.data(),before)
	end)
	test("city delivery retains actor and Hall caps",function()
		eq(Content.Limits.Level,100);eq(Content.HallUpgrades[19].To,20)
		local h=harness();h.setup();eq(Schema.validate(h.service.Sessions[1].record,1),true)
	end)
    test("Greenwood travel preserves profile and remains a safe traversal zone",function()
        local h=harness();h.setup();local before=Util.copy(h.data())
        eq(h.send("TravelZone",{zone="Greenwood"}),"OK");eq(h.data(),before)
        eq(Rules.validate("Greenwood",true,false,false,false,4),nil)
        eq(Rules.validate("Greenwood",true,false,true,false,4),"ReturnToGuild")
        eq(Rules.validate("Greenwood",true,false,false,true,4),"FinishExpedition")
        eq(City.region(0,1505),"Greenwood");eq(City.allowsCombat(0,7,1505,0,1),false)
        eq(City.region(0,-720),nil);eq(City.region(0,23),nil);eq(City.region(200,1505),nil)
    end)
    test("Greenwood primary and fallback landings are distinct and in regional bounds",function()
        local x,y,z=Rules.resolve("Greenwood",true);eq(x,0);eq(y,7);eq(z,1505)
        local fx,fy,fz=Rules.resolve("Greenwood",false);eq(fx,0);eq(fy,7);eq(fz,1495)
        eq(City.region(x,z),"Greenwood");eq(City.region(fx,fz),"Greenwood")
        eq(City.Destinations.Greenwood.GroundY,2);assert(Locale.Thai.Greenwood)
        for _,id in ipairs({"Ironveil","Ashen"}) do eq(Rules.validate(id,true,false,false,false,4),nil) end
    end)

    test("all regional routes preserve profiles and keep unique safe arrival bounds",function()
        local seen={}
        for _,id in ipairs(City.RegionOrder) do
            local h=harness();h.setup();local before=Util.copy(h.data())
            eq(h.send("TravelZone",{zone=id}),"OK");eq(h.data(),before)
            local d=City.Destinations[id];eq(City.region(d.X,d.Z),id);eq(City.region(d.FallbackX,d.FallbackZ),id)
            assert(not seen[d.X]);seen[d.X]=true
            eq(City.allowsCombat(d.X,d.Y,d.Z,d.X,1),false);assert(Locale.Thai[id])
        end
        eq(City.region(250,1505),nil);eq(City.region(750,1505),nil)
    end)

end
