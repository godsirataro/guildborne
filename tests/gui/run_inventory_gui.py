"""Inventory native-source callbacks/layout intent in a narrow simulation, not engine proof."""
from pathlib import Path
import subprocess,tempfile
ROOT=Path(__file__).resolve().parents[2]
def q(s):return '[====['+s+']====]'
paths=['src/shared/Config/Art.luau','src/shared/Config/VisualAssets.luau','src/shared/Config/Localization.luau','src/client/UI/AssetImage.luau','src/client/UI/DesignSystem/Theme.luau']
paths += ['src/client/UI/Components/'+n+'.luau' for n in ['RegalOrnament','GuildbornePanel','GuildborneButton','EquipmentSlot','InventoryPane']]
code='local Runtime=(function()\n'+(ROOT/'tests/gui/runtime.luau').read_text()+'\nend)()\nlocal env,connections=Runtime.environment()\nsetmetatable(env,{__index=getfenv()})\n'
code+=r'''
local function dim(a,b,c,d)return {a,b,c,d,X={Scale=a,Offset=b},Y={Scale=c,Offset=d}}end
env.UDim2={new=dim,fromOffset=function(x,y)return dim(0,x,0,y)end,fromScale=function(x,y)return dim(x,0,y,0)end}
local oldNew=env.Instance.new
env.Instance.new=function(class)
 local o=oldNew(class)
 function o:IsA(name)return self.ClassName==name or (name=="GuiObject" and table.find({"Frame","ScrollingFrame","TextButton","TextLabel","ImageLabel","ViewportFrame"},self.ClassName)~=nil)end
 function o:FindFirstChildOfClass(name)for _,c in ipairs(self.children)do if c:IsA(name)then return c end end end
 local oldDestroy=o.Destroy
 function o:Destroy()oldDestroy(self);if self.Parent then local index=table.find(self.Parent.children,self);if index then table.remove(self.Parent.children,index)end end end
 return o
end
local modules,cache,tree={},{},{}
local function node(path)local c=tree;for p in path:gmatch("[^/]+")do if not c[p]then c[p]={Parent=c}end;c=c[p]end;return c end
'''
for p in paths:code+='modules[node('+q(p[:-5])+')]='+q((ROOT/p).read_text(encoding='utf-8-sig'))+'\n'
code+='modules[node("src/client/UI/ItemViewport")]=[[return function(parent) local v=Instance.new("Frame");v.Size=UDim2.fromOffset(80,80);v.Parent=parent;return v end]]\n'
code+='modules[node("src/client/UI/Components/InventoryActorPreview")]=[[return function(parent) local v=Instance.new("Frame");v.Name="SimulatedPreview";v.Size=UDim2.fromScale(1,1);v.Parent=parent;local host=Instance.new("Frame");host.Name="InventoryActorPreview";host.Parent=v;local stage=Instance.new("Frame");stage.Name="PortraitStage";stage.Parent=host;local compass=Instance.new("Frame");compass.Parent=stage;local axis=Instance.new("Frame");axis.Name="SimulatedCompassAxis";axis.Parent=compass;local viewport=Instance.new("ViewportFrame");viewport.Name="ActorViewport";viewport.Parent=host;local fallback=Instance.new("TextLabel");fallback.Name="PreviewUnavailable";fallback.Parent=host;return {destroy=function()v:Destroy()end}end]]\n'
code+='env.game={ReplicatedStorage={Shared=node("src/shared")}}\nenv.UI=node("src/client/UI")\n'
code+=r'''
env.require=function(target)if cache[target]then return cache[target]end;assert(modules[target],"unmapped module");local fn=assert(loadstring(modules[target]));setfenv(fn,setmetatable({script=target},{__index=env}));cache[target]=fn();return cache[target]end
'''
code+='local test=assert(loadstring('+q((ROOT/'tests/gui/inventory_pane_behavior.luau').read_text(encoding='utf-8-sig'))+'));setfenv(test,env);test()\n'
with tempfile.TemporaryDirectory(prefix='inventory-gui-') as folder:
 p=Path(folder)/'run.luau';p.write_text(code,encoding='utf-8');raise SystemExit(subprocess.run([str(ROOT/'.tools/luau/luau.exe'),str(p)],cwd=ROOT).returncode)

