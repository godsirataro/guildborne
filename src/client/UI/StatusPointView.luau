--!strict
local Points=require(game.ReplicatedStorage.Shared.Data.StatusPoints)
local SymbolIcon=require(script.Parent.SymbolIcon)
return function(ui:any)
    local step=1;local confirmation:string?=nil
    local T,card,text,button=ui.T,ui.card,ui.text,ui.button
    local descriptions={STR="Melee attack for Warrior and Knight.",DEX="Archer attack and movement speed for every class.",INT="Magic attack for Mage and Priest.",VIT="Maximum health and defense for every class.",WIS="Healing amount and Guard strength. Does not add mana."}
    return function(data:any,catalog:any,actorId:string,busy:boolean)
        local actor=if actorId=="player" then data.character else data.adventurers[actorId]
        local head=card(ui.scroll,"Status points")
        if not catalog.StatusAllocationAvailable then text(head,"Status allocation is not available in this world.");return end
        if not actor or not actor.classId then text(head,"Select a class in Guild");return end
        local allocation=actor.statusAllocations or {};local valid,available=Points.validate(actor.level,allocation)
        if not valid then text(head,"Status allocation is not available in this world.");return end
        local blocked=busy or data.quests.active~=nil or data.expansion.tower.active~=nil or (actor.condition~=nil and actor.condition~="Healthy")
        for _,job in pairs(data.settlement.jobs) do if table.find(job.members,actorId) then blocked=true end end
        text(head,T("Available AP: {free} / {total}",{free=available,total=Points.budget(actor.level)}),18)
        text(head,"Each character earns 3 AP per level after level 1. Spend or reset near your own Guild Hall outside combat and expeditions.",15)
        text(head,"Maximum 150 per stat. Points above 40 and 80 have smaller effects.",15)
        button(head,T("Points per click: {amount}",{amount=step}),not busy,function() step=if step==1 then 5 elseif step==5 then 10 else 1;confirmation=nil;ui.render() end).Name="StatusStep"
        local before=Points.bonuses(actor.classId,allocation)
        for _,key in ipairs(Points.Order) do
            local frame=card(ui.scroll,key);frame.Name="Status_"..key
            text(frame,descriptions[key],15)
            text(frame,T("Allocated: {raw} · Effective: {effective}",{raw=allocation[key] or 0,effective=string.format("%.1f",Points.effective(allocation[key] or 0))}),16)
            local proposed=table.clone(allocation);proposed[key]=(proposed[key] or 0)+step
            local allowed=Points.validate(actor.level,proposed)
            if allowed then
                local after=Points.bonuses(actor.classId,proposed)
                text(frame,T("Change: HP +{hp} · Attack +{attack} · Defense +{defense}",{hp=after.Health-before.Health,attack=after.Attack-before.Attack,defense=after.Defense-before.Defense}),14)
                text(frame,T("Speed +{speed} · Healing +{heal} · Guard +{guard}%",{speed=string.format("%.2f",after.Speed-before.Speed),heal=after.HealPower-before.HealPower,guard=string.format("%.2f",(after.GuardBonus-before.GuardBonus)*100)}),14)
            end
            local add=button(frame,T("Add {amount} AP to {stat}",{amount=step,stat=key}),allowed and not blocked,function()confirmation=nil;ui.act("AllocateStatus",{actorId=actorId,stat=key,amount=step})end)
            add.Name="Allocate_"..key
            local padding=add:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
            padding.PaddingLeft=UDim.new(0,32);padding.PaddingRight=UDim.new(0,6);padding.Parent=add
            local mark=SymbolIcon(add,"ui.status."..string.lower(key),22)
            if mark then mark.Position=UDim2.new(0,-25,.5,-11) end
        end
        local reset=card(ui.scroll,"Reset build points")
        text(reset,"Return spent SP and AP for this character. Class, level, XP, equipment and cooldowns stay unchanged. Free during offline testing.",15)
        button(reset,if confirmation==actorId then "Confirm free point reset" else "Reset SP and AP",not blocked,function()
            if confirmation==actorId then confirmation=nil;ui.act("ResetBuildPoints",{actorId=actorId}) else confirmation=actorId;ui.render() end
        end).Name="ResetBuildPoints"
    end
end
