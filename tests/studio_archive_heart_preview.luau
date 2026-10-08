--!strict
-- Isolated native encounter setup. Synthetic eligibility only; never writes a profile.
return function(mode:string?,class:string?,language:string?):any
 assert(game:GetService("RunService"):IsStudio()and game.PlaceId==0 and game.GameId==0)
 local server=game.ServerScriptService.Server;assert(require(server.Config.Runtime).StudioPersistence=="Memory")
 local player=assert(game.Players:GetPlayers()[1]);local character=assert(player.Character)
 local m=mode or "keeper";local def=require(server.Config.ArchiveHeartEncounters).Modes[m];assert(def)
 local data={character={classId=class or "Mage",level=def.Level},personalGuild={buildings={guildHall=def.Hall}},progression={campaign={claimed=def.Claimed,objectives=if def.Prerequisite then {[def.Prerequisite]=true}else {}}},quests={},expansion={tower={}},settings={language=language or "en"}}
 local receipts={};local arena=require(server.Services.ArchiveHeartArena)(player,data,m,"native_fixture",Vector3.new(3600,100,1400),function()return player.Character==character end,function(receipt)table.insert(receipts,receipt);return true end)
 local snapshot=Instance.new("BindableFunction");snapshot.Name="FixtureSnapshot";snapshot.OnInvoke=function()return {state=arena.Snapshot(),receipts=receipts,profileWrites=0}end;snapshot.Parent=arena.model
 local clean=Instance.new("BindableFunction");clean.Name="FixtureCleanup";clean.OnInvoke=function()arena.Destroy();return true end;clean.Parent=arena.model
 return {mode=m,class=data.character.classId,temporaryFixture=true,profileWrites=0}
end
