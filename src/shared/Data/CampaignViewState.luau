--!strict
-- Presentation only. All objectives and rewards require server evidence.
return function(data:any,catalog:any,busy:boolean):any
 local state=data and data.progression and data.progression.campaign
 local config=catalog and catalog.CampaignChapter
 local unavailable={stage="Unavailable",objectives={},canClaim=false,ready=false}
 if not state or not config or not data.progression.novice or data.progression.novice.claimed~=6 then return unavailable end
 if #config.Chapters>0 and state.claimed==#config.Chapters then
  local last=config.Chapters[#config.Chapters]
  return {stage="Complete",title=if data.language=="th"then last.Thai else last.Title,total=#config.Chapters,
   finale=last.Id=="MAIN_06_06",objectives={},canClaim=false,ready=true,hallPermit=state.hallPermit}
 end
 local def=config.Chapters[state.claimed+1];if not def then return unavailable end
 local rows={};local ready=true;local nextId=nil
 for _,id in ipairs(def.Objectives)do
  local done=state.objectives[id]==true;ready=ready and done;if not done and not nextId then nextId=id end
  local names=config.ObjectiveLabels[id]
  table.insert(rows,{id=id,done=done,text=names[if data.language=="th"then 2 else 1]})
 end
 local equipment=0;for _ in pairs(data.inventory.equipment)do equipment+=1 end
 local heroes=0;for _ in pairs(data.adventurers)do heroes+=1 end
 local room=not def.Recruit or (equipment<catalog.EquipmentLimit and heroes<data.rosterCapacity)
 local traveling=data.quests.active~=nil or (data.expansion and data.expansion.tower.active~=nil)
 local levelReady=data.character.level>=def.Level
 local hallReady=not def.Hall or (data.hallLevel or 0)>=def.Hall
 return {stage=if def.Recruit then "Recruit"else "Quest",chapterId=def.Id,index=state.claimed+1,total=#config.Chapters,hallReady=hallReady,hall=def.Hall,
  title=if data.language=="th"then def.Thai else def.Title,objectives=rows,nextObjective=nextId,
  guidance=if nextId and config.Guidance then config.Guidance[nextId][if data.language=="th"then 2 else 1]else nil,
  ready=ready,room=room,traveling=traveling,levelReady=levelReady,level=def.Level,xp=def.XP,gold=def.Gold,hallPermit=def.HallPermit,
  canClaim=not busy and ready and room and not traveling and levelReady and hallReady}
end
