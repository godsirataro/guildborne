-- Disposable Client Play fixture; copied presentation only, capture-only command callback.
assert(game:GetService('RunService'):IsStudio() and game.PlaceId==0 and game.GameId==0)
local player=game.Players.LocalPlayer
local observed
local connection=game.ReplicatedStorage.GuildborneRemotes.State.OnClientEvent:Connect(function(v)if v.data then observed=v end end)
local deadline=os.clock()+12
repeat task.wait(.1)until observed or os.clock()>deadline
connection:Disconnect();assert(observed,'No passive state packet')
local view=require(game.ReplicatedStorage.Shared.Util.TableUtil).copy(observed)
local char=assert(player.Character);local original=char:GetPivot()
local root=assert(char:FindFirstChild('HumanoidRootPart'));local anchored=root.Anchored
local health=char:GetAttribute('CombatHealth')
local world=workspace.GuildborneWorld
local forge=world.City.Market.Blacksmith.CityForgeStation;local stationParent=forge.Parent
local owned
for _,v in ipairs(world:GetChildren())do if v.Name=='PersonalGuild' and v:GetAttribute('OwnerUserId')==player.UserId then owned=v end end
assert(owned,'Expected owned plot for simulated streaming test')
local clone,gui
local result={syntheticPresentation=true,simulatedStreaming=true,commands=0,checks={}}
local function check(label,value)assert(value,label);table.insert(result.checks,label)end
local ok,problem=xpcall(function()
 local before={};for _,v in ipairs(player.PlayerGui:GetChildren())do before[v]=true end
 clone=player.PlayerScripts.Client.UI:Clone();clone.Name='P1FixtureUI';clone.Parent=player.PlayerScripts.Client
 local ui=require(clone.SliceUI)(function()result.commands+=1 end)
 for _,v in ipairs(player.PlayerGui:GetChildren())do if not before[v] and v.Name=='GuildborneUI'then gui=v end end
 assert(gui);gui.Name='P1CraftingFixtureUI'
 view.status='Active';view.mode='SYNTHETIC UI';view.navigate='Crafting'
 view.data.hallLevel=3;view.data.character.classId='Warrior';view.data.character.level=10
 view.data.progression.ruleset='guildborne.progression.2';view.data.progression.novice={claimed=6}
 view.data.expansion.buildings={['fixture:forge']={kind='forge',x=6,z=-4,rotation=0}}
 view.data.inventory.stacks.iron_ore=30;view.data.inventory.stacks.stone=30;view.data.inventory.stacks.iron_ingot=0
 view.data.inventory.nextEquipmentSequence=1;view.data.quests.active=nil;view.data.expansion.tower.active=nil
 view.data.language='en';char:SetAttribute('CombatHealth',50);root.Anchored=true
 char:PivotTo(CFrame.new(forge.Position+Vector3.new(0,1,0)))
 ui.Update(view);gui.TitleScreen.Visible=false;gui.ManagementPanel.Visible=true
 local function tick()for _=1,5 do task.wait(.1);ui.Tick()end end
 local function button()return assert(gui:FindFirstChild('Craft_iron_ingot',true))end
 check('English craft enabled at forge',button().Active)
 check('Dedicated view omits building management',gui:FindFirstChild('OpenLand',true)==nil)
 char:PivotTo(CFrame.new(forge.Position+Vector3.new(25,1,0)));tick()
 check('Walk out disables via Tick',not button().Active)
 result.englishDistanceText=button().Text
 check('Exact English location reason',result.englishDistanceText=='Visit your guild workshop or the city forge to craft.')
 char:PivotTo(CFrame.new(forge.Position+Vector3.new(0,1,0)));tick();check('Return enables via Tick',button().Active)
 owned.Parent=nil;tick();check('City remains available without island replica',button().Active)
 forge.Parent=nil;tick();check('Missing station disables',not button().Active)
 forge.Parent=stationParent;tick();check('Station restored enables',button().Active)
 owned.Parent=world
 view.data.language='th';ui.Update(view)
 check('Thai craft enabled',button().Active)
 char:PivotTo(CFrame.new(forge.Position+Vector3.new(25,1,0)));tick()
 check('Thai walk out disables',not button().Active)
 result.thaiDistanceText=button().Text
 check('Exact Thai location reason',result.thaiDistanceText==require(game.ReplicatedStorage.Shared.Config.Localization).translate('th',result.englishDistanceText))
 check('No commands sent',result.commands==0)
end,debug.traceback)
forge.Parent=stationParent;owned.Parent=world
char:PivotTo(original);root.Anchored=anchored;char:SetAttribute('CombatHealth',health)
if gui then gui:Destroy()end;if clone then clone:Destroy()end
result.ok=ok;result.problem=if ok then nil else tostring(problem);result.restored=true
return result
