--!strict
-- Uses the same bounded, collision-free primitives as starter abilities.
local V=Vector3.new
return function(line:any,arc:any,missile:any,burst:any,later:any,reduced:any)
 return function(model:Model,identity:any,aim:CFrame,target:Vector3)
  local color=identity.Color;local pattern=identity.Pattern
  local origin=aim.Position;local floor=CFrame.new(target-V(0,2.4,0))
  local function segment(a:Vector3,b:Vector3) line(a,b,.16,color,.48) end
  local function diamond(cf:CFrame,r:number)
   local points={V(0,r,0),V(r,0,0),V(0,-r,0),V(-r,0,0)}
   for i,p in ipairs(points) do segment(cf:PointToWorldSpace(p),cf:PointToWorldSpace(points[i%4+1])) end
  end
  if pattern=="Whirl" then
   arc(aim*CFrame.Angles(.15,0,.3),3.8,color,0,math.pi*1.6,.35)
   later(model,.16,function() arc(aim*CFrame.Angles(-.15,0,-.3),4.5,color,math.pi,math.pi*1.6,.35) end)
  elseif pattern=="Thrust" or pattern=="Sight" then
   local focus=aim*CFrame.new(0,0,-2)
   diamond(focus,if pattern=="Sight" then 1.3 else .7)
   later(model,.12,function()
    missile(origin,target,color,.16)
    if pattern=="Thrust" then segment(origin+aim.RightVector*.45,target);segment(origin-aim.RightVector*.45,target)
    else diamond(CFrame.new(target)*aim.Rotation,1.5) end
   end)
  elseif pattern=="Bastion" or pattern=="Banner" then
   for i=-1,1 do
    local cf=aim*CFrame.new(i*1.6,0,-2.2)
    if pattern=="Bastion" then diamond(cf,1.6)
    else
     segment(cf:PointToWorldSpace(V(0,-2,0)),cf:PointToWorldSpace(V(0,2,0)))
     segment(cf:PointToWorldSpace(V(0,2,0)),cf:PointToWorldSpace(V(1,1.4,0)))
     segment(cf:PointToWorldSpace(V(1,1.4,0)),cf:PointToWorldSpace(V(0,.7,0)))
    end
   end
  elseif pattern=="Rain" then
   for i=1,(if reduced() then 3 else 5) do
    local a=i*2.399;local p=target+V(math.cos(a)*2,0,math.sin(a)*2)
    later(model,.04*i,function() missile(p+V(-2,7,1),p,color,.2) end)
   end
  elseif pattern=="Orbit" then
   arc(floor,3.3,color,0,math.pi*2,.55)
   later(model,.15,function() arc(CFrame.new(target)*CFrame.Angles(math.pi/2,0,.5),2.2,color,0,math.pi*2,.45) end)
  elseif pattern=="Rune" or pattern=="Eclipse" then
   local cf=aim*CFrame.new(0,0,-2)*CFrame.Angles(0,0,.6)
   diamond(cf,2);diamond(cf,1)
   later(model,.16,function()
    arc(CFrame.new(target)*CFrame.Angles(.4,0,.5),2.5,color,if pattern=="Eclipse" then .7 else 0,math.pi*1.5,.45)
    missile(target,origin,color,.28)
   end)
  elseif pattern=="Dawn" then
   for i=-1,1 do
    local at=target+aim.RightVector*(i*1.5)
    later(model,.08*(i+1),function() segment(at-V(0,2,0),at+V(0,3,0));segment(at-V(.65,0,0),at+V(.65,0,0)) end)
   end
   later(model,.2,function() missile(target,origin,color,.28) end)
  elseif pattern=="Sanctuary" or pattern=="Harmony" then
   arc(floor,3.5,color,0,math.pi*2,.65)
   for i=1,3 do
    local a=i*math.pi*2/3;local at=target+V(math.cos(a)*1.8,0,math.sin(a)*1.8)
    later(model,.06*i,function()
     if pattern=="Sanctuary" then segment(at-V(0,.8,0),at+V(0,1.2,0));segment(at-V(.6,0,0),at+V(.6,0,0))
     else diamond(CFrame.new(at)*aim.Rotation,.55);segment(at,at+V(0,1.6,0)) end
    end)
   end
  elseif pattern=="Fate" then
   local cf=CFrame.new(target)*aim.Rotation
   for _,side in ipairs({-1,1}) do
    local a=cf:PointToWorldSpace(V(-1.7,side*2,0));local b=cf:PointToWorldSpace(V(1.7,side*2,0))
    segment(a,b);segment(a,target);segment(b,target)
   end
  end
  if identity.Tier==3 then later(model,.24,function() arc(floor,4.4,color,0,math.pi*2,.4) end) end
  if identity.Effect~="Guard" and identity.Effect~="Heal" then later(model,.25,function() burst(target,color,false) end) end
 end
end
