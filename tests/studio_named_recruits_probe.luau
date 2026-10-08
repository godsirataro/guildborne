--!strict
-- Synthetic visual models only, never inserts actors into a player roster.
return function():any
 local Server=game.ServerScriptService.Server
 local content=require(Server.Config.Content);local rig=require(Server.Services.HeroRig)
 local choose=require(Server.Systems.HeroTemplateChoice)
 local folder=Instance.new("Folder");folder.Name="NamedRecruitFixture";folder.Parent=game.ServerStorage
 local checks=0
 local ok,result=pcall(function():any
  for _,id in ipairs(content.HeroTemplateOrder) do
   local template=content.HeroTemplates[id]
   local model=rig.Build(template.Class,choose(template.Class,"h:900",id));model.Parent=folder
   assert(model:GetAttribute("VisualTemplateId")==id and model:FindFirstChild("HeroAppearance"),"Visual mismatch "..id)
   assert(model:FindFirstChild("Head") and model:FindFirstChildOfClass("Humanoid"))
   local pieces=0;for _,part in ipairs(model:GetDescendants()) do if part:IsA("BasePart")then pieces+=1 end end
   assert(pieces>10 and pieces<80,"Unbounded recruit model")
   model:Destroy();checks+=1
  end
  return {namedVisuals=checks,templateIdsPreserved=true,synthetic=true,profileWrites=0}
 end)
 folder:Destroy();assert(ok,tostring(result));return result
end
