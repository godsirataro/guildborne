"""Compose local task evidence from actual recorded checks; never accepts a task."""
from __future__ import annotations
import argparse
from pathlib import Path
import sys
from forge import ROOT, digest, evidence_packet, inside, read_json, save_json, validate_plan
import git_evidence
import record_check


def compose(root: Path, task_id: str, checks: dict[str, str]) -> dict:
    plan = read_json(root/'production/plan.json')
    task = validate_plan(plan)[task_id]
    if task['environment'] != 'local':
        raise ValueError('Local command checks cannot certify Studio, Blender, device or cross-server tasks')
    if set(checks) != set(task['checks']):
        raise ValueError('Supply exactly one recorded result for every declared check')
    artifacts, runs, first = {}, {}, None
    for name, relative in checks.items():
        path = inside(root, relative)
        result = read_json(path)
        record_check.verify(root, result)
        if first is None:
            first = result
        runs[name] = {'path': relative, 'sha256': digest(path)}
        for a in [*result['artifacts'], {'path': relative, 'sha256': digest(path)}]:
            existing = artifacts.get(a['path'])
            if existing and existing['sha256'] != a['sha256']:
                raise ValueError('Conflicting evidence for the same path')
            artifacts[a['path']] = a
    packet = {'schemaVersion': 3, 'taskId': task_id, 'environment': 'local',
              'buildCommit': first['buildCommit'], 'sourceTree': first['sourceTree'],
              'planSha256': git_evidence.plan_hash(plan), 'invocation': first['invocation'],
              'checks': {name: 'PASS' for name in checks}, 'checkRuns': runs,
              'artifacts': list(artifacts.values()), 'humanApproved': False,
              'warning': 'Command success is not semantic, artistic or human approval. Independent review required.'}
    evidence_packet(root, task, packet)
    return packet


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', type=Path, default=ROOT)
    p.add_argument('--task', required=True)
    p.add_argument('--check', action='append', default=[], metavar='CHECK_ID=RESULT_PATH')
    p.add_argument('--output', required=True, help='Repository-relative evidence JSON destination')
    a = p.parse_args(argv)
    checks = {}
    for assignment in a.check:
        key, sep, value = assignment.partition('=')
        if not sep or not key or not value or key in checks:
            raise ValueError('Invalid or duplicate check assignment')
        checks[key] = value
    root = a.root.resolve()
    target = inside(root, a.output)
    if not a.output.startswith('build/agentic/evidence/') or target.exists():
        raise ValueError('Use a new file under build/agentic/evidence; no overwrites')
    packet = compose(root, a.task, checks)
    save_json(target, packet)
    print('LOCAL_EVIDENCE_COMPOSED_NOT_ACCEPTED', target)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print(f'Evidence composition failed: {exc}', file=sys.stderr)
        sys.exit(1)
