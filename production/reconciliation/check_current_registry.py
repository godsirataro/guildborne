"""Read-only registry acceptance checks; never import assets or promote status."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/agentic'))
import reconcile
import character_contract

paths = [ROOT / p for p in (
    'docs/uat01/intake/registry-reconciled.json',
    'production/character-kit-v1/catalog.json',
    'production/character-kit-v1/aliases.json', 'production/plan.json')]
before = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
registry, kit, aliases, plan = [json.loads(p.read_text(encoding='utf-8')) for p in paths]
report = reconcile.reconcile(ROOT, registry, kit, plan, aliases)
mode = sys.argv[1]
details = {}
if mode == 'row-coverage':
    expected = len(registry['assets']) + len(registry['screens']) + len(kit['assets'])
    assert len(report['entries']) == expected
    assert len({e['id'].casefold() for e in report['entries']}) == expected
    assert not report['routingReviewRequired']
    assert {e['designId'] for e in report['entries'] if e['kind'] == 'kit'} == {a[0] for a in kit['assets']}
    details = {'rows': expected, 'counts': report['counts']}
elif mode == 'source-hashes':
    assert not report['missingReferences'], report['missingReferences']
    files = {f['path']: f for e in report['entries'] for f in e['files']}
    for rel, item in files.items():
        p = ROOT / rel
        assert p.is_file() and not p.is_symlink()
        assert hashlib.sha256(p.read_bytes()).hexdigest() == item['sha256']
        assert p.stat().st_size == item['bytes']
    details = {'files': files, 'missingReferences': []}
elif mode == 'no-status-promotion':
    for name in ('reconcile.py', 'character_contract.py'):
        subprocess.run([sys.executable, str(ROOT / 'tools/agentic' / name)], cwd=ROOT, check=True)
    for kind, rows in (('asset', registry['assets']), ('screen', registry['screens'])):
        entries = {e['designId']: e for e in report['entries'] if e['kind'] == kind}
        assert len(entries) == len(rows)
        for row in rows:
            e = entries[row['designId']]
            assert e['sourceStatus'] == row.get('status')
            assert e['sourceUatApproved'] == (row.get('uatApproved') is True)
            assert e['robloxAssetId'] == row.get('robloxAssetId')
            assert e['productionBinding'] == row.get('productionBinding')
            assert e['implementationCandidate'] == row.get('implementationCandidate')
            assert e['uatApprovedByReconciliation'] is False
    details = {'sourceApproved': report['counts']['sourceApproved'],
               'nonNullRuntimeIds': sum(e.get('robloxAssetId') is not None for e in report['entries'])}
elif mode == 'aliases':
    character_contract.validate(kit, aliases)
    ids = {a[0] for a in kit['assets']}
    for alias, canonical in aliases.items():
        assert alias not in ids and canonical in ids and alias != canonical
    assert report['aliases'] == aliases
    details = {'aliases': aliases, 'bodyPresets': len(kit['bodyPresets']), 'skinPalettes': len(kit['skinPalettes'])}
else:
    raise ValueError('Unknown check: ' + mode)
after = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
assert before == after, 'Canonical registry/catalog/aliases/plan changed'
print(json.dumps({'check': mode, 'status': 'PASS_LOCAL_RECONCILIATION_ONLY',
                  'sourceHashes': after, 'details': details,
                  'importedOrHumanApprovedByCheck': False}, sort_keys=True))
