--!strict
-- Synthetic participants/reward adapter only. Never passes Players or persistent services.
return function():any
    assert(game.PlaceId==0 and game.GameId==0)
    local create=require(game.ServerScriptService.Server.Services.AdventureEncounterSession)
    local now=0;local attempts={};local members={"player","a:Warrior"};local closePending=false
    local scene=create("Greenwood",Vector3.new(19000,100,0),-900,{
        Clock=function()return now end,
        Members=function()return members end,
        Reward=function(ticket:any):string
            table.insert(attempts,ticket);task.wait(.05)
            if closePending then return "Committed" end
            return if #attempts==1 then "Retry" else "Committed"
        end,
    })
    local ok,result=pcall(function():any
        local actor=scene.actors[1];actor.health=0
        scene.Step({},now,.2);scene.Step({},now,.2)
        assert(#attempts==1,"Duplicate concurrent reward")
        members[1]="changed-after-death"
        assert(attempts[1].members[2]=="player","Participation snapshot mutated")
        now=1;task.wait(.1);assert(scene.State(actor.id).state=="Pending")
        scene.Suspend();scene.Suspend();assert(scene.model.Parent==nil)
        now=100;scene.Step({},now,.2);assert(#attempts==1 and actor.health==0)
        scene.Resume();scene.Resume();assert(scene.model.Parent==workspace and scene.State(actor.id).generation==1)
        now=1
        scene.Step({},now,.2);assert(#attempts==1,"Retry cooldown bypass")
        now=3;scene.Step({},now,.2);assert(#attempts==2)
        assert(attempts[1].deathId==attempts[2].deathId,"Retry changed death identity")
        task.wait(.1);assert(scene.State(actor.id).state=="Rewarded")
        now=17.9;scene.Step({},now,.2);assert(actor.health==0,"Early respawn")
        now=18;scene.Step({},now,.2);assert(actor.health==actor.maxHealth and scene.State(actor.id).generation==2)
        members={};actor.health=0;now=20;scene.Step({},now,.2)
        assert(#attempts==2 and scene.State(actor.id).state=="Unrewarded","No participants received reward")
        now=38;scene.Step({},now,.2);assert(actor.health==actor.maxHealth)
        members={"player"};actor.health=0;now=40;closePending=true;scene.Step({},now,.2)
        assert(#attempts==3 and attempts[3].deathId~=attempts[1].deathId)
        scene.Destroy();scene.Destroy();task.wait(.1)
        assert(scene.model.Parent==nil and scene.State(actor.id)==nil)
        return {rewardAttempts=#attempts,rewardIdentities=2,respawnGenerations=3,suspendPreservesPending=true,closeDuringPending=true,profileWrites=0}
    end)
    scene.Destroy();assert(ok,tostring(result));return result
end
