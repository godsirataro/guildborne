--!strict
-- Explicit local art fixture: modifies only the isolated preview poses.
return function(review:any):any
 local actors={};local bones=0;local triangles=0
 for _,actor in ipairs(review.actors)do actors[actor.id]=actor;bones+=#actor.bones;triangles+=#actor.data.triangles end
 assert(bones==23 and triangles>2670 and triangles<5000)
 local body=assert(actors.bow)
 local function vertex(actor:any,index:number):Vector3
  local v=actor.data.vertices[index];local bind=CFrame.new(table.unpack(actor.data.bones[v[4]].bind))
  return actor.bones[v[4]].TransformedWorldCFrame:PointToWorldSpace(bind:PointToObjectSpace(Vector3.new(v[1],v[2],v[3])))
 end
 local function center(name:string):Vector3
  for _,part in ipairs(body.data.parts)do if part.name==name then
   local low=Vector3.new(math.huge,math.huge,math.huge);local high=-low
   for i=part.firstVertex,part.firstVertex+part.vertices-1 do local v=vertex(body,i);low=low:Min(v);high=high:Max(v)end
   return (low+high)/2
  end end
  error("Missing mesh "..name)
 end
 local function joint(name:string):Bone
  for _,b in ipairs(body.bones)do if b.Name==name then return b end end
  error("Missing bone "..name)
 end
 review:Frame(0)
 local fixed={};for _,name in ipairs({"Root","LeftHand","LeftFoot","RightFoot"})do fixed[name]=joint(name).TransformedWorldCFrame end
 local maximum=0;local samples=0
 for _,frame in ipairs({0,1,3,6,7,8,9,12,18,19,24,27,30,33,36,39,42,45,48,51,54,56,59,60,66,67,68,78,120,126,127,128,138,153,162,179})do
  review:Frame((frame+.001)/30);local t=(frame/30)%2
  local gripError=(center("Bow_5_Grip")-joint("LeftHand").TransformedWorldCFrame.Position).Magnitude
  assert(gripError<.002);maximum=math.max(maximum,gripError)
  for name,base in pairs(fixed)do assert((joint(name).TransformedWorldCFrame.Position-base.Position).Magnitude<.002)end
  if t<=.24 then
   local nock=joint("RightHand").TransformedWorldCFrame.Position
   for _,pair in ipairs({{"StringUpper","Bow_8_TipCap"},{"StringLower","Bow_6_TipCap"}})do
    local stringActor=actors[pair[1]];local tip=center(pair[2]);local delta=nock-tip;local direction=delta.Unit;local low=math.huge;local high=-math.huge
    for i=1,#stringActor.data.vertices do local along=(vertex(stringActor,i)-tip):Dot(direction);low=math.min(low,along);high=math.max(high,along)end
    local err=math.max(math.abs(low),math.abs(high-delta.Magnitude));assert(err<.002,tostring(frame).." string "..err);maximum=math.max(maximum,err)
   end
   local err=(actors.Arrow.bones[1].TransformedWorldCFrame.Position-nock).Magnitude;assert(err<.002);maximum=math.max(maximum,err)
  end
  if t>=1.1 then local err=(actors.Arrow.bones[1].TransformedWorldCFrame.Position-joint("RightHand").TransformedWorldCFrame.Position).Magnitude;assert(err<.002);maximum=math.max(maximum,err)end
  local visible=t<=.60 or t>=1.1;assert(actors.Arrow.part.Transparency==(if visible then 0 else 1))
  samples+=1
 end
 review:Frame(.2)
 return {status="PASS",poseSamples=samples,nativeBones=bones,triangles=triangles,maximumContactError=maximum,fixedRootGripFeet=true,arrowVisibility=true,profileWrites=0,scope="Isolated local EditableMesh contact fixture; no gameplay combat acceptance"}
end
