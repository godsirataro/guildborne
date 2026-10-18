"""Scoped source checks; this candidate's Studio acceptance belongs to the controller."""
from pathlib import Path
import datetime,hashlib,json,subprocess,sys
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];TOOLS=Path('C:/Work/MySelf/Guildborne/.tools')
commands=[
 ('sync',[sys.executable,'tools/sync_novice_road_art.py','--check']),
 ('geometry',[sys.executable,str(HERE/'check_geometry.py')]),
 ('compile',[str(TOOLS/'luau/luau-compile.exe'),'--null','review/NoviceRoadKit.luau','src/server/Services/NoviceRoadArt.luau','tests/studio_novice_road_probe.luau']),
 ('types',[str(TOOLS/'luau-lsp/luau-lsp.exe'),'analyze','--platform=roblox','--definitions='+str(TOOLS/'luau-lsp/globalTypes.d.luau'),'review/NoviceRoadKit.luau','src/server/Services/NoviceRoadArt.luau','tests/studio_novice_road_probe.luau']),
 ('diff',['git','diff','--check']),
]
receipts=[]
for name,cmd in commands:
 started=datetime.datetime.now(datetime.timezone.utc).isoformat();r=subprocess.run(cmd,cwd=ROOT,capture_output=True)
 stdout=HERE/(name+'.stdout.txt');stderr=HERE/(name+'.stderr.txt');stdout.write_bytes(r.stdout);stderr.write_bytes(r.stderr)
 receipts.append(dict(name=name,command=cmd,cwd=str(ROOT),startedUtc=started,exitCode=r.returncode,stdout=stdout.name,stderr=stderr.name,stdoutSha256=hashlib.sha256(r.stdout).hexdigest(),stderrSha256=hashlib.sha256(r.stderr).hexdigest()));print(name,r.returncode)
(HERE/'check-receipts.json').write_bytes((json.dumps(receipts,indent=2)+'\n').encode())
if any(r['exitCode'] for r in receipts):raise SystemExit(1)
