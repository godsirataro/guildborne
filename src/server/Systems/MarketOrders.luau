--!strict
return function(config: any, util: any)
	local O = {}
	function O.validate(p: any): string?
		if type(p) ~= "table" then return "InvalidRequest" end
		local allowed = {itemId=true,side=true,kind=true,price=true,quantity=true}
		for k in pairs(p) do if not allowed[k] then return "InvalidRequest" end end
		if type(p.itemId) ~= "string" or not config.Items[p.itemId] then return "NonTradable" end
		if p.side ~= "BUY" and p.side ~= "SELL" then return "InvalidRequest" end
		if p.kind ~= "LIMIT" and p.kind ~= "MARKET" then return "InvalidRequest" end
		if not util.integer(p.price,1,config.MaxPrice) then return "InvalidPrice" end
		if not util.integer(p.quantity,1,config.MaxQuantity) then return "InvalidQuantity" end
		if p.price*p.quantity > config.MaxOrderValue then return "OrderValueLimit" end
		return nil
	end
	function O.active(o: any): boolean return o.state=="ACTIVE" or o.state=="PARTIALLY_FILLED" end
	function O.sorted(book: any, side: string): {any}
		local result = {}
		for _,o in pairs(book.orders) do if o.side==side and O.active(o) then table.insert(result,o) end end
		table.sort(result,function(a: any,b: any)
			if a.price==b.price then return a.sequence<b.sequence end
			return if side=="BUY" then a.price>b.price else a.price<b.price
		end)
		return result
	end
	return O
end
