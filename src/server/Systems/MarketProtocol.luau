--!strict
return function(config: any,orders: any)
	local P={}
	function P.errorResponse(p: any,code: string): any
		local id=if type(p)=="table" then p.requestId else nil
		return {code=code,requestId=if type(id)=="string" and #id<=40 and id:match("^[%w%-]+$") then id else nil}
	end
	function P.busyResponse(p: any): any return P.errorResponse(p,"MarketBusy") end
	function P.accept(bucket: any,now: number): boolean
		bucket.tokens=math.min(4,bucket.tokens+math.max(0,now-bucket.at)*.5);bucket.at=now
		if bucket.tokens<1 then return false end;bucket.tokens-=1;return true
	end
	function P.valid(p: any): boolean
		if type(p)~="table" or type(p.requestId)~="string" or #p.requestId<1 or #p.requestId>40 or not p.requestId:match("^[%w%-]+$") then return false end
		local allowed={requestId=true,action=true,itemId=true,period=true,order=true,orderId=true,epoch=true}
		if p.epoch~=nil and (type(p.epoch)~="number" or p.epoch~=p.epoch or p.epoch%1~=0 or p.epoch<1 or p.epoch>1000000000) then return false end
		for k in pairs(p) do if not allowed[k] then return false end end
		if not config.Items[p.itemId] then return false end
		if p.period~=nil and not ({["1H"]=true,["6H"]=true,["1D"]=true,["7D"]=true,["30D"]=true})[p.period] then return false end
		if p.action=="Create" then return not orders.validate(p.order) and p.order.itemId==p.itemId end
		if p.action=="Cancel" then return type(p.orderId)=="string" and #p.orderId<=100 end
		return p.action=="Read" or p.action=="Claim" or p.action=="Portfolio"
	end
	return P
end
