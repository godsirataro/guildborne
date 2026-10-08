--!strict
local Server=script.Parent.Parent;local Shared=game.ReplicatedStorage.Shared
local Util=require(Shared.Util.TableUtil);local Content=require(Server.Config.Content);local Combat=require(Server.Config.Combat)
local Gear=require(Shared.Data.Equipment)(Content,require(Shared.Data.Expansion),require(Shared.Data.StatusPoints))
return function(lessonId:string):any
 local lesson=require(Server.Config.NoviceLessons)[lessonId];assert(lesson,"Unknown course lesson")
 return {Goals=lesson.Goals,Lesson=true,EnemyVisual=if lessonId=="defeat_keeper"then "crossroads_keeper"else nil,EnemyName=if lessonId=="defeat_keeper"then "Crossroads Keeper"elseif lessonId=="clear_abandoned_hall"then "Hall Sentinel"else "Training dummy",Create=require(Server.Systems.NoviceTrialCombat)({Util=Util,Content=Content,Combat=Combat,Tuning=lesson,AbilityLessons=true,
  Trials=require(Server.Systems.NoviceLessonSession)(lessonId,lesson,Util,require(Server.Systems.NoviceTrialSession)),
  Stats=require(Server.Systems.CombatStats)(Content,Combat,Gear),Targeting=require(Server.Systems.CombatTargeting),Damage=require(Server.Systems.CombatDamage),Abilities=require(Server.Systems.CombatAbilities)})}
end
