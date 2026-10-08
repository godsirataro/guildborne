--!strict
-- Called only on disposable command copies; physical safe-zone checks precede persistence.
return function(content:any,rules:any,expansion:any)
    local S={}
    function S.apply(data:any,action:string,args:any,emit:any):string?
        if content.StatusAllocationAvailable~=true then return "StatusUnavailable" end
        local actor=expansion.actor(data,args.actorId)
        if not actor or not actor.classId then return "ActorNotReady" end
        if data.quests.active then return "FinishYourExpedition" end
        if data.expansion.tower.active then return "LeaveTowerFirst" end
        if actor.condition and actor.condition~="Healthy" then return "HeroUnavailable" end
        for _,job in pairs(data.settlement.jobs) do if table.find(job.members,args.actorId) then return "HeroUnavailable" end end
        if action=="AllocateStatus" then
            if not table.find(rules.Order,args.stat) or type(args.amount)~="number" or args.amount%1~=0 or args.amount<1 or args.amount>100 then return "InvalidAllocation" end
            local points=table.clone(actor.statusAllocations or {});points[args.stat]=(points[args.stat] or 0)+args.amount
            local valid=rules.validate(actor.level,points);if not valid then return "NotEnoughStatusPoints" end
            actor.statusAllocations=points
            emit("status_points_allocated",{actorId=args.actorId,stat=args.stat,amount=args.amount})
        elseif action=="ResetBuildPoints" then
            local build=data.expansion.actors[args.actorId]
            if not next(actor.statusAllocations or {}) and not (build and next(build.skills)) then return "NoPointsToReset" end
            actor.statusAllocations=nil
            if build then build.skills={};build.equipped=nil end
            emit("build_points_reset",{actorId=args.actorId})
        else return "InvalidAction" end
        return nil
    end
    return S
end
