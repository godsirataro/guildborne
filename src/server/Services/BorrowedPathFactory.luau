--!strict
local Server=script.Parent.Parent;local Shared=game.ReplicatedStorage.Shared
local Util=require(Shared.Util.TableUtil);local Content=require(Server.Config.Content);local BaseCombat=require(Server.Config.Combat)
local Expansion=require(Shared.Data.Expansion)
local Gear=require(Shared.Data.Equipment)(Content,Expansion,require(Shared.Data.StatusPoints))
return function(pathId:string,mastery:boolean?):any
 local path=assert(Expansion.Paths[pathId]);assert(path.Tier==(if mastery then 3 else 2))
 local combat=Util.copy(BaseCombat);combat.Classes[path.Class].Ability=path.Skill;combat.Abilities[path.Skill]=Util.copy(Expansion.Abilities[path.Skill])
 local trials=require(Server.Systems.BorrowedPathSession)(Expansion,Util,require(Server.Systems.NoviceTrialSession),pathId,mastery)
 return {Goals=trials.Goals,Lesson=true,AbilityId=path.Skill,Ability=Util.copy(combat.Abilities[path.Skill]),PathId=pathId,EnemyName=if mastery then "Mastery construct" else "Training dummy",Create=require(Server.Systems.NoviceTrialCombat)({Util=Util,Content=Content,Combat=combat,Trials=trials,Tuning={Level=if mastery then 70 else 35,EnemyHealth=if mastery then 3200 else 1600},AbilityLessons=true,
  Stats=require(Server.Systems.CombatStats)(Content,combat,Gear),Targeting=require(Server.Systems.CombatTargeting),Damage=require(Server.Systems.CombatDamage),Abilities=require(Server.Systems.CombatAbilities)})}
end
