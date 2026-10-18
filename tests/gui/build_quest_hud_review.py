"""Build an isolated native before/after quest HUD; no server bootstrap."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--rojo', type=Path, help='Existing executable; never installs tools.')
args = parser.parse_args()
local = ROOT / '.tools/rojo/rojo.exe'
rojo = args.rojo or (local if local.is_file() else shutil.which('rojo'))
if not rojo or not Path(rojo).is_file():
    parser.error('Pass --rojo with an existing Rojo executable.')
out = ROOT / 'build/quest-hud-review'
out.mkdir(parents=True, exist_ok=True)
def source(path):
    return {'$path': str(ROOT / path)}
ui = {
    'QuestTrackerView': source('src/client/UI/QuestTrackerView.luau'),
    'QuestTrackerBefore': source('tests/gui/quest_tracker_before.luau'),
    'DesignSystem': {'Theme': source('src/client/UI/DesignSystem/Theme.luau')},
    'Components': {name: source(f'src/client/UI/Components/{name}.luau') for name in ('QualityAsset', 'WaypointBeacon')},
}
project = {'name': 'GuildborneQuestHudReview', 'tree': {
    '$className': 'DataModel',
    'ReplicatedStorage': {'$className': 'ReplicatedStorage', 'Shared': {
        'Config': {name: source(f'src/shared/Config/{name}.luau') for name in ('Art', 'Localization')},
        'Data': {'CombatHudLayout': source('src/shared/Data/CombatHudLayout.luau')},
    }},
    'StarterPlayer': {'$className': 'StarterPlayer', 'StarterPlayerScripts': {
        '$className': 'StarterPlayerScripts', 'Review': source('tests/gui/quest_hud_review.client.luau'),
        'Client': {'UI': ui},
    }},
    'Workspace': {'$className': 'Workspace'},
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
place = out / 'GuildborneQuestHudReview.rbxlx'
subprocess.run([str(Path(rojo).resolve()), 'build', str(path), '--output', str(place)], check=True)
items = ET.parse(place).getroot().findall('.//Item')
assert sum(item.get('class') == 'LocalScript' for item in items) == 1
assert not any(item.get('class') in {'Script', 'RemoteEvent', 'RemoteFunction', 'UnreliableRemoteEvent'} for item in items)
baseline = (ROOT / 'tests/gui/quest_tracker_before.luau').read_bytes()
assert baseline == subprocess.check_output(['git', 'show', '3279e6d:src/client/UI/QuestTrackerView.luau'], cwd=ROOT)
print(json.dumps({'place': str(place), 'sha256': hashlib.sha256(place.read_bytes()).hexdigest(),
                  'baseline_sha256': hashlib.sha256(baseline).hexdigest(), 'status': 'BUILT_STUDIO_NOT_RUN'}))
