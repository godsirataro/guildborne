"""Blender-only wrapper: render bounded packet without regenerating historical art."""
from hashlib import sha256
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT/'assets/production/world-slice/corridor-landforms-bounded'
RECIPE = ROOT/'production/world/quality-slice/corridor-landforms/landform_recipe.py'


def main():
    spec = importlib.util.spec_from_file_location('historical_landforms', RECIPE)
    recipe = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(recipe)
    packet_path = OUT/'scenery.mesh.json'
    raw = packet_path.read_bytes()
    proof = json.loads((Path(__file__).parent/'bounds-proof.json').read_text(encoding='utf-8'))
    assert sha256(raw).hexdigest() == proof['outputSha256']
    recipe.OUT = OUT
    recipe.write_packet = lambda *_args, **_kwargs: json.loads(raw)
    recipe.render(recipe.DESCRIPTOR, recipe.GROUND)
    evidence_path = OUT/'render-evidence.json'
    evidence = json.loads(evidence_path.read_text(encoding='utf-8'))
    evidence.update(packetSha256=sha256(raw).hexdigest(), wrapperSha256=sha256(Path(__file__).read_bytes()).hexdigest(),
                    historicalRecipeSha256=sha256(RECIPE.read_bytes()).hexdigest(),
                    partitionSourceSha256=sha256((Path(__file__).parent/'partition.py').read_bytes()).hexdigest())
    evidence_path.write_text(json.dumps(evidence, indent=2)+'\n', encoding='utf-8')
    assert packet_path.read_bytes() == raw


if __name__ == '__main__':
    main()
