"""Execute the actual Bootstrap walking gate with isolated server dependencies."""
from pathlib import Path
import subprocess
ROOT = Path(__file__).resolve().parents[3]
source = (ROOT/'src/server/ServerBootstrap.server.luau').read_text(encoding='utf-8')
start = '-- BEGIN continuous walking eligibility: read-only, synchronous server policy.'
end = '-- END continuous walking eligibility.'
assert source.count(start) == source.count(end) == 1
gate = source.split(start, 1)[1].split(end, 1)[0]
prelude = '''
local Players={};local player={UserId=7,Parent=Players};local current=player
function Players:GetPlayerByUserId(id) return if id==7 then current else nil end
local data={expansion={tower={active=false}},settlement={journal={}}}
local session={state="Active",record={data=data},epoch=1,token="test"}
local Data={Sessions={[7]=session}}
local noviceProblem,releaseProblem,mentor,arena=nil,nil,false,nil
local Content={CivicTravel={}}
function Content.NoviceActionProblem(d,action) assert(d==data and action=="TravelZone");return noviceProblem end
local Release={}
function Release.problem(d,action,args) assert(d==data and action=="TravelZone");assert(args.zone=="City" or args.zone=="Greenwood");return releaseProblem end
local function sharedMentorActive(p) assert(p==player);return mentor end
local workspace={}
function workspace:FindFirstChild(name,recursive) assert(recursive==true);return if arena and name==arena.name then arena else nil end
'''
checks = '''
local count=0
local function check(expected)
 local actual=walkingGate(player,session,"City","Greenwood")
 assert(actual==expected,tostring(actual).." ~= "..tostring(expected));count+=1
end
check(nil)
assert(walkingGate(player,session,"Greenwood","City")==nil);count+=1
assert(walkingGate(player,session,"Guild","Greenwood")=="InvalidZone");count+=1
assert(walkingGate(player,nil,"City","Greenwood")=="ActorNotReady");count+=1
current={};check("ActorNotReady");current=player
player.Parent=nil;check("ActorNotReady");player.Parent=Players
Data.Sessions[7]={};check("ActorNotReady");Data.Sessions[7]=session
session.closing=true;check("ActorNotReady");session.closing=nil
session.state="Degraded";check("ActorNotReady");session.state="Active"
session.record=nil;check("ActorNotReady");session.record={data=data}
session.busy=true;check("SavePending");session.busy=nil
noviceProblem="NoviceRequired";check("NoviceRequired");noviceProblem=nil
releaseProblem="ReleaseContentUnavailable";check("ReleaseContentUnavailable");releaseProblem=nil
data.expansion.tower.active=true;check("FinishExpedition");data.expansion.tower.active=false
Content.CivicTravel.Greenwood="charter";check("CivicRouteLocked")
data.settlement.journal.charter={state="Active"};check("CivicRouteLocked")
data.settlement.journal.charter.state="Claimed";check(nil);Content.CivicTravel.Greenwood=nil
mentor=true;check("HeroMentorActive");mentor=false
for _,prefix in ipairs({"NoviceTrial_","TowerLesson_","ArchiveEncounter_"})do
 arena={name=prefix.."7",GetAttribute=function(_,key)assert(key=="OwnerUserId");return 7 end}
 check("FinishExpedition")
end
arena={name="NoviceTrial_7",GetAttribute=function()return 8 end};check(nil);arena=nil
-- Freeze every reachable profile table: future accidental writes must fail.
table.freeze(data.settlement.journal.charter);table.freeze(data.settlement.journal)
table.freeze(data.settlement);table.freeze(data.expansion.tower);table.freeze(data.expansion);table.freeze(data)
table.freeze(session.record);table.freeze(session);check(nil)
print("PASS actual Bootstrap walking eligibility",count,"cases; frozen profile unchanged")
'''
out=ROOT/'build/continuous-walking-gate.luau'
out.write_text(prelude+gate+checks,encoding='utf-8')
subprocess.run([str(ROOT/'.tools/luau/luau.exe'),str(out)],cwd=ROOT,check=True)
