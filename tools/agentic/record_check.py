"""Record an explicitly approved local check against an immutable Git source tree."""
from __future__ import annotations
import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import time
import uuid
from forge import ROOT, digest, inside, read_json, save_json
import git_evidence
from run_worker import run_process


def record(root: Path, argv: list[str], *, timeout=300, approved=False):
    if not approved or not argv or not all(isinstance(x,str) and x and '\0' not in x for x in argv):
        raise ValueError('An explicitly reviewed argv array is required')
    if type(timeout) is not int or not 1 <= timeout <= 1800: raise ValueError('Invalid timeout')
    git_evidence.clean_source(root)
    commit=git_evidence.head(root); tree=git_evidence.validate_commit(root,commit)
    run_id=uuid.uuid4().hex; out=inside(root,'build/agentic/checks/'+run_id)
    out.mkdir(parents=True,exist_ok=False)
    started=time.monotonic()
    # Reuse owned-process-group shutdown and bounded log/time budgets.
    try:
        result=run_process(argv,'',root,out,timeout,lambda:None)
        code=result['exitCode']
    except TimeoutError:
        code=124
    (out/'events.jsonl').rename(out/'stdout.txt')
    unchanged=git_evidence.head(root)==commit
    try: git_evidence.clean_source(root)
    except ValueError: unchanged=False
    artifacts=[{'path':p.relative_to(root).as_posix(),'sha256':digest(p),'bytes':p.stat().st_size}
               for p in (out/'stdout.txt',out/'stderr.txt')]
    packet={'schemaVersion':2,'buildCommit':commit,'sourceTree':tree,
        'status':'COMMAND_PASS_NOT_TASK_ACCEPTANCE' if code==0 and unchanged else 'FAIL',
        'sourceUnchanged':unchanged,'invocation':{'tool':argv[0],'argv':argv,'runId':run_id,
            'buildCommit':commit,'exitCode':code,'seconds':time.monotonic()-started,
            'logs':[x['path'] for x in artifacts if x['bytes']>0]},
        'artifacts':artifacts,'humanApproved':False}
    save_json(out/'result.json',packet)
    return packet


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config',required=True,type=Path)
    p.add_argument('--approve-command-sha256',required=True)
    a=p.parse_args()
    if digest(a.config)!=a.approve_command_sha256: raise ValueError('Command configuration hash mismatch')
    cfg=read_json(a.config); argv=cfg['argv']
    if not isinstance(argv,list) or not argv: raise ValueError('argv required')
    executable=shutil.which(argv[0])
    if not executable: raise ValueError('Check executable unavailable')
    result=record(ROOT,[executable,*argv[1:]],timeout=cfg.get('timeoutSeconds',300),approved=True)
    print(result['status'],result['invocation']['runId'])
    return 0 if result['status']=='COMMAND_PASS_NOT_TASK_ACCEPTANCE' else 1


if __name__=='__main__':
    try: sys.exit(main())
    except (OSError,ValueError,KeyError,TypeError,subprocess.SubprocessError) as exc:
        print(f'Check recording failed: {exc}',file=sys.stderr);sys.exit(1)
