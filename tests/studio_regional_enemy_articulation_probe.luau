--!strict
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local services=game.ServerScriptService.Server.Services
    local scenes={};local checks=0;local motors=0;local pieces=0
    local function check(ok:boolean,message:string?)assert(ok,message or ("Regional rig "..checks));checks+=1 end
    local ok,result=pcall(function():any
        for index,region in ipairs({"Greenwood","Ironveil","Ashen"}) do
            local bridge=require(services.AdventureCombatBridge)(region,Vector3.new(29000+index*350,100,0),-800,{},
                {hit=function()return 0 end,heal=function()return 0 end},function()error("Unexpected reward")end)
            table.insert(scenes,bridge)
            for _,actor in ipairs(bridge.actors) do
                check(actor.root.Anchored and not actor.root.CanCollide)
                check(actor.model.PrimaryPart==actor.root)
                check((actor.model:GetPivot().Position-Vector3.new(actor.home.x,actor.home.y,actor.home.z)).Magnitude<.001)
                check(actor.model:GetAttribute("EnemyArticulated")==true)
                check(game:GetService("CollectionService"):HasTag(actor.model,"GuildborneAnimatedEnemy"))
                local before=#actor.model:GetDescendants();require(services.EnemyArticulation)(actor.model,false);check(#actor.model:GetDescendants()==before)
                local jointCount=0
                for _,p in ipairs(actor.model:GetDescendants()) do
                    if p:IsA("Motor6D") then
                        motors+=1;jointCount+=1;check(p.Part0~=nil and p.Part1~=nil)
                        check((p.Part0.CFrame*p.C0).Position:FuzzyEq(p.Part1.Position,.001))
                    elseif p:IsA("BasePart") and p:GetAttribute("BindBone") then
                        pieces+=1;check(not p.Anchored and p.Massless and not p.CanCollide and not p.CanQuery)
                        local weld=p:FindFirstChild("EnemyArtWeld") :: WeldConstraint?;check(weld~=nil and weld.Part1==p)
                        local bone=p:GetAttribute("BindBone") :: string
                        if bone:find("FrontLeft") then check(p:GetAttribute("EnemyLimb")=="LeftArm")
                        elseif bone:find("RearRight") then check(p:GetAttribute("EnemyLimb")=="RightLeg") end
                    end
                end
                check(jointCount==6)
            end
        end
        check(motors==72 and pieces==334)
        return {actors=12,motors=motors,artPieces=pieces,checks=checks,profileWrites=0}
    end)
    for _,scene in ipairs(scenes) do scene.Destroy() end
    assert(ok,tostring(result));return result
end
