--!strict
-- Local Studio preview of reviewed source geometry. No upload, saved asset IDs,
-- combat authority or production import claim. The build validates input bounds.
local AssetService = game:GetService("AssetService")
local Preview = {}

-- One module is shared by all datasets. Only identical source geometry shares
-- a fixed mesh/template; IDs, placements and source coordinates stay per dataset.
-- Keep exact numeric arrays, not a rounded/stringified hash or mesh ID identity.
local entries: {any} = {}
local geometryFields = {"vertices", "colors", "triangles", "faceColors"}
local function copyArray(value: any): any
	if type(value) ~= "table" then return value end
	local copied = {}
	for i, item in ipairs(value) do copied[i] = copyArray(item) end
	return copied
end
local function sameArray(a: any, b: any): boolean
	if type(a) ~= "table" or type(b) ~= "table" then return a == b end
	if #a ~= #b then return false end
	for i, value in ipairs(a) do if not sameArray(value, b[i]) then return false end end
	return true
end
local function sameGeometry(a: any, b: any): boolean
	for _, field in ipairs(geometryFields) do
		if not sameArray(a[field], b[field]) then return false end
	end
	return true
end
local function forget(entry: any)
	local index = table.find(entries, entry)
	if index then table.remove(entries, index) end
end
local function dispose(entry: any)
	forget(entry)
	for _, field in ipairs({"template", "dynamic", "fixed"}) do
		local resource = entry[field]
		entry[field] = nil
		if resource then resource:Destroy() end
	end
end
local function release(entry: any)
	entry.references -= 1
	assert(entry.references >= 0, "Preview reference underflow")
	-- An async allocation can still return a resource. The builder owns cleanup
	-- until it settles; destroying a handle must never strand that late resource.
	if entry.references == 0 and entry.state ~= "building" then dispose(entry) end
end
local function vector(v: {number}): Vector3
	return Vector3.new(v[1], v[2], v[3])
end
local function build(entry: any, id: string)
	local def = entry.geometry
	local function alive() assert(entry.references > 0, "Preview construction cancelled") end
	local mesh = assert(AssetService:CreateEditableMesh(), "Editable mesh budget unavailable")
	entry.dynamic = mesh
	local vertices, colors = {}, {}
	-- MeshPart uses mesh-local coordinates: apply the source center once.
	local low = vector(def.vertices[1])
	local high = low
	for _, v in ipairs(def.vertices) do
		local point = vector(v)
		low = low:Min(point); high = high:Max(point)
	end
	local originalCenter = (low + high) / 2
	entry.center = originalCenter
	for i, v in ipairs(def.vertices) do
		vertices[i] = mesh:AddVertex(vector(v) - originalCenter)
		if i % 1000 == 0 then task.wait(); alive() end
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
		if i % 750 == 0 then task.wait(); alive() end
	end
	mesh:RemoveUnused()
	local fixed = assert(AssetService:CreateEditableMeshAsync(Content.fromObject(mesh), {FixedSize=true}), "Fixed mesh budget unavailable: " .. id)
	entry.fixed = fixed
	alive()
	assert(fixed.FixedSize and #fixed:GetVertices() == #def.vertices and #fixed:GetFaces() == #def.triangles, "Fixed mesh topology mismatch: " .. id)
	mesh:Destroy(); entry.dynamic = nil
	assert(fixed:GetCenter().Magnitude < 0.0001, "Imported chunk is not centered")
	local part = AssetService:CreateMeshPartAsync(Content.fromObject(fixed))
	entry.template = part
	alive()
	part.Name = id; part.Anchored = true
	part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
	part.Color = Color3.new(1,1,1); part.Material = Enum.Material.SmoothPlastic
	return true
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
	local owned: {any} = {}
	local result: any = {folder=folder, meshes=meshes, placements=0, triangles=0}
	local closed = false
	function result.destroy()
		if closed then return end
		closed = true
		folder:Destroy()
		for _, entry in ipairs(owned) do release(entry) end
		table.clear(owned); table.clear(templates); table.clear(meshes)
	end
	local function acquire(def: any): any
		local entry: any = nil
		for _, candidate in ipairs(entries) do
			if candidate.references > 0 and sameGeometry(candidate.geometry, def) then
				entry = candidate; break
			end
		end
		local isBuilder = entry == nil
		if isBuilder then
			local geometry = {}
			for _, field in ipairs(geometryFields) do geometry[field] = copyArray(def[field]) end
			entry = {geometry=geometry, references=0, state="building"}
			table.insert(entries, entry)
		end
		entry.references += 1
		table.insert(owned, entry) -- Register before any allocation/yield.
		if isBuilder then
			local ok, problem = pcall(build, entry, def.id)
			entry.state = if ok then "ready" else "failed"
			entry.problem = problem
			if not ok or entry.references == 0 then dispose(entry) end
		else
			while entry.state == "building" and not closed do task.wait() end
		end
		assert(not closed, "Preview construction cancelled")
		assert(entry.state == "ready", tostring(entry.problem))
		return entry
	end
	local ok, problem = pcall(function()
		if onAllocated then onAllocated(result) end
		for _, def in ipairs(data.meshes) do
			assert(not closed, "Preview construction cancelled")
			local entry = acquire(def)
			templates[def.id] = entry.template
			centers[def.id] = entry.center
			table.insert(meshes, entry.fixed)
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
		assert(not closed, "Preview construction cancelled")
	end)
	if not ok then result.destroy(); error(tostring(problem)) end
	return result
end
return Preview
