"""Run real local checks with immutable source hashes; never Studio proof."""
from pathlib import Path
import subprocess,json,hashlib,time,argparse
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];T=ROOT/'.tools'
ap=argparse.ArgumentParser();ap.add_argument('--run',required=True);ap.add_argument('--baseline',action='store_true');args=ap.parse_args()
assert args.run.isalnum()
OUT=HERE/('checks-'+args.run);OUT.mkdir(exist_ok=False)
sourcepaths=['src/server/Services/WorldQualitySlice.luau','src/shared/Config/WorldQuality.luau','tests/world_quality.luau']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
inputs={p:sha(ROOT/p) for p in sourcepaths};inputs[Path(__file__).relative_to(ROOT).as_posix()]=sha(Path(__file__))
wrapper=ROOT/'tests/_ironveil_final_lifecycle.luau';assert not wrapper.exists()
wrapper.write_bytes(('local run=require("./world_quality")\nrun([====['+(ROOT/sourcepaths[0]).read_text()+']====])\n').encode())
commands=[('contract',[str(T/'luau/luau.exe'),'tests/world_quality.luau']),('lifecycle',[str(T/'luau/luau.exe'),str(wrapper)])]
commands.extend([('compile',[str(T/'luau/luau-compile.exe'),'--null',*sourcepaths]),('types',[str(T/'luau-lsp/luau-lsp.exe'),'analyze','--platform=roblox','--sourcemap=build/sourcemap.json','--definitions='+str(T/'luau-lsp/globalTypes.d.luau'),*sourcepaths])])
if args.baseline:commands.append(('baseline',['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File','tools/validate.ps1']))
receipts=[]
try:
 for name,command in commands:
  start=time.monotonic()
  with (OUT/(name+'.stdout.txt')).open('wb') as out,(OUT/(name+'.stderr.txt')).open('wb') as err:
   result=subprocess.run(command,cwd=ROOT,stdout=out,stderr=err,timeout=1200)
  receipt=dict(name=name,command=command,exitCode=result.returncode,seconds=time.monotonic()-start,stdoutSha256=sha(OUT/(name+'.stdout.txt')),stderrSha256=sha(OUT/(name+'.stderr.txt')))
  receipts.append(receipt);print(name,result.returncode,flush=True)
finally:
 wrapper.unlink()
 unchanged=all(sha(ROOT/p)==h for p,h in inputs.items())
 (OUT/'receipts.json').write_text(json.dumps(dict(scope='LOCAL_SUBPROCESS_NOT_STUDIO',inputHashes=inputs,inputsUnchanged=unchanged,checks=receipts),indent=2)+'\n')
assert unchanged and all(r['exitCode']==0 for r in receipts)
