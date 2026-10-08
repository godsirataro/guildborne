--!strict
-- Private native adapter. Admission/profile selection belongs to its caller.
-- This module samples the actual avatar and delivers a server-owned receipt only.
local Run=game:GetService("RunService");local Players=game:GetService("Players");local Tags=game:GetService("CollectionService")
local Server=script.Parent.Parent;local Shared=game.ReplicatedStorage.Shared;local V=Vector3.new
local Util=require(Shared.Util.TableUtil);local Content=require(Server.Config.Content);local Combat=require(Server.Config.Combat)
local Config=require(Server.Config.ArchiveHeartEncounters)
local Gear=require(Shared.Data.Equipment)(Content,require(Shared.Data.Expansion),require(Shared.Data.StatusPoints))
local Create=require(Server.Systems.ArchiveHeartCombat)({Util=Util,Content=Content,Combat=Combat,EncounterConfig=Config,
 Create=require(Server.Systems.ArchiveHeartEncounter)(Config,Util,require(Server.Systems.AdventurePatterns)),
 Stats=require(Server.Systems.CombatStats)(Content,Combat,Gear),Targeting=require(Server.Systems.CombatTargeting),Damage=require(Server.Systems.CombatDamage),Abilities=require(Server.Systems.CombatAbilities)})
