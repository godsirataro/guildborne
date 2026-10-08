--!strict
-- Generated visual templates; no recruitment grants or stat/rarity advantage.
local V=Vector3.new
type Piece={name:string,size:Vector3,pos:Vector3,rotation:Vector3,color:Color3,bone:string}
type Bone={name:string,pos:Vector3,parent:string?}
type Asset={id:string,class:string,designId:string,bones:{Bone},parts:{Piece}}
local assets:{Asset}={
{id="last_warden",class="ArchiveHeart",designId="boss.archive_heart.last_warden",bones={
{name="Root",pos=V(0.0,0.0,0.0),parent=nil},
{name="LowerTorso",pos=V(0.0,3.87,0.0),parent="Root"},
{name="UpperTorso",pos=V(0.0,5.04,0.0),parent="LowerTorso"},
{name="Head",pos=V(0.0,6.75,0.0),parent="UpperTorso"},
{name="LeftUpperArm",pos=V(-1.89,6.57,0.0),parent="UpperTorso"},
{name="LeftLowerArm",pos=V(-2.07,5.13,0.0),parent="LeftUpperArm"},
{name="LeftHand",pos=V(-2.124,3.96,0.0),parent="LeftLowerArm"},
{name="LeftUpperLeg",pos=V(-0.864,3.87,0.0),parent="LowerTorso"},
{name="LeftLowerLeg",pos=V(-0.864,2.07,0.0),parent="LeftUpperLeg"},
{name="LeftFoot",pos=V(-0.864,0.63,0.0),parent="LeftLowerLeg"},
{name="RightUpperArm",pos=V(1.89,6.57,0.0),parent="UpperTorso"},
{name="RightLowerArm",pos=V(2.07,5.13,0.0),parent="RightUpperArm"},
{name="RightHand",pos=V(2.124,3.96,0.0),parent="RightLowerArm"},
{name="RightUpperLeg",pos=V(0.864,3.87,0.0),parent="LowerTorso"},
{name="RightLowerLeg",pos=V(0.864,2.07,0.0),parent="RightUpperLeg"},
{name="RightFoot",pos=V(0.864,0.63,0.0),parent="RightLowerLeg"},
},parts={
{name="Waist",size=V(2.61,1.26,1.53),pos=V(0.0,4.14,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="LowerTorso"},
{name="Chest",size=V(3.33,2.25,1.98),pos=V(0.0,5.76,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="UpperTorso"},
{name="ChestInlay",size=V(1.17,1.89,0.27),pos=V(0.0,5.76,-1.17),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="UpperTorso"},
{name="NameChannel",size=V(0.306,1.62,0.18),pos=V(0.0,5.76,-1.368),rotation=V(0,0,0),color=Color3.fromRGB(69,201,187),bone="UpperTorso"},
{name="Belt",size=V(2.97,0.36,1.8),pos=V(0.0,4.41,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="LowerTorso"},
{name="Mask",size=V(1.98,2.34,1.62),pos=V(0.0,8.01,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="Head"},
{name="Visor",size=V(1.26,0.288,0.216),pos=V(0.0,8.28,-0.9),rotation=V(0,0,0),color=Color3.fromRGB(25,32,42),bone="Head"},
{name="VisorSpine",size=V(0.234,1.62,0.27),pos=V(0.0,8.01,-0.972),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="LeftShoulder",size=V(1.71,0.9,2.16),pos=V(-2.016,6.57,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="LeftUpperArm"},
{name="LeftUpperArm",size=V(1.17,1.476,1.26),pos=V(-2.016,5.76,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="LeftUpperArm"},
{name="LeftElbow",size=V(1.08,0.54,1.08),pos=V(-2.106,4.968,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="LeftLowerArm"},
{name="LeftForearm",size=V(1.17,1.17,1.35),pos=V(-2.124,4.356,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="LeftLowerArm"},
{name="LeftHand",size=V(1.008,0.684,1.116),pos=V(-2.124,3.546,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="LeftHand"},
{name="LeftThigh",size=V(1.206,1.53,1.476),pos=V(-0.864,3.06,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="LeftUpperLeg"},
{name="LeftKnee",size=V(1.332,0.63,1.62),pos=V(-0.864,2.07,-0.09),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="LeftLowerLeg"},
{name="LeftShin",size=V(1.08,1.332,1.35),pos=V(-0.864,1.26,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="LeftLowerLeg"},
{name="LeftFoot",size=V(1.368,0.63,2.07),pos=V(-0.864,0.36,-0.36),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="LeftFoot"},
{name="RightShoulder",size=V(1.71,0.9,2.16),pos=V(2.016,6.57,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="RightUpperArm"},
{name="RightUpperArm",size=V(1.17,1.476,1.26),pos=V(2.016,5.76,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="RightUpperArm"},
{name="RightElbow",size=V(1.08,0.54,1.08),pos=V(2.106,4.968,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="RightLowerArm"},
{name="RightForearm",size=V(1.17,1.17,1.35),pos=V(2.124,4.356,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="RightLowerArm"},
{name="RightHand",size=V(1.008,0.684,1.116),pos=V(2.124,3.546,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="RightHand"},
{name="RightThigh",size=V(1.206,1.53,1.476),pos=V(0.864,3.06,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="RightUpperLeg"},
{name="RightKnee",size=V(1.332,0.63,1.62),pos=V(0.864,2.07,-0.09),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="RightLowerLeg"},
{name="RightShin",size=V(1.08,1.332,1.35),pos=V(0.864,1.26,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="RightLowerLeg"},
{name="RightFoot",size=V(1.368,0.63,2.07),pos=V(0.864,0.36,-0.36),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="RightFoot"},
{name="HollowCrown",size=V(1.43277,0.216,0.234),pos=V(1.8,8.37,0.756),rotation=V(0,0,90.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.43277,0.216,0.234),pos=V(1.27279,9.64279,0.756),rotation=V(0,0,135.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.43277,0.216,0.234),pos=V(0.0,10.17,0.756),rotation=V(0,0,180.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.43277,0.216,0.234),pos=V(-1.27279,9.64279,0.756),rotation=V(0,0,225.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.43277,0.216,0.234),pos=V(-1.8,8.37,0.756),rotation=V(0,0,270.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.43277,0.216,0.234),pos=V(-1.27279,7.09721,0.756),rotation=V(0,0,315.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.43277,0.216,0.234),pos=V(-0.0,6.57,0.756),rotation=V(0,0,360.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.43277,0.216,0.234),pos=V(1.27279,7.09721,0.756),rotation=V(0,0,405.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="OathShield",size=V(2.43,3.42,0.45),pos=V(-2.484,4.14,-0.99),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="LeftHand"},
{name="ShieldSigil",size=V(1.17,1.17,0.252),pos=V(-2.484,4.32,-1.35),rotation=V(0,0,45),color=Color3.fromRGB(69,201,187),bone="LeftHand"},
{name="BindingSeal1",size=V(0.684,0.81,0.252),pos=V(-0.9,6.57,-1.188),rotation=V(0,0,45),color=Color3.fromRGB(137,111,186),bone="UpperTorso"},
{name="BindingSeal2",size=V(0.684,0.81,0.252),pos=V(0.0,6.57,-1.188),rotation=V(0,0,45),color=Color3.fromRGB(137,111,186),bone="UpperTorso"},
{name="BindingSeal3",size=V(0.684,0.81,0.252),pos=V(0.9,6.57,-1.188),rotation=V(0,0,45),color=Color3.fromRGB(137,111,186),bone="UpperTorso"},
}},
{id="keeper_of_names",class="ArchiveHeart",designId="boss.archive_heart.keeper_of_names",bones={
{name="Root",pos=V(0.0,0.0,0.0),parent=nil},
{name="LowerTorso",pos=V(0.0,5.16,0.0),parent="Root"},
{name="UpperTorso",pos=V(0.0,6.72,0.0),parent="LowerTorso"},
{name="Head",pos=V(0.0,9.0,0.0),parent="UpperTorso"},
{name="LeftUpperArm",pos=V(-2.52,8.76,0.0),parent="UpperTorso"},
{name="LeftLowerArm",pos=V(-2.76,6.84,0.0),parent="LeftUpperArm"},
{name="LeftHand",pos=V(-2.832,5.28,0.0),parent="LeftLowerArm"},
{name="LeftUpperLeg",pos=V(-1.152,5.16,0.0),parent="LowerTorso"},
{name="LeftLowerLeg",pos=V(-1.152,2.76,0.0),parent="LeftUpperLeg"},
{name="LeftFoot",pos=V(-1.152,0.84,0.0),parent="LeftLowerLeg"},
{name="RightUpperArm",pos=V(2.52,8.76,0.0),parent="UpperTorso"},
{name="RightLowerArm",pos=V(2.76,6.84,0.0),parent="RightUpperArm"},
{name="RightHand",pos=V(2.832,5.28,0.0),parent="RightLowerArm"},
{name="RightUpperLeg",pos=V(1.152,5.16,0.0),parent="LowerTorso"},
{name="RightLowerLeg",pos=V(1.152,2.76,0.0),parent="RightUpperLeg"},
{name="RightFoot",pos=V(1.152,0.84,0.0),parent="RightLowerLeg"},
},parts={
{name="Waist",size=V(3.48,1.68,2.04),pos=V(0.0,5.52,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="LowerTorso"},
{name="Chest",size=V(4.44,3.0,2.64),pos=V(0.0,7.68,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="UpperTorso"},
{name="ChestInlay",size=V(1.56,2.52,0.36),pos=V(0.0,7.68,-1.56),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="UpperTorso"},
{name="NameChannel",size=V(0.408,2.16,0.24),pos=V(0.0,7.68,-1.824),rotation=V(0,0,0),color=Color3.fromRGB(69,201,187),bone="UpperTorso"},
{name="Belt",size=V(3.96,0.48,2.4),pos=V(0.0,5.88,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="LowerTorso"},
{name="Mask",size=V(2.64,3.12,2.16),pos=V(0.0,10.68,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="Head"},
{name="Visor",size=V(1.68,0.384,0.288),pos=V(0.0,11.04,-1.2),rotation=V(0,0,0),color=Color3.fromRGB(25,32,42),bone="Head"},
{name="VisorSpine",size=V(0.312,2.16,0.36),pos=V(0.0,10.68,-1.296),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="LeftShoulder",size=V(2.28,1.2,2.88),pos=V(-2.688,8.76,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="LeftUpperArm"},
{name="LeftUpperArm",size=V(1.56,1.968,1.68),pos=V(-2.688,7.68,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="LeftUpperArm"},
{name="LeftElbow",size=V(1.44,0.72,1.44),pos=V(-2.808,6.624,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="LeftLowerArm"},
{name="LeftForearm",size=V(1.56,1.56,1.8),pos=V(-2.832,5.808,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="LeftLowerArm"},
{name="LeftHand",size=V(1.344,0.912,1.488),pos=V(-2.832,4.728,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="LeftHand"},
{name="LeftThigh",size=V(1.608,2.04,1.968),pos=V(-1.152,4.08,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="LeftUpperLeg"},
{name="LeftKnee",size=V(1.776,0.84,2.16),pos=V(-1.152,2.76,-0.12),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="LeftLowerLeg"},
{name="LeftShin",size=V(1.44,1.776,1.8),pos=V(-1.152,1.68,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="LeftLowerLeg"},
{name="LeftFoot",size=V(1.824,0.84,2.76),pos=V(-1.152,0.48,-0.48),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="LeftFoot"},
{name="RightShoulder",size=V(2.28,1.2,2.88),pos=V(2.688,8.76,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="RightUpperArm"},
{name="RightUpperArm",size=V(1.56,1.968,1.68),pos=V(2.688,7.68,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="RightUpperArm"},
{name="RightElbow",size=V(1.44,0.72,1.44),pos=V(2.808,6.624,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="RightLowerArm"},
{name="RightForearm",size=V(1.56,1.56,1.8),pos=V(2.832,5.808,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="RightLowerArm"},
{name="RightHand",size=V(1.344,0.912,1.488),pos=V(2.832,4.728,0.0),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="RightHand"},
{name="RightThigh",size=V(1.608,2.04,1.968),pos=V(1.152,4.08,0.0),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="RightUpperLeg"},
{name="RightKnee",size=V(1.776,0.84,2.16),pos=V(1.152,2.76,-0.12),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="RightLowerLeg"},
{name="RightShin",size=V(1.44,1.776,1.8),pos=V(1.152,1.68,0.0),rotation=V(0,0,0),color=Color3.fromRGB(36,49,70),bone="RightLowerLeg"},
{name="RightFoot",size=V(1.824,0.84,2.76),pos=V(1.152,0.48,-0.48),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="RightFoot"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(2.4,11.16,1.008),rotation=V(0,0,90.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(2.07846,12.36,1.008),rotation=V(0,0,120.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(1.2,13.23846,1.008),rotation=V(0,0,150.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(0.0,13.56,1.008),rotation=V(0,0,180.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(-1.2,13.23846,1.008),rotation=V(0,0,210.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(-2.07846,12.36,1.008),rotation=V(0,0,240.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(-2.4,11.16,1.008),rotation=V(0,0,270.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(-2.07846,9.96,1.008),rotation=V(0,0,300.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(-1.2,9.08154,1.008),rotation=V(0,0,330.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(-0.0,8.76,1.008),rotation=V(0,0,360.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(1.2,9.08154,1.008),rotation=V(0,0,390.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="HollowCrown",size=V(1.29202,0.288,0.312),pos=V(2.07846,9.96,1.008),rotation=V(0,0,420.0),color=Color3.fromRGB(184,139,69),bone="Head"},
{name="SealRing1",size=V(0.76414,0.288,0.312),pos=V(-3.96,10.2,-0.24),rotation=V(0,0,90.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing1",size=V(0.76414,0.288,0.312),pos=V(-4.24118,10.87882,-0.24),rotation=V(0,0,135.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing1",size=V(0.76414,0.288,0.312),pos=V(-4.92,11.16,-0.24),rotation=V(0,0,180.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing1",size=V(0.76414,0.288,0.312),pos=V(-5.59882,10.87882,-0.24),rotation=V(0,0,225.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing1",size=V(0.76414,0.288,0.312),pos=V(-5.88,10.2,-0.24),rotation=V(0,0,270.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing1",size=V(0.76414,0.288,0.312),pos=V(-5.59882,9.52118,-0.24),rotation=V(0,0,315.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing1",size=V(0.76414,0.288,0.312),pos=V(-4.92,9.24,-0.24),rotation=V(0,0,360.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing1",size=V(0.76414,0.288,0.312),pos=V(-4.24118,9.52118,-0.24),rotation=V(0,0,405.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealCore1",size=V(0.528,1.008,0.288),pos=V(-4.92,10.2,-0.24),rotation=V(0,0,45),color=Color3.fromRGB(69,201,187),bone="UpperTorso"},
{name="SealRing2",size=V(0.76414,0.288,0.312),pos=V(5.88,10.2,-0.24),rotation=V(0,0,90.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing2",size=V(0.76414,0.288,0.312),pos=V(5.59882,10.87882,-0.24),rotation=V(0,0,135.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing2",size=V(0.76414,0.288,0.312),pos=V(4.92,11.16,-0.24),rotation=V(0,0,180.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing2",size=V(0.76414,0.288,0.312),pos=V(4.24118,10.87882,-0.24),rotation=V(0,0,225.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing2",size=V(0.76414,0.288,0.312),pos=V(3.96,10.2,-0.24),rotation=V(0,0,270.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing2",size=V(0.76414,0.288,0.312),pos=V(4.24118,9.52118,-0.24),rotation=V(0,0,315.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing2",size=V(0.76414,0.288,0.312),pos=V(4.92,9.24,-0.24),rotation=V(0,0,360.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing2",size=V(0.76414,0.288,0.312),pos=V(5.59882,9.52118,-0.24),rotation=V(0,0,405.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealCore2",size=V(0.528,1.008,0.288),pos=V(4.92,10.2,-0.24),rotation=V(0,0,45),color=Color3.fromRGB(69,201,187),bone="UpperTorso"},
{name="SealRing3",size=V(0.76414,0.288,0.312),pos=V(0.96,14.76,-0.24),rotation=V(0,0,90.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing3",size=V(0.76414,0.288,0.312),pos=V(0.67882,15.43882,-0.24),rotation=V(0,0,135.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing3",size=V(0.76414,0.288,0.312),pos=V(0.0,15.72,-0.24),rotation=V(0,0,180.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing3",size=V(0.76414,0.288,0.312),pos=V(-0.67882,15.43882,-0.24),rotation=V(0,0,225.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing3",size=V(0.76414,0.288,0.312),pos=V(-0.96,14.76,-0.24),rotation=V(0,0,270.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing3",size=V(0.76414,0.288,0.312),pos=V(-0.67882,14.08118,-0.24),rotation=V(0,0,315.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing3",size=V(0.76414,0.288,0.312),pos=V(-0.0,13.8,-0.24),rotation=V(0,0,360.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealRing3",size=V(0.76414,0.288,0.312),pos=V(0.67882,14.08118,-0.24),rotation=V(0,0,405.0),color=Color3.fromRGB(184,139,69),bone="UpperTorso"},
{name="SealCore3",size=V(0.528,1.008,0.288),pos=V(0.0,14.76,-0.24),rotation=V(0,0,45),color=Color3.fromRGB(137,111,186),bone="UpperTorso"},
{name="LedgerPlate",size=V(3.24,0.48,2.28),pos=V(0.0,4.8,-2.4),rotation=V(0,0,0),color=Color3.fromRGB(184,139,69),bone="LowerTorso"},
{name="LedgerPages",size=V(2.832,0.24,1.92),pos=V(0.0,5.184,-2.4),rotation=V(0,0,0),color=Color3.fromRGB(223,215,192),bone="LowerTorso"},
}},
}
return function(rigged:boolean?,onlyId:string?): Folder
    local folder=Instance.new("Folder");folder.Name="ArchiveHeartBossKit"
    for _,asset in ipairs(assets) do
        if onlyId and asset.id~=onlyId then continue end
        local m=Instance.new("Model");m.Name=asset.id;m.WorldPivot=CFrame.identity
        m:SetAttribute("ClassId",asset.class);m:SetAttribute("DesignId",asset.designId);m:SetAttribute("RecruitmentBound",false)
        local bones:{[string]:BasePart}={}
        if rigged then
            local skeleton=Instance.new("Folder");skeleton.Name="Skeleton";skeleton.Parent=m
            for _,entry in ipairs(asset.bones) do
                local bone=Instance.new("Part");bone.Name=entry.name;bone.Size=V(.1,.1,.1);bone.CFrame=CFrame.new(entry.pos)
                bone.Transparency=1;bone.Anchored=entry.parent==nil;bone.Massless=true
                bone.CanCollide=false;bone.CanTouch=false;bone.CanQuery=false;bone.Parent=skeleton;bones[entry.name]=bone
                if entry.parent then
                    local parent=bones[entry.parent];assert(parent)
                    local motor=Instance.new("Motor6D");motor.Name=entry.name;motor.Part0=parent;motor.Part1=bone
                    motor.C0=parent.CFrame:ToObjectSpace(bone.CFrame);motor.C1=CFrame.identity;motor.Parent=parent
                else m.PrimaryPart=bone end
            end
        end
        for _,entry in ipairs(asset.parts) do
            local p=Instance.new("Part");p.Name=entry.name;p.Size=entry.size
            p.CFrame=CFrame.new(entry.pos)*CFrame.Angles(math.rad(entry.rotation.X),math.rad(entry.rotation.Y),math.rad(entry.rotation.Z))
            p.Color=entry.color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=not rigged;p.Massless=true
            p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p:SetAttribute("BindBone",entry.bone);p.Parent=m
            if rigged then
                local weld=Instance.new("WeldConstraint");weld.Part0=bones[entry.bone];weld.Part1=p;weld.Parent=p
            end
        end
        m.Parent=folder
    end
    return folder
end
