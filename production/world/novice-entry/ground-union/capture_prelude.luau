-- Offline geometry adapter only. It does not emulate physics, navigation or Roblox execution.
local vec = {}; vec.__index = vec
local function v(x,y,z) return setmetatable({X=x,Y=y,Z=z},vec) end
vec.__add=function(a,b)return v(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
vec.__sub=function(a,b)return v(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
vec.__mul=function(a,b)if type(a)=="number" then a,b=b,a end return v(a.X*b,a.Y*b,a.Z*b)end
local Vector3={new=v,zero=v(0,0,0)}
local cf={}; cf.__index=cf
local function frame(p,r)return setmetatable({Position=p,r=r},cf)end
local unit={1,0,0,0,1,0,0,0,1}
local CFrame={}
CFrame.new=function(x,y,z) if type(x)=="table" then return frame(x,unit)end return frame(v(x or 0,y or 0,z or 0),unit)end
local function rotate(r,p)return v(r[1]*p.X+r[2]*p.Y+r[3]*p.Z,r[4]*p.X+r[5]*p.Y+r[6]*p.Z,r[7]*p.X+r[8]*p.Y+r[9]*p.Z)end
cf.__mul=function(a,b)
 if getmetatable(b)==vec then return a.Position+rotate(a.r,b)end
 local r={};for i=0,2 do for j=1,3 do r[i*3+j]=0;for k=1,3 do r[i*3+j]+=a.r[i*3+k]*b.r[(k-1)*3+j]end end end
 return frame(a.Position+rotate(a.r,b.Position),r)
end
CFrame.Angles=function(x,y,z)
 local c,s=math.cos,math.sin
 return frame(v(0,0,0),{1,0,0,0,c(x),-s(x),0,s(x),c(x)})*frame(v(0,0,0),{c(y),0,s(y),0,1,0,-s(y),0,c(y)})*frame(v(0,0,0),{c(z),-s(z),0,s(z),c(z),0,0,0,1})
end
CFrame.identity=CFrame.new()
local Color3={fromRGB=function(r,g,b)return {R=r/255,G=g/255,B=b/255}end}
local Enum=setmetatable({},{__index=function(_,category)return setmetatable({},{__index=function(_,key)return category.."."..key end})end})
local UDim2={fromOffset=function(...)return {...}end,fromScale=function(...)return {...}end}
local all={};local methods={};local inst={}
inst.__index=function(self,k)
 if methods[k] then return methods[k] end
 if k=="Position" then return self.values.CFrame.Position end
 return self.values[k]
end
inst.__newindex=function(self,k,value)
 if k=="Position" then self.values.CFrame=frame(value,self.values.CFrame.r)
 else self.values[k]=value end
end
function methods:SetAttribute(k,value)self.attrs[k]=value end
function methods:GetAttribute(k)return self.attrs[k]end
function methods:GetChildren()local children={};for _,p in ipairs(all)do if p.Parent==self then table.insert(children,p)end end return children end
function methods:GetDescendants()local children={};local function visit(parent)for _,p in ipairs(parent:GetChildren())do table.insert(children,p);visit(p)end end visit(self);return children end
function methods:IsA(class)return self.ClassName==class or (class=="BasePart" and (self.ClassName=="Part" or self.ClassName=="WedgePart"))end
local Instance={new=function(class)
 assert(table.find({"Model","Part","WedgePart","BillboardGui","TextLabel"},class),"Unsupported offline class: "..class)
 local p=setmetatable({values={ClassName=class,Name=class,CFrame=CFrame.identity,Transparency=0,CastShadow=true,Shape="PartType.Block",Material="Material.Plastic"},attrs={}},inst);table.insert(all,p);return p
end}
