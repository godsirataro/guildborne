--!strict
-- Staged factory for the existing measured-input arena; saves no borrowed stats.
local Server=script.Parent.Parent;local Shared=game.ReplicatedStorage.Shared
local Util=require(Shared.Util.TableUtil);local Content=require(Server.Config.Content);local Combat=require(Server.Config.Combat)
local Config=require(Server.Config.TowerGuardian)
local Gear=require(Shared.Data.Equipment)(Content,require(Shared.Data.Expansion),require(Shared.Data.StatusPoints))
return function():any
 local trials=require(Server.Systems.TowerGuardianSession)(Config,Util,require(Server.Systems.NoviceTrialSession))
 return {Goals=trials.Goals,Lesson=true,EnemyName="Records Guardian",Create=require(Server.Systems.NoviceTrialCombat)({Util=Util,Content=Content,Combat=Combat,Trials=trials,Tuning=Config,AbilityLessons=true,
  Stats=require(Server.Systems.CombatStats)(Content,Combat,Gear),Targeting=require(Server.Systems.CombatTargeting),Damage=require(Server.Systems.CombatDamage),Abilities=require(Server.Systems.CombatAbilities)})}
end
