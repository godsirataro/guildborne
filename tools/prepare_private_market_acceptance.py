"""Build isolated reserved-server acceptance artifact. Does not publish or upload."""
from pathlib import Path
import argparse, json, re, shutil, subprocess

parser=argparse.ArgumentParser()
parser.add_argument('--run-id', required=True)
parser.add_argument('--users', required=True, nargs='+', type=int)
parser.add_argument('--drop-messages', action='store_true')
args=parser.parse_args()
assert re.fullmatch(r'[A-Za-z0-9_-]{1,16}', args.run_id)
assert len(set(args.users))>=2 and all(n>0 for n in args.users)
root=Path(__file__).resolve().parents[1]
target=root/'build'/('private-acceptance-'+args.run_id)
assert not target.exists(), 'Choose a fresh run ID; existing acceptance artifacts are preserved'
shutil.copytree(root/'src',target/'src')
runtime=target/'src/server/Config/Runtime.luau'
source=runtime.read_text(encoding='utf-8')
replacement='PrivateAcceptance = { Enabled = true, RunId = '+json.dumps(args.run_id)+', UserIds = {'+','.join('['+str(n)+']=true' for n in sorted(set(args.users)))+'} },'
source,count=re.subn(r'PrivateAcceptance = .*',replacement,source)
assert count==1
runtime.write_text(source,encoding='utf-8')
if args.drop_messages:
    market_runtime=target/'src/server/Services/MarketRuntime.luau'
    text=market_runtime.read_text(encoding='utf-8')
    assert 'task.spawn(adapter.Subscribe)' in text
    market_runtime.write_text(text.replace('task.spawn(adapter.Subscribe)','-- Isolated acceptance artifact deliberately ignores invalidations.'),encoding='utf-8')
shutil.copy2(root/'tests/private_market_acceptance.server.luau',target/'src/server/PrivateAcceptance.server.luau')
shutil.copy2(root/'default.project.json',target/'default.project.json')
subprocess.run([str(root/'.tools/rojo/rojo.exe'),'build',str(target/'default.project.json'),'--output',str(target/'PrivateAcceptance.rbxlx')],check=True)
print('Built private acceptance artifact only:',target/'PrivateAcceptance.rbxlx')
print('Publication requires separate explicit approval. Default project/runtime remains unchanged.')
