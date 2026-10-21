-- Diagnostics only: vertex containment is not triangle collision.
local f=game.ReplicatedStorage.GoblinSwordReviewRunner
local s=require(f.ReviewTransport).Get()
local k=require(f.KitTransport).Get()
local meshes={}
for _,p in k.parts do
 local mesh=p.MeshContent.Object;local points={}
 for _,id in mesh:GetVertices() do table.insert(points,mesh:GetPosition(id)) end
 table.insert(meshes,{part=p,points=points,faces=#mesh:GetFaces()})
end
local body={}
for _,p in s.rig:GetDescendants() do if p:IsA('Part') and p.Shape==Enum.PartType.Block and p.Transparency==0 then table.insert(body,p) end end
local frames={{label="Idle"}}
for i=0,60 do table.insert(frames,{phase=i*2*math.pi/60,label="SyntheticGait"}) end
for i=0,40 do table.insert(frames,{age=i*.62/40,label="SyntheticWarriorSlash"}) end
table.insert(frames,{age=.24,label="ExactWarriorContactTime"})
table.insert(frames,{forwardDegrees=65,label='SyntheticForwardReach65'})
table.insert(frames,{forwardDegrees=100,label='SyntheticForwardReach100'})
local rows={}
for _,frame in frames do
 s:Pose(frame.age,frame.phase,'rx_neg90')
 if frame.forwardDegrees then
  local details={}
  for _,w in s.rig:GetDescendants() do if w:IsA('WeldConstraint') and w.Part0 and w.Part1 then table.insert(details,{a=w.Part0,b=w.Part1,cf=w.Part0.CFrame:ToObjectSpace(w.Part1.CFrame)}) end end
  for _,m in s.rig:GetDescendants() do if m:IsA('Motor6D') and m.Name:find('Shoulder') then m.Part1.CFrame=m.Part0.CFrame*m.C0*CFrame.Angles(math.rad(frame.forwardDegrees),0,0)*m.C1:Inverse() end end
  for _,w in details do w.b.CFrame=w.a.CFrame*w.cf end
 end
 local report=k:Pose()
 task.wait()
 local low=math.huge;local inside=0;local parts={}
 for _,entry in meshes do
  local localInside=0
  for _,v in entry.points do
   local world=entry.part.CFrame:PointToWorldSpace(v);low=math.min(low,world.Y)
   for _,p in body do
    local q=p.CFrame:PointToObjectSpace(world);local half=p.Size/2
    if math.abs(q.X)<half.X-.00001 and math.abs(q.Y)<half.Y-.00001 and math.abs(q.Z)<half.Z-.00001 then localInside+=1;break end
   end
  end
  inside+=localInside
  table.insert(parts,{name=entry.part.Name,vertices=#entry.points,faces=entry.faces,verticesInsideBody=localInside})
 end
 table.insert(rows,{label=frame.label,forwardDegrees=frame.forwardDegrees,age=frame.age,phase=frame.phase,minY=low,verticesInsideBody=inside,parts=parts,follow=report})
end
s:Pose(nil,nil,'rx_neg90');k:Pose()
local E=game:GetService('EncodingService');local H=game.HttpService;local raw=H:JSONEncode(rows)
return H:JSONEncode({scope="SYNTHETIC_EDIT_ARMOR_VERTEX_DIAGNOSTIC",kit=k.kit,frames=#frames,bodyBlocks=#body,bytes=#raw,zstdBase64=buffer.tostring(E:Base64Encode(E:CompressBuffer(buffer.fromstring(raw),Enum.CompressionAlgorithm.Zstd,3)))})