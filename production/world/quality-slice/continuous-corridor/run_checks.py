from pathlib import Path
import subprocess,json,hashlib,sys
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];T=ROOT/'.tools'
source=(ROOT/'src/server/Services/WorldQualitySlice.luau').read_text(encoding='utf8')
wrapper=ROOT/'tests/_corridor_lifecycle.luau'
wrapper.write_bytes(('local run=require("./world_quality")\nrun([====['+source+']====])\n').encode())
commands=[('lifecycle',[str(T/'luau/luau.exe'),str(wrapper)]),('compile',[str(T/'luau/luau-compile.exe'),'--null','src/server/Services/WorldQualitySlice.luau','src/shared/Config/WorldQuality.luau','tests/world_quality.luau']),('types',[str(T/'luau-lsp/luau-lsp.exe'),'analyze','--platform=roblox','--sourcemap=build/sourcemap.json','--definitions='+str(T/'luau-lsp/globalTypes.d.luau'),'src/server/Services/WorldQualitySlice.luau','src/shared/Config/WorldQuality.luau','tests/world_quality.luau']),('diff',['git','diff','--check'])]
receipts=[]
try:
 for name,cmd in commands:
  r=subprocess.run(cmd,cwd=ROOT,capture_output=True);(HERE/(name+'.stdout.txt')).write_bytes(r.stdout);(HERE/(name+'.stderr.txt')).write_bytes(r.stderr);receipts.append(dict(name=name,command=cmd,exitCode=r.returncode,stdoutSha256=hashlib.sha256(r.stdout).hexdigest(),stderrSha256=hashlib.sha256(r.stderr).hexdigest()));print(name,r.returncode)
finally:wrapper.unlink()
(HERE/'check-receipts.json').write_bytes((json.dumps(receipts,indent=2)+'\n').encode())
if any(r['exitCode'] for r in receipts):raise SystemExit(1)
