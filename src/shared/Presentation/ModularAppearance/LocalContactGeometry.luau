--!strict
-- Read-only solid separation of actual convex Blocks, not arbitrary mesh bounds.
-- Pure arrays API runs without Roblox globals. Native wrapper rejects Wedge/Mesh.
-- Gap is zero for overlapping solids, including containment; this is NOT penetration
-- depth or distance between the surfaces of a box contained inside another box.
local Geometry = {}
type Vec = {number}
type Box = {center: Vec, axes: {Vec}, halfExtents: Vec}
local AXIS_TOLERANCE = 1e-5
local MAX_COMPONENT = 1e9
local MIN_EXTENT = 1e-12 -- Bounded double-precision domain, far below native Part sizes.
local edges = {{1,5},{2,6},{3,7},{4,8},{1,3},{2,4},{5,7},{6,8},{1,2},{3,4},{5,6},{7,8}}

local function add(a: Vec,b: Vec): Vec return {a[1]+b[1],a[2]+b[2],a[3]+b[3]} end
local function sub(a: Vec,b: Vec): Vec return {a[1]-b[1],a[2]-b[2],a[3]-b[3]} end
local function mul(a: Vec,s: number): Vec return {a[1]*s,a[2]*s,a[3]*s} end
local function dot(a: Vec,b: Vec): number return a[1]*b[1]+a[2]*b[2]+a[3]*b[3] end
local function cross(a: Vec,b: Vec): Vec
	return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}
end
local function norm(a: Vec): number return math.sqrt(dot(a,a)) end
local function finite(value: any): boolean
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function vector(value: any): boolean
	return type(value) == "table" and #value == 3 and finite(value[1]) and finite(value[2]) and finite(value[3])
		and math.abs(value[1]) <= MAX_COMPONENT and math.abs(value[2]) <= MAX_COMPONENT and math.abs(value[3]) <= MAX_COMPONENT
end
local function invalid(status: string): any
	-- No fabricated finite distance for an unsupported shape or invalid input.
	return {supported=false,status=status,gap=nil,intersects=nil,measurement="CONVEX_BLOCK_SOLID_SEPARATION"}
end

local function box(value: any): (Box?,string?)
	if type(value) ~= "table" or not vector(value.center) or not vector(value.halfExtents)
		or type(value.axes) ~= "table" or #value.axes ~= 3 then return nil,"INVALID_BOX_INPUT" end
	for i=1,3 do
		if value.halfExtents[i] <= 0 or not vector(value.axes[i]) then return nil,"INVALID_EXTENT_OR_AXIS" end
		if value.halfExtents[i] < MIN_EXTENT then return nil,"EXTENT_BELOW_NUMERIC_RANGE" end
		if math.abs(norm(value.axes[i])-1) > AXIS_TOLERANCE then return nil,"NON_UNIT_AXIS" end
	end
	for i=1,2 do for j=i+1,3 do
		if math.abs(dot(value.axes[i],value.axes[j])) > AXIS_TOLERANCE then return nil,"NON_ORTHOGONAL_AXES" end
	end end
	if dot(cross(value.axes[1],value.axes[2]),value.axes[3]) <= 0 then return nil,"LEFT_HANDED_FRAME" end
	-- Repair only admitted floating-point frame drift, never a shear/skew input.
	local x = mul(value.axes[1],1/norm(value.axes[1]))
	local rawY = sub(value.axes[2],mul(x,dot(x,value.axes[2])))
	local y = mul(rawY,1/norm(rawY)); local z = cross(x,y)
	return {center={value.center[1],value.center[2],value.center[3]},axes={x,y,z},
		halfExtents={value.halfExtents[1],value.halfExtents[2],value.halfExtents[3]}},nil
end

local function vertices(b: Box): {Vec}
	local result: {Vec} = {}
	for _, x in ipairs({-1,1}) do for _, y in ipairs({-1,1}) do for _, z in ipairs({-1,1}) do
		table.insert(result,add(b.center,add(mul(b.axes[1],b.halfExtents[1]*x),
			add(mul(b.axes[2],b.halfExtents[2]*y),mul(b.axes[3],b.halfExtents[3]*z)))))
	end end end
	return result
end

local function closestPoint(point: Vec,b: Box): Vec
	local delta = sub(point,b.center); local result = b.center
	for i=1,3 do result = add(result,mul(b.axes[i],math.clamp(dot(delta,b.axes[i]),-b.halfExtents[i],b.halfExtents[i]))) end
	return result
end

local function closestSegments(p: Vec,q: Vec,r: Vec,s: Vec): (Vec,Vec)
	local d1,d2,offset = sub(q,p),sub(s,r),sub(p,r)
	local a,e = dot(d1,d1),dot(d2,d2)
	local t,u = 0,0
	if a == 0 and e == 0 then return p,r end
	if a == 0 then u = math.clamp(dot(d2,offset)/e,0,1)
	else
		local c = dot(d1,offset)
		if e == 0 then t = math.clamp(-c/a,0,1)
		else
			local b,f = dot(d1,d2),dot(d2,offset)
			local normal = cross(d1,d2); local denominator = dot(normal,normal)
			-- Cross-product form avoids subtracting two almost equal a*e and b*b.
			if denominator > 0 then t = math.clamp(dot(cross(d2,offset),normal)/denominator,0,1) end
			u = (b*t+f)/e
			if u < 0 then u = 0; t = math.clamp(-c/a,0,1)
			elseif u > 1 then u = 1; t = math.clamp((b-c)/a,0,1) end
		end
	end
	return add(p,mul(d1,t)),add(r,mul(d2,u))
