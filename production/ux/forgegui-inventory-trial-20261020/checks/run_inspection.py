"""Actual GUI source with existing narrow runtime; not native rendering evidence."""
from pathlib import Path
import subprocess,tempfile
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
runner=ROOT/'tests/gui/run_inventory_gui.py'
# Reuse the unchanged loader, replacing only its documented viewport stub.
source=runner.read_text(encoding='utf-8')
scope={'__file__':str(runner)}
exec(source.split("code+='local test=")[0],scope)
code=scope['code']
code=code.replace('return function(parent) local v=Instance.new("Frame");v.Size=UDim2.fromOffset(80,80);v.Parent=parent;return v end',
    'return function(parent,id,edge) local v=Instance.new("Frame");v.Name="ViewportStub";v:SetAttribute("ItemId",id);v.Size=UDim2.fromOffset(edge or 80,edge or 80);v.Parent=parent;return v end')
baseline=(ROOT/'tests/gui/inventory_pane_behavior.luau').read_text(encoding='utf-8-sig')
fixture=baseline.split('test("medium first viewport')[0]
fixture=fixture.replace('binding="Account bound",stats=', 'binding="Account bound",comparison="Comparison fixture",assignment="Assigned to player",stats=')
zero_fixture=fixture[fixture.index('local function make('):].replace('local function make(', 'local function makeZero(').replace('if i==2 then 123 else nil','if i==2 then 0 else nil')
fixture+=zero_fixture
tests=fixture+(HERE/'inspection_behavior.luau').read_text(encoding='utf-8')
code+='local test=assert(loadstring('+scope['q'](tests)+'));setfenv(test,env);test()\n'
code+='modules[node("src/client/UI/ItemViewport")]='+scope['q']((ROOT/'src/client/UI/ItemViewport.luau').read_text(encoding='utf-8'))+'\ncache[node("src/client/UI/ItemViewport")]=nil\n'
code+=r'''
local oldVector=env.Vector3.new
env.Vector3.new=function(x,y,z)
 local v=oldVector(x,y,z);local length=math.sqrt(x*x+y*y+z*z)
 v.Magnitude=length;v.Unit=oldVector(x/length,y/length,z/length);return v
end
modules[node("src/shared/Data/ItemVisuals")]=[[return function(id)
 if id=="missing" then return nil end
 local m=Instance.new("Model")
 function m:GetBoundingBox()return {Position=Vector3.new(2,3,4)},{Magnitude=6}end
 return m
end]]
local cameraTest=assert(loadstring([[
local Viewport=require(UI.ItemViewport)
local p=Instance.new("Frame");assert(Viewport(p,"missing")==nil and #p:GetChildren()==0)
local count=1
for _,case in ipairs({{nil,80},{256,256},{0,16},{1000,512},{math.huge,80},{0/0,80}})do
 local v=Viewport(p,"stone",case[1]);assert(v.Size.X.Offset==case[2] and v.Size.Y.Offset==case[2])
 local c=v.CurrentCamera;assert(c.FieldOfView==35 and c.Parent==v)
 local position,target=c.CFrame[1],c.CFrame[2]
 assert(target.X==2 and target.Y==3 and target.Z==4)
 local expected=3/math.sin(math.rad(17.5))*1.12
 local dx,dy,dz=position.X-2,position.Y-3,position.Z-4
 assert(math.abs(math.sqrt(dx*dx+dy*dy+dz*dz)-expected)<1e-7)
 assert(math.abs(dy/dx-.4)<1e-7 and math.abs(dz/dx+3)<1e-7)
 assert(v:GetAttribute("ItemId")=="stone");count+=1
end
p:Destroy();print("ACTUAL_ITEM_VIEWPORT_TESTS "..count.." passed; stub geometry/camera arithmetic, not pixels")
]]));setfenv(cameraTest,env);cameraTest()
'''
with tempfile.TemporaryDirectory(prefix='inspection-gui-') as folder:
    entry=Path(folder)/'run.luau';entry.write_text(code,encoding='utf-8')
    raise SystemExit(subprocess.run([str(ROOT/'.tools/luau/luau.exe'),str(entry)],cwd=ROOT).returncode)
