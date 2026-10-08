--!strict
-- One bounded reward slot per encounter. No client action dispatch or revision rebasing after uncertainty.
return function(data:any,userId:number,rewards:any,util:any):any
    local slots:{[string]:any}={}
    return function(ticket:any):(string,string)
        if type(ticket)~="table" or ticket.owner~=userId or not rewards[ticket.encounterId]
            or type(ticket.deathId)~="string" or #ticket.deathId<1 or #ticket.deathId>96
            or not util.integer(ticket.generation,1,1000000000) or type(ticket.members)~="table" or #ticket.members<1 or #ticket.members>6 then return "Rejected","InvalidTicket" end
        local s=data.Sessions[userId]
        if not s or s.closing then return "Retry","ProfileNotReady" end
        local slot=slots[ticket.encounterId]
        if slot and slot.deathId~=ticket.deathId then
            if ticket.generation<=slot.generation or not slot.outcome then return "Rejected","DeathConflict" end
            slot=nil
        end
        if not slot then
            slot={deathId=ticket.deathId,generation=ticket.generation,members=util.copy(ticket.members),epoch=s.epoch,token=s.token}
            slots[ticket.encounterId]=slot
        end
        if slot.generation~=ticket.generation or not util.equal(slot.members,ticket.members) then return "Rejected","DeathConflict" end
        if slot.outcome then return slot.outcome,slot.code end
        if slot.epoch~=s.epoch or slot.token~=s.token then slot.outcome="Rejected";slot.code="SessionChanged";return slot.outcome,slot.code end
        if s.busy then return "Retry","Busy" end
        if s.state=="Degraded" then
            local ok=pcall(data.Refresh,userId)
            if not ok then return "Retry","RefreshUnavailable" end
            s=data.Sessions[userId]
            if not s or s.epoch~=slot.epoch or s.token~=slot.token then return "Rejected","SessionChanged" end
        end
        if s.state~="Active" or s.busy or s.closing then return "Retry",s.state end
        if not slot.command then slot.command={version=1,requestId="combat:"..ticket.deathId,action="CombatReward",revision=s.record.revision,args={}} end
        local ok,code=pcall(data.CommitCombat,userId,slot.command,slot.members,ticket.encounterId)
        if not ok then slot.uncertain=true;return "Retry","CommitUnavailable" end
        if code=="OK" or code=="AlreadyCommitted" then slot.outcome="Committed";slot.code=code;return slot.outcome,code end
        if code=="SavePending" then slot.uncertain=true;return "Retry",code end
        if code=="Busy" or code=="AuditBacklog" or code=="LeaseExpiring" or code=="StaleRevision" then
            -- These preflight rejections wrote nothing. Only an unsubmitted candidate may refresh revision.
            if not slot.uncertain then slot.command=nil end
            if code=="AuditBacklog" then pcall(data.FlushAudit,userId) end
            return "Retry",code
        end
        if slot.uncertain then return "Retry",code end
        slot.outcome="Rejected";slot.code=code;return slot.outcome,code
    end
end
