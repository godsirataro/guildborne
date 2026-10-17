--!strict
-- Disposable SERVER-only synthetic native-prompt review. Not earned progression.
-- Caller operates actual R input; this module never fires or replaces Triggered.
return function(player:Player):any
 assert(game:GetService("RunService"):IsStudio(),"Studio only")
 assert(game.PlaceId==0 and game.GameId==0,"Offline preview only")
 local server=game:GetService("ServerScriptService"):WaitForChild("Server")
 local runtime=require(server.Config.Runtime)
 assert(runtime.StudioPersistence=="Memory","Memory preview required")
 local root=assert(player.Character and player.Character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local character=assert(player.Character);local initial=root.Position;local zone=player:GetAttribute("CurrentZone")
 local modelName="IronveilMine_"..player.UserId
 local function find():Instance?
  local world=workspace:FindFirstChild("GuildborneWorld")
  return (world and world:FindFirstChild(modelName))or workspace:FindFirstChild(modelName)
 end
 assert(not find(),"Existing owner mine must not be replaced")
 -- Slot1 removal has a recovery guard. Keep this fixture outside its volume.
 assert(math.abs(initial.Y-100)>=45 or (Vector2.new(initial.X,initial.Z)-Vector2.new(500,1400)).Magnitude>=165,"Avatar is inside fixture recovery volume")
 local config=require(server.Config.CampaignSequence)({require(server.Config.ChapterOne),require(server.Config.ChapterTwo)})
 local allowed:{[string]:boolean}={interview_carrier_carrier=true,MineReception=true,collect_reagent_reagent=true,Review_workers=true,Review_council=true,return_mine_key_arena_entry=true,meet_class_mentor_mentor=true,submit_ironveil_evidence_mentor=true}
 for _,prefix in ipairs({"inspect_ironveil_scales_scale_","read_mine_signal_signal_","choose_safe_shaft_signal_","inspect_shoring_support_","repair_shoring_support_","operate_mine_mechanism_mechanism_"})do for i=1,3 do allowed[prefix..i]=true end end
 for i=1,2 do allowed["compare_mine_seals_seal_"..i]=true end
 local function copy(value:any):any
  if type(value)~="table"then return value end
  local result={};for key,item in pairs(value)do result[key]=copy(item)end;return result
 end
 local data:any={settings={language="th"},character={classId="Mage",level=35},personalGuild={buildings={guildHall=4}},progression={campaign={claimed=6,objectives={},choices={}}}}
 local session:any={record={data=data},state="Active",epoch=1,token="SYNTHETIC_NATIVE_PROMPT_REVIEW"}
 local receipts:any={};local retries=0;local attempts=0;local pending=false;local notifications=0;local forbidden=0
 local service:any=nil;local selected:BasePart?=nil;local previous:Vector3?=nil;local selectedName:string?=nil;local destroyed=false;local invalidated=false
 local function restore()
  if selected and selected.Parent and previous then selected.Position=previous end
  selected=nil;previous=nil;selectedName=nil
 end
 -- Count forbidden requests without throwing: Remove must still disconnect and
 -- destroy its fixture if unexpected avatar movement activates recovery logic.
 local function noMutation(...:any):any forbidden+=1;return nil end
 local function cleanup()
  restore()
  if service then service.Destroy();service=nil end
 end
 local function assertSettled()
  assert(not destroyed and not invalidated,"Fixture inactive")
  assert(not pending,"Receipt unsettled; wait for State().pending=false")
 end
 local function label()
  local model=assert(find(),"Fixture mine missing")
  model:SetAttribute("SyntheticPromptReview",true)
  model:SetAttribute("AcceptanceScope","SYNTHETIC_NATIVE_PROMPTS_ONLY")
 end
 local ok,problem=pcall(function()
  service=require(server.Services.IronveilWorld)({Data={Sessions={[player.UserId]=session},FlushAudit=function()end},Config=config,
   World={RefreshCampaignCompanions=noMutation,IntentCommitted=noMutation,CompanionEvidence=function()return nil end},
   MakeReceipt=function(owner:number,receipt:any):any
    assert(owner==player.UserId and receipt.owner==owner and receipt.action=="CampaignObjective")
    local objective=receipt.args.objective
    assert(table.find(config.Chapters[data.progression.campaign.claimed+1].Objectives,objective),"Out-of-stage receipt")
    assert(not pending,"Overlapping receipt")
    pending=true;local captured=copy(receipt);local committed=false
    return function(): (string,string)
     attempts+=1
     if retries==0 then retries=1;return "Retry","SavePending" end
     if not committed then
      committed=true;table.insert(receipts,captured)
      data.progression.campaign.objectives[objective]=true
      if captured.args.choice then data.progression.campaign.choices[objective]=captured.args.choice end
     end
     pending=false;return "Committed","OK"
    end
   end,Notify=function()notifications+=1 end})
  service.Update(player);label()
 end)
 if not ok then
  local cleaned,cleanupProblem=pcall(function()cleanup();return ""end)
  -- Constructor failure may precede a returned service. Only this freshly
  -- created owner model can exist after the preflight absence assertion.
  local remaining=find();if remaining then remaining:Destroy()end
  error(tostring(problem)..(if cleaned then "" else " Cleanup: "..tostring(cleanupProblem)))
 end
 local handle={}
 function handle.Stage(claimed:number,done:any?)
  assertSettled();assert(claimed%1==0 and claimed>=6 and claimed<=11,"Stage must be 6..11")
  local objectives={}
  for id,value in pairs(done or {})do
   assert(value==true and table.find(config.Chapters[claimed+1].Objectives,id),"Invalid synthetic completed objective")
   objectives[id]=true
  end
  restore();service.Remove(player)
  data.progression.campaign={claimed=claimed,objectives=objectives,choices={}}
  service.Update(player);label()
 end
 function handle.Near(name:string)
  assertSettled();assert(allowed[name],"Only reviewed pure objective markers may move")
  restore();assert(player.Character==character and root.Parent,"Avatar replaced")
  local model=assert(find());local part=assert(model:FindFirstChild(name))
  assert(part:IsA("BasePart"));local prompt=part:FindFirstChild("Ironveil_"..name)
  assert(prompt and prompt:IsA("ProximityPrompt"),"Native prompt missing")
  -- R must not also operate ordinary gameplay. Inspect without disabling or
  -- relocating any external prompt, even if line-of-sight currently hides it.
  for _,other in ipairs(workspace:GetDescendants())do
   if other:IsA("ProximityPrompt") and not other:IsDescendantOf(model) and other.Enabled and other.KeyboardKeyCode==Enum.KeyCode.R then
    local parent=other.Parent;local position:Vector3?=nil
    if parent and parent:IsA("Attachment")then position=parent.WorldPosition
    elseif parent and parent:IsA("BasePart")then position=parent.Position
    elseif parent and parent:IsA("Model")then position=if parent.PrimaryPart then parent.PrimaryPart.Position else parent:GetPivot().Position end
    assert(position~=nil,"Cannot verify external R prompt position")
    assert((position-root.Position).Magnitude>other.MaxActivationDistance+2,"External gameplay R prompt is within avatar reach")
   end
  end
  for _,item in ipairs(model:GetChildren())do if item:IsA("BasePart")and item~=part then
   local other=item:FindFirstChild("Ironveil_"..item.Name)
   if other and other:IsA("ProximityPrompt")then assert((item.Position-root.Position).Magnitude>other.MaxActivationDistance+2,"Another fixture prompt is within avatar reach")end
  end end
  selected=part;previous=part.Position;selectedName=name;part.Position=root.Position-Vector3.new(0,2,0)
 end
 function handle.Far()restore()end
 function handle.SetLevel(level:number)
  assertSettled();assert(level%1==0 and level>=1 and level<=100,"Invalid synthetic level");data.character.level=level
 end
 function handle.Invalidate()
  assertSettled();restore();invalidated=true;session.epoch+=1
 end
 function handle.State():any
  local model=find();local count=0;local enabled=false
  if model then for _,item in ipairs(model:GetDescendants())do if item:IsA("ProximityPrompt")then count+=1 end end end
  if selected and selected.Parent then local prompt=selected:FindFirstChild("Ironveil_"..selected.Name);enabled=prompt~=nil and prompt:IsA("ProximityPrompt")and prompt.Enabled end
  return {synthetic=true,ordinaryProgression=false,profileWrites=0,promptCount=count,selected=selectedName,enabledSelected=enabled,pending=pending,
   receipts=copy(receipts),objectives=copy(data.progression.campaign.objectives),choices=copy(data.progression.campaign.choices),claimed=data.progression.campaign.claimed,level=data.character.level,
   retries=retries,receiptAttempts=attempts,notifications=notifications,forbiddenWorldCalls=forbidden,failed=forbidden>0,minePresent=model~=nil,
   avatarDelta=(root.Position-initial).Magnitude,characterUnchanged=player.Character==character,zoneUnchanged=player:GetAttribute("CurrentZone")==zone,destroyed=destroyed,invalidated=invalidated}
 end
 function handle.Destroy()
  if destroyed then return end
  cleanup();destroyed=true
 end
 return handle
end
