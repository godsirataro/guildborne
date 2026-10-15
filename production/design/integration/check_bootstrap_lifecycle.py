from pathlib import Path
import subprocess
root=Path.cwd()
source=(root/'src/server/ServerBootstrap.server.luau').read_text(encoding='utf-8')
observe=source[source.index('local function observeProduct'):source.index('local Expansion=')]
load=source[source.index('local function load(player: Player)'):source.index('Network = require(script.Parent.Services.NetworkService)')]
fixture='''--!nocheck
local current
local Players={}
function Players:GetPlayerByUserId(_id)return current end
local old={UserId=1,Parent=Players}
local newer={UserId=1,Parent=Players}
local funnelOwners={}
local begins,observations=0,0
local Funnel={Begin=function()begins+=1 end,End=function()end,Observe=function()observations+=1 end}
'''+observe+'''
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
'''+load+'''
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
'''
combat=(root/'src/server/Services/CombatService.luau').read_text(encoding='utf-8')
observer= combat[combat.index('\tlocal observerPending=0'):combat.index('\tlocal function emit(')]
fixture+='\nlocal queue={}\nlocal task={defer=function(fn)table.insert(queue,fn)end}\nlocal combatObserver=observeProduct\n'+observer+'''
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
'''
out=root/'production/design/integration/bootstrap-lifecycle-fixture.luau'
out.write_text(fixture,encoding='utf-8')
p=subprocess.run([str(root/'.tools/luau/luau.exe'),str(out)],capture_output=True,text=True)
(root/'production/design/integration/bootstrap-lifecycle.log').write_text(p.stdout+p.stderr,encoding='utf-8')
print(p.stdout+p.stderr)
raise SystemExit(p.returncode)

