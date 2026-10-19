"""Exercise the actual Bootstrap gate; this is not native movement evidence."""
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
source = (ROOT / 'src/server/ServerBootstrap.server.luau').read_text(encoding='utf-8-sig')
begin = '-- BEGIN continuous walking eligibility: read-only, synchronous server policy.'
end = '-- END continuous walking eligibility.'
assert source.count(begin) == source.count(end) == 1
gate = source.split(begin, 1)[1].split(end, 1)[0]
template = Path(__file__).with_name('walking_gate_cases.luau').read_text(encoding='utf-8-sig')
assert template.count('-- ACTUAL_GATE') == 1
target = ROOT / 'build/walking-gate-current.luau'
target.parent.mkdir(exist_ok=True)
target.write_text(template.replace('-- ACTUAL_GATE', gate), encoding='utf-8', newline='\n')
exe = ROOT / '.tools/luau/luau.exe'
subprocess.run([str(exe), str(target)], cwd=ROOT, check=True)