return function(player:Player,data:any,mode:string,runId:string,origin:Vector3,eligible:any,completed:any,exited:any?):any
 assert(typeof(origin)=="Vector3"and origin.Magnitude<1e6,"Invalid arena origin")
 assert(type(eligible)=="function"and type(completed)=="function","Missing arena callbacks")
 local sim,problem=Create(data,player.UserId,runId,mode,os.clock());assert(sim,problem)
 local character=assert(player.Character);local humanoid=assert(character:FindFirstChildOfClass("Humanoid"));local root=assert(character:FindFirstChild("HumanoidRootPart")) :: BasePart
 local returnTo=character:GetPivot();local disposed=false;local delivered=false;local delivering=false;local pending:any=nil;local retryAt=0;local started=false
 local th=data.settings and data.settings.language=="th";local connections:{RBXScriptConnection}={};local api:any={}
 local model=Instance.new("Model");model.Name="ArchiveEncounter_"..player.UserId;model:SetAttribute("OwnerUserId",player.UserId);model:SetAttribute("CampaignOwner",player.UserId);model:SetAttribute("ArchiveHeartArena",true);model:SetAttribute("ClassId",data.character.classId)
 local function part(name:string,size:Vector3,pos:Vector3,color:Color3,solid:boolean?):Part
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=origin+pos;p.Color=color;p.Anchored=true;p.CanCollide=solid==true;p.CanQuery=solid==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model;return p
 end
 part("ArchiveFloor",V(94,1,94),V(0,-.5,0),Color3.fromRGB(33,45,65),true)
 for _,x in ipairs({-46,46})do part("Boundary",V(1,1,94),V(x,.5,0),Color3.fromRGB(202,168,94))end
 for _,z in ipairs({-46,46})do part("Boundary",V(94,1,1),V(0,.5,z),Color3.fromRGB(202,168,94))end
 local kit=require(script.Parent.ArchiveHeartBossKit)(true);local boss=assert(kit:FindFirstChild(if mode=="warden"then "last_warden"else "keeper_of_names")) :: Model
 boss:PivotTo(CFrame.new(origin)*CFrame.Angles(0,math.pi,0));boss:SetAttribute("OwnerUserId",player.UserId);boss:SetAttribute("GuildborneEnemy",true);boss:SetAttribute("EnemyAnimationClass",if mode=="warden"then "Knight"else "Mage")
 boss:SetAttribute("CombatHealth",100);boss:SetAttribute("CombatState","Idle");boss.Parent=model;kit:Destroy();Tags:AddTag(boss,"GuildborneAnimatedEnemy")
 local warnings=Instance.new("Folder");warnings.Name="CommittedWarning";warnings.Parent=model;local lastWarning:any=nil
 local function warningPart(size:Vector3,cf:CFrame)
  local p=part("Warning",size,V(0,0,0),Color3.fromRGB(245,140,63));p.Material=Enum.Material.Neon;p.Transparency=.35;p.CFrame=cf;p.Parent=warnings
 end
 local function showWarning(w:any)
  warnings:ClearAllChildren();if not w then return end
  local center=origin+V(w.x,.08,w.z)
  if w.shape=="Line"then
   local direction=V(w.dx,0,w.dz);warningPart(V(w.width,.12,w.length),CFrame.lookAt(center+direction*w.length/2,center+direction*(w.length/2+1)))
  elseif w.shape=="Circle"then
   warningPart(V(.12,w.radius*2,w.radius*2),CFrame.new(center)*CFrame.Angles(0,0,math.pi/2));(warnings:GetChildren()[1] :: Part).Shape=Enum.PartType.Cylinder
  else
   local inner,outer=w.innerRadius,w.radius;local middle=(inner+outer)/2
   for i=1,48 do local angle=i*math.pi*2/48;local radial=V(math.sin(angle),0,math.cos(angle));local pos=center+radial*middle
    warningPart(V(2*outer*math.tan(math.pi/48),.12,outer-inner),CFrame.lookAt(pos,pos+radial))
   end
  end
 end
 local function sample(at:number):string
  local valid=player.Parent==Players and player.Character==character and root.Parent~=nil and eligible()==true
  local p=root.Position-origin
  return sim.step(at,{x=p.X,y=p.Y-3,z=p.Z},valid,humanoid.Health>0)
 end
 local promptRows={}
 for _,kind in ipairs({"Rescue","Release"})do
  if kind=="Rescue"and mode~="keeper"then continue end
  local points=if kind=="Rescue"then Config.RescuePoints else Config.SealPoints
  for index,p in ipairs(points)do
   local anchor=part(kind..index,if kind=="Rescue"then V(2,3,2)else V(2,1,2),V(p.x,if kind=="Rescue"then 1.5 else .5,p.z),if kind=="Rescue"then Color3.fromRGB(101,192,189)else Color3.fromRGB(201,155,233))
   local prompt=Instance.new("ProximityPrompt");prompt.Name=kind..index;prompt.ActionText=if kind=="Rescue"then (if th then "ช่วยผู้ติดค้าง"else "Free the trapped name")else (if th then "ปลดตรา"else "Release seal")
   prompt.ObjectText=tostring(index).." / 3";prompt.MaxActivationDistance=7;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.HoldDuration=0;prompt.Enabled=false;prompt.Parent=anchor
   table.insert(promptRows,{prompt=prompt,part=anchor,kind=kind,index=index})
   table.insert(connections,prompt.Triggered:Connect(function(who)
    if disposed or who~=player or not started then return end
    local at=os.clock();if sample(at)~="Active"then return end
    local s=sim.snapshot();local expected=if kind=="Rescue"then "Rescue"else "Mechanism";if s.stage~=index or s.phase~=expected then return end
    local ok,code=sim.act(kind,at);model:SetAttribute("LastActionAccepted",ok);model:SetAttribute("LastAction",code)
   end))
  end
 end
 local input=Instance.new("RemoteEvent");input.Name="TrialInput";input.Parent=model
 local accept=require(Server.Systems.NoviceTrialInput)(player.UserId)
 model:SetAttribute("BasicLabel",if th then "โจมตีพื้นฐาน"else "Basic Attack");model:SetAttribute("AbilityLabel",if th then "สกิลประจำคลาส"else "Class skill");model:SetAttribute("ReturnLabel",if th then "ออกจากการทดสอบ"else "Leave encounter")
 local function update()
  if disposed then return end
  local s=sim.snapshot();local warning=s.warning;local token=warning and warning.due
  if token~=lastWarning then lastWarning=token;showWarning(warning);boss:SetAttribute("TelegraphAt",if warning then workspace:GetServerTimeNow()else nil);boss:SetAttribute("TelegraphDuration",if warning then math.max(0,warning.due-os.clock())else nil)end
  boss:SetAttribute("CombatState",if s.phase=="Warning"then "Windup"elseif s.phase=="Attack"then "Attack"else "Idle")
  boss:SetAttribute("CombatHealth",if s.status=="Won"then 0 else s.coreHealth)
  model:SetAttribute("TrialStatus",s.status);model:SetAttribute("EncounterPhase",s.phase);model:SetAttribute("EncounterStage",s.stage);model:SetAttribute("Seals",s.seals);model:SetAttribute("Mistakes",s.mistakes);model:SetAttribute("CombatHits",s.combatHits)
  model:SetAttribute("TargetPosition",if s.target then origin+V(s.target.x,3,s.target.z)else nil)
  model:SetAttribute("EncounterCueUntil",workspace:GetServerTimeNow()+math.max(0,s.deadline-os.clock()))
  model:SetAttribute("WarningToken",token);model:SetAttribute("CoreHealth",s.coreHealth)
  local names={Ready={"Prepare","เตรียมพร้อม"},Warning={"Dodge orange warning","หลบพื้นที่สีส้ม"},Rescue={"Free the teal captive · E","ช่วยผู้ติดค้างสีฟ้า · E"},Mechanism={"Release violet seal · E","ปลดตราสีม่วง · E"},Attack={"Core exposed · move close and F","แกนเปิด · เข้าใกล้แล้วกด F"},Finished={"Encounter ended","จบการทดสอบ"}}
  local language=if th then 2 else 1
  model:SetAttribute("DisplayTitle",if mode=="warden"then "Last Warden"else "Keeper of Names")
  model:SetAttribute("DisplayHealth",(if th then "ตรา "else "Seals ")..s.seals.."/3 · "..(if th then "พลาด "else "Mistakes ")..s.mistakes.."/3")
  model:SetAttribute("DisplayGoals",if not started then (if th then "กด F เพื่อเริ่ม"else "Press F to begin")else names[s.phase][language])
  local hint=if th then "หลบ → ช่วย → ปลดตรา → โจมตี"else "Dodge → rescue → release → strike"
  if mode=="warden"then hint=if th then "หลบ → ปลดตรา · ไม่ต้องโจมตี"else "Dodge → release · no attack needed"end
  if warning then
   hint=if warning.shape=="Line"then (if th then "ก้าวออกด้านข้างของแนวเส้น"else "Step sideways out of the line")elseif warning.shape=="Ring"then (if th then "เข้ากลางวงหรือออกนอกวงแหวน"else "Move into the center or outside the ring")else (if th then "ออกจากวงที่ตำแหน่งเดิมของคุณ"else "Leave the circle marking your last position")
  elseif s.phase=="Attack"then hint=(if th then "พลังแกน "else "Core HP ")..s.coreHealth.."/"..s.coreMaxHealth..(if th then " · ทุกคลาสกด F ได้"else " · all classes can use F")end
  if s.status=="Won"then hint=if delivered then (if th then "สำเร็จ · ออกเพื่อเดินทางต่อ"else "Complete · leave to continue")else (if th then "กำลังบันทึกผล…"else "Saving result…")
  elseif s.status~="Active"then hint=if th then "ออกแล้วเริ่มใหม่ได้"else "Leave and retry when ready"end
  model:SetAttribute("DisplayHint",hint)
  for _,name in ipairs({"Basic","Ability"})do local untilAt=if name=="Basic"then s.nextAttack else s.nextAbility;model:SetAttribute("Next"..name.."At",workspace:GetServerTimeNow()+math.max(0,untilAt-os.clock()))end
  for _,row in ipairs(promptRows)do local active=started and s.status=="Active"and s.stage==row.index and s.phase==(if row.kind=="Rescue"then "Rescue"else "Mechanism");row.prompt.Enabled=active;row.part.Transparency=if active then 0 else .8 end
  if s.status=="Won"and not delivered and not delivering and os.clock()>=retryAt then
   pending=pending or sim.receipt(os.clock(),player.UserId)
   if pending then delivering=true;retryAt=os.clock()+.5;local ok,result=pcall(completed,Util.copy(pending));delivered=ok and result==true;delivering=false;if not disposed then model:SetAttribute("ReceiptDelivered",delivered)end end
  end
 end
 table.insert(connections,input.OnServerEvent:Connect(function(who,action,...)
  if disposed or not accept(who.UserId,action,os.clock(),select("#",...))then return end
  if action=="Return"then if sim.snapshot().status=="Won"and not delivered then return end;if exited then exited()else api.Destroy()end;return end
  if not started then if eligible()~=true then return end;local fresh,why=Create(data,player.UserId,runId,mode,os.clock());if not fresh then model:SetAttribute("TrialProblem",why);return end;sim=fresh;started=true end
  local at=os.clock();if sample(at)~="Active"then update();return end
  local ok,code=sim.input(action,at);model:SetAttribute("LastActionAccepted",ok);model:SetAttribute("LastAction",code)
  if ok then local ability=Combat.Abilities[Combat.Classes[data.character.classId].Ability];model:SetAttribute("ActionEffect",if action=="Basic"then "Basic"else ability.Effect);model:SetAttribute("ActionAbilityId",if action=="Basic"then nil else ability.Id);model:SetAttribute("ActionOriginPosition",root.Position);model:SetAttribute("ActionTargetPosition",origin+V(0,3,0));model:SetAttribute("ActionAt",workspace:GetServerTimeNow())end
  update()
 end))
 model.Parent=workspace;Tags:AddTag(model,"GuildborneArchiveEncounter");api.model=model
 character:PivotTo(CFrame.new(origin+V(0,3,22)));root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 local elapsed=0;table.insert(connections,Run.Heartbeat:Connect(function(dt)elapsed+=dt;if elapsed<.05 or disposed then return end;elapsed=0;if started then sample(os.clock())end;update()end))
 function api.Snapshot():any return sim.snapshot()end
 function api.Destroy()if disposed then return end;disposed=true;sim.cancel();for _,c in ipairs(connections)do c:Disconnect()end;model:Destroy();if player.Character==character and root.Parent and humanoid.Health>0 then character:PivotTo(returnTo);root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero end end
 update();return api
end
