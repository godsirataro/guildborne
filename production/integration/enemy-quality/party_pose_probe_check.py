"""Run deterministic tests of the probe's actual pure collector, never Studio evidence."""
import argparse
import hashlib
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--luau', required=True)
    args = parser.parse_args()
    source = Path(__file__).with_name('party_pose_probe.luau').read_text(encoding='utf-8-sig')
    first, last = '-- BEGIN PURE_COLLECTOR', '-- END PURE_COLLECTOR'
    assert source.count(first) == source.count(last) == 1
    body = source.split(first, 1)[1].split(last, 1)[0]
    discovery = 'local function selected(m)' + source.split('local function selected(m)', 1)[1].split('local function jointRecord', 1)[0]
    print('ACTUAL_COLLECTOR_SHA256', hashlib.sha256(body.encode()).hexdigest(), flush=True)
    tests = r'''
local make=require('./collector')
local total=0
local function check(name,fn) fn();total+=1;print('PASS '..name) end
check('append preserves sequence and deep copies input',function()
 local c=make(3,.15);local p={nested={v=1}}
 assert(c.append('frame',p,1));p.nested.v=99
 local rows=c.chunk(0,1);assert(#rows==1 and rows[1].sequence==1 and rows[1].payload.nested.v==1)
 local ok=pcall(function() rows[1].payload.nested.v=2 end);assert(not ok)
 assert(c.chunk(0,1)[1].payload.nested.v==1)
end)
check('bounded capacity counts omitted records rather than overwriting',function()
 local c=make(2,.15)
 assert(c.append('a',{},1) and c.append('b',{},2))
 assert(not c.append('c',{},3));local m=c.metadata()
 assert(m.count==2 and m.attempted==3 and m.dropped==1 and m.overflow==true)
 assert(c.chunk(0,2)[1].kind=='a' and c.chunk(0,2)[2].kind=='b')
end)
check('chunk reconstruction has no duplicates or gaps',function()
 local c=make(7,.15)
 for i=1,7 do assert(c.append('sample',{value=i},i)) end
 local merged={}
 for offset=0,6,3 do for _,r in ipairs(c.chunk(offset,3))do table.insert(merged,r)end end
 assert(#merged==7)
 for i,r in ipairs(merged)do assert(r.sequence==i and r.payload.value==i)end
 assert(#c.chunk(7,3)==0)
end)
check('frame gap and clock regression remain explicit',function()
 local c=make(10,.15)
 assert(c.tick(0) and c.tick(.1) and c.tick(.3))
 assert(not c.tick(.2));local m=c.metadata()
 assert(m.frameCount==3 and m.gapCount==1 and m.maxGap>.15 and m.clockRegression==true)
end)
check('invalid timestamps are rejected',function()
 local c=make(4,.15)
 assert(not c.append('bad',{},0/0));assert(not c.append('bad',{},math.huge))
 assert(not c.tick(-math.huge));assert(c.metadata().invalidTimes>=3)
 assert(c.metadata().count==0)
end)
check('terminal snapshot is stable and stop is idempotent',function()
 local c=make(4,.15);assert(c.append('frame',{},1))
 assert(c.finish(2,'deadline'));local before=c.metadata()
 assert(not c.finish(3,'manual'));assert(not c.append('late',{},4));assert(not c.tick(4))
 local after=c.metadata()
 assert(after.stopped and after.finishedAt==2 and after.reason=='deadline')
 assert(after.count==before.count and after.attempted==before.attempted and after.frameCount==before.frameCount)
end)
check('invalid chunk requests cannot bypass limits',function()
 local c=make(4,.15)
 for _,pair in ipairs({{-1,1},{.5,1},{0,0},{0,201},{0,1.5}})do
  local ok=pcall(function() c.chunk(pair[1],pair[2])end);assert(not ok)
 end
end)
check('metadata snapshots cannot mutate collector',function()
 local c=make(4,.15);c.append('frame',{},1)
 local m=c.metadata();local ok=pcall(function()m.count=400 end);assert(not ok)
 assert(c.metadata().count==1)
end)
check('missing terminal frame coverage cannot be complete',function()
 local c=make(4,.15);c.append('start',{},0);c.tick(0);c.tick(.1)
 c.finish(2,'duration');local m=c.metadata()
 assert(not m.complete and m.gapCount>0 and m.maxGap>=1.9)
end)
check('zero sampled frames cannot be complete',function()
 local c=make(4,.15);c.append('start',{},0);c.finish(.1,'duration')
 assert(not c.metadata().complete)
end)
check('missing initial frame coverage cannot be complete',function()
 local c=make(4,.15);c.append('start',{},0);c.tick(2);c.finish(2.01,'duration')
 local m=c.metadata();assert(not m.complete and m.gapCount>0 and m.maxGap>=2)
end)
check('actual discovery refuses detached character and preserves identity on return',function()
 local makeDiscovery=require('./discovery')
 local m={live=false,Name='Player'}
 function m:IsA(kind) return kind=='Model' end
 function m:IsDescendantOf(_) return self.live end
 function m:GetAttribute(_) return nil end
 function m:GetFullName() return 'Workspace.Player' end
 local d=makeDiscovery(m)
 d.discover(m,1);assert(#d.events==0)
 m.live=true;d.discover(m,2);assert(#d.events==1 and d.events[1].kind=='entity_added')
 local original=d.ids[m];d.actors[m]=nil;m.live=false
 d.discover(m,3);assert(#d.events==1 and d.actors[m]==nil)
 m.live=true;d.discover(m,4)
 assert(#d.events==2 and d.events[2].kind=='entity_returned' and d.ids[m]==original)
end)
print('LOCAL_COLLECTOR_CHECKS '..total..'; no native motion or VFX acceptance')
'''
    with tempfile.TemporaryDirectory(prefix='guildborne-pose-') as directory:
        folder = Path(directory)
        (folder/'collector.luau').write_text(body+'\nreturn pureCollector\n', encoding='utf-8')
        (folder/'discovery.luau').write_text('''return function(character)
local owner={Character=character};local config={ownerUserId=1};local workspace={}
local actorIds,actors,counts={},{},{};local actorCount=0;local discoveryOverflow=false
local events={}
local function emit(kind,payload,t) table.insert(events,{kind=kind,payload=payload,time=t}) end
local function attributes(_) return {} end
local function id(kind,n) return kind..n end
''' + discovery + '\nreturn {discover=discover,events=events,ids=actorIds,actors=actors}\nend\n', encoding='utf-8')
        (folder/'check.luau').write_text(tests, encoding='utf-8')
        subprocess.run([args.luau, str(folder/'check.luau')], check=True)


if __name__ == '__main__':
    main()
