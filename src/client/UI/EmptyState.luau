--!strict
local Colors=require(game.ReplicatedStorage.Shared.Config.Art).UI
local Symbol=require(script.Parent.SymbolIcon)
local copy: {[string]: {string}}={
    empty_inventory={"Your equipment collection starts here","Complete expeditions for equipment, or open the equipment shop above."},
    empty_party={"No companions selected","Select owned adventurers below, then save your party. Recruit Rowan for free if you are starting out."},
    no_quests={"No quests here yet","Choose another category or speak with the City Herald for your next task."},
    no_market_orders={"No market orders","Browse materials to review prices. Orders you create will appear here."},
    no_search_results={"Nothing matched","Clear your search or change the filters to see more results."},
    guild_not_joined={"No player guild joined","Your Personal Guild remains available. Player Guild membership is a separate feature."},
    content_locked={"This path is locked","Complete the requirements shown for this activity to unlock it."},
    offline_unavailable={"Market connection unavailable","Refresh to check again. If an order was submitted, review My Orders before submitting it again."},
}
return function(parent: Instance,key: string,T: (string)->string): Frame
    local words=assert(copy[key],"Unknown empty-state key")
    local frame=Instance.new("Frame");frame.Name="EmptyState_"..key;frame.Size=UDim2.new(1,-6,0,0);frame.AutomaticSize=Enum.AutomaticSize.Y
    frame.BackgroundColor3=Colors.Card;frame.BorderSizePixel=0;frame.Parent=parent
    local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.PaddingRight=UDim.new(0,12);pad.PaddingTop=UDim.new(0,12);pad.PaddingBottom=UDim.new(0,12);pad.Parent=frame
    local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=frame
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=frame
    local iconRow=Instance.new("Frame");iconRow.Name="IconRow";iconRow.BackgroundTransparency=1;iconRow.Size=UDim2.new(1,0,0,40);iconRow.Parent=frame
    Symbol(iconRow,"ui.empty_states."..key,36,Colors.Accent)
    for i,value in ipairs(words) do
        local label=Instance.new("TextLabel");label.Name=if i==1 then "Heading" else "Detail";label.LayoutOrder=i;label.BackgroundTransparency=1
        label.Size=UDim2.new(1,0,0,0);label.AutomaticSize=Enum.AutomaticSize.Y;label.TextWrapped=true;label.TextXAlignment=Enum.TextXAlignment.Left;label.TextYAlignment=Enum.TextYAlignment.Top
        label.Font=if i==1 then Enum.Font.GothamBold else Enum.Font.Gotham;label.TextSize=if i==1 then 18 else 15;label.TextColor3=if i==1 then Colors.Text else Colors.Muted;label.Text=T(value);label.Parent=frame
    end
    return frame
end
