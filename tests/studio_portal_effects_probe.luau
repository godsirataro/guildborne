--!strict
-- Manual presentation time and isolated tagged Parts; never triggers travel.
return function(make:any):any
 local collection=game:GetService("CollectionService")
 local folder=Instance.new("Folder");folder.Name="PortalEffectsFixture";folder.Parent=workspace
 local center=Vector3.new(7000,10,7000);local anchors={};local api:any=nil;local output:Instance?=nil
 local stages={};local checked=0
 local function anchor(i:number):Part
  local p=Instance.new("Part");p.Name="TestPortal"..i;p.Size=Vector3.new(9,11,.4);p.Anchored=true;p.CanCollide=false
  p.Position=center+Vector3.new(i*3,0,0);p:SetAttribute("TravelDestination",({"City","Guild","Greenwood","Ironveil","Ashen"})[(i-1)%5+1]);p.Parent=folder
  local prompt=Instance.new("ProximityPrompt");prompt.Enabled=true;prompt.Parent=p;collection:AddTag(p,"GuildborneTravelPortal");return p
 end
 local ok,result=pcall(function():any
  for i=1,10 do anchors[i]=anchor(i) end
  local before={};for _,child in ipairs(workspace:GetChildren()) do before[child]=true end
  api=make(folder,true)
  for _,child in ipairs(workspace:GetChildren()) do if not before[child]and child.Name=="GuildbornePortalEffects"then output=child end end
  assert(output)
  local function step(name:string,pos:Vector3,now:number,low:boolean,reduced:boolean,touch:boolean,active:number,parts:number)
   api.Step(pos,now,low,reduced,touch);local stats=api.Stats();assert(stats.active==active and stats.parts==parts,name)
   for _,p in ipairs((output :: Instance):GetDescendants()) do if p:IsA("BasePart") then assert(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery and not p.CastShadow);checked+=1 end end
   table.insert(stages,{name=name,active=stats.active,parts=stats.parts})
  end
  step("desktop high saturation",center,1,false,false,false,3,36)
  step("low rebuild",center,2,true,false,false,2,16)
  step("touch high cap",center,3,false,false,true,2,24)
  step("reduced motion first",center,10,false,true,false,3,36)
  local poses={};for _,p in ipairs((output :: Instance):GetDescendants()) do if p:IsA("BasePart")then poses[p]={cf=p.CFrame,alpha=p.Transparency}end end
  step("reduced motion later",center,20,false,true,false,3,36)
  for p,pose in pairs(poses)do assert(p.Parent and p.CFrame==pose.cf and p.Transparency==pose.alpha,"Reduced motion moved")end
  step("reverse face readability",center-Vector3.new(0,0,5),20,false,true,false,3,36)
  for p,pose in pairs(poses)do assert(p.Parent and math.abs(p.Position.Z-pose.cf.Position.Z+.9)<.001,"Wrong portal face")end
  step("distance cull",center+Vector3.new(1000,0,0),21,false,false,false,0,0)
  step("return rebuild",center,22,false,false,false,3,36)
  collection:RemoveTag(anchors[1],"GuildborneTravelPortal");assert(api.Stats().tracked==9)
  step("removed tag replacement",center,23,false,false,false,3,36)
  anchors[11]=anchor(11);assert(api.Stats().tracked==10)
  anchors[2]:SetAttribute("TravelDestination","Ashen");step("destination changes",center,24,false,false,false,3,36)
  local matching=0;for _,m in ipairs((output :: Instance):GetChildren())do if m:GetAttribute("Destination")=="Ashen"then matching+=1 end end;assert(matching>=1)
  anchors[2]:SetAttribute("TravelDestination","Unknown");step("unknown destination hidden",center,25,false,false,false,3,36)
  anchors[2]:SetAttribute("TravelDestination","City");step("destination restored",center,26,false,false,false,3,36)
  anchors[3].Parent=nil;step("streamed out",center,27,false,false,false,3,36);assert(api.Stats().tracked==9)
  for _,p in ipairs(anchors)do local prompt=p:FindFirstChildOfClass("ProximityPrompt");assert(prompt and prompt.Enabled,"Prompt changed")end
  folder:Destroy();assert(api.Stats().closed and api.Stats().parts==0 and (output :: Instance).Parent==nil)
  api.Destroy();return {stages=stages,geometryChecks=checked,promptMutations=0,profileWrites=0,cleanup=true}
 end)
 if api then api.Destroy()end;folder:Destroy();for _,p in ipairs(anchors)do p:Destroy()end
 assert(ok,tostring(result));return result
end
