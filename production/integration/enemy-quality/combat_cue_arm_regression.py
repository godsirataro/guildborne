"""Local regression of actual extracted manual-arm control flow; never native evidence."""
import argparse
import hashlib
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--luau', required=True)
    args = parser.parse_args()
    source = Path(__file__).with_name('combat_cue_probe.luau').read_text(encoding='utf-8-sig')
    helpers = source.split('-- BEGIN COVERAGE_HELPERS', 1)[1].split('-- END COVERAGE_HELPERS', 1)[0]
    observe = 'local function observe' + source.split('local function observe', 1)[1].split('local function actor', 1)[0]
    edge = source.split('"Manual arm deadline expired")', 1)[1].split('script:SetAttribute("ProbeStatus","RUNNING")', 1)[0]
    actual = helpers + observe + edge
    print('EXTRACTED_ARM_SOURCE_SHA256', hashlib.sha256(actual.encode()).hexdigest(), flush=True)
    module = helpers + '''
return function(state)
    local heartbeats=state.samples
    local coverageDiagnostic=nil
    local interference=state.interference
    local function now() return state.clock end
    local function condition(ok,message) assert(ok,"INCONCLUSIVE: "..message) end
    local function pause(seconds,label)
        state.waits+=1
        assert(seconds>0 and seconds<=.01)
        state.clock+=seconds
        if state.publish then table.insert(heartbeats,state.publish);state.publish=nil end
        if state.interfereOnWait then interference=true end
    end
''' + observe + '''
    local armedAt=state.armedAt
''' + edge + '''
    assert(armedAt==state.armedAt,"manual edge timestamp changed")
    return coverageDiagnostic
end
'''
    tests = '''
local arm=require("./arm")
local total=0
local function check(name,fn) fn();total+=1;print("PASS "..name) end
local function state()
    -- One second preceding a fractional arm edge; the successor is not yet recorded.
    return {armedAt=10.05,clock=10.05,waits=0,
        samples={9,9.1,9.2,9.3,9.4,9.5,9.6,9.7,9.8,9.9,10},publish=10.06}
end
check("actual manual arm waits for successor with fixed preceding interval",function()
    local s=state();local d=arm(s)
    assert(s.waits==1 and d.reason=="covered")
    assert(d.a==s.armedAt-1 and d.b==s.armedAt)
    assert(d.predecessor==9 and d.successor==10.06 and #s.samples==12)
    assert(d.maxWindowGap<=.15 and s.armedAt==10.05)
end)
check("actual manual arm rejects genuine gap without waiting",function()
    local s=state();table.remove(s.samples,5)
    local ok,err=pcall(arm,s)
    assert(not ok and tostring(err):find("Heartbeat coverage gap",1,true),tostring(err))
    assert(s.waits==0 and s.publish==10.06)
end)
check("actual manual arm rejects missing predecessor without waiting",function()
    local s=state();table.remove(s.samples,1)
    local ok,err=pcall(arm,s)
    assert(not ok and tostring(err):find("Heartbeat coverage no_start_sample",1,true),tostring(err))
    assert(s.waits==0)
end)
check("actual manual arm retains camera interference guard after publication",function()
    local s=state();s.interfereOnWait=true
    local ok,err=pcall(arm,s)
    assert(not ok and tostring(err):find("Camera changed during READY",1,true),tostring(err))
    assert(s.waits==1 and s.armedAt==10.05)
end)
print("PASS_MANUAL_ARM_LOCAL cases="..total)
'''
    with tempfile.TemporaryDirectory(prefix='guildborne-arm-') as directory:
        out = Path(directory)
        (out/'arm.luau').write_text(module, encoding='utf-8')
        (out/'check.luau').write_text(tests, encoding='utf-8')
        subprocess.run([args.luau, str(out/'check.luau')], check=True)


if __name__ == '__main__':
    main()
