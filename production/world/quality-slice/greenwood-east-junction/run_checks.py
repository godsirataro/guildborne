from pathlib import Path
import subprocess,json,hashlib,time
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];T=ROOT/'.tools'
paths=['src/server/Services/WorldQualitySlice.luau','src/shared/Config/WorldQuality.luau','tests/world_quality.luau']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
inputs={p:sha(ROOT/p) for p in paths}
harness=HERE/'lifecycle.luau'
harness.write_text('local run=require("../../../../tests/world_quality")\nrun([====['+(ROOT/paths[0]).read_text()+']====])\n',encoding='utf-8')
commands=[('contract',[str(T/'luau/luau.exe'),'tests/world_quality.luau']),('lifecycle',[str(T/'luau/luau.exe'),str(harness)]),('compile',[str(T/'luau/luau-compile.exe'),'--null',*paths]),('types',[str(T/'luau-lsp/luau-lsp.exe'),'analyze','--platform=roblox','--sourcemap=build/sourcemap.json','--definitions='+str(T/'luau-lsp/globalTypes.d.luau'),*paths])]
checks=[]
for name,cmd in commands:
 r=subprocess.run(cmd,cwd=ROOT,capture_output=True);(HERE/(name+'.stdout')).write_bytes(r.stdout);(HERE/(name+'.stderr')).write_bytes(r.stderr);checks.append(dict(name=name,command=cmd,exitCode=r.returncode,stdoutSHA256=sha(HERE/(name+'.stdout')),stderrSHA256=sha(HERE/(name+'.stderr'))));print(name,r.returncode)
unchanged=all(sha(ROOT/p)==h for p,h in inputs.items())
(HERE/'checks.json').write_text(json.dumps(dict(status='LOCAL_NOT_NATIVE',sourceHashes=inputs,inputsUnchanged=unchanged,checks=checks),indent=2)+'\n')
assert unchanged and all(c['exitCode']==0 for c in checks)
