"""Read-only UAT/Character Kit reconciliation; never promotes evidence or invents IDs."""
from __future__ import annotations
import argparse
from collections import Counter, defaultdict
from pathlib import Path
import re
import sys
from forge import ROOT, inside, read_json, save_json, digest, validate_plan

FILE_EXT = {'.luau','.lua','.py','.md','.json','.png','.webp','.svg','.jpg','.jpeg',
            '.fbx','.gltf','.glb','.blend','.bin','.csv','.xlsx','.wav','.ogg','.mp3','.flac','.rbxmx','.rbxm'}
ROUTES = (
    (r'guild.?war|territory|siege', 'guild-war-territory'),
    (r'island|plot|furniture|building.?theme|build.?mode|hall[._]?themes|utility[._]?themes', 'guild-islands'),
    (r'npc.?life|civic.?work|city.?host|envoy|dialogue|novice[.]trial[.]patient', 'npc-life'),
    (r'novice[.]trial[.]sentinel', 'monsters'),
    (r'novice[.]trial[.]', 'city-zones'),
    (r'brand|logo|crest|monogram', 'brand-art'),
    (r'audio|music|sound|sfx', 'audio'),
    (r'vfx|effect|particle|trail|telegraph', 'vfx'),
    (r'anim|motion|contact|pose', 'animation'),
    (r'enemy|monster|boss', 'monsters'),
    (r'hero|recruit|tavern', 'hero-stories'),
    (r'character|body|race|clothing|hair|beard|skin|rig', 'character-import'),
    (r'guild|island|building|plot|furniture', 'guild-foundation'),
    (r'quest|story|chapter|ending|narrative', 'story-quests'),
    (r'item|weapon|equipment|craft|inventory', 'inventory-crafting'),
    (r'market|exchange|trade', 'market-integrity'),
    (r'city|region|zone|world|map|environment|npc|portal|civic', 'city-zones'),
    (r'skill|stat|class|progress', 'progression'),
    (r'ui|icon|panel|frame|nav|badge|rank|button|screen|empty|state|symbol', 'ux-system'),
)


