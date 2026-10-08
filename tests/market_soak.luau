--!strict
-- Optional sustained deterministic soak; no Roblox network or real profiles.
local util=require('../src/shared/Util/TableUtil')
local content=require('../src/server/Config/Content')
local started=os.clock()
for run=1,4 do
	print('PHASE45_SOAK_RUN',run)
	require('./market_hardening')(function(name: string,f: any)
		if string.find(name,'5000 order',1,true) then f() end
	end,function(a: any,b: any) assert(util.equal(a,b),'Soak expectation failed: '..tostring(a)..' / '..tostring(b)) end,util,content,nil)
end
print(string.format('PHASE45_SOAK totalOrders=20000 runs=4 elapsedSeconds=%.3f invariantViolations=0',os.clock()-started))
