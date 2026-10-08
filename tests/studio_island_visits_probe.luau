--!strict
-- Synthetic owner + actual offline character; no real friendship API or profile writes.
return function()
    assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
    local Players=game:GetService("Players");local player=Players:GetPlayers()[1]
    assert(player and player.Character);local original=player.Character:GetPivot()
    local make=require(game.ServerScriptService.Server.Services.IslandVisits)
    local fixture=Instance.new("Folder");fixture.Name="IslandVisitsProbe";fixture.Parent=workspace
    local owner:any={UserId=-9999,Name="SyntheticOwner",DisplayName="Synthetic owner",Parent=Players}
    local model=Instance.new("Model");model.Parent=fixture
    local origin=Vector3.new(4000,1,0)
    local ground=Instance.new("Part");ground.Size=Vector3.new(64,2,80);ground.Position=origin+Vector3.new(64,-1,0);ground.Anchored=true;ground.Parent=model
    local entry=Instance.new("Part");entry.Position=origin+Vector3.new(64,2,-58);entry.Anchored=true;entry.CanCollide=false;entry.Parent=fixture
    local ownModel=Instance.new("Model");ownModel.Parent=fixture
    local ownEntry=Instance.new("Part");ownEntry.Anchored=true;ownEntry.Position=Vector3.new(0,3,-58);ownEntry.Parent=fixture
    local plots:any={[player]={model=ownModel,origin=Vector3.new(0,1,0)},[owner]={model=model,origin=origin}}
    local service:any=nil;local returns=0;local checks=0
    local function check(value:boolean)assert(value,"Island visit check "..(checks+1));checks+=1 end
    local function start(mode:string,lookup:any?)
        if service then service.destroy() end
        for _,part in ipairs({entry,ownEntry}) do for _,p in ipairs(part:GetChildren()) do p:Destroy() end end
        service=make(plots,{Visit=function(who:Player,target:Vector3)
            (who.Character :: Model):PivotTo(CFrame.new(target));return true
        end,Travel=function(who:Player,_zone:string)
            returns+=1;(who.Character :: Model):PivotTo(CFrame.new(0,5,23));return true
        end},lookup)
        service.add(player,ownEntry);service.update(player,{guildLand={accessMode="Private"}},true)
        service.add(owner,entry);service.update(owner,{guildLand={accessMode=mode}},true);
        (player.Character :: Model):PivotTo(CFrame.new(entry.Position+Vector3.new(0,2,0)))
    end
    local ok,reason=pcall(function()
        game:GetService("RunService").Heartbeat:Wait()
        start("Private");check(#service.directory(player)==1);service.enter(player,owner);check(player:GetAttribute("IslandVisitProblem")=="IslandPrivate")
        start("Public");check(#service.directory(player)==2);service.enter(player,owner);check(player:GetAttribute("VisitingIslandOwner")==owner.UserId)
        check(((player.Character :: Model):GetPivot().Position-(origin+Vector3.new(64,5,4))).Magnitude<1)
        check(#service.roster(player)==0);local roster=service.roster(owner)
        check(#roster==1 and roster[1].visitorId==tostring(player.UserId))
        roster[1].visitorId="tampered";check(service.roster(owner)[1].visitorId==tostring(player.UserId))
        check(service.kick(player,player)==false)
        local before=returns;service.update(owner,{guildLand={accessMode="Private"}},true)
        check(returns==before+1);check(player:GetAttribute("VisitingIslandOwner")==nil)
        start("Friends",function()return false end);service.enter(player,owner);check(player:GetAttribute("IslandVisitProblem")=="FriendsOnly")
        start("Friends",function()error("lookup unavailable")end);service.enter(player,owner);check(player:GetAttribute("IslandVisitProblem")=="FriendshipUnavailable")
        start("Friends",function()return true end);service.enter(player,owner);check(player:GetAttribute("VisitingIslandOwner")==owner.UserId)
        before=returns;service.remove(owner);check(returns==before+1);check(player:GetAttribute("VisitingIslandOwner")==nil)
        start("Friends",function()service.update(owner,{guildLand={accessMode="Private"}},true);return true end)
        service.enter(player,owner);check(player:GetAttribute("IslandVisitProblem")=="IslandPrivate")
        start("Friends",function()service.update(player,{},false);return true end)
        service.enter(player,owner);check(player:GetAttribute("IslandVisitProblem")=="IslandUnavailable")
        start("Public");service.enter(player,owner);before=returns
        check(service.kick(owner,player)==true);check(returns==before+1)
        check(#service.roster(owner)==0 and player:GetAttribute("VisitingIslandOwner")==nil)
        check(player:GetAttribute("IslandVisitProblem")=="VisitBlocked")
        start("Public");service.update(owner,{},false);service.enter(player,owner);check(player:GetAttribute("IslandVisitProblem")=="IslandUnavailable")
        start("Private");before=returns;(player.Character :: Model):PivotTo(CFrame.new(origin+Vector3.new(64,5,4)))
        task.wait(.7);check(returns==before+1);check(player:GetAttribute("IslandVisitProblem")=="IslandAccessDenied")
    end)
    if service then service.destroy() end
    fixture:Destroy();(player.Character :: Model):PivotTo(original)
    player:SetAttribute("VisitingIslandOwner",nil);player:SetAttribute("IslandVisitProblem",nil);player:SetAttribute("IslandVisitNoticeAt",nil)
    assert(ok,reason);return {checks=checks,realFriendshipCalls=0,profileWrites=0,fixtureDestroyed=true}
end
