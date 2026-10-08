--!strict
return function(data:any,catalog:any,busy:boolean):any
 local s=data and data.progression and data.progression.novice
 local config=catalog and catalog.NoviceChapter
 if not s or not config then return {stage="Unavailable",objectives={},canClaim=false,canSelect=false,canFound=false} end
 if s.claimed==6 then return {stage="Complete",objectives={},canClaim=false,canSelect=false,canFound=false} end
 local def=config.Chapters[s.claimed+1];local rows={};local complete=true
 for _,id in ipairs(def.Objectives) do
  local done=s.objectives[id]==true;complete=complete and done
  local names=config.ObjectiveLabels[id]
  table.insert(rows,{id=id,done=done,text=names[if data.language=="th" then 2 else 1]})
 end
 local count=0;for _ in pairs(data.inventory.equipment) do count+=1 end
 local room=count<catalog.EquipmentLimit
 local classId=data.character.classId;local stage="Quest"
 if s.claimed==5 then stage=if classId then "Foundation" elseif s.trialClass then "Class" else "Trial" end
 local eligible=not busy and data.character.level>=def.Level
 return {stage=stage,chapterId=def.Id,title=if data.language=="th" then def.Thai else def.Title,index=s.claimed+1,
  objectives=rows,ready=complete,trialClass=s.trialClass,xp=def.XP,room=room,
  canClaim=eligible and complete and s.claimed<5,
  canSelect=eligible and room and stage=="Class",
  canFound=eligible and complete and room and stage=="Foundation" and data.hallLevel==0 and next(data.adventurers)==nil}
end
