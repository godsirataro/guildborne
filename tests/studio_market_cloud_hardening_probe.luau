--!strict
-- MCP server QA: synthetic ledger in unique cloud namespace, no player profile writes.
assert(game:GetService('RunService'):IsStudio())
local root=game.ServerScriptService.Server
local u=require(game.ReplicatedStorage.Shared.Util.TableUtil)
local c=u.copy(require(root.Config.Market));c.ReplaySeconds=0;c.CacheSeconds=1;c.IndexTTL=2
local o=require(root.Systems.MarketOrders)(c,u)
local d=require(root.Systems.MarketData)(c,u,o)
local e=require(root.Systems.MarketEpochs)(c,u,o,require(root.Systems.MarketMatching)(c,o),require(root.Systems.MarketBook),d)
local ns='qa45_'..os.time();local h=game:GetService('HttpService')
_G.P45Cloud={namespace=ns,status='running'}
task.spawn(function()
	local started=os.clock();local ok,err=pcall(function()
		local make=require(root.Persistence.MarketCloud);local a=make(ns,c,o);local reader=make(ns,c,o)
		-- Reader intentionally never subscribes: messages are missed on this path.
		local notifications=0;local connection=game:GetService('MessagingService'):SubscribeAsync('GBM:'..ns,function() notifications+=1 end)
		local key='b:iron_ore:1';local now=os.time();local latencies={}
		local function apply(cmd: any): any
			cmd.epoch=cmd.epoch or 1;local t=os.clock()
			local b=a.Store.Update(key,function(raw) local nextBook=e.apply(raw,'iron_ore',cmd,now);e.invariants(nextBook);return nextBook end)
			table.insert(latencies,(os.clock()-t)*1000);return b
		end
		for _,p in ipairs({{id='seller',owner=101,side='SELL',quantity=5,price=10},{id='buyer',owner=102,side='BUY',quantity=2,price=12}}) do
			local payload={itemId='iron_ore',side=p.side,kind='LIMIT',quantity=p.quantity,price=p.price}
			apply({action='Prepare',id=p.id,owner=p.owner,payload=payload});apply({action='Deposit',id=p.id,owner=p.owner,payload=payload});apply({action='ConfirmSource',id=p.id,owner=p.owner})
		end
		local before=reader.Store.Read(key);assert(#before.trades==1 and before.burnedFees==1)
		a.Changed('iron_ore',before);task.wait(3)
		local map=game:GetService('MemoryStoreService'):GetSortedMap('GBM:'..ns..':iron_ore:SELL');local projection=map:GetAsync('depth');assert(projection and projection.rows[1].quantity==3)
		map:RemoveAsync('depth');assert(map:GetAsync('depth')==nil);a.Changed('iron_ore',before);task.wait(3);assert(map:GetAsync('depth'))
		task.wait(3);assert(map:GetAsync('depth')==nil)
		local closed=apply({action='CloseEpoch'});local _,blocked=e.apply(closed,'iron_ore',{action='Reconcile',epoch=1},now);assert(blocked=='RecoveryPending')
		-- Synthetic recipient acknowledgments; actual profile application is tested in native clients.
		for id,x in pairs(closed.claims) do apply({action='Ack',id=id,owner=x.owner}) end
		apply({action='Reconcile'});apply({action='Archive'});local final=apply({action='StartEpoch'})
		local stale=e.apply(final,'iron_ore',{action='Deposit',id='buyer',owner=102,epoch=1},now);assert(stale.epoch==2 and #stale.trades==0)
		task.wait(1.1);local refreshed=reader.Store.Read(key);assert(refreshed.epoch==2);assert(e.project(refreshed,101,now,'30D').candles[1].volume==2)
		table.sort(latencies);connection:Disconnect()
		_G.P45Cloud={namespace=ns,status='passed',seconds=os.clock()-started,epoch=refreshed.epoch,archiveFees=refreshed.archive.fees,chartVolume=2,violations=0,profileWrites=0,
			bytes=#h:JSONEncode(final),notifications=notifications,missedMessageReader=true,metrics=a.Metrics,readMetrics=reader.Metrics,
			latencyP50Ms=latencies[math.ceil(#latencies*.5)],latencyP95Ms=latencies[math.ceil(#latencies*.95)],operations=#latencies}
	end)
	if not ok then _G.P45Cloud.status='failed';_G.P45Cloud.error=tostring(err) end
	print('PHASE45 CLOUD '..h:JSONEncode(_G.P45Cloud))
end)
