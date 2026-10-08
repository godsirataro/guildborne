--!strict
return function(config: any,util: any,orders: any)
	local D={}
	local function median(values: {number}): number
		table.sort(values);local n=#values
		return if n%2==1 then values[math.ceil(n/2)] else (values[n/2]+values[n/2+1])/2
	end
	function D.reference(trades: any,now: number,item: string): any
		local c=config.Reference;local groups: any={}
		for _,t in ipairs(trades) do
			if t.at>now-c.Window and t.at<=now and t.buyer~=t.seller then
				local pair=tostring(math.min(t.buyer,t.seller))..":"..tostring(math.max(t.buyer,t.seller))
				local bucket=math.floor(t.at/c.BucketSeconds);local key=pair..":"..bucket
				local g=groups[key] or {pair=pair,bucket=bucket,buyer=t.buyer,seller=t.seller,volume=0,gross=0}
				g.volume+=t.quantity;g.gross+=t.gross;groups[key]=g
			end
		end
		local samples={};local prices={}
		for _,g in pairs(groups) do g.price=g.gross/g.volume;g.weight=math.min(g.volume,c.VolumeCap);table.insert(samples,g);table.insert(prices,g.price) end
		local function diverse(list: any): boolean
			local users,pairsSeen,buckets={},{},{}
			for _,s in ipairs(list) do users[s.buyer]=true;users[s.seller]=true;pairsSeen[s.pair]=true;buckets[s.bucket]=true end
			return #list>=c.Samples and util.count(users)>=c.Users and util.count(pairsSeen)>=c.Pairs and util.count(buckets)>=c.Buckets
		end
		local fallback={source="Design guide",value=config.Items[item],samples=#samples}
		if not diverse(samples) then return fallback end
		local m=median(prices);local deviations={};for _,v in ipairs(prices) do table.insert(deviations,math.abs(v-m)) end
		local band=math.max(c.MADMultiplier*median(deviations),c.MedianBand*m)
		local kept={};local weights: any={}
		for _,s in ipairs(samples) do if math.abs(s.price-m)<=band then table.insert(kept,s);weights[s.pair]=(weights[s.pair] or 0)+s.weight end end
		if not diverse(kept) then return fallback end
		local totals={};for _,v in pairs(weights) do table.insert(totals,v) end
		local cap=median(totals);local total=0
		for _,s in ipairs(kept) do s.weight*=math.min(1,cap/weights[s.pair]);total+=s.weight end
		table.sort(kept,function(a: any,b: any) return a.price<b.price end)
		local cumulative=0
		for _,s in ipairs(kept) do cumulative+=s.weight;if cumulative>=total/2 then return {source="Market reference",value=math.floor(s.price+.5),samples=#kept} end end
		return fallback
	end
	local periods={ ["1H"]={60,3600},["6H"]={300,21600},["1D"]={900,86400},["7D"]={3600,604800},["30D"]={14400,2592000} }
	function D.candles(trades: any,now: number,period: string): {any}
		local interval=periods[period] or periods["1D"];local buckets: any={}
		for _,t in ipairs(trades) do
			if t.at>now-interval[2] and t.at<=now then
				local start=math.floor(t.at/interval[1])*interval[1];local k=tostring(start)
				local c=buckets[k] or {at=start,open=t.price,high=t.price,low=t.price,close=t.price,volume=0,gross=0}
				c.high=math.max(c.high,t.price);c.low=math.min(c.low,t.price);c.close=t.price;c.volume+=t.quantity;c.gross+=t.gross;buckets[k]=c
			end
		end
		local result={};for _,c in pairs(buckets) do table.insert(result,c) end
		table.sort(result,function(a: any,b: any) return a.at<b.at end);return result
	end
	function D.project(book: any,userId: number,now: number,period: string): any
		local view: any={itemId=book.itemId,revision=book.revision,asOf=now,bids={},asks={},orders={},history={},pendingClaims=0,
			basePrice=config.Items[book.itemId],reference=D.reference(book.trades,now,book.itemId),candles=D.candles(book.trades,now,period),volume=0}
		for _,side in ipairs({"BUY","SELL"}) do
			local levels=if side=="BUY" then view.bids else view.asks
			for _,o in ipairs(orders.sorted(book,side)) do
				if o.expiresAt>now then
					local last=levels[#levels]
					if last and last.price==o.price then last.quantity+=o.remaining
					elseif #levels<config.Depth then table.insert(levels,{price=o.price,quantity=o.remaining}) end
				end
			end
		end
		view.bestBid=if view.bids[1] then view.bids[1].price else nil;view.bestAsk=if view.asks[1] then view.asks[1].price else nil
		view.spread=if view.bestBid and view.bestAsk then view.bestAsk-view.bestBid else nil
		for _,o in pairs(book.orders) do if o.owner==userId then
			table.insert(view.orders,{id=o.id,side=o.side,kind=o.kind,price=o.price,original=o.original,remaining=o.remaining,filled=o.filled,state=o.state,createdAt=o.createdAt})
		end end
		table.sort(view.orders,function(a: any,b: any) return a.createdAt>b.createdAt end)
		while #view.orders>config.HistoryLimit do table.remove(view.orders) end
		for _,t in ipairs(book.trades) do
			view.lastPrice=t.price
			if t.at>now-86400 and t.at<=now then view.high=math.max(view.high or t.price,t.price);view.low=math.min(view.low or t.price,t.price);view.volume+=t.quantity end
			if t.buyer==userId or t.seller==userId then
				local seller=t.seller==userId;local claim=book.claims[t.id..(if seller then ":seller" else ":buyer")]
				table.insert(view.history,{id=t.id,at=t.at,side=if seller then "SELL" else "BUY",quantity=t.quantity,price=t.price,gross=t.gross,
					fee=if seller then t.fee else 0,net=if seller then t.net else t.gross,state=if not claim or claim.state=="CLAIMED" then "CLAIMED" else "PENDING"})
			end
		end
		while #view.history>config.HistoryLimit do table.remove(view.history,1) end
		for _,c in pairs(book.claims) do if c.owner==userId and c.state=="PENDING" then view.pendingClaims+=1 end end
		return view
	end
	return D
end
