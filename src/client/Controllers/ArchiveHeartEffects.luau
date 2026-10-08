--!strict
-- Read-only objective glyphs. Server warning footprints remain authoritative and separate.
local Tags=game:GetService("CollectionService");local Run=game:GetService("RunService");local Input=game:GetService("UserInputService")
local Config=require(game.ReplicatedStorage.Shared.Config.VFXConfig);local V=Vector3.new
return function(scope:Instance?,manual:boolean?,ownerId:number?):any
 local root=scope or workspace;local owner=ownerId or game.Players.LocalPlayer.UserId
 local output=Instance.new("Model");output.Name="GuildborneArchiveHeartEffects";output.Parent=workspace
 local entries={};local connections={};local parts:{Part}={};local closed=false;local active=false;local lastLow:boolean?=nil;local S={}
 local function clear()for _,p in ipairs(parts)do p:Destroy()end;table.clear(parts);active=false;lastLow=nil end
 local function finite(v:any):boolean return typeof(v)=="Vector3"and v.Magnitude==v.Magnitude and v.Magnitude<1e7 end
 local function add(m:Instance)if m:IsA("Model")and m:IsDescendantOf(root)then entries[m]=true end end
 function S.Step(position:Vector3,now:number,low:boolean,reduced:boolean,touch:boolean)
  if closed then return end;low=low or touch
  local chosen:Instance?=nil;local anchor:any=nil;local phase:any=nil
  if finite(position)and now==now and math.abs(now)<1e12 then
   for m in pairs(entries)do
    if not m:IsDescendantOf(root)then entries[m]=nil;continue end
    local p:any=m:GetAttribute("TargetPosition");local state=m:GetAttribute("EncounterPhase");local untilAt=m:GetAttribute("EncounterCueUntil")
    if m:GetAttribute("OwnerUserId")==owner and m:GetAttribute("TrialStatus")=="Active"and (state=="Rescue"or state=="Mechanism"or state=="Attack")and finite(p)and (p-position).Magnitude<=80 and type(untilAt)=="number"and untilAt==untilAt and untilAt>now and untilAt-now<=13 then chosen=m;anchor=p;phase=state;break end
   end
  end
  if not chosen then clear();return end
  if #parts==0 or lastLow~=low then
   clear();lastLow=low
   for i=1,(if low then 8 else 16)do local p=Instance.new("Part");p.Name=if i<=4 then "TargetBracket"elseif i<=8 then "ObjectiveGlyph"else "ArchiveMote";p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Parent=output;table.insert(parts,p)end
  end
  active=true
  local color=if phase=="Rescue"then Color3.fromRGB(64,195,185)elseif phase=="Mechanism"then Color3.fromRGB(178,139,226)else Color3.fromRGB(238,196,108)
  for i,p in ipairs(parts)do
   p.Color=color;p.Transparency=.2;p.Shape=Enum.PartType.Block
   if i<=4 then
    local x=if i%2==0 then 2.4 else -2.4;local z=if i<=2 then -2.4 else 2.4
    p.Size=V(.18,1.3,.18);p.CFrame=CFrame.new(anchor+V(x,-2.2,z))
   elseif i<=8 then
    local n=i-4;local center=anchor+V(0,3,0)
    if phase=="Rescue"then
     p.Size=if n==1 then V(.85,.85,.85)elseif n==2 then V(.5,1.7,.3)else V(1.2,.3,.3)
     p.CFrame=CFrame.new(center+V(if n==3 then -.65 elseif n==4 then .65 else 0,if n==1 then 1 elseif n==2 then -.25 else .1,0))
    elseif phase=="Mechanism"then
     p.Size=V(1.7,.25,.25);local a=(n-1)*math.pi/2+math.pi/4;p.CFrame=CFrame.new(center+V(math.cos(a)*.8,math.sin(a)*.8,0))*CFrame.Angles(0,0,a+math.pi/2)
    else
     p.Size=if n<=2 then V(.25,2.8,.25)else V(1.2,.25,.25)
     p.CFrame=CFrame.new(center+V(if n%2==1 then -.5 else .5,if n<=2 then 0 else -.6,0))*CFrame.Angles(0,0,if n%2==1 then -.4 else .4)
    end
   else
    local a=(i-9)*math.pi/4+(if reduced then 0 else now*.4);p.Size=V(.18,.18,.18);p.CFrame=CFrame.new(anchor+V(math.cos(a)*3.1,if reduced then .5 else .5+.2*math.sin(now),math.sin(a)*3.1));p.Transparency=if reduced then 1 else .45
   end
  end
 end
 function S.Stats():any local n=0;for _ in pairs(entries)do n+=1 end;return {tracked=n,active=active,parts=#parts,closed=closed}end
 function S.Destroy()if closed then return end;closed=true;for _,c in ipairs(connections)do c:Disconnect()end;table.clear(entries);clear();output:Destroy()end
 for _,m in ipairs(Tags:GetTagged("GuildborneArchiveEncounter"))do add(m)end
 table.insert(connections,Tags:GetInstanceAddedSignal("GuildborneArchiveEncounter"):Connect(add));table.insert(connections,Tags:GetInstanceRemovedSignal("GuildborneArchiveEncounter"):Connect(function(m)entries[m]=nil end));table.insert(connections,root.Destroying:Connect(S.Destroy))
 if not manual then local elapsed=0;table.insert(connections,Run.RenderStepped:Connect(function(dt)elapsed+=dt;if elapsed<1/30 then return end;elapsed=0;local camera=workspace.CurrentCamera;if camera then S.Step(camera.CFrame.Position,workspace:GetServerTimeNow(),workspace:GetAttribute(Config.QualityAttribute)=="Low",workspace:GetAttribute(Config.ReducedMotionAttribute)==true,Input.TouchEnabled)end end))end
 return S
end
