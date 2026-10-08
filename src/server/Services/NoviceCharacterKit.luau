--!strict
-- Generated visual templates; no recruitment grants or stat/rarity advantage.
local V=Vector3.new
type Piece={name:string,size:Vector3,pos:Vector3,rotation:Vector3,color:Color3,bone:string}
type Bone={name:string,pos:Vector3,parent:string?}
type Asset={id:string,class:string,designId:string,bones:{Bone},parts:{Piece}}
local assets:{Asset}={
{id="courier",class="Human",designId="npc.novice.courier",bones={
{name="Root",pos=V(0,0,0),parent=nil},
{name="LowerTorso",pos=V(0,2.15,0),parent="Root"},
{name="UpperTorso",pos=V(0,2.8,0),parent="LowerTorso"},
{name="Head",pos=V(0,3.75,0),parent="UpperTorso"},
{name="LeftUpperArm",pos=V(-1.05,3.65,0),parent="UpperTorso"},
{name="LeftLowerArm",pos=V(-1.15,2.85,0),parent="LeftUpperArm"},
{name="LeftHand",pos=V(-1.18,2.2,0),parent="LeftLowerArm"},
{name="LeftUpperLeg",pos=V(-0.48,2.15,0),parent="LowerTorso"},
{name="LeftLowerLeg",pos=V(-0.48,1.15,0),parent="LeftUpperLeg"},
{name="LeftFoot",pos=V(-0.48,0.35,0),parent="LeftLowerLeg"},
{name="RightUpperArm",pos=V(1.05,3.65,0),parent="UpperTorso"},
{name="RightLowerArm",pos=V(1.15,2.85,0),parent="RightUpperArm"},
{name="RightHand",pos=V(1.18,2.2,0),parent="RightLowerArm"},
{name="RightUpperLeg",pos=V(0.48,2.15,0),parent="LowerTorso"},
{name="RightLowerLeg",pos=V(0.48,1.15,0),parent="RightUpperLeg"},
{name="RightFoot",pos=V(0.48,0.35,0),parent="RightLowerLeg"},
},parts={
{name="Waist",size=V(1.45,0.6,0.78),pos=V(0,2.45,0),rotation=V(0,0,0),color=Color3.fromRGB(40,54,79),bone="LowerTorso"},
{name="Chest",size=V(1.7,0.85,0.95),pos=V(0,3.22,0),rotation=V(0,0,0),color=Color3.fromRGB(40,54,79),bone="UpperTorso"},
{name="Belt",size=V(1.58,0.2,0.86),pos=V(0,2.35,0),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LowerTorso"},
{name="Head",size=V(1.32,1.1,1.12),pos=V(0,4.35,0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="Head"},
{name="LeftEye",size=V(0.13,0.14,0.05),pos=V(-0.3,4.42,-0.576),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="LeftUpperArm",size=V(0.56,0.72,0.64),pos=V(-1.16,3.25,0),rotation=V(0,0,0),color=Color3.fromRGB(40,54,79),bone="LeftUpperArm"},
{name="LeftLowerArm",size=V(0.51,0.56,0.59),pos=V(-1.16,2.54,0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="LeftLowerArm"},
{name="LeftHand",size=V(0.49,0.35,0.56),pos=V(-1.16,2.02,0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="LeftHand"},
{name="LeftUpperLeg",size=V(0.61,0.86,0.68),pos=V(-0.48,1.68,0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="LeftUpperLeg"},
{name="LeftLowerLeg",size=V(0.59,0.7,0.66),pos=V(-0.48,0.75,0),rotation=V(0,0,0),color=Color3.fromRGB(40,54,79),bone="LeftLowerLeg"},
{name="LeftBoot",size=V(0.72,0.42,1),pos=V(-0.48,0.23,-0.18),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LeftFoot"},
{name="RightEye",size=V(0.13,0.14,0.05),pos=V(0.3,4.42,-0.576),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="RightUpperArm",size=V(0.56,0.72,0.64),pos=V(1.16,3.25,0),rotation=V(0,0,0),color=Color3.fromRGB(40,54,79),bone="RightUpperArm"},
{name="RightLowerArm",size=V(0.51,0.56,0.59),pos=V(1.16,2.54,0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="RightLowerArm"},
{name="RightHand",size=V(0.49,0.35,0.56),pos=V(1.16,2.02,0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="RightHand"},
{name="RightUpperLeg",size=V(0.61,0.86,0.68),pos=V(0.48,1.68,0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="RightUpperLeg"},
{name="RightLowerLeg",size=V(0.59,0.7,0.66),pos=V(0.48,0.75,0),rotation=V(0,0,0),color=Color3.fromRGB(40,54,79),bone="RightLowerLeg"},
{name="RightBoot",size=V(0.72,0.42,1),pos=V(0.48,0.23,-0.18),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="RightFoot"},
{name="HairCap",size=V(1.4,0.3,1.2),pos=V(0,4.99,0.02),rotation=V(0,0,0),color=Color3.fromRGB(71,50,43),bone="Head"},
{name="LeftBrow",size=V(0.25,0.065,0.065),pos=V(-0.3,4.59,-0.62),rotation=V(0,0,-4),color=Color3.fromRGB(71,50,43),bone="Head"},
{name="LeftEar",size=V(0.16,0.24,0.25),pos=V(-0.73,4.4,0.0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="Head"},
{name="RightBrow",size=V(0.25,0.065,0.065),pos=V(0.3,4.59,-0.62),rotation=V(0,0,4),color=Color3.fromRGB(71,50,43),bone="Head"},
{name="RightEar",size=V(0.16,0.24,0.25),pos=V(0.73,4.4,0.0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="Head"},
{name="Mouth",size=V(0.25,0.045,0.06),pos=V(0,4.07,-0.61),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="Scarf",size=V(1.48,0.24,1.25),pos=V(0,3.87,0),rotation=V(0,0,0),color=Color3.fromRGB(57,110,116),bone="UpperTorso"},
{name="ScarfTail",size=V(0.38,0.8,0.17),pos=V(0.45,3.4,-0.63),rotation=V(0,0,-12),color=Color3.fromRGB(57,110,116),bone="UpperTorso"},
{name="SatchelStrap",size=V(0.22,1.7,0.15),pos=V(0,3.04,-0.62),rotation=V(0,0,-35),color=Color3.fromRGB(104,72,48),bone="UpperTorso"},
{name="Satchel",size=V(0.8,0.85,0.4),pos=V(0.86,2.18,-0.18),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LowerTorso"},
{name="SatchelFlap",size=V(0.86,0.23,0.1),pos=V(0.86,2.5,-0.44),rotation=V(0,0,0),color=Color3.fromRGB(209,169,79),bone="LowerTorso"},
{name="Envelope",size=V(0.83,0.5,0.1),pos=V(1.18,2.01,-0.38),rotation=V(0,0,0),color=Color3.fromRGB(223,215,188),bone="RightHand"},
{name="Seal",size=V(0.15,0.15,0.05),pos=V(1.18,2.01,-0.46),rotation=V(0,0,45),color=Color3.fromRGB(209,169,79),bone="RightHand"},
}},
{id="dwarf_traveler",class="Dwarf",designId="npc.novice.dwarf_traveler",bones={
{name="Root",pos=V(0.0,0.0,0.0),parent=nil},
{name="LowerTorso",pos=V(0.0,1.677,0.0),parent="Root"},
{name="UpperTorso",pos=V(0.0,2.184,0.0),parent="LowerTorso"},
{name="Head",pos=V(0.0,2.925,0.0),parent="UpperTorso"},
{name="LeftUpperArm",pos=V(-1.239,2.847,0.0),parent="UpperTorso"},
{name="LeftLowerArm",pos=V(-1.357,2.223,0.0),parent="LeftUpperArm"},
{name="LeftHand",pos=V(-1.3924,1.716,0.0),parent="LeftLowerArm"},
{name="LeftUpperLeg",pos=V(-0.5664,1.677,0.0),parent="LowerTorso"},
{name="LeftLowerLeg",pos=V(-0.5664,0.897,0.0),parent="LeftUpperLeg"},
{name="LeftFoot",pos=V(-0.5664,0.273,0.0),parent="LeftLowerLeg"},
{name="RightUpperArm",pos=V(1.239,2.847,0.0),parent="UpperTorso"},
{name="RightLowerArm",pos=V(1.357,2.223,0.0),parent="RightUpperArm"},
{name="RightHand",pos=V(1.3924,1.716,0.0),parent="RightLowerArm"},
{name="RightUpperLeg",pos=V(0.5664,1.677,0.0),parent="LowerTorso"},
{name="RightLowerLeg",pos=V(0.5664,0.897,0.0),parent="RightUpperLeg"},
{name="RightFoot",pos=V(0.5664,0.273,0.0),parent="RightLowerLeg"},
},parts={
{name="Waist",size=V(1.711,0.468,0.858),pos=V(0.0,1.911,0.0),rotation=V(0,0,0),color=Color3.fromRGB(152,67,65),bone="LowerTorso"},
{name="Chest",size=V(2.006,0.663,1.045),pos=V(0.0,2.5116,0.0),rotation=V(0,0,0),color=Color3.fromRGB(152,67,65),bone="UpperTorso"},
{name="Belt",size=V(1.8644,0.156,0.946),pos=V(0.0,1.833,0.0),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LowerTorso"},
{name="Head",size=V(1.5576,0.858,1.232),pos=V(0.0,3.393,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="LeftEye",size=V(0.1534,0.1092,0.055),pos=V(-0.354,3.4476,-0.6336),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="LeftUpperArm",size=V(0.6608,0.5616,0.704),pos=V(-1.3688,2.535,0.0),rotation=V(0,0,0),color=Color3.fromRGB(152,67,65),bone="LeftUpperArm"},
{name="LeftLowerArm",size=V(0.6018,0.4368,0.649),pos=V(-1.3688,1.9812,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="LeftLowerArm"},
{name="LeftHand",size=V(0.5782,0.273,0.616),pos=V(-1.3688,1.5756,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="LeftHand"},
{name="LeftUpperLeg",size=V(0.7198,0.6708,0.748),pos=V(-0.5664,1.3104,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="LeftUpperLeg"},
{name="LeftLowerLeg",size=V(0.6962,0.546,0.726),pos=V(-0.5664,0.585,0.0),rotation=V(0,0,0),color=Color3.fromRGB(152,67,65),bone="LeftLowerLeg"},
{name="LeftBoot",size=V(0.8496,0.3276,1.1),pos=V(-0.5664,0.1794,-0.198),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LeftFoot"},
{name="RightEye",size=V(0.1534,0.1092,0.055),pos=V(0.354,3.4476,-0.6336),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="RightUpperArm",size=V(0.6608,0.5616,0.704),pos=V(1.3688,2.535,0.0),rotation=V(0,0,0),color=Color3.fromRGB(152,67,65),bone="RightUpperArm"},
{name="RightLowerArm",size=V(0.6018,0.4368,0.649),pos=V(1.3688,1.9812,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="RightLowerArm"},
{name="RightHand",size=V(0.5782,0.273,0.616),pos=V(1.3688,1.5756,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="RightHand"},
{name="RightUpperLeg",size=V(0.7198,0.6708,0.748),pos=V(0.5664,1.3104,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="RightUpperLeg"},
{name="RightLowerLeg",size=V(0.6962,0.546,0.726),pos=V(0.5664,0.585,0.0),rotation=V(0,0,0),color=Color3.fromRGB(152,67,65),bone="RightLowerLeg"},
{name="RightBoot",size=V(0.8496,0.3276,1.1),pos=V(0.5664,0.1794,-0.198),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="RightFoot"},
{name="HairCap",size=V(1.652,0.234,1.32),pos=V(0.0,3.8922,0.022),rotation=V(0,0,0),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="LeftBrow",size=V(0.295,0.0507,0.0715),pos=V(-0.354,3.5802,-0.682),rotation=V(0,0,-4),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="LeftEar",size=V(0.1888,0.1872,0.275),pos=V(-0.8614,3.432,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="RightBrow",size=V(0.295,0.0507,0.0715),pos=V(0.354,3.5802,-0.682),rotation=V(0,0,4),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="RightEar",size=V(0.1888,0.1872,0.275),pos=V(0.8614,3.432,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="Mouth",size=V(0.295,0.0351,0.066),pos=V(0.0,3.1746,-0.671),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="Beard",size=V(1.298,0.546,0.33),pos=V(0.0,3.1044,-0.704),rotation=V(0,0,0),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="BeardTip",size=V(0.7434,0.3276,0.297),pos=V(0.0,2.7378,-0.704),rotation=V(0,0,0),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="Pack",size=V(1.534,1.092,0.605),pos=V(0.0,2.379,0.825),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="UpperTorso"},
{name="Bedroll",size=V(2.006,0.3588,0.605),pos=V(0.0,3.1122,0.836),rotation=V(0,0,0),color=Color3.fromRGB(223,215,188),bone="UpperTorso"},
{name="MapRoll",size=V(0.354,0.5616,0.33),pos=V(0.9204,1.794,-0.33),rotation=V(0,0,-20),color=Color3.fromRGB(223,215,188),bone="LowerTorso"},
}},
{id="elf_traveler",class="Elf",designId="npc.novice.elf_traveler",bones={
{name="Root",pos=V(0.0,0.0,0.0),parent=nil},
{name="LowerTorso",pos=V(0.0,2.322,0.0),parent="Root"},
{name="UpperTorso",pos=V(0.0,3.024,0.0),parent="LowerTorso"},
{name="Head",pos=V(0.0,4.05,0.0),parent="UpperTorso"},
{name="LeftUpperArm",pos=V(-0.987,3.942,0.0),parent="UpperTorso"},
{name="LeftLowerArm",pos=V(-1.081,3.078,0.0),parent="LeftUpperArm"},
{name="LeftHand",pos=V(-1.1092,2.376,0.0),parent="LeftLowerArm"},
{name="LeftUpperLeg",pos=V(-0.4512,2.322,0.0),parent="LowerTorso"},
{name="LeftLowerLeg",pos=V(-0.4512,1.242,0.0),parent="LeftUpperLeg"},
{name="LeftFoot",pos=V(-0.4512,0.378,0.0),parent="LeftLowerLeg"},
{name="RightUpperArm",pos=V(0.987,3.942,0.0),parent="UpperTorso"},
{name="RightLowerArm",pos=V(1.081,3.078,0.0),parent="RightUpperArm"},
{name="RightHand",pos=V(1.1092,2.376,0.0),parent="RightLowerArm"},
{name="RightUpperLeg",pos=V(0.4512,2.322,0.0),parent="LowerTorso"},
{name="RightLowerLeg",pos=V(0.4512,1.242,0.0),parent="RightUpperLeg"},
{name="RightFoot",pos=V(0.4512,0.378,0.0),parent="RightLowerLeg"},
},parts={
{name="Waist",size=V(1.363,0.648,0.741),pos=V(0.0,2.646,0.0),rotation=V(0,0,0),color=Color3.fromRGB(99,123,85),bone="LowerTorso"},
{name="Chest",size=V(1.598,0.918,0.9025),pos=V(0.0,3.4776,0.0),rotation=V(0,0,0),color=Color3.fromRGB(99,123,85),bone="UpperTorso"},
{name="Belt",size=V(1.4852,0.216,0.817),pos=V(0.0,2.538,0.0),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LowerTorso"},
{name="Head",size=V(1.2408,1.188,1.064),pos=V(0.0,4.698,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="LeftEye",size=V(0.1222,0.1512,0.0475),pos=V(-0.282,4.7736,-0.5472),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="LeftUpperArm",size=V(0.5264,0.7776,0.608),pos=V(-1.0904,3.51,0.0),rotation=V(0,0,0),color=Color3.fromRGB(99,123,85),bone="LeftUpperArm"},
{name="LeftLowerArm",size=V(0.4794,0.6048,0.5605),pos=V(-1.0904,2.7432,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="LeftLowerArm"},
{name="LeftHand",size=V(0.4606,0.378,0.532),pos=V(-1.0904,2.1816,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="LeftHand"},
{name="LeftUpperLeg",size=V(0.5734,0.9288,0.646),pos=V(-0.4512,1.8144,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="LeftUpperLeg"},
{name="LeftLowerLeg",size=V(0.5546,0.756,0.627),pos=V(-0.4512,0.81,0.0),rotation=V(0,0,0),color=Color3.fromRGB(99,123,85),bone="LeftLowerLeg"},
{name="LeftBoot",size=V(0.6768,0.4536,0.95),pos=V(-0.4512,0.2484,-0.171),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LeftFoot"},
{name="RightEye",size=V(0.1222,0.1512,0.0475),pos=V(0.282,4.7736,-0.5472),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="RightUpperArm",size=V(0.5264,0.7776,0.608),pos=V(1.0904,3.51,0.0),rotation=V(0,0,0),color=Color3.fromRGB(99,123,85),bone="RightUpperArm"},
{name="RightLowerArm",size=V(0.4794,0.6048,0.5605),pos=V(1.0904,2.7432,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="RightLowerArm"},
{name="RightHand",size=V(0.4606,0.378,0.532),pos=V(1.0904,2.1816,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="RightHand"},
{name="RightUpperLeg",size=V(0.5734,0.9288,0.646),pos=V(0.4512,1.8144,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="RightUpperLeg"},
{name="RightLowerLeg",size=V(0.5546,0.756,0.627),pos=V(0.4512,0.81,0.0),rotation=V(0,0,0),color=Color3.fromRGB(99,123,85),bone="RightLowerLeg"},
{name="RightBoot",size=V(0.6768,0.4536,0.95),pos=V(0.4512,0.2484,-0.171),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="RightFoot"},
{name="HairCap",size=V(1.316,0.324,1.14),pos=V(0.0,5.3892,0.019),rotation=V(0,0,0),color=Color3.fromRGB(191,172,126),bone="Head"},
{name="LeftBrow",size=V(0.235,0.0702,0.0617),pos=V(-0.282,4.9572,-0.589),rotation=V(0,0,-4),color=Color3.fromRGB(191,172,126),bone="Head"},
{name="LeftEar",size=V(0.3478,0.54,0.2375),pos=V(-0.7708,4.752,0.0),rotation=V(0,0,-25),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="RightBrow",size=V(0.235,0.0702,0.0617),pos=V(0.282,4.9572,-0.589),rotation=V(0,0,4),color=Color3.fromRGB(191,172,126),bone="Head"},
{name="RightEar",size=V(0.3478,0.54,0.2375),pos=V(0.7708,4.752,0.0),rotation=V(0,0,25),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="Mouth",size=V(0.235,0.0486,0.057),pos=V(0.0,4.3956,-0.5795),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="TiedHair",size=V(0.47,0.864,0.285),pos=V(0.0,4.7628,0.646),rotation=V(0,0,0),color=Color3.fromRGB(191,172,126),bone="Head"},
{name="Cloak",size=V(1.5228,2.052,0.171),pos=V(0.0,3.1104,0.646),rotation=V(0,0,0),color=Color3.fromRGB(99,123,85),bone="UpperTorso"},
{name="Clasp",size=V(0.282,0.324,0.114),pos=V(0.0,3.78,-0.5605),rotation=V(0,0,45),color=Color3.fromRGB(209,169,79),bone="UpperTorso"},
{name="Pack",size=V(0.987,1.134,0.475),pos=V(0.0,3.348,0.9215),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="UpperTorso"},
}},
{id="crossroads_keeper",class="Human",designId="npc.novice.crossroads_keeper",bones={
{name="Root",pos=V(0.0,0.0,0.0),parent=nil},
{name="LowerTorso",pos=V(0.0,2.3005,0.0),parent="Root"},
{name="UpperTorso",pos=V(0.0,2.996,0.0),parent="LowerTorso"},
{name="Head",pos=V(0.0,4.0125,0.0),parent="UpperTorso"},
{name="LeftUpperArm",pos=V(-1.134,3.9055,0.0),parent="UpperTorso"},
{name="LeftLowerArm",pos=V(-1.242,3.0495,0.0),parent="LeftUpperArm"},
{name="LeftHand",pos=V(-1.2744,2.354,0.0),parent="LeftLowerArm"},
{name="LeftUpperLeg",pos=V(-0.5184,2.3005,0.0),parent="LowerTorso"},
{name="LeftLowerLeg",pos=V(-0.5184,1.2305,0.0),parent="LeftUpperLeg"},
{name="LeftFoot",pos=V(-0.5184,0.3745,0.0),parent="LeftLowerLeg"},
{name="RightUpperArm",pos=V(1.134,3.9055,0.0),parent="UpperTorso"},
{name="RightLowerArm",pos=V(1.242,3.0495,0.0),parent="RightUpperArm"},
{name="RightHand",pos=V(1.2744,2.354,0.0),parent="RightLowerArm"},
{name="RightUpperLeg",pos=V(0.5184,2.3005,0.0),parent="LowerTorso"},
{name="RightLowerLeg",pos=V(0.5184,1.2305,0.0),parent="RightUpperLeg"},
{name="RightFoot",pos=V(0.5184,0.3745,0.0),parent="RightLowerLeg"},
},parts={
{name="Waist",size=V(1.566,0.642,0.8424),pos=V(0.0,2.6215,0.0),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="LowerTorso"},
{name="Chest",size=V(1.836,0.9095,1.026),pos=V(0.0,3.4454,0.0),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="UpperTorso"},
{name="Belt",size=V(1.7064,0.214,0.9288),pos=V(0.0,2.5145,0.0),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LowerTorso"},
{name="Head",size=V(1.4256,1.177,1.2096),pos=V(0.0,4.6545,0.0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="Head"},
{name="LeftEye",size=V(0.1404,0.1498,0.054),pos=V(-0.324,4.7294,-0.6221),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="LeftUpperArm",size=V(0.6048,0.7704,0.6912),pos=V(-1.2528,3.4775,0.0),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="LeftUpperArm"},
{name="LeftLowerArm",size=V(0.5508,0.5992,0.6372),pos=V(-1.2528,2.7178,0.0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="LeftLowerArm"},
{name="LeftHand",size=V(0.5292,0.3745,0.6048),pos=V(-1.2528,2.1614,0.0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="LeftHand"},
{name="LeftUpperLeg",size=V(0.6588,0.9202,0.7344),pos=V(-0.5184,1.7976,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="LeftUpperLeg"},
{name="LeftLowerLeg",size=V(0.6372,0.749,0.7128),pos=V(-0.5184,0.8025,0.0),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="LeftLowerLeg"},
{name="LeftBoot",size=V(0.7776,0.4494,1.08),pos=V(-0.5184,0.2461,-0.1944),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LeftFoot"},
{name="RightEye",size=V(0.1404,0.1498,0.054),pos=V(0.324,4.7294,-0.6221),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="RightUpperArm",size=V(0.6048,0.7704,0.6912),pos=V(1.2528,3.4775,0.0),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="RightUpperArm"},
{name="RightLowerArm",size=V(0.5508,0.5992,0.6372),pos=V(1.2528,2.7178,0.0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="RightLowerArm"},
{name="RightHand",size=V(0.5292,0.3745,0.6048),pos=V(1.2528,2.1614,0.0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="RightHand"},
{name="RightUpperLeg",size=V(0.6588,0.9202,0.7344),pos=V(0.5184,1.7976,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="RightUpperLeg"},
{name="RightLowerLeg",size=V(0.6372,0.749,0.7128),pos=V(0.5184,0.8025,0.0),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="RightLowerLeg"},
{name="RightBoot",size=V(0.7776,0.4494,1.08),pos=V(0.5184,0.2461,-0.1944),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="RightFoot"},
{name="HairCap",size=V(1.512,0.321,1.296),pos=V(0.0,5.3393,0.0216),rotation=V(0,0,0),color=Color3.fromRGB(71,50,43),bone="Head"},
{name="LeftBrow",size=V(0.27,0.0696,0.0702),pos=V(-0.324,4.9113,-0.6696),rotation=V(0,0,-4),color=Color3.fromRGB(71,50,43),bone="Head"},
{name="LeftEar",size=V(0.1728,0.2568,0.27),pos=V(-0.7884,4.708,0.0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="Head"},
{name="RightBrow",size=V(0.27,0.0696,0.0702),pos=V(0.324,4.9113,-0.6696),rotation=V(0,0,4),color=Color3.fromRGB(71,50,43),bone="Head"},
{name="RightEar",size=V(0.1728,0.2568,0.27),pos=V(0.7884,4.708,0.0),rotation=V(0,0,0),color=Color3.fromRGB(175,122,87),bone="Head"},
{name="Mouth",size=V(0.27,0.0481,0.0648),pos=V(0.0,4.3549,-0.6588),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="Tabard",size=V(1.3392,1.7655,0.1836),pos=V(0.0,3.0067,-0.6264),rotation=V(0,0,0),color=Color3.fromRGB(152,67,65),bone="UpperTorso"},
{name="FalseCrestLeft",size=V(0.2808,0.6099,0.0972),pos=V(-0.216,3.3812,-0.7668),rotation=V(0,0,25),color=Color3.fromRGB(209,169,79),bone="UpperTorso"},
{name="FalseCrestRight",size=V(0.2268,0.4708,0.0972),pos=V(0.2052,3.4561,-0.7668),rotation=V(0,0,-25),color=Color3.fromRGB(209,169,79),bone="UpperTorso"},
{name="Helmet",size=V(1.62,0.4815,1.4148),pos=V(0.0,5.3714,0.0),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="Head"},
{name="HelmBrow",size=V(1.6308,0.1605,0.1404),pos=V(0.0,5.0932,-0.7452),rotation=V(0,0,0),color=Color3.fromRGB(161,178,191),bone="Head"},
{name="Shoulder",size=V(0.9504,0.3852,1.0152),pos=V(-1.2312,3.8734,0.0),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="LeftUpperArm"},
{name="Shoulder",size=V(0.9504,0.3852,1.0152),pos=V(1.2312,3.8734,0.0),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="RightUpperArm"},
{name="Shield",size=V(1.35,1.712,0.2808),pos=V(-1.4796,2.3754,-0.54),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LeftHand"},
{name="ShieldRim",size=V(1.4472,0.1819,0.3348),pos=V(-1.4796,3.21,-0.54),rotation=V(0,0,0),color=Color3.fromRGB(83,103,130),bone="LeftHand"},
{name="Grip",size=V(0.162,0.535,0.162),pos=V(1.404,2.1186,-0.378),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="RightHand"},
{name="Guard",size=V(0.702,0.1605,0.216),pos=V(1.404,2.4182,-0.378),rotation=V(0,0,0),color=Color3.fromRGB(161,178,191),bone="RightHand"},
{name="Blade",size=V(0.27,1.605,0.1296),pos=V(1.404,3.2528,-0.378),rotation=V(0,0,0),color=Color3.fromRGB(161,178,191),bone="RightHand"},
}},
}
return function(rigged:boolean?,onlyId:string?): Folder
    local folder=Instance.new("Folder");folder.Name="NoviceCharacterKit"
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
