-- Reads actual EditableMesh positions and native Bone transformed matrices.
local r=require(game.ServerStorage.CivicContactNativeReview)
local function cf(v)return CFrame.new(table.unpack(v))end
local function bounds(a,name)
 local found
 for _,p in ipairs(a.data.parts)do if p.name==name then found=p;break end end
 assert(found,"Missing mesh component "..name)
 local low=Vector3.new(math.huge,math.huge,math.huge);local high=-low
 for i=found.firstVertex,found.firstVertex+found.vertices-1 do
  local v=a.data.vertices[i];local point=a.mesh:GetPosition(a.vertexIds[i])
  local p=a.bones[v[4]].TransformedWorldCFrame:PointToWorldSpace(cf(a.data.bones[v[4]].bind):PointToObjectSpace(point))
  low=low:Min(p);high=high:Max(p)
 end
 return low,high,(low+high)*.5
end
local report={status="PASS",actors={},method="EditableMesh rest positions plus native Bone.TransformedWorldCFrame skinning; visual Studio captures separate. Cosmetic particle motion excluded."}
for _,a in ipairs(r.actors)do
 a.vertexIds=a.mesh:GetVertices();assert(#a.vertexIds==#a.data.vertices)
 for i,id in ipairs(a.vertexIds)do local v=a.data.vertices[i];assert((a.mesh:GetPosition(id)-Vector3.new(v[1],v[2],v[3])).Magnitude<.00001)end
 assert(#a.mesh:GetBones()==16 and #a.bones==16)
 local samples={}
 local frames=if a.id=="borin"then{30,90,150}elseif a.id=="elian"then{90}elseif a.id=="sela"then{0,22,44,52,60,82,104,112,120,142,164,172}else{0,15,30,45,60,75,90,105,120,135,150,165}
 for _,frame in ipairs(frames)do
  r:Frame(frame/30)
  local errorValue=0
  if a.id=="borin"or a.id=="elian"then
   local tool=if a.id=="borin"then"Hammer_Head"else"StampFoot"
   local surface=if a.id=="borin"then"HotWorkpiece"else"Document"
   local low=bounds(a,tool);local _,high=bounds(a,surface);errorValue=math.abs(low.Y-high.Y);assert(errorValue<.002,a.id.." contact")
  elseif a.id=="roka"then
   local _,_,tip=bounds(a,"LadleCup");local _,top,food=bounds(a,"Stew")
   local radius=Vector2.new(tip.X-food.X,tip.Z-food.Z).Magnitude;errorValue=math.abs(radius-.25);assert(errorValue<.002 and radius+.16<.58 and math.abs(tip.Y-top.Y-.03)<.002)
  elseif a.id=="vaela"then
   local _,_,mouth=bounds(a,"SpoutRose");local _,soil=bounds(a,"Soil");assert(mouth.Y>soil.Y+.2)
  else
   local _,_,tip=bounds(a,"ToolTip");local low,high=bounds(a,"Document");local clearance=tip.Y-high.Y
   assert(tip.X>low.X and tip.X<high.X and tip.Z>low.Z and tip.Z<high.Z)
   if a.id=="nyra"or frame%60<=44 then errorValue=math.abs(clearance);assert(errorValue<.002)else assert(clearance>.08)end
  end
  table.insert(samples,{frame=frame,error=errorValue})
 end
 table.insert(report.actors,{id=a.id,vertices=#a.vertexIds,triangles=#a.data.triangles,bones=16,samples=samples})
end
r:Frame(3)
return game.HttpService:JSONEncode(report)
