--!strict
-- Disposable synthetic native probe, not live campaign acceptance. No remote calls.
local shared=game:GetService("ReplicatedStorage").Shared
local collect=require(game.StarterPlayer.StarterPlayerScripts.Client.UI.Components.CampaignRouteContext)
local city=require(shared.Config.City)
local route=require(shared.Data.QuestRoute)(city,{Paths={}},require(shared.Data.CityWaypoint))
local root=Instance.new("Folder");root.Name="SyntheticCampaignRouteProbe";root.Parent=workspace
local gui=Instance.new("ScreenGui");gui.Name="CampaignRouteProbe";gui.ResetOnSpawn=false
gui.Parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local label=Instance.new("TextLabel");label.Size=UDim2.new(1,-32,1,-32);label.Position=UDim2.fromOffset(16,16)
label.BackgroundColor3=Color3.fromRGB(15,21,35);label.TextColor3=Color3.fromRGB(245,236,216)
label.TextSize=16;label.Font=Enum.Font.Code;label.TextWrapped=true;label.TextXAlignment=Enum.TextXAlignment.Left
label.TextYAlignment=Enum.TextYAlignment.Top;label.Parent=gui
local lines={"GUILDBORNE / SYNTHETIC CAMPAIGN ROUTE PROBE","Native Instances + actual collector and route modules. No game services."}
local passed,failed=0,0
local function check(name:string,run:any)
 local ok,err=pcall(run)
 if ok then passed+=1 else failed+=1 end
 table.insert(lines,(if ok then "PASS " else "FAIL ")..name..(if ok then "" else ": "..tostring(err)))
 label.Text=table.concat(lines,"\n")
 print("CAMPAIGN_ROUTE_NATIVE_PROBE",name,ok,err)
end
local function part(model:Model,name:string,position:Vector3,size:Vector3):Part
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Position=position;p.Size=size;p.Parent=model;return p
end
local function court(prefix:string,x:number,width:number):Model
 local m=Instance.new("Model");m.Name=prefix.."Court_7";m:SetAttribute("CampaignOwner",7);m.Parent=root
 if prefix=="Tower" then m:SetAttribute("Chapter04Court",true) end
 part(m,"CourtWalkableFloor",Vector3.new(x,99.25,1400),Vector3.new(width,1.5,width))
 -- Real art and action parts share this name. Art must not shadow the enabled action.
 part(m,"CourtExit",Vector3.new(x,100,1400),Vector3.new(4,1,4))
 return m
end
local function marker(m:Model,prefix:string,name:string,position:Vector3):ProximityPrompt
 local p=part(m,name,position,Vector3.new(2,.15,2))
 local prompt=Instance.new("ProximityPrompt");prompt.Name=prefix.."_"..name;prompt.Enabled=true;prompt.Parent=p
 return prompt
end
local ashen=court("Ashen",1000,230);local tower=court("Tower",2000,330)
marker(ashen,"Ashen","CourtEntrance",Vector3.new(1000,2.15,1498))
marker(tower,"Tower","CourtEntrance",Vector3.new(1000,2.15,1498))
marker(ashen,"Ashen","CourtExit",Vector3.new(1000,100.15,1502))
marker(tower,"Tower","CourtExit",Vector3.new(2000,100.15,1553))
local charter=marker(ashen,"Ashen","request_ashen_charter_permit_ledger",Vector3.new(950,100.15,1460))
marker(ashen,"Ashen","choose_bridge_route_sheltered_route",Vector3.new(950,100.15,1400))
marker(ashen,"Ashen","choose_bridge_route_direct_route",Vector3.new(960,100.15,1400))
marker(tower,"Tower","collect_tower_chart_route_chart",Vector3.new(1920,100.15,1510))
marker(tower,"Tower","choose_tower_door_sun_door",Vector3.new(1920,100.15,1290))
marker(tower,"Tower","choose_tower_door_moon_door",Vector3.new(1930,100.15,1290))
local function context(position:Vector3):any
 local c=collect(root,7,position);c.playerId=7;return c
end
local function target(objective:string,position:Vector3,ready:boolean?):any
 return route({kind="Campaign",name="Synthetic chapter",objective=objective,ready=ready},{Journal={}},position.X,position.Z,context(position))
end
local surface=Vector3.new(1000,7,1490);local a=Vector3.new(1000,103,1400);local t=Vector3.new(2000,103,1400)
check("Owner collector and enabled prompt",function()
 local c=context(a);assert(c.ashen.ownerId==7 and c.tower.ownerId==7)
 assert(c.ashen.anchors.request_ashen_charter_permit_ledger)
end)
check("Duplicate art exit does not shadow the action part",function()
 local c=context(a);assert(c.ashen.anchors.CourtExit.z==1502 and c.tower.anchors.CourtExit.z==1553)
 local r=target("survive_bell_wave",a);assert(r and r.kind=="Portal" and r.z==1502)
end)
check("Disabled prompt omitted, then recovers",function()
 charter.Enabled=false;local absent=context(a).ashen.anchors.request_ashen_charter_permit_ledger
 charter.Enabled=true;assert(absent==nil);assert(context(a).ashen.anchors.request_ashen_charter_permit_ledger)
end)
check("Foreign owner omitted, then recovers",function()
 ashen:SetAttribute("CampaignOwner",8);local absent=context(a).ashen
 ashen:SetAttribute("CampaignOwner",7);assert(absent==nil);assert(context(a).ashen)
end)
check("Streamed court removal and recovery",function()
 tower.Parent=nil;local absent=context(t).tower;tower.Parent=root
 assert(absent==nil);assert(context(t).tower)
end)
check("Ashen surface enters owned court",function()
 local r=target("request_ashen_charter",surface);assert(r and r.kind=="Portal" and r.final==false and r.y<10)
end)
check("Ashen owner court objective",function()
 local r=target("request_ashen_charter",a);assert(r and r.kind=="Objective" and r.y>99)
end)
check("Tower surface entrance vs owner annex objective",function()
 local s=target("collect_tower_chart",surface);local r=target("collect_tower_chart",t)
 assert(s and s.kind=="Portal" and s.x==1000);assert(r and r.kind=="Objective" and r.x>1800)
end)
check("Both choice groups are areas, never endorsed choices",function()
 for _,pair in ipairs({{objective="choose_bridge_route",position=a},{objective="choose_tower_door",position=t}})do
  local r=target(pair.objective,pair.position);assert(r and r.kind=="ObjectiveArea" and r.final==false)
 end
end)
check("Claim-ready is instruction only",function()
 local r=target("collect_tower_chart",t,true);assert(r and r.kind=="Instruction" and r.x==nil)
end)
check("Unknown objective has no invented route",function()assert(target("not_a_canonical_objective",a)==nil)end)
check("Missing enabled objective has no final marker",function()
 charter.Enabled=false;local r=target("request_ashen_charter",a);charter.Enabled=true;assert(r==nil)
end)
gui:SetAttribute("Passed",passed);gui:SetAttribute("Failed",failed)
table.insert(lines,string.format("\nRESULT: %d passed / %d failed. Synthetic only; live session/streaming/device QA remains separate.",passed,failed))
label.Text=table.concat(lines,"\n")
print("CAMPAIGN_ROUTE_NATIVE_RESULT",passed,failed)
