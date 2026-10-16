--!strict
-- Pure, bounded input contract for the standalone Greenwood art preview.
local Quality = {}
Quality.ProtectedNames = table.freeze({Island=true, Landing=true, BossRise=true, RootAscent=true,
	EncounterMarkers=true, ReviewRoutes=true, GreenwoodSpawn=true, ["Central City"]=true})
function Quality.isDecoration(name: string, className: string): boolean
	return className == "Part" and (name == "Trunk" or name == "Canopy")
end
local function finite(n: any): boolean
	return type(n) == "number" and n == n and math.abs(n) < math.huge
end
local function array(t: any, length: number)
	assert(type(t) == "table" and #t == length, "Invalid numeric array")
	for i=1,length do assert(finite(t[i]), "Nonfinite geometry") end
end
function Quality.validate(data: any): boolean
	assert(type(data) == "table" and data.schemaVersion == 1, "Unknown world quality schema")
	assert(type(data.sourceMeshSha256) == "string" and #data.sourceMeshSha256 == 64
		and data.sourceMeshSha256:match("^[0-9a-f]+$"), "Missing source mesh hash")
	assert(type(data.expectedArtNames) == "table" and #data.expectedArtNames > 0 and #data.expectedArtNames <= 512, "Missing art names")
	assert(data.minArtPlacements == #data.expectedArtNames, "Art count mismatch")
	local names: {[string]: boolean} = {}
	for _,name in ipairs(data.expectedArtNames) do
		assert(type(name)=="string" and #name>0 and #name<=128 and not names[name], "Invalid or duplicate art name")
		names[name]=true
	end
	assert(type(data.colliders)=="table" and #data.colliders>0 and #data.colliders<=512, "Invalid collider count")
	local colliderNames: {[string]: boolean} = {}
	for _,c in ipairs(data.colliders) do
		assert(type(c.name)=="string" and #c.name>0 and #c.name<=128 and not colliderNames[c.name], "Invalid collider name")
		colliderNames[c.name]=true
		assert(c.kind=="Part" or c.kind=="WedgePart", "Unsupported collider class")
		array(c.size,3); array(c.cframe,12)
		for _,s in ipairs(c.size) do assert(s>=.05 and s<=128, "Collider size out of bounds") end
		local f=c.cframe
		-- A proper rigid basis prevents scaled/sheared frames bypassing corner bounds.
		for r=0,2 do for s=0,2 do
			local dot=0
			for k=4,6 do dot+=f[k+r*3]*f[k+s*3] end
			assert(math.abs(dot-(if r==s then 1 else 0))<.001, "Nonrigid collider transform")
		end end
		local det=f[4]*(f[8]*f[12]-f[9]*f[11])-f[5]*(f[7]*f[12]-f[9]*f[10])+f[6]*(f[7]*f[11]-f[8]*f[10])
		assert(math.abs(det-1)<.001, "Reflected collider transform")
		for _,x in ipairs({-c.size[1]/2,c.size[1]/2}) do
			for _,y in ipairs({-c.size[2]/2,c.size[2]/2}) do
				for _,z in ipairs({-c.size[3]/2,c.size[3]/2}) do
					-- WedgePart's upper -Z box corners are empty space, not geometry.
					if c.kind=="WedgePart" and y>0 and z<0 then continue end
					local wx=f[1]+f[4]*x+f[5]*y+f[6]*z
					local wy=f[2]+f[7]*x+f[8]*y+f[9]*z
					local wz=f[3]+f[10]*x+f[11]*y+f[12]*z
					assert(math.abs(wx)<=112 and wy>=-8 and wy<=100 and wz>=1298 and wz<=1528, "Collider outside Greenwood")
				end
			end
		end
	end
	return true
end
return table.freeze(Quality)
