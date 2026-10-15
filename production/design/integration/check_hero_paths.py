"""Execute current HeroService movement closures with controlled async mocks, not Studio.

The pure Luau CLI cannot require a Roblox service module. Extract exact source
closures into ignored build output; keep unique ordered boundaries fail-closed.
"""
import hashlib
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def extract(text, start, end):
    if text.count(start) != 1 or text.count(end) != 1:
        raise ValueError(f"HeroService extraction boundaries changed: {start!r} / {end!r}")
    first = text.index(start) + len(start)
    last = text.index(end)
    if first >= last:
        raise ValueError("HeroService extraction boundary order changed")
    return text[first:last]


def main():
    source = ROOT / "src/server/Services/HeroService.luau"
    source_bytes = source.read_bytes()
    text = source_bytes.decode("utf-8").replace("\r\n", "\n")
    invalidate = "local function invalidatePath" + extract(text, "local function invalidatePath", "local function appearance")
    movement = "\tlocal function recover" + extract(text, "\tlocal function recover", "\tlocal elapsed=0")
    character = "\tfunction service.Character" + extract(text, "\tfunction service.Character", "\tlocal function makeHero")
    reset = "\t\t\t\tif s.reset or " + extract(text, "\t\t\t\tif s.reset or ", "\n\t\t\t\tif #s.history==0")
    park = extract(text, "\t\t\t\t\tif not valid then\n", "\n\t\t\t\t\telse\n\t\t\t\t\t\tlocal remaining=")
    program = '''local run=require("../../tests/run_shared_combat_coordinator")
run(function(env)
local V,Vector3,CFrame,Enum,workspace,Pathfinding,task=env.V,env.Vector3,env.CFrame,env.Enum,env.workspace,env.Pathfinding,env.task
local s,h,root,sessions=env.s,env.h,env.root,env.sessions
local destroyed,shared=false,nil
local service={}
local function appearance()end
''' + invalidate + character + movement + '''
return {walk=walk,recover=recover,character=service.Character,reset=function()
''' + reset + '''
end,park=function()
''' + park + '''
end}
end)
'''
    output = ROOT / "build/agentic"
    output.mkdir(parents=True, exist_ok=True)
    harness = output / "gl2_hero_path_harness.luau"
    harness.write_text(program, encoding="utf-8")
    executable = ROOT / ".tools/luau/luau.exe"
    if not executable.is_file():
        executable = ROOT / ".tools/luau/luau"
    result = subprocess.run([str(executable), str(harness)], cwd=ROOT, capture_output=True, timeout=60)
    (output / "gl2_hero_path.stdout.log").write_bytes(result.stdout)
    (output / "gl2_hero_path.stderr.log").write_bytes(result.stderr)
    print("HeroService SHA256:", hashlib.sha256(source_bytes).hexdigest())
    print(result.stdout.decode("utf-8"), end="")
    print(result.stderr.decode("utf-8"), end="")
    if source.read_bytes() != source_bytes:
        raise RuntimeError("HeroService changed during check; rerun against stable source")
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
