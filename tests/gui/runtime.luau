--!nocheck
-- Minimal deterministic simulation for callback/state tests, never engine/layout evidence.
local Runtime = {}
function Runtime.environment()
 local connections = {}
 local function signal()
  local listeners = {}
  return {
   Connect = function(_, callback)
    local connection = {Connected = true, callback = callback}
    function connection:Disconnect() self.Connected = false end
    table.insert(listeners, connection); table.insert(connections, connection)
    return connection
   end,
   Fire = function(_, ...)
    for _, connection in ipairs(table.clone(listeners)) do
     if connection.Connected then connection.callback(...) end
    end
   end,
  }
 end
 local methods = {}
 function methods:SetAttribute(key, value) self.attributes[key] = value end
 function methods:GetAttribute(key) return self.attributes[key] end
 function methods:GetPropertyChangedSignal(key)
  if not self.signals[key] then self.signals[key] = signal() end
  return self.signals[key]
 end
 function methods:GetChildren() return table.clone(self.children) end
 function methods:FindFirstChild(name)
  for _, child in ipairs(self.children) do if child.Name == name then return child end end
  return nil
 end
 function methods:Destroy()
  if self.destroyed then return end
  self.Destroying:Fire(); self.destroyed = true
  for _, child in ipairs(table.clone(self.children)) do child:Destroy() end
 end
 local function new(class)
  local object = {ClassName = class, Name = class, children = {}, attributes = {}, signals = {}, AbsoluteSize = {X = 800, Y = 600}, Visible = true, IsLoaded = false}
  for _, key in ipairs({"MouseEnter", "MouseLeave", "SelectionGained", "SelectionLost", "InputBegan", "InputEnded", "Activated", "Destroying"}) do object[key] = signal() end
  return setmetatable(object, {__index = methods, __newindex = function(t, key, value)
   rawset(t, key, value)
   if key == "Parent" and value then table.insert(value.children, t) end
  end})
 end
 local function vector(x, y, z)
  return setmetatable({X = x, Y = y, Z = z, Magnitude = math.sqrt(x*x+y*y)}, {
   __mul=function(a,b) return vector(a.X*b,a.Y*b) end,
   __sub=function(a,b) return vector(a.X-b.X,a.Y-b.Y) end,
  })
 end
 local function color(r, g, b)
  return {R = r, G = g, B = b, Lerp = function(self, other, alpha) return color(self.R + (other.R-self.R)*alpha, self.G+(other.G-self.G)*alpha, self.B+(other.B-self.B)*alpha) end}
 end
 local enum = setmetatable({}, {__index = function(t, key)
  local group = setmetatable({}, {__index = function(_, item) return key .. "." .. item end}); rawset(t, key, group); return group
 end})
 return {
  Instance = {new = new}, Enum = enum,
  ColorSequence = {new = function(...) return {...} end},
  Color3 = {new = color, fromRGB = function(r,g,b) return color(r/255,g/255,b/255) end},
  Vector2 = {new = vector}, Vector3 = {new = vector},
  UDim = {new = function(scale, offset) return {Scale=scale, Offset=offset} end},
  UDim2 = {new = function(...) return {...} end, fromScale = function(x,y) return {x,0,y,0} end, fromOffset = function(x,y) return {0,x,0,y} end},
 }, connections
end
return Runtime
