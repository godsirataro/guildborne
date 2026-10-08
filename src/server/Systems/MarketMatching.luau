--!strict
-- Pure single-book transforms: no yielding, service calls or callback side effects.
return function(config: any, orders: any)
	local M = {}
	function M.claim(book: any, id: string, owner: number, source: string, asset: string, amount: number, now: number)
		if amount==0 then return end
		assert(not book.claims[id],"Duplicate claim identity")
		book.claimSequence+=1
		book.claims[id]={id=id,sequence=book.claimSequence,owner=owner,source=source,asset=asset,amount=amount,state="PENDING",createdAt=now}
	end
	function M.cancel(book: any,o: any,now: number,state: string)
		if not orders.active(o) then return end
		M.claim(book,"refund:"..o.id,o.owner,o.id,if o.side=="BUY" then "Gold" else "Item",o.escrow,now)
		o.escrow=0;o.state=state;o.closedAt=now
	end
	function M.run(book: any,incoming: any,now: number)
		local other=if incoming.side=="BUY" then "SELL" else "BUY"
		for _,maker in ipairs(orders.sorted(book,other)) do
			if incoming.remaining==0 then break end
			local crosses=if incoming.side=="BUY" then incoming.price>=maker.price else incoming.price<=maker.price
			if not crosses then break end
			if maker.owner==incoming.owner then M.cancel(book,incoming,now,"SELF_TRADE_CANCELLED");break end
			local buy=if incoming.side=="BUY" then incoming else maker
			local sell=if incoming.side=="SELL" then incoming else maker
			local quantity=math.min(buy.remaining,sell.remaining)
			local gross=quantity*maker.price
			local cumulative=sell.gross+gross
			local fee=math.ceil(cumulative*sell.feeBps/10000)-sell.fee
			book.tradeSequence+=1
			local id="t:"..book.tradeSequence
			local trade={id=id,sequence=book.tradeSequence,buy=buy.id,sell=sell.id,buyer=buy.owner,seller=sell.owner,
				price=maker.price,quantity=quantity,gross=gross,fee=fee,net=gross-fee,at=now}
			table.insert(book.trades,trade);book.burnedFees+=fee
			sell.gross=cumulative;sell.fee+=fee
			buy.escrow-=quantity*buy.price;sell.escrow-=quantity
			M.claim(book,id..":seller",sell.owner,id,"Gold",gross-fee,now)
			M.claim(book,id..":buyer",buy.owner,id,"Item",quantity,now)
			M.claim(book,id..":improvement",buy.owner,id,"Gold",quantity*buy.price-gross,now)
			for _,o in ipairs({buy,sell}) do
				o.remaining-=quantity;o.filled+=quantity
				o.state=if o.remaining==0 then "FILLED" else "PARTIALLY_FILLED"
				if o.remaining==0 then o.closedAt=now end
			end
		end
		if incoming.kind=="MARKET" then M.cancel(book,incoming,now,"CANCELLED") end
	end
	return M
end
