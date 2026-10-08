--!strict
local M=require("../src/server/Systems/PlayerGuildMembership")
local Make=require("../src/server/Systems/PlayerGuildFounderCoordinator")
local Schema=require("../src/server/Systems/PlayerGuildSchema")
local function copy(t:any):any local c={};for k,v in pairs(t)do c[k]=if type(v)=="table"then copy(v)else v end;return c end
return function(test:any,eq:any)
	local function fixture(failAt:number?,after:boolean?):(any,any,any)
		local records:any={Slot={['1']=M.newSlot(),['2']=M.newSlot()},Guild={},Operation={}}
		local calls=0;local store={}
		function store.read(kind:string,key:string):(any,string)
			local v=records[kind][key];return if v then copy(v)else nil,if v then "Found"else "Missing"
		end
		local function create(kind:string,key:string,v:any):(any,string)
			if kind=="Guild"then assert(Schema.guild(v))else assert(Schema.operation(v,key))end
			calls+=1;local fail=calls==failAt;if fail and not after then return nil,"Unavailable"end
			records[kind][key]=records[kind][key]or copy(v);if fail then return nil,"Unavailable"end
			return copy(records[kind][key]),"Found"
		end
		function store.createOperation(key:string,v:any):(any,string)return create("Operation",key,v)end
		function store.createGuild(key:string,v:any):(any,string)return create("Guild",key,v)end
		function store.update(kind:string,key:string,callback:any):(any,string,string?)
			calls+=1;local fail=calls==failAt;if fail and not after then return nil,"Unavailable",nil end
			if not records[kind][key]then return nil,"Unavailable",nil end
			local v=copy(records[kind][key]);local ok,reason=callback(v);if not ok then return nil,"Rejected",reason end
			if kind=="Guild"then assert(Schema.guild(v))elseif kind=="Slot"then assert(Schema.slot(v))else assert(Schema.operation(v,key))end
			records[kind][key]=v;if fail then return nil,"Unavailable",nil end
			return copy(v),"Committed",reason
		end
		return Make(store,M,50),records,store
	end
	test("player guild creation retries all six writes without duplicate guilds or slots",function()
		for failAt=1,6 do for _,after in ipairs({false,true})do
			local c,r=fixture(failAt,after);eq(c.create("1","guild","found"),"Pending")
			eq(c.create("1","guild","found"),"Created");eq(c.create("1","guild","found"),"Created")
			eq(r.Slot['1'].generation,1);eq(r.Guild.guild.leader,"1");eq(M.can(r.Guild.guild,"1","AssignRoles"),true)
			eq(Schema.guild(r.Guild.guild),true);eq(Schema.slot(r.Slot['1']),true)
			local count=0;for _ in pairs(r.Guild)do count+=1 end;eq(count,1)
		end end
	end)
	test("player guild creation cannot overwrite another founder at the same guild key",function()
		local c,r=fixture();eq(c.create("1","guild","found"),"Created")
		eq(c.create("2","guild","found2"),"NeedsRecovery")
		eq(r.Guild.guild.leader,"1");eq(r.Guild.guild.members['2'],nil)
		eq(r.Slot['2'].state,"Reserved");eq(M.can(r.Guild.guild,"2","Participate"),false)
	end)
	test("player guild creation journal pins identity and rejects parallel second founding",function()
		local c,r=fixture(3,false);eq(c.create("1","guild","found"),"Pending")
		eq(c.create("1","other","found"),"Rejected");eq(c.create("1","other","second"),"Rejected")
		eq(c.create("1","guild","found"),"Created");eq(r.Guild.other,nil)
	end)
	test("player guild delayed founder replay cannot steal a newer membership reservation",function()
		local c,r=fixture(6,false);eq(c.create("1","guild","found"),"Pending")
		local g,slot=r.Guild.guild,r.Slot['2'];assert(M.reserve(slot,"guild","join2"))
		local invite=M.invite(g,"1","2",0,100);assert(invite);assert(M.prepareJoin(g,"2",invite.token,slot,1))
		assert(M.activateSlot(slot,g,"2"));assert(M.activateMember(g,"2",slot))
		local offer=M.offerTransfer(g,"1","2",2);assert(offer);assert(M.acceptTransfer(g,"2",offer.token,3))
		assert(M.revoke(g,"1","1","leave"));assert(M.clearSlot(r.Slot['1'],g,"1"));assert(M.finishRemoval(g,"1",r.Slot['1']))
		assert(M.reserve(r.Slot['1'],"other","new"))
		eq(c.create("1","guild","found"),"NeedsRecovery");eq(r.Slot['1'].guildId,"other");eq(g.leader,"2")
	end)
	test("player guild immutable origin survives legitimate leadership transfer during finalization",function()
		local c,r=fixture(6,false);eq(c.create("1","guild","found"),"Pending")
		local g,slot=r.Guild.guild,r.Slot['2'];assert(M.reserve(slot,"guild","join2"))
		local invite=M.invite(g,"1","2",0,100);assert(invite);assert(M.prepareJoin(g,"2",invite.token,slot,1))
		assert(M.activateSlot(slot,g,"2"));assert(M.activateMember(g,"2",slot))
		local offer=M.offerTransfer(g,"1","2",2);assert(offer);assert(M.acceptTransfer(g,"2",offer.token,3))
		eq(c.create("1","guild","found"),"Created");eq(r.Guild.guild.leader,"2");eq(r.Guild.guild.members['1'].role,"Officer")
		eq(Schema.guild(r.Guild.guild),true)
	end)
	test("player guild creation schema rejects malformed origin and generation fences safely",function()
		local c,r=fixture();eq(c.create("1","guild","found"),"Created")
		local g=copy(r.Guild.guild);g.creation.generation=2;eq(Schema.guild(g),false)
		g=copy(r.Guild.guild);g.fences['1']='bad';eq(Schema.guild(g),false)
		g=copy(r.Guild.guild);g.creation.founder='02';eq(Schema.guild(g),false)
		local bad=Make({read=function()error("Invalid input reached storage")end},M,50)
		eq(bad.create("0","guild","op"),"Rejected");eq(bad.create("1","guild",string.rep("x",65)),"Rejected")
	end)
	test("player guild generations and counters stop before leaving their persisted range",function()
		local slot=M.newSlot();slot.generation=2147483647
		eq(M.reserve(slot,"guild","op"),false);eq(slot.state,"Empty");eq(slot.generation,2147483647)
		local c,r=fixture();eq(c.create("1","guild","found"),"Created");local g=r.Guild.guild
		local exhausted,records=fixture();records.Slot['1'].generation=2147483647
		eq(exhausted.create("1","guild","found"),"Rejected");eq(next(records.Operation),nil)
		g.nextInvite=2147483647;eq(M.invite(g,"1","2",0,100),nil);eq(g.nextInvite,2147483647)
		g.nextInvite=1;local memberSlot=r.Slot['2'];assert(M.reserve(memberSlot,"guild","join2"))
		local invite=M.invite(g,"1","2",0,100);assert(invite);assert(M.prepareJoin(g,"2",invite.token,memberSlot,1))
		assert(M.activateSlot(memberSlot,g,"2"));assert(M.activateMember(g,"2",memberSlot))
		g.nextTransfer=2147483647;eq(M.offerTransfer(g,"1","2",1),nil);eq(g.nextTransfer,2147483647)
		g.nextTransfer=1;g.leaderEpoch=2147483647;eq(M.offerTransfer(g,"1","2",1),nil)
		g.transfer={token="old",from="1",target="2",epoch=2147483647,expiresAt=100}
		eq(M.acceptTransfer(g,"2","old",2),false);eq(g.leader,"1");eq(g.leaderEpoch,2147483647)
		eq(Schema.guild(g),true)
	end)
end
