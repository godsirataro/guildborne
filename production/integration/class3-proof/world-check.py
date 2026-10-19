"""Execute actual world adapter source in a small deterministic Luau fake host."""
from pathlib import Path
import subprocess
import sys
import tempfile
import re

root = Path(__file__).resolve().parents[3]
source = (root / "src/server/Services/HeroMentorWorld.luau").read_text(encoding="utf-8")
body = source[source.index("return function(deps:any):any"):]
fixture = Path(__file__).with_name("world-host.luau").read_text(encoding="utf-8")
script = fixture.replace("-- WORLD_FACTORY_SOURCE", "local makeWorld=(function()\n" + body + "\nend)()")
with tempfile.TemporaryDirectory(prefix="guildborne-world-check-") as directory:
    target = Path(directory) / "world-check.luau"
    target.write_text(script, encoding="utf-8")
    result = subprocess.run([sys.argv[1], str(target)], check=False)
    if result.returncode:
        raise SystemExit(result.returncode)
    cross = (root / "src/server/Services/CrosshavenWorld.luau").read_text(encoding="utf-8")
    delivery = cross[cross.index('   if e.pending and not e.deliveryBusy'):cross.index('   local data=s.record.data;local id=nextId(data)')]
    before_delivery = cross[cross.index('   if e.trial and e.trialCharacter~=player.Character'):cross.index('   if e.trial and e.trialProof and not e.pending')]
    api = cross[cross.index(' function S.Intent(player:Player'):cross.index(' function S.Destroy()')]
    stop = cross[cross.index(' local function stopActivity(e:any)'):cross.index(' function S.Remove(player:Player)')]
    repeat_line = next(line for line in cross.splitlines() if 'marker("RepeatMastery"' in line)
    repeat_callback = re.search(r'(function\(data:any\)local code=startMastery\(data\);.*?end end),function', repeat_line)
    assert repeat_callback, "Repeat callback extraction no longer matches; review fixture"
    cross_fixture = Path(__file__).with_name("world-crosshaven-host.luau").read_text(encoding="utf-8")
    cross_fixture = cross_fixture.replace('-- CROSS_STOP', stop).replace('-- CROSS_API', api)
    cross_fixture = cross_fixture.replace('-- CROSS_DELIVERY', delivery)
    cross_fixture = cross_fixture.replace('-- CROSS_PRE_DELIVERY', before_delivery)
    cross_fixture = cross_fixture.replace('-- CROSS_REPEAT', 'local repeatCallback=' + repeat_callback.group(1))
    target.write_text(cross_fixture, encoding="utf-8")
    raise SystemExit(subprocess.run([sys.argv[1], str(target)], check=False).returncode)
