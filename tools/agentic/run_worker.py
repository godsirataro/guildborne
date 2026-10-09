"""Opt-in bounded Codex execution for local-code tasks; no model calls in CI/preflight."""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import time
import uuid
from forge import ROOT, Ledger, inside, read_json, save_json, validate_skills, contains_path
import git_evidence


def command(executable: str, output: Path) -> list[str]:
    # Prompt on stdin, never interpolated into a shell command. Preserve host approvals.
    return [executable, 'exec', '--json', '--sandbox', 'workspace-write',
            '--output-last-message', str(output), '-']


def run_process(argv, prompt: str, root: Path, out: Path, timeout: int, heartbeat):
    out.mkdir(parents=True, exist_ok=True)
    creation = {'creationflags': subprocess.CREATE_NEW_PROCESS_GROUP} if os.name == 'nt' else {'start_new_session': True}
    with (out/'events.jsonl').open('wb') as log, (out/'stderr.txt').open('wb') as err, (out/'prompt.md').open('wb+') as feed:
        feed.write(prompt.encode()); feed.seek(0)
        proc = subprocess.Popen(argv, cwd=root, stdin=feed, stdout=log, stderr=err, shell=False, **creation)
        started, next_heartbeat = time.monotonic(), time.monotonic()
        stopped = False
        try:
            while proc.poll() is None:
                if time.monotonic() - started > timeout:
                    raise TimeoutError('Worker time budget exhausted')
                if sum((out/p).stat().st_size for p in ('events.jsonl','stderr.txt')) > 32*1024*1024:
                    raise ValueError('Worker output budget exhausted')
                if time.monotonic() >= next_heartbeat:
                    heartbeat(); next_heartbeat = time.monotonic() + 15
                time.sleep(.1)
            if sum((out/p).stat().st_size for p in ('events.jsonl','stderr.txt')) > 32*1024*1024:
                raise ValueError('Worker output budget exhausted')
            stopped = True
            return {'exitCode': proc.returncode, 'seconds': time.monotonic()-started, 'workerStopped': True}
        finally:
            if not stopped:
                if os.name == 'nt':
                    subprocess.run(['taskkill','/PID',str(proc.pid),'/T','/F'], capture_output=True, timeout=15)
                else:
                    try: os.killpg(proc.pid, signal.SIGKILL)
                    except ProcessLookupError: pass
                proc.wait(timeout=15)


def changed_paths(root: Path):
    tracked = git_evidence.git(root, 'diff', '--no-renames', '--name-only', 'HEAD', '-z')
    untracked = git_evidence.git(root, 'ls-files', '--others', '--exclude-standard', '-z')
    return sorted(set(filter(None, (tracked + '\0' + untracked).split('\0'))))


def changed_outside(paths, scopes):
    return [p for p in paths if not p.startswith('build/agentic/')
            and not any(contains_path(s, p) for s in scopes)]


