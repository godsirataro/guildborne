--!strict
local Players=game:GetService("Players")
local Replicated=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local Locale=require(Replicated.Shared.Config.Localization)
local Colors=require(Replicated.Shared.Config.Art).UI
local RequestWindow=require(Replicated.Shared.Data.RequestWindow)
local EmptyState=require(script.Parent.EmptyState)
return function()
	local remotes=Replicated:WaitForChild("GuildborneRemotes")
	local remote=remotes:WaitForChild("Market") :: RemoteEvent
	local gui=Instance.new("ScreenGui");gui.Name="GuildborneMarket";gui.ResetOnSpawn=false;gui.DisplayOrder=30;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=Players.LocalPlayer.PlayerGui
	local panel=Instance.new("Frame");panel.Name="Exchange";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.new(1,-16,1,-16);panel.BackgroundColor3=Colors.Background;panel.Visible=false;panel.Parent=gui
	require(script.Parent.MenuRouter).register("Market",panel)
	local size=Instance.new("UISizeConstraint");size.MaxSize=Vector2.new(960,820);size.Parent=panel
	local corner=Instance.new("UICorner");corner.Parent=panel
	local title=Instance.new("TextLabel");title.Size=UDim2.new(1,-62,0,52);title.Position=UDim2.fromOffset(12,0);title.BackgroundTransparency=1;title.Font=Enum.Font.GothamBold;title.TextSize=20;title.TextColor3=Colors.Accent;title.TextXAlignment=Enum.TextXAlignment.Left;title.TextWrapped=true;title.Parent=panel
	local close=Instance.new("TextButton");close.Name="Close";close.Text="×";close.TextSize=28;close.Size=UDim2.fromOffset(48,48);close.Position=UDim2.new(1,-52,0,2);close.BackgroundColor3=Colors.Button;close.TextColor3=Colors.Text;close.Parent=panel;close.Activated:Connect(function() panel.Visible=false end)
	local nav=Instance.new("Frame");nav.Size=UDim2.new(1,-16,0,52);nav.Position=UDim2.fromOffset(8,54);nav.BackgroundTransparency=1;nav.Parent=panel
	local body=Instance.new("ScrollingFrame");body.Name="Content";body.Position=UDim2.fromOffset(10,114);body.Size=UDim2.new(1,-20,1,-124);body.BackgroundTransparency=1;body.BorderSizePixel=0;body.ScrollBarThickness=5;body.AutomaticCanvasSize=Enum.AutomaticSize.Y;body.CanvasSize=UDim2.new();body.Parent=panel
	local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,9);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=body
	local language="en";local page="Browse";local item="iron_ore";local period="1D";local snapshot: any=nil
	local query="";local notice="";local request=RequestWindow.new();local timedOut=false;local snapshotContext: string?=nil;local entry: any=nil;local confirmation: any=nil;local advanced=false
	local function context(): string return item..":"..period..":"..page end
	local render: any;local send: any
	local function T(key: string): string
  local labels={BUY="Buy",SELL="Sell",ACTIVE="Open",PARTIALLY_FILLED="Partially filled",FILLED="Completed",CANCELLED="Cancelled",EXPIRED="Expired",SELF_TRADE_CANCELLED="Self-trade prevented",PENDING="Pending collection",CLAIMED="Collected",MarketBusy="Market is busy. Wait briefly and try again.",MarketCapacity="Market capacity temporarily reached. Cancellation and collection remain available.",MarketReadOnly="Market is read-only. New orders are temporarily disabled.",MarketPaused="Market is paused. Your assets remain recorded.",EpochClosing="This market round is closing. Collect pending settlements and refresh later.",EpochExpired="The market round changed. Refresh before confirming."}
  return if language=="en" then labels[key] or key else Locale.translate(language,key)
 end
	local function label(value: string,height: number?): TextLabel
		local l=Instance.new("TextLabel");l.Size=UDim2.new(1,-6,0,height or 40);l.BackgroundTransparency=1;l.TextColor3=Colors.Text;l.TextSize=16;l.Font=Enum.Font.Gotham;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Text=value;l.Parent=body;return l
	end
	local function button(name: string,text: string,callback: any,parent: Instance?): TextButton
		local b=Instance.new("TextButton");b.Name=name;b.Size=UDim2.new(1,-6,0,48);b.BackgroundColor3=Colors.Button;b.TextColor3=Colors.Text;b.Font=Enum.Font.GothamMedium;b.TextSize=16;b.TextWrapped=true;b.Text=T(text);b.Parent=parent or body
		b.Active=not request.pending;b.Selectable=b.Active;b.AutoButtonColor=b.Active
		local round=Instance.new("UICorner");round.Parent=b
		b.Activated:Connect(function() if not request.pending then callback() end end);return b
	end
	local function input(name: string,value: string,callback: any)
		local box=Instance.new("TextBox");box.Name=name;box.Size=UDim2.new(1,-6,0,48);box.BackgroundColor3=Colors.Card;box.TextColor3=Colors.Text;box.TextSize=18;box.Font=Enum.Font.Gotham;box.Text=value;box.ClearTextOnFocus=false;box.Parent=body
		box.TextEditable=not request.pending
		if name=="Search" then box.PlaceholderText=T("Search by name or category");box.PlaceholderColor3=Colors.Muted end
		box.FocusLost:Connect(function() callback(box.Text) end);return box
	end
	local function name(id: string): string
		for _,d in ipairs(snapshot and snapshot.catalog or {}) do if d.id==id then return T(d.name) end end
		return id
	end
	local function number(v: any): string return if v~=nil then tostring(v) else "—" end
	local function field(key: string,v: any) label(T(key)..": "..number(v),32) end
	local function chart(candles: any)
		label(T("Price history").." · "..period,30)
		local frame=Instance.new("Frame");frame.Name="PriceChart";frame.Size=UDim2.new(1,-6,0,130);frame.BackgroundColor3=Colors.Card;frame.ClipsDescendants=true;frame.Parent=body
		if #candles==0 then
			local empty=Instance.new("TextLabel");empty.Size=UDim2.fromScale(1,1);empty.BackgroundTransparency=1;empty.Text=T("No recent trade");empty.TextColor3=Colors.Muted;empty.TextSize=16;empty.Parent=frame
		else
			local low,high=math.huge,0;for _,c in ipairs(candles) do low=math.min(low,c.low);high=math.max(high,c.high) end
			local width=math.max(1,high-low)
   for n,value in ipairs({tostring(high).." Gold",tostring(low).." Gold"}) do
    local axis=Instance.new("TextLabel");axis.Name="PriceAxis";axis.Size=UDim2.fromOffset(120,18);axis.Position=UDim2.fromOffset(6,if n==1 then 2 else 108);axis.BackgroundTransparency=1;axis.TextColor3=Colors.Muted;axis.TextXAlignment=Enum.TextXAlignment.Left;axis.TextSize=12;axis.Font=Enum.Font.Gotham;axis.Text=value;axis.Parent=frame
   end
			local windows={ ["1H"]=3600,["6H"]=21600,["1D"]=86400,["7D"]=604800,["30D"]=2592000 }
			local span=windows[period] or 86400
			for _,c in ipairs(candles) do
				local point=Instance.new("Frame");point.Name="TradeCandle";point.AnchorPoint=Vector2.new(.5,.5);point.Size=UDim2.fromOffset(5,math.max(4,100*(c.high-c.low)/width));point.Position=UDim2.new(math.clamp((c.at-(snapshot.view.asOf-span))/span,.02,.98),0,0,114-100*((c.high+c.low)/2-low)/width);point.BackgroundColor3=Colors.Accent;point.BorderSizePixel=0;point.Parent=frame
			end
		end
		local row=Instance.new("Frame");row.Size=UDim2.new(1,-6,0,48);row.BackgroundTransparency=1;row.Parent=body
		for n,p in ipairs({"1H","6H","1D","7D","30D"}) do local b=button(p,p,function() period=p;send("Read") end,row);b.Size=UDim2.new(.2,-4,1,0);b.Position=UDim2.fromScale((n-1)*.2,0) end
	end
	send=function(action: string,order: any?,orderId: string?)
		local requestId=Http:GenerateGUID(false)
		if not RequestWindow.begin(request,requestId,context()) then return end;timedOut=false;notice=T("Loading market")
		remote:FireServer({requestId=requestId,action=action,itemId=item,period=period,order=order,orderId=orderId,epoch=if snapshot then snapshot.view.epoch else nil})
		task.delay(12,function() if gui.Parent and RequestWindow.timeout(request,requestId) then timedOut=true;notice=T("Market unavailable. Your guild is safe. Refresh to recover.");render() end end)
		render()
	end
	local function begin(side: string,kind: string)
		entry={side=side,kind=kind,quantity=1,price=if side=="BUY" then snapshot.view.bestAsk or snapshot.view.reference.value else snapshot.view.bestBid or snapshot.view.reference.value}
		confirmation=nil;render()
	end
	render=function()
		for _,child in ipairs(body:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
		title.Text=T("Guildborne Exchange")
		for _,b in ipairs(nav:GetChildren()) do if b:IsA("TextButton") then b.Text=T(b.Name);b.Active=not request.pending;b.Selectable=b.Active;b.AutoButtonColor=b.Active;b.TextColor3=if b.Active then Colors.Text else Colors.Muted end end
		if notice~="" then label(notice,52) end
		if timedOut then EmptyState(body,"offline_unavailable",T) end
		if not snapshot or snapshotContext~=context() then
			if not request.pending and not timedOut then EmptyState(body,"offline_unavailable",T) end
			button("Retry","Refresh",function() send(if page=="My Orders" or page=="History" then "Portfolio" else "Read") end);return
		end
		local v=snapshot.view
		if v.health=="READ_ONLY" then label(T("MarketReadOnly"),52) elseif v.health=="PAUSED" then label(T("MarketPaused"),52) elseif v.phase and v.phase~="ACTIVE" then label(T("EpochClosing"),52) end
		label(T("Gold")..": "..snapshot.gold.."   ·   "..name(item)..": "..snapshot.owned,34)
		if confirmation then
			local o=confirmation;label(T("Review order").." · "..name(item),42)
			field("Quantity",o.quantity);field("Price",o.price);field("Estimated total",o.price*o.quantity)
			local fee=math.ceil(o.price*o.quantity*snapshot.feeBps/10000)
			if o.side=="SELL" then field("Estimated fee",fee);field("Minimum proceeds if fully filled",o.price*o.quantity-fee) else field("Maximum cost",o.price*o.quantity) end
			if o.kind=="MARKET" then
				local remaining=o.quantity;local quantity,gross=0,0
				for _,level in ipairs(if o.side=="BUY" then v.asks else v.bids) do
					if (o.side=="BUY" and level.price<=o.price) or (o.side=="SELL" and level.price>=o.price) then local q=math.min(remaining,level.quantity);quantity+=q;gross+=q*level.price;remaining-=q end
				end
				field("Estimated quantity",quantity);field("Average price",if quantity>0 then math.floor(gross/quantity*100)/100 else nil)
				label(T("Partial fills are possible. Unfilled quantity is cancelled. Price protection is enforced per unit."),72)
			end
			label(T("Gold and game items only. Seller fees round up cumulatively."),54)
			button("Confirm","Confirm order",function() confirmation=nil;entry=nil;send("Create",o) end)
			button("Back","Back",function() confirmation=nil;render() end);return
		end
		if entry then
			label(T(if entry.side=="BUY" then "Buy" else "Sell").." · "..name(item).." · "..T(if entry.kind=="MARKET" then "Immediate order" else "Limit order"))
			label(T("Quantity"),26);input("Quantity",tostring(entry.quantity),function(s) entry.quantity=tonumber(s) end)
			label(T(if entry.kind=="LIMIT" then "Price" elseif entry.side=="BUY" then "Maximum unit price" else "Minimum unit price"),30)
			input("Price",tostring(entry.price),function(s) entry.price=tonumber(s) end)
			button("Review","Review order",function()
				if not entry.price or not entry.quantity or entry.price<1 or entry.quantity<1 then notice=T("Enter a valid price and quantity.");render();return end
				confirmation={itemId=item,side=entry.side,kind=entry.kind,price=entry.price,quantity=entry.quantity};render()
			end)
			button("Back","Back",function() entry=nil;render() end);return
		end
		if page=="Browse" or page=="Search" then
			input("Search",query,function(s) query=s;render() end)
			local found=0
			for _,d in ipairs(snapshot.catalog) do
				if query=="" or string.find(string.lower(T(d.name).." "..d.name.." "..Locale.translate("th",d.name).." "..T(d.category)),string.lower(query),1,true) then
					found+=1
					button(d.id,"◆  "..T(d.name).." · "..T(d.category),function() item=d.id;page="Detail";send("Read") end)
				end
			end
			if found==0 then EmptyState(body,"no_search_results",T);button("ClearSearch","Clear search",function() query="";render() end) end
			label(T("Only listed materials are tradable. Equipped and account-bound gear cannot be sold here."),70)
		elseif page=="My Orders" then
			local list=snapshot.portfolioOrders or v.orders
			if #list==0 then EmptyState(body,"no_market_orders",T) end
			for _,o in ipairs(list) do
				label(name(o.itemId or item).." · "..T(o.side).." · "..T(o.state).."\n"..o.price.." Gold · "..T("Original / Filled / Remaining")..": "..o.original.." / "..o.filled.." / "..o.remaining.."\n"..os.date("!%Y-%m-%d %H:%M UTC",o.createdAt),100)
				if o.state=="ACTIVE" or o.state=="PARTIALLY_FILLED" then button("CancelRemaining","Cancel remaining",function() item=o.itemId or item;send("Cancel",nil,o.id) end) end
			end
		elseif page=="History" then
			local list=snapshot.portfolioHistory or v.history
			if #list==0 then label(T("No recent trade")) end
			for _,t in ipairs(list) do label(name(t.itemId or item).." · "..T(t.side).." · "..t.quantity.." × "..t.price.." Gold\n"..T("Fee")..": "..t.fee.." · "..T("Net")..": "..t.net.." · "..T(t.state),74) end
		else
			label("◆ "..name(item),40)
			local actions=Instance.new("Frame");actions.Name="ImmediateActions";actions.Size=UDim2.new(1,-6,0,48);actions.BackgroundTransparency=1;actions.Parent=body
			local buy=button("BuyNow","Buy now",function() begin("BUY","MARKET") end,actions);buy.Size=UDim2.new(.5,-4,1,0)
			local sell=button("SellNow","Sell now",function() begin("SELL","MARKET") end,actions);sell.Size=UDim2.new(.5,-4,1,0);sell.Position=UDim2.fromScale(.5,0)
			button("Advanced","Advanced order",function() advanced=not advanced;render() end)
			if advanced then button("LimitBuy","Buy at my price",function() begin("BUY","LIMIT") end);button("LimitSell","Sell at my price",function() begin("SELL","LIMIT") end) end
			field(v.reference.source,v.reference.value);field("Last price",v.lastPrice);field("Best bid",v.bestBid);field("Best ask",v.bestAsk);field("Spread",v.spread)
			field("24h high",v.high);field("24h low",v.low);field("24h volume",v.volume)
			label(T("Order book"),36)
			for _,side in ipairs({"asks","bids"}) do
				label(T(if side=="asks" then "Sell offers" else "Buy offers"),30)
				if #v[side]==0 then label(T(if side=="asks" then "No sell orders" else "No buy orders"),30) end
				for _,level in ipairs(v[side]) do label(level.price.." Gold   ×   "..level.quantity,28) end
			end
			chart(v.candles)
		end
		button("Refresh","Refresh",function() send(if page=="My Orders" or page=="History" then "Portfolio" else "Read") end)
		button("Claim","Collect pending settlements",function() send("Claim") end)
	end
	for n,p in ipairs({"Browse","Search","My Orders","History"}) do
		local b=button(p,p,function() page=p;entry=nil;confirmation=nil;send(if p=="My Orders" or p=="History" then "Portfolio" else "Read") end,nav)
		b.Size=UDim2.new(.25,-4,1,0);b.Position=UDim2.fromScale((n-1)*.25,0);b.TextSize=14
	end
	remote.OnClientEvent:Connect(function(response: any)
		if type(response)~="table" then return end
		local accepted,receivedContext=RequestWindow.finish(request,response.requestId);if not accepted then return end
		timedOut=false
		if response.view then snapshot=response;snapshotContext=receivedContext;language=response.language end
		notice=if response.code=="OK" then "" else T(response.code);render()
	end)
	local stateRemote=remotes:WaitForChild("State") :: RemoteEvent
	stateRemote.OnClientEvent:Connect(function(view: any)
		if view.data then language=view.data.language or "en" end
		if view.navigate=="Market" then panel.Visible=true;send("Read") end
	end)
	return gui
end
