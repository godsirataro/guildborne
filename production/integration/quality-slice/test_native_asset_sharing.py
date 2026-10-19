"""Execute the real importer against allocation/lifetime mocks; not Studio proof."""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
SOURCE = Path(__file__).with_name("NativeAssetPreview.luau")
HARNESS = r'''
local resources = {}
local dynamicCount, fixedCount, templateCount = 0, 0, 0
local failFixed, failPart, async = false, false, false
local vec = {}
local vm = {__index=function(self,k)
 if k=="Magnitude" then return math.sqrt(self.x*self.x+self.y*self.y+self.z*self.z) end
 if k=="Unit" then return self/self.Magnitude end
 return vec[k]
end}
local function v(x,y,z) return setmetatable({x=x,y=y,z=z},vm) end
vm.__add=function(a,b)return v(a.x+b.x,a.y+b.y,a.z+b.z)end
vm.__sub=function(a,b)return v(a.x-b.x,a.y-b.y,a.z-b.z)end
vm.__div=function(a,b)return v(a.x/b,a.y/b,a.z/b)end
vm.__mul=function(a,b)if type(b)=="number"then return v(a.x*b,a.y*b,a.z*b)end;return v(a.x*b.x,a.y*b.y,a.z*b.z)end
function vec:Min(b)return v(math.min(self.x,b.x),math.min(self.y,b.y),math.min(self.z,b.z))end
function vec:Max(b)return v(math.max(self.x,b.x),math.max(self.y,b.y),math.max(self.z,b.z))end
function vec:Cross(b)return v(self.y*b.z-self.z*b.y,self.z*b.x-self.x*b.z,self.x*b.y-self.y*b.x)end
local function equalv(a,b) return (a-b).Magnitude<1e-10 end
local cm = {__mul=function(a,b)return {left=a,right=b}end}
local function cf(...)return setmetatable({values={...}},cm)end
local function resource(kind)
 local r={kind=kind,dead=false,destroyCount=0,attributes={}}
 function r:Destroy()
  assert(not self.dead,"double destroy: "..self.kind)
  self.dead=true;self.destroyCount+=1
  if self.kind=="Folder" then
   for _,item in ipairs(resources) do if item.Parent==self and not item.dead then item:Destroy() end end
  end
 end
 function r:SetAttribute(k,value)self.attributes[k]=value end
 table.insert(resources,r)
 return r
end
local function mesh(fixed,source)
 local m=resource(if fixed then "fixed" else "dynamic")
 m.FixedSize=fixed;m.vertices={};m.faces={};m.colors={};m.normals={};m.faceColors={};m.faceNormals={}
 if source then
  for _,k in ipairs({"vertices","faces","colors","normals","faceColors","faceNormals"})do m[k]=table.clone(source[k])end
 end
 function m:AddVertex(value)table.insert(self.vertices,value);return #self.vertices end
 function m:AddColor(value,alpha)table.insert(self.colors,{value,alpha});return #self.colors end
 function m:AddTriangle(a,b,c)table.insert(self.faces,{a,b,c});return #self.faces end
 function m:AddNormal(value)table.insert(self.normals,value);return #self.normals end
 function m:SetFaceColors(face,value)self.faceColors[face]=value end
 function m:SetFaceNormals(face,value)self.faceNormals[face]=value end
 function m:RemoveUnused()self.compacted=true end
 function m:GetVertices()return self.vertices end
 function m:GetFaces()return self.faces end
 function m:GetCenter()
  local lo,hi=self.vertices[1],self.vertices[1]
  for _,p in ipairs(self.vertices)do lo=lo:Min(p);hi=hi:Max(p)end
  return (lo+hi)/2
 end
 return m
end
local function part(source,kind)
 local p=resource(kind);p.mesh=source;p.Size=v(2,4,1)
 function p:Clone()
  assert(not self.dead and not self.mesh.dead,"cloned dead template")
  local c=part(self.mesh,"placement")
  c.Size=self.Size;c.Anchored=self.Anchored;c.CanCollide=self.CanCollide
  c.CanTouch=self.CanTouch;c.CanQuery=self.CanQuery;c.Color=self.Color;c.Material=self.Material
  return c
 end
 return p
end
local asset={}
function asset:CreateEditableMesh()dynamicCount+=1;return mesh(false)end
function asset:CreateEditableMeshAsync(source,options)
 assert(source.compacted and options.FixedSize)
 if async then coroutine.yield("fixed") end
 if failFixed then failFixed=false;return nil end
 fixedCount+=1;return mesh(true,source)
end
function asset:CreateMeshPartAsync(source)
 assert(source.FixedSize and not source.dead)
 if async then coroutine.yield("part") end
 if failPart then failPart=false;error("injected part failure")end
 templateCount+=1;return part(source,"template")
end
local env={
 game={PlaceId=0,GameId=0,GetService=function(_,name)
  if name=="AssetService"then return asset end
  if name=="RunService"then return {IsStudio=function()return true end} end
  error(name)
 end},
 Vector3={new=v},Color3={new=function(...)return {...}end},CFrame={new=cf},
 Enum={Material={SmoothPlastic="smooth"}},Content={fromObject=function(o)return o end},
 Instance={new=resource},task={wait=function()if async then coroutine.yield("wait")end end},
}
setmetatable(env,{__index=getfenv()})
local module=assert(loadstring(SOURCE));setfenv(module,env);local Preview=module()
local function definition(id)
 return {id=id,vertices={{10,2,3},{12,2,3},{10,6,3}},colors={{0.2,0.3,0.4}},triangles={{1,2,3}},faceColors={1}}
end
local function data(def)
 return {schemaVersion=1,meshes={def},placements={{meshId=def.id,name="placed-"..def.id,scale={2,3,4},cframe={20,30,40,1,0,0,0,1,0,0,0,1}}}}
end
local function placed(handle)
 for _,r in ipairs(resources)do if r.Parent==handle.folder and r.kind=="placement"then return r end end
 error("no placement")
end
local function noLeaks()
 for _,r in ipairs(resources)do assert(r.dead,"leaked "..r.kind)end
end
local count=0
local function pass(name)count+=1;print("PASS "..name)end

-- Different IDs and different placements share only the identical geometry.
local a=Preview.create(data(definition("first")),{})
local bData=data(definition("other-id"));bData.placements[1].cframe[1]=80
local b=Preview.create(bData,{})
assert(dynamicCount==1 and fixedCount==1 and templateCount==1)
assert(a.meshes[1]==b.meshes[1] and a.triangles==1 and b.triangles==1)
local pa,pb=placed(a),placed(b)
assert(pa.attributes.SourceMeshId=="first" and pb.attributes.SourceMeshId=="other-id")
assert(pa.CFrame.left.values[1]==20 and pb.CFrame.left.values[1]==80)
assert(equalv(pa.CFrame.right.values[1],v(22,12,12)) and equalv(pa.Size,v(4,12,4)))
assert(pa.CanCollide==false and pa.CanTouch==false and pa.CanQuery==false)
assert(equalv(a.meshes[1].normals[1],v(0,0,1)))
assert(a.meshes[1].colors[1][1][1]==0.2 and a.meshes[1].faceColors[1][1]==1)
pass("exact geometry sharing preserves IDs, transforms, normals, colors and flags")
local retained=b.meshes[1]
a.destroy();a.destroy();assert(not retained.dead and not pb.dead)
b.destroy();b.destroy();assert(retained.dead);noLeaks()
pass("first handle destroyed first; idempotent final release")
a=Preview.create(data(definition("x")),{});b=Preview.create(data(definition("x")),{})
retained=a.meshes[1];b.destroy();assert(not retained.dead);a.destroy();noLeaks()
pass("second handle destroyed first")

-- Each field participates, including tiny float changes that rounded keys lose.
for _,field in ipairs({"vertices","colors","triangles","faceColors"})do
 local original=definition("same-id");original.colors[2]={0.9,0.8,0.7}
 local changed=definition("same-id");changed.colors[2]={0.9,0.8,0.7}
 if field=="vertices"then changed.vertices[1][1]+=1e-12
 elseif field=="colors"then changed.colors[1][1]+=1e-12
 elseif field=="triangles"then changed.triangles[1]={1,3,2}
 else changed.faceColors[1]=2 end
 a=Preview.create(data(original),{});b=Preview.create(data(changed),{})
 assert(a.meshes[1]~=b.meshes[1],field.." incorrectly shared")
 a.destroy();b.destroy();noLeaks();pass("same ID different "..field.." stays independent")
end

-- Snapshot identity cannot be rewritten by caller mutation after first import.
local mutable=definition("mutable")
a=Preview.create(data(mutable),{});mutable.colors[1][1]=0.8
b=Preview.create(data(mutable),{});assert(a.meshes[1]~=b.meshes[1])
a.destroy();b.destroy();noLeaks();pass("caller mutation does not poison cache identity")

-- New allocation failure releases only this handle's references.
a=Preview.create(data(definition("keep")),{});retained=a.meshes[1]
local failData=data(definition("reuse"));local unique=definition("new");unique.colors[1][1]=0.9
table.insert(failData.meshes,unique);failFixed=true
local ok=pcall(Preview.create,failData,{})
assert(not ok and not retained.dead and not placed(a).dead)
b=Preview.create(data(unique),{});b.destroy();a.destroy();noLeaks()
pass("fixed allocation failure retains other handle and permits retry")
failPart=true;ok=pcall(Preview.create,data(definition("part-fail")),{})
assert(not ok);noLeaks();pass("template failure releases dynamic and fixed resources")

local function start(d)
 local job={}
 job.thread=coroutine.create(function()
  job.ok,job.value=pcall(Preview.create,d,{},function(h)job.handle=h end)
 end)
 return job
end
local function step(job)
 local good,event=coroutine.resume(job.thread);assert(good,tostring(event));return event
end
local function finish(job)
 for _=1,30 do if coroutine.status(job.thread)=="dead"then return end;step(job)end
 error("coroutine did not settle")
end
async=true
local before=dynamicCount
local ja=start(data(definition("pending-a")));assert(step(ja)=="fixed")
local jb=start(data(definition("pending-b")));assert(step(jb)=="wait")
ja.handle.destroy();finish(ja);finish(jb)
assert(not ja.ok and jb.ok and dynamicCount==before+1)
assert(not jb.value.meshes[1].dead)
jb.value.destroy();noLeaks();pass("pending reuse survives builder handle cancellation")

ja=start(data(definition("pending-a")));assert(step(ja)=="fixed")
jb=start(data(definition("pending-b")));assert(step(jb)=="wait")
jb.handle.destroy();finish(jb);finish(ja)
assert(ja.ok and not jb.ok and not ja.value.meshes[1].dead)
ja.value.destroy();noLeaks();pass("pending waiter cancellation preserves builder")

ja=start(data(definition("all-cancel")));assert(step(ja)=="fixed")
jb=start(data(definition("all-cancel2")));assert(step(jb)=="wait")
ja.handle.destroy();jb.handle.destroy();finish(ja);finish(jb)
assert(not ja.ok and not jb.ok);noLeaks();pass("all cancelled during fixed allocation cleans late resource")

ja=start(data(definition("part-cancel")));assert(step(ja)=="fixed");assert(step(ja)=="part")
ja.handle.destroy();finish(ja);assert(not ja.ok);noLeaks()
pass("cancel during template allocation cleans late template")

ja=start(data(definition("fail-shared")));assert(step(ja)=="fixed")
jb=start(data(definition("fail-shared2")));assert(step(jb)=="wait")
failFixed=true;finish(ja);finish(jb);assert(not ja.ok and not jb.ok);noLeaks()
pass("pending shared allocation failure settles both waiters")
local emptyData=data(definition("last-mesh-wait"));emptyData.placements={}
ja=start(emptyData);assert(step(ja)=="fixed");assert(step(ja)=="part");assert(step(ja)=="wait")
ja.handle.destroy();finish(ja);assert(not ja.ok);noLeaks()
pass("cancellation after final mesh yield with no placements cannot report success")
local twelve=data(definition("last-placement-wait"))
for i=2,12 do twelve.placements[i]=table.clone(twelve.placements[1])end
ja=start(twelve);assert(step(ja)=="fixed");assert(step(ja)=="part");assert(step(ja)=="wait");assert(step(ja)=="wait")
ja.handle.destroy();finish(ja);assert(not ja.ok);noLeaks()
pass("cancellation after final placement yield cannot report success")
async=false
ok=pcall(Preview.create,data(definition("early-cancel")),{},function(h)h.destroy()end)
assert(not ok);noLeaks();pass("onAllocated cancellation before first resource")
print(string.format("%d importer mock behavior cases passed; Studio memory/import acceptance remains pending",count))
'''

if __name__ == "__main__":
    code = "local SOURCE=[====[" + SOURCE.read_text(encoding="utf-8-sig") + "]====]\n" + HARNESS
    with tempfile.TemporaryDirectory(prefix="guildborne-mesh-sharing-") as temp:
        script = Path(temp) / "run.luau"
        script.write_text(code, encoding="utf-8")
        raise SystemExit(subprocess.run([str(ROOT / ".tools/luau/luau.exe"), str(script)], cwd=ROOT).returncode)
