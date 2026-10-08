--!strict
-- Isolated client-only preview actors. No combat commands, progression or rewards.
return function(quality:string?):any
 local player=game.Players.LocalPlayer
 local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
 local paths=require(game.ReplicatedStorage.Shared.Config.PathVFX)
 local expansion=require(game.ReplicatedStorage.Shared.Data.Expansion)
 local effect=require(player.PlayerScripts.Client.Controllers.SkillEffects)()
 local camera=workspace.CurrentCamera :: Camera
 local original=workspace:GetAttribute(config.QualityAttribute)
 local spawned:{BasePart}={};local actors:{Model}={};local seen={}
 local connection=workspace.ChildAdded:Connect(function(child:Instance)
  if child.Name=="GuildborneSkillEffect" and child:IsA("BasePart") then table.insert(spawned,child) end
 end)
 local function actor(id:string):Model
  local definition=expansion.Abilities[id]
  local model=Instance.new("Model");model.Name="PathVFXPreview"
  local root=Instance.new("Part");root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.CanTouch=false;root.Transparency=1
  root.CFrame=camera.CFrame*CFrame.new(0,0,-14);root.Parent=model;model.PrimaryPart=root
  model:SetAttribute("ClassId",definition.Class);model:SetAttribute("ActionEffect",definition.Effect)
  model:SetAttribute("ActionAbilityId",id);model:SetAttribute("ActionTargetPosition",root.Position+Vector3.new(3,0,-3))
  model.Parent=workspace;table.insert(actors,model);return model
 end
 local ok,result=pcall(function():any
  workspace:SetAttribute(config.QualityAttribute,quality or "High")
  local ids={};for id in pairs(paths.Catalog) do table.insert(ids,id) end;table.sort(ids);assert(#ids==24)
  assert(paths.resolve("unknown","Warrior","Physical")==nil)
  assert(paths.resolve("cleave","Mage","Area")==nil)
  assert(paths.resolve("cleave","Warrior","Basic")==nil)
  for _,id in ipairs(ids) do
   local identity=paths.Catalog[id];local definition=expansion.Abilities[id]
   assert(paths.resolve(id,definition.Class,definition.Effect)==identity)
   local model=actor(id);local start=#spawned;effect(model)
   local peak={Detail=0,Primary=0,Telegraph=0};local deadline=os.clock()+.8
   repeat
    task.wait(.025);local counts={Detail=0,Primary=0,Telegraph=0}
    for i=start+1,#spawned do local p=spawned[i];if p.Parent then
     assert(not p.CanCollide and not p.CanTouch and not p.CanQuery and p.Anchored)
     local bucket=p:GetAttribute("VFXBucket") :: string;counts[bucket]+=1
    end end
    for key,n in pairs(counts) do peak[key]=math.max(peak[key],n) end
   until os.clock()>=deadline
   assert(#spawned>start,"Missing art: "..id)
   assert(peak.Detail<=(if game:GetService("UserInputService").TouchEnabled then config.Budget.Touch else config.Budget.Desktop))
   assert(peak.Primary<=config.Budget.Primary and peak.Telegraph==0)
   if quality=="Low" then assert(peak.Detail==0 and peak.Primary>0,"Low quality lost compact cue") end
   task.wait(.55);for i=start+1,#spawned do assert(spawned[i].Parent==nil,"Leaked art: "..id) end
   table.insert(seen,{id=id,pattern=identity.Pattern,tier=identity.Tier,spawned=#spawned-start,peak=peak})
   model:Destroy()
  end
  -- Every delayed family must stop adding geometry after its caster leaves the world.
  for _,id in ipairs(ids) do
   local model=actor(id);local fresh=require(player.PlayerScripts.Client.Controllers.SkillEffects)();fresh(model);model:Destroy()
  end
  local count=#spawned;task.wait(1.4);assert(#spawned==count,"Late geometry after caster removal")
  for _,p in ipairs(spawned) do assert(p.Parent==nil,"Removal leaked geometry") end
  return {quality=quality or "High",arts=#ids,cases=seen,unknownAndMismatchRejected=true,collisionFree=true,budgetsPassed=true,cleanupPassed=true,removedCasterSpawns=0,synthetic=true}
 end)
 connection:Disconnect();workspace:SetAttribute(config.QualityAttribute,original)
 for _,m in ipairs(actors) do m:Destroy() end;for _,p in ipairs(spawned) do p:Destroy() end
 assert(ok,tostring(result));return result
end
