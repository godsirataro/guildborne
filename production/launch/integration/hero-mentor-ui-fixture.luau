assert(game.PlaceId==0 and game.GameId==0)
local p=game.Players.LocalPlayer
local draw=require(p.PlayerScripts.Client.UI.ExpansionView)
local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local gui=Instance.new("ScreenGui");gui.Name="HeroMentorUIFixture";gui.Parent=p.PlayerGui
local host=Instance.new("ScrollingFrame");host.Size=UDim2.fromOffset(640,650);host.Position=UDim2.fromOffset(30,30);host.AutomaticCanvasSize=Enum.AutomaticSize.Y;host.Parent=gui
Instance.new("UIListLayout",host)
local results={}
local ok,err=pcall(function()
for _,lang in ipairs({"en","th"})do
host:ClearAllChildren();Instance.new("UIListLayout",host)
local callbacks={}
local function T(s,v)return locale.translate(lang,s,v)end
local function text(parent,s,size)local x=Instance.new("TextLabel");x.Size=UDim2.new(1,0,0,36);x.TextWrapped=true;x.TextSize=size or 16;x.Text=T(s);x.Parent=parent;return x end
local function card(parent,s)local x=Instance.new("Frame");x.Size=UDim2.new(1,0,0,0);x.AutomaticSize=Enum.AutomaticSize.Y;x.Parent=parent;Instance.new("UIListLayout",x);text(x,s);return x end
local function button(parent,s,enabled,cb)local x=Instance.new("TextButton");x.Size=UDim2.new(1,0,0,52);x.TextWrapped=true;x.TextSize=16;x.Text=T(s);x.Active=enabled;x.Selectable=enabled;x.Parent=parent;callbacks[x]=cb;return x end
local render=draw({scroll=host,T=T,text=text,card=card,button=button,act=function()error("No network allowed")end,navigate=function()end,render=function()end})
local data={language=lang,character={classId="Warrior",level=35},adventurers={h1={name="Rowan",rank="A",classId="Warrior",level=35}},progression={ruleset="guildborne.progression.2"},quests={firstClears={quarry_patrol=true}},expansion={actors={h1={tier=1,skills={}}},gathered={},buildings={},tower={highest=5}},heroMentor={h1={berserker={ready=false}}}}
local catalog={Character={Classes={Warrior={SkillId="cleave"}}}}
render("Skills",data,catalog,false);local actor=host:FindFirstChild("SkillActor",true);callbacks[actor]()
for _,case in ipairs({"idle","Active","Saving","partyRemoved","dispatched"})do
host:ClearAllChildren();Instance.new("UIListLayout",host)
data.heroMentorSession=if case=="Active" or case=="Saving" then {status=case,actorId="h1",pathId="berserker"}else nil
data.heroMentor.h1.berserker={ready=case=="partyRemoved" or case=="dispatched",advanceProblem=if case=="partyRemoved" then "PartyRequired" elseif case=="dispatched" then "FinishExpedition" else "HeroMentorRequired"}
render("Skills",data,catalog,false);task.wait(.05)
local train=assert(host:FindFirstChild("TrainHero_berserker",true))
local cancel=host:FindFirstChild("CancelHeroMentor",true)
local advance=assert(host:FindFirstChild("Advance_berserker",true))
assert(train.Active==(case=="idle"),"Train "..case)
assert((cancel~=nil)==(case=="Active" or case=="Saving"),"Cancel visibility "..case)
if cancel then assert(cancel.Active==(case=="Active"),"Cancel enabled "..case)end
assert(not advance.Active,"Advance "..case)
for _,x in ipairs(host:GetDescendants())do if x:IsA("TextLabel")or x:IsA("TextButton")then assert(not x.Text:find("HeroMentor",1,true) and not x.Text:find("PartyRequired",1,true) and not x.Text:find("FinishExpedition",1,true),"Raw code")end end
table.insert(results,{language=lang,state=case,train=train.Active,cancel=if cancel then cancel.Active else "absent",advance=advance.Active})
end end end)
gui:Destroy();assert(ok,tostring(err));return {synthetic=true,noProfileWrites=true,cases=results}
