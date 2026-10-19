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
  -- Native isolated-label probe (2026-10-20): enabling scaling enables wrapping;
  -- disabling wrapping disables scaling. Keep these outside the raw table so
  -- repeated assignments also reach __newindex. This is not text measurement.
  local textObject = class == "TextLabel" or class == "TextButton" or class == "TextBox"
  local textProperties = {TextScaled = false, TextWrapped = false}
  for _, key in ipairs({"ChildAdded", "AncestryChanged", "MouseEnter", "MouseLeave", "SelectionGained", "SelectionLost", "InputBegan", "InputEnded", "Activated", "Destroying"}) do object[key] = signal() end
  return setmetatable(object, {__index = function(_, key)
   if textObject and textProperties[key] ~= nil then return textProperties[key] end
   if textObject and key == "TextSize" then return 8 end
   return methods[key]
  end, __newindex = function(t, key, value)
   if textObject and textProperties[key] ~= nil then
    textProperties[key] = value
    if key == "TextScaled" and value then textProperties.TextWrapped = true end
    if key == "TextWrapped" and not value then textProperties.TextScaled = false end
    return
   end
   rawset(t, key, value)
   if key == "Parent" and value then table.insert(value.children, t); value.ChildAdded:Fire(t) end
  end})
 end
 local function vector(x, y, z)
  return setmetatable({X = x, Y = y, Z = z, Magnitude = math.sqrt(x*x+y*y)}, {
   __mul=function(a,b) return vector(a.X*b,a.Y*b,if a.Z then a.Z*b else nil) end,
   __sub=function(a,b) return vector(a.X-b.X,a.Y-b.Y,if a.Z and b.Z then a.Z-b.Z else nil) end,
   __add=function(a,b) return vector(a.X+b.X,a.Y+b.Y,if a.Z and b.Z then a.Z+b.Z else nil) end,
  })
 end
 local function color(r, g, b)
  return {R = r, G = g, B = b, Lerp = function(self, other, alpha) return color(self.R + (other.R-self.R)*alpha, self.G+(other.G-self.G)*alpha, self.B+(other.B-self.B)*alpha) end}
 end
 local enum = setmetatable({}, {__index = function(t, key)
  local group = setmetatable({}, {__index = function(_, item) return key .. "." .. item end}); rawset(t, key, group); return group
 end})
 enum.ContextActionPriority = {High = {Value = 3000}}
 local actions = {bindings = {}}
 function actions:BindActionAtPriority(name, callback, touch, priority, key)
  self.bindings[name] = {callback=callback,touch=touch,priority=priority,key=key}
 end
 function actions:UnbindAction(name) self.bindings[name] = nil end
 local input = {focused = nil}
 function input:GetFocusedTextBox() return self.focused end
 local function transform(...) return setmetatable({...},{__mul=function(a,b) return transform(a,b) end}) end
 return {
  Services = {ContextActionService=actions,UserInputService=input,GuiService={MenuIsOpen=false}},
  Instance = {new = new}, Enum = enum,
  CFrame = {lookAt = function(a,b) return {a,b} end,new=transform,Angles=transform},
  ColorSequence = {new = function(...) return {...} end},
  Color3 = {new = color, fromRGB = function(r,g,b) return color(r/255,g/255,b/255) end},
  Vector2 = {new = vector,zero=vector(0,0)}, Vector3 = {new = vector},
  Rect = {new=function(x1,y1,x2,y2) return {Min=vector(x1,y1),Max=vector(x2,y2)} end},
  UDim = {new = function(scale, offset) return {Scale=scale, Offset=offset} end},
  UDim2 = {new = function(...) return {...} end, fromScale = function(x,y) return {x,0,y,0} end, fromOffset = function(x,y) return {0,x,0,y} end},
 }, connections
end
return Runtime
