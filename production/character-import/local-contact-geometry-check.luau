--!strict
-- Return a reusable pure-math test function. Optional native=true creates only
-- disposable unparented Instances to check read-only shape admission; no actor edits.
return function(G: any,native: boolean?): any
	local cases: {string} = {}
	local function check(label: string,condition: boolean) assert(condition,label); table.insert(cases,label) end
	local function near(a: number,b: number,tolerance: number?): boolean return math.abs(a-b) <= (tolerance or 1e-8) end
	local function box(x: number,y: number,z: number,hx: number?,hy: number?,hz: number?): any
		return {center={x,y,z},axes={{1,0,0},{0,1,0},{0,0,1}},halfExtents={hx or 1,hy or 1,hz or 1}}
	end
	local function rz(angle: number): {{number}}
		return {{math.cos(angle),math.sin(angle),0},{-math.sin(angle),math.cos(angle),0},{0,0,1}}
	end
	local function distance(a: {number},b: {number}): number
		return math.sqrt((a[1]-b[1])^2+(a[2]-b[2])^2+(a[3]-b[3])^2)
	end
	local function boundary(point: {number},b: any): boolean
		local onFace = false
		for i=1,3 do
			local axis = b.axes[i]
			local v = (point[1]-b.center[1])*axis[1]+(point[2]-b.center[2])*axis[2]+(point[3]-b.center[3])*axis[3]
			if math.abs(v) > b.halfExtents[i]+1e-7 then return false end
			if near(math.abs(v),b.halfExtents[i],1e-7) then onFace = true end
		end
		return onFace
	end
	local function separation(label: string,a: any,b: any,expected: number,tolerance: number?): any
		local result = G.BoxGap(a,b)
		check(label.."_gap",result.supported == true and near(result.gap,expected,tolerance))
		if expected > 0 then
			check(label.."_disjoint",result.intersects == false)
			check(label.."_witness_distance",result.witnessA ~= nil and result.witnessB ~= nil and near(distance(result.witnessA,result.witnessB),result.gap,tolerance))
			check(label.."_surface_witnesses",boundary(result.witnessA,a) and boundary(result.witnessB,b))
		end
		local reverse = G.BoxGap(b,a)
		check(label.."_symmetry",reverse.supported == true and near(reverse.gap,result.gap,tolerance))
		return result
	end
	separation("parallel_faces",box(0,0,0),box(3,0,0),1)
	separation("diagonal_corners",box(0,0,0),box(3,4,5),math.sqrt(14))
	for _, delta in ipairs({{2,0,0},{2,2,0},{2,2,2}}) do
		local result = separation("touch_"..table.concat(delta,"_"),box(0,0,0),box(delta[1],delta[2],delta[3]),0)
		check("touch_intersection_"..table.concat(delta,"_"),result.intersects and result.status == "TOUCHING")
	end
	local overlap = separation("overlap",box(0,0,0),box(1,.5,-.2),0)
	check("overlap_classification",overlap.intersects and overlap.status == "INTERSECTING")
	local contained = separation("containment",box(0,0,0,3,4,5),box(.1,.2,.3),0)
	check("containment_is_solid_overlap_not_surface_distance",contained.intersects and contained.witnessA == nil and contained.witnessB == nil)
	local rotated = box(1+math.sqrt(2)+.5,0,0); rotated.axes = rz(math.pi/4)
	separation("rotated_vertex_to_face",box(0,0,0),rotated,.5)
	local crossing = box(0,0,.6,3,.1,.1); crossing.axes = rz(math.pi/2)
	separation("crossed_edges_no_vertex_face_minimum",box(0,0,0,3,.1,.1),crossing,.4)
	crossing.axes = rz(math.pi/4)
	separation("oblique_crossed_edges",box(0,0,0,3,.1,.1),crossing,.4)
	local nearlyParallel = box(0,3,0,3,1,1); nearlyParallel.axes = rz(1e-10)
	separation("nearly_parallel",box(0,0,0,3,1,1),nearlyParallel,1,1e-8)
	separation("tiny_positive_extents",box(0,0,0,1e-12,1e-12,1e-12),box(3e-12,0,0,1e-12,1e-12,1e-12),1e-12,1e-20)
	separation("large_translation",box(1000000,-2000000,3000000),box(1000003,-1999996,3000005),math.sqrt(14),1e-7)
	-- Independent axis-aligned analytic oracle across a deterministic grid.
	for x=-3,3 do for y=-3,3 do
		local expected = math.sqrt(math.max(0,math.abs(x)-1.2)^2+math.max(0,math.abs(y)-1.8)^2+.4^2)
		local result = G.BoxGap(box(0,0,0,.5,.7,.2),box(x,y,1,.7,1.1,.4))
		check("analytic_grid_"..x.."_"..y,result.supported and near(result.gap,expected))
	end end
	-- Common rigid transforms must preserve distance even for skew 3-D frames.
	local function transform(b: any,angle: number): any
		local ca,sa = math.cos(angle),math.sin(angle)
		local cb,sb = math.cos(.37),math.sin(.37)
		local function turn(v: {number}): {number}
			local x,y,z = ca*v[1]-sa*v[2],sa*v[1]+ca*v[2],v[3]
			return {x,cb*y-sb*z,sb*y+cb*z}
		end
		local c = turn(b.center); c[1]+=13; c[2]-=9; c[3]+=5
		return {center=c,axes={turn(b.axes[1]),turn(b.axes[2]),turn(b.axes[3])},halfExtents=table.clone(b.halfExtents)}
	end
	for i=1,12 do
		local a,b = transform(box(0,0,0,3,.1,.1),i*.21),transform(crossing,i*.21)
		separation("rigid_invariance_"..i,a,b,.4,1e-7)
	end
	local bad: {any} = {
		{label="zero_extent",value=box(0,0,0,0,1,1)},
		{label="negative_extent",value=box(0,0,0,-1,1,1)},
		{label="underflow_extent",value=box(0,0,0,1e-200,1,1)},
		{label="nan_center",value=box(0/0,0,0)},
		{label="infinite_center",value=box(math.huge,0,0)},
		{label="out_of_numeric_range",value=box(2e9,0,0)},
		{label="non_table",value="invalid"},
	}
	local shear = box(0,0,0); shear.axes[2]={.6,.8,0}; table.insert(bad,{label="shear",value=shear})
	local left = box(0,0,0); left.axes[3]={0,0,-1}; table.insert(bad,{label="left_handed",value=left})
	local scaled = box(0,0,0); scaled.axes[1]={2,0,0}; table.insert(bad,{label="scaled_axis",value=scaled})
	for _, entry in ipairs(bad) do
		local result = G.BoxGap(entry.value,box(0,0,0))
		check("reject_"..entry.label,result.supported == false and result.gap == nil)
	end
	check("reject_missing_input",G.BoxGap(nil,nil).supported == false)
	local drift = box(3,0,0); drift.axes[1]={1+1e-7,0,0}
	check("admitted_frame_roundoff_repaired",near(G.BoxGap(box(0,0,0),drift).gap,1))
	local nativeCases = 0
	if native then
		local first = Instance.new("Part"); first.Size = Vector3.new(2,2,2)
		local second = Instance.new("Part"); second.Size = first.Size; second.CFrame = CFrame.new(3,0,0)
		local wedge = Instance.new("WedgePart")
		local initial = {frame=first.CFrame,size=first.Size,transparency=first.Transparency,anchored=first.Anchored,secondFrame=second.CFrame}
		local ok,err = pcall(function()
			check("native_actual_block_gap",near(G.MeasureParts(first,second).gap,1))
			check("native_wedge_explicitly_unsupported",G.MeasureParts(first,wedge).status == "UNSUPPORTED_NON_BLOCK_GEOMETRY")
			local mesh = Instance.new("SpecialMesh"); mesh.Parent = first
			check("native_mesh_not_bounds",G.MeasureParts(first,second).status == "UNSUPPORTED_MESH_GEOMETRY")
			mesh:Destroy(); first.Transparency = 1
			check("native_hidden_part_rejected",G.MeasureParts(first,second).status == "PART_NOT_VISIBLE")
			first.Transparency = initial.transparency
			check("native_readonly_properties",first.CFrame == initial.frame and first.Size == initial.size and first.Transparency == initial.transparency
				and first.Anchored == initial.anchored and second.CFrame == initial.secondFrame)
			return true
		end)
		first:Destroy(); second:Destroy(); wedge:Destroy(); assert(ok,err); nativeCases = 5
	end
	return {passed=#cases,cases=cases,nativeCases=nativeCases,actualGameContactAcceptance=false,wedgeSupported=false}
end
