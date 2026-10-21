local h=require(game.ReplicatedStorage.GoblinSwordReviewRunner.ReviewTransport).Get()
local hand
for _,w in h.rig:GetDescendants() do if w:IsA('WeldConstraint') and w.Part0==h.rig['Right Arm'] and w.Part1.Name=='Hand' then hand=w.Part1 end end
local rows={}
for _,age in {0,.1,.155,.24,.26,.4,.62} do
 h:Pose(age,nil,'rx_neg90')
 for _,pitch in {-1.4,1.5} do
  local cf=hand.CFrame*CFrame.Angles(pitch,0,0)*CFrame.Angles(0,-math.pi/2,0)
  local tip=cf:PointToWorldSpace(Vector3.new(0,3.345,0))
  table.insert(rows,{scope="SYNTHETIC_DIRECTION_DIAGNOSTIC",age=age,pitch=pitch,hand={hand.Position.X,hand.Position.Y,hand.Position.Z},sourceAxisTip={tip.X,tip.Y,tip.Z},tipForwardOfRoot=-tip.Z,bladeForward=-cf.UpVector.Z})
 end
end
h:Pose(nil,nil,'rx_neg90')
return game.HttpService:JSONEncode(rows)