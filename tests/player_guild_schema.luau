--!strict
local M=require("../src/server/Systems/PlayerGuildMembership")
local S=require("../src/server/Systems/PlayerGuildSchema")
return function(test:any,eq:any)
	local function founder(): (any,any)
		local slot=M.newSlot();M.reserve(slot,"guild","create");return M.newGuild("guild","1",slot),slot
	end
	test("player guild persisted schema accepts each legitimate founder phase and cancellation",function()
		local g,s=founder();eq(S.slot(s),true);eq(S.guild(g),true)
		M.activateSlot(s,g,"1");eq(S.slot(s),true);eq(S.guild(g),true)
		M.activateMember(g,"1",s);eq(S.guild(g),true)
		M.invite(g,"1","2",10.25,30.5);eq(S.guild(g),true)
		local a,b=founder();M.abortJoin(a,"1",b,"abort");eq(S.guild(a),true)
		M.clearSlot(b,a,"1");eq(S.slot(b),true);M.finishRemoval(a,"1",b);eq(S.guild(a),true)
	end)
	test("player guild persisted schema rejects malformed or contradictory authority",function()
		for _,value in ipairs({-1,1.5,math.huge,0/0,2147483648})do eq(S.slot({state="Empty",generation=value}),false)end
		eq(S.slot({state="Empty",generation=0,guildId="ghost"}),false)
		local g=founder();g.members['1'].role="Owner";eq(S.guild(g),false)
		g=founder();g.fences['1']=2;eq(S.guild(g),false)
		g=founder();g.members['1'].role="Member";eq(S.guild(g),false)
		g=founder();g.abandoned=true;eq(S.guild(g),false)
		g=founder();g.members['1'].state="Revoked";eq(S.guild(g),false)
		g=founder();g.invites.bad={target="02",inviter="1",expiresAt=100};eq(S.guild(g),false)
		g=founder();g.transfer={token="x",from="1",target="999",epoch=1,expiresAt=100};eq(S.guild(g),false)
	end)
	test("player guild schema stays valid across repeated joins leadership changes and removals",function()
		local g,founderSlot=founder();M.activateSlot(founderSlot,g,"1");M.activateMember(g,"1",founderSlot)
		local slots:any={['1']=founderSlot}
		for step=1,240 do
			local uid=tostring(2+(step%12));local slot=slots[uid]or M.newSlot();slots[uid]=slot
			if slot.state=="Empty"then
				local invite=M.invite(g,g.leader,uid,step,60);assert(invite)
				assert(M.reserve(slot,g.id,"join:"..step));assert(M.prepareJoin(g,uid,invite.token,slot,step))
				eq(S.guild(g),true);assert(M.activateSlot(slot,g,uid));assert(M.activateMember(g,uid,slot))
			elseif uid~=g.leader then
				if step%3==0 then
					local offer=M.offerTransfer(g,g.leader,uid,step);assert(offer);assert(M.acceptTransfer(g,uid,offer.token,step))
				else
					assert(M.revoke(g,g.leader,uid,"kick:"..step));eq(S.guild(g),true)
					assert(M.clearSlot(slot,g,uid));assert(M.finishRemoval(g,uid,slot))
				end
			end
			eq(S.guild(g),true)
			for _,s in pairs(slots)do eq(S.slot(s),true)end
		end
	end)
end
