"""Run real GUI Luau source in a narrow engine simulation; no Roblox acceptance claim."""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
MODULES = ["src/shared/Config/Art.luau", "src/shared/Config/VisualAssets.luau",
           "src/client/UI/AssetImage.luau", "src/client/UI/DesignSystem/Theme.luau"]
MODULES += [f"src/client/UI/Components/{name}.luau" for name in
            ("GuildborneButton", "GuildbornePanel", "HeaderBar", "TabBar", "TitleKeyboardFocus", "RegalOrnament", "TitleVista")]
MODULES += ["src/client/UI/SymbolIcon.luau", "src/shared/Data/UISymbols.luau"]
MODULES += ["src/client/UI/TitleView.luau", "src/shared/Config/Localization.luau"]
MODULES += ["src/shared/Data/JournalViewState.luau", "src/client/UI/EmptyState.luau",
            "src/shared/Data/CombatHudLayout.luau",
            "src/client/UI/QuestTrackerView.luau", "src/client/UI/Components/QualityAsset.luau",
            "src/client/UI/Components/JournalPane.luau", "src/client/UI/Components/WaypointBeacon.luau",
            "src/client/UI/Components/CombatChrome.luau"]
# Only Title orchestration dependencies are stubbed; component source and Title are real.
STUBS = {
    "MenuRouter": "return {register=function() end,focusCurrent=function() Services.FocusCalls=(Services.FocusCalls or 0)+1 end}",
    "CompanyPreview": '''return function(parent)
 local frame=Instance.new("Frame");frame.Name="CompanyPreview";frame.Parent=parent
 return {update=function() parent:SetAttribute("PreviewUpdates",(parent:GetAttribute("PreviewUpdates") or 0)+1) end,
 destroy=function() parent:SetAttribute("PreviewDestroys",(parent:GetAttribute("PreviewDestroys") or 0)+1);frame:Destroy() end}
end''',
    "SettingsControls": '''return function(parent)
 local frame=Instance.new("Frame");frame.Parent=parent
 return {frame=frame,refresh=function() end}
end''',
}

def quote(text):
    mark = "="
    while f"]{mark}]" in text:
        mark += "="
    return f"[{mark}[{text}]{mark}]"

def main():
    prefix = (ROOT / "tests/gui/runtime.luau").read_text(encoding="utf-8")
    code = "local Runtime=(function()\n" + prefix + "\nend)()\n"
    code += "local env,connections=Runtime.environment()\nsetmetatable(env,{__index=getfenv()})\nlocal modules,cache={},{}\nlocal tree={}\n"
    code += '''local function node(path)
 local current=tree
 for part in string.gmatch(path,"[^/]+") do
  if not current[part] then current[part]={Parent=current} end
  current=current[part]
 end
 return current
end
'''
    for path in MODULES:
        code += f"modules[node({quote(path.removesuffix('.luau'))})]={quote((ROOT/path).read_text(encoding='utf-8'))}\n"
    for name, stub in STUBS.items():
        code += f"modules[node({quote('src/client/UI/'+name)})]={quote(stub)}\n"
    code += '''env.game={ReplicatedStorage={Shared=node("src/shared")},GetService=function(_,name) return env.Services[name] end}
env.UI=node("src/client/UI")
env.require=function(target)
 if cache[target] then return cache[target] end
 assert(modules[target],"Unmapped module")
 local scope=setmetatable({script=target},{__index=env})
 local fn=assert(loadstring(modules[target]));setfenv(fn,scope)
 cache[target]=fn();return cache[target]
end
'''
    code += "local run=assert(loadstring(" + quote((ROOT/"tests/gui/behavior.luau").read_text(encoding="utf-8")) + "));setfenv(run,env);run()\n"
    code += "local gameplay=assert(loadstring(" + quote((ROOT/"tests/gui/gameplay_behavior.luau").read_text(encoding="utf-8")) + "));setfenv(gameplay,env);gameplay()\n"
    code += "local waypoint=assert(loadstring(" + quote((ROOT/"tests/gui/waypoint_behavior.luau").read_text(encoding="utf-8")) + "));setfenv(waypoint,env);waypoint()\n"
    code += "local tracker=assert(loadstring(" + quote((ROOT/"tests/gui/tracker_polish.luau").read_text(encoding="utf-8")) + "));setfenv(tracker,env);tracker()\n"
    with tempfile.TemporaryDirectory(prefix="guildborne-gui-tests-") as folder:
        entry = Path(folder)/"run.luau"
        entry.write_text(code, encoding="utf-8")
        result = subprocess.run([str(ROOT/".tools/luau/luau.exe"), str(entry)], cwd=ROOT)
        raise SystemExit(result.returncode)

if __name__ == "__main__":
    main()
