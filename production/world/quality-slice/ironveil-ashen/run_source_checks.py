"""Record compiler and pure/mocked checks, explicitly not Studio acceptance."""
from pathlib import Path
import subprocess,json,hashlib
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
TOOLS=Path('C:/Work/MySelf/Guildborne/.tools/luau')
source=ROOT/'src/server/Services/WorldQualitySlice.luau'
runner=ROOT/'build/ironveil-ashen-source-check.luau'
runner.parent.mkdir(exist_ok=True)
runner.write_bytes(('local test=require("../tests/world_quality")\ntest([====['+source.read_text()+']====])\n').encode())
inputs=['src/shared/Config/WorldQuality.luau','src/server/Services/WorldQualitySlice.luau','tests/world_quality.luau']
commands=[('compile',[str(TOOLS/'luau-compile.exe'),'--null',*inputs]),('contracts',[str(TOOLS/'luau.exe'),str(runner)])]
receipts=[]
for name,cmd in commands:
    r=subprocess.run(cmd,cwd=ROOT,capture_output=True)
    (HERE/(name+'.stdout.txt')).write_bytes(r.stdout)
    (HERE/(name+'.stderr.txt')).write_bytes(r.stderr)
    receipts.append(dict(name=name,command=cmd,exitCode=r.returncode,stdoutSha256=hashlib.sha256(r.stdout).hexdigest(),stderrSha256=hashlib.sha256(r.stderr).hexdigest()))
record=dict(status='LOCAL_SOURCE_CHECKS_NOT_STUDIO',inputs={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in inputs},runs=receipts)
(HERE/'source-checks.json').write_bytes((json.dumps(record,indent=2)+'\n').encode())
assert all(x['exitCode']==0 for x in receipts)
print('PASS compiler and pure/mocked lifecycle; Studio NOT_RUN')
