-- Local Memory fixture; invokes production spatial validation with isolated actor/plot.
return function()
 assert(game:GetService('RunService'):IsStudio() and game.PlaceId==0 and game.GameId==0)
 local server=game.ServerScriptService.Server
 assert(require(server.Config.Runtime).StudioPersistence=='Memory')
 local world=workspace.GuildborneWorld
 local city=world.City
 local forge=city.Market.Blacksmith.CityForgeStation
 local tavern=city.Tavern['The Hearth and Banner'].CityTavernStation
 local tests={}
 local container=Instance.new('Model');container.Name='CityServicesProbe';container.Parent=world
 local originalParent=forge.Parent
 local function check(name,value)assert(value,name);table.insert(tests,name)end
 local ok,problem=xpcall(function()
  for _,entry in ipairs({{forge,'Crafting'},{tavern,'Tavern'}})do
   local anchor,tab=entry[1],entry[2]
   check(tab..' physical anchor',anchor:IsA('BasePart') and not anchor.CanCollide and not anchor.CanTouch and anchor:GetAttribute('CityService')==tab)
   local prompt=anchor:FindFirstChildOfClass('ProximityPrompt')
   check(tab..' prompt',prompt~=nil and prompt.MaxActivationDistance<=14)
  end
  check('registered forge',game:GetService('CollectionService'):HasTag(forge,'GuildborneCityCraftingStation'))
  local char=Instance.new('Model');char.Name='Actor';char.Parent=container
  local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=char
  local hum=Instance.new('Humanoid');hum.Parent=char
  char:SetAttribute('CombatHealth',50)
  local owner={Character=char,GetAttribute=function()return 'City'end}
  local plot={model=container,origin=Vector3.new(7000,0,6000),nodes={}}
  local make=require(server.Services.ExpansionWorld)
  local service=make(function()end,function()end,nil,forge)
  local function validate(action)return service.validate(owner,plot,action or 'CraftItem',{})end
  root.Position=forge.Position
  check('craft at forge',validate()==nil)
  root.Position=forge.Position+Vector3.new(14,0,0);check('inclusive radius',validate()==nil)
  root.Position=forge.Position+Vector3.new(14.1,0,0);check('outside radius denied',validate()~=nil)
  root.Position=forge.Position
  for _,action in ipairs({'PlaceBuilding','CraftFurniture','MoveBuilding','LearnSkill','SelectRace','StartTower'})do
   check('city denies '..action,validate(action)~=nil)
  end
  check('missing plot denied',service.validate(owner,nil,'CraftItem',{})~=nil)
  local missing=make(function()end,function()end,nil,nil)
  check('missing station denied',missing.validate(owner,plot,'CraftItem',{})~=nil)
  container:SetAttribute('InCombat',true);check('combat denied',validate()~=nil);container:SetAttribute('InCombat',false)
  local invalidHealth:{any}={0,-1,math.huge,'bad'}
  for _,health in ipairs(invalidHealth)do char:SetAttribute('CombatHealth',health);check('invalid combat health '..tostring(health),validate()~=nil)end
  char:SetAttribute('CombatHealth',50)
  hum.Parent=nil;check('missing humanoid denied',validate()~=nil);hum.Parent=char
  hum.Health=0;check('dead humanoid denied',validate()~=nil);hum.Health=100
  forge.Parent=container;check('moved station denied',validate()~=nil)
  forge.Parent=nil;check('removed station denied',validate()~=nil);forge.Parent=originalParent
  root.Parent=container;check('missing root denied',validate()~=nil);root.Parent=char
  root.Position=Vector3.new(0/0,0,0);check('nonfinite position denied',validate()~=nil)
  root.Position=plot.origin;check('island crafting preserved',validate()==nil)
  check('island building preserved',validate('PlaceBuilding')==nil)
 end,debug.traceback)
 forge.Parent=originalParent;container:Destroy()
 return {ok=ok,problem=if ok then nil else tostring(problem),tests=tests,syntheticActor=true,actualExpansionWorld=true,cleanup=world:FindFirstChild('CityServicesProbe')==nil}
end
