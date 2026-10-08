--!strict
-- Local visual rigs exercised by the existing bootstrap animator; no combat/profile writes.
return function(make:any):any
 local folder=make(true);folder.Name="ArchiveBossRigFixture";folder.Parent=workspace
 local tags=game:GetService("CollectionService");local camera=assert(workspace.CurrentCamera)
 local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig);local oldReduced=workspace:GetAttribute(config.ReducedMotionAttribute)
 local results={};local parts=0;local totalMotors=0
 local ok,result=pcall(function():any
  workspace:SetAttribute(config.ReducedMotionAttribute,true)
  for _,instance in ipairs(folder:GetChildren())do
   local model=instance :: Model;local root=assert(model.PrimaryPart);assert(root.Anchored)
   model:SetAttribute("GuildborneEnemy",true);model:SetAttribute("OwnerUserId",game.Players.LocalPlayer.UserId)
   model:SetAttribute("EnemyAnimationClass",if model.Name=="last_warden"then "Knight"else "Mage")
   model:SetAttribute("CombatHealth",100);model:SetAttribute("CombatState","Idle")
   model:PivotTo(CFrame.new(camera.CFrame.Position+camera.CFrame.LookVector*20));tags:AddTag(model,"GuildborneAnimatedEnemy")
   local before=root.CFrame;local motors:{Motor6D}={}
   for _,v in ipairs(model:GetDescendants())do
    if v:IsA("BasePart")then assert(not v.CanCollide and not v.CanQuery and not v.CanTouch);if v.Transparency<1 then parts+=1 end
    elseif v:IsA("Motor6D")then assert(v.Part0 and v.Part1);table.insert(motors,v)end
   end
   local function posed():boolean for _,j in ipairs(motors)do if j.Transform~=CFrame.identity then return true end end;return false end
   local function sample()task.wait(.25)end
   sample();assert(not posed(),"Reduced idle not settled")
   model:SetAttribute("CombatState","Approach");sample();assert(posed(),"Walk missing")
   model:SetAttribute("CombatState","Attack");model:SetAttribute("EnemyActionAt",workspace:GetServerTimeNow());sample();assert(posed(),"Attack missing")
   model:SetAttribute("EnemyActionAt",nil);model:SetAttribute("CombatState","Windup");model:SetAttribute("TelegraphAt",workspace:GetServerTimeNow());model:SetAttribute("TelegraphDuration",1.5);sample();assert(posed(),"Windup missing")
   model:SetAttribute("TelegraphAt",nil);model:SetAttribute("CombatState","Idle");sample();assert(not posed(),"Cancelled windup stuck")
   model:SetAttribute("CombatState","Approach");sample();assert(posed())
   model:SetAttribute("CombatHealth",0);sample();assert(not posed(),"Defeated pose not reset")
   model:SetAttribute("CombatHealth",100);sample();assert(posed(),"Revived pose missing")
   assert((root.Position-before.Position).Magnitude<.001,"Animator moved root")
   model:PivotTo(CFrame.new(camera.CFrame.Position+Vector3.new(0,0,500)));sample();assert(not posed(),"Distant rig not reset")
   totalMotors+=#motors;table.insert(results,{id=model.Name,motors=#motors,walk=true,attack=true,windup=true,cancelRestores=true,reducedIdle=true,deathRevive=true,distanceCullResets=true,rootUntouched=true})
  end
  assert(parts==106 and totalMotors==30)
  return {rigs=results,visibleParts=parts,motors=totalMotors,profileWrites=0,combatBound=false}
 end)
 workspace:SetAttribute(config.ReducedMotionAttribute,oldReduced);folder:Destroy();if not ok then error(result)end;return result
end
