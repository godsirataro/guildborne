--!strict
-- Local Studio preview of reviewed source geometry. No upload, saved asset IDs,
-- combat authority or production import claim. The build validates input bounds.
local AssetService = game:GetService("AssetService")
local Preview = {}
local function vector(v: {number}): Vector3
	return Vector3.new(v[1], v[2], v[3])
end
function Preview.create(data: any, parent: Instance, onAllocated: ((any) -> ())?): any
	assert(game:GetService("RunService"):IsStudio() and game.PlaceId == 0 and game.GameId == 0, "Local Studio only")
	assert(data.schemaVersion == 1, "Unknown asset schema")
	local folder = Instance.new("Folder")
	folder.Name = "QualitySourceArt"; folder:SetAttribute("LocalPreviewOnly", true)
	folder.Parent = parent
	local meshes: {EditableMesh} = {}
	local templates: {[string]: MeshPart} = {}
	local centers: {[string]: Vector3} = {}
	local result: any = {folder=folder, meshes=meshes, placements=0, triangles=0}
	local closed = false
	function result.destroy()
		closed = true
		folder:Destroy()
		for _, part in pairs(templates) do part:Destroy() end
		for _, mesh in ipairs(meshes) do mesh:Destroy() end
		table.clear(templates); table.clear(meshes)
	end
	local ok, problem = pcall(function()
		if onAllocated then onAllocated(result) end
		for _, def in ipairs(data.meshes) do
			assert(not closed, "Preview construction cancelled")
			local mesh = assert(AssetService:CreateEditableMesh(), "Editable mesh budget unavailable")
			table.insert(meshes, mesh)
			local vertices, colors = {}, {}
			for i, v in ipairs(def.vertices) do
				vertices[i] = mesh:AddVertex(vector(v))
				if i % 1000 == 0 then task.wait(); assert(not closed, "Preview construction cancelled") end
			end
			for i, c in ipairs(def.colors) do colors[i] = mesh:AddColor(Color3.new(c[1], c[2], c[3]), 1) end
			for i, f in ipairs(def.triangles) do
				local face = mesh:AddTriangle(vertices[f[1]], vertices[f[2]], vertices[f[3]])
				local color = colors[def.faceColors[i]]
				mesh:SetFaceColors(face, {color, color, color})
				local a, b, c = vector(def.vertices[f[1]]), vector(def.vertices[f[2]]), vector(def.vertices[f[3]])
				local cross = (b-a):Cross(c-a)
				if cross.Magnitude > 0.000001 then
					local normal = mesh:AddNormal(cross.Unit)
					mesh:SetFaceNormals(face, {normal, normal, normal})
				end
				if i % 750 == 0 then task.wait(); assert(not closed, "Preview construction cancelled") end
			end
			local part = AssetService:CreateMeshPartAsync(Content.fromObject(mesh))
			templates[def.id] = part
			assert(not closed, "Preview construction cancelled")
			part.Name = def.id; part.Anchored = true
			part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
			part.Color = Color3.new(1,1,1); part.Material = Enum.Material.SmoothPlastic
			templates[def.id] = part; centers[def.id] = mesh:GetCenter()
			result.triangles += #def.triangles
			task.wait()
		end
		for i, def in ipairs(data.placements) do
			assert(not closed, "Preview construction cancelled")
			local part = assert(templates[def.meshId], "Unknown mesh placement"):Clone()
			part.Name = def.name
			local scale = vector(def.scale or {1,1,1})
			part.Size *= scale
			part.CFrame = CFrame.new(table.unpack(def.cframe)) * CFrame.new(centers[def.meshId] * scale)
			part:SetAttribute("SourceMeshId", def.meshId)
			part.Parent = folder; result.placements += 1
			if i % 12 == 0 then task.wait() end
		end
	end)
	if not ok then result.destroy(); error(tostring(problem)) end
	return result
end
return Preview
