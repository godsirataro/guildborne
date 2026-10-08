--!strict
-- Session-owned encounter state survives region switches. Adapters alone supply confirmed effects.
return function(catalog:any,owner:number,newId:any,respawnSeconds:number)
    assert(type(owner)=="number" and owner==owner)
    assert(respawnSeconds>=1 and respawnSeconds<=600)
    local states:{[string]:any}={};local closed=false
    for region,definition in pairs(catalog.Regions) do
        for _,entry in ipairs(definition.Encounters) do
            assert(states[entry.Asset]==nil,"Duplicate encounter")
            states[entry.Asset]={region=region,generation=1,state="Alive"}
        end
    end
    local function finite(n:any):boolean return type(n)=="number" and n==n and math.abs(n)<1e12 end
    local S={}
    function S.death(id:string,actorOwner:number,members:{string},now:number):(boolean,string)
        local s=states[id]
        if closed or actorOwner~=owner or not s or not finite(now) then return false,"InvalidEncounter" end
        if s.state~="Alive" then return false,"AlreadyRecorded" end
        if #members>6 then return false,"InvalidParty" end
        local copy={};local seen={}
        for _,member in ipairs(members) do
            if type(member)~="string" or #member<1 or #member>96 or seen[member] then return false,"InvalidParty" end
            seen[member]=true;table.insert(copy,member)
        end
        table.sort(copy)
        local token=newId();assert(type(token)=="string" and #token>0 and #token<=96,"Server death token required")
        s.deathId=token;s.members=table.freeze(copy);s.diedAt=now;s.nextAttempt=now;s.attempts=0
        s.state=if #copy==0 then "Unrewarded" else "Pending"
        return true,"OK"
    end
    function S.claim(id:string,now:number):any
        local s=states[id]
        if closed or not s or not finite(now) or s.state~="Pending" or s.inFlight or now<s.nextAttempt then return nil end
        s.inFlight=true;s.attempts+=1
        return table.freeze({encounterId=id,owner=owner,deathId=s.deathId,generation=s.generation,members=s.members,attempt=s.attempts})
    end
    function S.finish(ticket:any,result:string,now:number):boolean
        if closed or not ticket or ticket.owner~=owner or not finite(now) then return false end
        local s=states[ticket.encounterId]
        if not s or not s.inFlight or s.state~="Pending" or s.deathId~=ticket.deathId or s.generation~=ticket.generation or s.attempts~=ticket.attempt then return false end
        if result~="Committed" and result~="Retry" and result~="Rejected" then return false end
        s.inFlight=false
        if result=="Committed" then s.state="Rewarded"
        elseif result=="Rejected" then s.state="Unrewarded"
        else s.nextAttempt=now+math.min(30,2^math.min(s.attempts,5)) end
        return true
    end
    function S.respawn(id:string,now:number):boolean
        local s=states[id]
        if closed or not s or not finite(now) or (s.state~="Rewarded" and s.state~="Unrewarded") or now-s.diedAt<respawnSeconds then return false end
        states[id]={region=s.region,generation=s.generation+1,state="Alive"}
        return true
    end
    function S.read(id:string):any
        local s=states[id];if closed or not s then return nil end
        return table.freeze({region=s.region,generation=s.generation,state=s.state,deathId=s.deathId,attempts=s.attempts,inFlight=s.inFlight==true})
    end
    function S.close()closed=true;table.clear(states)end
    return S
end
