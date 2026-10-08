--!strict
-- Read-only closed-cohort audit. Supply quiescent, same-checkpoint profile snapshots.
return function(book: any,profiles: any,initial: any): any
	local gold=book.burnedFees;local items=0
	if book.archive and book.phase~='ARCHIVED' then gold+=book.archive.fees end
	if book.archive and book.phase=='ARCHIVED' then gold=book.archive.fees end
	for _,o in pairs(book.orders) do
		assert(profiles[o.owner],'IncompleteAuditScope')
		if o.side=='BUY' then gold+=o.escrow else items+=o.escrow end
	end
	for user,p in pairs(profiles) do
		local d=p.data or p
		assert(d.profile.userId==user,'WrongAuditProfile')
		gold+=d.currencies.gold;items+=d.inventory.stacks[book.itemId] or 0
		for id,t in pairs(d.market.transfers) do
			if t.payload.itemId==book.itemId and t.state=='PREPARED' then
				local r=book.receipts[id]
				if not r or r.state~='ACCEPTED' then if t.payload.side=='BUY' then gold+=t.payload.quantity*t.payload.price else items+=t.payload.quantity end end
			end
		end
	end
	for _,claim in pairs(book.claims) do
		local p=profiles[claim.owner];assert(p,'IncompleteAuditScope');local d=p.data or p
		if (d.market.claims[book.itemId..':1'] or 0)<claim.sequence then if claim.asset=='Gold' then gold+=claim.amount else items+=claim.amount end end
	end
	local goldResidual=gold-(initial.gold+(initial.goldAdjustment or 0));local itemResidual=items-(initial.items+(initial.itemAdjustment or 0))
	return {gold=gold,items=items,goldResidual=goldResidual,itemResidual=itemResidual,violations=if goldResidual==0 and itemResidual==0 then 0 else 1}
end
