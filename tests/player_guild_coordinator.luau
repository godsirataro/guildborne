--!strict
local M=require("../src/server/Systems/PlayerGuildMembership")
local Make=require("../src/server/Systems/PlayerGuildJoinCoordinator")
local Cancel=require("../src/server/Systems/PlayerGuildCancelCoordinator")
local Schema=require("../src/server/Systems/PlayerGuildSchema")
local function clone(t:any):any local c={};for k,v in pairs(t)do c[k]=if type(v)=="table"then clone(v)else v end;return c end
return function(test:any,eq:any)
	local function fixture(failAt:number?,afterCommit:boolean?):(any,any,any,any)
		local founder=M.newSlot();M.reserve(founder,"guild","found");local g=M.newGuild("guild","1",founder);M.activateSlot(founder,g,"1");M.activateMember(g,"1",founder)
		local invite=M.invite(g,"1","2",0,100);assert(invite)
		local records:any={Slot={['2']=M.newSlot()},Guild={guild=g},Operation={}}
		local calls=0;local failed=false
		local function fault():boolean calls+=1;if not failed and calls==failAt then failed=true;return true end;return false end
		local store={}
		function store.read(kind:string,key:string):(any,string)
			local value=records[kind][key];return if value then clone(value)else nil,if value then "Found"else "Missing"
		end
		function store.createOperation(key:string,value:any):(any,string)
			assert(Schema.operation(value,key))
			local fail=fault();if fail and not afterCommit then return nil,"Unavailable"end
			records.Operation[key]=records.Operation[key]or clone(value)
			if fail then return nil,"Unavailable"end
			return clone(records.Operation[key]),"Found"
		end
		function store.update(kind:string,key:string,callback:any):(any,string,string?)
			local fail=fault();if fail and not afterCommit then return nil,"Unavailable",nil end
			local current=records[kind][key];if not current then return nil,"Unavailable",nil end
			local nextValue=clone(current);local ok,reason=callback(nextValue)
			if not ok then return nil,"Rejected",reason end
			if kind=="Guild"then assert(Schema.guild(nextValue))elseif kind=="Slot"then assert(Schema.slot(nextValue))else assert(Schema.operation(nextValue,key))end
			records[kind][key]=nextValue
			if fail then return nil,"Unavailable",nil end
			return clone(nextValue),"Committed",reason
		end
		return Make(store,M),records,invite,store
	end
	test("player guild join retries every uncertain write without duplicate membership",function()
		for failAt=1,6 do for _,after in ipairs({false,true})do
			local c,records,invite=fixture(failAt,after)
			local first=c.accept("2","guild",invite.token,"join",1);eq(first,"Pending")
			eq(c.accept("2","guild",invite.token,"join",2),"Completed")
			eq(records.Slot['2'].generation,1);eq(records.Guild.guild.members['2'].state,"Active")
			eq(c.accept("2","guild",invite.token,"join",3),"Completed");eq(records.Slot['2'].generation,1)
		end end
	end)
	test("player guild unfinished operation cannot replay after membership was removed",function()
		local c,records,invite=fixture(6,false)
		eq(c.accept("2","guild",invite.token,"join",1),"Pending")
		local g,s=records.Guild.guild,records.Slot['2']
		M.revoke(g,"1","2","kick");M.clearSlot(s,g,"2");M.finishRemoval(g,"2",s)
		eq(c.accept("2","guild",invite.token,"join",2),"Rejected")
		eq(s.generation,1);eq(s.state,"Empty");eq(M.can(g,"2","Participate"),false)
	end)
	test("player guild operation identity cannot be reused with another invitation",function()
		local c,_,invite=fixture(2,false)
		eq(c.accept("2","guild",invite.token,"join",1),"Pending")
		eq(c.accept("2","guild","different","join",2),"Rejected")
		eq(c.accept("2","guild",invite.token,"join",2),"Completed")
	end)
	test("player guild expired invitation retains reservation for explicit safe cancellation",function()
		local c,records,invite=fixture()
		eq(c.accept("2","guild",invite.token,"join",101),"NeedsCancellation")
		eq(records.Slot['2'].state,"Reserved");eq(records.Guild.guild.members['2'],nil)
		eq(M.can(records.Guild.guild,"2","Participate"),false)
	end)
	test("player guild revocation racing join activation never grants canonical authority",function()
		local c,records,invite,store=fixture();local update=store.update;local injected=false
		store.update=function(kind:string,key:string,callback:any):(any,string,string?)
			local value,status,reason=update(kind,key,callback)
			if kind=="Guild"and status=="Committed"and not injected then
				injected=true;assert(M.revoke(records.Guild.guild,"1","2","concurrent-kick"))
			end
			return value,status,reason
		end
		eq(c.accept("2","guild",invite.token,"join",1),"NeedsRecovery")
		eq(records.Guild.guild.members['2'].state,"Revoked");eq(M.can(records.Guild.guild,"2","Participate"),false)
		assert(M.clearSlot(records.Slot['2'],records.Guild.guild,"2"));eq(records.Slot['2'].state,"Empty")
	end)
	test("player guild concurrent cancellation protects a subsequent guild reservation",function()
		local c,records,invite,store=fixture();local update=store.update;local injected=false
		store.update=function(kind:string,key:string,callback:any):(any,string,string?)
			local value,status,reason=update(kind,key,callback)
			if kind=="Guild"and status=="Committed"and not injected then
				injected=true;local g,s=records.Guild.guild,records.Slot['2']
				assert(M.abortJoin(g,"2",s,"cancel"));assert(M.clearSlot(s,g,"2"));assert(M.finishRemoval(g,"2",s))
				assert(M.reserve(s,"other","next"))
			end
			return value,status,reason
		end
		eq(c.accept("2","guild",invite.token,"join",1),"NeedsRecovery")
		eq(records.Slot['2'].guildId,"other");eq(records.Slot['2'].generation,2)
		eq(M.can(records.Guild.guild,"2","Participate"),false)
	end)
	test("player guild invalid join intents are rejected before storage access",function()
		local c=Make({read=function()error("Invalid intent reached storage")end},M)
		for _,uid in ipairs({"0","02","-1","1.5","9007199254740992"})do eq(c.accept(uid,"guild","token","op",1),"Rejected")end
		eq(c.accept("2","guild","","op",1),"Rejected")
		eq(c.accept("2","guild","token",string.rep("x",65),1),"Rejected")
		eq(c.accept("2","guild","token","op",0/0),"Rejected")
	end)
	test("player guild cancellation recovers every write at each unfinished join stage",function()
		for stage=2,6 do for failAt=1,6 do for _,after in ipairs({false,true})do
			local join,records,invite,store=fixture(stage,false)
			eq(join.accept("2","guild",invite.token,"join",1),"Pending")
			local update=store.update;local calls=0
			store.update=function(kind:string,key:string,callback:any):(any,string,string?)
				calls+=1;local fail=calls==failAt
				if fail and not after then return nil,"Unavailable",nil end
				local v,s,r=update(kind,key,callback)
				if fail then return nil,"Unavailable",nil end
				return v,s,r
			end
			local cancel=Cancel(store,M)
			eq(cancel.cancel("2","guild","join"),"Pending")
			eq(cancel.cancel("2","guild","join"),"Cancelled")
			eq(cancel.cancel("2","guild","join"),"Cancelled")
			eq(join.accept("2","guild",invite.token,"join",2),"Cancelled")
			eq(records.Slot['2'].state,"Empty");eq(records.Slot['2'].generation,1)
			eq(records.Guild.guild.members['2'],nil);eq(records.Guild.guild.fences['2'],1)
			eq(Schema.slot(records.Slot['2']),true);eq(Schema.guild(records.Guild.guild),true)
		end end end
	end)
	test("player guild cancellation fences an accept already past the journal read",function()
		local join,records,invite,store=fixture();local update=store.update;local injected=false
		store.update=function(kind:string,key:string,callback:any):(any,string,string?)
			local v,s,r=update(kind,key,callback)
			if kind=="Slot"and s=="Committed"and not injected then
				injected=true;eq(Cancel(store,M).cancel("2","guild","join"),"Cancelled")
			end
			return v,s,r
		end
		eq(join.accept("2","guild",invite.token,"join",1),"NeedsCancellation")
		eq(records.Slot['2'].state,"Empty");eq(M.can(records.Guild.guild,"2","Participate"),false)
		eq(join.accept("2","guild",invite.token,"join",2),"Cancelled")
	end)
	test("player guild cancellation wins against delayed completion of active membership",function()
		local join,records,invite,store=fixture();local update=store.update;local injected=false
		store.update=function(kind:string,key:string,callback:any):(any,string,string?)
			local v,s,r=update(kind,key,callback)
			if kind=="Guild"and s=="Committed"and v.members['2']and v.members['2'].state=="Active"and not injected then
				injected=true;eq(Cancel(store,M).cancel("2","guild","join"),"Cancelled")
			end
			return v,s,r
		end
		eq(join.accept("2","guild",invite.token,"join",1),"Pending")
		eq(records.Operation['2:join'].state,"Cancelled")
		eq(records.Slot['2'].state,"Empty");eq(M.can(records.Guild.guild,"2","Participate"),false)
	end)
	test("player guild old cancellation preserves a newer same-guild membership",function()
		local join,records,invite,store=fixture(4,false)
		eq(join.accept("2","guild",invite.token,"join",1),"Pending")
		local update=store.update;local injected=false
		store.update=function(kind:string,key:string,callback:any):(any,string,string?)
			local v,s,r=update(kind,key,callback)
			if kind=="Slot"and s=="Committed"and v.state=="Empty"and not injected then
				injected=true;local g,slot=records.Guild.guild,records.Slot['2']
				assert(M.finishRemoval(g,"2",slot));assert(M.reserve(slot,"guild","new-join"))
				local fresh=M.invite(g,"1","2",2,100);assert(fresh)
				assert(M.prepareJoin(g,"2",fresh.token,slot,3));assert(M.activateSlot(slot,g,"2"));assert(M.activateMember(g,"2",slot))
			end
			return v,s,r
		end
		eq(Cancel(store,M).cancel("2","guild","join"),"Cancelled")
		eq(records.Slot['2'].generation,2);eq(records.Slot['2'].operationId,"new-join")
		eq(records.Guild.guild.members['2'].operationId,"new-join");eq(M.can(records.Guild.guild,"2","Participate"),true)
		eq(Schema.guild(records.Guild.guild),true)
	end)
	test("player guild completed join cannot be undone by cancellation",function()
		local join,records,invite,store=fixture();eq(join.accept("2","guild",invite.token,"join",1),"Completed")
		local state,reason=Cancel(store,M).cancel("2","guild","join");eq(state,"Rejected");eq(reason,"AlreadyJoined")
		eq(M.can(records.Guild.guild,"2","Participate"),true)
	end)
	test("player guild cancellation handles missing reads and invalid callers without writes",function()
		local bad=Cancel({read=function()error("Invalid request reached storage")end},M)
		for _,u in ipairs({"0","02","-1","9007199254740992"})do eq(bad.cancel(u,"guild","join"),"Rejected")end
		local store={read=function(): (any,string) return nil,"Unavailable"end,update=function()error("Read failure reached write")end}
		eq(Cancel(store,M).cancel("2","guild","join"),"Pending")
		store.read=function(): (any,string)return nil,"Missing"end
		eq(Cancel(store,M).cancel("2","guild","join"),"Rejected")
	end)
end
