--!strict
-- Read-only local feedback. No rewards, prompt activation, collision or networking.
local Collection=game:GetService("CollectionService")
local Run=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local V=Vector3.new
local amber=Color3.fromRGB(242,148,68);local teal=Color3.fromRGB(75,214,182)
type Entry={model:Model,visual:Model?,parts:{Part},mode:string?,low:boolean?}
return function(scope:Instance?,manual:boolean?,ownerId:number?):any
 local root=scope or workspace;local owner=ownerId or game.Players.LocalPlayer.UserId
 local entries:{[Instance]:Entry}={};local connections:{RBXScriptConnection}={};local closed=false
 local output=Instance.new("Folder");output.Name="GuildborneMineActivityEffects";output.Parent=workspace
 local api:any={}
 local function clear(e:Entry)
  if e.visual then e.visual:Destroy();e.visual=nil end
  table.clear(e.parts);e.mode=nil;e.low=nil
 end
 local function remove(value:Instance)local e=entries[value];if e then clear(e);entries[value]=nil end end
 local function add(value:Instance)
  if closed or entries[value]or not value:IsA("Model")or not value:IsDescendantOf(root)then return end
  entries[value]={model=value,parts={}}
 end
 local function make(e:Entry,mode:string,low:boolean)
  clear(e);local m=Instance.new("Model");m.Name=mode;m.Parent=output;e.visual=m;e.mode=mode;e.low=low
  local count=if mode=="Protection"then (if low then 8 else 14)else (if low then 8 else 12)
  for i=1,count do
   local p=Instance.new("Part");p.Name=if mode=="Protection"then (if i<=4 then "WarningBorder"elseif i<=8 then "SafetyShutter"else "FallingDebris")else (if i<=4 then "MinerFootprint"else "ExitBeacon")
   p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Parent=m;table.insert(e.parts,p)
  end
 end
 local function finite(v:any):boolean
  return typeof(v)=="Vector3"and v.X==v.X and v.Y==v.Y and v.Z==v.Z and v.Magnitude<1e7
 end
 function api.Step(position:Vector3,now:number,low:boolean,reduced:boolean,touch:boolean)
  if closed then return end
  low=low or touch
  local displayed=false
  for value,e in pairs(entries)do
   if not value:IsDescendantOf(root)then remove(value);continue end
   if value:GetAttribute("CampaignOwner")~=owner then clear(e);continue end
   local warning:any=value:GetAttribute("ProtectionWarningPosition")
   local impact=value:GetAttribute("ProtectionImpactAt")
   local escort:any=value:GetAttribute("EscortPosition");local exit:any=value:GetAttribute("EscortExit")
   local state=value:GetAttribute("EscortStatus")
   local protection=value:GetAttribute("ProtectionStatus")=="Active"and finite(warning)and type(impact)=="number"and impact>now and impact-now<=3
   local rescuing=(state=="Walking"or state=="Paused")and finite(escort)and finite(exit)
   local mode=if protection then "Protection"elseif rescuing then "Escort"else nil
   local anchor=if protection then warning else escort
   if displayed or not mode or not finite(anchor)or (anchor-position).Magnitude>100 then clear(e);continue end
   displayed=true
   if not e.visual or e.mode~=mode or e.low~=low then make(e,mode,low)end
   if protection then
    local blocked=value:GetAttribute("ProtectionWarningBlocked")==true
    local color=if blocked then teal else amber
    local phase=math.clamp(1-((impact :: number)-now)/2.5,0,1)
    for i,p in ipairs(e.parts)do
     p.Color=color;p.Transparency=.2
     if i<=4 then
      local angle=(i-1)*math.pi/2;p.Size=V(7,.1,.15);p.CFrame=CFrame.new(warning)*CFrame.Angles(0,angle,0)*CFrame.new(0,.18,-3.5)
     elseif i<=8 then
      p.Size=V(6,.35,.2);p.CFrame=CFrame.new(warning+V(0,if blocked then .6+(i-5)*.55 else 4.2+(i-5)*.4,-1.5))
      p.Transparency=if blocked then .15 else .6
     else
      p.Size=V(.32,.32,.32);local k=i-9
      p.CFrame=CFrame.new(warning+V((k%3-1)*1.7,if reduced then 5 else 1+(1-phase)*6,math.floor(k/3)*1.5-.75))
      p.Transparency=if blocked or reduced then 1 else .25+phase*.5
     end
    end
   else
    local color=if state=="Paused"then amber else teal
    for i,p in ipairs(e.parts)do
     p.Color=color;p.Transparency=.25
     if i<=4 then
      local angle=(i-1)*math.pi/2;p.Size=V(3,.1,.15);p.CFrame=CFrame.new(escort)*CFrame.Angles(0,angle,0)*CFrame.new(0,.2,-1.5)
     else
      local count=#e.parts-4;local angle=(i-5)*math.pi*2/count
      p.Size=V(.18,if reduced then 1.5 else 1.5+.2*math.sin(now*1.8),.18)
      p.CFrame=CFrame.new(exit+V(math.cos(angle)*2,1,math.sin(angle)*2))
     end
    end
   end
  end
 end
 function api.Stats():any
  local tracked,active,parts=0,0,0;for _,e in pairs(entries)do tracked+=1;if e.visual then active+=1;parts+=#e.parts end end
  return {tracked=tracked,active=active,parts=parts,closed=closed}
 end
 function api.Destroy()
  if closed then return end;closed=true;for _,c in ipairs(connections)do c:Disconnect()end;table.clear(connections)
  for _,e in pairs(entries)do clear(e)end;table.clear(entries);output:Destroy()
 end
 for _,value in ipairs(Collection:GetTagged("GuildborneMineActivity"))do add(value)end
 table.insert(connections,Collection:GetInstanceAddedSignal("GuildborneMineActivity"):Connect(add))
 table.insert(connections,Collection:GetInstanceRemovedSignal("GuildborneMineActivity"):Connect(remove))
 table.insert(connections,root.Destroying:Connect(api.Destroy))
 if not manual then
  local elapsed=0;table.insert(connections,Run.RenderStepped:Connect(function(dt)
   elapsed+=dt;if elapsed<1/30 then return end;elapsed=0;local camera=workspace.CurrentCamera;if not camera then return end
   api.Step(camera.CFrame.Position,workspace:GetServerTimeNow(),workspace:GetAttribute(Config.QualityAttribute)=="Low",workspace:GetAttribute(Config.ReducedMotionAttribute)==true,Input.TouchEnabled)
  end))
 end
 return api
end
