--!nocheck
local current
local Players={}
function Players:GetPlayerByUserId(_id)return current end
local old={UserId=1,Parent=Players}
local newer={UserId=1,Parent=Players}
local funnelOwners={}
local begins,observations=0,0
local Funnel={Begin=function()begins+=1 end,End=function()end,Observe=function()observations+=1 end}
local function observeProduct(userId:number,name:string,payload:any,sourcePlayer:Player?)
	-- Telemetry is never part of combat/profile authority or commit success.
	if sourcePlayer and funnelOwners[userId]==sourcePlayer and Players:GetPlayerByUserId(userId)==sourcePlayer then pcall(Funnel.Observe,userId,name,payload) end
end

current=newer;funnelOwners[1]=newer
observeProduct(1,"combat_reward",{},old)
assert(observations==0,"stale player accepted")
observeProduct(1,"combat_reward",{},newer)
assert(observations==1,"current player rejected")
current=nil;funnelOwners[1]=nil
observeProduct(1,"combat_reward",{},nil)
assert(observations==1,"nil equality accepted")
local closing=false
local started={}
local Data={Load=function()coroutine.yield();return "OK"end,Close=function()end}
local HttpService={GenerateGUID=function()return "test"end}
local Analytics={Emit=function()end}
local PermanentPassRuntime=nil
local HumanParty={Add=function()end}
local function load(player: Player): string
	if closing or player.Parent ~= Players then return "Closing" end
	local code = Data.Load(player.UserId, HttpService:GenerateGUID(false))
	if code == "OK" and not closing and player.Parent==Players and Players:GetPlayerByUserId(player.UserId)==player and not started[player] then
		started[player] = true
		if funnelOwners[player.UserId]~=player then pcall(Funnel.End,player.UserId);funnelOwners[player.UserId]=player;pcall(Funnel.Begin,player.UserId) end
		Analytics.Emit("session_started", {}, player)
	end
	if player.Parent ~= Players then Data.Close(player.UserId) end
	if code=="OK" and player.Parent==Players and PermanentPassRuntime then PermanentPassRuntime.Joined(player) end
	if code=="OK" and player.Parent==Players then HumanParty.Add(player) end
	return code
end

current=old;old.Parent=Players
local worker=coroutine.create(function()load(old)end)
assert(coroutine.resume(worker))
old.Parent=nil;current=nil
assert(coroutine.resume(worker))
assert(begins==0 and started[old]==nil and funnelOwners[1]==nil,"orphan session created")
old.Parent=Players;current=old
worker=coroutine.create(function()load(old)end)
assert(coroutine.resume(worker))
current=newer
assert(coroutine.resume(worker))
assert(begins==0,"superseded player created session")
current=newer
worker=coroutine.create(function()load(newer)end)
assert(coroutine.resume(worker));assert(coroutine.resume(worker))
assert(begins==1 and started[newer] and funnelOwners[1]==newer)
print("PASS bootstrap actual-source lifecycle: disconnected load, replacement load, stale observation, current observation")

local queue={}
local task={defer=function(fn)table.insert(queue,fn)end}
local combatObserver=observeProduct
	local observerPending=0
	local function observe(owner:number,event:string,payload:any)
		if combatObserver and observerPending<32 then
			-- Capture connection identity before queueing; never attribute an old hit to a rejoin.
			local originalPlayer=Players:GetPlayerByUserId(owner)
			if not originalPlayer then return end
			observerPending+=1
			task.defer(function()pcall(combatObserver,owner,event,payload,originalPlayer);observerPending-=1 end)
		end
	end

current=old;funnelOwners[1]=old
observe(1,"combat_player_damage",{amount=1})
assert(#queue==1)
current=newer;funnelOwners[1]=newer
local before=observations
queue[1]()
assert(observations==before,"old queued event attributed to rejoin")
table.clear(queue)
for i=1,33 do observe(1,"combat_player_damage",{amount=1})end
assert(#queue==32,"observer capacity exceeded")
for _,fn in ipairs(queue)do fn()end
assert(observations==before+32)
table.clear(queue);current=nil
observe(1,"combat_player_damage",{amount=1});assert(#queue==0)
print("PASS actual combat observer: captured identity, rejoin rejection, capacity, absent player")
