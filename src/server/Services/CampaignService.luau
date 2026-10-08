--!strict
-- Optional Chapter 01 domain. Apply only to disposable transaction candidates.
-- observe is private server evidence; never expose it as a client command.
return function(content:any,util:any,economy:any,config:any)
 local S={}
 function S.new():any return {version=config.Version,claimed=0,objectives={},choices={}}end
 local function available(data:any):boolean
  return content.ProgressionMode(data)==content.ProgressionRulesets.Novice and data.progression.novice and data.progression.novice.claimed==6 and data.personalGuild.buildings.guildHall>=1 and data.progression.campaign~=nil
 end
 function S.validate(data:any)
  local s=data.progression.campaign;assert(type(s)=="table"and s.version==config.Version)
  assert(content.ProgressionMode(data)==content.ProgressionRulesets.Novice)
  assert(util.integer(s.claimed,0,#config.Chapters)and type(s.objectives)=="table"and type(s.choices)=="table")
  for k in pairs(s)do assert(({version=true,claimed=true,objectives=true,choices=true,recruitHero=true,hallPermit=true})[k],"Unknown campaign field")end
  if s.claimed>0 or next(s.objectives)then assert(available(data),"Campaign before founding")end
  local chapter=config.Chapters[s.claimed+1]
  for i,c in ipairs(config.Chapters)do
   if c.Hall and (s.claimed>=i or (i==s.claimed+1 and next(s.objectives)))then assert(data.personalGuild.buildings.guildHall>=c.Hall,"Campaign before Hall upgrade")end
  end
  for id,value in pairs(s.objectives)do assert(chapter and table.find(chapter.Objectives,id)and value==true,"Unknown objective")end
  if chapter then local gap=false;for _,id in ipairs(chapter.Objectives)do if s.objectives[id]then assert(not gap,"Skipped campaign objective")else gap=true end end end
  for id,value in pairs(s.choices)do
   assert(config.Choices[id]and config.Choices[id][value],"Unknown campaign choice")
   local index=nil;for i,c in ipairs(config.Chapters)do if table.find(c.Objectives,id)then index=i end end
   assert(index and (s.claimed>=index or s.objectives[id]),"Choice before observation")
  end
  for i,c in ipairs(config.Chapters)do for _,id in ipairs(c.Objectives)do if config.Choices[id]and (s.claimed>=i or s.objectives[id])then assert(s.choices[id],"Missing campaign choice")end end end
  local recruit=false;local permit=nil
  for i=1,s.claimed do local done=config.Chapters[i];if done.Recruit then recruit=true end;if done.HallPermit then permit=done.HallPermit end end
  if recruit then assert(type(s.recruitHero)=="string"and data.adventurers[s.recruitHero],"Missing guaranteed recruit")else assert(s.recruitHero==nil)end
  assert(s.hallPermit==permit,"Invalid Hall permit")
  local minimum=450;for i=1,s.claimed do minimum+=config.Chapters[i].XP end
  if s.claimed>0 then assert(data.character.xp>=minimum,"Missing campaign XP")end
 end
 function S.observe(data:any,id:string,choice:string?):string?
  if not available(data)then return "CampaignLocked"end
  local s=data.progression.campaign;local c=config.Chapters[s.claimed+1]
  if not c or not table.find(c.Objectives,id)then return "WrongObjective"end
  if c.Hall and data.personalGuild.buildings.guildHall<c.Hall then return "CampaignHallRequired"end
  if data.character.level<c.Level then return "CampaignLevelRequired"end
  if s.objectives[id]then return "AlreadyObserved"end
  for _,prior in ipairs(c.Objectives)do if prior==id then break end;if not s.objectives[prior]then return "PreviousObjectiveRequired"end end
  if config.Choices[id]then if not config.Choices[id][choice]then return "InvalidCampaignChoice"end
  elseif choice~=nil then return "InvalidCampaignChoice"end
  s.objectives[id]=true;if choice then s.choices[id]=choice end;return nil
 end
 function S.claim(data:any,id:string,heroClass:string?,emit:any):string?
  if not available(data)then return "CampaignLocked"end
  local s=data.progression.campaign;local c=config.Chapters[s.claimed+1]
  if not c or c.Id~=id then return "ChapterNotActive"end
  if c.Hall and data.personalGuild.buildings.guildHall<c.Hall then return "CampaignHallRequired"end
  if data.character.level<c.Level then return "CampaignLevelRequired"end
  for _,objective in ipairs(c.Objectives)do if not s.objectives[objective]then return "ChapterIncomplete"end end
  if data.quests.active or data.expansion.tower.active then return "FinishExpedition"end
  if c.Recruit then
   if not heroClass or not content.Adventurers[heroClass]then return "InvalidClass"end
   if util.count(data.adventurers)>=content.RosterCapacity(data)then return "RosterFull"end
   if data.settlement.nextHero>=1000000000 then return "SequenceCap"end
  elseif heroClass~=nil then return "UnexpectedRecruitChoice"end
  local actors={data.character};local seen={};for _,actorId in ipairs(data.party.adventurerIds)do local actor=data.adventurers[actorId];if not actor or seen[actorId]then return "AdventurerNotOwned"end;seen[actorId]=true;table.insert(actors,actor)end
  for _,actor in ipairs(actors)do if actor.xp+c.XP>content.Limits.XP then return "XPCap"end end
  local problem=economy.gold(data,c.Gold,"CampaignReward",emit);if problem then return problem end
  if c.Items then problem=economy.items(data,c.Items,"campaign:"..c.Id,emit);if problem then return problem end end
  for _,actor in ipairs(actors)do actor.xp+=c.XP;actor.level=content:LevelFromXP(actor.xp,content.ProfileLevelCap(data))end
  if c.Recruit then
   local hero=content.Adventurers[heroClass];local nextId=data.settlement.nextHero;local actorId="h:"..nextId
   if data.adventurers[actorId]then return "DuplicateAdventurer"end
   local prefix="campaign:recruit:"..nextId;problem=economy.items(data,{{Id=content.Character.Classes[hero.Class].Weapon,Quantity=1}},prefix,emit);if problem then return problem end
   local xp=content.RecruitmentStartingXP(data)
   data.adventurers[actorId]={id=actorId,name=hero.Name,classId=hero.Class,rank="F",xp=xp,level=content:LevelFromXP(xp,content.ProfileLevelCap(data)),baseStats=util.copy(hero.Stats),equipmentSlots={weapon=prefix..":1"}}
   data.progression.recruitedClasses[hero.Class]=true;data.settlement.nextHero+=1;s.recruitHero=actorId
   emit("campaign_recruit_granted",{heroId=actorId,classId=hero.Class})
  end
  s.claimed+=1;s.objectives={};if c.HallPermit then s.hallPermit=c.HallPermit end
  emit("campaign_chapter_claimed",{chapterId=c.Id,xp=c.XP,gold=c.Gold});return nil
 end
 function S.receipt(record:any,command:any):(any,any,any)
  if command.action~="CampaignObjective"or type(command.args)~="table"then return nil,{code="InvalidAction"},{}end
  for key in pairs(command.args)do if key~="objective"and key~="choice"then return nil,{code="InvalidRequest"},{}end end
  if type(command.args.objective)~="string"or (command.args.choice~=nil and type(command.args.choice)~="string")then return nil,{code="InvalidRequest"},{}end
  local copy=util.copy(record);local problem=S.observe(copy.data,command.args.objective,command.args.choice)
  if problem then return nil,{code=problem},{}end
  return copy,{code="OK"},{{name="campaign_objective_observed",payload={objective=command.args.objective}}}
 end
 return S
end
