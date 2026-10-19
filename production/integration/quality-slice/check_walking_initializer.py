"""Run failure injection against the actual WorldService initializer block."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[3]
source = (root / 'src/server/Services/WorldService.luau').read_text(encoding='utf-8-sig')
block = source.split('-- BEGIN REVIEWED WALKING INITIALIZER', 1)[1].split('-- END REVIEWED WALKING INITIALIZER', 1)[0]
cases = r'''
local function check(mode)
    local folder={};local walking=nil
    local walkingPolicy={Session={},Gate={},Notify={}}
    local made,destroyed=0,0
    local wallDetached=false
    local quality={}
    local function descriptor(id)
        made+=1
        return {id=id,geometry={IsDescendantOf=function(_,target) return target==folder and mode~="wrong-parent" end},
            isReady=function() return mode~="not-ready" end}
    end
    quality.buildContinuousCorridor=function()
        wallDetached=true
        if mode=="first-error" then error("first construction failed") end
        return descriptor("city_greenwood")
    end
    quality.buildGreenwoodIronveilCorridor=function()
        if mode=="second-error" then error("second construction failed") end
        return descriptor("greenwood_ironveil_south")
    end
    quality.destroy=function() destroyed+=1;wallDetached=false end
    local ok,problem=pcall(function()
__ACTUAL_BLOCK__
    end)
    if mode=="success" then
        assert(ok and destroyed==0 and made==2 and wallDetached)
        assert(#walking.Routes==2 and walking.Routes[2].id=="greenwood_ironveil_south")
        assert(walking.Session==walkingPolicy.Session and walking.Gate==walkingPolicy.Gate and walking.Notify==walkingPolicy.Notify)
    else
        assert(not ok and destroyed==1 and not wallDetached and walking==nil,mode)
        assert(type(problem)=="string" and #problem>0)
    end
    print("PASS actual WorldService initializer",mode)
end
for _,mode in ipairs({"success","first-error","second-error","not-ready","wrong-parent"}) do check(mode) end
'''
out = root / 'build/walking-initializer-check.luau'
out.write_text(cases.replace('__ACTUAL_BLOCK__', block), encoding='utf-8')
subprocess.run([str(root / '.tools/luau/luau.exe'), str(out)], cwd=root, check=True)
