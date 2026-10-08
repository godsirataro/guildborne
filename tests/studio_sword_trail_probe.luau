-- Read-only observer of actual moving fixture attachments and time window.
return function(data:any):any
local player=game.Players.LocalPlayer;local gui=player.PlayerGui:WaitForChild("SwordContactViewer")
local part=workspace.CivicContactArtReview:WaitForChild("sword")
local trail=part:WaitForChild("WatchbladeCutTrail");local hand=part:FindFirstChild("RightHand",true)
local bones={};for _,b in ipairs(data.bones)do table.insert(bones,part:FindFirstChild(b.name,true))end
local blade;local edgeParts={}
for _,p in ipairs(data.parts)do if p.name=="Sword_3_Blade"then blade=p end;if string.find(p.name,"_Blade",1,true)or string.find(p.name,"_Point",1,true)then table.insert(edgeParts,p)end end
local function vertex(index)
 local v=data.vertices[index];local bind=CFrame.new(table.unpack(data.bones[v[4]].bind));return bones[v[4]].TransformedWorldCFrame:PointToWorldSpace(bind:PointToObjectSpace(Vector3.new(v[1],v[2],v[3])))
end
local active=0;local inactive=0;local maximum=0
for sample=1,100 do
 task.wait(.035)
 local t=gui:GetAttribute("Elapsed");local enabled=gui:GetAttribute("Playing")and gui:GetAttribute("TrailEnabled")and t>=.2 and t<.45
 assert(trail.Enabled==enabled)
 if enabled then active+=1 else inactive+=1 end
 local grip=hand.TransformedWorldCFrame.Position;local center=Vector3.zero
 for i=blade.firstVertex,blade.firstVertex+blade.vertices-1 do center+=vertex(i)end
 center/=blade.vertices;local direction=(center-grip).Unit;local low=math.huge;local high=-math.huge
 for _,p in ipairs(edgeParts)do for i=p.firstVertex,p.firstVertex+p.vertices-1 do local along=(vertex(i)-grip):Dot(direction);low=math.min(low,along);high=math.max(high,along)end end
 local e=math.max((trail.Attachment0.WorldPosition-(grip+direction*(low+.04))).Magnitude,(trail.Attachment1.WorldPosition-(grip+direction*(high-.02))).Magnitude)
 maximum=math.max(maximum,e);assert(e<.002,tostring(e))
end
assert(active>0 and inactive>0)
return {status="PASS",samples=100,activeSamples=active,inactiveSamples=inactive,maxEndpointError=maximum,scope="Read-only observation of local weapon-review trail; no gameplay VFX acceptance"}
end
