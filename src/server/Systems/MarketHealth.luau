--!strict
return function(c: any,now: any)
	local H: any={state='HEALTHY',failures=0,retries=0,throttles=0,untilAt=0,reason=nil}
	function H.allow(read: boolean?): boolean
		if H.state=='PAUSED' then return read==true end
		if H.state=='READ_ONLY' and now()<H.untilAt then return read==true end
		if H.state=='READ_ONLY' then H.state='DEGRADED' end
		return true
	end
	function H.failed(reason: string)
		H.failures+=1;H.reason=reason
		if H.state=='PAUSED' or string.find(reason,'MarketInvariant',1,true) then H.state='PAUSED';return end
		if H.failures>=c.FailureThreshold then H.state='READ_ONLY';H.untilAt=now()+c.BreakerSeconds else H.state='DEGRADED' end
	end
	function H.success() if H.state=='PAUSED' then return end;H.failures=0;H.state='HEALTHY';H.reason=nil end
	function H.budget(reads: number,writes: number,maintenance: boolean?): boolean
		local reserve=if maintenance then c.MaintenanceBudgetReserve else c.BudgetReserve
		if reads<=reserve or writes<=reserve then H.throttles+=1;return false end
		return true
	end
	return H
end
