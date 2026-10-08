--!strict
-- Generated visual templates; no recruitment grants or stat/rarity advantage.
local V=Vector3.new
type Piece={name:string,size:Vector3,pos:Vector3,rotation:Vector3,color:Color3,bone:string}
type Bone={name:string,pos:Vector3,parent:string?}
type Asset={id:string,class:string,designId:string,bones:{Bone},parts:{Piece}}
local assets:{Asset}={
{id="miner",class="Dwarf",designId="npc.ironveil.miner",bones={
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
{name="Waist",size=V(1.711,0.468,0.858),pos=V(0.0,1.911,0.0),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="LowerTorso"},
{name="Chest",size=V(2.006,0.663,1.045),pos=V(0.0,2.5116,0.0),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="UpperTorso"},
{name="Belt",size=V(1.8644,0.156,0.946),pos=V(0.0,1.833,0.0),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LowerTorso"},
{name="Head",size=V(1.5576,0.858,1.232),pos=V(0.0,3.393,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="LeftEye",size=V(0.1534,0.1092,0.055),pos=V(-0.354,3.4476,-0.6336),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="LeftUpperArm",size=V(0.6608,0.5616,0.704),pos=V(-1.3688,2.535,0.0),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="LeftUpperArm"},
{name="LeftLowerArm",size=V(0.6018,0.4368,0.649),pos=V(-1.3688,1.9812,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="LeftLowerArm"},
{name="LeftHand",size=V(0.5782,0.273,0.616),pos=V(-1.3688,1.5756,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="LeftHand"},
{name="LeftUpperLeg",size=V(0.7198,0.6708,0.748),pos=V(-0.5664,1.3104,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="LeftUpperLeg"},
{name="LeftLowerLeg",size=V(0.6962,0.546,0.726),pos=V(-0.5664,0.585,0.0),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="LeftLowerLeg"},
{name="LeftBoot",size=V(0.8496,0.3276,1.1),pos=V(-0.5664,0.1794,-0.198),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LeftFoot"},
{name="RightEye",size=V(0.1534,0.1092,0.055),pos=V(0.354,3.4476,-0.6336),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="RightUpperArm",size=V(0.6608,0.5616,0.704),pos=V(1.3688,2.535,0.0),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="RightUpperArm"},
{name="RightLowerArm",size=V(0.6018,0.4368,0.649),pos=V(1.3688,1.9812,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="RightLowerArm"},
{name="RightHand",size=V(0.5782,0.273,0.616),pos=V(1.3688,1.5756,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="RightHand"},
{name="RightUpperLeg",size=V(0.7198,0.6708,0.748),pos=V(0.5664,1.3104,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="RightUpperLeg"},
{name="RightLowerLeg",size=V(0.6962,0.546,0.726),pos=V(0.5664,0.585,0.0),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="RightLowerLeg"},
{name="RightBoot",size=V(0.8496,0.3276,1.1),pos=V(0.5664,0.1794,-0.198),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="RightFoot"},
{name="HairCap",size=V(1.652,0.234,1.32),pos=V(0.0,3.8922,0.022),rotation=V(0,0,0),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="LeftBrow",size=V(0.295,0.0507,0.0715),pos=V(-0.354,3.5802,-0.682),rotation=V(0,0,-4),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="LeftEar",size=V(0.1888,0.1872,0.275),pos=V(-0.8614,3.432,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="RightBrow",size=V(0.295,0.0507,0.0715),pos=V(0.354,3.5802,-0.682),rotation=V(0,0,4),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="RightEar",size=V(0.1888,0.1872,0.275),pos=V(0.8614,3.432,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="Mouth",size=V(0.295,0.0351,0.066),pos=V(0.0,3.1746,-0.671),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="Beard",size=V(1.298,0.546,0.33),pos=V(0.0,3.1044,-0.704),rotation=V(0,0,0),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="BeardTip",size=V(0.7434,0.3276,0.297),pos=V(0.0,2.7378,-0.704),rotation=V(0,0,0),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="SafetyHelmet",size=V(1.85,0.36,1.5),pos=V(0,3.95,0),rotation=V(0,0,0),color=Color3.fromRGB(191,117,61),bone="Head"},
{name="HelmetRim",size=V(1.95,0.12,1.65),pos=V(0,3.78,0),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="Head"},
{name="LampHousing",size=V(0.48,0.38,0.2),pos=V(0,3.94,-0.8),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="Head"},
{name="LampLens",size=V(0.28,0.25,0.1),pos=V(0,3.94,-0.94),rotation=V(0,0,0),color=Color3.fromRGB(231,221,190),bone="Head"},
{name="WorkApron",size=V(1.6,1.45,0.15),pos=V(0,2.1,-0.72),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="UpperTorso"},
{name="ReflectiveStrip",size=V(0.16,0.85,0.09),pos=V(-0.55,2.48,-0.84),rotation=V(0,0,0),color=Color3.fromRGB(231,221,190),bone="UpperTorso"},
{name="ReflectiveStrip",size=V(0.16,0.85,0.09),pos=V(0.55,2.48,-0.84),rotation=V(0,0,0),color=Color3.fromRGB(231,221,190),bone="UpperTorso"},
{name="RescueBand",size=V(0.48,0.22,0.7),pos=V(-1.38,2.19,0),rotation=V(0,0,0),color=Color3.fromRGB(231,221,190),bone="LeftLowerArm"},
{name="DustPatch",size=V(0.29,0.16,0.07),pos=V(0.51,3.25,-0.7),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="Head"},
}},
{id="engineer",class="Dwarf",designId="npc.ironveil.engineer",bones={
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
{name="Waist",size=V(1.711,0.468,0.858),pos=V(0.0,1.911,0.0),rotation=V(0,0,0),color=Color3.fromRGB(73,145,147),bone="LowerTorso"},
{name="Chest",size=V(2.006,0.663,1.045),pos=V(0.0,2.5116,0.0),rotation=V(0,0,0),color=Color3.fromRGB(73,145,147),bone="UpperTorso"},
{name="Belt",size=V(1.8644,0.156,0.946),pos=V(0.0,1.833,0.0),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LowerTorso"},
{name="Head",size=V(1.5576,0.858,1.232),pos=V(0.0,3.393,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="LeftEye",size=V(0.1534,0.1092,0.055),pos=V(-0.354,3.4476,-0.6336),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="LeftUpperArm",size=V(0.6608,0.5616,0.704),pos=V(-1.3688,2.535,0.0),rotation=V(0,0,0),color=Color3.fromRGB(73,145,147),bone="LeftUpperArm"},
{name="LeftLowerArm",size=V(0.6018,0.4368,0.649),pos=V(-1.3688,1.9812,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="LeftLowerArm"},
{name="LeftHand",size=V(0.5782,0.273,0.616),pos=V(-1.3688,1.5756,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="LeftHand"},
{name="LeftUpperLeg",size=V(0.7198,0.6708,0.748),pos=V(-0.5664,1.3104,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="LeftUpperLeg"},
{name="LeftLowerLeg",size=V(0.6962,0.546,0.726),pos=V(-0.5664,0.585,0.0),rotation=V(0,0,0),color=Color3.fromRGB(73,145,147),bone="LeftLowerLeg"},
{name="LeftBoot",size=V(0.8496,0.3276,1.1),pos=V(-0.5664,0.1794,-0.198),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="LeftFoot"},
{name="RightEye",size=V(0.1534,0.1092,0.055),pos=V(0.354,3.4476,-0.6336),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="RightUpperArm",size=V(0.6608,0.5616,0.704),pos=V(1.3688,2.535,0.0),rotation=V(0,0,0),color=Color3.fromRGB(73,145,147),bone="RightUpperArm"},
{name="RightLowerArm",size=V(0.6018,0.4368,0.649),pos=V(1.3688,1.9812,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="RightLowerArm"},
{name="RightHand",size=V(0.5782,0.273,0.616),pos=V(1.3688,1.5756,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="RightHand"},
{name="RightUpperLeg",size=V(0.7198,0.6708,0.748),pos=V(0.5664,1.3104,0.0),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="RightUpperLeg"},
{name="RightLowerLeg",size=V(0.6962,0.546,0.726),pos=V(0.5664,0.585,0.0),rotation=V(0,0,0),color=Color3.fromRGB(73,145,147),bone="RightLowerLeg"},
{name="RightBoot",size=V(0.8496,0.3276,1.1),pos=V(0.5664,0.1794,-0.198),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="RightFoot"},
{name="HairCap",size=V(1.652,0.234,1.32),pos=V(0.0,3.8922,0.022),rotation=V(0,0,0),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="LeftBrow",size=V(0.295,0.0507,0.0715),pos=V(-0.354,3.5802,-0.682),rotation=V(0,0,-4),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="LeftEar",size=V(0.1888,0.1872,0.275),pos=V(-0.8614,3.432,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="RightBrow",size=V(0.295,0.0507,0.0715),pos=V(0.354,3.5802,-0.682),rotation=V(0,0,4),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="RightEar",size=V(0.1888,0.1872,0.275),pos=V(0.8614,3.432,0.0),rotation=V(0,0,0),color=Color3.fromRGB(219,177,139),bone="Head"},
{name="Mouth",size=V(0.295,0.0351,0.066),pos=V(0.0,3.1746,-0.671),rotation=V(0,0,0),color=Color3.fromRGB(39,44,57),bone="Head"},
{name="Beard",size=V(1.298,0.546,0.33),pos=V(0.0,3.1044,-0.704),rotation=V(0,0,0),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="BeardTip",size=V(0.7434,0.3276,0.297),pos=V(0.0,2.7378,-0.704),rotation=V(0,0,0),color=Color3.fromRGB(132,70,43),bone="Head"},
{name="SafetyHelmet",size=V(1.85,0.36,1.5),pos=V(0,3.95,0),rotation=V(0,0,0),color=Color3.fromRGB(191,117,61),bone="Head"},
{name="HelmetRim",size=V(1.95,0.12,1.65),pos=V(0,3.78,0),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="Head"},
{name="LampHousing",size=V(0.48,0.38,0.2),pos=V(0,3.94,-0.8),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="Head"},
{name="LampLens",size=V(0.28,0.25,0.1),pos=V(0,3.94,-0.94),rotation=V(0,0,0),color=Color3.fromRGB(231,221,190),bone="Head"},
{name="WorkApron",size=V(1.6,1.45,0.15),pos=V(0,2.1,-0.72),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="UpperTorso"},
{name="ReflectiveStrip",size=V(0.16,0.85,0.09),pos=V(-0.55,2.48,-0.84),rotation=V(0,0,0),color=Color3.fromRGB(231,221,190),bone="UpperTorso"},
{name="ReflectiveStrip",size=V(0.16,0.85,0.09),pos=V(0.55,2.48,-0.84),rotation=V(0,0,0),color=Color3.fromRGB(231,221,190),bone="UpperTorso"},
{name="Blueprint",size=V(0.95,0.7,0.14),pos=V(1.38,1.64,-0.65),rotation=V(0,0,0),color=Color3.fromRGB(73,145,147),bone="RightHand"},
{name="BlueprintMark",size=V(0.65,0.07,0.05),pos=V(1.38,1.76,-0.75),rotation=V(0,0,0),color=Color3.fromRGB(231,221,190),bone="RightHand"},
{name="ToolBelt",size=V(1.7,0.25,1.25),pos=V(0,1.7,0),rotation=V(0,0,0),color=Color3.fromRGB(46,57,67),bone="LowerTorso"},
{name="WrenchHandle",size=V(0.16,0.63,0.15),pos=V(-1.45,1.56,-0.45),rotation=V(0,0,0),color=Color3.fromRGB(161,178,191),bone="LeftHand"},
{name="WrenchJaw",size=V(0.13,0.27,0.16),pos=V(-1.61,1.99,-0.45),rotation=V(0,0,0),color=Color3.fromRGB(161,178,191),bone="LeftHand"},
{name="WrenchJaw",size=V(0.13,0.27,0.16),pos=V(-1.29,1.99,-0.45),rotation=V(0,0,0),color=Color3.fromRGB(161,178,191),bone="LeftHand"},
}},
{id="carrier",class="Orc",designId="npc.ironveil.carrier",bones={
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
{name="Waist",size=V(1.48,0.6,0.85),pos=V(0,2.45,0),rotation=V(0,0,0),color=Color3.fromRGB(183,139,70),bone="LowerTorso"},
{name="Chest",size=V(1.9,0.9,1.05),pos=V(0,3.2,0),rotation=V(0,0,0),color=Color3.fromRGB(183,139,70),bone="UpperTorso"},
{name="Belt",size=V(1.55,0.18,0.94),pos=V(0,2.35,0),rotation=V(0,0,0),color=Color3.fromRGB(76,61,53),bone="LowerTorso"},
{name="Head",size=V(1.45,1.12,1.18),pos=V(0,4.35,0),rotation=V(0,0,0),color=Color3.fromRGB(111,146,91),bone="Head"},
{name="LeftEyeWhite",size=V(0.24,0.22,0.045),pos=V(-0.3,4.45,-0.606),rotation=V(0,0,0),color=Color3.fromRGB(222,211,179),bone="Head"},
{name="LeftEye",size=V(0.14,0.16,0.055),pos=V(-0.3,4.45,-0.61),rotation=V(0,0,0),color=Color3.fromRGB(36,42,40),bone="Head"},
{name="LeftEar",size=V(0.42,0.42,0.28),pos=V(-0.83,4.47,0.02),rotation=V(0,0,-22),color=Color3.fromRGB(111,146,91),bone="Head"},
{name="LeftTusk",size=V(0.12,0.27,0.14),pos=V(-0.4,4.02,-0.66),rotation=V(0,0,14),color=Color3.fromRGB(222,211,179),bone="Head"},
{name="LeftUpperArm",size=V(0.62,0.74,0.7),pos=V(-1.16,3.27,0),rotation=V(0,0,0),color=Color3.fromRGB(183,139,70),bone="LeftUpperArm"},
{name="LeftLowerArm",size=V(0.58,0.6,0.64),pos=V(-1.16,2.57,0),rotation=V(0,0,0),color=Color3.fromRGB(111,146,91),bone="LeftLowerArm"},
{name="LeftHand",size=V(0.55,0.36,0.61),pos=V(-1.16,2.03,0),rotation=V(0,0,0),color=Color3.fromRGB(111,146,91),bone="LeftHand"},
{name="LeftUpperLeg",size=V(0.65,0.87,0.71),pos=V(-0.48,1.69,0),rotation=V(0,0,0),color=Color3.fromRGB(76,61,53),bone="LeftUpperLeg"},
{name="LeftLowerLeg",size=V(0.61,0.7,0.69),pos=V(-0.48,0.77,0),rotation=V(0,0,0),color=Color3.fromRGB(183,139,70),bone="LeftLowerLeg"},
{name="LeftBoot",size=V(0.76,0.43,1.05),pos=V(-0.48,0.235,-0.18),rotation=V(0,0,0),color=Color3.fromRGB(76,61,53),bone="LeftFoot"},
{name="RightEyeWhite",size=V(0.24,0.22,0.045),pos=V(0.3,4.45,-0.606),rotation=V(0,0,0),color=Color3.fromRGB(222,211,179),bone="Head"},
{name="RightEye",size=V(0.14,0.16,0.055),pos=V(0.3,4.45,-0.61),rotation=V(0,0,0),color=Color3.fromRGB(36,42,40),bone="Head"},
{name="RightEar",size=V(0.42,0.42,0.28),pos=V(0.83,4.47,0.02),rotation=V(0,0,22),color=Color3.fromRGB(111,146,91),bone="Head"},
{name="RightTusk",size=V(0.12,0.27,0.14),pos=V(0.4,4.02,-0.66),rotation=V(0,0,-14),color=Color3.fromRGB(222,211,179),bone="Head"},
{name="RightUpperArm",size=V(0.62,0.74,0.7),pos=V(1.16,3.27,0),rotation=V(0,0,0),color=Color3.fromRGB(183,139,70),bone="RightUpperArm"},
{name="RightLowerArm",size=V(0.58,0.6,0.64),pos=V(1.16,2.57,0),rotation=V(0,0,0),color=Color3.fromRGB(111,146,91),bone="RightLowerArm"},
{name="RightHand",size=V(0.55,0.36,0.61),pos=V(1.16,2.03,0),rotation=V(0,0,0),color=Color3.fromRGB(111,146,91),bone="RightHand"},
{name="RightUpperLeg",size=V(0.65,0.87,0.71),pos=V(0.48,1.69,0),rotation=V(0,0,0),color=Color3.fromRGB(76,61,53),bone="RightUpperLeg"},
{name="RightLowerLeg",size=V(0.61,0.7,0.69),pos=V(0.48,0.77,0),rotation=V(0,0,0),color=Color3.fromRGB(183,139,70),bone="RightLowerLeg"},
{name="RightBoot",size=V(0.76,0.43,1.05),pos=V(0.48,0.235,-0.18),rotation=V(0,0,0),color=Color3.fromRGB(76,61,53),bone="RightFoot"},
{name="Smile",size=V(0.36,0.055,0.06),pos=V(0,4.04,-0.615),rotation=V(0,0,0),color=Color3.fromRGB(36,42,40),bone="Head"},
{name="Brow",size=V(0.35,0.07,0.08),pos=V(-0.3,4.67,-0.64),rotation=V(0,0,4),color=Color3.fromRGB(36,42,40),bone="Head"},
{name="SmileCorner",size=V(0.06,0.12,0.065),pos=V(-0.2,4.07,-0.62),rotation=V(0,0,0),color=Color3.fromRGB(36,42,40),bone="Head"},
{name="Brow",size=V(0.35,0.07,0.08),pos=V(0.3,4.67,-0.64),rotation=V(0,0,-4),color=Color3.fromRGB(36,42,40),bone="Head"},
{name="SmileCorner",size=V(0.06,0.12,0.065),pos=V(0.2,4.07,-0.62),rotation=V(0,0,0),color=Color3.fromRGB(36,42,40),bone="Head"},
{name="HairCrown",size=V(1.5,0.3,1.2),pos=V(0,4.97,0.03),rotation=V(0,0,0),color=Color3.fromRGB(76,61,53),bone="Head"},
{name="ShortBeard",size=V(1.05,0.3,0.23),pos=V(0,3.9,-0.55),rotation=V(0,0,0),color=Color3.fromRGB(76,61,53),bone="Head"},
{name="Sideburn",size=V(0.2,0.4,0.18),pos=V(-0.66,4.15,-0.5),rotation=V(0,0,0),color=Color3.fromRGB(76,61,53),bone="Head"},
{name="Sideburn",size=V(0.2,0.4,0.18),pos=V(0.66,4.15,-0.5),rotation=V(0,0,0),color=Color3.fromRGB(76,61,53),bone="Head"},
{name="CarrierHarness",size=V(0.26,1.8,0.15),pos=V(-0.55,3,-0.71),rotation=V(0,0,-14),color=Color3.fromRGB(191,117,61),bone="UpperTorso"},
{name="CarrierHarness",size=V(0.26,1.8,0.15),pos=V(0.55,3,-0.71),rotation=V(0,0,14),color=Color3.fromRGB(191,117,61),bone="UpperTorso"},
{name="OrePack",size=V(1.8,1.5,0.75),pos=V(0,3,0.88),rotation=V(0,0,0),color=Color3.fromRGB(104,72,48),bone="UpperTorso"},
{name="PackBand",size=V(0.18,1.55,0.82),pos=V(-0.55,3,0.88),rotation=V(0,0,0),color=Color3.fromRGB(191,117,61),bone="UpperTorso"},
{name="PackBand",size=V(0.18,1.55,0.82),pos=V(0.55,3,0.88),rotation=V(0,0,0),color=Color3.fromRGB(191,117,61),bone="UpperTorso"},
{name="ReceiptBook",size=V(0.72,0.87,0.13),pos=V(1.42,2,-0.54),rotation=V(0,0,0),color=Color3.fromRGB(231,221,190),bone="RightHand"},
{name="ReceiptSeal",size=V(0.2,0.2,0.05),pos=V(1.42,2,-0.64),rotation=V(0,0,45),color=Color3.fromRGB(73,145,147),bone="RightHand"},
}},
}
return function(rigged:boolean?,onlyId:string?): Folder
    local folder=Instance.new("Folder");folder.Name="IronveilCharacterKit"
    for _,asset in ipairs(assets) do
        if onlyId and asset.id~=onlyId then continue end
        local m=Instance.new("Model");m.Name=asset.id;m.WorldPivot=CFrame.identity
        m:SetAttribute("RaceId",asset.class);m:SetAttribute("FriendlyNPC",true);m:SetAttribute("DesignId",asset.designId);m:SetAttribute("RecruitmentBound",false)
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
