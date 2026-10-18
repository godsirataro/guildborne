--!strict
-- Read-only replicated Chapter03/04 geometry. Rebuilt each tick so stream-out,
-- disabled prompts and owner changes cannot leave cached quest destinations.
return function(root:Instance,owner:number,playerPosition:Vector3):any
 local result:any={}
 local world=root:FindFirstChild("GuildborneWorld")
 local function vectorPoint(value:any):any
  return if typeof(value)=="Vector3" then {x=value.X,y=value.Y,z=value.Z,zone="Ashen"} else nil
 end
 for _,definition in ipairs({{key="ashen",model="AshenCourt_",prefix="Ashen_"},{key="tower",model="TowerCourt_",prefix="Tower_"}})do
  local model=(world and world:FindFirstChild(definition.model..owner)) or root:FindFirstChild(definition.model..owner)
  if not model or not model:IsA("Model") or model:GetAttribute("CampaignOwner")~=owner then continue end
  if definition.key=="tower" and model:GetAttribute("Chapter04Court")~=true then continue end
  local floor=model:FindFirstChild("CourtWalkableFloor")
  if not floor or not floor:IsA("BasePart") then continue end
  local state:any={ownerId=owner,playerY=playerPosition.Y,anchors={},floor={x=floor.Position.X,y=floor.Position.Y+floor.Size.Y/2,z=floor.Position.Z,width=floor.Size.X,depth=floor.Size.Z}}
  for _,part in ipairs(model:GetChildren())do
   if not part:IsA("BasePart") then continue end
   local prompt=part:FindFirstChild(definition.prefix..part.Name)
   if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
    local point=vectorPoint(part.Position+Vector3.new(0,part.Size.Y/2,0));point.anchor=part
    state.anchors[part.Name]=point
   end
  end
  if definition.key=="ashen" then
   state.escortStatus=model:GetAttribute("EscortStatus")
   state.escortPosition=vectorPoint(model:GetAttribute("EscortPosition"));state.escortExit=vectorPoint(model:GetAttribute("EscortExit"))
   state.escortReasons={}
   -- Reasons remain on retired actors; QuestRoute selects the current objective's actor.
   for _,name in ipairs({"gatekeeper","bridgewright"})do
    local actor=model:FindFirstChild(name,true)
    if actor then state.escortReasons[name]=actor:GetAttribute("EscortReason") end
   end
   state.protectionStatus=model:GetAttribute("ProtectionStatus")
   state.warning=vectorPoint(model:GetAttribute("ProtectionWarningPosition"))
   local impact=model:GetAttribute("ProtectionImpactAt")
   state.warningLive=model:GetAttribute("ProtectionWarningBlocked")==false and type(impact)=="number" and impact>workspace:GetServerTimeNow()
  else
   local actor=model:FindFirstChild("memory_echo",true)
   state.escortStatus=actor and actor:GetAttribute("EscortStatus")
   local lesson=model:FindFirstChild("TowerLesson_"..owner)
   if lesson and lesson:GetAttribute("OwnerUserId")==owner and lesson:GetAttribute("TrainingOnly")==true then
    state.lessonStatus=lesson:GetAttribute("LessonStatus");state.lessonRole=lesson:GetAttribute("LessonRole")
   end
   local trial=root:FindFirstChild("NoviceTrial_"..owner)
   state.trial=trial~=nil and trial:GetAttribute("OwnerUserId")==owner and trial:GetAttribute("NoviceTrialArena")==true
  end
  result[definition.key]=state
 end
 local encounter=root:FindFirstChild("RegionalEncounter_"..owner.."_Ashen")
 local actors=encounter and encounter:FindFirstChild("EncounterArt")
 local area=world and world:FindFirstChild("Ashen");local markers=area and area:FindFirstChild("EncounterMarkers")
 if result.ashen and encounter and encounter:GetAttribute("AdventureSceneOwner")==owner and actors and markers then
  result.ashen.encounters={}
  for _,actor in ipairs(actors:GetChildren())do
   local id=actor:GetAttribute("EncounterId");local marker=actor:GetAttribute("EncounterMarker");local health=actor:GetAttribute("CombatHealth")
   local part=if type(marker)=="string"then markers:FindFirstChild(marker)else nil
   if actor:IsA("Model") and actor:GetAttribute("OwnerUserId")==owner and type(id)=="string" and type(health)=="number" and health>0 and part and part:IsA("BasePart")then
    result.ashen.encounters[id]={ownerId=owner,alive=true,marker=marker,point=vectorPoint(part.Position)}
   end
  end
 end
 return result
end
