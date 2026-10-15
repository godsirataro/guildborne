--!strict
-- Native geometry only. No runtime downloads, Terrain edits or frame loops.
local Details=require(script.Parent.CityLandscapeData)
return function(town: Folder)
    local root=Instance.new("Folder");root.Name="NaturalLandscape";root.Parent=town
    root:SetAttribute("RecipeVersion",1)
    local groups:{[string]:Model?}={}
    local function getGroup(name:string):Model
        local existing=groups[name]
        if existing then return existing end
        local created=Instance.new("Model");created.Name=name;created.Parent=root;groups[name]=created
        return created
    end
    for _,d in ipairs(Details) do
        local group=getGroup(d.group)
        local p=Instance.new("Part");p.Name=d.name
        p.Shape=if d.shape=="Ball" then Enum.PartType.Ball elseif d.shape=="Cylinder" then Enum.PartType.Cylinder else Enum.PartType.Block
        p.Size=Vector3.new(d.size[1],d.size[2],d.size[3])
        p.CFrame=CFrame.new(d.position[1],d.position[2],d.position[3])*CFrame.Angles(math.rad(d.rotation[1]),math.rad(d.rotation[2]),math.rad(d.rotation[3]))
        p.Color=Color3.fromRGB(d.color[1],d.color[2],d.color[3])
        p.Material=(Enum.Material :: any)[d.material]
        p.Anchored=true;p.CanCollide=d.solid;p.CanQuery=d.solid;p.CanTouch=false
        p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
        p.CastShadow=d.name=="Trunk" or d.name=="Bough" or d.name=="OakCrown" or d.name=="WeatheredRock"
        p.Parent=group
    end
end
