--!strict
local Players=game:GetService("Players")
local Colors=require(game.ReplicatedStorage.Shared.Config.Art).UI
local project=require(game.ReplicatedStorage.Shared.Data.IslandDirectoryState)
local identitySummary=require(game.ReplicatedStorage.Shared.Data.GuildIdentitySummary)
local symbol=require(script.Parent.SymbolIcon)
return function(ui:any)
    local query=""
    local mode="All"
    return function(entries:{any},busy:boolean,visitors:{any})
        local head=ui.card(ui.scroll,"Visit islands")
        ui.button(head,"Back to Guild",not busy,function()ui.navigate("Guild")end)
        ui.text(head,"Islands in this server. Use a Guild portal or an island bridge sign to travel.",16)
        ui.text(head,"Friends-only islands check friendship when you request a visit.",15)
        local search=Instance.new("TextBox");search.Name="IslandSearch";search.Size=UDim2.new(1,0,0,48)
        search.BackgroundColor3=Colors.Background;search.TextColor3=Colors.Text;search.PlaceholderColor3=Colors.Muted
        search.Font=Enum.Font.Gotham;search.TextSize=16;search.ClearTextOnFocus=false;search.Text=query
        search.PlaceholderText=ui.T("Search name or user ID");search.Parent=head
        search.FocusLost:Connect(function()query=string.sub(search.Text,1,48);ui.render(true)end)
        local labels={All="All islands",Public="Public islands",Friends="Friends-only islands",Mine="My island"}
        ui.button(head,ui.T("Show islands")..": "..ui.T(labels[mode]),not busy,function()
            mode=({All="Public",Public="Friends",Friends="Mine",Mine="All"})[mode];ui.render(true)
        end).Name="IslandFilter"
        if query~=""or mode~="All"then ui.button(head,"Clear island filters",not busy,function()query="";mode="All";ui.render(true)end).Name="ClearIslandFilters"end
        ui.button(head,"Refresh islands",not busy,function()ui.act("GetState")end).Name="RefreshIslands"
        local guests=ui.card(ui.scroll,"Visitors on my island");guests.Name="IslandVisitors"
        ui.text(guests,"Removed visitors cannot return until you leave this server.",15)
        if #visitors==0 then ui.text(guests,"No visitors on your island.",16) end
        for _,visitor in ipairs(visitors) do
            ui.text(guests,visitor.displayName.." · @"..visitor.name,16)
            ui.button(guests,ui.T("Remove visitor").." · @"..visitor.name,not busy,function()
                ui.act("KickIslandVisitor",{visitorId=visitor.visitorId})
            end).Name="Kick_"..visitor.visitorId
        end
        local rows=project(entries,tostring(Players.LocalPlayer.UserId),query,mode)
        ui.text(head,ui.T("Matching islands")..": "..#rows,15)
        for _,row in ipairs(rows) do
            local entry,own=row.entry,row.own
            local frame=ui.card(ui.scroll,entry.displayName);frame.Name="Island_"..entry.ownerId
            ui.text(frame,"@"..entry.name.." · "..entry.ownerId,14)
            if entry.hallLevel then ui.text(frame,ui.T("Guild Hall").." · Lv"..entry.hallLevel,16)end
            local identity=identitySummary.labels(entry.crestId,entry.mottoId,"en")
            if identity then
                local strip=Instance.new("Frame");strip.Name="IslandIdentity";strip.Size=UDim2.new(1,0,0,72);strip.BackgroundTransparency=1;strip.Parent=frame
                symbol(strip,identity.symbol,48,Colors.Accent)
                local label=Instance.new("TextLabel");label.Name="IdentityText";label.Position=UDim2.fromOffset(58,0);label.Size=UDim2.new(1,-58,1,0)
                label.BackgroundTransparency=1;label.Font=Enum.Font.Gotham;label.TextSize=16;label.TextColor3=Colors.Text;label.TextWrapped=true;label.TextXAlignment=Enum.TextXAlignment.Left;label.Text=ui.T(identity.crest).."\n"..ui.T(identity.motto);label.Parent=strip
            end
            ui.text(frame,ui.T(entry.mode).." · "..entry.visitors.." / "..entry.capacity.." "..ui.T("Visitors"),15)
            if row.full then ui.text(frame,"Island full. Refresh later to check for space.",15)end
            ui.button(frame,if own then "Return to my island"elseif row.full then "Island full"else "Visit island",not busy and not row.full,function()
                local player=Players.LocalPlayer;local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local world=workspace:FindFirstChild("GuildborneWorld");local city=world and world:FindFirstChild("City")
                local portal:BasePart?=nil
                if city then for _,candidate in ipairs(city:GetChildren()) do
                    if candidate:IsA("BasePart") and candidate:GetAttribute("TravelDestination")=="Guild" then portal=candidate;break end
                end end
                if own and root and root:IsA("BasePart") and portal and portal:IsA("BasePart") and (root.Position-portal.Position).Magnitude<=14 then
                    ui.act("TravelZone",{zone="Guild"})
                else ui.act("VisitIsland",{ownerId=entry.ownerId}) end
            end).Name="Visit_"..entry.ownerId
        end
        if #rows==0 then ui.text(head,"No matching islands are available in this server.",16) end
    end
end
