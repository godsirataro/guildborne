--!strict
-- Isolated normal-input combat fixture. Temporary arena stats only; no profile grants.
local arena:any=nil;local receipts=0;local selected="";local live=false
local S={}
function S.Start(class:string,language:string):any
 assert(({Warrior=true,Knight=true,Archer=true,Mage=true,Priest=true})[class])
 if arena then arena.Destroy();arena=nil end
 local p=assert(game.Players:GetPlayers()[1]);selected=class;receipts=0;live=true
 local data={settings={language=language},character={classId=class,level=100},personalGuild={buildings={guildHall=17}},progression={campaign={claimed=35,objectives={}}},quests={},expansion={tower={}}}
 arena=require(game.ServerScriptService.Server.Services.ArchiveHeartArena)(p,data,"keeper","root:"..class,Vector3.new(-2000,100,0),function()return live end,function(receipt)
  assert(receipt.owner==p.UserId and receipt.args.objective=="complete_keeper_of_names");receipts+=1;return true
 end)
 return S.Read()
end
function S.Read():any
 local p=game.Players:GetPlayers()[1];local pos=p and p.Character and p.Character:GetPivot().Position
 return {class=selected,origin={x=-2000,y=100,z=0},position=pos and {x=pos.X,y=pos.Y,z=pos.Z},state=arena and arena.Snapshot(),receipts=receipts,profileWrites=0}
end
function S.Destroy()live=false;if arena then arena.Destroy();arena=nil end end
return S
