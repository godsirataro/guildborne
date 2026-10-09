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
    if not approved or not argv or not all(isinstance(x, str) and x and '\0' not in x for x in argv):
        raise ValueError('An explicitly reviewed argv array is required')
    if type(timeout) is not int or not 1 <= timeout <= 1800:
        raise ValueError('Invalid timeout')
    git_evidence.clean_source(root)
    commit = git_evidence.head(root)
    tree = git_evidence.validate_commit(root, commit)
    run_id = uuid.uuid4().hex
    out = inside(root, 'build/agentic/checks/' + run_id)
    out.mkdir(parents=True, exist_ok=False)
    started, error = time.monotonic(), None
    try:
        result = run_process(argv, '', root, out, timeout, lambda: None)
        code = result['exitCode']
    except (OSError, ValueError, TimeoutError, subprocess.SubprocessError, KeyboardInterrupt) as exc:
        code = 124 if isinstance(exc, TimeoutError) else 130 if isinstance(exc, KeyboardInterrupt) else 125
        error = f'{type(exc).__name__}: {exc}'
    events = out/'events.jsonl'
    if events.exists():
        events.rename(out/'stdout.txt')
    streams = []
    for p in (out/'stdout.txt', out/'stderr.txt'):
        if p.exists():
            streams.append({'path': p.relative_to(root).as_posix(), 'sha256': digest(p), 'bytes': p.stat().st_size})
    try:
        unchanged = git_evidence.head(root) == commit
        git_evidence.clean_source(root)
    except ValueError:
        unchanged = False
    # A quiet command legitimately has zero-byte stdout/stderr. Keep them in the
    # receipt, not as empty proof artifacts that Forge intentionally rejects.
    receipt_path = out/'invocation.json'
    receipt = {'schemaVersion': 1, 'kind': 'LOCAL_COMMAND_RECEIPT', 'runId': run_id,
               'tool': argv[0], 'argv': argv, 'buildCommit': commit, 'sourceTree': tree,
               'exitCode': code, 'sourceUnchanged': unchanged,
               'seconds': time.monotonic()-started, 'streams': streams, 'error': error}
    save_json(receipt_path, receipt)
    receipt_artifact = {'path': receipt_path.relative_to(root).as_posix(),
                        'sha256': digest(receipt_path), 'bytes': receipt_path.stat().st_size}
    artifacts = [receipt_artifact, *(a for a in streams if a['bytes'] > 0)]
    packet = {'schemaVersion': 3, 'buildCommit': commit, 'sourceTree': tree,
              'status': 'COMMAND_PASS_NOT_TASK_ACCEPTANCE' if code == 0 and unchanged else 'FAIL',
              'sourceUnchanged': unchanged,
              'invocation': {'tool': argv[0], 'argv': argv, 'runId': run_id,
                             'buildCommit': commit, 'exitCode': code, 'seconds': receipt['seconds'],
                             'recordPath': receipt_artifact['path'], 'recordSha256': receipt_artifact['sha256'],
                             'logs': [a['path'] for a in artifacts]},
              'artifacts': artifacts, 'humanApproved': False}
    save_json(out/'result.json', packet)
    return packet


def verify(root: Path, packet: dict) -> None:
    """Validate a recorded check. This is consistency checking, NOT signed attestation."""
    if packet.get('status') != 'COMMAND_PASS_NOT_TASK_ACCEPTANCE' or packet.get('sourceUnchanged') is not True:
        raise ValueError('Check did not pass on unchanged source')
    git_evidence.validate_identity(root, packet)
    artifacts = packet.get('artifacts')
    if not isinstance(artifacts, list) or not artifacts:
        raise ValueError('Check artifacts required')
    seen = set()
    for item in artifacts:
        p = inside(root, item['path'])
        if item['path'] in seen or not p.is_file() or not p.stat().st_size or digest(p) != item['sha256']:
            raise ValueError('Check artifact missing, duplicate or changed')
        seen.add(item['path'])
    invocation = packet['invocation']
    relative = invocation.get('recordPath')
    if relative not in seen or digest(inside(root, relative)) != invocation.get('recordSha256'):
        raise ValueError('Recorded invocation is missing or changed')
    receipt = read_json(inside(root, relative))
    if (receipt.get('schemaVersion') != 1 or receipt.get('kind') != 'LOCAL_COMMAND_RECEIPT'
            or receipt.get('sourceUnchanged') is not True or receipt.get('sourceTree') != packet['sourceTree']):
        raise ValueError('Invalid invocation receipt')
    for field in ('runId', 'tool', 'argv', 'buildCommit', 'exitCode'):
        if receipt.get(field) != invocation.get(field):
            raise ValueError(f'Invocation receipt mismatch: {field}')
    streams = receipt.get('streams')
    if not isinstance(streams, list) or not streams:
        raise ValueError('Receipt must retain captured stream metadata')
    for stream in streams:
        p = inside(root, stream['path'])
        if not p.is_file() or p.stat().st_size != stream['bytes'] or digest(p) != stream['sha256']:
            raise ValueError('Captured stream changed after check')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config', required=True, type=Path)
    p.add_argument('--approve-command-sha256', required=True)
    a = p.parse_args()
    if digest(a.config) != a.approve_command_sha256:
        raise ValueError('Command configuration hash mismatch')
    cfg = read_json(a.config)
    argv = cfg['argv']
    if not isinstance(argv, list) or not argv:
        raise ValueError('argv required')
    executable = shutil.which(argv[0])
    if not executable:
        raise ValueError('Check executable unavailable')
    result = record(ROOT, [executable, *argv[1:]], timeout=cfg.get('timeoutSeconds', 300), approved=True)
    print(result['status'], result['invocation']['runId'])
    return 0 if result['status'] == 'COMMAND_PASS_NOT_TASK_ACCEPTANCE' else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as exc:
        print(f'Check recording failed: {exc}', file=sys.stderr)
        sys.exit(1)
