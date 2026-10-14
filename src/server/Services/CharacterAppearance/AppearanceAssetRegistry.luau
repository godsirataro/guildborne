--!strict
-- Import map. Catalog entries stay PLANNED until a reviewed import record exists.
-- An export on disk or a matching target path alone never confers TESTED/ACCEPTED status.
local Catalog=require(game.ReplicatedStorage.Shared.Data.AppearanceCatalog)
local Registry: any={}
Registry.Entries={}
for id,asset in pairs(Catalog.Assets) do
	Registry.Entries[id]={assetId=id,status="PLANNED",robloxAssetId=nil,template=nil,studioPath=asset.studioPath,sourcePath=asset.sourcePath,exportPath=asset.exportPath,fitTestedPresets={},cagesValidated=false}
end
function Registry.Get(id: string): any return Registry.Entries[id] end
function Registry.ValidateLayeredTemplate(body: Model,garment: Instance): (boolean,string?)
	local handle=garment:FindFirstChild("Handle")
	if not handle or not handle:IsA("MeshPart") or handle.MeshId=="" then return false,"LAYERED_MESH_MISSING" end
	local layer=handle:FindFirstChildOfClass("WrapLayer")
	if not layer or layer.CageMeshId=="" or layer.ReferenceMeshId=="" then return false,"LAYERED_CAGES_MISSING" end
	local count=0
	for _,part in ipairs(body:GetChildren()) do
		if part:IsA("MeshPart") and part:GetAttribute("CoreBodyPart")==true then
			local target=part:FindFirstChildOfClass("WrapTarget")
			if not target or target.CageMeshId=="" then return false,"BODY_WRAP_TARGET_MISSING" end
			count+=1
		end
	end
	if count~=15 then return false,"BODY_15_MESHPARTS_REQUIRED" end
	-- This is a structural precheck, never a UV, deformation, or per-preset acceptance.
	return true,nil
end
return Registry
