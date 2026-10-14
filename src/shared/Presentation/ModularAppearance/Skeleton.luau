--!strict
-- Offline articulation reference. These sizes are visual only and never replace combat proxies.
local V = Vector3.new
local Skeleton: any = {}
Skeleton.Names = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
Skeleton.Parts = {
	Head={V(1.08,1.05,.95),V(0,2.1,0)}, UpperTorso={V(1.75,1.12,.84),V(0,1.01,0)}, LowerTorso={V(1.46,.72,.79),V(0,.09,0)},
	LeftUpperArm={V(.58,.88,.61),V(-1.18,1.14,0)}, LeftLowerArm={V(.49,.78,.53),V(-1.18,.31,0)}, LeftHand={V(.48,.48,.49),V(-1.18,-.32,0)},
	RightUpperArm={V(.58,.88,.61),V(1.18,1.14,0)}, RightLowerArm={V(.49,.78,.53),V(1.18,.31,0)}, RightHand={V(.48,.48,.49),V(1.18,-.32,0)},
	LeftUpperLeg={V(.67,.94,.74),V(-.43,-.73,0)}, LeftLowerLeg={V(.54,1,.6),V(-.43,-1.69,0)}, LeftFoot={V(.57,.38,.9),V(-.43,-2.38,-.13)},
	RightUpperLeg={V(.67,.94,.74),V(.43,-.73,0)}, RightLowerLeg={V(.54,1,.6),V(.43,-1.69,0)}, RightFoot={V(.57,.38,.9),V(.43,-2.38,-.13)},
}
Skeleton.Joints = {
	{name="Root",a="HumanoidRootPart",b="LowerTorso",pivot=V(0,.09,0)}, {name="Waist",a="LowerTorso",b="UpperTorso",pivot=V(0,.45,0)}, {name="Neck",a="UpperTorso",b="Head",pivot=V(0,1.57,0)},
	{name="LeftShoulder",a="UpperTorso",b="LeftUpperArm",pivot=V(-1.18,1.58,0)}, {name="LeftElbow",a="LeftUpperArm",b="LeftLowerArm",pivot=V(-1.18,.7,0)}, {name="LeftWrist",a="LeftLowerArm",b="LeftHand",pivot=V(-1.18,-.08,0)},
	{name="RightShoulder",a="UpperTorso",b="RightUpperArm",pivot=V(1.18,1.58,0)}, {name="RightElbow",a="RightUpperArm",b="RightLowerArm",pivot=V(1.18,.7,0)}, {name="RightWrist",a="RightLowerArm",b="RightHand",pivot=V(1.18,-.08,0)},
	{name="LeftHip",a="LowerTorso",b="LeftUpperLeg",pivot=V(-.43,-.26,0)}, {name="LeftKnee",a="LeftUpperLeg",b="LeftLowerLeg",pivot=V(-.43,-1.2,0)}, {name="LeftAnkle",a="LeftLowerLeg",b="LeftFoot",pivot=V(-.43,-2.19,0)},
	{name="RightHip",a="LowerTorso",b="RightUpperLeg",pivot=V(.43,-.26,0)}, {name="RightKnee",a="RightUpperLeg",b="RightLowerLeg",pivot=V(.43,-1.2,0)}, {name="RightAnkle",a="RightLowerLeg",b="RightFoot",pivot=V(.43,-2.19,0)},
}
Skeleton.Attachments = {Head={"HairAttachment","HatAttachment","FaceFrontAttachment"},UpperTorso={"BodyFrontAttachment","BodyBackAttachment","NeckAttachment"},LowerTorso={"WaistCenterAttachment"},LeftHand={"LeftGripAttachment"},RightHand={"RightGripAttachment"},LeftFoot={"LeftFootAttachment"},RightFoot={"RightFootAttachment"}}
return Skeleton
