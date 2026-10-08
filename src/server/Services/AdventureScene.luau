--!strict
-- Reviewable native scene assembly. Returns an unparented model and never starts gameplay.
local Catalog=require(script.Parent.Parent.Config.AdventureEncounters)
local MapKit=require(script.Parent.AdventureMapKit)
local EnemyKit=require(script.Parent.AdventureEnemyKit)
return function(region:string,geometry:Model?): Model?
    local def=(Catalog.Regions :: any)[region];if not def then return nil end
    local maps=if geometry then nil else MapKit();local enemies=EnemyKit()
    local model=if geometry then Instance.new("Model") else (maps :: Folder):FindFirstChild(def.Map) :: Model?
    if not model then if maps then maps:Destroy() end;enemies:Destroy();return nil end
    model.Parent=nil;if maps then maps:Destroy() end
    if geometry then model.Name=region;model.WorldPivot=geometry:GetPivot() end
    local ok,problem=pcall(function()
        local markers=(geometry or model):FindFirstChild("EncounterMarkers") :: Folder
        assert(markers and markers:FindFirstChild(def.Arrival),"Arrival marker missing")
        local actors=Instance.new("Folder");actors.Name="EncounterArt";actors.Parent=model
        for _,entry in ipairs(def.Encounters) do
            local marker=markers:FindFirstChild(entry.Marker) :: BasePart?
            local template=enemies:FindFirstChild(entry.Asset) :: Model?
            assert(marker and template,"Encounter binding missing: "..entry.Asset)
            assert(marker:GetAttribute("Role")==entry.Role and template:GetAttribute("VisualRole")==entry.Role,"Role mismatch")
            assert(template:GetAttribute("Region")==region,"Region mismatch")
            local actor=template:Clone();actor:PivotTo(marker.CFrame)
            actor:SetAttribute("EncounterMarker",entry.Marker);actor:SetAttribute("PreviewOnly",true);actor.Parent=actors
        end
        model:SetAttribute("PreviewOnly",true);model:SetAttribute("EncountersEnabled",false)
    end)
    enemies:Destroy()
    if not ok then model:Destroy();error(tostring(problem)) end
    return model
end
