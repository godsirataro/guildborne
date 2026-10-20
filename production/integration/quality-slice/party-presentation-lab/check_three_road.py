"""Focused source checks. No build; temporary Luau stays inside this lab folder."""
from pathlib import Path
import importlib.util, json, subprocess, tempfile
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location("party_builder", HERE / "build.py")
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)
source = ROOT / "build/quality-preview.project.json"
original = Path.read_text
project = json.loads(source.read_text())
runtime = Path(project["tree"]["ServerScriptService"]["Server"]["Config"]["Runtime"]["$path"])
chain = ("NoviceJourney", "IronveilJourney", "AshenJourney", "TowerJourney", "CrosshavenJourney", "ArchiveHeartJourney")
base = (ROOT / "offline/ArchiveHeartRuntime.luau").read_text(encoding="utf-8-sig").replace("return {", "return {\n    FullConnectedWorldCandidate=true,", 1)
variants = [base]
for flag in ("FullConnectedWorldCandidate", *chain):
    for value in ('false', '"true"'):
        variants.append(base.replace(flag+"=true", flag+"="+value))
    variants.append(base.replace(flag+"=true,", ""))
for flag in ("LaunchCandidate", "SharedCombatCandidate", "ContinuousWorldCandidate"):
    variants.append(base.replace("return {", "return {\n    "+flag+"=true,"))
variants.append(base.replace("FullConnectedWorldCandidate=true,", "-- FullConnectedWorldCandidate=true,"))
variants.append(base.replace("FullConnectedWorldCandidate=true,", "FullConnectedWorldCandidate=true, FullConnectedWorldCandidate=false,"))
count = 0
for enabled in (False, True):
    for content in variants:
        def read(path, *a, **kw):
            return content if path == runtime else original(path, *a, **kw)
        expected = not enabled or content == base
        with patch.object(Path, "read_text", read):
            try:
                result = builder.prepare(source, "City", enabled)
            except AssertionError:
                assert not expected
            else:
                assert expected
                tree = result["tree"]
                assert tree["ServerScriptService"]["PartyPresentationLab"]["$attributes"] == {"StartZone": "City", "ThreeRoadWalk": enabled}
                assert tree["ServerScriptService"]["Server"]["ServerBootstrap"]["$properties"]["Disabled"] is True
                assert tree["StarterPlayer"]["StarterPlayerScripts"]["Client"]["ClientBootstrap"]["$properties"]["Disabled"] is True
            count += 1
server = (HERE / "PartyPresentation.server.luau").read_text()
guards = server[server.index('assert(runtime.StudioPersistence'):server.index('assert(not workspace:FindFirstChild')]
assert server.index('Three-road lab requires') < server.index('local folder=Instance.new')
assert 'FullConnectedWorld=threeRoadWalk,' in server
pair = next(line.strip() for line in server.splitlines() if 'then return "InvalidZone"' in line)
harness = 'local function guard(runtime,flag)\nlocal script={GetAttribute=function()return flag end}\n' + guards + '\nreturn threeRoadWalk end\n'
harness += '''local n=0
local chain={"NoviceJourney","IronveilJourney","AshenJourney","TowerJourney","CrosshavenJourney","ArchiveHeartJourney"}
local function valid()
 local r={StudioPersistence="Memory",AllowedDataStoreUniverses={},FullConnectedWorldCandidate=true}
 for _,flag in ipairs(chain)do r[flag]=true end
 return r
end
for _,key in ipairs(chain)do
 for _,value in ipairs({false,"true",1})do
  local r=valid();r[key]=value;assert(not pcall(guard,r,true));assert(pcall(guard,r,false));n+=2
 end
 local r=valid();r[key]=nil;assert(not pcall(guard,r,true));assert(pcall(guard,r,false));n+=2
end
for _,key in ipairs({"LaunchCandidate","SharedCombatCandidate","ContinuousWorldCandidate"})do
 local r=valid();r[key]=true;assert(not pcall(guard,r,true));assert(pcall(guard,r,false));n+=2
end
for _,flag in ipairs({false,true,"true",1})do
 for _,candidate in ipairs({false,true,"true",1})do
  for _,mode in ipairs({"Memory","Persistent"})do
   local r=valid();r.StudioPersistence=mode;r.FullConnectedWorldCandidate=candidate
   local ok=pcall(guard,r,flag)
   assert(ok==(mode=="Memory" and (flag~=true or candidate==true)));n+=1
  end
 end
end
for _,universes in ipairs({false,"bad",{[1]="forbidden"}})do
 assert(not pcall(guard,{StudioPersistence="Memory",AllowedDataStoreUniverses=universes,FullConnectedWorldCandidate=true},true));n+=1
end
'''
harness += 'local function gate(from,to,threeRoadWalk)\n' + pair + '\nreturn nil end\n'
harness += '''for _,flag in ipairs({false,true})do
 for _,pair in ipairs({{"City","Greenwood"},{"Greenwood","City"},{"Greenwood","Ironveil"},{"Ironveil","Greenwood"}})do assert(gate(pair[1],pair[2],flag)==nil);n+=1 end
 for _,pair in ipairs({{"Ironveil","Ashen"},{"Ashen","Ironveil"}})do assert((gate(pair[1],pair[2],flag)==nil)==flag);n+=1 end
 for _,pair in ipairs({{"City","Ashen"},{"Ashen","Greenwood"},{"Ironveil","City"},{"Ashen","Ashen"}})do assert(gate(pair[1],pair[2],flag)=="InvalidZone");n+=1 end
end
print("PASS actual lab runtime guard and gate "..n.." cases; no Studio")
'''
with tempfile.NamedTemporaryFile(mode="w", suffix=".luau", prefix="guard-check-", dir=HERE, delete=False) as f:
    f.write(harness)
    name = Path(f.name)
try:
    subprocess.run([str(ROOT / ".tools/luau/luau.exe"), str(name)], check=True, timeout=20)
finally:
    name.unlink()
print(f"PASS builder opt-in {count} cases; no build")
