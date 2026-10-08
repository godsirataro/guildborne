--!strict
-- Fit authored visual pieces to the existing six-joint companion rig.
-- Equipped weapons/armor remain separate; this module grants no items or statistics.
local kit=require(script.Parent.HeroVisualKit)
local V=Vector3.new
local weaponParts:{[string]:boolean}={Grip=true,Guard=true,Blade=true,BowLimb=true,Bowstring=true,Staff=true,Focus=true}
return function(model:Model,id:string):boolean
    if model:GetAttribute("VisualTemplateId")==id and model:FindFirstChild("HeroAppearance") then return true end
    local folder=kit(false,id);local visual=folder:FindFirstChild(id) :: Model?
    if not visual then folder:Destroy();return false end
    local ok=pcall(function()
        for _,entry in ipairs(visual:GetChildren()) do
            local part=entry :: BasePart
            if weaponParts[part.Name] then part:Destroy();continue end
            local bone=part:GetAttribute("BindBone") :: string
            local limb="Torso";local reference=V(0,3.22,0)
            if bone=="Head" then limb="Head";reference=V(0,4.35,0)
            elseif string.find(bone,"Arm") or string.find(bone,"Hand") then
                local left=string.sub(bone,1,4)=="Left";limb=if left then "Left Arm" else "Right Arm";reference=V(if left then -1.16 else 1.16,3,0)
            elseif string.find(bone,"Leg") or string.find(bone,"Foot") then
                local left=string.sub(bone,1,4)=="Left";limb=if left then "Left Leg" else "Right Leg";reference=V(if left then -.48 else .48,1,0)
            end
            local anchor=model:FindFirstChild(limb) :: BasePart?;assert(anchor)
            part.CFrame=anchor.CFrame*CFrame.new(-reference)*part.CFrame
            part.Anchored=false;part.Massless=true;part.CollisionGroup="GuildborneHeroes"
            local weld=Instance.new("WeldConstraint");weld.Part0=anchor;weld.Part1=part;weld.Parent=part
        end
    end)
    if not ok then folder:Destroy();return false end
    local old=model:FindFirstChild("HeroAppearance");if old then old:Destroy() end
    for _,part in ipairs(model:GetChildren()) do
        if part:IsA("BasePart") then part.Transparency=1 end
    end
    visual.Parent=model;visual.Name="HeroAppearance";folder:Destroy()
    model:SetAttribute("VisualTemplateId",id);return true
end
