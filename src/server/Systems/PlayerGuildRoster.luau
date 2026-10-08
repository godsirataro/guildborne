--!strict
-- Server projection only. Display names must be resolved/filtered separately.
return function(Membership:any)
local Roster={}
local order={Master=1,Officer=2,Commander=3,Member=4}
-- Called only with a validated server journal owned by the authenticated viewer.
-- Exposes no operation ID, invitation token, target identity or canonical proof.
function Roster.pending(operation:any,viewer:string,needsRecovery:boolean?):any?
	if type(operation)~="table"then return nil end
	local phase=operation.state
	if phase=="Removing"then
		if operation.actorId~=viewer then return nil end
	elseif phase=="Joining"or phase=="Creating"or phase=="Cancelling"then
		if operation.userId~=viewer then return nil end
	else return nil end
	return {state="Pending",phase=phase,needsRecovery=needsRecovery==true}
end
function Roster.project(g:any,viewer:string,now:number):any?
	if not Membership.can(g,viewer,"View") then return nil end
	local rows={}
	for userId,member in pairs(g.members) do
		if member.state=="Active" then
			table.insert(rows,{userId=userId,role=member.role,isSelf=userId==viewer,generation=member.generation})
		end
	end
	table.sort(rows,function(a:any,b:any):boolean
		if order[a.role]~=order[b.role] then return order[a.role]<order[b.role] end
		return tonumber(a.userId)<tonumber(b.userId)
	end)
	local capabilities={}
	for _,name in ipairs({"Invite","Command","AssignRoles","Transfer","Participate"}) do
		capabilities[name]=Membership.can(g,viewer,name)
	end
	local result:any={guildId=g.id,leaderId=g.leader,capacity=g.capacity,members=rows,capabilities=capabilities}
	local offer=g.transfer
	if offer and offer.target==viewer and offer.epoch==g.leaderEpoch and offer.from==g.leader and now<offer.expiresAt then
		result.transferOffer={token=offer.token,fromUserId=offer.from,expiresAt=offer.expiresAt}
	end
	return result
end
return Roster
end
