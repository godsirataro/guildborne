-- Deterministic review equivalents for authored cosmetic effects. No gameplay remotes.
return function(review)
 assert(not review.effects,"Effects already attached")
 local folder=Instance.new("Folder");folder.Name="ContactEffects";folder.Parent=review.folder
 local effects={};review.effects=effects
 local function ball(name,color,size)
  local p=Instance.new("Part");p.Name=name;p.Shape=Enum.PartType.Ball;p.Size=size;p.Color=color;p.Material=Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Transparency=1;p.Parent=folder;return p
 end
 for _,a in ipairs(review.actors)do
  local e={actor=a,parts={}};effects[a.id]=e
  if a.id=="borin"then for i=1,9 do table.insert(e.parts,ball("ForgeSpark",Color3.fromRGB(255,166,55),Vector3.one*.05))end
  elseif a.id=="vaela"then
   for i=1,8 do table.insert(e.parts,ball("WaterDrop",Color3.fromRGB(90,183,215),Vector3.new(.044,.09,.044)))end
   for i,b in ipairs(a.data.bones)do if b.name=="RightHand"then e.handIndex=i;break end end
  elseif a.id=="roka"then for i=1,5 do table.insert(e.parts,ball("FoodSteam",Color3.fromRGB(209,218,203),Vector3.new(.20,.30,.20)))end
  elseif a.id=="elian"then
   local p=ball("CharterSeal",Color3.fromRGB(186,142,59),Vector3.new(.004,.30,.30));p.Shape=Enum.PartType.Cylinder;p.Material=Enum.Material.SmoothPlastic;e.parts={p}
  elseif a.id=="nyra"then
   local p=ball("PrismGlowAnchor",Color3.fromRGB(85,180,220),Vector3.one*.05);p.Transparency=1
   local light=Instance.new("PointLight");light.Color=p.Color;light.Range=2;light.Brightness=.35;light.Shadows=false;light.Parent=p;e.parts={p};e.light=light
  end
 end
 local original=review.Frame
 function review:Frame(seconds)
  original(self,seconds)
  local t=seconds%6;local frame=math.floor(t*30)
  for id,e in pairs(effects)do
   local origin=e.actor.part.CFrame
   if id=="borin"then
    local f=(t%2-1)*30;local visible=f>=0 and f<=10
    local travel=if f<=5 then f/5 else 1+.6*(f-5)/5
    local scale=if f<=5 then 1 else math.max(0,1-(f-5)/5)
    for i,p in ipairs(e.parts)do
     local n=i-1;local angle=n*math.pi*2/9
     p.CFrame=origin*CFrame.new(Vector3.new(.35,2.70,1.45)+Vector3.new(math.cos(angle)*.7,.35+n%3*.15,-math.sin(angle)*.7)*travel)
     p.Size=Vector3.one*math.max(.001,.05*scale);p.Transparency=if visible then 0 else 1
    end
   elseif id=="vaela"then
    local a=e.actor;local bind=CFrame.new(table.unpack(a.data.bones[e.handIndex].bind))
    local mouth=a.bones[e.handIndex].TransformedWorldCFrame:PointToWorldSpace(bind:PointToObjectSpace(Vector3.new(.15,4.25,1.45)))
    local soil=origin:PointToWorldSpace(Vector3.new(.15,3.30,1.45))
    for i,p in ipairs(e.parts)do p.Position=mouth:Lerp(soil,(i-1)/7);p.Transparency=if frame>=60 and frame<=120 then .12 else 1 end
   elseif id=="roka"then
    for i,p in ipairs(e.parts)do
     local n=i-1;local phase=(t/6+n/5)%1;local scale=math.sin(math.pi*phase)
     p.Position=origin:PointToWorldSpace(Vector3.new(-.35+.16*math.sin(phase*math.pi*2+n),2.83+.35+phase*.65,1.35-.13*math.cos(n)))
     p.Size=Vector3.new(.20,.30,.20)*math.max(.005,scale);p.Transparency=if scale>.001 then .82 else 1
    end
   elseif id=="elian"then
    local p=e.parts[1];p.CFrame=origin*CFrame.new(.22,3.226,1.10)*CFrame.Angles(0,0,math.pi/2)
    p.Transparency=if frame<90 then 1 elseif frame<=160 then 0 else (frame-160)/20
   elseif id=="nyra"then
    e.parts[1].Position=origin:PointToWorldSpace(Vector3.new(-.90,3.62,1.35));e.light.Brightness=.25+.10*math.sin(t/6*math.pi*2)^2
   end
  end
 end
 review:Frame(0)
 return effects
end
