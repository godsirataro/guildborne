--!strict
-- Local synthetic attributes only; verifies visibility, ownership and geometry budgets.
return function(factory:any):any
 local collection=game:GetService("CollectionService")
 local root=Instance.new("Folder");root.Name="MineEffectsFixture";root.Parent=workspace
 local owner=game.Players.LocalPlayer.UserId;local checks=0;local safety=0
 local function mine(id:number):Model
  local m=Instance.new("Model");m:SetAttribute("CampaignOwner",id);m.Parent=root;collection:AddTag(m,"GuildborneMineActivity");return m
 end
 local own=mine(owner);local foreign=mine(owner+1);local api=factory(root,true,owner)
 local function warning(m:Model,at:number)
  m:SetAttribute("ProtectionStatus","Active");m:SetAttribute("ProtectionWarningPosition",Vector3.new(0,0,0));m:SetAttribute("ProtectionImpactAt",at)
 end
 local function check(parts:number)
  assert(api.Stats().parts==parts,"Unexpected parts: "..api.Stats().parts);checks+=1
  for _,folder in ipairs(workspace:GetChildren())do if folder.Name=="GuildborneMineActivityEffects"then
   for _,p in folder:GetDescendants()do if p:IsA("BasePart")then
    assert(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch and not p.CastShadow);safety+=1
   end end
  end end
 end
 local ok,result=pcall(function():any
  warning(foreign,102);api.Step(Vector3.zero,100,false,false,false);check(0)
  warning(own,102);api.Step(Vector3.zero,100,false,false,false);check(14)
  api.Step(Vector3.zero,100,true,false,false);check(8)
  api.Step(Vector3.zero,100,false,false,true);check(8)
  api.Step(Vector3.zero,100,false,true,false);check(14)
  for _,f in workspace:GetChildren()do if f.Name=="GuildborneMineActivityEffects"then for _,p in f:GetDescendants()do if p:IsA("BasePart")and p.Name=="FallingDebris"then assert(p.Transparency==1)end end end end
  own:SetAttribute("ProtectionWarningBlocked",true);api.Step(Vector3.zero,100,false,false,false);check(14)
  api.Step(Vector3.zero,102,false,false,false);check(0)
  warning(own,110);api.Step(Vector3.zero,100,false,false,false);check(0)
  warning(own,102);api.Step(Vector3.new(101,0,0),100,false,false,false);check(0)
  own:SetAttribute("ProtectionStatus",nil);own:SetAttribute("EscortStatus","Walking");own:SetAttribute("EscortPosition",Vector3.zero);own:SetAttribute("EscortExit",Vector3.new(8,0,0))
  api.Step(Vector3.zero,100,false,false,false);check(12)
  own:SetAttribute("EscortStatus","Paused");api.Step(Vector3.zero,100,true,true,false);check(8)
  own:SetAttribute("EscortStatus","Completed");api.Step(Vector3.zero,100,false,false,false);check(0)
  own:SetAttribute("EscortStatus","Walking");own:SetAttribute("EscortExit","invalid");api.Step(Vector3.zero,100,false,false,false);check(0)
  warning(own,102);collection:RemoveTag(own,"GuildborneMineActivity");task.wait();api.Step(Vector3.zero,100,false,false,false);check(0)
  collection:AddTag(own,"GuildborneMineActivity");task.wait();api.Step(Vector3.zero,100,false,false,false);check(14)
  local duplicate=mine(owner);warning(duplicate,102);task.wait();api.Step(Vector3.zero,100,false,false,false);check(14)
  duplicate:Destroy();own.Parent=workspace;api.Step(Vector3.zero,100,false,false,false);check(0);own:Destroy()
  api.Destroy();api.Step(Vector3.zero,100,false,false,false);check(0);assert(api.Stats().closed)
  return {stages=checks,nonCollidingPartChecks=safety,highPartCap=14,lowTouchPartCap=8,profileWrites=0,synthetic=true}
 end)
 api.Destroy();root:Destroy();if own.Parent then own:Destroy()end
 if not ok then error(result)end;return result
end
