"""Local, pinned document intake. Never executes archive contents or overwrites files."""
from pathlib import Path, PurePosixPath
import hashlib
import json
import stat
import zipfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
DOWNLOADS = Path('C:/Users/godsi/Downloads')
PACKS = {
    'Guildborne_Living_World_NPC_QuestReady_Production_Pack_2026-10-17.zip': (
        '5505944b5cbe42c718f35f552069d1dde82cb6cbc84daeb448403abfef6650dd',
        'Guildborne_Living_World_NPC_QuestReady_Pack_2026-10-17'),
    'Guildborne_NPC_Quest_Modular_World_Addendum_2026-10-17.zip': (
        'f42278cc1103a925f06fa393085610c48bad3bf902dfa49a7ae9470ecaf32795',
        'Guildborne_NPC_Quest_Modular_World_Addendum_2026-10-17'),
}

def sha(data):
    return hashlib.sha256(data).hexdigest()

def main():
    planned = []
    receipt = {'status': 'DOCUMENT_INTAKE_ONLY', 'archives': []}
    for filename, (expected, folder) in PACKS.items():
        source = DOWNLOADS / filename
        raw = source.read_bytes()
        assert sha(raw) == expected, f'Archive changed: {filename}'
        record = {'source': str(source), 'sha256': expected, 'members': []}
        with zipfile.ZipFile(source) as archive:
            assert len(archive.infolist()) <= 100
            assert sum(info.file_size for info in archive.infolist()) <= 5_000_000
            for info in archive.infolist():
                name = PurePosixPath(info.filename)
                assert not name.is_absolute() and '..' not in name.parts
                assert '\\' not in info.filename and ':' not in info.filename
                assert name.parts[0] == folder and not info.is_dir()
                assert not stat.S_ISLNK(info.external_attr >> 16)
                assert name.suffix in {'.md', '.json', '.csv'}
                target = (ROOT / 'design' / Path(*name.parts)).resolve()
                assert target.is_relative_to((ROOT / 'design' / folder).resolve())
                data = archive.read(info)
                assert len(data) == info.file_size
                planned.append((target, data))
                record['members'].append({'path': target.relative_to(ROOT).as_posix(), 'sha256': sha(data), 'bytes': len(data)})
        planned.append((HERE / 'intake' / filename, raw))
        receipt['archives'].append(record)
    # Validate every destination before any writes, including case-insensitive collisions.
    seen = set()
    for target, data in planned:
        key = str(target).casefold()
        assert key not in seen, f'Duplicate target: {target}'
        seen.add(key)
        assert not target.exists() or target.read_bytes() == data, f'Refuse overwrite: {target}'
    for target, data in planned:
        if not target.exists():
            target.parent.mkdir(parents=True, exist_ok=True)
            with target.open('xb') as handle:
                handle.write(data)
        assert sha(target.read_bytes()) == sha(data)
    output = HERE / 'INTAKE_RECEIPT.json'
    data = (json.dumps(receipt, indent=2, ensure_ascii=False) + '\n').encode('utf-8')
    assert not output.exists() or output.read_bytes() == data
    if not output.exists():
        with output.open('xb') as handle:
            handle.write(data)
    print('INTAKE_VERIFIED: 2 pinned archives, 20 byte-preserved documents; no bundled code executed')

if __name__ == '__main__':
    main()
