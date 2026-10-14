-- Local client rendering fixture. Does not change saved class or progress.
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0)
local R=game.ReplicatedStorage.GuildborneRemotes;local view=nil
local id="availability-ui-probe"
local conn=R.State.OnClientEvent:Connect(function(v)if v.requestId==id then view=v end end)
R.Command:FireServer({version=1,requestId=id,revision=0,action="GetState",args={}})
local deadline=os.clock()+8;repeat task.wait(.1)until view or os.clock()>deadline
conn:Disconnect();assert(view,"Snapshot timeout")
assert(view.catalog.ReleaseContent.BlockedTasks.ashen_watch and view.catalog.ReleaseContent.TowerUnavailable)
assert(view.data.settings==nil,"Fixture must match actual projected language contract")
local U=require(game.ReplicatedStorage.Shared.Util.TableUtil)
local d=U.copy(view.data);d.character.classId="Warrior";d.character.level=10;d.character.xp=450
d.releaseAdvancementProblems={player={berserker="ClassMentorRequired",duelist="ClassMentorRequired"}}
local root=Instance.new("Frame");root.Name="ReleaseAvailabilityFixture"
local callbacks={};local labels={}
local ui={scroll=root,T=function(s)return s end,render=function()end,navigate=function()end,explore=function()end,act=function()error("Fixture must never send an action")end}
ui.card=function(parent,title)local f=Instance.new("Frame");f.Parent=parent;table.insert(labels,title);return f end
ui.text=function(parent,value)local t=Instance.new("TextLabel");t.Text=value;t.Parent=parent;table.insert(labels,value);return t end
ui.button=function(parent,label,enabled,callback)local b=Instance.new("TextButton");b.Text=label;b.Active=enabled;b.Parent=parent;callbacks[label]={enabled=enabled,callback=callback};return b end
local ok,problem=pcall(function()
 local draw=require(game.Players.LocalPlayer.PlayerScripts.Client.UI.ExpansionView)(ui)
 draw("Skills",d,view.catalog,false)
 local b=root:FindFirstChild("Advance_berserker",true);assert(b and not b.Active)
 assert(b.Text=="Complete the Class2 mentor chapter first.")
 root:ClearAllChildren();table.clear(callbacks);draw("Tower",d,view.catalog,false)
 assert(not callbacks["Begin at floor 1"] and not callbacks["Resume at floor 6"] and not callbacks["Enter floor"])
 d.expansion.tower.active={state="Ready",floor=1};draw("Tower",d,view.catalog,false)
 assert(callbacks["Leave tower"] and callbacks["Leave tower"].enabled)
end)
root:Destroy();assert(ok,problem)
return {status="PASS",kind="Synthetic native UI fixture with actual snapshot shape",skillsNoSettings=true,mentorDisabled=true,towerExitRetained=true,profileMutation=false}
