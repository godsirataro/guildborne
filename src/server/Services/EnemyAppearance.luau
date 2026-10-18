--!strict
-- Original native Tower armor; no uploaded assets or changes to combat proxies.
local V=Vector3.new
local dark=Color3.fromRGB(35,43,56)
local steel=Color3.fromRGB(113,133,151)
local edge=Color3.fromRGB(177,190,197)
local brass=Color3.fromRGB(168,129,64)
local leather=Color3.fromRGB(67,48,42)
local violet=Color3.fromRGB(106,76,143)
local teal=Color3.fromRGB(45,101,113)
return function(model: Model,role: string)
    assert(not model:FindFirstChild("EnemyAppearance"),"Tower appearance already built")
    local base=assert(model.PrimaryPart).CFrame*CFrame.new(0,-2,0)
    local folder=Instance.new("Folder");folder.Name="EnemyAppearance";folder.Parent=model
    local boss,ranged=role=="Spire Warden",role=="Echo Archer"
    local width=if boss then 1.10 elseif ranged then .86 else 1
    local cloth=if ranged then teal else violet
    local trim=if boss then brass else edge
    local count=0
    local function piece(name:string,limb:string,size:Vector3,pos:Vector3,color:Color3,shape:string?,rotation:CFrame?,material:Enum.Material?):BasePart
        local p:BasePart
        if shape=="Wedge" then p=Instance.new("WedgePart") else
            local part=Instance.new("Part")
            if shape=="Cylinder" then part.Shape=Enum.PartType.Cylinder elseif shape=="Ball" then part.Shape=Enum.PartType.Ball end
            p=part
        end
        p.Name=name;p.Size=size;p.CFrame=base*CFrame.new(pos)*(rotation or CFrame.identity)
        p.Color=color;p.Material=material or Enum.Material.Metal
        p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=material~=Enum.Material.Neon
        p:SetAttribute("EnemyVisualLimb",limb);p.Parent=folder;count+=1;return p
    end
    local function rod(name:string,limb:string,a:Vector3,b:Vector3,radius:number,color:Color3)
        local midpoint=(a+b)/2
        return piece(name,limb,V((b-a).Magnitude,radius*2,radius*2),midpoint,color,"Cylinder",CFrame.lookAt(midpoint,b).Rotation*CFrame.Angles(0,math.pi/2,0))
    end
    piece("Gambeson","Torso",V(1.5*width,1.38,.86),V(0,2.25,0),dark,nil,nil,Enum.Material.Fabric)
    piece("Backplate","Torso",V(1.46*width,1.20,.18),V(0,2.32,.48),steel)
    piece("Breastplate","Torso",V(1.36*width,.94,.22),V(0,2.53,-.49),steel,"Wedge",CFrame.Angles(0,math.pi,0))
    piece("Gorget","Torso",V(1.1,.16,.74),V(0,3.04,0),trim)
    piece("WaistBelt","Torso",V(1.6*width,.18,.96),V(0,1.70,0),leather,nil,nil,Enum.Material.Fabric)
    piece("Buckle","Torso",V(.33,.27,.08),V(0,1.7,-.53),brass)
    piece("Tabard","Torso",V(.64,.97,.10),V(0,1.26,-.52),cloth,nil,nil,Enum.Material.Fabric)
    piece("TabardTip","Torso",V(.64,.25,.10),V(0,.67,-.52),cloth,"Wedge",CFrame.Angles(0,0,math.pi/2),Enum.Material.Fabric)
    piece("BackMantle","Torso",V(1.12,1.8,.11),V(0,2.05,.61),cloth,nil,CFrame.Angles(.12,0,0),Enum.Material.Fabric)
    for _,side in ipairs({-1,1}) do
        local arm=if side<0 then "LeftArm" else "RightArm"
        local leg=if side<0 then "LeftLeg" else "RightLeg"
        local x=side*.47
        piece("ThighMail",leg,V(.51,.73,.58),V(x,1.39,0),dark)
        piece("KneeCap",leg,V(.61,.32,.24),V(x,1.05,-.35),trim,"Wedge",CFrame.Angles(0,math.pi,0))
        piece("ShinPlate",leg,V(.51,.64,.24),V(x,.65,-.27),steel,"Wedge",CFrame.Angles(0,math.pi,0))
        piece("Boot",leg,V(.64,.38,.82),V(x,.25,-.06),dark)
        piece("Sabatons",leg,V(.65,.19,.48),V(x,.25,-.47),steel,"Wedge",CFrame.Angles(0,math.pi,0))
        piece("BootCuff",leg,V(.57,.12,.62),V(x,.48,0),leather)
        local ax=side*(.85*width+.21)
        piece("Sleeve",arm,V(.44,1.04,.54),V(ax,2.34,0),dark,nil,CFrame.Angles(0,0,side*.08),Enum.Material.Fabric)
        piece("Pauldron",arm,V(if boss then 1.02 else .72,.36,.88),V(ax,2.99,0),steel,"Wedge",CFrame.Angles(0,if side<0 then math.pi else 0,side*.14))
        piece("PauldronRim",arm,V(if boss then 1.07 else .77,.11,.94),V(ax,2.83,0),trim)
        piece("Bracer",arm,V(.51,.48,.62),V(ax,2.02,0),steel)
        piece("Glove",arm,V(.43,.35,.48),V(ax,1.66,-.02),leather,nil,nil,Enum.Material.Fabric)
        piece("ChestFlange","Torso",V(.14,.85,.12),V(side*.62*width,2.51,-.64),trim,nil,CFrame.Angles(0,0,-side*.16))
        piece("HipLame","Torso",V(.45,.44,.18),V(side*.60*width,1.48,-.43),steel,"Wedge",CFrame.Angles(0,math.pi,side*.12))
    end
    piece("HelmShell","Head",V(1.08,.96,.97),V(0,3.61,0),dark)
    piece("HelmTop","Head",V(1.12,.26,1.01),V(0,4.12,0),steel,"Wedge")
    piece("Visor","Head",V(.92,.19,.08),V(0,3.69,-.53),Color3.fromRGB(17,23,30))
    piece("Brow","Head",V(1.17,.13,.18),V(0,3.89,-.51),trim)
    piece("Nasal","Head",V(.12,.44,.13),V(0,3.64,-.60),steel)
    piece("JawGuard","Head",V(.66,.22,.20),V(0,3.25,-.47),steel,"Wedge")
    for _,side in ipairs({-1,1}) do
        piece("CheekGuard","Head",V(.20,.46,.36),V(side*.48,3.48,-.33),steel,"Wedge",CFrame.Angles(0,side*.15,0))
        piece("VisorEye","Head",V(.21,.07,.025),V(side*.27,3.69,-.58),if boss then brass elseif ranged then teal else violet,nil,nil,Enum.Material.Neon)
    end
    if boss then
        piece("CrownBand","Head",V(1.2,.16,1.06),V(0,4.12,0),brass)
        for i=1,5 do
            local x=(i-3)*.25
            piece("CrownTooth","Head",V(.14,if i==3 then .68 else .44,.20),V(x,4.40,-.37),brass,"Wedge",CFrame.Angles(0,0,-x*.45))
        end
        rod("HammerHaft","RightArm",V(1.20,.55,-.16),V(1.20,3.18,-.16),.085,leather)
        piece("HammerPommel","RightArm",V(.27,.22,.27),V(1.20,.58,-.16),brass,"Ball")
        piece("HammerCore","RightArm",V(1.42,.68,.66),V(1.20,3.23,-.16),dark)
        for _,side in ipairs({-1,1}) do
            piece("HammerFace","RightArm",V(.27,.83,.83),V(1.20+side*.81,3.23,-.16),steel)
            piece("HammerFaceBevel","RightArm",V(.25,.24,.83),V(1.20+side*.81,3.74,-.16),trim,"Wedge")
            piece("HammerBand","RightArm",V(.13,.74,.73),V(1.20+side*.48,3.23,-.16),brass)
            piece("CrownShoulderFin",if side<0 then "LeftArm" else "RightArm",V(.22,.52,.72),V(side*1.20,3.34,0),brass,"Wedge")
        end
        piece("HammerSeal","RightArm",V(.25,.31,.035),V(1.20,3.23,-.51),brass,nil,nil,Enum.Material.Neon)
    elseif ranged then
        piece("HoodBack","Head",V(1.20,1.08,.37),V(0,3.64,.43),teal,nil,nil,Enum.Material.Fabric)
        piece("HoodPoint","Head",V(.74,.50,.85),V(0,4.29,.08),teal,"Wedge",nil,Enum.Material.Fabric)
        local x=-1.05
        rod("BowGrip","LeftArm",V(x,1.44,-.39),V(x,1.90,-.39),.10,leather)
        for _,side in ipairs({-1,1}) do
            local a,b,c=V(x,1.67+side*.20,-.40),V(x,1.67+side*.72,-.68),V(x,1.67+side*1.12,-.42)
            rod("BowInnerLimb","LeftArm",a,b,.07,brass)
            rod("BowRecurve","LeftArm",b,c,.055,steel)
            piece("BowTip","LeftArm",V(.16,.14,.16),c,brass)
        end
        rod("BowString","LeftArm",V(x,.55,-.42),V(x,2.79,-.42),.012,edge)
        piece("Quiver","Torso",V(.46,1.17,.42),V(.44,2.52,.82),leather,nil,CFrame.Angles(0,0,-.16),Enum.Material.Fabric)
        piece("QuiverRim","Torso",V(.52,.12,.48),V(.53,3.11,.82),brass)
        for i=1,3 do
            local ax=.34+i*.10
            rod("QuiverArrow","Torso",V(ax,2.86,.82),V(ax,3.58,.82),.022,edge)
            piece("ArrowFletch","Torso",V(.12,.18,.035),V(ax,3.48,.82),teal,"Wedge")
        end
    else
        local x=-1.07
        piece("ShieldBody","LeftArm",V(1.14,1.48,.20),V(x,1.99,-.51),dark)
        piece("ShieldFoot","LeftArm",V(1.14,.48,.20),V(x,1.01,-.51),steel,"Wedge",CFrame.Angles(0,0,math.pi/2))
        for _,side in ipairs({-1,1}) do
            piece("ShieldRail","LeftArm",V(.10,1.55,.26),V(x+side*.58,1.99,-.51),trim)
            piece("ShieldStud","LeftArm",V(.13,.13,.08),V(x+side*.40,2.50,-.66),brass,"Ball")
        end
        piece("ShieldCrest","LeftArm",V(.32,.63,.07),V(x,2.05,-.65),violet,"Wedge")
        piece("ShieldTop","LeftArm",V(1.26,.12,.27),V(x,2.78,-.51),steel)
        piece("ShieldBoss","LeftArm",V(.30,.30,.15),V(x,1.96,-.70),brass,"Ball")
        rod("SwordGrip","RightArm",V(1.06,1.40,-.15),V(1.06,1.86,-.15),.075,leather)
        piece("SwordPommel","RightArm",V(.21,.21,.21),V(1.06,1.35,-.15),brass,"Ball")
        piece("SwordGuard","RightArm",V(.68,.11,.20),V(1.06,1.92,-.15),brass)
        piece("SwordBlade","RightArm",V(.21,1.48,.10),V(1.06,2.72,-.15),edge)
        piece("SwordFuller","RightArm",V(.045,1.25,.012),V(1.06,2.70,-.21),dark)
        piece("SwordTip","RightArm",V(.21,.30,.10),V(1.06,3.61,-.15),edge,"Wedge",CFrame.Angles(0,0,math.pi))
    end
    assert(count<=78,"Tower cosmetic part budget exceeded") -- plus six carriers and existing root <=85
    model:SetAttribute("VisualRole",role);model:SetAttribute("EnemyVisualStyle","SpireForgedV2");model:SetAttribute("EnemyVisualPartCount",count)
end
