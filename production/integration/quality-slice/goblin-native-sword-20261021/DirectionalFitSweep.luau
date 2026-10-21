-- Measured item-specific candidates on an isolated manual Edit FK fixture.
local h=require(game.ReplicatedStorage.GoblinSwordReviewRunner.ReviewTransport).Get()
local mesh=h.part.MeshContent.Object
local points={}
for _,id in ipairs(mesh:GetVertices()) do table.insert(points,mesh:GetPosition(id)+h.center) end
local arm=h.rig['Right Arm'];local hand
for _,w in ipairs(h.rig:GetDescendants()) do
 if w:IsA('WeldConstraint') and w.Part0==arm and w.Part1.Name=='Hand' then hand=w.Part1 end
end
assert(hand,'HAND_REQUIRED')
local body={}
for _,p in ipairs(h.rig:GetDescendants()) do
 if p:IsA('Part') and p.Shape==Enum.PartType.Block and p.Transparency==0 then table.insert(body,p) end
end
local candidates={}
for _,x in ipairs({0.4,0.8,1.2}) do
 for _,y in ipairs({0.1,0.4}) do
  for _,z in ipairs({-0.4,-0.8}) do
   for _,roll in ipairs({0,math.pi/2}) do
    local up=Vector3.new(x,y,z).Unit;local right=up:Cross(Vector3.zAxis).Unit
    table.insert(candidates,{direction={up.X,up.Y,up.Z},roll=roll,scale=1,minY=math.huge,maxIntrudingUpperVertices=0,totalIntrudingUpperVertices=0,samples=0})
   end
  end
 end
end
local frames={}
table.insert(frames,{label='Idle'})
for i=0,60 do table.insert(frames,{phase=i*2*math.pi/60,label='SyntheticGait'}) end
for i=0,40 do table.insert(frames,{age=i*.62/40,label='SyntheticSlash'}) end
table.insert(frames,{age=.24,label="ExactContact"})
local rows={}
for frameIndex,frame in ipairs(frames) do
 h:Pose(frame.age,frame.phase,'rx_neg90')
 for index,c in ipairs(candidates) do
  local up=Vector3.new(table.unpack(c.direction));local right=up:Cross(Vector3.zAxis).Unit;local cf=hand.CFrame*CFrame.fromMatrix(Vector3.zero,right,up,right:Cross(up))*CFrame.Angles(0,c.roll,0)
  local low=math.huge;local intruding=0
  for _,p in ipairs(points) do
   local world=cf:PointToWorldSpace(p*c.scale)
   low=math.min(low,world.Y)
   -- This is an explicit vertex-containment diagnostic, not triangle collision.
   -- Source Y>.5 selects upper geometry beyond the candidate grip, not a semantic blade ID.
   if p.Y>.5 then
    for _,part in ipairs(body) do
     local q=part.CFrame:PointToObjectSpace(world);local half=part.Size*.5
     if math.abs(q.X)<half.X-.00001 and math.abs(q.Y)<half.Y-.00001 and math.abs(q.Z)<half.Z-.00001 then intruding+=1;break end
    end
   end
  end
  if frame.label=="ExactContact" then local tip=cf:PointToWorldSpace(Vector3.new(0,3.345,0));c.contactTip={tip.X,tip.Y,tip.Z};c.contactBladeForward=-cf.UpVector.Z end
  c.samples+=1;c.minY=math.min(c.minY,low)
  c.maxIntrudingUpperVertices=math.max(c.maxIntrudingUpperVertices,intruding)
  c.totalIntrudingUpperVertices+=intruding
  table.insert(rows,{candidate=index,frame=frameIndex,age=frame.age,phase=frame.phase,label=frame.label,minY=low,upperVerticesInsideOpaqueBodyBlocks=intruding})
 end
 task.wait()
end
h:Pose(nil,nil,'rx_neg90')
local H=game:GetService('HttpService');local E=game:GetService('EncodingService')
local raw=H:JSONEncode(rows)
return H:JSONEncode({scope='SYNTHETIC_EDIT_CANDIDATE_ONLY',frames=#frames,candidates=candidates,rows=#rows,bodyBlocks=#body,rawBytes=#raw,zstdBase64=buffer.tostring(E:Base64Encode(E:CompressBuffer(buffer.fromstring(raw),Enum.CompressionAlgorithm.Zstd,3)))})
