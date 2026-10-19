"""Capture scoped read-only checks; keep failures and empty raw streams."""
from pathlib import Path
import argparse,hashlib,json,subprocess,time
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
ap=argparse.ArgumentParser();ap.add_argument('--run',required=True);ap.add_argument('--preflight',action='store_true');args=ap.parse_args()
assert args.run.isalnum()
out=HERE/('checks-'+args.run);out.mkdir(exist_ok=False)
commands=([('forge', ['python','tools/agentic/forge.py','validate']),('studio', ['python','tools/agentic/studio.py','validate']),('adapters', ['python','tools/agentic/studio.py','verify'])] if args.preflight else [('syntax',['python','-c',"from pathlib import Path; p=Path('production/world/quality-slice/ironveil-ore-yard'); files=list(p.glob('*.py')); [compile(f.read_bytes(),str(f),'exec') for f in files]; print('Python syntax:',len(files),'files')"]),('whitespace',['git','diff','--check'])])
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
if not args.preflight:commands.append(('scope',['python','production/world/quality-slice/ironveil-ore-yard/check_scope.py']))
inputs={str(p.relative_to(ROOT)).replace('\\','/'):sha(p) for p in HERE.glob('*.py')}
results=[]
for name,command in commands:
    start=time.monotonic()
    with (out/(name+'.stdout.txt')).open('wb') as stdout,(out/(name+'.stderr.txt')).open('wb') as stderr:
        result=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr,timeout=120)
    results.append(dict(name=name,command=command,exitCode=result.returncode,seconds=time.monotonic()-start,stdoutSha256=sha(out/(name+'.stdout.txt')),stderrSha256=sha(out/(name+'.stderr.txt'))))
    print(name,result.returncode)
unchanged=all(sha(ROOT/p)==h for p,h in inputs.items())
(out/'receipts.json').write_bytes((json.dumps(dict(scope='LOCAL_SCOPED_CHECKS_NOT_STUDIO',inputHashes=inputs,inputsUnchanged=unchanged,checks=results),indent=2)+'\n').encode())
raise SystemExit(1 if any(x['exitCode'] for x in results) or not unchanged else 0)
