--!strict
-- Synthetic view and captured callbacks. No live quest or profile actions.
return function()
    local p=game.Players.LocalPlayer;local draw=require(p.PlayerScripts.Client.UI.SettlementView)
    local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
    local gui=Instance.new("ScreenGui");gui.Name="JournalFilterFixture";gui.Parent=p.PlayerGui
    local host=Instance.new("Frame");host.BackgroundTransparency=1;host.Size=UDim2.fromOffset(240,800);host.Parent=gui
    local catalog: any={JournalOrder={"available","locked","active","ready","claimed"},Journal={}}
    for _,id in ipairs(catalog.JournalOrder) do catalog.Journal[id]={Name=id,Description="Quest in progress",Category="Main",Count=5,Gold=10,XP=5} end
    catalog.Journal.locked.Requires="active";catalog.Journal.ready.Item="herb";catalog.Journal.claimed.Item="timber"
    local data={settlement={journal={active={state="Active",progress=2},ready={state="Active",progress=0},claimed={state="Claimed",progress=5}}},inventory={stacks={herb=5,timber=0}}}
    local checks=0
    local ok,result=pcall(function()
        for _,width in ipairs({240,640}) do for _,lang in ipairs({"en","th"}) do
            host.Size=UDim2.fromOffset(width,800)
            local callbacks: {[Instance]: ()->()}={};local focus: string?=nil;local busy=false
            local render: any=nil
            local function T(s: string,values: any?): string return locale.translate(lang,s,values) end
            local function text(parent: Instance,value: string,size: number?): TextLabel
                local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,0);l.AutomaticSize=Enum.AutomaticSize.Y;l.TextWrapped=true;l.TextSize=size or 18;l.Text=T(value);l.Parent=parent;return l
            end
            local function card(parent: Instance,_title: string): Frame
                local f=Instance.new("Frame");f.Size=UDim2.new(1,0,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
                local layout=Instance.new("UIListLayout");layout.Parent=f;return f
            end
            local function button(parent: Instance,value: string,enabled: boolean,callback: ()->()): TextButton
                local b=Instance.new("TextButton");b.Text=T(value);b.Size=UDim2.new(1,0,0,52);b.TextWrapped=true;b.Active=enabled;b.Selectable=enabled;b.Parent=parent;callbacks[b]=callback;return b
            end
            local function refresh()
                host:ClearAllChildren();table.clear(callbacks);render("Journal",data,catalog,busy)
            end
            render=draw({scroll=host,T=T,text=text,card=card,button=button,act=function()error("No mutations permitted")end,navigate=function()end,render=refresh,isTracked=function()return false end,trackQuest=function()end,journalFocus=function()local id=focus;focus=nil;return id end})
            refresh()
            local function click(name: string)
                local b=assert(host:FindFirstChild(name,true)) :: TextButton;assert(b.Active);callbacks[b]();task.wait(.03)
            end
            local function count(expected: number)
                local n=0;for _,child in ipairs(host:GetChildren()) do if child.Name:sub(1,8)=="Journal_" then n+=1 end end
                assert(n==expected,"Wrong filter count: "..n.." expected "..expected);checks+=1
            end
            count(5)
            local claimed=assert(host:FindFirstChild("Journal_claimed"))
            local progress=claimed:FindFirstChild("JournalProgress") :: TextLabel;assert(progress.Text:find("5/5",1,true),"Claimed item progress regressed")
            assert(not host:FindFirstChild("Claim_claimed",true),"Claimed quest has reward action")
            assert(not (host:FindFirstChild("Accept_locked",true) :: TextButton).Active)
            assert(not (host:FindFirstChild("Claim_active",true) :: TextButton).Active)
            assert((host:FindFirstChild("Claim_ready",true) :: TextButton).Active)
            click("JournalFilter");count(1);assert(host:FindFirstChild("Journal_available"))
            click("JournalFilter");count(2)
            click("JournalFilter");count(1);assert(host:FindFirstChild("Journal_ready"))
            data.inventory.stacks.herb=0;refresh();task.wait(.04);count(0)
            local empty=assert(host:FindFirstChild("EmptyState_no_quests"))
            for _,l in ipairs(empty:GetDescendants()) do if l:IsA("TextLabel") then assert(l.TextBounds.X<=l.AbsoluteSize.X+1 and l.TextBounds.Y<=l.AbsoluteSize.Y+1,"Empty copy clipped") end end
            click("ResetJournalFilter");count(5)
            click("JournalFilter");focus="claimed";refresh();count(5)
            busy=true;refresh();assert(not (host:FindFirstChild("JournalFilter",true) :: TextButton).Active)
            data.inventory.stacks.herb=5
        end end
        return {filterCountChecks=checks,widths={240,640},languages={"en","th"},claimedItemsRemainComplete=true,currentStockUsed=true,focusResetsFilter=true,busyGate=true,emptyReset=true,noProfileWrites=true,synthetic=true}
    end)
    gui:Destroy();assert(ok,tostring(result));return result
end
