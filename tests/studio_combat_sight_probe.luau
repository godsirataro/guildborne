--!strict
return function():any
    local fixture=Instance.new("Folder");fixture.Name="CombatSightProbe";fixture.Parent=workspace
    local checks=0
    local function check(ok:boolean)assert(ok,"Combat sight "..checks);checks+=1 end
    local ok,problem=pcall(function()
        local function part(name:string,position:Vector3,size:Vector3,solid:boolean):Part
            local p=Instance.new("Part");p.Name=name;p.Position=position;p.Size=size;p.Anchored=true;p.CanCollide=solid;p.Parent=fixture;return p
        end
        local a={root=part("Actor",Vector3.new(5000,10,5000),Vector3.one,false)}
        local b={root=part("Target",Vector3.new(5000,10,5020),Vector3.one,false)}
        local sight=require(game.ServerScriptService.Server.Services.CombatLineOfSight)(fixture)
        check(sight(a,b));check(not sight(nil,b));check(not sight(a,{}))
        local wall=part("Wall",Vector3.new(5000,11,5010),Vector3.new(10,8,1),true)
        check(not sight(a,b));check(not sight(b,a))
        wall.CanQuery=false;check(not sight(a,b)) -- physical blockers still obstruct
        wall.CanCollide=false;check(sight(a,b))
        wall.CanQuery=true;check(sight(a,b)) -- queryable visual VFX are not walls
        wall.CanCollide=true;wall.Position+=Vector3.new(20,0,0);check(sight(a,b))
        b.root.Position=a.root.Position;check(sight(a,b))
    end)
    fixture:Destroy();if not ok then error(tostring(problem)) end
    return {checks=checks,fixtureDestroyed=true,profileWrites=0}
end
