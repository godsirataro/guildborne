--!strict
-- Opt-in domain, bound only in the memory-only Novice preview.
-- Mutations run on disposable candidates. Only server world/trial adapters may
-- call observe/trialWon; never accept those receipts from client payloads.
return function(content:any,util:any,economy:any,config:any)
 local S={}
 function S.receipt(record:any,command:any):(any,any,any)
  local copy=util.copy(record);local problem:string?
  if command.action=="NoviceObjective" then problem=S.observe(copy.data,command.args.objective,command.args.branch)
  elseif command.action=="NoviceTrial" then problem=S.trialWon(copy.data,command.args.classId)
  else return nil,{code="InvalidAction"},{} end
  if problem then return nil,{code=problem},{} end
  return copy,{code="OK"},{{name="novice_objective_observed",payload={action=command.action,objective=command.args.objective,classId=command.args.classId}}}
 end
 function S.new():any return {version=config.Version,claimed=0,objectives={}} end
 local function state(data:any):any return data.progression.novice end
 function S.validate(data:any)
  local s=state(data);assert(type(s)=="table" and s.version==config.Version)
  assert(content.ProgressionMode(data)==content.ProgressionRulesets.Novice)
  assert(util.integer(s.claimed,0,6) and type(s.objectives)=="table")
  for key in pairs(s) do assert(({version=true,claimed=true,objectives=true,branch=true,trialClass=true,founderHero=true})[key],"Unknown story field") end
  local def=config.Chapters[s.claimed+1]
  for objective,value in pairs(s.objectives) do assert(def and table.find(def.Objectives,objective) and value==true) end
  if def and s.claimed~=4 then
   local gap=false
   for _,objective in ipairs(def.Objectives) do
    if s.objectives[objective] then assert(not gap,"Skipped story objective") else gap=true end
   end
  end
  assert(s.branch==nil or s.branch=="rescue" or s.branch=="supplies")
  if s.claimed<2 then assert(s.branch==nil) elseif s.claimed>=3 then assert(s.branch~=nil) end
  if s.claimed==2 then assert((s.branch~=nil)==(s.objectives.caravan_choice==true)) end
  if s.trialClass then assert(s.claimed>=5 and content.Character.Classes[s.trialClass] and data.character.level>=10) end
  if data.character.classId then assert(s.trialClass==data.character.classId and s.claimed>=5) end
  if s.claimed==5 and next(s.objectives) then assert(data.character.classId) end
  if s.claimed==6 then
   assert(data.character.classId and data.personalGuild.buildings.guildHall>=1 and type(s.founderHero)=="string")
   assert(data.adventurers[s.founderHero],"Missing founding hero")
  else assert(s.founderHero==nil and data.personalGuild.buildings.guildHall==0) end
  local minimumXP=0;for i=1,s.claimed do minimumXP+=config.Chapters[i].XP end
  assert(data.character.xp>=minimumXP,"Missing chapter XP")
 end
 local function enabled(data:any):boolean
  return content.ProgressionMode(data)==content.ProgressionRulesets.Novice and state(data)~=nil
 end
 function S.observe(data:any,objective:string,branch:string?):string?
  if not enabled(data) then return "NoviceUnavailable" end
  local s=state(data);local def=config.Chapters[s.claimed+1]
  if not def or not table.find(def.Objectives,objective) then return "WrongObjective" end
  if data.character.level<def.Level then return "LevelRequired" end
  if s.claimed==5 and not data.character.classId then return "ClassTrialRequired" end
  if s.objectives[objective] then return "AlreadyObserved" end
  -- Lessons and story beats are ordered; the five class previews can be tried in any order.
  local index=table.find(def.Objectives,objective) :: number
  if s.claimed~=4 and index>1 and not s.objectives[def.Objectives[index-1]] then return "PreviousObjectiveRequired" end
  if objective=="caravan_choice" then
   if branch~="rescue" and branch~="supplies" then return "InvalidChoice" end
   s.branch=branch
  elseif branch~=nil then return "InvalidChoice" end
  s.objectives[objective]=true;return nil
 end
 function S.trialWon(data:any,classId:string):string?
  if not enabled(data) then return "NoviceUnavailable" end
  local s=state(data)
  if not content.Character.Classes[classId] then return "InvalidClass" end
  if s.claimed~=5 or data.character.level<10 then return "ClassTrialLocked" end
  if data.character.classId then return "ClassAlreadySelected" end
  if s.trialClass==classId then return "AlreadyObserved" end
  s.trialClass=classId;return nil
 end
 function S.selectClass(data:any,classId:string,emit:any):string?
  if not enabled(data) then return "NoviceUnavailable" end
  local s=state(data);local def=content.Character.Classes[classId]
  if not def then return "InvalidClass" end
  if data.character.classId then return "ClassAlreadySelected" end
  if s.claimed~=5 or s.trialClass~=classId or data.character.level<10 then return "ClassTrialRequired" end
  local problem=economy.items(data,{{Id=def.Weapon,Quantity=1}},"novice:class",emit)
  if problem then return problem end
  local c=data.character;c.classId=classId;c.classPathId=def.PathId;c.skillId=def.SkillId
  c.equipmentSlots.weapon="novice:class:1"
  emit("novice_class_selected",{classId=classId});return nil
 end
 function S.claim(data:any,chapterId:string,heroClass:string?,emit:any):string?
  if not enabled(data) then return "NoviceUnavailable" end
  local s=state(data);local def=config.Chapters[s.claimed+1]
  if not def or def.Id~=chapterId then return "ChapterNotActive" end
  if data.character.level<def.Level then return "LevelRequired" end
  for _,objective in ipairs(def.Objectives) do if not s.objectives[objective] then return "ChapterIncomplete" end end
  if data.character.xp+def.XP>content.Limits.XP then return "XPCap" end
  if s.claimed==5 then
   if not data.character.classId then return "ClassTrialRequired" end
   local hero=heroClass and content.Adventurers[heroClass]
   if not hero then return "InvalidAdventurer" end
   if next(data.adventurers) or data.personalGuild.buildings.guildHall~=0 then return "GuildAlreadyFounded" end
   local problem=economy.items(data,{{Id=content.Character.Classes[hero.Class].Weapon,Quantity=1}},"novice:founder",emit)
   if problem then return problem end
   local id="a:"..hero.Id
   data.personalGuild.buildings.guildHall=1
   data.adventurers[id]={id=id,name=hero.Name,classId=hero.Class,rank=config.HeroRank,level=config.HeroLevel,xp=config.HeroXP,baseStats=util.copy(hero.Stats),equipmentSlots={weapon="novice:founder:1"}}
   data.progression.recruitedClasses[hero.Class]=true;data.party.adventurerIds={id};s.founderHero=id
   data.progression.welcomeSeen=true;data.progression.tutorialStep="complete";data.progression.tutorialCompleted=true
   emit("novice_guild_founded",{heroId=id,classId=hero.Class,hallLevel=1,goldCost=0})
  elseif heroClass~=nil then return "UnexpectedHeroChoice" end
  data.character.xp+=def.XP
  data.character.level=content:LevelFromXP(data.character.xp,content.ProfileLevelCap(data))
  s.claimed+=1;s.objectives={};emit("novice_chapter_claimed",{chapterId=chapterId,xp=def.XP});return nil
 end
 return S
end
