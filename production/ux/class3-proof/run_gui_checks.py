"""Execute actual ExpansionView source with a narrow UI double; not Studio evidence."""
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]


def quote(text):
    mark = "="
    while f"]{mark}]" in text:
        mark += "="
    return f"[{mark}[{text}]{mark}]"


def main():
    runtime = (ROOT / "tests/gui/runtime.luau").read_text(encoding="utf-8")
    view = (ROOT / "src/client/UI/ExpansionView.luau").read_text(encoding="utf-8")
    status = (ROOT / "src/client/UI/StatusPointView.luau").read_text(encoding="utf-8")
    availability = (ROOT / "src/client/UI/SkillAvailability.luau").read_text(encoding="utf-8")
    checks = (Path(__file__).parent / "gui_checks.luau").read_text(encoding="utf-8")
    code = "local Runtime=(function()\n" + runtime + "\nend)()\n"
    code += "local source=" + quote(view) + "\nlocal statusSource=" + quote(status) + "\n"
    code += "local env=Runtime.environment();setmetatable(env,{__index=getfenv()})\n"
    code += "local check=assert(loadstring(" + quote(checks) + "));setfenv(check,env)\n"
    code += "local gui=check()(source,statusSource,env," + quote(availability) + ")\n"
    code += '''local U=require("../../src/shared/Util/TableUtil")
local count=0
local function eq(a,b) assert(U.equal(a,b),"Values differ: "..tostring(a).." / "..tostring(b)) end
local function test(name,run) run();count+=1;print("PASS "..name) end
require("../../tests/class3_ui")(test,eq,gui)
print(count.." Class3 projection/UI-double checks passed; no native layout/device evidence.")
'''
    entry = ROOT / "build/agentic/class3_ui_gui_generated.luau"
    entry.parent.mkdir(parents=True, exist_ok=True)
    entry.write_text(code, encoding="utf-8")
    raise SystemExit(subprocess.run([str(ROOT / ".tools/luau/luau.exe"), str(entry)], cwd=ROOT).returncode)


if __name__ == "__main__":
    main()
