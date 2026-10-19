"""Exercise real Pane serialization with a yielding preview stub, not engine evidence."""
from pathlib import Path
import runpy
import subprocess
import tempfile
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[3]
captured = []


def capture(argv, **kwargs):
    captured.append(Path(argv[1]).read_text(encoding="utf-8"))
    return subprocess.CompletedProcess(argv, 0)


# Reuse the checked-in simulation's loader and stubs, without executing its process.
with patch("subprocess.run", capture):
    try:
        runpy.run_path(str(ROOT / "tests/gui/run_inventory_gui.py"))
    except SystemExit as result:
        assert result.code == 0
assert len(captured) == 1
code = captured[0]
needle = 'local v=Instance.new("Frame");v.Name="SimulatedPreview"'
assert code.count(needle) == 1
code = code.replace(needle, 'if InventoryPreviewHook then InventoryPreviewHook(parent) end;' + needle)
needle = 'destroy=function()v:Destroy()end'
assert code.count(needle) == 1
code = code.replace(needle, 'destroy=function()v:Destroy();if InventoryDisposeHook then InventoryDisposeHook() end end')
code += r'''
local extra = assert(loadstring([====[
local Pane = require(UI.Components.InventoryPane)
local function paneOf(stage)
 local node=stage
 while node and node.Name~="InventoryPane" do node=node.Parent end
 assert(node);return node
end
local function model()
 return {actorId="player",actorName="Player",actors={},slots={},items={{id="one",name="Sword",onSelect=function()end}},filters={}}
end
local root, previewCalls, disposed
local function begin()
 previewCalls=0;disposed=0
 InventoryDisposeHook=function()disposed+=1 end
 InventoryPreviewHook=function(stage)
  previewCalls+=1
  if previewCalls==1 then root=paneOf(stage);coroutine.yield("constructing-preview") end
 end
 local thread=coroutine.create(function()return Pane(Instance.new("Frame"),model())end)
 local ok, checkpoint=coroutine.resume(thread)
 assert(ok and checkpoint=="constructing-preview")
 return thread
end
local thread=begin()
for _,width in ipairs({920,1000,744})do
 root.AbsoluteSize={X=width,Y=600};root:GetPropertyChangedSignal("AbsoluteSize"):Fire()
end
assert(previewCalls==1,"resize entered another constructor while first draw yielded")
local ok, result=coroutine.resume(thread);assert(ok,result)
assert(result==root and coroutine.status(thread)=="dead")
assert(previewCalls==2 and disposed==1,"resize notifications must coalesce into one followup")
local names={}
for _,child in ipairs(root:GetChildren())do
 assert(not names[child.Name],"duplicate pane child: "..child.Name);names[child.Name]=true
end
assert(#root:GetChildren()==6 and names.ItemGrid and names.SelectedActorLoadout and not names.ActorSelection)
assert(root:FindFirstChild("InventoryHeading").Size.X.Offset==744*.55,"latest width lost")
root:Destroy();assert(disposed==2)
print("PASS yielded draw coalesces three resizes without duplicate children and uses latest width")

thread=begin()
root.AbsoluteSize={X=1000,Y=600};root:GetPropertyChangedSignal("AbsoluteSize"):Fire()
root:Destroy()
ok,result=coroutine.resume(thread);assert(ok,result)
assert(coroutine.status(thread)=="dead" and previewCalls==1 and disposed==1)
assert(#root:GetChildren()==0,"destroyed pane received new children")
root:GetPropertyChangedSignal("AbsoluteSize"):Fire();assert(previewCalls==1)
InventoryPreviewHook=nil;InventoryDisposeHook=nil
print("PASS destruction during yielded draw disposes late preview and cancels pending redraw")
]====]));setfenv(extra,env);extra()
'''
with tempfile.TemporaryDirectory(prefix="inventory-reentrant-") as folder:
    path = Path(folder) / "run.luau"
    path.write_text(code, encoding="utf-8")
    raise SystemExit(subprocess.run([str(ROOT / ".tools/luau/luau.exe"), str(path)], cwd=ROOT).returncode)
