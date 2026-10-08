-- Native untextured trail bound to the actual reviewed blade; local cosmetic only.
return function(actor)
 local data=actor.data;local hand;local bind
 for i,b in ipairs(data.bones)do if b.name=="RightHand"then hand=actor.bones[i];bind=CFrame.new(table.unpack(b.bind));break end end
 assert(hand and bind)
 local points={};local center=Vector3.zero;local count=0
 for _,part in ipairs(data.parts)do
  if part.name=="Sword_3_Blade"then
   for i=part.firstVertex,part.firstVertex+part.vertices-1 do local v=data.vertices[i];center+=Vector3.new(v[1],v[2],v[3]);count+=1 end
  end
  if string.find(part.name,"_Blade",1,true)or string.find(part.name,"_Point",1,true)then
   for i=part.firstVertex,part.firstVertex+part.vertices-1 do local v=data.vertices[i];table.insert(points,Vector3.new(v[1],v[2],v[3]))end
  end
 end
 local direction=(center/count-bind.Position).Unit;local low=math.huge;local high=-math.huge
 for _,point in ipairs(points)do local distance=(point-bind.Position):Dot(direction);low=math.min(low,distance);high=math.max(high,distance)end
 local locals={bind:PointToObjectSpace(bind.Position+direction*(low+.04)),bind:PointToObjectSpace(bind.Position+direction*(high-.02))}
 local attachments={}
 for i,name in ipairs({"BladeTrailBase","BladeTrailTip"})do local a=Instance.new("Attachment");a.Name=name;a.Parent=actor.part;attachments[i]=a end
 local trail=Instance.new("Trail");trail.Name="WatchbladeCutTrail";trail.Attachment0=attachments[1];trail.Attachment1=attachments[2];trail.Lifetime=.12;trail.MinLength=.03;trail.FaceCamera=true;trail.LightEmission=.55
 trail.Color=ColorSequence.new(Color3.fromRGB(250,233,179),Color3.fromRGB(177,206,222));trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.32),NumberSequenceKeypoint.new(1,1)});trail.Enabled=false;trail.Parent=actor.part
 local api={trail=trail,attachments=attachments,hand=hand,localPoints=locals}
 function api:Update(seconds,playing,enabled)
  local world=hand.TransformedWorldCFrame
  for i,a in ipairs(attachments)do a.Position=actor.part.CFrame:PointToObjectSpace(world:PointToWorldSpace(locals[i]))end
  local t=seconds%2;local active=playing and enabled and t>=.2 and t<.45
  if trail.Enabled and not active then trail:Clear()end
  trail.Enabled=active
 end
 api:Update(0,false,true);return api
end
