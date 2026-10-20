"""Run failure injection against the actual WorldService initializer block."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[3]
source = (root / 'src/server/Services/WorldService.luau').read_text(encoding='utf-8-sig')
block = source.split('-- BEGIN REVIEWED WALKING INITIALIZER', 1)[1].split('-- END REVIEWED WALKING INITIALIZER', 1)[0]
cases = r'''
local function check(mode,full)
    local folder={};local walking=nil
    local walkingPolicy={Session={},Gate={},Notify={},FullConnectedWorld=full}
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
    quality.buildGreenwoodEastJunction=function()
        assert(full==true,"Junction builder called without exact opt-in")
        -- A separate owned support handle, never counted as a registered route.
        local alive=true
        local geometry={IsDescendantOf=function(_,target)return alive and target==folder and mode~="wrong-parent"end}
        return {id="greenwood_east_junction",geometry=geometry,ownedModel=geometry,
            isReady=function()return alive and mode~="not-ready"end,
            destroy=function()alive=false end}
    end
    quality.buildIronveilAshenCorridor=function()
        assert(full==true,"Third builder called without exact opt-in")
        if mode=="third-error" then error("third construction failed") end
        local route=descriptor("ironveil_ashen_south")
        if mode=="third-not-ready" then route.isReady=function()return false end end
        if mode=="third-wrong-parent" then route.geometry.IsDescendantOf=function()return false end end
        return route
    end
    quality.destroy=function() destroyed+=1;wallDetached=false end
    local ok,problem=pcall(function()
__ACTUAL_BLOCK__
    end)
    if mode=="success" then
        local expected=if full==true then 3 else 2
        assert(ok and destroyed==0 and made==expected and wallDetached)
        assert(#walking.Routes==expected and walking.Routes[2].id=="greenwood_ironveil_south")
        if full==true then assert(walking.Routes[3].id=="ironveil_ashen_south") end
        assert(walking.Session==walkingPolicy.Session and walking.Gate==walkingPolicy.Gate and walking.Notify==walkingPolicy.Notify)
    else
        assert(not ok and destroyed==1 and not wallDetached and walking==nil,mode)
        assert(type(problem)=="string" and #problem>0)
    end
    print("PASS actual WorldService initializer",mode,tostring(full))
end
for _,mode in ipairs({"success","first-error","second-error","not-ready","wrong-parent"}) do check(mode);check(mode,true) end
for _,flag in ipairs({false,"true",1}) do check("success",flag) end
for _,mode in ipairs({"third-error","third-not-ready","third-wrong-parent"}) do check(mode,true) end
'''
out = root / 'build/walking-initializer-check.luau'
out.write_text(cases.replace('__ACTUAL_BLOCK__', block), encoding='utf-8')
subprocess.run([str(root / '.tools/luau/luau.exe'), str(out)], cwd=root, check=True)
