--!strict
-- Isolated support lesson adapter. The caller owns admission and completion receipts.
-- No avatar teleport, XP, profile mutation or real combat-health writes occur here.
local Run=game:GetService("RunService");local V=Vector3.new
local DefaultLesson=require(script.Parent.Parent.Systems.TowerLesson)
local DefaultConfig=require(script.Parent.Parent.Config.TowerLessons)
return function(deps:any?):any
 deps=deps or {};local create=deps.CreateLesson or DefaultLesson;local config=deps.Config or DefaultConfig
 local clock=deps.Now or os.clock;local heartbeat=deps.Heartbeat or Run.Heartbeat
 local current:any=nil;local connections={};local S={}
 local function disconnect()
  for _,c in ipairs(connections)do c:Disconnect()end;table.clear(connections)
 end
 function S.Stop()
  local e=current;if not e then return end;current=nil;e.lesson.cancel();disconnect();e.model:Destroy()
 end
 function S.Start(player:Player,origin:Vector3,role:string,eligible:any,completed:any):(boolean,string)
  if current then return false,"LessonActive"end
  if typeof(origin)~="Vector3"or origin.Magnitude~=origin.Magnitude or origin.Magnitude>1e6 then return false,"InvalidOrigin"end
  if role~="Guard"and role~="Mend"and role~="Combined"then return false,"InvalidRole"end
  if type(eligible)~="function"or type(completed)~="function"then return false,"InvalidCallbacks"end
  local admission=eligible();if not admission or not admission.current or not admission.alive or not admission.near then return false,"NotEligible"end
  local model=Instance.new("Model");model.Name="TowerLesson_"..player.UserId;model:SetAttribute("OwnerUserId",player.UserId);model:SetAttribute("TrainingOnly",true)
  local e:any={player=player,model=model,lesson=create(config,role,clock()),targets={},prompts={},role=role,complete=false,eligible=eligible,completed=completed};current=e
  local function part(name:string,size:Vector3,pos:Vector3,color:Color3,solid:boolean?):Part
   local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=origin+pos;p.Color=color;p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CanTouch=false;p.CanQuery=solid==true;p.CanCollide=solid==true;p.Parent=model;return p
  end
  part("TrainingFloor",V(42,1,28),V(0,-.5,0),Color3.fromRGB(42,57,76),true)
  local board=part("LessonBoard",V(1,1,1),V(0,13,-9),Color3.new());board.Transparency=1
  local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(380,140);gui.AlwaysOnTop=true;gui.MaxDistance=65;gui.Parent=board
  local label=Instance.new("TextLabel");label.Name="Instructions";label.Size=UDim2.fromScale(1,1);label.TextWrapped=true;label.TextSize=18;label.Font=Enum.Font.GothamMedium;label.BackgroundColor3=Color3.fromRGB(22,29,38);label.TextColor3=Color3.fromRGB(244,233,208);label.Parent=gui;e.label=label
  local function bind(prompt:ProximityPrompt,callback:any)
   table.insert(connections,if deps.BindPrompt then deps.BindPrompt(prompt,callback)else prompt.Triggered:Connect(callback))
  end
  for i,id in ipairs(config.Targets)do
   local x=(i-2)*12;local anchor=part("Trainee_"..id,V(2,3,1.5),V(x,3,-5),Color3.fromRGB(64,195,185));anchor.Material=Enum.Material.Neon
   if deps.TargetStyle=="Ward"then
    anchor.Name="Ward_"..id;anchor.Size=V(1.5,4,1.5)
    part("WardCap",V(2.8,.5,2.8),V(x,5.3,-5),Color3.fromRGB(216,207,185))
    local shield=part("WardShield",V(5,5,.25),V(x,3.5,-5.8),Color3.fromRGB(64,195,185));shield.Material=Enum.Material.Neon;shield.Transparency=.65
   else
    part("TraineeHead",V(1.8,1.8,1.8),V(x,5.5,-5),Color3.fromRGB(216,207,185))
    for _,dx in ipairs({-1.5,1.5})do part("TraineeArm",V(.8,2,.8),V(x+dx,3,-5),Color3.fromRGB(64,195,185))end
   end
   local targetGui=Instance.new("BillboardGui");targetGui.Size=UDim2.fromOffset(160,70);targetGui.StudsOffset=V(0,5,0);targetGui.AlwaysOnTop=true;targetGui.MaxDistance=55;targetGui.Parent=anchor
   local text=Instance.new("TextLabel");text.Name="TrainingHealth";text.Size=UDim2.fromScale(1,1);text.TextWrapped=true;text.TextSize=16;text.Font=Enum.Font.Gotham; text.BackgroundColor3=Color3.fromRGB(22,29,38);text.TextColor3=Color3.fromRGB(244,233,208);text.Parent=targetGui
   e.targets[id]={part=anchor,label=text}
   for _,action in ipairs({"Guard","Mend"})do
    local prompt=Instance.new("ProximityPrompt");prompt.Name=action.."_"..id;prompt.MaxActivationDistance=8;prompt.RequiresLineOfSight=false;prompt.HoldDuration=0;prompt.Exclusivity=Enum.ProximityPromptExclusivity.AlwaysShow
    prompt.KeyboardKeyCode=if action=="Guard"then Enum.KeyCode.E else Enum.KeyCode.R;prompt.GamepadKeyCode=if action=="Guard"then Enum.KeyCode.ButtonX else Enum.KeyCode.ButtonY
    prompt.UIOffset=Vector2.new(if action=="Guard"then -80 else 80,0);prompt.Parent=anchor;e.prompts[prompt]={action=action,target=id}
    bind(prompt,function(who:Player)
     if who~=player or current~=e or e.complete then return end
     local state=eligible();local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
     if not state or not state.current or not state.alive or not state.near or not r or not r:IsA("BasePart")or (r.Position-anchor.Position).Magnitude>9 then return end
     local ok,code=e.lesson.act(action,id,clock());model:SetAttribute("LastAction",code);model:SetAttribute("LastActionAccepted",ok)
    end)
   end
  end
  model.Parent=deps.Parent or workspace;game:GetService("CollectionService"):AddTag(model,"GuildborneTowerLesson")
  local function step()
   if current~=e then return end
   local state=eligible()or {};local now=clock();e.lesson.step(now,state.current==true,state.alive==true,state.near==true)
   local view=e.lesson.snapshot();local th=state.language=="th";local language=if th then 2 else 1;local cue=view.cue
   model:SetAttribute("LessonStatus",view.status);model:SetAttribute("LessonRole",role);model:SetAttribute("LessonPhase",view.phase);model:SetAttribute("Successes",view.successes)
   model:SetAttribute("CueTarget",cue and cue.target or nil);model:SetAttribute("CueRole",cue and cue.role or nil)
   model:SetAttribute("CuePosition",if cue then e.targets[cue.target].part.Position else nil)
   model:SetAttribute("CueActed",cue and cue.acted or false)
   model:SetAttribute("CueEndsAt",if cue then workspace:GetServerTimeNow()+math.max(0,(if view.phase=="Warning"then cue.impactAt else cue.expiresAt)-now)else nil)
   local title=if deps.Title then deps.Title[language]elseif th then "บทฝึกสนับสนุน · ไม่ใช้พลังชีวิตจริง"else "Support lesson · training health only"
   local instruction=if cue then config.Roles[cue.role][language].." · "..config.Labels[cue.target][language]else config.Roles[role][language]
   local status=if view.status=="Completed"then (if th then "ผ่านบทฝึก"else "Lesson complete")elseif view.status=="Failed"then (if th then "ลองใหม่ที่สถานีฝึก"else "Retry at the training station")elseif view.status=="Cancelled"then (if th then "ออกจากบทฝึกแล้ว"else "Lesson ended")else instruction
   label.Text=title.."\n"..status.."\n"..view.successes.." / "..config.RequiredSuccesses..(if th then " สำเร็จ · "else " complete · ")..view.mistakes.." / "..config.MaxMistakes..(if th then " พลาด"else " mistakes")
   for id,target in pairs(e.targets)do
    target.label.Text=config.Labels[id][language].."\n"..(if th then "HP ฝึก "else "Training HP ")..view.health[id].."/"..view.maxHealth
    target.part.Color=if cue and cue.target==id then (if cue.role=="Guard"then Color3.fromRGB(243,181,76)else Color3.fromRGB(64,195,185))else Color3.fromRGB(99,157,220)
   end
   for prompt,info in pairs(e.prompts)do
    prompt.Enabled=view.status=="Active";prompt.ActionText=if info.action=="Guard"then (if th then "โล่ฝึก"else "Training shield")else (if th then "ฟื้นฟูฝึก"else "Training heal")
    prompt.ObjectText=config.Labels[info.target][language]
   end
   if view.status=="Completed"and not e.complete then e.complete=true;completed(player,role)end
   if view.status=="Cancelled"then S.Stop()end
  end
  step();if current==e then table.insert(connections,heartbeat:Connect(step))end
  return true,"Started"
 end
 function S.Snapshot():any return if current then current.lesson.snapshot()else nil end
 function S.Destroy()S.Stop()end
 return S
end
