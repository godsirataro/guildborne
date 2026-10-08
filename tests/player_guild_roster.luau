--!strict
local M=require("../src/server/Systems/PlayerGuildMembership")
local R=require("../src/server/Systems/PlayerGuildRoster")(M)
return function(test:any,eq:any)
	test("player guild pending projection exposes only its owner's public phase",function()
		for _,phase in ipairs({"Joining","Creating","Cancelling","Removing"})do
			local op={state=phase,userId="2",actorId="2",targetId="3",id="private-operation",token="private-invite",guildId="private-guild"}
			eq(R.pending(op,"3"),nil);local p=R.pending(op,"2",true);assert(p)
			eq(p.phase,phase);eq(p.state,"Pending");eq(p.needsRecovery,true)
			eq(p.id,nil);eq(p.token,nil);eq(p.targetId,nil);eq(p.guildId,nil)
		end
		for _,phase in ipairs({"Completed","Created","Cancelled","Removed","Unknown"})do eq(R.pending({state=phase,userId="2"},"2"),nil)end
	end)
	local function setup():any
		local s=M.newSlot();M.reserve(s,"guild","found");local g=M.newGuild("guild","1",s);M.activateSlot(s,g,"1");M.activateMember(g,"1",s)
		for _,u in ipairs({"10","2","3"}) do
			local invite=M.invite(g,"1",u,0,100);local slot=M.newSlot();M.reserve(slot,g.id,"join:"..u)
			M.prepareJoin(g,u,invite.token,slot,1);M.activateSlot(slot,g,u);M.activateMember(g,u,slot)
		end
		return g
	end
	test("player guild roster excludes internal records and rejects nonmembers",function()
		local g=setup();g.secret="private";M.invite(g,"1","99",0,100)
		eq(R.project(g,"99",1),nil);local p=R.project(g,"2",1);assert(p)
		eq(p.secret,nil);eq(p.invites,nil);eq(p.fences,nil);eq(p.members[1].operationId,nil)
		eq(p.members[1].userId,"1");eq(p.members[2].userId,"2");eq(p.members[4].userId,"10")
		p.members[1].role="Member";eq(g.members['1'].role,"Master")
		eq(p.capabilities.AssignRoles,false);M.revoke(g,"1","2","kick");eq(R.project(g,"2",1),nil)
	end)
	test("player guild roster transfer consent is visible only to the current recipient",function()
		local g=setup();local offer=M.offerTransfer(g,"1","2",10);assert(offer)
        local function projected(u:string,t:number):any local p=R.project(g,u,t);assert(p);return p end
		eq(projected("3",11).transferOffer,nil);eq(projected("1",11).transferOffer,nil)
		eq(projected("2",11).transferOffer.token,offer.token);eq(projected("2",310).transferOffer,nil)
		M.offerTransfer(g,"1","3",12);eq(projected("2",13).transferOffer,nil)
		M.setRole(g,"1","10","Officer");local p=R.project(g,"10",13)
		eq(p.members[2].userId,"10");eq(p.capabilities.Invite,true);eq(p.capabilities.Command,false)
	end)
end

