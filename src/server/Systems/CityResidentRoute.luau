--!strict
-- Pure bounded route reducer. Server integration owns world queries and presentation.
local M = {}
local PI = math.pi
local function finite(v: any): boolean
	return type(v) == "number" and v == v and math.abs(v) < math.huge
end
local function dense(t: any, limit: number): boolean
	if type(t) ~= "table" or #t > limit then return false end
	local count = 0
	for k in pairs(t) do
		if type(k) ~= "number" or k % 1 ~= 0 or k < 1 or k > #t then return false end
		count += 1
	end
	return count == #t
end
local function point(p: any): boolean
	return type(p) == "table" and finite(p.x) and finite(p.z)
		and math.abs(p.x) <= 1e6 and math.abs(p.z) <= 1e6
end
local function angle(a: number): number return (a + PI) % (2 * PI) - PI end
local function heading(x: number, z: number): number return math.atan2(-x, -z) end
local function validDt(dt: any): boolean return finite(dt) and dt > 0 end

function M.new(points: any, initialYaw: any, lookAt: any): (any, string?)
	if not dense(points, 8) or #points < 2 or not finite(initialYaw) or not point(lookAt) then
		return nil, "InvalidRoute"
	end
	local route, total = {}, 0
	for i, p in ipairs(points) do
		if not point(p) then return nil, "InvalidRoute" end
		route[i] = {x=p.x, z=p.z}
		if i > 1 then
			local prev = route[i-1]
			local length = math.sqrt((p.x-prev.x)^2 + (p.z-prev.z)^2)
			if length < .1 or length > 100 then return nil, "InvalidSegment" end
			total += length
		end
	end
	if total > 200 then return nil, "RouteTooLong" end
	local homeYaw = angle(initialYaw)
	local look = {x=lookAt.x, z=lookAt.z}
	local state: any = {x=route[1].x, z=route[1].z, yaw=homeYaw, phase="Rest", remaining=8,
		index=1, direction=1, moving=false, status="Rest"}
	local dead = false
	local function snapshot(s: any): any
		return {x=s.x,z=s.z,yaw=s.yaw,status=s.status,moving=s.moving,reason=s.reason}
	end
	local function advance(dt: number): any
		local s: any = table.clone(state)
		s.reason = nil
		s.moving = false
		if s.phase == "Rest" or s.phase == "Waiting" then
			s.remaining = math.max(0, s.remaining-dt)
			if s.remaining == 0 then
				if s.phase == "Waiting" then s.direction = -1 end
				s.phase = "Turning"
			end
		elseif s.phase == "Turning" or s.phase == "Looking" or s.phase == "HomeTurn" then
			local targetYaw = homeYaw
			if s.phase == "Turning" then
				local target = route[s.index+s.direction]
				targetYaw = heading(target.x-s.x,target.z-s.z)
			elseif s.phase == "Looking" then
				if (look.x-s.x)^2+(look.z-s.z)^2 > 1e-12 then targetYaw=heading(look.x-s.x,look.z-s.z)
				else targetYaw=s.yaw end
			end
			local delta = angle(targetYaw-s.yaw)
			local bound = PI/2*dt
			s.yaw = angle(s.yaw+math.clamp(delta,-bound,bound))
			if math.abs(delta) <= bound then
				if s.phase == "Turning" then s.phase="Walking"
				elseif s.phase == "Looking" then s.phase="Waiting";s.remaining=6
				else s.phase="Rest";s.remaining=8;s.direction=1 end
			end
		elseif s.phase == "Walking" then
			local target = route[s.index+s.direction]
			local dx,dz = target.x-s.x,target.z-s.z
			local distance = math.sqrt(dx*dx+dz*dz)
			local stride = math.min(3*dt,distance)
			if distance > 0 then s.x+=dx/distance*stride;s.z+=dz/distance*stride;s.moving=stride>0 end
			if distance <= stride then
				s.x=target.x;s.z=target.z;s.index+=s.direction
				if s.index == #route then s.phase="Looking"
				elseif s.index == 1 then s.phase="HomeTurn"
				else s.phase="Turning" end
			end
		end
		s.status=s.phase
		return s
	end
	local api = {}
	function api.snapshot(): any return snapshot(state) end
	function api.propose(dt: any): any
		if dead or not validDt(dt) then return snapshot(state) end
		return snapshot(advance(math.min(dt,.1)))
	end
	function api.step(dt: any, relevant: boolean, clear: boolean): any
		if dead then return snapshot(state) end
		if not validDt(dt) or relevant ~= true or clear ~= true then
			state.status="Paused";state.moving=false
			state.reason=if not validDt(dt) then "InvalidDt" elseif relevant ~= true then "Irrelevant" else "Blocked"
		else state=advance(math.min(dt,.1)) end
		return snapshot(state)
	end
	function api.destroy()
		dead=true;state.status="Destroyed";state.moving=false;state.reason=nil
	end
	return api, nil
end

-- Disk swept through XZ; the disk also conservatively encloses in-place turns.
-- Callers must supply visible furniture and actors even when CanQuery is false.
function M.sweptBlocked(from: any, to: any, radius: any, bottom: any, top: any, boxes: any): (boolean,string?)
	if not point(from) or not point(to) or not finite(radius) or radius <= 0 or radius > 10
		or not finite(bottom) or not finite(top) or top <= bottom or top-bottom > 20
		or not dense(boxes,512) then return true,"InvalidGeometry" end
	-- Validate the complete set before considering an early intersection.
	for _,b in ipairs(boxes) do
		if type(b) ~= "table" then return true,"InvalidGeometry" end
		for _,k in ipairs({"minX","maxX","minY","maxY","minZ","maxZ"}) do
			if not finite(b[k]) or math.abs(b[k]) > 1e6 then return true,"InvalidGeometry" end
		end
		if b.minX>b.maxX or b.minY>b.maxY or b.minZ>b.maxZ then return true,"InvalidGeometry" end
	end
	for _,b in ipairs(boxes) do
		if top >= b.minY and bottom <= b.maxY then
			local enter,leave=0,1
			local intersects=true
			for _,axis in ipairs({"X","Z"}) do
				local key=string.lower(axis)
				local origin,delta=from[key],to[key]-from[key]
				local lo,hi=b["min"..axis]-radius,b["max"..axis]+radius
				if math.abs(delta)<1e-12 then
					if origin<lo or origin>hi then intersects=false end
				else
					local a,c=(lo-origin)/delta,(hi-origin)/delta
					if a>c then a,c=c,a end
					enter=math.max(enter,a);leave=math.min(leave,c)
					if enter>leave then intersects=false end
				end
			end
			if intersects then return true,"Blocked" end
		end
	end
	return false,nil
end
return M