def source_paths(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from source_paths(child)
    elif isinstance(value, list):
        for child in value:
            yield from source_paths(child)
    elif isinstance(value, str):
        # The checked-in legacy registry uses semicolon-separated source lists.
        # Preserve the registry itself; only normalize its reference representation.
        for token in value.split(';'):
            token = token.strip()
            if ('/' in token or '\\' in token) and '://' not in token:
                if Path(token).suffix.lower() in FILE_EXT or token.endswith('/'):
                    yield token


def row_id(row, kind):
    key = row.get('designId') or row.get('screenId') or row.get('id')
    if not isinstance(key, str) or not key or len(key) > 200:
        raise ValueError(f'Missing/invalid {kind} ID')
    return key


def routing(row, kind):
    if kind == 'screen':
        return 'ux-system'
    words = str(row.get('group', '')) + ' ' + row_id(row, kind)
    return next((target for pattern, target in ROUTES if re.search(pattern, words, re.I)), 'audit')


def reconcile(root: Path, registry: dict, kit: dict, plan: dict, aliases: dict):
    tasks = validate_plan(plan)
    entries, missing, shared, cache, seen = [], [], defaultdict(list), {}, set()
    for kind, source in (('asset', registry.get('assets')), ('screen', registry.get('screens'))):
        if not isinstance(source, list):
            raise ValueError(f'Expected registry {kind} array')
        for row in source:
            if not isinstance(row, dict):
                raise ValueError('Registry rows must be objects')
            key = row_id(row, kind)
            identity = kind + ':' + key
            if identity.casefold() in seen:
                raise ValueError(f'Duplicate/case-colliding registry identity: {identity}')
            seen.add(identity.casefold())
            files, directories = [], []
            for rel in sorted(set(source_paths(row.get('source', {}))) | set(source_paths(row.get('productionBinding', {}))) | set(source_paths(row.get('implementationCandidate', {})))):
                directory_reference = rel.endswith('/')
                path = inside(root, rel[:-1] if directory_reference else rel)
                if path.is_symlink():
                    raise ValueError(f'Symlink is not accepted as a source: {rel}')
                if directory_reference:
                    if path.is_dir():
                        directories.append({'path': rel[:-1], 'verifiedHere': 'DIRECTORY_EXISTS_ONLY'})
                    else:
                        missing.append({'id': identity, 'path': rel, 'kind': 'directory'})
                    continue
                if not path.is_file():
                    missing.append({'id': identity, 'path': rel})
                    continue
                if rel not in cache:
                    cache[rel] = {'path': rel, 'sha256': digest(path), 'bytes': path.stat().st_size}
                files.append(cache[rel])
                shared[cache[rel]['sha256']].append({'id': identity, 'path': rel})
            target = routing(row, kind)
            if target not in tasks:
                raise ValueError(f'Routing references absent task {target}')
            entries.append({'id': identity, 'designId': key, 'kind': kind,
                'scope': row.get('scope', 'UAT01'), 'group': row.get('group'),
                'sourceStatus': row.get('status'), 'sourceUatApproved': row.get('uatApproved') is True,
                'robloxAssetId': row.get('robloxAssetId'), 'productionBinding': row.get('productionBinding'),
                'implementationCandidate': row.get('implementationCandidate'),
                'requiredBehavior': row.get('requiredBehavior'), 'requiredStates': row.get('requiredStates'),
                'files': files, 'directories': directories, 'workPackage': target,
                'action': 'REVIEW_EXISTING_BEFORE_GENERATION' if files or directories else 'RESOLVE_SOURCE_OR_NATIVE_BINDING',
                'provenance': row.get('provenance'), 'licenseReview': 'REQUIRED_UNLESS_VERIFIED_SEPARATELY',
                'verifiedHere': 'FILE_BYTES_ONLY', 'uatApprovedByReconciliation': False})
    kit_ids = set()
    for row in kit.get('assets', []):
        if not isinstance(row, list) or len(row) < 8 or row[0] in kit_ids:
            raise ValueError('Malformed/duplicate kit asset row')
        kit_ids.add(row[0])
        entries.append({'id': 'kit:' + row[0], 'designId': row[0], 'kind': 'kit',
            'sourceStatus': 'PLANNED', 'sourceUatApproved': False, 'robloxAssetId': None,
            'workPackage': 'character-intake', 'action': 'RESOLVE_AGAINST_EXISTING_LIBRARY',
            'files': [], 'uatApprovedByReconciliation': False})
    for alias, canonical in aliases.items():
        if canonical not in kit_ids or alias in kit_ids or alias == canonical:
            raise ValueError(f'Invalid character ID alias: {alias}')
    return {'schemaVersion': 2, 'mode': 'READ_ONLY_DRY_RUN',
        'counts': {'assets': len(registry['assets']), 'screens': len(registry['screens']),
                   'kitAssets': len(kit_ids), 'sourceApproved': sum(x['sourceUatApproved'] for x in entries),
                   'filesHashed': len(cache), 'missingReferences': len(missing)},
        'entries': entries, 'aliases': aliases, 'missingReferences': missing,
        'sharedContentCandidates': [v for v in shared.values() if len(v) > 1],
        'routingReviewRequired': [x['id'] for x in entries if x['workPackage'] == 'audit'],
        'tasks': dict(Counter(x['workPackage'] for x in entries)),
        'warning': 'Legacy semicolon lists are parsed read-only; directories are existence-checked, not recursively approved. Native GUI/parts may legitimately have no upload ID. Shared source bytes do not prove interchangeable assets. No status or runtime record was changed.'}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=ROOT)
    args = parser.parse_args(argv)
    root = args.root.resolve()
    registry_path = root/'docs/uat01/intake/registry-reconciled.json'
    report = reconcile(root, read_json(registry_path),
        read_json(root/'production/character-kit-v1/catalog.json'), read_json(root/'production/plan.json'),
        read_json(root/'production/character-kit-v1/aliases.json'))
    report['registrySha256'] = digest(registry_path)
    out = root/'build/agentic/reconciliation.json'
    save_json(out, report)
    print(report['counts'])
    print(f'Report: {out}; reference conflicts remain review items, NOT UAT approval')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, TypeError, KeyError) as exc:
        print(f'Reconciliation failed: {exc}', file=sys.stderr)
        sys.exit(1)
