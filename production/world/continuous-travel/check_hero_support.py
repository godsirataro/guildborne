"""Execute actual HeroService floor/recover/walk functions with geometric mocks.

No Roblox simulation claim. Temporary harness stays in this evidence directory.
"""
from pathlib import Path
import subprocess, tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
source = (ROOT / "src/server/Services/HeroService.luau").read_text(encoding="utf-8-sig")
actual = source[source.index("\tlocal function floor("):source.index("\tlocal elapsed=0")]
prefix = r'''
local mt={}
local function V(x,y,z)return setmetatable({X=x,Y=y,Z=z},mt)end
mt.__add=function(a,b)return V(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
mt.__sub=function(a,b)return V(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
mt.__index=function(a,k)if k=="Magnitude"then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z)end end
local Vector3={zero=V(0,0,0)}
local CFrame={new=function(p)return p end}
local os={clock=function()return 100 end}
local function invalidatePath(h)h.generation+=1;h.path=nil;h.waypoint=nil end
local planes={};local calls=0;local params={sentinel=true}
local workspace={}
function workspace:Raycast(origin,direction,received)
 assert(received==params,"Original collision filter must be preserved")
 calls+=1
 if direction.X~=0 or direction.Z~=0 then return nil end
 local best=nil
 for _,plane in ipairs(planes)do
  local y=plane.y+(plane.slope or 0)*origin.X
  if y<=origin.Y and y>=origin.Y+direction.Y and (not best or y>best)then best=y end
 end
 return if best then {Position=V(origin.X,best,origin.Z)}else nil
end
local task={spawn=function()error("Unexpected pathfinding in focused near-goal test")end}
local Pathfinding={};local Enum={PathWaypointAction={Jump="Jump"}}
local s={params=params,origin=V(0,0,0)}
local function actor(p)
 local h={root={Position=p,Anchored=false},lastPosition=p,lastProgress=0,recoveries=0,generation=0,model={},humanoid={}}
 function h.model:PivotTo(value)h.root.Position=value end
 function h.model:SetAttribute(k,v)assert(k=="RecoveryCount");h.attribute=v end
 function h.humanoid:MoveTo(value)h.lastMove=value end
 return h
end
'''
tests = r'''
local n=0
local function support(y,expected)
 local p=floor(s,V(0,y,1517.69))
 assert(p and math.abs(p.Y-expected)<.0001,"Wrong support for root Y"..y..": "..tostring(p and p.Y));n+=1;return p
end
planes={{y=2},{y=12.5}}
local goal=support(5.078125,5)
support(7,5) -- Travel destination root, below the same overhead lintel.
support(9,5) -- Jumping reference still resolves to the ground below.
for _=1,5 do goal=floor(s,goal);assert(goal.Y==5);n+=1 end
local h=actor(V(0,5,1516.8877))
for i=1,51 do walk(s,h,goal,(i-1)*.2)end
assert(h.recoveries==0 and h.root.Position.Y==5 and h.lastProgress==10);n+=1
planes={{y=52},{y=62.5}}
support(55.078125,55) -- Legitimate elevated walkable floor; no world-height clamp.
planes={{y=2,slope=.25}}
local slope=floor(s,V(2,5.5,0));assert(slope and slope.Y==5.5);n+=1
planes={{y=4}}
support(5,7) -- Modest step up remains available.
planes={}
assert(floor(s,V(0,5,0))==nil);n+=1
planes={{y=-15}} -- Twenty below reference: outside the original search envelope.
assert(floor(s,V(0,5,0))==nil);n+=1
planes={{y=-11}} -- Original reference-minus-16 lower boundary remains reachable.
support(5,-8)
planes={{y=2},{y=12.5}}
goal=support(5,5)
local far=actor(V(60,5,1517.69));walk(s,far,goal,10)
assert(far.recoveries==1 and far.attribute==1 and far.root.Position.Y==5);n+=1
local stuck=actor(V(10,5,1517.69));walk(s,stuck,goal,8)
assert(stuck.recoveries==1 and stuck.root.Position.Y==5);n+=1
assert(calls>0)
print("PASS actual HeroService support/walk "..n.." checks; native physics NOT_RUN")
'''

def run(body):
    with tempfile.NamedTemporaryFile(mode="w", suffix=".luau", prefix="support-check-", dir=HERE, delete=False) as f:
        f.write(prefix + body + tests)
        path = Path(f.name)
    try:
        return subprocess.run([str(ROOT / ".tools/luau/luau.exe"), str(path)], capture_output=True, text=True, timeout=20)
    finally:
        path.unlink()

result = run(actual)
print(result.stdout, end="")
if result.returncode:
    raise AssertionError(result.stderr)
assert actual.count("position+V(0,1,0)") == 1
old = run(actual.replace("position+V(0,1,0)", "position+V(0,8,0)").replace("V(0,-17,0)", "V(0,-24,0)"))
assert old.returncode != 0 and "Wrong support for root Y5.078125: 15.5" in old.stderr, old.stderr
print("PASS old +8 probe reproduces lintel failure; same regression rejects it")
