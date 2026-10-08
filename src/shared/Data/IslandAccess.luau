--!strict
-- Session-only access ledger. Policy persistence, friendship lookup and teleporting
-- are adapters; this module never accepts client claims about friendship or payment.
return function(config:any)
    local maxVisitors=config.maxVisitors or 8
    local ticketSeconds=config.ticketSeconds or 5
    assert(type(maxVisitors)=="number" and maxVisitors%1==0 and maxVisitors>=1 and maxVisitors<=32)
    assert(type(ticketSeconds)=="number" and ticketSeconds>=1 and ticketSeconds<=15)
    local modes={Private=true,Friends=true,Public=true}
    local owners:{[number]:any}={};local visits:{[number]:any}={};local generation=0
    local pending:{[number]:any}={};local nextTicket=0
    local A={}
    local function id(value:any):boolean return type(value)=="number" and value==value and value%1==0 and value~=0 and math.abs(value)<=9007199254740991 end
    local function revoke(owner:number):{number}
        local removed={}
        for visitor,visit in pairs(visits) do if visit.owner==owner then visits[visitor]=nil;table.insert(removed,visitor) end end
        for visitor,ticket in pairs(pending) do if ticket.owner==owner then pending[visitor]=nil end end
        table.sort(removed);return removed
    end
    local function occupancy(owner:number,except:number):number
        local count=0;for visitor,visit in pairs(visits) do if visit.owner==owner and visitor~=except then count+=1 end end;return count
    end
    local function allowed(visitor:number,owner:number,context:any):(boolean,string)
        local target=owners[owner]
        if not target or not target.ready then return false,"IslandUnavailable" end
        if not context or context.alive~=true then return false,"ActorNotReady" end
        if context.inCombat==true or context.inTower==true then return false,"ReturnToGuild" end
        if target.blocked[visitor] then return false,"VisitBlocked" end
        if visitor~=owner then
            if target.mode=="Private" then return false,"IslandPrivate" end
            if target.mode=="Friends" and context.friend~=true then return false,"FriendsOnly" end
            if occupancy(owner,visitor)>=maxVisitors then return false,"IslandFull" end
        end
        return true,"OK"
    end
    function A.register(owner:number,mode:string?):boolean
        if not id(owner) or owners[owner] or (mode~=nil and not modes[mode]) then return false end
        generation+=1;owners[owner]={mode=mode or "Private",ready=true,generation=generation,blocked={}};return true
    end
    function A.policy(owner:number,mode:string):(boolean,string,{number})
        local target=owners[owner];if not target then return false,"IslandUnavailable",{} end
        if not modes[mode] then return false,"InvalidAccessMode",{} end
        if target.mode==mode then return true,"OK",{} end
        generation+=1;target.mode=mode;target.generation=generation
        -- Reauthorization is explicit after any policy change, including friend lookup.
        return true,"OK",revoke(owner)
    end
    function A.ready(owner:number,ready:boolean):{number}
        local target=owners[owner];if not target or target.ready==ready then return {} end
        generation+=1;target.ready=ready;target.generation=generation
        return if ready then {} else revoke(owner)
    end
    function A.request(visitor:number,owner:number,context:any,now:number):(any?,string)
        if not id(visitor) or not id(owner) or type(now)~="number" or now~=now or math.abs(now)==math.huge then return nil,"InvalidRequest" end
        if not context or context.nearPortal~=true then return nil,"VisitStation" end
        local ok,reason=allowed(visitor,owner,context);if not ok then return nil,reason end
        nextTicket+=1
        local ticket={serial=nextTicket,visitor=visitor,owner=owner,generation=owners[owner].generation,expires=now+ticketSeconds}
        pending[visitor]=ticket
        -- Callers receive a copy; mutations cannot alter the retained authorization.
        return table.clone(ticket),"OK"
    end
    function A.commit(ticket:any,context:any,now:number):(boolean,string)
        if type(ticket)~="table" or not id(ticket.visitor) then return false,"InvalidVisitTicket" end
        local retained=pending[ticket.visitor]
        if not retained or retained.serial~=ticket.serial or retained.owner~=ticket.owner or retained.generation~=ticket.generation or retained.expires~=ticket.expires then return false,"InvalidVisitTicket" end
        pending[ticket.visitor]=nil
        if type(now)~="number" or now~=now or now>retained.expires or now<retained.expires-ticketSeconds then return false,"VisitExpired" end
        local target=owners[ticket.owner]
        if not target or not target.ready or target.generation~=ticket.generation then return false,"IslandChanged" end
        if not context or context.nearPortal~=true or context.destinationClear~=true then return false,"TravelUnavailable" end
        local ok,reason=allowed(ticket.visitor,ticket.owner,context);if not ok then return false,reason end
        if ticket.visitor==ticket.owner then visits[ticket.visitor]=nil
        else visits[ticket.visitor]={owner=ticket.owner,generation=target.generation} end
        return true,"OK"
    end
    function A.leave(visitor:number) visits[visitor]=nil;pending[visitor]=nil end
    function A.kick(owner:number,visitor:number):(boolean,string)
        local target=owners[owner];local visit=visits[visitor]
        if not target or not visit or visit.owner~=owner then return false,"VisitorNotPresent" end
        target.blocked[visitor]=true;visits[visitor]=nil;pending[visitor]=nil;return true,"OK"
    end
    function A.remove(owner:number):{number}
        local removed=revoke(owner);owners[owner]=nil;A.leave(owner);return removed
    end
    function A.contains(visitor:number,owner:number):boolean
        local target=owners[owner];if not target or not target.ready then return false end
        if visitor==owner then return true end
        local visit=visits[visitor]
        return visit~=nil and visit.owner==owner and visit.generation==target.generation and not target.blocked[visitor]
    end
    function A.describe(owner:number):any?
        local target=owners[owner];if not target then return nil end
        return {mode=target.mode,ready=target.ready,visitors=occupancy(owner,owner),capacity=maxVisitors}
    end
    return A
end