def run(root: Path, task_id: str, executable: str, ledger_path: Path, *, attempts=1, timeout=900,
        authorized=False, invoke=run_process, resume_run=None, confirmed_stopped=False):
    if not authorized:
        raise ValueError('Model use needs explicit --authorize-model-run; may consume quota/cost')
    if type(attempts) is not int or not 1 <= attempts <= 3 or type(timeout) is not int or not 10 <= timeout <= 1800:
        raise ValueError('Attempts 1..3 and timeout 10..1800 required')
    plan = read_json(root/'production/plan.json')
    validate_skills(root, plan)
    base = git_evidence.head(root)
    if not resume_run: git_evidence.clean_source(root)
    elif not confirmed_stopped or not re.fullmatch(r'[a-f0-9]{32}', resume_run):
        raise ValueError('Resume requires exact run ID and --confirm-worker-stopped')
    ledger = Ledger(ledger_path, root, plan)
    run_id = resume_run or uuid.uuid4().hex
    out = inside(root, 'build/agentic/runs/' + run_id)
    record = {'schemaVersion':2, 'runId':run_id,'taskId':task_id,'buildCommit':base,
              'status':'PREPARING','attempts':[],'planSha256':git_evidence.plan_hash(plan)}
    try:
        task = ledger.tasks[task_id]
        if task.get('blockedExternal'):
            raise ValueError('Task is externally blocked: ' + task['blockedExternal'])
        if task['environment'] != 'local':
            raise ValueError('Unattended worker is local-code-only; interactive/physical/platform tasks need their verified tool session')
        if resume_run:
            record = read_json(out/'run.json')
            if (record['taskId'] != task_id or record['buildCommit'] != base
                    or record['planSha256'] != git_evidence.plan_hash(plan)):
                raise ValueError('Resume task/build/plan changed; reconcile explicitly')
            if changed_outside(changed_paths(root),task['writeScopes']):
                raise ValueError('Resume blocked by out-of-scope changes')
            checkpoint = read_json(out/'lease.json')
            if checkpoint['ledger'] != str(ledger_path.resolve()):
                raise ValueError('Resume requires original shared ledger')
            ledger.release(task_id, checkpoint['leaseToken'])
        else: out.mkdir(parents=True, exist_ok=False)
        token = ledger.claim(task_id, 'codex-' + run_id)
        # Cooperative local coordination token only. Never commit or upload this directory.
        save_json(out/'lease.json', {'taskId':task_id,'leaseToken':token,'ledger':str(ledger_path.resolve())})
        if os.name != 'nt': (out/'lease.json').chmod(0o600)
        packet = '# Guildborne bounded worker\nRead AGENTS.md and production/LATEST_GOALS.md.\n'
        packet += (root/'.agents/skills'/task['skill']/'SKILL.md').read_text()
        packet += '\nTask:\n' + json.dumps(task, ensure_ascii=False, indent=2)
        packet += ('\nOnly edit the assigned writeScopes. Preserve all existing work. Do not commit, publish, '
                   'upload, make purchases, enable commerce, or touch cloud data. '
                   'Do not launch background/daemon processes. Do not change the production plan, skills or runner. '
                   'Run tests and report exact commands/results; the coordinator owns the ledger. '
                   'External-tool work stays pending. Never claim full game or visual acceptance.\n')
        if resume_run: packet += '\nResume after confirmed stop; inspect saved attempts in ' + str(out) + '. Preserve unfinished work.\n'
        offset = len(record['attempts'])
        for n in range(attempts):
            step = out/f'attempt-{offset+n+1}'
            record['status'] = 'RUNNING'; save_json(out/'run.json',record)
            try:
                result = invoke(command(executable, step/'last-message.txt'), packet, root, step,
                                timeout, lambda: ledger.heartbeat(task_id, token))
            except (OSError, ValueError, TimeoutError, subprocess.SubprocessError, KeyboardInterrupt) as exc:
                record['status'] = 'INTERRUPTED_REQUIRES_REVIEW'; record['error'] = str(exc)
                # Count even interrupted attempts so resume never overwrites prior logs.
                record['attempts'].append({'status':'INTERRUPTED','path':str(step.relative_to(root))})
                save_json(out/'run.json',record)
                raise
            record['attempts'].append({**result,'path':str(step.relative_to(root))})
            try:
                if git_evidence.head(root) != base:
                    record['status'] = 'BLOCKED_HEAD_CHANGED'; break
                if git_evidence.plan_hash(read_json(root/'production/plan.json')) != record['planSha256']:
                    record['status'] = 'BLOCKED_PLAN_CHANGED'; break
                violations = changed_outside(changed_paths(root), task['writeScopes'])
                if violations:
                    record['status'] = 'BLOCKED_SCOPE_VIOLATION'; record['outOfScope'] = violations; break
            except (OSError, ValueError, TypeError) as exc:
                record['status'] = 'BLOCKED_POSTCHECK_FAILED'; record['error'] = str(exc); break
            if result['exitCode'] == 0:
                record['status'] = 'REVIEW_CANDIDATE_NOT_ACCEPTED'; break
            packet += '\nPrevious attempt failed; inspect ' + str(step) + ' and fix only assigned work.\n'
        else: record['status'] = 'FAILED_RETRY_LIMIT'
        record['requiresIndependentReview'] = True
        record['next'] = 'Review diff/logs, commit tested source, rerun acceptance on that commit, submit hashed evidence using local lease.json. Ownership stays reserved; no automatic acceptance.'
        save_json(out/'run.json',record)
        return record
    finally: ledger.close()


def main(argv=None):
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root',type=Path,default=ROOT); p.add_argument('--task',required=True)
    p.add_argument('--ledger',type=Path,required=True,help='One shared ledger for all workers')
    p.add_argument('--codex',default='codex'); p.add_argument('--authorize-model-run',action='store_true')
    p.add_argument('--attempts',type=int,default=1); p.add_argument('--timeout',type=int,default=900)
    p.add_argument('--resume-run'); p.add_argument('--confirm-worker-stopped',action='store_true')
    a=p.parse_args(argv)
    executable=shutil.which(a.codex)
    if not executable: raise ValueError('Codex executable not found; nothing was launched')
    result=run(a.root.resolve(),a.task,executable,a.ledger,attempts=a.attempts,timeout=a.timeout,
        authorized=a.authorize_model_run,resume_run=a.resume_run,confirmed_stopped=a.confirm_worker_stopped)
    print(json.dumps(result,indent=2))
    return 0 if result['status']=='REVIEW_CANDIDATE_NOT_ACCEPTED' else 1


if __name__=='__main__':
    try: sys.exit(main())
    except (OSError,ValueError,KeyError,TypeError,TimeoutError,subprocess.SubprocessError) as exc:
        print(f'Worker blocked: {exc}',file=sys.stderr);sys.exit(1)
