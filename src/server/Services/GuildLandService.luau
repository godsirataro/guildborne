--!strict
-- Runs exclusively on disposable candidates within PlayerDataService.Execute.
return function(rules: any)
    local S={}
    function S.apply(data: any,action: string,args: any,emit: any): string?
        if not data.guildLand then return "LandUnavailable" end
        local code: string
        if action=="SetGuildAccess" then code=rules.setAccess(data.guildLand,args.mode)
        elseif action=="UnlockGuildPlot" then
            code=rules.unlock(data.guildLand,args.plotId,data.quests.firstClears)
        elseif action=="ContributeGuildPlot" then
            code=rules.contribute(data.guildLand,args.plotId,data.inventory.stacks,args.itemId,args.amount)
            if code=="OK" then emit("item_destroyed",{itemId=args.itemId,quantity=args.amount,reason="GuildLand",plotId=args.plotId}) end
        elseif action=="OpenGuildPlot" then code=rules.open(data.guildLand,args.plotId)
        else return "InvalidAction" end
        if code~="OK" then return code end
        emit("guild_land_action",{action=action,plotId=args.plotId});return nil
    end
    return S
end
