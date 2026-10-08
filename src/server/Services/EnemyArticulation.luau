--!strict
-- Six cosmetic joints around the existing authoritative anchored root.
-- Art welds do not change targeting, collision, health, rewards or locomotion.
local V=Vector3.new
return function(model: Model,legacyGoblin: boolean?)
    if model:FindFirstChild("EnemyJoints") then return end
    local root=assert(model.PrimaryPart,"Enemy root required")
    local pieces: {BasePart}={}
    for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") and p~=root then table.insert(pieces,p) end end
    local folder=Instance.new("Folder");folder.Name="EnemyJoints";folder.Parent=model
    local center=root.CFrame
    local pivots={Torso=V(0,0,0),Head=V(0,1.2,0),LeftArm=V(-1,1,0),RightArm=V(1,1,0),LeftLeg=V(-.45,-.4,0),RightLeg=V(.45,-.4,0)}
    local regional=model:GetAttribute("EncounterId")~=nil
    local function boundGroup(bone:string):string
        if bone=="Head" then return "Head" end
        local side=if bone:find("Left") then "Left" else "Right"
        if bone:find("Front") or bone:find("Arm") or bone:find("Hand") then return side.."Arm" end
        if bone:find("Rear") or bone:find("Leg") or bone:find("Foot") then return side.."Leg" end
        return "Torso"
    end
    if regional then
        local chosen={}
        for _,p in ipairs(pieces) do
            local bone=tostring(p:GetAttribute("BindBone") or "")
            local group=boundGroup(bone)
            if not chosen[group] and ((group=="Head" and p.Name=="Head") or bone:find("UpperArm") or bone:find("UpperLeg")) then
                pivots[group]=center:PointToObjectSpace(p.Position+V(0,p.Size.Y*(if group=="Head" then -.5 else .5),0));chosen[group]=true
            end
        end
    end
    local names={Torso="RootJoint",Head="Neck",LeftArm="Left Shoulder",RightArm="Right Shoulder",LeftLeg="Left Hip",RightLeg="Right Hip"}
    local carriers: {[string]: BasePart}={}
    for name,offset in pairs(pivots) do
        local p=Instance.new("Part");p.Name=name;p.Size=V(.1,.1,.1);p.Transparency=1;p.Anchored=false;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.CFrame=center*CFrame.new(offset);p.Parent=folder;carriers[name]=p
    end
    for name,p in pairs(carriers) do
        local parent=if name=="Torso" then root else carriers.Torso
        local joint=Instance.new("Motor6D");joint.Name=names[name];joint.Part0=parent;joint.Part1=p;joint.C0=parent.CFrame:ToObjectSpace(p.CFrame);joint.Parent=folder
    end
    for _,p in ipairs(pieces) do
        -- The legacy static goblin was authored facing +Z; Roblox forward is -Z.
        if legacyGoblin then p.CFrame=center*CFrame.Angles(0,math.pi,0)*center:ToObjectSpace(p.CFrame) end
        local name=p.Name;local localPosition=center:PointToObjectSpace(p.Position)
        local side=if localPosition.X<0 then "Left" else "Right"
        local group="Torso"
        if regional then group=boundGroup(tostring(p:GetAttribute("BindBone") or ""))
        elseif name=="Arm" or name=="Shoulder" then group=side.."Arm"
        elseif name=="Boot" or name=="Leg" or name=="Greave" then group=side.."Leg"
        elseif name=="Head" or name=="Nose" or name=="Eye" or name=="PointedEar" or name=="Helm" or name=="Brow" or name=="HoodPeak" or name:find("Crown") then group="Head"
        elseif name:find("Hammer") or name:find("Sword") then group="RightArm"
        elseif name:find("Shield") or name:find("Bow") then group="LeftArm" end
        p.Anchored=false;p.Massless=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
        local weld=Instance.new("WeldConstraint");weld.Name="EnemyArtWeld";weld.Part0=carriers[group];weld.Part1=p;weld.Parent=p
        p:SetAttribute("EnemyLimb",group)
    end
    local role=model:GetAttribute("VisualRole")
    model:SetAttribute("EnemyAnimationClass",if role=="Echo Archer" or role=="Ranged" then "Archer" elseif role=="Spell" then "Mage" elseif role=="Support" then "Priest" elseif role=="Spire Warden" or role=="Boss" then "Warrior" else "Knight")
    model:SetAttribute("EnemyArticulated",true)
    game:GetService("CollectionService"):AddTag(model,"GuildborneAnimatedEnemy")
end
