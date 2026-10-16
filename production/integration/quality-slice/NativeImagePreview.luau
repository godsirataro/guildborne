--!strict
-- Exact source PNG pixels, packaged locally. Not a Roblox asset upload.
local AssetService = game:GetService("AssetService")
local ImagePreview = {}
function ImagePreview.create(data: any, root: Instance, onAllocated: ((any) -> ())?): any
	assert(game:GetService("RunService"):IsStudio() and game.PlaceId == 0 and game.GameId == 0)
	assert(data.schemaVersion == 1)
	local images: {[string]: any} = {}
	local connection: RBXScriptConnection? = nil
	local result: any = {count=0, bindings=0}
	local closed = false
	function result.destroy()
		closed = true
		if connection then connection:Disconnect(); connection=nil end
		for _, entry in pairs(images) do entry.image:Destroy() end
		table.clear(images)
	end
	local ok, problem = pcall(function()
		if onAllocated then onAllocated(result) end
		for _, def in ipairs(data.images) do
			assert(not closed, "Image construction cancelled")
			local size = Vector2.new(def.width, def.height)
			local pixels = buffer.create(def.width*def.height*4)
			local index = 0
			for _, run in ipairs(def.runs) do
				for _ = 1, run[1] do
					buffer.writeu32(pixels,index*4,run[2]); index+=1
					if index%32768 == 0 then task.wait(); assert(not closed, "Image construction cancelled") end
				end
			end
			assert(index == def.width*def.height, "Pixel stream length mismatch")
			local image = assert(AssetService:CreateEditableImage({Size=size}), "Image memory unavailable")
			images[def.key] = {image=image, slice=def.sliceCenter}
			image:WritePixelsBuffer(Vector2.zero,size,pixels)
			result.count+=1
		end
		local function bind(instance: Instance)
			if not (instance:IsA("ImageLabel") or instance:IsA("ImageButton")) then return end
			local key = instance:GetAttribute("QualityAssetKey")
			if type(key) ~= "string" then return end
			local entry = images[key]
			if not entry then return end
			instance.ImageContent = Content.fromObject(entry.image)
			instance.ImageTransparency = 0
			if entry.slice then
				instance.ScaleType = Enum.ScaleType.Slice
				instance.SliceCenter = Rect.new(table.unpack(entry.slice))
			end
			instance:SetAttribute("LocalImageBound", true)
			result.bindings+=1
		end
		connection = root.DescendantAdded:Connect(bind)
		for _, instance in ipairs(root:GetDescendants()) do bind(instance) end
	end)
	if not ok then result.destroy(); error(tostring(problem)) end
	return result
end
return ImagePreview
