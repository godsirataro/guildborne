"""Build an isolated client-only cue probe; never sync, upload or publish."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[3]
out = ROOT / 'build/combat-cue-review'
out.mkdir(parents=True, exist_ok=True)
probe = ROOT / 'production/integration/enemy-quality/combat_cue_probe.luau'
assert probe.is_file(), 'Integrate the reviewed probe before building'
runtime = ROOT / 'offline/Runtime.luau'
runtime_source = runtime.read_text(encoding='utf-8-sig')
assert 'StudioPersistence = "Memory"' in runtime_source or 'StudioPersistence="Memory"' in runtime_source
probe_copy = out / 'CombatCueProbe.client.luau'
probe_copy.write_bytes(probe.read_bytes())
client = {'$className': 'Folder', 'Runtime': {'$path': str(runtime)}}
for entry in sorted((ROOT / 'src/client').iterdir()):
    if entry.is_dir():
        client[entry.name] = {'$path': str(entry)}
    elif entry.suffix == '.luau':
        name = entry.stem.removesuffix('.client').removesuffix('.server')
        client[name] = {'$path': str(entry)}
        if name == 'ClientBootstrap':
            client[name]['$properties'] = {'Disabled': True}
project = {'name': 'Guildborne_CombatCueReview', 'serveAddress': '127.0.0.1', 'tree': {
    '$className': 'DataModel',
    'Workspace': {'$className': 'Workspace',
        'ProbeSpawnFloor': {'$className': 'Part', '$properties': {
            'Anchored': True, 'CanCollide': True, 'Size': [64, 1, 64],
            'Position': [0, 0, 0]}},
        'ProbeSpawn': {'$className': 'SpawnLocation', '$properties': {
            'Anchored': True, 'CanCollide': True, 'Enabled': True,
            'Neutral': True, 'Duration': 0, 'Size': [12, 1, 12],
            'Position': [0, 1, 0]}}},
    'ReplicatedStorage': {'$className': 'ReplicatedStorage',
        'Shared': {'$path': str(ROOT / 'src/shared')}, 'CombatCueProbeClient': client},
    'StarterPlayer': {'$className': 'StarterPlayer', 'StarterPlayerScripts': {
        '$className': 'StarterPlayerScripts', 'CombatCueProbe': {
            '$path': str(probe_copy), '$properties': {'Disabled': True}}}},
}}
project_path = out / 'review.project.json'
project_path.write_text(json.dumps(project, indent=2), encoding='utf-8', newline='\n')
place = out / 'Guildborne_CombatCueReview.rbxlx'
subprocess.run([str(ROOT / '.tools/rojo/rojo.exe'), 'build', str(project_path), '--output', str(place)], check=True, cwd=ROOT)
receipt = {'status': 'BUILT_NOT_STUDIO_TESTED',
    'sourceCommit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
    'candidateSha256': hashlib.sha256(place.read_bytes()).hexdigest(),
    'probeSha256': hashlib.sha256(probe.read_bytes()).hexdigest(),
    'noServerBootstrap': True, 'clientBootstrapDisabled': True,
    'probeInitiallyDisabled': True, 'staticNeutralSpawn': True,
    'requiresObservedClientWarmupAndManualProbeEnable': True,
    'runtime': str(runtime), 'project': str(project_path), 'place': str(place)}
(out / 'build-receipt.json').write_text(json.dumps(receipt, indent=2), encoding='utf-8', newline='\n')
print(json.dumps(receipt, indent=2))
