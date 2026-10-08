--!strict
-- Display only projected state; payment references never reach this view.
return function(ui: any,data: any,catalog: any,busy: boolean)
    local T,card,text,button=ui.T,ui.card,ui.text,ui.button
    local head=card(ui.scroll,"Guild land")
    button(head,"Back to Guild",not busy,function()ui.navigate("Guild")end)
    button(head,"Visit islands",not busy,function()ui.navigate("Islands")end)
    local mode=data.guildLand and data.guildLand.accessMode or "Private"
    button(head,T("Island access")..": "..T(mode),not busy,function()
        ui.act("SetGuildAccess",{mode=({Private="Friends",Friends="Public",Public="Private"})[mode] or "Private"})
    end).Name="IslandAccessMode"
    text(head,"Changing access returns current visitors to their own islands.",15)
    text(head,"Visitors in this server can use the sign at your island bridge. Discovery across servers is not available yet.",15)
    text(head,"Complete the plot quests, purchase its permanent right, then deliver the required materials.",16)
    local plots=data.guildLand and data.guildLand.plots
    if not plots then text(head,"Land information is unavailable.",16);return end
    local ids={};for id in pairs(plots) do table.insert(ids,id) end;table.sort(ids)
    local labels={QuestLocked="Plot quests required",PurchaseRequired="Purchase required",MaterialsRequired="Materials required",ReadyToOpen="Ready to open",Buildable="Plot opened"}
    for _,id in ipairs(ids) do
        local plot=plots[id];local frame=card(ui.scroll,plot.name);frame.Name="Land_"..id
        text(frame,labels[plot.status] or "Land information is unavailable.",17)
        local quests={};for quest in pairs(plot.quests) do table.insert(quests,quest) end;table.sort(quests)
        for _,quest in ipairs(quests) do
            text(frame,(if plot.quests[quest] then "✓ " else "○ ")..T(catalog.Quests[quest].Name),15)
        end
        local items={};for item in pairs(plot.materials) do table.insert(items,item) end;table.sort(items)
        for _,item in ipairs(items) do
            local need=plot.materials[item];local delivered=plot.delivered[item] or 0;local stock=data.inventory.stacks[item] or 0
            text(frame,T(catalog.Items[item].Name)..": "..delivered.." / "..need.." · "..T("In inventory")..": "..stock,15)
            if plot.status=="MaterialsRequired" then
                local amount=math.min(need-delivered,stock,100)
                button(frame,T("Deliver materials").." · "..T(catalog.Items[item].Name).." ×"..amount,not busy and amount>0,function()
                    ui.act("ContributeGuildPlot",{plotId=id,itemId=item,amount=amount})
                end).Name="Deliver_"..item
            end
        end
        if plot.status=="QuestLocked" then
            button(frame,"Unlock purchase eligibility",plot.questEligible and not busy,function()ui.act("UnlockGuildPlot",{plotId=id})end).Name="UnlockPlot"
        elseif plot.status=="PurchaseRequired" then
            if plot.purchaseAvailable then
                text(frame,"One-time ownership. Materials are still required. Review the Robux price in Roblox before confirming.",15)
                button(frame,"Review plot purchase",not busy,function()ui.act("RequestPermanentPass",{kind="Land",key=id})end).Name="PurchasePlot_"..id
            else text(frame,"Robux purchase is not available yet. No payment has been taken.",15) end
        elseif plot.status=="ReadyToOpen" then
            button(frame,"Open plot",not busy,function()ui.act("OpenGuildPlot",{plotId=id})end).Name="OpenPlot"
        end
        if plot.purchased then text(frame,"Permanent purchase right saved.",15) end
    end
end
