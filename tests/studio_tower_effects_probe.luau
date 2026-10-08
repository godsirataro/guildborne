--!strict
-- Local synthetic attribute sources, never gameplay requests or profile changes.
return function(create:any):any
 local owner=game.Players.LocalPlayer.UserId;local scope=Instance.new("Folder");scope.Name="TowerEffectsFixture";scope.Parent=workspace
 local model=Instance.new("Model");model.Parent=scope;local tags=game:GetService("CollectionService")
 model:SetAttribute("OwnerUserId",owner);model:SetAttribute("LessonStatus","Active");model:SetAttribute("LessonPhase","Warning");model:SetAttribute("CueRole","Guard");model:SetAttribute("CuePosition",Vector3.new(0,3,0));model:SetAttribute("CueEndsAt",103)
 tags:AddTag(model,"GuildborneTowerLesson");local api=create(scope,true,owner);local checks=0;local stages=0
 local function step(now:number,low:boolean?,reduced:boolean?,touch:boolean?,position:Vector3?)api.Step(position or Vector3.new(),now,low==true,reduced==true,touch==true);stages+=1 end
 local function count(n:number)
  assert(api.Stats().parts==n);local output=assert(workspace:FindFirstChild("GuildborneTowerLessonEffects"))
  for _,p in ipairs(output:GetChildren())do assert(p:IsA("BasePart")and p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch);assert(p.Position.Magnitude<100);checks+=1 end
 end
 local ok,result=pcall(function():any
  step(100);count(14);model:SetAttribute("CueActed",true);step(100.2);count(14)
  step(100.3,true);count(8);step(100.4,false,false,true);count(8)
  model:SetAttribute("CueRole","Mend");model:SetAttribute("CueActed",false);step(100.5);count(14)
  model:SetAttribute("LessonPhase","Recovery");step(100.6);count(14);step(100.7,false,true);count(14)
  local output=workspace.GuildborneTowerLessonEffects;local before={};for _,p in ipairs(output:GetChildren())do if p:IsA("BasePart")then before[p]=p.CFrame end end
  step(100.8,false,true);for p,cf in pairs(before)do assert(p.CFrame==cf,"Reduced motion moved")end
  step(100.9,false,false,false,Vector3.new(1000,0,0));count(0)
  model:SetAttribute("OwnerUserId",owner+1);step(101);count(0);model:SetAttribute("OwnerUserId",owner)
  step(104);count(0);model:SetAttribute("CueEndsAt",120);step(101);count(0)
  model:SetAttribute("CueEndsAt",103);model:SetAttribute("LessonStatus","Completed");step(101);count(0)
  model:SetAttribute("LessonStatus","Active");model:SetAttribute("CueRole","Invalid");step(101);count(0)
  model:SetAttribute("CueRole","Guard");step(101);count(14);tags:RemoveTag(model,"GuildborneTowerLesson");step(101.1);count(0)
  tags:AddTag(model,"GuildborneTowerLesson");step(101.2);count(14);model.Parent=nil;step(101.3);count(0)
  api.Destroy();api.Destroy();assert(api.Stats().closed and not workspace:FindFirstChild("GuildborneTowerLessonEffects"))
  return {stages=stages,partChecks=checks,highCap=14,lowTouchCap=8,reducedMotionStatic=true,ownerDistanceExpiryCleanup=true,profileWrites=0}
 end)
 api.Destroy();model:Destroy();scope:Destroy();if not ok then error(result)end;return result
end
