-- Apply only the locally generated, reviewed build/integration-sync payload.
-- Serve that directory read-only on 127.0.0.1:8774; stop the server after testing.
assert(game:GetService("RunService"):IsStudio() and not game:GetService("RunService"):IsRunning(), "Edit mode required")
assert(game.PlaceId==0 and game.GameId==0, "Only the separate local preview may be synced")
local H=game:GetService("HttpService")
local old=H.HttpEnabled;H.HttpEnabled=true
local ok,raw=pcall(function()return H:GetAsync("http://127.0.0.1:8774/sources.json")end)
H.HttpEnabled=old;assert(ok,raw)
local data=H:JSONDecode(raw)
local runtime=false
local allowed={StarterPlayer=true,ServerScriptService=true,ReplicatedStorage=true}
-- Validate the whole payload before any source assignment.
for _,entry in ipairs(data.entries)do
 assert(allowed[entry.path[1]],"Unexpected service")
 assert(entry.className=="Script" or entry.className=="LocalScript" or entry.className=="ModuleScript")
 assert(type(entry.source)=="string")
 local existing=game
 for depth,name in ipairs(entry.path)do
  assert(type(name)=="string" and #name>0,"Invalid instance path")
  existing=existing and existing:FindFirstChild(name)
  if existing and depth==#entry.path then assert(existing.ClassName==entry.className,"Class conflict: "..table.concat(entry.path,"."))end
 end
 if table.concat(entry.path,".")=="ServerScriptService.Server.Config.Runtime"then
  runtime=entry.source:find('StudioPersistence="Memory"',1,true)~=nil and entry.source:find('AllowedDataStoreUniverses={}',1,true)~=nil
 end
end
assert(runtime,"Memory runtime required before writes")
local changed=0
for i,entry in ipairs(data.entries)do
 local parent=game
 for depth=1,#entry.path-1 do
  local name=entry.path[depth];local found=parent:FindFirstChild(name)
  if not found then found=Instance.new("Folder");found.Name=name;found.Parent=parent end
  parent=found
 end
 local name=entry.path[#entry.path];local s=parent:FindFirstChild(name)
 if not s then s=Instance.new(entry.className);s.Name=name;s.Parent=parent end
 assert(s.ClassName==entry.className,name)
 if s.Source~=entry.source then
  if #entry.source>=200000 then game:GetService("ScriptEditorService"):UpdateSourceAsync(s,function()return entry.source end)
  else s.Source=entry.source end
  changed+=1
 end
 if i%24==0 then task.wait()end
end
local art=game.ReplicatedStorage:FindFirstChild("IntegrationArt")
if art and data.artSourceSha256 then art:SetAttribute("SourceSha256",data.artSourceSha256)end
game:SetAttribute("IntegrationCandidateSha256",data.candidateSha256)
return {sourcesChecked=#data.entries,changed=changed,candidateSha256=data.candidateSha256,persistence="Memory"}
