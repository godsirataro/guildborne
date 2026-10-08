--!strict
-- Synthetic presentation attributes only; no combat input or profile changes.
return function(create:any):any
 local owner=game.Players.LocalPlayer.UserId;local scope=Instance.new("Folder");scope.Name="ArchiveEffectsFixture";scope.Parent=workspace
 local model=Instance.new("Model");model.Parent=scope;local tags=game:GetService("CollectionService")
 model:SetAttribute("OwnerUserId",owner);model:SetAttribute("TrialStatus","Active");model:SetAttribute("TargetPosition",Vector3.new(0,3,0));model:SetAttribute("EncounterCueUntil",112)
 tags:AddTag(model,"GuildborneArchiveEncounter");local api=create(scope,true,owner);local checks=0;local stages=0
 local function step(now:number,low:boolean?,reduced:boolean?,touch:boolean?,position:Vector3?)api.Step(position or Vector3.zero,now,low==true,reduced==true,touch==true);stages+=1 end
 local function count(n:number)
  assert(api.Stats().parts==n,"Part budget mismatch")
  for _,p in ipairs(workspace.GuildborneArchiveHeartEffects:GetChildren())do assert(p:IsA("BasePart")and p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch and not p.CastShadow);assert(p.Position.Magnitude<100);checks+=1 end
 end
 local ok,result=pcall(function():any
  local silhouettes={}
  for _,phase in ipairs({"Rescue","Mechanism","Attack"})do
   model:SetAttribute("EncounterPhase",phase);step(100);count(16)
   local shapes={};for _,p in ipairs(workspace.GuildborneArchiveHeartEffects:GetChildren())do if p:IsA("Part")and p.Name=="ObjectiveGlyph"then table.insert(shapes,tostring(p.Size)..tostring(p.CFrame))end end
   silhouettes[phase]=table.concat(shapes,"|")
   step(100.1,true);count(8);step(100.2,false,false,true);count(8);step(100.3,false,true);count(16)
   local before={};for _,p in ipairs(workspace.GuildborneArchiveHeartEffects:GetChildren())do if p:IsA("BasePart")then before[p]=p.CFrame end end
   step(101,false,true);for p,cf in pairs(before)do assert(p.CFrame==cf,"Reduced motion moved")end
  end
  assert(silhouettes.Rescue~=silhouettes.Mechanism and silhouettes.Mechanism~=silhouettes.Attack and silhouettes.Rescue~=silhouettes.Attack)
  step(100,false,false,false,Vector3.new(1000,0,0));count(0)
  model:SetAttribute("OwnerUserId",owner+1);step(100);count(0);model:SetAttribute("OwnerUserId",owner)
  step(113);count(0);model:SetAttribute("EncounterCueUntil",120);step(100);count(0);model:SetAttribute("EncounterCueUntil",112)
  for _,phase in ipairs({"Ready","Warning","Finished","Invalid"})do model:SetAttribute("EncounterPhase",phase);step(100);count(0)end
  model:SetAttribute("EncounterPhase","Rescue");model:SetAttribute("TrialStatus","Won");step(100);count(0);model:SetAttribute("TrialStatus","Active")
  model:SetAttribute("TargetPosition",Vector3.new(0/0,0,0));step(100);count(0);model:SetAttribute("TargetPosition",Vector3.new(0,3,0))
  step(100);count(16);tags:RemoveTag(model,"GuildborneArchiveEncounter");step(100);count(0)
  tags:AddTag(model,"GuildborneArchiveEncounter");step(100);count(16);model.Parent=nil;step(100);count(0)
  api.Destroy();api.Destroy();assert(api.Stats().closed and not workspace:FindFirstChild("GuildborneArchiveHeartEffects"))
  return {stages=stages,partChecks=checks,highCap=16,lowTouchCap=8,distinctGlyphs=3,reducedMotionStatic=true,ownerDistanceExpiryCleanup=true,profileWrites=0}
 end)
 api.Destroy();model:Destroy();scope:Destroy();if not ok then error(result)end;return result
end
