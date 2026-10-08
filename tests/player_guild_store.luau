--!strict
local M=require("../src/server/Systems/PlayerGuildMembership")
local Schema=require("../src/server/Systems/PlayerGuildSchema")
local Make=require("../src/server/Systems/PlayerGuildStore")
local Founder=require("../src/server/Systems/PlayerGuildFounderCoordinator")
local Join=require("../src/server/Systems/PlayerGuildJoinCoordinator")
local Cancel=require("../src/server/Systems/PlayerGuildCancelCoordinator")
local Removal=require("../src/server/Systems/PlayerGuildRemovalCoordinator")
local function copy(t:any):any if type(t)~="table"then return t end;local c={};for k,v in pairs(t)do c[k]=copy(v)end;return c end
return function(test:any,eq:any)
	local function fixture(): (any,any,any,any)
		local records={};local control:any={};local ids={};local counter=0
		local function keyFor(kind:string,key:string):string
			local logical=kind..":"..key
			if not ids[logical]then counter+=1;ids[logical]="test:"..counter end
			return ids[logical]
		end
		local provider={}
		function provider.Get(key:string):any if control.readFailure then error("Read unavailable")end;return copy(records[key])end
		function provider.Update(key:string,transform:any):any
			if control.before then control.before=false;error("Before write")end
			local candidate=transform(copy(records[key]))
			if control.replay then
				local race=control.replay;control.replay=nil;race(records,key)
				candidate=transform(copy(records[key]))
			end
			if candidate==nil then return nil end
			records[key]=copy(candidate)
			if control.after then control.after=false;error("After write")end
			return copy(candidate)
		end
		return Make(provider,keyFor,Schema,M),records,control,keyFor
	end
	test("player guild validated store drives founder join cancellation and removal end to end",function()
		local store,records=fixture();store.ensureSlot("1");store.ensureSlot("2");store.ensureSlot("3")
		eq(Founder(store,M,50).create("1","guild","found"),"Created")
		local token:string?=nil
		store.update("Guild","guild",function(g:any):(boolean,string)local invite=M.invite(g,"1","2",0,100);assert(invite);token=invite.token;return true,"Invited"end)
		eq(Join(store,M).accept("2","guild",token :: string,"join2",1),"Completed")
		eq(Removal(store,M).remove("2",1,"guild","2",1,"leave2"),"Removed")
		store.update("Guild","guild",function(g:any):(boolean,string)local invite=M.invite(g,"1","3",0,100);assert(invite);token=invite.token;return true,"Invited"end)
		eq(Join(store,M).accept("3","guild",token :: string,"join3",101),"NeedsCancellation")
		eq(Cancel(store,M).cancel("3","guild","join3"),"Cancelled")
		local guild,status=store.read("Guild","guild");eq(status,"Found");eq(guild.members['2'],nil);eq(guild.members['3'],nil)
		for _,raw in pairs(records)do
			eq(raw.version,1);eq(raw.revision>=1,true)
			if raw.kind=="Guild"then eq(Schema.guild(raw.data),true)elseif raw.kind=="Slot"then eq(Schema.slot(raw.data),true)else eq(Schema.operation(raw.data,raw.logicalKey),true)end
		end
	end)
	test("player guild store keeps before and after write failures uncertain and retryable",function()
		for _,mode in ipairs({"before","after"})do
			local store,_,control=fixture();control[mode]=true
			local _,state=store.ensureSlot("2");eq(state,"Unavailable")
			local slot,retry=store.ensureSlot("2");eq(retry,"Found");eq(slot.generation,0)
			control[mode]=true
			local _,write=store.update("Slot","2",function(s:any):(boolean,string)return M.reserve(s,"guild","join")end);eq(write,"Unavailable")
			local current,finished=store.update("Slot","2",function(s:any):(boolean,string)return M.reserve(s,"guild","join")end)
			eq(finished,"Committed");eq(current.generation,1)
		end
	end)
	test("player guild store reruns callbacks on current copies and discards stale candidates",function()
		local store,records,control,keyFor=fixture();store.ensureSlot("2")
		local address=keyFor("Slot","2")
		control.replay=function(values:any,key:string)
			assert(M.reserve(values[key].data,"other","winner"));values[key].revision+=1
		end
		local _,status,reason=store.update("Slot","2",function(s:any):(boolean,string)return M.reserve(s,"guild","loser")end)
		eq(status,"Rejected");eq(reason,"MembershipOccupied");eq(records[address].data.guildId,"other")
		eq(records[address].revision,2)
	end)
	test("player guild store rejects invalid mutations without changing persisted records",function()
		local store,records,_,keyFor=fixture();store.ensureSlot("2");local address=keyFor("Slot","2")
		local _,status,reason=store.update("Slot","2",function(s:any):(boolean,string)s.generation=-1;return true,"Bad"end)
		eq(status,"Rejected");eq(reason,"InvalidCandidate");eq(records[address].data.generation,0);eq(records[address].revision,1)
		local value,read=store.read("Slot","2");eq(read,"Found");value.generation=999;eq(records[address].data.generation,0)
		records[address].revision=2147483647
		local _,full=store.update("Slot","2",function()error("Exhausted revision reached callback")end);eq(full,"Rejected")
	end)
	test("player guild store never treats unavailable or corrupted records as missing",function()
		local store,records,control,keyFor=fixture();local _,missing=store.read("Slot","2");eq(missing,"Missing")
		store.ensureSlot("2");control.readFailure=true;local _,failed=store.read("Slot","2");eq(failed,"Unavailable")
		control.readFailure=false;records[keyFor("Slot","2")].data.generation="bad"
		local _,corrupt=store.read("Slot","2");eq(corrupt,"Unavailable")
		local _,rewrite=store.ensureSlot("2");eq(rewrite,"Unavailable");eq(records[keyFor("Slot","2")].data.generation,"bad")
	end)
	test("player guild physical key collisions cannot read or replace another logical record",function()
		local raw:any=nil;local provider={Get=function()return copy(raw)end,Update=function(_key:string,callback:any)local v=callback(copy(raw));if v then raw=copy(v)end;return v end}
		local store=Make(provider,function()return "collision"end,Schema,M)
		local _,created=store.ensureSlot("1");eq(created,"Found")
		local _,read=store.read("Slot","2");eq(read,"Unavailable")
		local _,second=store.ensureSlot("2");eq(second,"Unavailable");eq(raw.logicalKey,"1")
		local _,changed=store.update("Slot","2",function()error("Collision reached callback")end);eq(changed,"Rejected")
	end)
end
