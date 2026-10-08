-- Isolated city/cast integration fixture; no profile or dialogue reward remotes.
local player=game.Players.LocalPlayer
local root=game.ReplicatedStorage.CivicReview
local review=require(root.NativeReview)
local entries={{"Crownford","elian","Marshal Elian","Market"},{"Sylvaris","vaela","Arborist Vaela","Market"},{"Deepforge","borin","Smith Borin","Market"},{"Astralis","nyra","Cartographer Nyra","Market"},{"Crosshaven","sela","Harbormaster Sela","Market"},{"Ironroot","roka","Steward Roka","Tavern"}}
local states={};local prompts={};local ui=Instance.new("ScreenGui");ui.Name="CivicCastSceneReview";ui.ResetOnSpawn=false;ui.Parent=player:WaitForChild("PlayerGui")
local status=Instance.new("TextLabel");status.Name="Status";status.Size=UDim2.new(1,0,0,44);status.Position=UDim2.new(0,0,1,-44);status.TextWrapped=true;status.BackgroundColor3=Color3.fromRGB(23,35,47);status.TextColor3=Color3.new(1,1,1);status.TextSize=13;status.Text="Loading local cast…";status.Parent=ui
local districtFolder=workspace:WaitForChild("CityDistrictPrototypes")
local cityChanged=game.ReplicatedStorage.ArchitectureReviewDestination.OnClientEvent:Connect(function(city)
 status.Text=city.." · walk beside the market (Roka: tavern) · E pauses/resumes local work"
end)
for _,entry in ipairs(entries)do
 local city=districtFolder:WaitForChild(entry[1]);local marker=city:WaitForChild(entry[4])
 local origin=Vector3.new(marker.Position.X-10,.35,marker.Position.Z+18)
 local ok,err=pcall(function()review:Add(entry[2],origin,require(root.Data[entry[2]]))end)
 if not ok then warn("Cast review load failed: "..entry[2].." "..tostring(err));continue end
 local actor=review.actors[#review.actors];actor.part:SetAttribute("City",entry[1]);actor.part:SetAttribute("ReviewOnly",true)
 local anchor=Instance.new("Part");anchor.Name=entry[2].."TalkAnchor";anchor.Size=Vector3.one*.1;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false;anchor.Position=origin+Vector3.new(0,3,0);anchor.Parent=review.folder
 local prompt=Instance.new("ProximityPrompt");prompt.Name="ReviewGreeting";prompt.ObjectText=entry[3];prompt.ActionText="Pause work / คุย";prompt.RequiresLineOfSight=false;prompt.MaxActivationDistance=8;prompt.Parent=anchor
 local state={actor=actor,clock=0,paused=false,near=false,name=entry[3],prompt=prompt};states[entry[2]]=state;table.insert(prompts,anchor)
 prompt.Triggered:Connect(function()
  state.paused=not state.paused
  prompt.ActionText=if state.paused then "Resume work / ทำงานต่อ"else"Pause work / คุย"
  status.Text=if state.paused then state.name.." · paused for local greeting review; press E to resume"else state.name.." · activity resumed"
 end)
end
local effects=require(root.Effects)(review)
local allActors=table.clone(review.actors);local allEffects=table.clone(effects)
local connection=game:GetService("RunService").RenderStepped:Connect(function(dt)
 local character=player.Character;local hrp=character and character:FindFirstChild("HumanoidRootPart")
 local active=0
 for id,state in pairs(states)do
  local distance=if hrp then (hrp.Position-state.actor.part.Position).Magnitude else math.huge
  local near=distance<120
  if state.paused and distance>12 then
   state.paused=false;state.prompt.ActionText="Pause work / คุย"
   if near then status.Text=state.name.." · work resumed after leaving the conversation"end
  end
  state.near=near;state.prompt.Enabled=near
  state.actor.part.LocalTransparencyModifier=if near then 0 else 1
  if near then
   active+=1
   if not state.paused then state.clock=(state.clock+math.min(dt,.1))%6 end
   -- The shared review engine normally advances all actors together. This fixture
   -- scopes each call to one actor so dialogue/distance can pause its own clock.
   review.actors={state.actor};table.clear(effects);effects[id]=allEffects[id]
   review:Frame(state.clock)
  end
  local effect=allEffects[id]
  if effect then
   for _,part in ipairs(effect.parts)do part.LocalTransparencyModifier=if near and not state.paused then 0 else 1 end
   if effect.light then effect.light.Enabled=near and not state.paused end
  end
  state.actor.part:SetAttribute("ReviewClock",state.clock)
  state.actor.part:SetAttribute("ReviewPaused",state.paused)
  state.actor.part:SetAttribute("ReviewNear",near)
 end
 review.actors=allActors;table.clear(effects);for id,effect in pairs(allEffects)do effects[id]=effect end
 ui:SetAttribute("LoadedActors",#allActors);ui:SetAttribute("ActiveActors",active)
end)
status.Text="Six local cast studies · walk beside the market (Roka: tavern) · E pauses/resumes work · no gameplay rewards"
script.Destroying:Connect(function()connection:Disconnect();cityChanged:Disconnect();review:Destroy();ui:Destroy()end)