end

local function measure(a: Box,b: Box): any
	local delta = sub(b.center,a.center)
	local maxSeparation = -math.huge
	local function axisSeparation(axis: Vec)
		local length = norm(axis)
		if length == 0 then return end -- Parallel-edge cross product is not an axis.
		local unit = mul(axis,1/length)
		local radius = 0
		for i=1,3 do radius += a.halfExtents[i]*math.abs(dot(unit,a.axes[i])) + b.halfExtents[i]*math.abs(dot(unit,b.axes[i])) end
		maxSeparation = math.max(maxSeparation,math.abs(dot(delta,unit))-radius)
	end
	for i=1,3 do axisSeparation(a.axes[i]); axisSeparation(b.axes[i]) end
	for i=1,3 do for j=1,3 do axisSeparation(cross(a.axes[i],b.axes[j])) end end
	local scale = math.max(1,norm(a.halfExtents),norm(b.halfExtents),norm(delta))
	local tolerance = scale*1e-9 + math.max(norm(a.center),norm(b.center))*8e-15
	if maxSeparation <= 0 then
		return {supported=true,status=if maxSeparation < -tolerance then "INTERSECTING" else "TOUCHING",
			gap=0,intersects=true,witnessA=nil,witnessB=nil,witnessKind="NOT_COMPUTED_FOR_OVERLAP",
			numericalTolerance=tolerance,axisAdmissionTolerance=AXIS_TOLERANCE,measurement="CONVEX_BLOCK_SOLID_SEPARATION"}
	end
	local av,bv = vertices(a),vertices(b)
	local minimum = math.huge; local witnessA: Vec? = nil; local witnessB: Vec? = nil
	local function consider(pa: Vec,pb: Vec)
		local difference = sub(pa,pb); local squared = dot(difference,difference)
		if squared < minimum then minimum = squared; witnessA = pa; witnessB = pb end
	end
	-- Every disjoint convex-polyhedron closest pair lies on vertex/face or edge/edge features.
	for _, point in ipairs(av) do consider(point,closestPoint(point,b)) end
	for _, point in ipairs(bv) do consider(closestPoint(point,a),point) end
	for _, ae in ipairs(edges) do for _, be in ipairs(edges) do
		local pa,pb = closestSegments(av[ae[1]],av[ae[2]],bv[be[1]],bv[be[2]])
		consider(pa,pb)
	end end
	local gap = math.sqrt(minimum)
	if not finite(gap) then return invalid("NUMERIC_FAILURE") end
	return {supported=true,status=if gap <= tolerance then "NEAR_CONTACT" else "SEPARATED",gap=gap,
		intersects=false,witnessA=witnessA,witnessB=witnessB,witnessKind="CLOSEST_SURFACE_PAIR",
		numericalTolerance=tolerance,axisAdmissionTolerance=AXIS_TOLERANCE,measurement="CONVEX_BLOCK_SOLID_SEPARATION"}
end

function Geometry.BoxGap(first: any,second: any): any
	local ok,result = pcall(function()
		local a,aError = box(first); if not a then return invalid(aError :: string) end
		local b,bError = box(second); if not b then return invalid(bError :: string) end
		return measure(a,b)
	end)
	if not ok then return invalid("INVALID_BOX_INPUT") end
	return result
end

function Geometry.MeasureParts(first: any,second: any): any
	local function read(part: any): (any?,string?)
		if typeof(part) ~= "Instance" or not part:IsA("BasePart") then return nil,"BASEPART_REQUIRED" end
		if not part:IsA("Part") or part.ClassName ~= "Part" or part.Shape ~= Enum.PartType.Block then return nil,"UNSUPPORTED_NON_BLOCK_GEOMETRY" end
		if part.Transparency >= 1 or part.LocalTransparencyModifier >= 1 then return nil,"PART_NOT_VISIBLE" end
		for _, child in ipairs(part:GetDescendants()) do
			if child:IsA("DataModelMesh") then return nil,"UNSUPPORTED_MESH_GEOMETRY" end
		end
		local function array(v: Vector3): Vec return {v.X,v.Y,v.Z} end
		return {center=array(part.Position),axes={array(part.CFrame.RightVector),array(part.CFrame.UpVector),array(part.CFrame.ZVector)},
			halfExtents=array(part.Size/2)},nil
	end
	local ok,result = pcall(function()
		local a,aError = read(first); if not a then return invalid(aError :: string) end
		local b,bError = read(second); if not b then return invalid(bError :: string) end
		return Geometry.BoxGap(a,b)
	end)
	if not ok then return invalid("INVALID_NATIVE_INPUT") end
	return result
end

return Geometry
