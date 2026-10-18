"""Build isolated real InventoryView fixture; one LocalScript, no server/remotes."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--rojo', type=Path)
args = parser.parse_args()
local = ROOT / '.tools/rojo/rojo.exe'
rojo = args.rojo or (local if local.is_file() else shutil.which('rojo'))
if not rojo or not Path(rojo).is_file():
    parser.error('Supply an existing Rojo executable; this builder installs nothing.')
out = ROOT / 'build/inventory-review'
out.mkdir(parents=True, exist_ok=True)
def source(path):
    return {'$path': str(ROOT / path)}
ui = {name: source(f'src/client/UI/{name}.luau') for name in ('InventoryView', 'AssetImage', 'ItemViewport')}
ui['DesignSystem'] = {'Theme': source('src/client/UI/DesignSystem/Theme.luau')}
ui['Components'] = {name: source(f'src/client/UI/Components/{name}.luau') for name in
                    ('InventoryPane', 'EquipmentSlot', 'InventoryActorPreview', 'GuildbornePanel', 'GuildborneButton', 'RegalOrnament')}
project = {'name': 'GuildborneInventoryReview', 'tree': {
    '$className': 'DataModel',
    'ReplicatedStorage': {'$className': 'ReplicatedStorage', 'Shared': {
        'Config': {name: source(f'src/shared/Config/{name}.luau') for name in ('Art', 'VisualAssets', 'Localization')},
        'Data': {name: source(f'src/shared/Data/{name}.luau') for name in ('Equipment', 'ItemVisuals')},
    }},
    'StarterPlayer': {'$className': 'StarterPlayer', 'StarterPlayerScripts': {
        '$className': 'StarterPlayerScripts', 'InventoryReview': source('tests/gui/inventory_review.client.luau'),
        'Client': {'UI': ui},
    }},
    'Workspace': {'$className': 'Workspace', 'ReviewSpawn': {
        '$className': 'SpawnLocation', '$properties': {'Anchored': True, 'Size': [24, 1, 24], 'Position': [0, 0, 0], 'Neutral': True},
    }},
}}
def folders(node):
    if '$path' not in node:
        node.setdefault('$className', 'Folder')
        for key, child in node.items():
            if not key.startswith('$') and isinstance(child, dict):
                folders(child)
folders(project['tree'])
path = out / 'review.project.json'
path.write_text(json.dumps(project, indent=2), encoding='utf-8')
place = out / 'GuildborneInventoryReview.rbxlx'
subprocess.run([str(Path(rojo).resolve()), 'build', str(path), '--output', str(place)], check=True)
items = ET.parse(place).getroot().findall('.//Item')
assert sum(item.get('class') == 'LocalScript' for item in items) == 1
assert not any(item.get('class') in {'Script', 'RemoteEvent', 'RemoteFunction', 'UnreliableRemoteEvent'} for item in items)
receipt = {'place': str(place), 'sha256': hashlib.sha256(place.read_bytes()).hexdigest(),
           'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
           'source_files': {}, 'status': 'BUILT_STUDIO_NOT_RUN', 'local_scripts': 1, 'server_scripts': 0, 'remotes': 0}
def hashes(node):
    if '$path' in node:
        source_path = Path(node['$path'])
        receipt['source_files'][str(source_path.relative_to(ROOT))] = hashlib.sha256(source_path.read_bytes()).hexdigest()
    for child in node.values():
        if isinstance(child, dict): hashes(child)
hashes(project['tree'])
(out / 'build_receipt.json').write_text(json.dumps(receipt, indent=2), encoding='utf-8')
print(json.dumps(receipt))
