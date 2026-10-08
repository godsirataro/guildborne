--!strict
-- Read-only training cues; caller opts in. No networking, collision or saved state.
local Collection=game:GetService("CollectionService");local Run=game:GetService("RunService");local Input=game:GetService("UserInputService")
local Config=require(game.ReplicatedStorage.Shared.Config.VFXConfig);local V=Vector3.new
return function(scope:Instance?,manual:boolean?,ownerId:number?):any
 local root=scope or workspace;local owner=ownerId or game.Players.LocalPlayer.UserId
 local output=Instance.new("Model");output.Name="GuildborneTowerLessonEffects";output.Parent=workspace
 local entries={};local connections={};local parts:{Part}={};local closed=false;local active=false;local currentLow:boolean?=nil
 local S={}
 local function clear()for _,p in ipairs(parts)do p:Destroy()end;table.clear(parts);active=false;currentLow=nil end
 local function add(model:Instance)if model:IsA("Model")and model:IsDescendantOf(root)then entries[model]=true end end
 local function finite(v:any):boolean return typeof(v)=="Vector3"and v.X==v.X and v.Y==v.Y and v.Z==v.Z and v.Magnitude<1e7 end
 function S.Step(position:Vector3,now:number,low:boolean,reduced:boolean,touch:boolean)
  if closed then return end;low=low or touch
  local chosen:Instance?=nil;local anchor:any=nil;local role:any=nil;local phase:any=nil;local acted=false
  if finite(position)and type(now)=="number"and now==now and math.abs(now)<1e12 then
   for m in pairs(entries)do
    if not m:IsDescendantOf(root)then entries[m]=nil;continue end
    local p:any=m:GetAttribute("CuePosition");local deadline=m:GetAttribute("CueEndsAt");local r=m:GetAttribute("CueRole");local state=m:GetAttribute("LessonPhase")
    if m:GetAttribute("OwnerUserId")==owner and m:GetAttribute("LessonStatus")=="Active"and (r=="Guard"or r=="Mend")and (state=="Warning"or state=="Recovery")and finite(p)and (p-position).Magnitude<=80 and type(deadline)=="number"and deadline==deadline and deadline>now and deadline-now<=8 then
     chosen=m;anchor=p;role=r;phase=state;acted=m:GetAttribute("CueActed")==true;break
    end
   end
  end
  if not chosen then clear();return end
  if #parts==0 or currentLow~=low then
   clear();currentLow=low
   for i=1,(if low then 8 else 14)do
    local p=Instance.new("Part");p.Name=if i<=4 then "TargetBorder"elseif i<=6 then "RoleSymbol"elseif i<=8 then "ShieldEdge"else "TrainingMote"
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Parent=output;table.insert(parts,p)
   end
  end
  active=true;local color=if role=="Guard"and not acted then Color3.fromRGB(243,181,76)else Color3.fromRGB(64,195,185)
  for i,p in ipairs(parts)do
   p.Color=color;p.Transparency=.2
   if i<=4 then
    local angle=(i-1)*math.pi/2;p.Size=V(5,.12,.16);p.CFrame=CFrame.new(anchor-V(0,2.8,0))*CFrame.Angles(0,angle,0)*CFrame.new(0,0,-2.5)
   elseif role=="Guard"then
    if i<=6 then p.Size=V(2.2,2.8,.12);p.CFrame=CFrame.new(anchor+V(if i==5 then -.8 else .8,.4,1.3))*CFrame.Angles(0,if i==5 then -.25 else .25,0);p.Transparency=if acted then .18 else .65
    elseif i<=8 then p.Size=V(.15,3.3,.15);p.CFrame=CFrame.new(anchor+V(if i==7 then -1.8 else 1.8,.4,1.2))
    else p.Size=V(.2,.2,.2);local a=(i-9)*math.pi/3;p.CFrame=CFrame.new(anchor+V(math.cos(a)*2.2,if reduced then 3 else 3+.15*math.sin(now*2),math.sin(a)*2.2));p.Transparency=if reduced or acted then 1 else .4 end
   else
    if i<=6 then p.Size=if i==5 then V(.4,2.4,.2)else V(2.4,.4,.2);p.CFrame=CFrame.new(anchor+V(0,3.3,0));p.Transparency=if phase=="Recovery"then .1 else .65
    elseif i<=8 then p.Size=V(.12,1.6,.12);p.CFrame=CFrame.new(anchor+V(if i==7 then -2 else 2,.5,0));p.Transparency=if phase=="Recovery"then .3 else 1
    else local a=(i-9)*math.pi/3+(if reduced then 0 else now*.6);p.Size=V(.25,.25,.25);p.CFrame=CFrame.new(anchor+V(math.cos(a)*2,if reduced then 1 else .5+(now*.5)%2,math.sin(a)*2));p.Transparency=if phase=="Recovery"then .35 else 1 end
   end
  end
 end
 function S.Stats():any local count=0;for _ in pairs(entries)do count+=1 end;return {tracked=count,active=active,parts=#parts,closed=closed}end
 function S.Destroy()if closed then return end;closed=true;for _,c in ipairs(connections)do c:Disconnect()end;table.clear(connections);table.clear(entries);clear();output:Destroy()end
 for _,m in ipairs(Collection:GetTagged("GuildborneTowerLesson"))do add(m)end
 table.insert(connections,Collection:GetInstanceAddedSignal("GuildborneTowerLesson"):Connect(add))
 table.insert(connections,Collection:GetInstanceRemovedSignal("GuildborneTowerLesson"):Connect(function(m)entries[m]=nil end))
 table.insert(connections,root.Destroying:Connect(S.Destroy))
 if not manual then local elapsed=0;table.insert(connections,Run.RenderStepped:Connect(function(dt)
  elapsed+=dt;if elapsed<1/30 then return end;elapsed=0;local camera=workspace.CurrentCamera;if not camera then return end
  S.Step(camera.CFrame.Position,workspace:GetServerTimeNow(),workspace:GetAttribute(Config.QualityAttribute)=="Low",workspace:GetAttribute(Config.ReducedMotionAttribute)==true,Input.TouchEnabled)
 end))end
 return S
end
