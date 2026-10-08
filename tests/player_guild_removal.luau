--!strict
local M=require("../src/server/Systems/PlayerGuildMembership")
local Make=require("../src/server/Systems/PlayerGuildRemovalCoordinator")
local Schema=require("../src/server/Systems/PlayerGuildSchema")
local function copy(t:any):any local c={};for k,v in pairs(t)do c[k]=if type(v)=="table"then copy(v)else v end;return c end
return function(test:any,eq:any)
	local function fixture(failAt:number?,after:boolean?):(any,any,any)
		local founder=M.newSlot();assert(M.reserve(founder,"guild","found"));local g=M.newGuild("guild","1",founder)
		assert(M.activateSlot(founder,g,"1"));assert(M.activateMember(g,"1",founder))
		local records:any={Guild={guild=g},Slot={['1']=founder},Operation={}}
		for _,uid in ipairs({'2','3'})do
			local slot=M.newSlot();records.Slot[uid]=slot;assert(M.reserve(slot,"guild","join"..uid))
			local invite=M.invite(g,"1",uid,0,100);assert(invite);assert(M.prepareJoin(g,uid,invite.token,slot,1))
			assert(M.activateSlot(slot,g,uid));assert(M.activateMember(g,uid,slot))
		end
		assert(M.setRole(g,"1","3","Officer"))
		local calls=0;local store={}
		function store.read(kind:string,key:string):(any,string)
			local v=records[kind][key];return if v then copy(v)else nil,if v then "Found"else "Missing"
		end
		function store.createOperation(key:string,v:any):(any,string)
			assert(Schema.operation(v,key))
			calls+=1;local fail=calls==failAt;if fail and not after then return nil,"Unavailable"end
			records.Operation[key]=records.Operation[key]or copy(v);if fail then return nil,"Unavailable"end
			return copy(records.Operation[key]),"Found"
		end
		function store.update(kind:string,key:string,callback:any):(any,string,string?)
			calls+=1;local fail=calls==failAt;if fail and not after then return nil,"Unavailable",nil end
			if not records[kind][key]then return nil,"Unavailable",nil end
			local v=copy(records[kind][key]);local ok,reason=callback(v);if not ok then return nil,"Rejected",reason end
			if kind=="Guild"then assert(Schema.guild(v))elseif kind=="Slot"then assert(Schema.slot(v))else assert(Schema.operation(v,key))end
			records[kind][key]=v;if fail then return nil,"Unavailable",nil end
			return copy(v),"Committed",reason
		end
		return Make(store,M),records,store
	end
	test("player guild leave and kick recover every uncertain durable write",function()
		for _,actor in ipairs({'1','2','3'})do for failAt=1,5 do for _,after in ipairs({false,true})do
			local c,r=fixture(failAt,after)
			eq(c.remove(actor,1,"guild","2",1,"remove"),"Pending")
			eq(c.remove(actor,1,"guild","2",1,"remove"),"Removed")
			eq(c.remove(actor,1,"guild","2",1,"remove"),"Removed")
			eq(r.Slot['2'].state,"Empty");eq(r.Slot['2'].generation,1);eq(r.Guild.guild.members['2'],nil)
			eq(r.Guild.guild.fences['2'],1);eq(Schema.guild(r.Guild.guild),true);eq(Schema.slot(r.Slot['2']),true)
		end end end
	end)
	test("player guild removal validates current role and actor incarnation before revoking",function()
		local c,r=fixture()
		eq(c.remove("2",1,"guild","3",1,"peer"),"Rejected")
		eq(c.remove("1",1,"guild","1",1,"master-leave"),"Rejected")
		assert(M.setRole(r.Guild.guild,"1","2","Officer"))
		eq(c.remove("3",1,"guild","2",1,"officer-peer"),"Rejected")
		eq(c.remove("1",2,"guild","2",1,"stale-actor"),"Rejected")
		eq(M.can(r.Guild.guild,"2","Participate"),true);eq(r.Slot['2'].state,"Active")
	end)
	test("player guild removal operation identity cannot change its actor or target",function()
		local c,r=fixture(2,false);eq(c.remove("1",1,"guild","2",1,"remove"),"Pending")
		eq(c.remove("3",1,"guild","2",1,"remove"),"Rejected")
		eq(c.remove("1",1,"guild","3",1,"remove"),"Rejected")
		eq(c.remove("1",1,"guild","2",1,"remove"),"Removed");eq(M.can(r.Guild.guild,"3","Participate"),true)
	end)
	test("player guild removal completes its written revocation after actor loses privileges",function()
		local c,r=fixture(3,false);eq(c.remove("3",1,"guild","2",1,"remove"),"Pending")
		assert(M.setRole(r.Guild.guild,"1","3","Member"))
		eq(c.remove("3",1,"guild","2",1,"remove"),"Removed");eq(r.Slot['2'].state,"Empty")
	end)
	test("player guild delayed removal never deletes a newer rejoined member",function()
		local c,r,store=fixture();local update=store.update;local injected=false
		store.update=function(kind:string,key:string,callback:any):(any,string,string?)
			local v,s,reason=update(kind,key,callback)
			if kind=="Slot"and s=="Committed"and v.state=="Empty"and not injected then
				injected=true;local g,slot=r.Guild.guild,r.Slot['2'];assert(M.finishRemoval(g,"2",slot))
				assert(M.reserve(slot,"guild","rejoined"));local invite=M.invite(g,"1","2",2,100);assert(invite)
				assert(M.prepareJoin(g,"2",invite.token,slot,3));assert(M.activateSlot(slot,g,"2"));assert(M.activateMember(g,"2",slot))
			end
			return v,s,reason
		end
		eq(c.remove("1",1,"guild","2",1,"remove"),"Removed")
		eq(c.remove("1",1,"guild","2",1,"another-old-request"),"Removed")
		eq(r.Slot['2'].generation,2);eq(r.Guild.guild.members['2'].operationId,"rejoined")
		eq(M.can(r.Guild.guild,"2","Participate"),true);eq(Schema.guild(r.Guild.guild),true)
	end)
	test("player guild removal rejects malformed input before touching storage",function()
		local c=Make({read=function()error("Invalid request reached store")end},M)
		eq(c.remove("02",1,"guild","2",1,"remove"),"Rejected")
		eq(c.remove("1",0,"guild","2",1,"remove"),"Rejected")
		eq(c.remove("1",1,"guild","2",0/0,"remove"),"Rejected")
		eq(c.remove("1",1,"guild","2",2147483648,"remove"),"Rejected")
	end)
end
