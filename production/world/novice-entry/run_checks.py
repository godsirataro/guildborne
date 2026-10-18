"""Record scoped local checks with exact stdout/stderr; never promotes them to Studio evidence."""
from pathlib import Path
import datetime,hashlib,json,subprocess,sys
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
TOOLS=Path('C:/Work/MySelf/Guildborne/.tools')
commands=[
 ('sync-check',[sys.executable,'tools/sync_novice_road_art.py','--check']),
 ('geometry-check',[sys.executable,str(HERE/'check_geometry.py')]),
 ('compile',[str(TOOLS/'luau/luau-compile.exe'),'--null','review/NoviceRoadKit.luau','src/server/Services/NoviceRoadArt.luau','tests/studio_novice_road_probe.luau']),
 ('types',[str(TOOLS/'luau-lsp/luau-lsp.exe'),'analyze','--platform=roblox','--definitions='+str(TOOLS/'luau-lsp/globalTypes.d.luau'),'review/NoviceRoadKit.luau','src/server/Services/NoviceRoadArt.luau','tests/studio_novice_road_probe.luau']),
 ('diff-check',['git','diff','--check']),
]
receipts=[]
for name,cmd in commands:
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();result=subprocess.run(cmd,cwd=ROOT,capture_output=True)
 out=HERE/(name+'.stdout.txt');err=HERE/(name+'.stderr.txt');out.write_bytes(result.stdout);err.write_bytes(result.stderr)
 receipts.append(dict(name=name,command=cmd,cwd=str(ROOT),startedUtc=start,exitCode=result.returncode,stdout=out.name,stderr=err.name,stdoutSha256=hashlib.sha256(result.stdout).hexdigest(),stderrSha256=hashlib.sha256(result.stderr).hexdigest()))
 print(name,result.returncode)
(HERE/'check-receipts.json').write_bytes((json.dumps(receipts,indent=2)+'\n').encode())
if any(r['exitCode'] for r in receipts):raise SystemExit(1)
